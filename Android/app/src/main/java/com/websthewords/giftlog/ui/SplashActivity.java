package com.websthewords.giftlog.ui;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;

import com.google.firebase.auth.FirebaseAuth;
import com.websthewords.giftlog.R;
import com.websthewords.giftlog.data.GLPreference;
import com.websthewords.giftlog.data.manage.DataManager;
import com.websthewords.giftlog.ui.base.BaseActivity;

/**
 * @description     Splash Activity
 *
 * @author          Adrian
 */
public class SplashActivity extends BaseActivity {

    // Variables
    private final int SPLASH_DURATION = 3 * 1000;       // 2 seconds

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);

        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                if (GLPreference.isFirstRun()) {
                    startActivity(new Intent(SplashActivity.this, TutorialActivity.class));
                }
                else {
                    if (FirebaseAuth.getInstance().getCurrentUser() != null) {
                        DataManager.getInstance().initialize();
                        startActivity(new Intent(SplashActivity.this, MainActivity.class));
                    }
                    else {
                        startActivity(new Intent(SplashActivity.this, LoginActivity.class));
                    }
                }

                finish();
            }
        }, SPLASH_DURATION);
    }

}
