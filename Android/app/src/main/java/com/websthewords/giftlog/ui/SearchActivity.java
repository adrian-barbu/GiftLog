package com.websthewords.giftlog.ui;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.LinearInterpolator;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import com.github.aakira.expandablelayout.ExpandableLinearLayout;
import com.websthewords.giftlog.R;
import com.websthewords.giftlog.data.manage.DataManager;
import com.websthewords.giftlog.data.model.event.ContactChangedEvent;
import com.websthewords.giftlog.data.model.event.EventChangedEvent;
import com.websthewords.giftlog.data.model.event.GiftChangedEvent;
import com.websthewords.giftlog.data.model.firebase.fbContact;
import com.websthewords.giftlog.data.model.firebase.fbEvent;
import com.websthewords.giftlog.data.model.firebase.fbGift;
import com.websthewords.giftlog.ui.base.BaseActivity;
import com.websthewords.giftlog.ui.creation.CreateContactActivity;
import com.websthewords.giftlog.utils.StringUtils;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.ArrayList;

import butterknife.Bind;
import butterknife.ButterKnife;

/**
 * @description     Search Activity
 *
 * @author          Adrian
 */
public class SearchActivity extends BaseActivity {

    public final static int REQUEST_SELECT_CONTACTS = 1000;
    public final static int REQUEST_SELECT_EVENTS = 2000;

    // Variables
    ArrayList<fbGift>                mAllGifts;
    ArrayList<fbEvent>               mAllEvents;
    ArrayList<fbContact>             mAllContacts;

    ArrayList<fbGift>                mSearchedGifts;
    ArrayList<fbEvent>               mSearchedEvents;
    ArrayList<fbContact>             mSearchedContacts;

    LayoutInflater                      mLayoutInflater;

    // UI Controls
    @Bind(R.id.etKeyword)             EditText etKeyword;
    @Bind(R.id.ivClearKeyword)          ImageView ivClearKeyword;

    @Bind(R.id.tvResult)             TextView tvResult;

    @Bind(R.id.layoutGifts)             View layoutGifts;
    @Bind(R.id.layoutExpGifts)       ExpandableLinearLayout layoutExpGifts;

    @Bind(R.id.layoutEvents)          View layoutEvents;
    @Bind(R.id.layoutExpEvents)       ExpandableLinearLayout layoutExpEvents;

    @Bind(R.id.layoutContacts)       View layoutContacts;
    @Bind(R.id.layoutExpContacts)    ExpandableLinearLayout layoutExpContacts;

    @Bind(R.id.layoutGiftList)          ViewGroup layoutGiftList;
    @Bind(R.id.layoutEventList)         ViewGroup layoutEventList;
    @Bind(R.id.layoutContactList)       ViewGroup layoutContactList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_search);

        ButterKnife.bind(this);

        mLayoutInflater = (LayoutInflater) getSystemService(Context.LAYOUT_INFLATER_SERVICE);

        mSearchedGifts = new ArrayList<>();
        mSearchedEvents = new ArrayList<>();
        mSearchedContacts = new ArrayList<>();

        updateAllGifts();
        updateAllEvents();
        updateAllContacts();

        initUI();
        initExpandableControls();
    }

    private void initUI() {
        etKeyword.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                search();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    public void search() {
        String keyword = etKeyword.getText().toString().toLowerCase();

        mSearchedGifts.clear();
        mSearchedEvents.clear();
        mSearchedContacts.clear();

        if (!TextUtils.isEmpty(keyword)) {
            if (mAllGifts != null) {
                for (fbGift gift : mAllGifts) {
                    if (gift.getName().toLowerCase().contains(keyword))
                        mSearchedGifts.add(gift);
                }
            }

            if (mAllEvents != null) {
                for (fbEvent event : mAllEvents) {
                    if (event.getEventTitle().toLowerCase().contains(keyword))
                        mSearchedEvents.add(event);
                }
            }

            if (mAllContacts != null) {
                for (fbContact contact : mAllContacts) {
                    if (contact.getFirstName().toLowerCase().contains(keyword) || contact.getLastName().toLowerCase().contains(keyword))
                        mSearchedContacts.add(contact);
                }
            }
        }

        int count = mSearchedGifts.size() + mSearchedEvents.size() + mSearchedContacts.size();
        tvResult.setText(String.format("%d results found", count));

        updateGiftListLayout(false);
        updateEventListLayout(false);
        updateContactListLayout(false);

        if (mSearchedGifts.size() == 0)
            layoutExpGifts.collapse();
        else
            layoutExpGifts.expand();

        if (mSearchedEvents.size() == 0)
            layoutExpEvents.collapse();
        else
            layoutExpEvents.expand();

        if (mSearchedContacts.size() == 0)
            layoutExpContacts.collapse();
        else
            layoutExpContacts.expand();
    }

    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.ivClearKeyword:
                etKeyword.setText("");
                search();
                break;

        }
    }

    public void onSearch(View v) {
        startActivity(new Intent(this, SearchActivity.class));
    }

    /**
     * Update Gift List Layout
     */
    public void updateGiftListLayout(boolean withScroll) {
        layoutGiftList.removeAllViews();

        if (mSearchedGifts.size() == 0)
            return;

        View itemView;
        for (fbGift gift : mSearchedGifts) {
            itemView = mLayoutInflater.inflate(R.layout.list_item_gift, null);

            ((TextView)itemView.findViewById(R.id.tvGiftName)).setText(gift.getName());
            ((TextView)itemView.findViewById(R.id.tvGiftDescription)).setText(gift.getDescription());

            layoutGiftList.addView(itemView);
        }

        layoutExpGifts.initLayout();
        layoutExpGifts.expand(0, new LinearInterpolator());
    }

    /**
     * Update Event List Layout
     */
    public void updateEventListLayout(boolean withScroll) {
        layoutEventList.removeAllViews();

        if (mSearchedEvents == null) {
            return;
        }

        View itemView;
        for (fbEvent event : mSearchedEvents) {
            itemView = mLayoutInflater.inflate(R.layout.list_item_event, null);
            ((TextView) itemView.findViewById(R.id.tvEventName)).setText(event.getEventTitle());
            ((TextView) itemView.findViewById(R.id.tvStartDate)).setText(StringUtils.getDateFromMiliseconds(event.getDateStart()));

            layoutEventList.addView(itemView);
        }

        layoutExpEvents.initLayout();
        layoutExpEvents.expand(0, new LinearInterpolator());
    }

    /**
     * Update Contact List Layout
     */
    public void updateContactListLayout(boolean withScroll) {
        layoutContactList.removeAllViews();

        if (mSearchedContacts.isEmpty())
            return;

        View itemView;
        for (final fbContact contact : mSearchedContacts) {
            itemView = mLayoutInflater.inflate(R.layout.list_item_contact, null);

            ((TextView)itemView.findViewById(R.id.tvName)).setText(contact.getFullName());
            ((TextView)itemView.findViewById(R.id.tvPhoneNumber)).setText(contact.getPhoneNumber());
            ((View)itemView.findViewById(R.id.layoutShare)).setVisibility(View.GONE);

            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Intent intent = new Intent(SearchActivity.this, CreateContactActivity.class);
                    intent.putExtra(BaseActivity.PARAM_ORIGINAL, contact);
                    startActivity(intent);
                }
            });
            layoutContactList.addView(itemView);
        }

        layoutExpContacts.initLayout();
        layoutExpContacts.expand(0, new LinearInterpolator());
    }

    private void updateAllGifts() {
        mAllGifts = DataManager.getInstance().getAllGifts();
        search();
    }

    private void updateAllEvents() {
        mAllEvents = DataManager.getInstance().getAllEvents();
        search();
    }

    private void updateAllContacts() {
        mAllContacts = DataManager.getInstance().getAllContacts();
        search();
    }

    public void initExpandableControls() {
        layoutGifts.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                layoutExpGifts.toggle();

                if (!layoutExpGifts.isExpanded())
                    ((ImageView)findViewById(R.id.ivGiftArrowIcon)).setImageResource(R.drawable.ic_arrow_up);
                else
                    ((ImageView)findViewById(R.id.ivGiftArrowIcon)).setImageResource(R.drawable.ic_arrow_down);
            }
        });

        layoutEvents.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                layoutExpEvents.toggle();

                if (!layoutExpEvents.isExpanded())
                    ((ImageView)findViewById(R.id.ivEventArrowIcon)).setImageResource(R.drawable.ic_arrow_up);
                else
                    ((ImageView)findViewById(R.id.ivEventArrowIcon)).setImageResource(R.drawable.ic_arrow_down);
            }
        });

        layoutContacts.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                layoutExpContacts.toggle();

                if (!layoutExpContacts.isExpanded())
                    ((ImageView)findViewById(R.id.ivContactArrowIcon)).setImageResource(R.drawable.ic_arrow_up);
                else
                    ((ImageView)findViewById(R.id.ivContactArrowIcon)).setImageResource(R.drawable.ic_arrow_down);
            }
        });
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
    public void onMessageEvent(GiftChangedEvent event) {
        updateAllGifts();
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onMessageEvent(ContactChangedEvent event) {
        updateAllContacts();
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onMessageEvent(EventChangedEvent event) {
        updateAllEvents();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {

    }
}
