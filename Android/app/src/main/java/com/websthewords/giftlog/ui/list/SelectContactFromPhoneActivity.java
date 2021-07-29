package com.websthewords.giftlog.ui.list;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.websthewords.giftlog.R;
import com.websthewords.giftlog.adapters.ContactItemSelectableFromPhoneAdapter;
import com.websthewords.giftlog.data.manage.DataManager;
import com.websthewords.giftlog.data.model.event.ContactChangedEvent;
import com.websthewords.giftlog.data.model.firebase.fbContact;
import com.websthewords.giftlog.ui.base.BaseActivity;
import com.websthewords.giftlog.ui.creation.CreateContactActivity;
import com.websthewords.giftlog.ui.fragment.ContactsFragment;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

import butterknife.Bind;
import butterknife.ButterKnife;

/**
 * @description     Contact Select From Phone
 *
 * @author          Adrian
 */
public class SelectContactFromPhoneActivity extends BaseActivity {
    public final String TAG = SelectContactFromPhoneActivity.class.getName();

    public final static String PARAM_CONTACTS_FROM_PHONE = "contacts_from_phone";

    // UI Members
    @Bind(R.id.lvContacts)      ListView lvContacts;
    @Bind(R.id.tvNoContacts)    TextView tvNoContacts;

    @Bind(R.id.etKeyword)       EditText etKeyword;
    @Bind(R.id.ivClearKeyword)  ImageView ivClearKeyword;

    // Variables
    ArrayList<fbContact> mContactsFromPhone;
    ArrayList<fbContact> mSelectedContacts;
    ContactItemSelectableFromPhoneAdapter mContactItemAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_select_contact_from_phone);
        ButterKnife.bind(this);

        mContactsFromPhone = getIntent().getParcelableArrayListExtra(PARAM_CONTACTS_FROM_PHONE);

        mSelectedContacts = new ArrayList<>();

        mContactItemAdapter = new ContactItemSelectableFromPhoneAdapter(this, new ContactItemSelectableFromPhoneAdapter.OnItemSelectedListener() {
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

        etKeyword.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                updateUI();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });

        updateUI();
    }

    public void updateUI() {
        // Filtering
        String keyword = etKeyword.getText().toString().trim();

        ArrayList<fbContact> selectableContacts = new ArrayList<>();

        for (fbContact contact : mContactsFromPhone) {
            if (!isExistInAddedContacts(contact) && contact.getFullName().toLowerCase().contains(keyword.toLowerCase()))
                selectableContacts.add(contact);
        }

        if (selectableContacts.isEmpty()) {
            tvNoContacts.setVisibility(View.VISIBLE);
            mContactItemAdapter.setData(selectableContacts, mSelectedContacts);
            return;
        }

        tvNoContacts.setVisibility(View.INVISIBLE);
        Collections.sort(selectableContacts, new AZComparator());
        mContactItemAdapter.setData(selectableContacts, mSelectedContacts);
    }

    private boolean isExistInAddedContacts(fbContact contact) {
        ArrayList<fbContact> allContacts = DataManager.getInstance().getAllContacts();

        if (allContacts.isEmpty())
            return false;

        boolean exist = false;
        for (fbContact contact1 : allContacts) {
            if (!TextUtils.isEmpty(contact.phoneNumber) && contact.phoneNumber.equals(contact1.phoneNumber)) {
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
                    addContactsToServer();
                    finish();
                } else {
                    showToast(R.string.no_selected_contacts);
                }
                break;

            case R.id.ivClearKeyword:
                etKeyword.setText("");
                updateUI();
                break;
        }
    }

    private void addContactsToServer() {
        for (fbContact contact : mSelectedContacts) {
            createContactOnServer(contact);
        }
    }

    private void createContactOnServer(fbContact contact) {
        String identifier = DataManager.getInstance().getContactRoot().push().getKey();
        contact.identifier = identifier;
        contact.ownerId = DataManager.getInstance().getCurrentUserID();
        DataManager.getInstance().getContactRoot().child(identifier).setValue(contact, new DatabaseReference.CompletionListener() {
            @Override
            public void onComplete(DatabaseError databaseError, DatabaseReference databaseReference) {
                mWaitDialog.dismiss();
            }
        });
    }

    public class AZComparator implements Comparator<fbContact>
    {
        public int compare(fbContact left, fbContact right) {
            return left.firstName.compareTo(right.firstName);
        }
    }

}