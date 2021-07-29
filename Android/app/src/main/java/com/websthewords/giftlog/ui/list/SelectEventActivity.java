package com.websthewords.giftlog.ui.list;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.TextView;

import com.websthewords.giftlog.R;
import com.websthewords.giftlog.adapters.EventItemAdapter;
import com.websthewords.giftlog.data.manage.DataManager;
import com.websthewords.giftlog.data.model.event.EventChangedEvent;
import com.websthewords.giftlog.data.model.firebase.fbContact;
import com.websthewords.giftlog.data.model.firebase.fbEvent;
import com.websthewords.giftlog.ui.base.BaseActivity;
import com.websthewords.giftlog.ui.creation.CreateEventActivity;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.ArrayList;

import butterknife.Bind;
import butterknife.ButterKnife;

/**
 * @description     Event Select Activity
 *
 * @author          Adrian
 */
public class SelectEventActivity extends BaseActivity {
    public final String TAG = SelectEventActivity.class.getName();
    public final static int REQUEST_CREATE_EVENT = 1000;

    // UI Members
    @Bind(R.id.lvEvents)        ListView lvEvents;
    @Bind(R.id.tvNoEvents)      TextView tvNoEvents;

    // Variables
    ArrayList<fbEvent>          mAllEvents;
    EventItemAdapter            mEventItemAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_select_event);

        ButterKnife.bind(this);

        mEventItemAdapter = new EventItemAdapter(this);
        lvEvents.setAdapter(mEventItemAdapter);
        lvEvents.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Intent returnIntent = new Intent();
                returnIntent.putExtra("result", mAllEvents.get(position));
                setResult(Activity.RESULT_OK, returnIntent);
                finish();
            }
        });

        updateUI();
    }

    @Override
    public void updateUI() {
        mAllEvents = DataManager.getInstance().getAllEvents();
        if (mAllEvents == null || mAllEvents.isEmpty()) {
            tvNoEvents.setVisibility(View.VISIBLE);
            return;
        }

        mEventItemAdapter.setData(mAllEvents);
    }

    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.tvCancel:
                setResult(Activity.RESULT_CANCELED, new Intent());
                finish();
                break;
        }
    }

    public void onAddEvent(View v) {
        Intent intent = new Intent(this, CreateEventActivity.class);
        intent.putExtra(PARAM_SELECTED_GIFT, getIntent().getParcelableExtra(PARAM_SELECTED_GIFT));
        startActivityForResult(intent, REQUEST_CREATE_EVENT);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CREATE_EVENT) {
            if (resultCode == Activity.RESULT_OK) {
                fbEvent event = data.getParcelableExtra("result");

                Intent returnIntent = new Intent();
                returnIntent.putExtra("result", event);
                setResult(Activity.RESULT_OK, returnIntent);
                finish();
            } else if (resultCode == Activity.RESULT_CANCELED) {

            }
        }
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
    public void onMessageEvent(EventChangedEvent event) {
        updateUI();
    }

}