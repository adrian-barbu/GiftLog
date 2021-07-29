package com.websthewords.giftlog.ui.fragment;

import android.os.Bundle;
import android.support.annotation.LayoutRes;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import com.websthewords.giftlog.ui.MainActivity;
import com.websthewords.giftlog.R;
import com.websthewords.giftlog.controls.WaitDialog;

import butterknife.ButterKnife;

/**
 * @description     Base Fragment
 *
 * @author          Adrian
 */
public class BaseFragment extends Fragment {

    protected WaitDialog mWaitDialog;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View root = inflater.inflate(getLayoutId(), null);
        ButterKnife.bind(this, root);

        mWaitDialog = new WaitDialog(getActivity());

        initViews();

        return root;
    }

    @LayoutRes
    protected int getLayoutId() {return 0;};

    protected void initViews() {};

    public void refresh() {}

    /**
     * Add Fragment
     */
    public void addFragment(BaseFragment fragment, boolean replace) {
        ((MainActivity) getActivity()).addFragment(fragment, replace);
    }

    /**
     * Remove Last Fragment
     */
    public void removeLastFragment(BaseFragment fragment) {
        fragment.onDestroy();

        FragmentTransaction transaction = getFragmentManager().beginTransaction();
        transaction.setCustomAnimations(R.anim.enter_from_left, R.anim.exit_to_right);
        transaction.remove(fragment);
        transaction.commit();
    }

    /**
     * Show Toast Message
     *
     * @param res_id
     */
    protected void showToastMessage(int res_id) {
        try {
            Toast.makeText(getActivity(), res_id, Toast.LENGTH_SHORT).show();
        }
        catch (Exception e)
        {}
    }

    protected void showToastMessage(String msg) {
        try {
            Toast.makeText(getActivity(), msg, Toast.LENGTH_SHORT).show();
        } catch (Exception e) {

        }
    }

    protected int dp2px(int dp) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp,
                getResources().getDisplayMetrics());
    }
}
