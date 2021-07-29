package com.websthewords.giftlog.data.manage;

import android.content.Context;
import android.support.annotation.NonNull;

import com.facebook.login.LoginManager;
import com.google.android.gms.auth.api.Auth;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.common.api.Status;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.websthewords.giftlog.App;
import com.websthewords.giftlog.data.model.event.ContactChangedEvent;
import com.websthewords.giftlog.data.model.event.EventChangedEvent;
import com.websthewords.giftlog.data.model.event.GiftChangedEvent;
import com.websthewords.giftlog.data.model.event.UserProfileChangedEvent;
import com.websthewords.giftlog.data.model.firebase.fbContact;
import com.websthewords.giftlog.data.model.firebase.fbEvent;
import com.websthewords.giftlog.data.model.firebase.fbGift;
import com.websthewords.giftlog.data.model.firebase.fbUser;
import com.websthewords.giftlog.ui.MainActivity;

import org.greenrobot.eventbus.EventBus;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;

/**
 * @description     Data Manager With Firebase
 *
 * @author          Adrian
 */

public class DataManager {
    private static DataManager INSTANCE = new DataManager();

    // Constants
    public final static String GIFTS = "gifts";
    public final static String EVENTS = "events";
    public final static String CONTACTS = "contacts";
    public final static String USERS = "users";

    public final static String RESULT = "result";
    public final static String TRACKING = "tracking";

    private fbUser mUser;
    private ArrayList<fbGift> mGifts;
    private ArrayList<fbEvent> mEvents;
    private ArrayList<fbContact> mContacts;
    GoogleApiClient mGoogleApiClient;

    DatabaseReference mDBRef = FirebaseDatabase.getInstance().getReference();

    // Variables
    public static Context mContext;

    // Initiailze
    public static DataManager getInstance() {
        if (INSTANCE == null)
            INSTANCE = new DataManager();

        return INSTANCE;
    }

    // Constructor
    private DataManager() {
        mGifts = new ArrayList<>();
        mEvents = new ArrayList<>();
        mContacts = new ArrayList<>();

        GoogleSignInOptions gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                .requestIdToken("166939248803-931ksv0g9pen2sm7qee6p5ct24i617eq.apps.googleusercontent.com")
                .requestEmail()
                .build();

        mGoogleApiClient = new GoogleApiClient.Builder(App.gContext)
                .addApi(Auth.GOOGLE_SIGN_IN_API, gso)
                .build();
    }

    public DatabaseReference getGiftRoot() {
        return mDBRef.child(GIFTS);
    }

    public DatabaseReference getEventRoot() {
        return mDBRef.child(EVENTS);
    }

    public DatabaseReference getContactRoot() {
        return mDBRef.child(CONTACTS);
    }

    public DatabaseReference getUsersRoot() {
        return mDBRef.child(USERS);
    }

    public void initialize() {
        String ownerId = getCurrentUserID();

        // Start monitoring to get all changed gifts, events, contacts
        mDBRef.child(USERS).child(ownerId).addValueEventListener(mUserValueEventListener);
        mDBRef.child(GIFTS).orderByChild("ownerId").equalTo(ownerId).addValueEventListener(mGiftValueEventListener);
        mDBRef.child(EVENTS).orderByChild("ownerId").equalTo(ownerId).addValueEventListener(mEventValueEventListener);
        mDBRef.child(CONTACTS).orderByChild("ownerId").equalTo(ownerId).addValueEventListener(mContactValueEventListener);
    }

    public void signOut() {
        String ownerId = getCurrentUserID();

        // remove all event listners
        mDBRef.child(USERS).child(ownerId).removeEventListener(mUserValueEventListener);
        mDBRef.child(USERS).child(ownerId).removeEventListener(mGiftValueEventListener);
        mDBRef.child(USERS).child(ownerId).removeEventListener(mEventValueEventListener);
        mDBRef.child(USERS).child(ownerId).removeEventListener(mContactValueEventListener);

        FirebaseAuth.getInstance().signOut();
        LoginManager.getInstance().logOut();
//        Auth.GoogleSignInApi.signOut(mGoogleApiClient);
    }

    ValueEventListener mUserValueEventListener = new ValueEventListener() {
        @Override
        public void onDataChange(DataSnapshot dataSnapshot) {
            mUser = dataSnapshot.getValue(fbUser.class);

            // Send Changed Event
            EventBus.getDefault().post(new UserProfileChangedEvent());
        }

        @Override
        public void onCancelled(DatabaseError databaseError) {
        }
    };

    ValueEventListener mGiftValueEventListener = new ValueEventListener() {
        @Override
        public void onDataChange(DataSnapshot dataSnapshot) {
            mGifts.clear();

            for (DataSnapshot snapShot : dataSnapshot.getChildren()) {
                try {
                    fbGift gift = snapShot.getValue(fbGift.class);
                    gift.identifier = snapShot.getKey();
                    mGifts.add(gift);
                } catch (Exception e) {
                }
            }

            // Send Changed Event
            EventBus.getDefault().post(new GiftChangedEvent());
        }

        @Override
        public void onCancelled(DatabaseError databaseError) {
        }
    };

    ValueEventListener mEventValueEventListener = new ValueEventListener() {
        @Override
        public void onDataChange(DataSnapshot dataSnapshot) {
            mEvents.clear();

            for (DataSnapshot snapShot : dataSnapshot.getChildren()) {
                try {
                    fbEvent gift = snapShot.getValue(fbEvent.class);
                    gift.identifier = snapShot.getKey();
                    mEvents.add(gift);
                } catch (Exception e) {}
            }

            // Send Changed Event
            EventBus.getDefault().post(new EventChangedEvent());
        }

        @Override
        public void onCancelled(DatabaseError databaseError) {
        }
    };

    ValueEventListener mContactValueEventListener = new ValueEventListener() {
        @Override
        public void onDataChange(DataSnapshot dataSnapshot) {
            mContacts.clear();

            for (DataSnapshot snapShot : dataSnapshot.getChildren()) {
                try {
                    fbContact contact = snapShot.getValue(fbContact.class);
                    contact.identifier = snapShot.getKey();
                    mContacts.add(contact);
                } catch (Exception e) {}
            }

            // Send Changed Event
            EventBus.getDefault().post(new ContactChangedEvent());
        }

        @Override
        public void onCancelled(DatabaseError databaseError) {
        }
    };

    public FirebaseUser getCurrentUser() {
        return FirebaseAuth.getInstance().getCurrentUser();
    }

    public String getCurrentUserID() {
        return FirebaseAuth.getInstance().getCurrentUser().getUid();
    }

    public fbUser getUserProfile() {
        return mUser;
    }
    public ArrayList<fbGift> getAllGifts() {
        return mGifts;
    }
    public ArrayList<fbEvent> getAllEvents() { return mEvents; }
    public ArrayList<fbContact> getAllContacts() { return mContacts; }

    public fbGift getGiftById(String identifier) {
        for (fbGift gift: mGifts) {
            if (gift.getIdentifier().equals(identifier)) {
                return gift;
            }
        }

        return null;
    }

    public fbContact getContactById(String identifier) {
        for (fbContact contact: mContacts) {
            if (contact.getIdentifier().equals(identifier)) {
                return contact;
            }
        }

        return null;
    }

    public fbEvent getEventById(String identifier) {
        for (fbEvent event: mEvents) {
            if (event.getIdentifier().equals(identifier)) {
                return event;
            }
        }

        return null;
    }
}
