package com.websthewords.giftlog.ui.list;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.ContentResolver;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.os.Bundle;
import android.provider.ContactsContract;
import android.view.View;
import android.widget.ListView;
import android.widget.TextView;

import com.websthewords.giftlog.R;
import com.websthewords.giftlog.adapters.ContactItemAdapter;
import com.websthewords.giftlog.adapters.ContactItemSelectableAdapter;
import com.websthewords.giftlog.data.manage.DataManager;
import com.websthewords.giftlog.data.model.event.ContactChangedEvent;
import com.websthewords.giftlog.data.model.firebase.fbContact;
import com.websthewords.giftlog.data.model.firebase.fbEvent;
import com.websthewords.giftlog.data.model.firebase.fbPreloader;
import com.websthewords.giftlog.ui.base.BaseActivity;
import com.websthewords.giftlog.ui.creation.CreateContactActivity;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.ArrayList;
import java.util.HashMap;

import butterknife.Bind;
import butterknife.ButterKnife;

/**
 * @description     Contact Select Activity
 *
 * @author          Adrian
 */
public class SelectContactActivity extends BaseActivity {
    public final String TAG = SelectContactActivity.class.getName();
    public final static int REQUEST_CREATE_CONTACT = 1000;

    public final static String PARAM_SELECTED_CONTACTS = "selectedContacts";

    // UI Members
    @Bind(R.id.lvContacts)      ListView lvContacts;
    @Bind(R.id.tvNoContacts)    TextView tvNoContacts;

    // Variables
    ArrayList<fbPreloader> mAlreadySelectedContacts;
    ArrayList<fbContact> mSelectedContacts;
    ContactItemSelectableAdapter mContactItemAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_select_contact);

        ButterKnife.bind(this);

        mAlreadySelectedContacts = getIntent().getParcelableArrayListExtra(PARAM_SELECTED_CONTACTS);

        mSelectedContacts = new ArrayList<>();

        mContactItemAdapter = new ContactItemSelectableAdapter(this, new ContactItemSelectableAdapter.OnItemSelectedListener() {
            @Override
            public void onItemSelected(fbContact contact) {
                mSelectedContacts.add(contact);
                mContactItemAdapter.notifyDataSetChanged();
            }

            @Override
            public void onItemUnSelected(fbContact contact) {
                mSelectedContacts.remove(contact);
                mContactItemAdapter.notifyDataSetChanged();
            }
        });
        lvContacts.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE);
        lvContacts.setAdapter(mContactItemAdapter);

        updateUI();
    }

    public void updateUI() {
        ArrayList<fbContact> allContacts = DataManager.getInstance().getAllContacts();

        ArrayList<fbContact> selectableContacts = new ArrayList<>();

        for (fbContact contact : allContacts) {
            if (!isExistInAddedContacts(contact))
                selectableContacts.add(contact);
        }

        if (selectableContacts.isEmpty()) {
            tvNoContacts.setVisibility(View.VISIBLE);
            mContactItemAdapter.setData(selectableContacts, mSelectedContacts);
            return;
        }

        mContactItemAdapter.setData(selectableContacts, mSelectedContacts);
    }

    private boolean isExistInAddedContacts(fbContact contact) {
        if (mAlreadySelectedContacts == null || mAlreadySelectedContacts.isEmpty())
            return false;

        boolean exist = false;
        for (fbPreloader preloader : mAlreadySelectedContacts) {
            if (preloader.getIdentifier().equals(contact.getIdentifier())) {
                exist = true;
                break;
            }
        }
        return exist;
    }

    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.tvCancel:
                setResult(Activity.RESULT_CANCELED, new Intent());
                finish();
                break;

            case R.id.ivDone:
                if (mSelectedContacts != null && !mSelectedContacts.isEmpty()) {
                    onDone();
                } else {
                    showToast(R.string.no_selected_contacts);
                }
                break;
        }
    }

    public void onDone() {
        Intent returnIntent = new Intent();
        returnIntent.putExtra("result", mSelectedContacts);
        setResult(Activity.RESULT_OK, returnIntent);
        finish();
    }

    public void onAddContact(View v) {
        final String[] contactMenuItems = getResources().getStringArray(R.array.addCntactMenu);
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(R.string.add_contact_title);
        builder.setItems(contactMenuItems, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                switch (which) {
                    case 0:     // from phone
                        ArrayList<fbContact> contactsFromPhone = requestContactsFromPhone();
                        Intent intent1 = new Intent(SelectContactActivity.this, SelectContactFromPhoneActivity.class);
                        intent1.putParcelableArrayListExtra(SelectContactFromPhoneActivity.PARAM_CONTACTS_FROM_PHONE, contactsFromPhone);
                        startActivity(intent1);
                        break;

                    case 1:     // manually
                        Intent intent = new Intent(SelectContactActivity.this, CreateContactActivity.class);
                        intent.putExtra(PARAM_SELECTED_GIFT, getIntent().getParcelableExtra(PARAM_SELECTED_GIFT));
                        startActivityForResult(intent, REQUEST_CREATE_CONTACT);
                        break;
                }
            }
        });
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CREATE_CONTACT) {
            if (resultCode == Activity.RESULT_OK) {
                fbContact contact = data.getParcelableExtra("result");
                mSelectedContacts.add(contact);
                onDone();
            } else if (resultCode == Activity.RESULT_CANCELED) {

            }
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onMessageEvent(ContactChangedEvent event) {
        updateUI();
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

    private static final String CONTACT_ID = ContactsContract.Contacts._ID;
    private static final String HAS_PHONE_NUMBER = ContactsContract.Contacts.HAS_PHONE_NUMBER;

    private static final String PHONE_DISPLAY_NAME = ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME;
    private static final String PHONE_NUMBER = ContactsContract.CommonDataKinds.Phone.NUMBER;
    private static final String PHONE_CONTACT_ID = ContactsContract.CommonDataKinds.Phone.CONTACT_ID;

    private ArrayList<fbContact> requestContactsFromPhone() {
        ArrayList<fbContact> contactsFromPhone = new ArrayList<>();

        ContentResolver cr = getContentResolver();

        Cursor pCur = cr.query(
                ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                new String[]{PHONE_DISPLAY_NAME, PHONE_NUMBER, PHONE_CONTACT_ID},
                null,
                null,
                null
        );
        if(pCur != null){
            if(pCur.getCount() > 0) {
                HashMap<Integer, ArrayList<String>> phones = new HashMap<>();
                while (pCur.moveToNext()) {
                    Integer contactId = pCur.getInt(pCur.getColumnIndex(PHONE_CONTACT_ID));
                    ArrayList<String> curPhones = new ArrayList<>();
                    if (phones.containsKey(contactId)) {
                        curPhones = phones.get(contactId);
                    }
                    String displayName = pCur.getString(pCur.getColumnIndex(PHONE_DISPLAY_NAME));
                    String phoneNumber = pCur.getString(pCur.getColumnIndex(PHONE_NUMBER));
                    curPhones.add(displayName);
                    curPhones.add(phoneNumber);
                    phones.put(contactId, curPhones);

                    // Create new contact
                    contactsFromPhone.add(new fbContact(displayName, phoneNumber));
                }
            }
            pCur.close();
        }

        return contactsFromPhone;
    }

}