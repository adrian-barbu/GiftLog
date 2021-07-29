package com.websthewords.giftlog.ui;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import com.google.firebase.auth.FirebaseAuth;
import com.websthewords.giftlog.R;
import com.websthewords.giftlog.controls.CirclePageIndicator;
import com.websthewords.giftlog.data.GLPreference;
import com.websthewords.giftlog.data.manage.DataManager;
import com.websthewords.giftlog.ui.base.BaseActivity;

/**
 * @description Tutorial Activity
 *
 * @author      Adrian
 */
public class TutorialActivity extends BaseActivity {

    // UI Members
    CirclePageIndicator cpiIndicator;
    ViewPager vpTutorial;
    TextView tvNext;
    Button btnLogin, btnSignUp;

    // Variables
    TutorialPagerAdapter mTutorialPagerAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_tutorial);

        tvNext = (TextView) findViewById(R.id.tvNext);
        tvNext.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                goNext();
            }
        });

        mTutorialPagerAdapter = new TutorialPagerAdapter(this);

        vpTutorial = (ViewPager) findViewById(R.id.vpTutorial);
        vpTutorial.setAdapter(mTutorialPagerAdapter);

        cpiIndicator = (CirclePageIndicator) findViewById(R.id.cpiIndicator);
        cpiIndicator.setViewPager(vpTutorial);
    }

    private void goNext() {
        GLPreference.setFirstRun(false);

        if (FirebaseAuth.getInstance().getCurrentUser() != null) {
            DataManager.getInstance().initialize();
            startActivity(new Intent(TutorialActivity.this, MainActivity.class));
        }
        else {
            startActivity(new Intent(TutorialActivity.this, LoginActivity.class));
        }

        finish();
    }

    /*
    * Pager Adapter
    */
    class TutorialPagerAdapter extends PagerAdapter {
        private LayoutInflater mInflater;

        public TutorialPagerAdapter(Context context) {
            mInflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        }

        @Override
        public int getCount() {
            return 5;
        }

        @Override
        public boolean isViewFromObject(View view, Object object) {
            return (view == object);
        }

        @Override
        public Object instantiateItem(ViewGroup container, final int position) {
            ViewGroup rootView;

            if (position == 0)
                rootView = (ViewGroup) mInflater.inflate(R.layout.page_item_tutorial_1, null);
            else if (position == 1)
                rootView = (ViewGroup) mInflater.inflate(R.layout.page_item_tutorial_2, null);
            else if (position == 2)
                rootView = (ViewGroup) mInflater.inflate(R.layout.page_item_tutorial_3, null);
            else if (position == 3)
                rootView = (ViewGroup) mInflater.inflate(R.layout.page_item_tutorial_4, null);
            else {
                rootView = (ViewGroup) mInflater.inflate(R.layout.page_item_tutorial_5, null);
                ((TextView)rootView.findViewById(R.id.tvLetsGo)).setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        goNext();
                    }
                });
            }

            container.addView(rootView);
            return rootView;
        }

        @Override
        public void destroyItem(ViewGroup container, int position, Object object) {
            container.removeView((View) object);
        }
    }
}
