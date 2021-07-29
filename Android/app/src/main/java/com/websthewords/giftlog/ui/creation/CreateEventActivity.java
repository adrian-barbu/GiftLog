package com.websthewords.giftlog.ui.creation;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.text.Editable;
import android.text.InputType;
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
import android.widget.ScrollView;
import android.widget.TextView;

import com.baoyz.swipemenulistview.SwipeMenu;
import com.baoyz.swipemenulistview.SwipeMenuItem;
import com.baoyz.swipemenulistview.SwipeMenuLayout;
import com.baoyz.swipemenulistview.SwipeMenuView;
import com.github.aakira.expandablelayout.ExpandableLinearLayout;
import com.github.aakira.expandablelayout.ExpandableRelativeLayout;
import com.github.florent37.singledateandtimepicker.SingleDateAndTimePicker;
import com.github.florent37.singledateandtimepicker.dialog.SingleDateAndTimePickerDialog;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.websthewords.giftlog.R;
import com.websthewords.giftlog.data.GLPreference;
import com.websthewords.giftlog.data.manage.DataManager;
import com.websthewords.giftlog.data.manage.ReminderManager;
import com.websthewords.giftlog.data.model.enums.InOutType;
import com.websthewords.giftlog.data.model.event.ContactChangedEvent;
import com.websthewords.giftlog.data.model.firebase.fbContact;
import com.websthewords.giftlog.data.model.firebase.fbEvent;
import com.websthewords.giftlog.data.model.firebase.fbGift;
import com.websthewords.giftlog.data.model.firebase.fbGiftImage;
import com.websthewords.giftlog.data.model.firebase.fbPreloader;
import com.websthewords.giftlog.data.model.firebase.fbUser;
import com.websthewords.giftlog.ui.base.BaseActivity;
import com.websthewords.giftlog.ui.list.SelectContactActivity;
import com.websthewords.giftlog.utils.ImageUtil;
import com.websthewords.giftlog.utils.StringUtils;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.ArrayList;
import java.util.Date;

import belka.us.androidtoggleswitch.widgets.ToggleSwitch;
import butterknife.Bind;
import butterknife.ButterKnife;

/**
 * @description     Create Event Activity
 *
 * @author          Adrian
 */
public class CreateEventActivity extends BaseActivity {

    public final static int REQUEST_SELECT_CONTACTS = 1000;
    public final static int REQUEST_SELECT_GIFT = 2000;

    // Variables
    boolean isCreateRequestedWithGift;      // the case when the gift is already set
    boolean isCreateRequestedWithContact;   // the case when the contact is already set

    LayoutInflater                      mLayoutInflater;

    fbEvent mEvent;                     // edit event object
    fbEvent mOrgEvent;

    ArrayList<fbPreloader>              mSelectedContacts;
    ArrayList<fbPreloader>              mSelectedGifts;

    long startDate;
    long endDate;

    boolean isRequestReturn = false;

    // UI Controls
    @Bind(R.id.tvEventTitle)            TextView tvEventTitle;
    @Bind(R.id.etEventTitle)            EditText etEventTitle;
    @Bind(R.id.tvStartDate)             TextView tvStartDate;
    @Bind(R.id.tvEndDate)               TextView tvEndDate;
    @Bind(R.id.etEventType)             EditText etEventType;
    @Bind(R.id.etDescription)           EditText etDescription;
    @Bind(R.id.toggleHostingType)       ToggleSwitch toggleHostingType;

    @Bind(R.id.layoutContactList)       ViewGroup layoutContactList;
    @Bind(R.id.layoutGiftList)          ViewGroup layoutGiftList;

    @Bind(R.id.etLikes)                 EditText etLikes;
    @Bind(R.id.etDislikes)              EditText etDislikes;

    @Bind(R.id.layoutInfo)              View layoutInfo;
    @Bind(R.id.layoutExpInfo)           ExpandableRelativeLayout layoutExpInfo;

    @Bind(R.id.layoutAttendees)         View layoutAttendees;
    @Bind(R.id.layoutExpAttendees)      ExpandableLinearLayout layoutExpAttendees;

    @Bind(R.id.layoutGifts)             View layoutGifts;
    @Bind(R.id.layoutExpGifts)          ExpandableLinearLayout layoutExpGifts;

    @Bind(R.id.layoutWishList)          View layoutWishList;
    @Bind(R.id.layoutExpWishList)       ExpandableRelativeLayout layoutExpWishList;
    @Bind(R.id.layoutShare)             View layoutShare;

    @Bind(R.id.ivDelete)                ImageView ivDelete;

    @Bind(R.id.scrollView)              ScrollView scrollView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_create_event);

        ButterKnife.bind(this);

        mLayoutInflater = (LayoutInflater) getSystemService(Context.LAYOUT_INFLATER_SERVICE);

        mSelectedContacts = new ArrayList<>();
        mSelectedGifts = new ArrayList<>();

        initUI();

        mOrgEvent = getIntent().getParcelableExtra(PARAM_ORIGINAL);
        if (mOrgEvent != null) {
            mEvent = fbEvent.clone(mOrgEvent);
            bindUI();
        }
        else {
            // Create new event here
            mEvent = new fbEvent();
            mEvent.ownerId = getUserId();
            mEvent.identifier = DataManager.getInstance().getEventRoot().push().getKey();
        }

        isCreateRequestedWithGift = (getIntent().getParcelableExtra(PARAM_SELECTED_GIFT) != null);
        if (isCreateRequestedWithGift) {
            fbGift gift = getIntent().getParcelableExtra(PARAM_SELECTED_GIFT);
            boolean isAlreadyAdded = false;
            for (fbPreloader preloader : mSelectedGifts) {
                if (preloader.getIdentifier().equals(gift.getIdentifier())) {
                    isAlreadyAdded = true;
                    break;
                }
            }

            if (!isAlreadyAdded)
                mSelectedGifts.add(new fbPreloader(gift.getIdentifier()));
        }

        isCreateRequestedWithContact = (getIntent().getParcelableExtra(PARAM_SELECTED_CONTACT) != null);
        if (isCreateRequestedWithContact) {
            fbContact contact = getIntent().getParcelableExtra(PARAM_SELECTED_CONTACT);

            boolean isAlreadyAdded = false;
            for (fbPreloader preloader : mSelectedContacts) {
                if (preloader.getIdentifier().equals(contact.getIdentifier())) {
                    isAlreadyAdded = true;
                    break;
                }
            }

            if (!isAlreadyAdded)
                mSelectedContacts.add(new fbPreloader(contact.getIdentifier()));
        }

        initExpandableControls();

        layoutExpWishList.collapse();
    }

    private void initUI() {
        etEventTitle.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String title = etEventTitle.getText().toString().trim();
                tvEventTitle.setText(title);
                mEvent.eventTitle = title;
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });

        etDescription.setRawInputType(InputType.TYPE_CLASS_TEXT);
    }

    private void bindUI() {
        if (mEvent == null)
            return;

        ivDelete.setVisibility(View.VISIBLE);

        tvEventTitle.setText(mEvent.getEventTitle());
        etEventTitle.setText(mEvent.getEventTitle());

        startDate = mEvent.getDateStart();
        endDate = mEvent.getDateEnd();
        tvStartDate.setText(StringUtils.getDateFromMiliseconds(startDate));
        tvEndDate.setText(StringUtils.getDateFromMiliseconds(endDate));

        etEventType.setText(mEvent.getEventType());
        etDescription.setText(mEvent.getDescription());
        toggleHostingType.setCheckedTogglePosition(mEvent.getHostingType());

        if (mEvent.getContacts() != null)
            mSelectedContacts = mEvent.getContacts();
        updateContactListLayout(false);

        if (mEvent.getGifts() != null)
            mSelectedGifts = mEvent.getGifts();
        updateGiftListLayout(false);
    }

    public void onDone(View v) {
        // Validation
        if (!validation())
            return;

        pushTo();

        // Now, create event
        mWaitDialog.show();

        String identifier = mEvent.getIdentifier();
        DataManager.getInstance().getEventRoot().child(identifier).setValue(mEvent, new DatabaseReference.CompletionListener() {
            @Override
            public void onComplete(DatabaseError databaseError, DatabaseReference databaseReference) {
                // save push notification
                if (GLPreference.isUseNotification())
                    ReminderManager.saveLocalNotificationForEventIfNeeded(mEvent);

                mWaitDialog.dismiss();

                mOrgEvent = fbEvent.clone(mEvent);

                if (isRequestReturn || isCreateRequestedWithGift || isCreateRequestedWithContact)
                {
                    Intent returnIntent = new Intent();
                    returnIntent.putExtra("result", mEvent);
                    setResult(Activity.RESULT_OK, returnIntent);
                    finish();
                }
            }
        });
    }

    private void pushTo() {
        mEvent.eventTitle = etEventTitle.getText().toString();
        mEvent.dateStart = startDate;
        mEvent.dateEnd = endDate;
        mEvent.eventType = etEventType.getText().toString();
        mEvent.description = etDescription.getText().toString();
        mEvent.hostingType = toggleHostingType.getCheckedTogglePosition();

        mEvent.likes = etLikes.getText().toString();
        mEvent.dislikes = etDislikes.getText().toString();

        // Set Contacts
        if (!mSelectedContacts.isEmpty())
            mEvent.contacts = mSelectedContacts;

        // Set Gifts
        if (!mSelectedGifts.isEmpty())
            mEvent.gifts = mSelectedGifts;
    }

    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.tvStartDate:
                selectStartDate();
                break;

            case R.id.tvEndDate:
                selectEndDate();
                break;

            case R.id.ivAddContact:
                requestAddContacts();
                break;

            case R.id.ivAddGift:
                requestAddGifts();
                break;

            case R.id.layoutShare:
                requestSendShareWishlist();
                break;
        }
    }

    private void selectStartDate() {
        SingleDateAndTimePickerDialog.Builder builder = new SingleDateAndTimePickerDialog.Builder(this)
                .displayListener(new SingleDateAndTimePickerDialog.DisplayListener() {
                    @Override
                    public void onDisplayed(SingleDateAndTimePicker picker) {
                        //retrieve the SingleDateAndTimePicker
                    }
                })
                .title("Start Date & Time")
                .minutesStep(5)
                .listener(new SingleDateAndTimePickerDialog.Listener() {
                    @Override
                    public void onDateSelected(Date date) {
                        startDate = date.getTime() / 1000;
                        tvStartDate.setText(StringUtils.getDateFromMiliseconds(startDate));

                        endDate = date.getTime() / 1000 + 60 * 60;
                        tvEndDate.setText(StringUtils.getDateFromMiliseconds(endDate));
                    }
                });

        if (startDate > 0)
            builder.defaultDate(new Date(startDate * 1000));

        builder.display();
    }

    private void selectEndDate() {
        SingleDateAndTimePickerDialog.Builder builder = new SingleDateAndTimePickerDialog.Builder(this)
                .displayListener(new SingleDateAndTimePickerDialog.DisplayListener() {
                    @Override
                    public void onDisplayed(SingleDateAndTimePicker picker) {
                        //retrieve the SingleDateAndTimePicker
                    }
                })
                .minutesStep(5)
                .title("End Date & Time")
                .listener(new SingleDateAndTimePickerDialog.Listener() {
                    @Override
                    public void onDateSelected(Date date) {
                        endDate = date.getTime() / 1000;
                        tvEndDate.setText(StringUtils.getDateFromMiliseconds(endDate));
                    }
                });

        if (endDate > 0)
            builder.defaultDate(new Date(endDate * 1000));

        builder.display();
    }

    /**
     * Request Add Contact
     */
    private void requestAddContacts() {
        if (!validation())
            return;

        Intent intent = new Intent(this, SelectContactActivity.class);
        intent.putParcelableArrayListExtra(SelectContactActivity.PARAM_SELECTED_CONTACTS, mSelectedContacts);
        startActivityForResult(intent, REQUEST_SELECT_CONTACTS);
    }

    /**
     * Request Add Gift
     */
    private void requestAddGifts() {
        if (!validation())
            return;

        Intent intent = new Intent(this, CreateGiftActivity.class);
        intent.putExtra(PARAM_SELECTED_EVENT, mEvent);
        intent.putExtra(BaseActivity.PARAM_REQUEST_RETURN, true);
        startActivityForResult(intent, REQUEST_SELECT_GIFT);
    }

    /**
     * Update Contact List Layout
     */
    public void updateContactListLayout(boolean withScroll) {
        layoutContactList.removeAllViews();

        if (!mSelectedContacts.isEmpty()) {

            View itemView;
            for (final fbPreloader preloader : mSelectedContacts) {
                final fbContact contact = DataManager.getInstance().getContactById(preloader.getIdentifier());

                if (contact == null)
                    continue;

                itemView = mLayoutInflater.inflate(R.layout.list_item_contact_deletable, null);

                ((TextView) itemView.findViewById(R.id.tvName)).setText(contact.getFullName());
                ((TextView) itemView.findViewById(R.id.tvPhoneNumber)).setText(contact.getPhoneNumber());

                View layoutDelete = (View) itemView.findViewById(R.id.layoutDelete);
                layoutDelete.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        mSelectedContacts.remove(preloader);
                        updateContactListLayout(true);
                    }
                });

                itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Intent intent = new Intent(CreateEventActivity.this, CreateContactActivity.class);
                        intent.putExtra(BaseActivity.PARAM_ORIGINAL, contact);

                        if (isCreateRequestedWithGift)
                            intent.putExtra(PARAM_SELECTED_GIFT, getIntent().getParcelableExtra(PARAM_SELECTED_GIFT));

                        startActivity(intent);
                    }
                });

                layoutContactList.addView(itemView);
            }
        }

        layoutExpAttendees.initLayout();

        if (withScroll) {
            layoutExpAttendees.expand(0, new LinearInterpolator());
            layoutGifts.getParent().requestChildFocus(layoutGifts, layoutGifts);
        }
    }

    /**
     * Update Gift List Layout
     */
    public void updateGiftListLayout(boolean withScroll) {
        layoutGiftList.removeAllViews();

        if (!mSelectedGifts.isEmpty()) {
            View itemView;
            for (final fbPreloader preloader : mSelectedGifts) {
                final fbGift gift = DataManager.getInstance().getGiftById(preloader.getIdentifier());

                if (gift == null)
                    continue;

                itemView = mLayoutInflater.inflate(R.layout.list_item_gift_deletable, null);

                ((TextView) itemView.findViewById(R.id.tvGiftName)).setText(gift.getName());

                ImageView ivGiftImage = (ImageView) itemView.findViewById(R.id.ivGiftImage);

                ArrayList<fbGiftImage> images = gift.images;
                if (images != null && !images.isEmpty())
                    ImageUtil.displayUserImage(ivGiftImage, gift.images.get(0).getUrl(), null);
                else
                    ivGiftImage.setImageResource(R.drawable.ic_gift_item);

                setGiftItemDescription(itemView, gift);

                View layoutDelete = (View) itemView.findViewById(R.id.layoutDelete);
                layoutDelete.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        mSelectedGifts.remove(preloader);
                        updateGiftListLayout(true);
                    }
                });

                itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Intent intent = new Intent(CreateEventActivity.this, CreateGiftActivity.class);
                        intent.putExtra(BaseActivity.PARAM_ORIGINAL, gift);
                        startActivity(intent);
                    }
                });

                layoutGiftList.addView(itemView);
            }
        }

        layoutExpGifts.initLayout();

        if (withScroll) {
            layoutExpGifts.expand(0, new LinearInterpolator());
            layoutWishList.getParent().requestChildFocus(layoutWishList, layoutWishList);
        }
    }

    private void requestSendShareWishlist() {
        fbUser user = DataManager.getInstance().getUserProfile();
        String name = user.getFirstName() + " " + user.getLastName();

        String wouldLike = etLikes.getText().toString().trim();
        String wouldNotLike = etDislikes.getText().toString().trim();

        String message = "Hi,\n\n";
        message += String.format("Here’s my wishlist for %s.\n", etEventTitle.getText().toString().trim());

        if (!TextUtils.isEmpty(wouldLike))
            message += String.format("Would Like:\n%s\n", wouldLike);

        if (!TextUtils.isEmpty(wouldNotLike))
            message += String.format("Would Not Like:\n%s\n", wouldNotLike);

        message += String.format("\n\nRegards,\n%s\n\n", name);
        message += String.format("Sent from GiftLog – your essential gift management app!\n");
        doShare(message);
    }

    private boolean validation() {
        String title = etEventTitle.getText().toString();
        String startDate = tvStartDate.getText().toString();
        String endDate = tvEndDate.getText().toString();

        if (TextUtils.isEmpty(title) || TextUtils.isEmpty(startDate) || TextUtils.isEmpty(endDate)) {
            showWarningDialog(R.string.warning_create_event_1_text, R.string.warning_create_event_1);
            return false;
        }

        return true;
    }

    @Override
    public void onBackPressed() {
        pushTo();

        if (mOrgEvent != null && mEvent.equals(mOrgEvent)) {
            super.onBackPressed();
            return;
        }

        final String[] backMenuArray = getResources().getStringArray(R.array.backMenu);
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(R.string.warning_gift_no_saved_message);
//        builder.setMessage(R.string.warning_gift_no_saved_message);
        builder.setItems(backMenuArray, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                switch (which) {
                    case 0:     // continue
                        dialog.dismiss();
                        break;

                    case 1:     // save
                        dialog.dismiss();
                        isRequestReturn = true;
                        onDone(null);
                        break;

                    case 2:     // discard
                        dialog.dismiss();
                        mEvent = null;
                        finish();
                        break;
                }

            }
        });
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
    }

    public void initExpandableControls() {
        layoutInfo.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                layoutExpInfo.toggle();

                if (!layoutExpInfo.isExpanded())
                    ((ImageView)findViewById(R.id.ivInfoArrowIcon)).setImageResource(R.drawable.ic_arrow_up);
                else
                    ((ImageView)findViewById(R.id.ivInfoArrowIcon)).setImageResource(R.drawable.ic_arrow_down);
            }
        });

        layoutAttendees.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (isCreateRequestedWithContact) {
                    // If contact was set when requesting, there is no need to expand
                    showToast(R.string.warning_contact_info_already_set);
                    return;
                }

                layoutExpAttendees.toggle();

                if (!layoutExpAttendees.isExpanded())
                    ((ImageView)findViewById(R.id.ivAttendeesArrows)).setImageResource(R.drawable.ic_arrow_up);
                else
                    ((ImageView)findViewById(R.id.ivAttendeesArrows)).setImageResource(R.drawable.ic_arrow_down);
            }
        });

        layoutGifts.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (isCreateRequestedWithGift) {
                    // If gift was set when requesting, there is no need to expand
                    showToast(R.string.warning_gift_info_already_set);
                    return;
                }

                layoutExpGifts.toggle();

                if (!layoutExpGifts.isExpanded())
                    ((ImageView)findViewById(R.id.ivGiftsArrowIcon)).setImageResource(R.drawable.ic_arrow_up);
                else
                    ((ImageView)findViewById(R.id.ivGiftsArrowIcon)).setImageResource(R.drawable.ic_arrow_down);
            }
        });

        layoutWishList.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                layoutExpWishList.toggle();
                layoutShare.getParent().requestChildFocus(layoutShare, layoutShare);

                if (!layoutExpWishList.isExpanded()) {
                    ((ImageView) findViewById(R.id.ivWishListIcon)).setImageResource(R.drawable.ic_arrow_up);

                    final int scrollY = (int)scrollView.getX() + scrollView.getHeight();
                    scrollView.postDelayed(new Runnable() {
                        public void run() {
                            scrollView.smoothScrollTo(0, scrollY);
                        }
                    }, 250);

                }
                else {
                    ((ImageView) findViewById(R.id.ivWishListIcon)).setImageResource(R.drawable.ic_arrow_down);
                }
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
    public void onMessageEvent(ContactChangedEvent event) {
        updateContactListLayout(false);
    }

    public void createMenu(SwipeMenu menu) {
        // Test Code
        SwipeMenuItem item = new SwipeMenuItem(this);
        item.setTitle("Item 1");
        item.setBackground(new ColorDrawable(Color.GRAY));
        item.setWidth(300);
        menu.addMenuItem(item);

        item = new SwipeMenuItem(this);
        item.setTitle("Item 2");
        item.setBackground(new ColorDrawable(Color.RED));
        item.setWidth(300);
        menu.addMenuItem(item);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_SELECT_CONTACTS) {
            if (resultCode == Activity.RESULT_OK) {
                ArrayList<fbContact> contactList = data.getParcelableArrayListExtra("result");
                for (fbContact contact : contactList)
                    mSelectedContacts.add(new fbPreloader(contact.getIdentifier()));
                updateContactListLayout(true);
            } else if (resultCode == Activity.RESULT_CANCELED) {

            }
        }

        else if (requestCode == REQUEST_SELECT_GIFT) {
            if (resultCode == Activity.RESULT_OK) {
                try {
                    fbGift gift = data.getParcelableExtra("result");
                    mSelectedGifts.add(new fbPreloader(gift.getIdentifier()));
                    updateGiftListLayout(true);
                } catch (Exception e) {}
            } else if (resultCode == Activity.RESULT_CANCELED) {

            }
        }
    }

    public void onDelete(View v) {
        final String[] deleteEventMenuArray = getResources().getStringArray(R.array.deleteEventMenu);
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setItems(deleteEventMenuArray, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                if (which == 0) {
                    deleteEvent();
                }
            }
        });
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
    }

    private void deleteEvent() {
        mWaitDialog.show();

        ReminderManager.removeOldLocalNotificationOfEvent(mEvent);
        DataManager.getInstance().getEventRoot().child(mEvent.getIdentifier()).removeValue(new DatabaseReference.CompletionListener() {
            @Override
            public void onComplete(DatabaseError databaseError, DatabaseReference databaseReference) {
                mWaitDialog.dismiss();
                finish();
            }
        });
    }

    private void setGiftItemDescription(View itemView, fbGift gift) {
        String description = "";
        if (gift.getInOutType() == InOutType.GIVEN)
            description = "To ";
        else
            description = "From ";

        ArrayList<fbContact> fContactList = new ArrayList<>();

        if (gift.getContacts() != null) {
            fbContact fContact;
            for (fbPreloader preloader : gift.getContacts()) {
                fContact = DataManager.getInstance().getContactById(preloader.getIdentifier());
                if (fContact != null)
                    fContactList.add(fContact);
            }
        }

        if (fContactList.size() == 0)
            description = "";
        else if (fContactList.size() > 1)
            description += String.format("%s and other(s)", fContactList.get(0).getFullName());
        else
            description += fContactList.get(0).getFullName();

        ((TextView) itemView.findViewById(R.id.tvGiftDescription)).setText(description);
    }
}