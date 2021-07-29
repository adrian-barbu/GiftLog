package com.websthewords.giftlog.ui;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.text.TextUtils;
import android.view.View;
import android.widget.EditText;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.FirebaseAuth;
import com.websthewords.giftlog.R;
import com.websthewords.giftlog.ui.base.BaseActivity;
import com.websthewords.giftlog.utils.StringUtils;

/**
 * @description     Forgot Password Activity
 *
 * @author          Adrian
 */
public class ForgotPasswordActivity extends BaseActivity {

    // Variables
    EditText etEmail;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_forgot_password);

        etEmail = (EditText)findViewById(R.id.etEmail);

    }

    /**
     * Back Event Handler
     *
     * @param v
     */
    public void onBack(View v) {
        startActivity(new Intent(this, LoginActivity.class));
        finish();
    }

    public void onStart(View v) {
        String email = etEmail.getText().toString();
        if (TextUtils.isEmpty(email)) {
            showToast(R.string.warning_all_field_required);
            return;
        } else if (!StringUtils.isEmailValid(email)) {
            showToast(R.string.wrong_invalid_email);
            return;
        }

        // Send Reset Email
        FirebaseAuth.getInstance().sendPasswordResetEmail(email)
                .addOnCompleteListener(new OnCompleteListener<Void>() {
                    @Override
                    public void onComplete(@NonNull Task<Void> task) {
                        if (task.isSuccessful()) {
                            showToast("Reset password email is sent.");
                            onBack(null);
                        }
                        else {
                            showToast("There is no exist user or something is wrong.");
                        }
                    }
                });
    }
}
