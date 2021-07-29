package com.websthewords.giftlog.ui.fragment;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.TextView;

import com.baoyz.swipemenulistview.SwipeMenu;
import com.baoyz.swipemenulistview.SwipeMenuCreator;
import com.baoyz.swipemenulistview.SwipeMenuItem;
import com.baoyz.swipemenulistview.SwipeMenuListView;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.websthewords.giftlog.R;
import com.websthewords.giftlog.adapters.GiftItemAdapter;
import com.websthewords.giftlog.data.manage.DataManager;
import com.websthewords.giftlog.data.model.enums.InOutType;
import com.websthewords.giftlog.data.model.event.ContactChangedEvent;
import com.websthewords.giftlog.data.model.event.GiftChangedEvent;
import com.websthewords.giftlog.data.model.firebase.fbGift;
import com.websthewords.giftlog.ui.base.BaseActivity;
import com.websthewords.giftlog.ui.creation.CreateGiftActivity;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;

import butterknife.Bind;

/**
 * @author Adrian
 * @description Gifts Fragment
 */
public class GiftsFragment extends BaseFragment {
    private final static String TAG = GiftsFragment.class.getSimpleName();

    private final static int MODE_NO_FILTER = 5;

    private final static int SORT_A2Z = 0;
    private final static int SORT_Z2A = 1;
    private final static int SORT_NONE = 2;

    public enum ViewMode {
        ALL,
        RECEIVED,
        GIVEN
    };

    // UI Members
    @Bind(R.id.layoutAll)               View layoutAll;
    @Bind(R.id.layoutReceived)          View layoutReceived;
    @Bind(R.id.layoutGiven)             View layoutGiven;
    @Bind(R.id.lvItems)                 SwipeMenuListView lvItems;
    @Bind(R.id.ivCreateNew)             ImageView ivCreateNew;

    @Bind(R.id.layoutFilterBy)          View layoutFilterBy;
    @Bind(R.id.tvFilterMode)            TextView tvFilterMode;

    @Bind(R.id.layoutSortBy)            View layoutSortBy;
    @Bind(R.id.tvSortMode)              TextView tvSortMode;

    @Bind(R.id.tvNoGift)                TextView tvNoGift;

    // Variables
    ViewMode mViewMode;
    int filterMode = MODE_NO_FILTER;         // clear filter
    int sortMode = SORT_NONE;
    GiftItemAdapter mGiftItemAdapter;
    ArrayList<fbGift> mGifts;
    String[] giftFilterOptions;
    String[] giftSortOptions;

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_gifts;
    }

    @Override
    protected void initViews() {
        initUI();

        giftFilterOptions = getResources().getStringArray(R.array.giftStatusWithClear);
        giftSortOptions = getResources().getStringArray(R.array.giftSortOptions);

        mGifts = new ArrayList<>();
        changeViewMode(ViewMode.ALL);
    }

    private void initUI() {
        ivCreateNew.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                getActivity().startActivity(new Intent(getActivity(), CreateGiftActivity.class));
            }
        });

        layoutAll.setBackgroundResource(R.drawable.ic_tab_bg);
        layoutAll.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                changeViewMode(ViewMode.ALL);
            }
        });

        layoutReceived.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                changeViewMode(ViewMode.RECEIVED);
            }
        });

        layoutFilterBy.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showFilterOptions();
            }
        });
        layoutSortBy.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showSortOptions();
            }
        });
        layoutGiven.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                changeViewMode(ViewMode.GIVEN);
            }
        });

        mGiftItemAdapter = new GiftItemAdapter(getActivity());
        lvItems.setAdapter(mGiftItemAdapter);
        lvItems.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                requestUpdateGift(position);
            }
        });
        initMenuCreator();
    }

    /**
     * Change View Mode
     *
     * @param mode
     */
    private void changeViewMode(ViewMode mode) {
        if (mode == mViewMode)
            return;

        mViewMode = mode;

        layoutAll.setBackgroundResource((mViewMode == ViewMode.ALL) ? R.drawable.ic_tab_bg : android.R.color.transparent);
        layoutReceived.setBackgroundResource((mViewMode == ViewMode.RECEIVED) ? R.drawable.ic_tab_bg : android.R.color.transparent);
        layoutGiven.setBackgroundResource((mViewMode == ViewMode.GIVEN) ? R.drawable.ic_tab_bg : android.R.color.transparent);

        updateUI();
    }

    private void updateUI() {
        if (filterMode == MODE_NO_FILTER)    // clear filter
        {
            tvFilterMode.setVisibility(View.GONE);
        } else {
            tvFilterMode.setVisibility(View.VISIBLE);
            tvFilterMode.setText(giftFilterOptions[filterMode]);
        }

        if (sortMode == SORT_NONE)    // clear filter
        {
            tvSortMode.setVisibility(View.GONE);
        } else {
            tvSortMode.setVisibility(View.VISIBLE);
            tvSortMode.setText(giftSortOptions[sortMode]);
        }

        // Reset Data
        mGifts.clear();

        ArrayList<fbGift> gifts = DataManager.getInstance().getAllGifts();
        for (Iterator<fbGift> it = gifts.iterator(); it.hasNext(); ) {
            fbGift gift = it.next();

            if (mViewMode == ViewMode.RECEIVED) {
                if (gift.getInOutType() == InOutType.RECEIVED) {
                    if (filterMode == MODE_NO_FILTER)
                        mGifts.add(gift);
                    else if (filterMode != MODE_NO_FILTER && gift.getStatus() == filterMode)
                        mGifts.add(gift);
                }
            } else if (mViewMode == ViewMode.GIVEN) {
                if (gift.getInOutType() == InOutType.GIVEN) {
                    if (filterMode == MODE_NO_FILTER)
                        mGifts.add(gift);
                    else if (filterMode != MODE_NO_FILTER && gift.getStatus() == filterMode)
                        mGifts.add(gift);
                }
            } else {
                if (filterMode == MODE_NO_FILTER)
                    mGifts.add(gift);
                else if (filterMode != MODE_NO_FILTER && gift.getStatus() == filterMode)
                    mGifts.add(gift);
            }
        }

        Collections.reverse(mGifts);

        if (sortMode == SORT_A2Z)
            Collections.sort(mGifts, new GiftAZComparator());
        else if (sortMode == SORT_Z2A)
            Collections.sort(mGifts, new GiftZAComparator());

        mGiftItemAdapter.setData(mGifts);

        tvNoGift.setVisibility((mGifts.isEmpty()) ? View.VISIBLE : View.GONE);
    }

    private void initMenuCreator() {
        SwipeMenuCreator creator = new SwipeMenuCreator() {
            @Override
            public void create(SwipeMenu menu) {
                SwipeMenuItem item1 = new SwipeMenuItem(getActivity());
                item1.setBackground(R.color.colorBlue);
                item1.setWidth(dp2px(90));
                item1.setIcon(R.drawable.ic_edit_white);
                menu.addMenuItem(item1);

                SwipeMenuItem item2 = new SwipeMenuItem(getActivity());
                item2.setBackground(R.color.colorMagento);
                item2.setWidth(dp2px(90));
                item2.setIcon(R.drawable.ic_delete_white);
                menu.addMenuItem(item2);
            }
        };

        // set creator
        lvItems.setMenuCreator(creator);

        lvItems.setOnMenuItemClickListener(new SwipeMenuListView.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(int position, SwipeMenu menu, int index) {
                switch (index) {
                    case 0:
                        // edit
                        requestUpdateGift(position);
                        break;

                    case 1:
                        // delete
                        requestDelete(position);
                        break;
                }
                return false;
            }
        });
    }

    private void requestDelete(final int position) {
        final String[] deleteGiftMenuArray = getResources().getStringArray(R.array.deleteGiftMenu);
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        builder.setItems(deleteGiftMenuArray, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                if (which == 0) {
                    deleteGift(position);
                }
            }
        });
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
    }

    private void deleteGift(int position) {
        final fbGift gift = mGifts.get(position);

        mWaitDialog.show();
        DataManager.getInstance().getGiftRoot().child(gift.getIdentifier()).removeValue(new DatabaseReference.CompletionListener() {
            @Override
            public void onComplete(DatabaseError databaseError, DatabaseReference databaseReference) {
                mWaitDialog.dismiss();
                mGifts.remove(gift);
                mGiftItemAdapter.notifyDataSetChanged();
            }
        });
    }

    /**
     * Update Gift
     *
     * @param position
     */
    private void requestUpdateGift(int position) {
        fbGift gift = mGifts.get(position);

        Intent intent = new Intent(getActivity(), CreateGiftActivity.class);
        intent.putExtra(BaseActivity.PARAM_ORIGINAL, gift);
        startActivity(intent);
    }

    private void showFilterOptions() {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        builder.setTitle("Filter");
        builder.setItems(giftFilterOptions, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                filterMode = which;
                updateUI();
            }
        });
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
    }

    private void showSortOptions() {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        builder.setTitle("Sort");
        builder.setItems(giftSortOptions, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                sortMode = which;
                updateUI();
            }
        });
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
    }

    @Override
    public void onStart() {
        super.onStart();

        if (!EventBus.getDefault().isRegistered(this))
            EventBus.getDefault().register(this);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();

        EventBus.getDefault().unregister(this);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onMessageEvent(GiftChangedEvent event) {
        updateUI();
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onMessageEvent(ContactChangedEvent event) {
        updateUI();
    }

    public class GiftAZComparator implements Comparator<fbGift>
    {
        public int compare(fbGift left, fbGift right) {
            return left.name.compareTo(right.name);
        }
    }

    public class GiftZAComparator implements Comparator<fbGift>
    {
        public int compare(fbGift left, fbGift right) {
            return right.name.compareTo(left.name);
        }
    }
}