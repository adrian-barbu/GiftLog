package com.websthewords.giftlog.data.manage;

import android.app.AlarmManager;
import android.app.Notification;
import android.app.PendingIntent;
import android.app.TaskStackBuilder;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.provider.Settings;
import android.text.TextUtils;
import android.util.Log;

import com.websthewords.giftlog.R;
import com.websthewords.giftlog.data.GLPreference;
import com.websthewords.giftlog.data.model.firebase.fbEvent;
import com.websthewords.giftlog.ui.MainActivity;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;

/**
 * @description     Reminder Manager For Events
 *
 * @author          Adrian
 */

public class ReminderManager {
    // Constants

    // Variables
    public static Context mContext;

    // Initiailze
    public static void initialize(Context context) {
        mContext = context;
    }

    // Constructor
    private ReminderManager() {

    }

    /**
     * Register scheduled notification for all available events
     */
    public static void saveLocalNotificationsForEvents() {
        if (!GLPreference.isUseNotification())
            return;

        ArrayList<fbEvent> events = DataManager.getInstance().getAllEvents();
        for (fbEvent event: events)
            saveLocalNotificationForEventIfNeeded(event);
    }

    /**
     * Remove all of scheduled notifications
     */
    public static void removeLocalNotificationsForEvents() {
        ArrayList<fbEvent> events = DataManager.getInstance().getAllEvents();
        for (fbEvent event: events)
            removeOldLocalNotificationOfEvent(event);
    }

    /**
     * Register scheduled notification for specific events
     *
     * @param event
     */
    public static void saveLocalNotificationForEventIfNeeded(fbEvent event) {
        if (removeOldLocalNotificationOfEvent(event))
            postNewLocalNotificationForEvent(event);
    }

    /**
     * Register new notification for event
     *
     * @param event
     */
    public static void postNewLocalNotificationForEvent(fbEvent event) {
        if (!GLPreference.isUseNotification())
            return;

        long endTime = event.getDateEnd();
        if (endTime < System.currentTimeMillis() / 1000)
            return;

        AlarmManager alarmManager = (AlarmManager) mContext.getSystemService(mContext.ALARM_SERVICE);
        long reminderTime = (endTime + 24 * 60 * 60) * 1000;

        PendingIntent broadcast = createPendingIntent(event);
        alarmManager.set(AlarmManager.RTC_WAKEUP, reminderTime, broadcast);
    }

    public static boolean removeOldLocalNotificationOfEvent(fbEvent event) {
        AlarmManager alarmManager = (AlarmManager) mContext.getSystemService(mContext.ALARM_SERVICE);
        PendingIntent broadcast = createPendingIntent(event);
        alarmManager.cancel(broadcast);
        return true;
    }

    private static PendingIntent createPendingIntent(fbEvent event) {
        long endTime = event.getDateEnd();

        long reminderTime = (endTime + 24 * 60 * 60) * 1000;

        String title = mContext.getResources().getString(R.string.app_name);
        String description = String.format("We hope %s went well. Don’t forget to log your gifts!", event.getEventTitle());

        Intent notificationIntent = new Intent("android.media.action.DISPLAY_NOTIFICATION");
        notificationIntent.addCategory("android.intent.category.DEFAULT");

        notificationIntent.putExtra("Notification", buildNotification(title, description, endTime));
        notificationIntent.putExtra("NotificationDate", reminderTime);
        notificationIntent.putExtra("NotificationID", endTime);
        notificationIntent.putExtra("eventID", event.getIdentifier());

        return PendingIntent.getBroadcast(mContext, (int)(reminderTime / 1000), notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT);
    }

    private static Notification buildNotification(String title, String description, Long ID){
        Intent notificationIntent = new Intent(mContext, MainActivity.class);

        TaskStackBuilder stackBuilder = TaskStackBuilder.create(mContext);
        stackBuilder.addParentStack(MainActivity.class);
        stackBuilder.addNextIntent(notificationIntent);

        PendingIntent pendingIntent = stackBuilder.getPendingIntent(0, PendingIntent.FLAG_UPDATE_CURRENT);

        Notification.Builder builder = new Notification.Builder(mContext);
        builder.setContentTitle(title);
        if (!TextUtils.isEmpty(description)) {
            builder.setContentText(description);
            builder.setStyle(new Notification.BigTextStyle().bigText(description));
        }
        builder.setSmallIcon(R.drawable.ic_launcher);
        builder.setTicker("Please do not forget to use GiftLog!");
        builder.setAutoCancel(true);
        builder.setVibrate(new long[] { 1000, 1000, 1000, 1000, 1000 });
        builder.setSound(Settings.System.DEFAULT_NOTIFICATION_URI);
        builder.setContentIntent(pendingIntent);

        Log.e("aaa", "notificatino is created!!!");

        return builder.build();
    }
}
