package com.websthewords.giftlog.data.model.firebase;


import android.os.Parcel;
import android.os.Parcelable;

/**
 * @description     Firebase Preloader Structure
 *
 * @author          Adrian
 */

public class fbPreloader implements Parcelable {
    public String identifier;

    public fbPreloader() {}
    public fbPreloader(String identifier) { this.identifier = identifier; }
    public fbPreloader(Parcel in) {
        identifier = in.readString();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(identifier);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<fbPreloader> CREATOR = new Creator<fbPreloader>() {
        @Override
        public fbPreloader createFromParcel(Parcel in) {
            return new fbPreloader(in);
        }

        @Override
        public fbPreloader[] newArray(int size) {
            return new fbPreloader[size];
        }
    };

    public String getIdentifier() { return identifier; }
}
