package com.websthewords.giftlog.data.model.firebase;

import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;

import com.google.gson.Gson;

import java.util.ArrayList;

/**
 * @description     Firebase Contact
 * 
 * @author          Adrian
 */

public class fbContact implements Parcelable {
    public String identifier;
    public String ownerId;
    public String email;
    public String firstName;
    public String lastName;
    public String nickName;
    public String avatar;
    public String phoneNumber;
    public ArrayList<fbContactDate> dates;
    public ArrayList<fbPreloader> gifts;
    public String likes;
    public String dislikes;

    public fbContact() {}
    public fbContact(String firstName, String phoneNumber) {
        this.firstName = firstName;
        this.phoneNumber = phoneNumber;
    }

    protected fbContact(Parcel in) {
        identifier = in.readString();
        ownerId = in.readString();
        email = in.readString();
        firstName = in.readString();
        lastName = in.readString();
        nickName = in.readString();
        avatar = in.readString();
        phoneNumber = in.readString();
        dates = in.createTypedArrayList(fbContactDate.CREATOR);
        gifts = in.createTypedArrayList(fbPreloader.CREATOR);
        likes = in.readString();
        dislikes = in.readString();
    }

    public static final Creator<fbContact> CREATOR = new Creator<fbContact>() {
        @Override
        public fbContact createFromParcel(Parcel in) {
            return new fbContact(in);
        }

        @Override
        public fbContact[] newArray(int size) {
            return new fbContact[size];
        }
    };

    public String getIdentifier() { return identifier; }
    public String getOwnerId() { return ownerId; }
    public String getEmail() { return email; }
    public String getFirstName() { return (TextUtils.isEmpty(firstName)) ? "" : firstName; }
    public String getLastName() { return (TextUtils.isEmpty(lastName)) ? "" : lastName; }
    public String getNickName() { return nickName; }
    public String getAvatar() { return avatar; }
    public String getLikes() { return likes; }
    public String getDislikes() { return dislikes; }
    public String getPhoneNumber() { return phoneNumber; }

    public ArrayList<fbContactDate> getDates() { return dates; }
    public ArrayList<fbPreloader> getGifts() { return gifts; }
    public String getFullName() {
        String fullName = "";
        if (!TextUtils.isEmpty(firstName))
            fullName += firstName;
        if (!TextUtils.isEmpty(lastName))
            fullName += " " + lastName;
        return fullName;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(identifier);
        dest.writeString(ownerId);
        dest.writeString(email);
        dest.writeString(firstName);
        dest.writeString(lastName);
        dest.writeString(nickName);
        dest.writeString(avatar);
        dest.writeString(phoneNumber);
        dest.writeTypedList(dates);
        dest.writeTypedList(gifts);
        dest.writeString(likes);
        dest.writeString(dislikes);
    }

    // For Clone
    public String toJSON() {
        Gson gson = new Gson();
        String json = gson.toJson(this);
        return json;
    }

    public static fbContact fromJSON(String jsonString) {
        return new Gson().fromJson(jsonString, fbContact.class);
    }

    public static fbContact clone(fbContact other) {
        return fbContact.fromJSON(other.toJSON());
    }

    public boolean equals(fbContact user) {
        return this.toJSON().equals(user.toJSON());
    }
}
