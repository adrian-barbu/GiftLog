package com.websthewords.giftlog.ui.fragment;

import android.app.AlertDialog;
import android.content.ContentResolver;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.provider.ContactsContract;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ImageView;

import com.baoyz.swipemenulistview.SwipeMenu;
import com.baoyz.swipemenulistview.SwipeMenuCreator;
import com.baoyz.swipemenulistview.SwipeMenuItem;
import com.baoyz.swipemenulistview.SwipeMenuListView;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.websthewords.giftlog.R;
import com.websthewords.giftlog.adapters.ContactItemAdapter;
import com.websthewords.giftlog.data.manage.DataManager;
import com.websthewords.giftlog.data.model.event.ContactChangedEvent;
import com.websthewords.giftlog.data.model.firebase.fbContact;
import com.websthewords.giftlog.ui.creation.CreateContactActivity;
import com.websthewords.giftlog.ui.base.BaseActivity;
import com.websthewords.giftlog.ui.list.SelectContactFromPhoneActivity;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Iterator;

import butterknife.Bind;

/**
 * @description     Contacts Fragment
  *
 * @author          Adrian
 */
public class ContactsFragment extends BaseFragment {
    private final static String TAG = ContactsFragment.class.getSimpleName();

    // UI Members
    @Bind(R.id.lvItems)
    SwipeMenuListView lvItems;
    @Bind(R.id.ivAddContact)
    ImageView ivAddContact;

    // Variables
    ArrayList<fbContact> mContacts;
    ContactItemAdapter mContactItemAdapter;

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_contacts;
    }

    @Override
    protected void initViews() {
        initUI();

        mContacts = new ArrayList<>();

        updateUI();
    }

    private void initUI() {
        mContactItemAdapter = new ContactItemAdapter(getActivity());
        lvItems.setAdapter(mContactItemAdapter);
        lvItems.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                requestUpdateContact(position);
            }
        });
        initMenuCreator();

        ivAddContact.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showAddMenuItems();
            }
        });
    }

    private void updateUI() {
        mContacts.clear();

        ArrayList<fbContact> contacts = DataManager.getInstance().getAllContacts();
        for (Iterator<fbContact> it = contacts.iterator(); it.hasNext(); ) {
            fbContact contact = it.next();
            mContacts.add(contact);
        }

        Collections.sort(mContacts, new AZComparator());
        mContactItemAdapter.setData(mContacts);
    }

    private void requestUpdateContact(int position) {
        fbContact contact = mContacts.get(position);

        Intent intent = new Intent(getActivity(), CreateContactActivity.class);
        intent.putExtra(BaseActivity.PARAM_ORIGINAL, contact);
        startActivity(intent);
    }

    private void initMenuCreator() {
        SwipeMenuCreator creator = new SwipeMenuCreator() {
            @Override
            public void create(SwipeMenu menu) {
                SwipeMenuItem item1 = new SwipeMenuItem(getActivity());
                item1.setBackground(R.color.colorBlue);
                item1.setWidth(dp2px(90));
                item1.setIcon(R.drawable.ic_edit_white);
                menu.addMenuItem(item1);

                SwipeMenuItem item2 = new SwipeMenuItem(getActivity());
                item2.setBackground(R.color.colorMagento);
                item2.setWidth(dp2px(90));
                item2.setIcon(R.drawable.ic_delete_white);
                menu.addMenuItem(item2);
            }
        };

        // set creator
        lvItems.setMenuCreator(creator);

        lvItems.setOnMenuItemClickListener(new SwipeMenuListView.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(int position, SwipeMenu menu, int index) {
                switch (index) {
                    case 0:
                        // edit
                        requestUpdateContact(position);
                        break;

                    case 1:
                        // delete
                        requestDelete(position);
                        break;
                }
                return false;
            }
        });
    }

    private void requestDelete(final int position) {
        final String[] deleteContactMenuArray = getResources().getStringArray(R.array.deleteContactMenu);
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        builder.setItems(deleteContactMenuArray, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                if (which == 0) {
                    deleteContact(position);
                }
            }
        });
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
    }

    private void deleteContact(int position) {
        final fbContact contact = mContacts.get(position);

        mWaitDialog.show();
        DataManager.getInstance().getContactRoot().child(contact.getIdentifier()).removeValue(new DatabaseReference.CompletionListener() {
            @Override
            public void onComplete(DatabaseError databaseError, DatabaseReference databaseReference) {
                mWaitDialog.dismiss();
                mContacts.remove(contact);
                mContactItemAdapter.notifyDataSetChanged();
            }
        });
    }

    private void showAddMenuItems() {
        final String[] contactMenuItems = getResources().getStringArray(R.array.addCntactMenu);
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        builder.setTitle(R.string.add_contact_title);
        builder.setItems(contactMenuItems, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                switch (which) {
                    case 0:     // from phone
                        ArrayList<fbContact> contactsFromPhone = requestContactsFromPhone();
                        Intent intent1 = new Intent(getActivity(), SelectContactFromPhoneActivity.class);
                        intent1.putParcelableArrayListExtra(SelectContactFromPhoneActivity.PARAM_CONTACTS_FROM_PHONE, contactsFromPhone);
                        startActivity(intent1);
                        break;

                    case 1:     // manually
                        Intent intent = new Intent(getActivity(), CreateContactActivity.class);
                        startActivity(intent);
                        break;
                }
            }
        });
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
    }

    private static final String CONTACT_ID = ContactsContract.Contacts._ID;
    private static final String HAS_PHONE_NUMBER = ContactsContract.Contacts.HAS_PHONE_NUMBER;

    private static final String PHONE_DISPLAY_NAME = ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME;
    private static final String PHONE_NUMBER = ContactsContract.CommonDataKinds.Phone.NUMBER;
    private static final String PHONE_CONTACT_ID = ContactsContract.CommonDataKinds.Phone.CONTACT_ID;

    private ArrayList<fbContact> requestContactsFromPhone() {
        ArrayList<fbContact> contactsFromPhone = new ArrayList<>();

        ContentResolver cr = getActivity().getContentResolver();

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
                /*
                Cursor cur = cr.query(
                        ContactsContract.Contacts.CONTENT_URI,
                        new String[]{CONTACT_ID, HAS_PHONE_NUMBER},
                        HAS_PHONE_NUMBER + " > 0",
                        null,null);
                if (cur != null) {
                    if (cur.getCount() > 0) {
                        ArrayList<String> contacts = new ArrayList<>();
                        while (cur.moveToNext()) {
                            int id = cur.getInt(cur.getColumnIndex(CONTACT_ID));
                            if(phones.containsKey(id)) {
                                contacts.addAll(phones.get(id));
                            }
                        }
                        int a;
                        a = 1;
                        return contacts;
                    }
                    cur.close();
                }
                */
            }
            pCur.close();
        }

        return contactsFromPhone;
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
        updateUI();
    }

    public class AZComparator implements Comparator<fbContact>
    {
        public int compare(fbContact left, fbContact right) {
            return left.firstName.compareTo(right.firstName);
        }
    }
}