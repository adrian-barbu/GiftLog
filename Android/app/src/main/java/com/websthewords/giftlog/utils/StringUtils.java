package com.websthewords.giftlog.utils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * @description     String Utility Functions
 *
 */

public class StringUtils {
    /**
     * Check email validation
     *
     * @param emailText
     * @return
     */
    public static boolean isEmailValid(String emailText) {
        String emailPattern = "[a-zA-Z0-9._-]+@[a-z]+\\.+[a-z]+";
        return emailText.matches(emailPattern);
    }

    public static String makeDurationFromMilisecond(int miliSec) {
        int sec = miliSec / 1000;
        int minutes = (sec % 3600) / 60;
        int seconds = sec % 60;

        return String.format("%02d:%02d", minutes, seconds);
    }

    public static String getDateFromMiliseconds(long miliseconds) {
        Date date = new Date(miliseconds * 1000);
        //SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy h:mm a");
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        return sdf.format(date);
    }

    public static String getDateFromMiliseconds1(long miliseconds) {
        Date date = new Date(miliseconds * 1000);
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        return sdf.format(date);
    }
}
