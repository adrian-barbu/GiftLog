package com.websthewords.giftlog.ui.creation;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.media.Image;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.annotation.NonNull;
import android.text.Editable;
import android.text.InputType;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.LinearInterpolator;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.PopupMenu;
import android.widget.ScrollView;
import android.widget.TextView;

import com.baoyz.swipemenulistview.SwipeMenu;
import com.baoyz.swipemenulistview.SwipeMenuItem;
import com.baoyz.swipemenulistview.SwipeMenuLayout;
import com.baoyz.swipemenulistview.SwipeMenuView;
import com.github.aakira.expandablelayout.ExpandableLinearLayout;
import com.github.aakira.expandablelayout.ExpandableRelativeLayout;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;
import com.websthewords.giftlog.R;
import com.websthewords.giftlog.data.manage.DataManager;
import com.websthewords.giftlog.data.model.enums.InOutType;
import com.websthewords.giftlog.data.model.event.ContactChangedEvent;
import com.websthewords.giftlog.data.model.event.EventChangedEvent;
import com.websthewords.giftlog.data.model.firebase.fbContact;
import com.websthewords.giftlog.data.model.firebase.fbEvent;
import com.websthewords.giftlog.data.model.firebase.fbGift;
import com.websthewords.giftlog.data.model.firebase.fbGiftImage;
import com.websthewords.giftlog.data.model.firebase.fbPreloader;
import com.websthewords.giftlog.data.model.firebase.fbUser;
import com.websthewords.giftlog.phototaker.PhotoTaker;
import com.websthewords.giftlog.ui.ImageViewActivity;
import com.websthewords.giftlog.ui.base.BaseActivity;
import com.websthewords.giftlog.ui.list.SelectContactActivity;
import com.websthewords.giftlog.ui.list.SelectEventActivity;
import com.websthewords.giftlog.utils.ImageUtil;
import com.websthewords.giftlog.utils.StringUtils;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.ArrayList;

import belka.us.androidtoggleswitch.widgets.BaseToggleSwitch;
import belka.us.androidtoggleswitch.widgets.ToggleSwitch;
import butterknife.Bind;
import butterknife.ButterKnife;

/**
 * @description     Create Gift Activity
 *
 * @author          Adrian
 */
public class CreateGiftActivity extends BaseActivity {

    public final static int REQUEST_SELECT_CONTACTS = 1000;
    public final static int REQUEST_SELECT_EVENTS = 2000;

    // Variables
    boolean isRequestReturn;
    boolean isCreateRequestedWithEvent;     // the case when the event is already set
    boolean isCreateRequestedWithContact;   // the case when the contact is already set

    fbGift mGift;                   // Gift Object
    fbGift mOrgGift;

    ArrayList<fbPreloader>              mSelectedContacts;
    fbPreloader                         mSelectedEvent;

    LayoutInflater                      mLayoutInflater;
    String[]                            giftTypesArray;
    String[]                            giftStatusArray;
    String[]                            giftThanksSentOptions;

    int mGiftStatus = 4;                // This is NONE
    boolean isThankSent = false;
    int mGiftType = -1;

    PhotoTaker photoTaker;
    Bitmap giftImageBitmap;

    // UI Controls
    @Bind(R.id.tvGiftTitle)             TextView tvGiftTitle;
    @Bind(R.id.layoutGiftInfo)          View layoutGiftInfo;
    @Bind(R.id.layoutExpGiftInfo)       ExpandableRelativeLayout layoutExpGiftInfo;

    @Bind(R.id.layoutContactInfo)       View layoutContactInfo;
    @Bind(R.id.layoutExpContactInfo)    ExpandableLinearLayout layoutExpContactInfo;

    @Bind(R.id.layoutEventInfo)          View layoutEventInfo;
    @Bind(R.id.layoutExpEventInfo)       ExpandableLinearLayout layoutExpEventInfo;

    @Bind(R.id.etGiftName)              EditText etGiftName;
    @Bind(R.id.toggleInOut)             ToggleSwitch toggleInOut;
    @Bind(R.id.tvGiftType)              TextView tvGiftType;
    @Bind(R.id.etGiftDescription)       EditText etGiftDescription;
    @Bind(R.id.etGiftValue)             EditText etGiftValue;
    @Bind(R.id.toggleGiftReceipt)       ToggleSwitch toggleGiftReceipt;
    @Bind(R.id.tvGiftStatus)             TextView tvGiftStatus;
    @Bind(R.id.ivPictureSelect)          ImageView ivPictureSelect;

    @Bind(R.id.layoutImageList)         ViewGroup layoutImageList;
    @Bind(R.id.layoutContactList)       ViewGroup layoutContactList;
    @Bind(R.id.layoutEventList)         ViewGroup layoutEventList;

    @Bind(R.id.layoutForThanks)         View layoutForThanks;
    @Bind(R.id.layoutSendThanks)        View layoutSendThanks;
    @Bind(R.id.tvThankSent)             TextView tvThankSent;

    @Bind(R.id.ivDelete)                ImageView ivDelete;
    @Bind(R.id.ivGiftImage)             ImageView ivGiftImage;

    @Bind(R.id.scrollView)              ScrollView scrollView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_create_gift);

        ButterKnife.bind(this);

        isRequestReturn = getIntent().getBooleanExtra(PARAM_REQUEST_RETURN, false);

        mLayoutInflater = (LayoutInflater) getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        giftTypesArray = getResources().getStringArray(R.array.giftTypes);
        giftStatusArray = getResources().getStringArray(R.array.giftStatus);
        giftThanksSentOptions = getResources().getStringArray(R.array.giftThanksSentOptions);

        mSelectedContacts = new ArrayList<>();
        photoTaker = new PhotoTaker(this);

        initUI();

        mOrgGift = getIntent().getParcelableExtra(PARAM_ORIGINAL);
        if (mOrgGift != null) {
            mGift = fbGift.clone(mOrgGift);
            bindUI();
        } else {
            // Create new gift here
            mGift = new fbGift();
            mGift.ownerId = getUserId();
            mGift.identifier = DataManager.getInstance().getGiftRoot().push().getKey();
        }

        isCreateRequestedWithEvent = (getIntent().getParcelableExtra(PARAM_SELECTED_EVENT) != null);
        if (isCreateRequestedWithEvent) {
            fbEvent event = getIntent().getParcelableExtra(PARAM_SELECTED_EVENT);

            if (event != null)
                mSelectedEvent = new fbPreloader(event.getIdentifier());
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
    }

    private void initUI() {
        etGiftName.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String title = etGiftName.getText().toString().trim();
                tvGiftTitle.setText(title);
                mGift.name = title;
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });

        etGiftDescription.setRawInputType(InputType.TYPE_CLASS_TEXT);

        toggleInOut.setOnToggleSwitchChangeListener(new BaseToggleSwitch.OnToggleSwitchChangeListener() {
            @Override
            public void onToggleSwitchChangeListener(int position, boolean isChecked) {
                if (position == 0)
                    layoutForThanks.setVisibility(View.VISIBLE);
                else
                    layoutForThanks.setVisibility(View.GONE);

                updateContactListLayout(false);
            }
        });
    }

    private void bindUI() {
        if (mGift == null)
            return;

        ivDelete.setVisibility(View.VISIBLE);

        mGiftType = mGift.getType();
        mGiftStatus = mGift.getStatus();

        tvGiftTitle.setText(mGift.getName());
        etGiftName.setText(mGift.getName());
        toggleInOut.setCheckedTogglePosition(mGift.getInOutType());
        if (mGiftType > 0)
            tvGiftType.setText(giftTypesArray[mGiftType]);
        etGiftDescription.setText(mGift.getDescription());
        toggleGiftReceipt.setCheckedTogglePosition(mGift.getRecieptType());
        etGiftValue.setText(mGift.getPrice());
        tvGiftStatus.setText(giftStatusArray[mGiftStatus]);
        tvThankSent.setText(mGift.isThankYouSent() ? giftThanksSentOptions[0] : giftThanksSentOptions[1]);

        if (mGift.getContacts() != null)
            mSelectedContacts = mGift.getContacts();
        updateContactListLayout(false);

        mSelectedEvent = mGift.getEventPreloader();
        updateEventListLayout(false);

        updateGiftImageListLayout();
    }

    public void onDone(View v) {
        // Validation
        if (!validation())
            return;

        if (mSelectedContacts.isEmpty()) {
            showWarningDialog(R.string.warning_gift_no_contacts_text, R.string.warning_gift_no_contacts);
            return;
        }

        pushTo();

        // Now, create gift
        mWaitDialog.show();

        String giftIdentifier = mGift.getIdentifier();
        fbPreloader newGiftPreloader = new fbPreloader(giftIdentifier);

        // Update Event which was added by this gift
        if (mSelectedEvent != null) {
            fbEvent event = DataManager.getInstance().getEventById(mSelectedEvent.getIdentifier());
            if (event != null) {
                boolean isFound = false;

                if (event.gifts != null) {
                    for (fbPreloader preloader : event.gifts) {
                        if (preloader.getIdentifier().equals(giftIdentifier)) {
                            isFound = true;
                            break;
                        }
                    }
                }

                if (!isFound) {
                    if (event.gifts == null)
                        event.gifts = new ArrayList<>();

                    event.gifts.add(newGiftPreloader);
                    DataManager.getInstance().getEventRoot().child(mSelectedEvent.getIdentifier()).setValue(event);
                }
            }
        }

        // Update Contact which was added by this gift
        if (mSelectedContacts != null && mSelectedContacts.size() > 0) {
            for (fbPreloader preloader : mSelectedContacts) {
                fbContact contact = DataManager.getInstance().getContactById(preloader.getIdentifier());
                if (contact != null) {
                    boolean isFound = false;

                    if (contact.gifts != null) {
                        for (fbPreloader pre : contact.gifts) {
                            if (pre.getIdentifier().equals(giftIdentifier)) {
                                isFound = true;
                                break;
                            }
                        }
                    }

                    if (!isFound) {
                        if (contact.gifts == null)
                            contact.gifts = new ArrayList<>();

                        contact.gifts.add(newGiftPreloader);
                        DataManager.getInstance().getContactRoot().child(preloader.getIdentifier()).setValue(contact);
                    }
                }
            }
        }

        // Save Gifts
        DataManager.getInstance().getGiftRoot().child(giftIdentifier).setValue(mGift, new DatabaseReference.CompletionListener() {
            @Override
            public void onComplete(DatabaseError databaseError, DatabaseReference databaseReference) {
                mWaitDialog.dismiss();

                mOrgGift = fbGift.clone(mGift);

                if (isRequestReturn || isCreateRequestedWithContact || isCreateRequestedWithEvent)
                {
                    Intent returnIntent = new Intent();
                    returnIntent.putExtra("result", mGift);
                    setResult(Activity.RESULT_OK, returnIntent);
                    finish();
                }
            }
        });
    }

    private void pushTo() {
        mGift.name = etGiftName.getText().toString().trim();
        mGift.inOutType = toggleInOut.getCheckedTogglePosition();
        if (mGiftType > 0)
            mGift.type = mGiftType;
        mGift.description = etGiftDescription.getText().toString().trim();
        String price = etGiftValue.getText().toString().trim();
        if (!TextUtils.isEmpty(price))
            mGift.price = price;
        mGift.recieptType = toggleGiftReceipt.getCheckedTogglePosition();
        mGift.status = mGiftStatus;

        // Set Contacts
        if (!mSelectedContacts.isEmpty())
            mGift.contacts = mSelectedContacts;

        mGift.thankYouSent = isThankSent;

        // Set Event
        if (mSelectedEvent != null)
            mGift.eventPreload = new fbPreloader(mSelectedEvent.getIdentifier());
    }

    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.tvGiftType:
                showTypeItems();
                break;

            case R.id.tvGiftStatus:
                showStatusItems();
                break;

            case R.id.ivPictureSelect:
                requestAddImage(v);
                break;

            case R.id.ivAddContact:
                requestAddContacts();
                break;

            case R.id.layoutSendThanks:
                requestSendThanks();
                break;

            case R.id.tvThankSent:
                showThanksSentOptions();
                break;

            case R.id.ivAddEvent:
                requestAddEvents();
                break;
        }
    }

    /**
     * Request Add Contact
     */
    private void requestAddContacts() {
        if (!validation())
            return;

        Intent intent = new Intent(this, SelectContactActivity.class);
        intent.putExtra(PARAM_SELECTED_GIFT, mGift);
        intent.putParcelableArrayListExtra(SelectContactActivity.PARAM_SELECTED_CONTACTS, mSelectedContacts);
        startActivityForResult(intent, REQUEST_SELECT_CONTACTS);
    }

    /**
     * Request Add Event
     */
    private void requestAddEvents() {
        if (!validation())
            return;

        if (mSelectedEvent != null) {
            showWarningDialog(R.string.warning_gift_cannot_add_event_more, R.string.warning_gift_cannot_add_event_more_text);
            return;
        }

        Intent intent = new Intent(this, SelectEventActivity.class);
        intent.putExtra(PARAM_SELECTED_GIFT, mGift);
        startActivityForResult(intent, REQUEST_SELECT_EVENTS);
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
                        Intent intent = new Intent(CreateGiftActivity.this, CreateContactActivity.class);
                        intent.putExtra(BaseActivity.PARAM_ORIGINAL, contact);
                        intent.putExtra(PARAM_SELECTED_GIFT, mGift);
                        startActivity(intent);
                    }
                });

                layoutContactList.addView(itemView);
            }
        }

        layoutExpContactInfo.initLayout();

        if (withScroll) {
            layoutExpContactInfo.expand(0, new LinearInterpolator());
            layoutSendThanks.getParent().requestChildFocus(layoutSendThanks, layoutSendThanks);
        }
    }

    /**
     * Update Event List Layout
     */
    public void updateEventListLayout(boolean withScroll) {
        layoutEventList.removeAllViews();

        if (mSelectedEvent != null) {

            final fbEvent event = DataManager.getInstance().getEventById(mSelectedEvent.getIdentifier());

            if (event != null) {
                View itemView = mLayoutInflater.inflate(R.layout.list_item_event_deletable, null);

                ((TextView) itemView.findViewById(R.id.tvEventName)).setText(event.getEventTitle());
                ((TextView) itemView.findViewById(R.id.tvStartDate)).setText(StringUtils.getDateFromMiliseconds(event.getDateStart()));

                View layoutDelete = (View) itemView.findViewById(R.id.layoutDelete);
                layoutDelete.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        mSelectedEvent = null;
                        updateEventListLayout(true);
                    }
                });

                itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Intent intent = new Intent(CreateGiftActivity.this, CreateEventActivity.class);
                        intent.putExtra(BaseActivity.PARAM_ORIGINAL, event);
                        intent.putExtra(PARAM_SELECTED_GIFT, mGift);

                        if (isCreateRequestedWithContact)
                            intent.putExtra(PARAM_SELECTED_CONTACT, getIntent().getParcelableExtra(PARAM_SELECTED_CONTACT));

                        startActivity(intent);
                    }
                });

                SwipeMenu menu = new SwipeMenu(this);
                createMenu(menu);
                View layout = new SwipeMenuLayout(itemView, new SwipeMenuView(menu, null), null, null);
                layoutEventList.addView(layout);

                if (withScroll && itemView != null)
                    itemView.getParent().requestChildFocus(itemView, itemView);
            }
        }

        layoutExpEventInfo.initLayout();

        if (withScroll)
            layoutExpEventInfo.expand(0, new LinearInterpolator());
    }

    /**
     * Update Gift Images Layout
     */
    public void updateGiftImageListLayout() {
        layoutImageList.removeAllViews();

        ArrayList<fbGiftImage> images = mGift.images;
        if (images == null || images.isEmpty()) {
            ivGiftImage.setImageResource(R.drawable.ic_picture_holder);
            return;
        }

        // Set Header Image
        ImageUtil.displayUserImage(ivGiftImage, mGift.images.get(0).getUrl(), null);

        // Set all images
        int sizeOfImage = Math.round(getResources().getDimension(R.dimen.giftImageSize));
        int marginLeft = Math.round(getResources().getDimension(R.dimen.giftImageMargin));

        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(sizeOfImage, sizeOfImage);
        lp.setMargins(0, 0, marginLeft, 0);

        for (final fbGiftImage image : images) {
            ImageView newImageView = new ImageView(this);
            newImageView.setLayoutParams(lp);
            newImageView.setScaleType(ImageView.ScaleType.CENTER_CROP);

            ImageUtil.displayImage(newImageView, image.getUrl(), null);

            newImageView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    showImageOptions(image);
                }
            });

            layoutImageList.addView(newImageView);
        }
    }

    private void requestSendThanks() {
        if (!validation())
            return;

        if (mGift.inOutType == InOutType.RECEIVED) {
            if (!mSelectedContacts.isEmpty()) {
                fbUser user = DataManager.getInstance().getUserProfile();
                String name = user.getFirstName() + " " + user.getLastName();

                String message = "Hi,\n\n";
                message += String.format("Thank you for the %s.\n\nRegards,\n%s\n\n", etGiftName.getText().toString(), name);
                message += "Sent from GiftLog – your essential gift management app!\n\n";
                message += "Download the app: www.giftlog.co.uk\n";

                doShare(message);
            } else {
                showWarningDialog(R.string.warning_gift_request_add_contacts, R.string.warning_gift_request_add_contacts_text);
            }
        }
        else {
            showWarningDialog(R.string.warning_gift_cannot_send_thanks, R.string.warning_gift_cannot_send_thanks_text);
        }
    }

    private void showThanksSentOptions() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Thank you sent");
        builder.setItems(giftThanksSentOptions, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                tvThankSent.setText(giftThanksSentOptions[which]);
                isThankSent = (which == 0) ? true : false;
            }
        });
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
    }

    private void showTypeItems() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Gift Type");
        builder.setItems(giftTypesArray, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                tvGiftType.setText(giftTypesArray[which]);
                mGiftType = which;
            }
        });
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
    }

    private void showStatusItems() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Gift Status");
        builder.setItems(giftStatusArray, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                tvGiftStatus.setText(giftStatusArray[which]);
                mGiftStatus = which;
            }
        });
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
    }

    private boolean validation() {
        String giftName = etGiftName.getText().toString();

        if (TextUtils.isEmpty(giftName) || mGiftStatus < 0) {
            showWarningDialog(R.string.warning_create_gift_1_text, R.string.warning_create_gift_1);
            return false;
        }

        return true;
    }

    public void initExpandableControls() {
        layoutGiftInfo.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                layoutExpGiftInfo.toggle();

                if (!layoutExpGiftInfo.isExpanded())
                    ((ImageView)findViewById(R.id.ivGiftArrowIcon)).setImageResource(R.drawable.ic_arrow_up);
                else
                    ((ImageView)findViewById(R.id.ivGiftArrowIcon)).setImageResource(R.drawable.ic_arrow_down);
            }
        });

        layoutContactInfo.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (isCreateRequestedWithContact) {
                    // If contact was set when requesting, there is no need to expand
                    showToast(R.string.warning_contact_info_already_set);
                    return;
                }

                layoutExpContactInfo.toggle();

                if (!layoutExpContactInfo.isExpanded())
                    ((ImageView)findViewById(R.id.ivContactArrowIcon)).setImageResource(R.drawable.ic_arrow_up);
                else
                    ((ImageView)findViewById(R.id.ivContactArrowIcon)).setImageResource(R.drawable.ic_arrow_down);
            }
        });

        layoutEventInfo.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (isCreateRequestedWithEvent) {
                    // If contact was set when requesting, there is no need to expand
                    showToast(R.string.warning_event_info_already_set);
                    return;
                }

                layoutExpEventInfo.toggle();

                if (!layoutExpEventInfo.isExpanded()) {
                    ((ImageView) findViewById(R.id.ivEventArrowIcon)).setImageResource(R.drawable.ic_arrow_up);

                    final int scrollY = (int)scrollView.getX() + scrollView.getHeight();
                    scrollView.postDelayed(new Runnable() {
                        public void run() {
                            scrollView.smoothScrollTo(0, scrollY);
                        }
                    }, 250);
                }
                else
                    ((ImageView)findViewById(R.id.ivEventArrowIcon)).setImageResource(R.drawable.ic_arrow_down);
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

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onMessageEvent(EventChangedEvent event) {
        updateEventListLayout(false);
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
        if (photoTaker != null)
            photoTaker.onActivityResult(requestCode, resultCode, data);

        if (requestCode == REQUEST_SELECT_CONTACTS) {
            if (resultCode == Activity.RESULT_OK) {
                ArrayList<fbContact> contactList = data.getParcelableArrayListExtra("result");
                for (fbContact contact : contactList)
                    mSelectedContacts.add(new fbPreloader(contact.getIdentifier()));
                updateContactListLayout(true);

            } else if (resultCode == Activity.RESULT_CANCELED) {

            }
        }

        else if (requestCode == REQUEST_SELECT_EVENTS) {
            if (resultCode == Activity.RESULT_OK) {
                fbEvent event = data.getParcelableExtra("result");
                mSelectedEvent = new fbPreloader(event.getIdentifier());
                updateEventListLayout(true);
            } else if (resultCode == Activity.RESULT_CANCELED) {

            }
        }
    }

    private void showImageOptions(final fbGiftImage image) {
        final String[] imageEditOptions = getResources().getStringArray(R.array.imageEditOptions);
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setItems(imageEditOptions, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                switch (which) {
                    case 0:     // show image
                        Intent intent = new Intent(CreateGiftActivity.this, ImageViewActivity.class);
                        intent.putExtra(ImageViewActivity.PARAM_IMAGE_URL, image.getUrl());
                        startActivity(intent);
                        break;

                    case 1:     // delete image
                        mGift.images.remove(image);
                        updateGiftImageListLayout();
                        break;
                }

            }
        });
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
    }

    @Override
    public void onBackPressed() {
        pushTo();

        if (mOrgGift != null && mGift.equals(mOrgGift)) {
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
                        mGift = null;
                        finish();
                        break;
                }

            }
        });
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
    }

    public void onDelete(View v) {
        final String[] deleteGiftMenuArray = getResources().getStringArray(R.array.deleteGiftMenu);
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setItems(deleteGiftMenuArray, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                if (which == 0) {
                    deleteGift();
                }
            }
        });
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
    }

    private void deleteGift() {
        mWaitDialog.show();
        DataManager.getInstance().getGiftRoot().child(mGift.getIdentifier()).removeValue(new DatabaseReference.CompletionListener() {
            @Override
            public void onComplete(DatabaseError databaseError, DatabaseReference databaseReference) {
                mWaitDialog.dismiss();
                finish();
            }
        });
    }

    protected void requestAddImage(View v) {
        if (!validation())
            return;

        // Popup menu
        final PopupMenu popup = new PopupMenu(this, v);
        //Inflating the Popup using xml file
        popup.getMenuInflater().inflate(R.menu.popup_add_image, popup.getMenu());

        //registering popup with OnMenuItemClickListener
        popup.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
            public boolean onMenuItemClick(MenuItem item) {
                switch (item.getItemId()) {
                    case R.id.take_picture:
                        photoTaker.setCropfinishListener(new PhotoTaker.OnCropFinishListener() {
                            @Override
                            public boolean OnCropFinish(Uri uri) {
                                if (uri != null) {
                                    // String path = CommonUtils.getPathFromUri(ChatActivity.this, uri);
                                    String decodedUri = Uri.decode(uri.toString());
                                    try {
                                        //ImageUtil.displayUserImageWithNoCache(ivUserImage, "file://" + decodedUri, null);
                                        giftImageBitmap = MediaStore.Images.Media.getBitmap(getContentResolver(), uri);
                                        if (giftImageBitmap != null)
                                            uploadImageData(giftImageBitmap);
                                    } catch (IOException e) {
                                        e.printStackTrace();
                                    }
                                }
                                return false;
                            }
                        });
                        photoTaker.doImageCapture();
                        break;

                    case R.id.choose_photo:
                        photoTaker.setCropfinishListener(new PhotoTaker.OnCropFinishListener() {
                            @Override
                            public boolean OnCropFinish(Uri uri) {
                                if (uri != null) {
                                    // String path = CommonUtils.getPathFromUri(ChatActivity.this, uri);
                                    String path = uri.toString();
                                    try {
                                        //ImageUtil.displayUserImageWithNoCache(ivUserImage, path, null);
                                        giftImageBitmap = MediaStore.Images.Media.getBitmap(getContentResolver(), uri);
                                        if (giftImageBitmap != null)
                                            uploadImageData(giftImageBitmap);
                                    } catch (IOException e) {
                                        e.printStackTrace();
                                    }
                                }
                                return false;
                            }
                        });
                        photoTaker.doPickImage();
                        break;

                    case R.id.cancel:
                        popup.dismiss();
                        break;
                }

                return true;
            }
        });

        popup.show(); //showing popup menu
    }

    /**
     * Upload Image Data
     *
     * @throws IOException
     */
    private void uploadImageData(Bitmap bitmap) throws IOException {
        final String identifier = mGift.getIdentifier();

        String filePath = String.format("images/gift/%s.jpg", identifier);
        FirebaseStorage storage = FirebaseStorage.getInstance();
        StorageReference storageRef = storage.getReference();
        StorageReference mountainImagesRef = storageRef.child(filePath);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, 30, baos);
        byte[] data = baos.toByteArray();

        mWaitDialog.show();

        UploadTask uploadTask = mountainImagesRef.putBytes(data);
        uploadTask.addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception exception) {
                // Handle unsuccessful uploads
                mWaitDialog.dismiss();
            }
        }).addOnSuccessListener(new OnSuccessListener<UploadTask.TaskSnapshot>() {
            @Override
            public void onSuccess(UploadTask.TaskSnapshot taskSnapshot) {
                mWaitDialog.dismiss();

                // taskSnapshot.getMetadata() contains file metadata such as size, content-type, and download URL.
                final Uri downloadUrl = taskSnapshot.getDownloadUrl();

                // save to user data
                if (mGift != null) {
                    if (mGift.images == null)
                        mGift.images = new ArrayList<fbGiftImage>();

                    mGift.images.add(new fbGiftImage(downloadUrl.toString()));

                    updateGiftImageListLayout();
                }
            }
        });
    }
}
