package com.websthewords.giftlog.ui;

import android.media.Image;
import android.os.Bundle;
import android.widget.ImageView;

import com.websthewords.giftlog.R;
import com.websthewords.giftlog.ui.base.BaseActivity;
import com.websthewords.giftlog.utils.ImageUtil;

/**
 * @description     Image View Activity
 *
 * @author          Adrian
 */
public class ImageViewActivity extends BaseActivity {

    public final static String PARAM_IMAGE_URL = "imageUrl";

    // Variables
    String mImageUrl;

    // UI Controls
    ImageView ivImage;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_image_view);

        mImageUrl = getIntent().getStringExtra(PARAM_IMAGE_URL);

        ivImage = (ImageView) findViewById(R.id.ivImage);
        ImageUtil.displayImage(ivImage, mImageUrl, null);
    }

}
