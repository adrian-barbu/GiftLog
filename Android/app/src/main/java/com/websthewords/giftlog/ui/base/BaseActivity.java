package com.websthewords.giftlog.ui.base;

import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.view.View;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.Toast;

import com.google.firebase.auth.FirebaseAuth;
import com.websthewords.giftlog.R;
import com.websthewords.giftlog.controls.WaitDialog;
import com.websthewords.giftlog.data.model.event.ContactChangedEvent;
import com.websthewords.giftlog.data.model.event.NetworkStatusChangedEvent;
import com.websthewords.giftlog.network.NetworkChangeReceiver;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

/**
 * @description     Base Activity
 *
 * @author          Adrian
 */

public class BaseActivity extends FragmentBaseActivity {
    public final static String PARAM_ORIGINAL = "original";
    public final static String PARAM_REQUEST_RETURN = "return";

    public final static String PARAM_SELECTED_GIFT = "selectedGift";
    public final static String PARAM_SELECTED_EVENT = "selectedEvent";
    public final static String PARAM_SELECTED_CONTACT = "selectedContact";

    // Variables
    public WaitDialog mWaitDialog;
    public AlertDialog mNotConnectedDialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mWaitDialog = new WaitDialog(this);

        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        //builder.setTitle(R.string.app_name);
        builder.setMessage(R.string.not_connected_to_network);
        builder.setNegativeButton(R.string.okay, null);
        mNotConnectedDialog = builder.create();
    }

    @Override
    public void onStart() {
        super.onStart();

        if (!EventBus.getDefault().isRegistered(this))
            EventBus.getDefault().register(this);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();

        EventBus.getDefault().unregister(this);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onMessageEvent(NetworkStatusChangedEvent event) {
        int status = event.getStatus();

        if (status == NetworkChangeReceiver.TYPE_NOT_CONNECTED) {
            if (!mNotConnectedDialog.isShowing())
                mNotConnectedDialog.show();
        } else {
            if (mNotConnectedDialog.isShowing())
                mNotConnectedDialog.dismiss();
        }
    }

    protected String getUserId() {
        return FirebaseAuth.getInstance().getCurrentUser().getUid();
    }

    public void onBack(View v) {
        onBackPressed();
    }

    public void onBackPressed() {
        finish();
    }

    /**
     * Share Message
     *
     */
    protected void doShare(String text) {
        Intent shareIntent = new Intent();
        shareIntent.setAction(Intent.ACTION_SEND);
        shareIntent.putExtra(android.content.Intent.EXTRA_TEXT, text);

        shareIntent.setType("text/plain");

        // Launch sharing dialog for image
        startActivity(Intent.createChooser(shareIntent, "Share App"));
    }

    public void showWarningDialog(int titleResId, int messageResId) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(titleResId);
        builder.setMessage(messageResId);
        builder.setNegativeButton(android.R.string.ok, null);
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
    }

    public void hideSoftKeyboard (View view)
    {
        InputMethodManager imm = (InputMethodManager)getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(view.getApplicationWindowToken(), 0);
    }

    public void showToast(int res_id) {
        Toast.makeText(this, res_id, Toast.LENGTH_SHORT).show();
    }

    public void showToast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }
}
