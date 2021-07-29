package com.websthewords.giftlog.data.model.firebase;

import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;

import com.google.gson.Gson;

import java.util.ArrayList;

/**
 * @description     Firebase Event Structure
 *
 * @author          Adrian
 */

public class fbEvent implements Parcelable {
    public String identifier;
    public String ownerId;
    public String eventTitle;
    public int hostingType;
    public long dateStart;
    public long dateEnd;

    public String eventType;
    public String description;
    public String image;
    public ArrayList<fbPreloader> contacts;
    public ArrayList<fbPreloader> gifts;
    public String likes;
    public String dislikes;

    public fbEvent() {}

    protected fbEvent(Parcel in) {
        identifier = in.readString();
        ownerId = in.readString();
        eventTitle = in.readString();
        hostingType = in.readInt();
        dateStart = in.readLong();
        dateEnd = in.readLong();
        eventType = in.readString();
        description = in.readString();
        image = in.readString();
        contacts = in.createTypedArrayList(fbPreloader.CREATOR);
        gifts = in.createTypedArrayList(fbPreloader.CREATOR);
        likes = in.readString();
        dislikes = in.readString();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(identifier);
        dest.writeString(ownerId);
        dest.writeString(eventTitle);
        dest.writeInt(hostingType);
        dest.writeLong(dateStart);
        dest.writeLong(dateEnd);
        dest.writeString(eventType);
        dest.writeString(description);
        dest.writeString(image);
        dest.writeTypedList(contacts);
        dest.writeTypedList(gifts);
        dest.writeString(likes);
        dest.writeString(dislikes);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<fbEvent> CREATOR = new Creator<fbEvent>() {
        @Override
        public fbEvent createFromParcel(Parcel in) {
            return new fbEvent(in);
        }

        @Override
        public fbEvent[] newArray(int size) {
            return new fbEvent[size];
        }
    };

    public String getIdentifier() { return identifier; }
    public String getEventTitle() { return TextUtils.isEmpty(eventTitle) ? "" : eventTitle; }
    public String getOwnerId() { return ownerId; }

    public String getEventType() { return eventType; }
    public String getDescription() { return description; }
    public int getHostingType() { return hostingType; }
    public long getDateStart() { return dateStart; }
    public long getDateEnd() { return dateEnd; }
    public ArrayList<fbPreloader> getContacts() { return contacts; }
    public ArrayList<fbPreloader> getGifts() { return gifts; }

    // For Clone
    public String toJSON() {
        Gson gson = new Gson();
        String json = gson.toJson(this);
        return json;
    }

    public static fbEvent fromJSON(String jsonString) {
        return new Gson().fromJson(jsonString, fbEvent.class);
    }

    public static fbEvent clone(fbEvent other) {
        return fbEvent.fromJSON(other.toJSON());
    }

    public boolean equals(fbEvent user) {
        return this.toJSON().equals(user.toJSON());
    }}
