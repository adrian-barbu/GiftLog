package com.websthewords.giftlog.data.model.firebase;

import com.google.gson.Gson;

import java.util.ArrayList;

/**
 * @description     Firebase Custom User
 * 
 * @author          Adrian
 */

public class fbUser {
    public String gplusId;
    public String facebookId;

    public String firstName;
    public String lastName;
    public String nickName;
    public String email;
    public String phoneNumber;
    public String avatar;
    public String likes;
    public String dislikes;
    public ArrayList<fbContactDate> dates;

    public String getEmail() { return email; }
    public String getFirstName() { return (firstName == null) ? "" : firstName; }
    public String getLastName() { return (lastName == null) ? "" : lastName; }
    public String getNickName() { return nickName; }
    public String getAvatar() { return avatar; }
    public String getLikes() { return likes; }
    public String getDislikes() { return dislikes; }
    public String getPhoneNumber() { return phoneNumber; }
    public ArrayList<fbContactDate> getDates() { return dates;}

    public fbUser() {}

    public String toJSON() {
        Gson gson = new Gson();
        String json = gson.toJson(this);
        return json;
    }

    public static fbUser fromJSON(String jsonString) {
        return new Gson().fromJson(jsonString, fbUser.class);
    }

    public static fbUser clone(fbUser other) {
        return fbUser.fromJSON(other.toJSON());
    }

    public boolean equals(fbUser user) {
        return this.toJSON().equals(user.toJSON());
    }
}
