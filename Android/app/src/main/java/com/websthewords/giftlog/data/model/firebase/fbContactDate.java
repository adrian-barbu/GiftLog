package com.websthewords.giftlog.data.model.firebase;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * @description     Firebase Contact Date
 * 
 * @author          Adrian
 */

public class fbContactDate implements Parcelable {
    public String identifier;
    public long timeStamp;
    public String name;

    public fbContactDate() {}
    public fbContactDate(String name, long timeStamp) {
        this.name = name;
        this.timeStamp = timeStamp;
    }

    protected fbContactDate(Parcel in) {
        identifier = in.readString();
        timeStamp = in.readLong();
        name = in.readString();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(identifier);
        dest.writeLong(timeStamp);
        dest.writeString(name);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<fbContactDate> CREATOR = new Creator<fbContactDate>() {
        @Override
        public fbContactDate createFromParcel(Parcel in) {
            return new fbContactDate(in);
        }

        @Override
        public fbContactDate[] newArray(int size) {
            return new fbContactDate[size];
        }
    };

    public String getIdentifier() { return identifier; }
    public String getName() { return name; }
    public long getTimeStamp() { return timeStamp; }
}
