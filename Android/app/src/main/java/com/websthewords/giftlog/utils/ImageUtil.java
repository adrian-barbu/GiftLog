package com.websthewords.giftlog.utils;

import android.graphics.Bitmap.Config;
import android.graphics.Color;
import android.widget.ImageView;

import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.ImageScaleType;
import com.nostra13.universalimageloader.core.display.CircleBitmapDisplayer;
import com.nostra13.universalimageloader.core.display.FadeInBitmapDisplayer;
import com.nostra13.universalimageloader.core.listener.ImageLoadingListener;
import com.websthewords.giftlog.R;

/**
 * @description		Image Util Functions
 *
 * @author 			Adrian
 */
public class ImageUtil {
	
	public static void displayUserImage(ImageView view, String path, ImageLoadingListener listener) {
		ImageLoader loader = ImageLoader.getInstance();
		try {
			loader.displayImage(path, view, ROUND_DISPLAY_IMAGE_OPTIONS, listener);
		} catch (OutOfMemoryError e) {
			e.printStackTrace();
			loader.clearMemoryCache();
		}
	}

	public static void displayPhotoImage(ImageView view, String path, ImageLoadingListener listener) {
		ImageLoader loader = ImageLoader.getInstance();
		try {
			loader.displayImage(path, view, ROUND_DISPLAY_PHOTO_OPTIONS, listener);
		} catch (OutOfMemoryError e) {
			e.printStackTrace();
			loader.clearMemoryCache();
		}
	}

	public static void displayUserImageWithNoCache(ImageView view, String path, ImageLoadingListener listener) {
		ImageLoader loader = ImageLoader.getInstance();
		try {
			loader.displayImage(path, view, ROUND_DISPLAY_IMAGE_OPTIONS_WITHNO_CACHE, listener);
		} catch (OutOfMemoryError e) {
			e.printStackTrace();
			loader.clearMemoryCache();
		}
	}

	public static void displayUserImageWithBorder(ImageView view, String path, ImageLoadingListener listener) {
		ImageLoader loader = ImageLoader.getInstance();
		try {
			loader.displayImage(path, view, ROUND_DISPLAY_IMAGE_WITH_BORDER_OPTIONS, listener);
		} catch (OutOfMemoryError e) {
			e.printStackTrace();
			loader.clearMemoryCache();
		}
	}

	public static void displayImage(ImageView view, String path, ImageLoadingListener listener) {
		ImageLoader loader = ImageLoader.getInstance();
		try {
			loader.displayImage(path, view, DEFAULT_DISPLAY_IMAGE_OPTIONS, listener);
		} catch (OutOfMemoryError e) {
			e.printStackTrace();
			loader.clearMemoryCache();
		}
	}

	public static void loadImage(String path, ImageLoadingListener listener) {
		ImageLoader loader = ImageLoader.getInstance();
		try {
			loader.loadImage(path, DEFAULT_DISPLAY_IMAGE_OPTIONS, listener);
		} catch (OutOfMemoryError e) {
			e.printStackTrace();
		}
	}

	private static final DisplayImageOptions ROUND_DISPLAY_IMAGE_OPTIONS  = new DisplayImageOptions.Builder()
			.imageScaleType(ImageScaleType.IN_SAMPLE_POWER_OF_2)
			.showImageForEmptyUri(R.drawable.ic_photo_empty)
			.showImageOnLoading(R.drawable.ic_photo_empty)
			.showImageOnFail(R.drawable.ic_photo_empty)
			.considerExifParams(true)
			.cacheOnDisk(true)
			.cacheInMemory(true)
			.bitmapConfig(Config.ARGB_8888)
			.displayer(new CircleBitmapDisplayer()).build();

	private static final DisplayImageOptions ROUND_DISPLAY_PHOTO_OPTIONS  = new DisplayImageOptions.Builder()
			.imageScaleType(ImageScaleType.IN_SAMPLE_POWER_OF_2)
			.showImageForEmptyUri(R.drawable.ic_picture_holder)
			.showImageOnLoading(R.drawable.ic_picture_holder)
			.showImageOnFail(R.drawable.ic_picture_holder)
			.considerExifParams(true)
			.cacheOnDisk(true)
			.cacheInMemory(true)
			.bitmapConfig(Config.ARGB_8888)
			.displayer(new CircleBitmapDisplayer()).build();

	private static final DisplayImageOptions ROUND_DISPLAY_IMAGE_OPTIONS_WITHNO_CACHE  = new DisplayImageOptions.Builder()
			.imageScaleType(ImageScaleType.IN_SAMPLE_POWER_OF_2)
			.showImageForEmptyUri(R.drawable.ic_photo_empty)
			.showImageOnLoading(R.drawable.ic_photo_empty)
			.showImageOnFail(R.drawable.ic_photo_empty)
			.considerExifParams(true)
			.cacheInMemory(false)
			.cacheOnDisk(false)
			.bitmapConfig(Config.ARGB_8888)
			.displayer(new CircleBitmapDisplayer()).build();

	private static final DisplayImageOptions ROUND_DISPLAY_IMAGE_WITH_BORDER_OPTIONS  = new DisplayImageOptions.Builder()
			.imageScaleType(ImageScaleType.IN_SAMPLE_POWER_OF_2)
			.showImageForEmptyUri(R.drawable.ic_photo_empty)
			.showImageOnLoading(R.drawable.ic_photo_empty)
			.showImageOnFail(R.drawable.ic_photo_empty)
			.considerExifParams(true)
			.cacheOnDisk(true)
			.cacheInMemory(true)
			.bitmapConfig(Config.ARGB_8888)
			.displayer(new CircleBitmapDisplayer(Color.WHITE, 10)).build();

	private static final DisplayImageOptions DEFAULT_DISPLAY_IMAGE_OPTIONS = new DisplayImageOptions.Builder()
			.imageScaleType(ImageScaleType.IN_SAMPLE_POWER_OF_2)
			.considerExifParams(true)
			.displayer(new FadeInBitmapDisplayer(500))
			.showImageForEmptyUri(android.R.color.darker_gray)
			.showImageOnLoading(android.R.color.darker_gray)
			.showImageOnFail(android.R.color.darker_gray)
			.cacheOnDisk(true)
			.cacheInMemory(true)
			.bitmapConfig(Config.ARGB_8888).build();
}
