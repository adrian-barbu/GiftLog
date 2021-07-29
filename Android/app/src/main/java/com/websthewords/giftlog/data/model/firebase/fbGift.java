package com.websthewords.giftlog.data.model.firebase;

import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;

import com.google.gson.Gson;

import java.util.ArrayList;

/**
 * @description     Firebase Gift Structure
 *
 * @author          Adrian
 */

public class fbGift implements Parcelable {
    public String identifier;
    public String ownerId;

    public int inOutType;
    public String name;
    public String description;
    public int recieptType;
    public int type;
    public int status;
    public String price;
    public boolean thankYouSent;
    public ArrayList<fbGiftImage> images;

    public ArrayList<fbPreloader> contacts;
    public fbPreloader eventPreload;

    public fbGift() {}

    protected fbGift(Parcel in) {
        identifier = in.readString();
        ownerId = in.readString();
        inOutType = in.readInt();
        name = in.readString();
        description = in.readString();
        recieptType = in.readInt();
        type = in.readInt();
        status = in.readInt();
        price = in.readString();
        thankYouSent = in.readByte() != 0;
        images = in.createTypedArrayList(fbGiftImage.CREATOR);
        contacts = in.createTypedArrayList(fbPreloader.CREATOR);
        eventPreload = in.readParcelable(fbPreloader.class.getClassLoader());
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(identifier);
        dest.writeString(ownerId);
        dest.writeInt(inOutType);
        dest.writeString(name);
        dest.writeString(description);
        dest.writeInt(recieptType);
        dest.writeInt(type);
        dest.writeInt(status);
        dest.writeString(price);
        dest.writeByte((byte) (thankYouSent ? 1 : 0));
        dest.writeTypedList(images);
        dest.writeTypedList(contacts);
        dest.writeParcelable(eventPreload, flags);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<fbGift> CREATOR = new Creator<fbGift>() {
        @Override
        public fbGift createFromParcel(Parcel in) {
            return new fbGift(in);
        }

        @Override
        public fbGift[] newArray(int size) {
            return new fbGift[size];
        }
    };

    public String getIdentifier() { return identifier; }
    public String getName() { return TextUtils.isEmpty(name) ? "" : name; }
    public String getOwnerId() { return ownerId; }
    public String getDescription() { return description; }
    public int getType() { return type; }
    public int getInOutType() { return inOutType; }
    public int getRecieptType() { return recieptType; }
    public String getPrice() { return price; }
    public ArrayList<fbGiftImage> getImages() { return images; }
    public int getStatus() { return status; }
    public boolean isThankYouSent() { return thankYouSent; }

    public ArrayList<fbPreloader> getContacts() { return contacts; }
    public fbPreloader getEventPreloader() { return eventPreload; }

    // For Clone
    public String toJSON() {
        Gson gson = new Gson();
        String json = gson.toJson(this);
        return json;
    }

    public static fbGift fromJSON(String jsonString) {
        return new Gson().fromJson(jsonString, fbGift.class);
    }

    public static fbGift clone(fbGift other) {
        return fbGift.fromJSON(other.toJSON());
    }

    public boolean equals(fbGift user) {
        return this.toJSON().equals(user.toJSON());
    }
}
