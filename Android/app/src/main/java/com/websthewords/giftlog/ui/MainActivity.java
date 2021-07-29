package com.websthewords.giftlog.ui;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.jeremyfeinstein.slidingmenu.lib.SlidingMenu;
import com.websthewords.giftlog.R;
import com.websthewords.giftlog.data.manage.DataManager;
import com.websthewords.giftlog.data.model.enums.InOutType;
import com.websthewords.giftlog.data.model.event.UserProfileChangedEvent;
import com.websthewords.giftlog.data.model.firebase.fbContact;
import com.websthewords.giftlog.data.model.firebase.fbEvent;
import com.websthewords.giftlog.data.model.firebase.fbGift;
import com.websthewords.giftlog.data.model.firebase.fbPreloader;
import com.websthewords.giftlog.data.model.firebase.fbUser;
import com.websthewords.giftlog.ui.base.BaseActivity;
import com.websthewords.giftlog.ui.fragment.ContactsFragment;
import com.websthewords.giftlog.ui.fragment.EventsFragment;
import com.websthewords.giftlog.ui.fragment.GiftIdeasFragment;
import com.websthewords.giftlog.ui.fragment.GiftsFragment;
import com.websthewords.giftlog.ui.base.FragmentBaseActivity;
import com.websthewords.giftlog.ui.creation.CreateProfileActivity;
import com.websthewords.giftlog.utils.ImageUtil;
import com.websthewords.giftlog.utils.StringUtils;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.util.ArrayList;

import butterknife.Bind;
import butterknife.ButterKnife;

/**
 * @description     Main Activity
 *
 * @author          Adrian
 */
public class MainActivity extends BaseActivity {

    private final int TAB_GIFTS = 100;
    private final int TAB_EVENTS = 200;
    private final int TAB_CONTACTS = 300;
    private final int TAB_GIFT_IDEAS = 400;

    // UI Controls
    @Bind(R.id.tabGifts)        View tabGifts;
    @Bind(R.id.tabEvents)       View tabEvents;
    @Bind(R.id.tabContacts)     View tabContacts;
    @Bind(R.id.tabGiftIdeas)    View tabGiftIdeas;

    @Bind(R.id.tvTitle)         TextView tvTitle;

    TextView tvUserName;
    ImageView ivUserImage;

    // Variables
    private int currentTab;
    private SlidingMenu mMenu = null;
    private FirebaseAuth mAuth;
    private FirebaseUser mCurrentUser;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        ButterKnife.bind(this);

        setupLeftMenu();
        switchTab(TAB_GIFTS);

        tvUserName = (TextView) findViewById(R.id.tvUserName);
        ivUserImage = (ImageView) findViewById(R.id.ivUserImage);
    }

    @Override
    public void onStart() {
        super.onStart();

        mAuth = FirebaseAuth.getInstance();
        mCurrentUser = mAuth.getCurrentUser();

        if (mCurrentUser == null)
            finish();

        if (!EventBus.getDefault().isRegistered(this))
            EventBus.getDefault().register(this);

        updateUserProfile();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();

        EventBus.getDefault().unregister(this);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onMessageEvent(UserProfileChangedEvent event) {
        updateUserProfile();
    }

    private void updateUserProfile() {
        fbUser user = DataManager.getInstance().getUserProfile();

        if (user == null)
            return;

        if (!TextUtils.isEmpty(user.getFirstName()) || !TextUtils.isEmpty(user.getLastName()))
            tvUserName.setText(user.getFirstName() + " " + user.getLastName());
        else
            tvUserName.setText(R.string.username);

        ImageUtil.displayUserImage(ivUserImage, user.getAvatar(), null);
    }

    /**
     * Setup Side Menu
     */
    private void setupLeftMenu() {
        mMenu = new SlidingMenu(this);
        mMenu.setMode(SlidingMenu.LEFT);
        mMenu.setBehindOffset((int) (getResources().getDimension(
                R.dimen.sideMenuOffset) / getResources().getDisplayMetrics().density));
        mMenu.setFadeDegree(0.35f);
        mMenu.setFadeEnabled(true);
        mMenu.setSlidingEnabled(true);
        mMenu.setTouchModeAbove(SlidingMenu.TOUCHMODE_MARGIN);
        mMenu.setTouchModeBehind(SlidingMenu.TOUCHMODE_MARGIN);

        mMenu.attachToActivity(this, SlidingMenu.SLIDING_WINDOW);
        mMenu.setMenu(R.layout.layout_menu);
    }

    public void onMenu(View v) {
        if (mMenu != null)
            mMenu.toggle();
    }

    public void onSearch(View v) {
        startActivity(new Intent(this, SearchActivity.class));
    }

    public void onTabClick(View v) {
        switch (v.getId()) {
            case R.id.tabGifts:
                switchTab(TAB_GIFTS);
                break;

            case R.id.tabEvents:
                switchTab(TAB_EVENTS);
                break;

            case R.id.tabContacts:
                switchTab(TAB_CONTACTS);
                break;

            case R.id.tabGiftIdeas:
                switchTab(TAB_GIFT_IDEAS);
                break;
        }
    }

    /**
     * Side Bar Item Click Event Handler
     */
    public void onMenuItemClick(View v) {
        int fragmentId = -1;

        switch (v.getId()) {
            case R.id.layoutProfile:
                startActivity(new Intent(this, CreateProfileActivity.class));
                break;

            case R.id.layoutGifts:
                switchTab(TAB_GIFTS);
                break;

            case R.id.layoutEvents:
                switchTab(TAB_EVENTS);
                break;

            case R.id.layoutContacts:
                switchTab(TAB_CONTACTS);
                break;

            case R.id.layoutGiftIdeas:
                switchTab(TAB_GIFT_IDEAS);
                break;

            case R.id.layoutFaq:
                startDocumentViewerActivity(DocumentViewActivity.PAGE_FAQ);
                break;

            case R.id.layoutShareApp:
                String text = String.format("%s%s\n\n", getResources().getString(R.string.share_app_text), tvUserName.getText().toString());
                text += getResources().getString(R.string.download_app_text);
                doShare(text);
                break;

            case R.id.layoutEmailGift:
                requestSendEmailGift();
                break;

            case R.id.layoutPrivacyPolicy:
                startDocumentViewerActivity(DocumentViewActivity.PAGE_POLICY);
                break;

            case R.id.layoutTermsConditions:
                startDocumentViewerActivity(DocumentViewActivity.PAGE_TERMS);
                break;

            case R.id.layoutContactUs:
                startDocumentViewerActivity(DocumentViewActivity.PAGE_CONTACTUS);
                break;

            case R.id.layoutLogout:
                requestLogOut();
                break;
        }

        mMenu.toggle();
    }

    protected void switchTab(int tabWhat) {
        if (currentTab == tabWhat)
            return;

        switch (tabWhat) {
            case TAB_GIFTS:
                addFragment(new GiftsFragment(), true);
                tvTitle.setText(R.string.sm_gifts);
                break;

            case TAB_EVENTS:
                addFragment(new EventsFragment(), true);
                tvTitle.setText(R.string.sm_events);
                break;

            case TAB_CONTACTS:
                addFragment(new ContactsFragment(), true);
                tvTitle.setText(R.string.sm_contacts);
                break;

            case TAB_GIFT_IDEAS:
                addFragment(new GiftIdeasFragment(), true);
                tvTitle.setText(R.string.sm_gift_ideas);
                break;
        }

        tabGifts.setVisibility((tabWhat == TAB_GIFTS) ? View.GONE : View.VISIBLE);
        tabEvents.setVisibility((tabWhat == TAB_EVENTS) ? View.GONE : View.VISIBLE);
        tabContacts.setVisibility((tabWhat == TAB_CONTACTS) ? View.GONE : View.VISIBLE);
        tabGiftIdeas.setVisibility((tabWhat == TAB_GIFT_IDEAS) ? View.GONE : View.VISIBLE);

        currentTab = tabWhat;
    }

    private void startDocumentViewerActivity(int what) {
        Intent intent = new Intent(this, DocumentViewActivity.class);
        intent.putExtra(DocumentViewActivity.PARAM_WHAT, what);
        startActivity(intent);
    }

    protected void requestLogOut() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(R.string.logout_confirm);
        builder.setPositiveButton(R.string.logout, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                DataManager.getInstance().signOut();
                startActivity(new Intent(MainActivity.this, LoginActivity.class));
                finish();
            }
        });
        builder.setNegativeButton(android.R.string.cancel, null);
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
    }

    @Override
    public void updateUI() {
        if (mSelectedFragment == null)
            return;

        ((View)findViewById(R.id.layoutGifts)).setBackgroundResource((mSelectedFragment instanceof GiftsFragment) ? R.color.colorMagento : R.drawable.menu_bg_shape);
        ((View)findViewById(R.id.layoutEvents)).setBackgroundResource((mSelectedFragment instanceof EventsFragment) ? R.color.colorMagento : R.drawable.menu_bg_shape);
        ((View)findViewById(R.id.layoutContacts)).setBackgroundResource((mSelectedFragment instanceof ContactsFragment) ? R.color.colorMagento : R.drawable.menu_bg_shape);
        ((View)findViewById(R.id.layoutGiftIdeas)).setBackgroundResource((mSelectedFragment instanceof GiftIdeasFragment) ? R.color.colorMagento : R.drawable.menu_bg_shape);
    }

    String[]                            giftTypesArray;
    String[]                            giftStatusArray;

    /**
     * Send Gift via Email
     */
    private void requestSendEmailGift() {
        ArrayList<fbGift> allGifts = DataManager.getInstance().getAllGifts();

        giftTypesArray = getResources().getStringArray(R.array.giftTypes);
        giftStatusArray = getResources().getStringArray(R.array.giftStatus);

        String csvText = "Name,In/Out,Gift type,Description,Value,Reciept type,Status,Event,Contacts\n";
        String inOutString, typeString, receiptString, statusString, eventTitle, eventStarts, eventEnds;
        String contactsString = "";
        for (fbGift gift : allGifts) {

            if (gift.getInOutType() == InOutType.RECEIVED)
                inOutString = "Received";
            else
                inOutString = "Given";

            if (gift.getType() > 0)
                typeString = giftTypesArray[gift.getType()];
            else
                typeString = "-";

            if (gift.getStatus() > 0)
                statusString = giftStatusArray[gift.getStatus()];
            else
                statusString = "-";

            if (gift.getRecieptType() == 0)
                receiptString = "No";
            else
                receiptString = "Yes";

            eventTitle = "-";
            eventStarts = "-";
            eventEnds = "-";

            if (gift.getEventPreloader() != null) {
                fbEvent event = DataManager.getInstance().getEventById(gift.getEventPreloader().getIdentifier());
                eventTitle = event.getEventTitle();
                eventStarts = StringUtils.getDateFromMiliseconds(event.getDateStart());
                eventEnds = StringUtils.getDateFromMiliseconds(event.getDateEnd());
            }

            csvText += String.format("%s,%s,%s,%s,%s,%s,%s,",
                    gift.getName(), inOutString, typeString, gift.getDescription(), gift.price,
                    receiptString, statusString);

            // add event text
            csvText += String.format("Name: %s Starts: %s Ends: %s,", eventTitle, eventStarts, eventEnds);

            // add contacts
            if (gift.getContacts() != null && gift.getContacts().size() > 0) {
                contactsString = "";
                for (fbPreloader preloader : gift.getContacts()) {
                    fbContact contact = DataManager.getInstance().getContactById(preloader.getIdentifier());
                    contactsString += String.format("Name: %s Number: %s; ", contact.getFullName(), contact.getPhoneNumber());
                }
            }
            else {
                contactsString = "-";
            }

            csvText += String.format("%s\n", contactsString);
        }

        // Now ready to send email
        String fileName = "giftLogFile.csv";

        File csvFile = new File(Environment.getExternalStorageDirectory()  + "/" + fileName);

        try {
            FileOutputStream fos = new FileOutputStream (csvFile);
            OutputStreamWriter outputStream  = new OutputStreamWriter(fos);
            outputStream.write(csvText);
            outputStream.close();
        } catch (Exception e) {
            e.printStackTrace();
        }

        sendViaEmail(csvFile);
    }

    private void sendViaEmail(File file) {
        try {
            Intent intent = new Intent(Intent.ACTION_SEND);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.setType("vnd.android.cursor.item/email");
            intent.putExtra(Intent.EXTRA_EMAIL, new String[] {"email@example.com"});
            Uri fileUri = Uri.fromFile(file);
            intent.putExtra(android.content.Intent.EXTRA_STREAM, Uri.parse("file://" + fileUri));
            intent.putExtra(Intent.EXTRA_SUBJECT, "");
            intent.putExtra(Intent.EXTRA_TEXT, "CSV File from GiftLog App");
            startActivity(intent);
        } catch(Exception e)  {
            System.out.println("is exception raises during sending mail"+e);
        }
    }
}

