package com.websthewords.giftlog;

import android.app.Application;
import android.content.Context;

import com.facebook.FacebookSdk;
import com.google.firebase.database.FirebaseDatabase;
import com.nostra13.universalimageloader.cache.disc.naming.Md5FileNameGenerator;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.ImageLoaderConfiguration;
import com.nostra13.universalimageloader.core.assist.QueueProcessingType;
import com.websthewords.giftlog.data.GLPreference;
import com.websthewords.giftlog.data.manage.ReminderManager;

/**
 * @description		Main App
 * 
 * @author          Adrian
 */

public class App extends Application {

    public static Context gContext;

    @Override
    public void onCreate() {
        super.onCreate();

        FacebookSdk.sdkInitialize(this.getApplicationContext());
        FirebaseDatabase.getInstance().setPersistenceEnabled(true);

        GLPreference.initialize(this);
        ReminderManager.initialize(this);

        initImageLoader(this);

        gContext = this;
    }

    public static void initImageLoader(Context context) {
        // This configuration tuning is custom. You can tune every option, you may tune some of them,
        // or you can create default configuration by
        //  ImageLoaderConfiguration.createDefault(this);
        // method.
        ImageLoaderConfiguration.Builder config = new ImageLoaderConfiguration.Builder(context);
        config.threadPriority(Thread.NORM_PRIORITY - 2);
        config.denyCacheImageMultipleSizesInMemory();
        config.diskCacheFileNameGenerator(new Md5FileNameGenerator());
        config.diskCacheSize(50 * 1024 * 1024); // 50 MiB
        config.tasksProcessingOrder(QueueProcessingType.LIFO);

        // Initialize ImageLoader with configuration.
        ImageLoader.getInstance().init(config.build());
    }
}