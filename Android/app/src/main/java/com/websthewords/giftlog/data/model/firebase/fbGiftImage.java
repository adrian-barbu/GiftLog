package com.websthewords.giftlog.data.model.firebase;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * @description     Firebase Gift Image
 * 
 * @author          Adrian
 */

public class fbGiftImage implements Parcelable {
    public String url;

    public fbGiftImage() {}
    public fbGiftImage(String url) {
        this.url = url;
    }

    protected fbGiftImage(Parcel in) {
        url = in.readString();
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(url);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<fbGiftImage> CREATOR = new Creator<fbGiftImage>() {
        @Override
        public fbGiftImage createFromParcel(Parcel in) {
            return new fbGiftImage(in);
        }

        @Override
        public fbGiftImage[] newArray(int size) {
            return new fbGiftImage[size];
        }
    };

    public String getUrl() { return url; }
}
