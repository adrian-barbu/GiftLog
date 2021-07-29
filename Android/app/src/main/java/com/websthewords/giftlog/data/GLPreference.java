package com.websthewords.giftlog.data;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;

/**
 * @description		Global Configuration
 *
 * @author 			Adrian
 *
 */
public class GLPreference {
	/** the preferences. */
	private static SharedPreferences mPreference;

	/** the configuratrion name. */
	private static String CONFIG_NAME = "giftlog";

	// Config Variables
	private static String CONFIG_FIRST_RUN = "firstRun";				// Flag indicates the app is running on first
	private static String CONFIG_USE_NOTIFICATION = "useNotification";	// Flag indicates the app is use of notification for events

	public static void initialize(Context context) {
		mPreference = context.getSharedPreferences(CONFIG_NAME, Context.MODE_PRIVATE);
	}

	////////////////////////////////////////////////////////////////////
	////////////////////// Set Global Variables ////////////////////////
	////////////////////////////////////////////////////////////////////
	public static boolean setFirstRun(boolean first) { return setBooleanValue(CONFIG_FIRST_RUN, first); }
	public static boolean isFirstRun() { return getBooleanValue(CONFIG_FIRST_RUN, true); }

	public static boolean setUseNotification(boolean use) { return setBooleanValue(CONFIG_USE_NOTIFICATION, use); }
	public static boolean isUseNotification() { return getBooleanValue(CONFIG_USE_NOTIFICATION, true); }

	////////////////////////////////////////////////////////////////////
	////////////////////// Put/Get Configuration ///////////////////////
	////////////////////////////////////////////////////////////////////

	/* String Type */
	private static boolean setStringValue(String config, String value)
	{
		Editor edit = mPreference.edit();
		edit.putString(config, value);
		return edit.commit();
	}

	private static String getStringValue(String config, String defValue)
	{
		return mPreference.getString(config, defValue);
	}

	/* Integer Type */
	private static boolean setIntValue(String config, int value)
	{
		Editor edit = mPreference.edit();
		edit.putInt(config, value);
		return edit.commit();
	}

	private static int getIntValue(String config, int defValue)
	{
		return mPreference.getInt(config, defValue);
	}

	/* Boolean Type */
	private static boolean setBooleanValue(String config, boolean value)
	{
		Editor edit = mPreference.edit();
		edit.putBoolean(config, value);
		return edit.commit();
	}

	private static boolean getBooleanValue(String config, boolean defValue)
	{
		return mPreference.getBoolean(config, defValue);
	}
}