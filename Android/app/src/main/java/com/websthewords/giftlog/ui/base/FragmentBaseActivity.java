package com.websthewords.giftlog.ui.base;

import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentTransaction;

import com.websthewords.giftlog.R;
import com.websthewords.giftlog.ui.fragment.BaseFragment;

import java.util.ArrayList;

/**
 * @description     Fragment Base Activity
 *
 * @author          Adrian
 */

public class FragmentBaseActivity extends FragmentActivity {

    // Variables
    public ArrayList<BaseFragment> mFragments;
    public BaseFragment mSelectedFragment;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

    }

    /**
     * Add Sub Fragment
     *
     */
    public void addFragment(BaseFragment fragment, boolean replace) {
        if (fragment == null)
            return;

        if (fragment != null) {
            FragmentTransaction transaction = getSupportFragmentManager().beginTransaction();
            transaction.setCustomAnimations(R.anim.enter_from_right, R.anim.exit_to_left);
            if (replace) {
                transaction.replace(R.id.container, fragment);

                if (mFragments != null)
                    mFragments.clear();
            }
            else {
                transaction.add(R.id.container, fragment);
                transaction.addToBackStack(null);
            }

            transaction.commit();
        }

        onFragmentAdded(fragment);
    }

    public void onFragmentAdded(BaseFragment fragment) {
        if (mFragments == null)
            mFragments = new ArrayList<>();

        mFragments.add(fragment);

        mSelectedFragment = fragment;

        updateUI();
    }

    public void updateUI() {
        if (mSelectedFragment == null)
            return;

        /*
        if (mSelectedFragment instanceof ProgressFragment) {
            ((TextView) findViewById(R.id.tvPageTitle)).setText(getString(R.string.menu_progress));
        }
        else if (mSelectedFragment instanceof CreateSessionFragment) {
            ((TextView) findViewById(R.id.tvPageTitle)).setText(getString(R.string.track_activity));
        }
        else if (mSelectedFragment instanceof TrackingLiveFragment) {
            ((TextView) findViewById(R.id.tvPageTitle)).setText(getString(R.string.tracking_live));
        }
        else if (mSelectedFragment instanceof PerformanceFragment) {
            ((TextView) findViewById(R.id.tvPageTitle)).setText(getString(R.string.performance));
        }
        */
    }

    protected boolean isFirstLevelFragment(BaseFragment fragment) {
        return true;
        /*
        return (fragment instanceof ProgressFragment ||
                fragment instanceof CreateSessionFragment ||
                fragment instanceof DevicesFragment);
        */
    }

    /**
     * Back Pressed Event Handler
     */
    public void onBackPressed() {
        /*
        if (mSelectedFragment instanceof ProgressFragment) {
            // finish();
            //super.onBackPressed();
            moveTaskToBack(true);
            return;
        }

        if (mSelectedFragment instanceof TrackingLiveFragment || mSelectedFragment instanceof PerformanceFragment) {
            return;
        }

        if (mFragments != null && mFragments.size() > 0) {
            BaseFragment last = getLastFragment();
            if (last != null) {
                if (isFirstLevelFragment(last)) {
                    mSelectedFragment.removeLastFragment(getLastFragment());
                    mFragments.remove(last);

                    // Open Progress Fragment
                    setProgressScreen();
                }
                else {
                    mSelectedFragment.removeLastFragment(getLastFragment());
                    mFragments.remove(last);
                }
            }

            // Check this fragment is home fragment
            last = getLastFragment();
            if (last != null) {
                last.refresh();
            }
        }
        */
    }
}
