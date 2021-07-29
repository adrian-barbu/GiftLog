package com.websthewords.giftlog.network;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

import com.websthewords.giftlog.data.model.event.NetworkStatusChangedEvent;

import org.greenrobot.eventbus.EventBus;

/**
 * @description     Network Status Monitoring
 *
 * @author          Adrian
 */

public class NetworkChangeReceiver extends BroadcastReceiver {
    public static int TYPE_WIFI = 1;
    public static int TYPE_MOBILE = 2;
    public static int TYPE_NOT_CONNECTED = 0;

    @Override
    public void onReceive(final Context context, final Intent intent) {
        int status = getConnectivityStatus(context);

        // Send changed message
        EventBus.getDefault().post(new NetworkStatusChangedEvent(status));
    }

    public static int getConnectivityStatus(Context context) {
        ConnectivityManager cm = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);

        NetworkInfo activeNetwork = cm.getActiveNetworkInfo();
        if (null != activeNetwork) {
            if(activeNetwork.getType() == ConnectivityManager.TYPE_WIFI)
                return TYPE_WIFI;

            if(activeNetwork.getType() == ConnectivityManager.TYPE_MOBILE)
                return TYPE_MOBILE;
        }
        return TYPE_NOT_CONNECTED;
    }

    public static String getConnectivityStatusString(Context context) {
        int conn = getConnectivityStatus(context);
        String status = null;
        if (conn == TYPE_WIFI) {
            status = "Wifi enabled";
        } else if (conn == TYPE_MOBILE) {
            status = "Mobile data enabled";
        } else if (conn == TYPE_NOT_CONNECTED) {
            status = "Not connected to Internet";
        }
        return status;
    }
}
