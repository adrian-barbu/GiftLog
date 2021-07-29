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
import com.websthewords.giftlog.adapters.EventItemAdapter;
import com.websthewords.giftlog.data.manage.DataManager;
import com.websthewords.giftlog.data.model.enums.HostingType;
import com.websthewords.giftlog.data.model.event.EventChangedEvent;
import com.websthewords.giftlog.data.model.firebase.fbEvent;
import com.websthewords.giftlog.ui.base.BaseActivity;
import com.websthewords.giftlog.ui.creation.CreateEventActivity;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;

import butterknife.Bind;

/**
 * @description     Events Fragment
  *
 * @author          Adrian
 */
public class EventsFragment extends BaseFragment  {
    private final static String TAG = EventsFragment.class.getSimpleName();

    private final static int SORT_A2Z = 0;
    private final static int SORT_Z2A = 1;
    private final static int SORT_NEWEST = 2;
    private final static int SORT_OLDEST = 3;
    private final static int SORT_NONE = 4;

    public enum ViewMode {
        ALL,
        ATTENDED,
        HOSTED
    };

    // UI Members
    @Bind(R.id.ivCreateNew)         ImageView ivCreateNew;
    @Bind(R.id.layoutAll)           View layoutAll;
    @Bind(R.id.layoutAttended)      View layoutAttended;
    @Bind(R.id.layoutHosted)        View layoutHosted;
    @Bind(R.id.lvItems)             SwipeMenuListView lvItems;

    @Bind(R.id.layoutSortBy)        View layoutSortBy;
    @Bind(R.id.tvSortMode)          TextView tvSortMode;

    @Bind(R.id.tvNoEvents)          TextView tvNoEvents;

    // Variables
    int sortMode = SORT_NONE;

    ViewMode mViewMode;
    ArrayList<fbEvent> mEvents;
    EventItemAdapter mEventItemAdapter;
    String[] eventSortOptions;

    @Override  protected int getLayoutId() {
        return R.layout.fragment_events;
    }

    @Override
    protected void initViews() {
        initUI();

        eventSortOptions = getResources().getStringArray(R.array.eventSortOptions);

        mEvents = new ArrayList<>();
        changeViewMode(ViewMode.ALL);
    }

    private void initUI() {
        ivCreateNew.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                getActivity().startActivity(new Intent(getActivity(), CreateEventActivity.class));
            }
        });

        layoutAll.setBackgroundResource(R.drawable.ic_tab_bg);
        layoutAll.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                changeViewMode(ViewMode.ALL);
            }
        });

        layoutAttended.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                changeViewMode(ViewMode.ATTENDED);
            }
        });

        layoutHosted.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                changeViewMode(ViewMode.HOSTED);
            }
        });

        layoutSortBy.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showSortOptions();
            }
        });

        mEventItemAdapter = new EventItemAdapter(getActivity());
        lvItems.setAdapter(mEventItemAdapter);
        lvItems.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                requestUpdateEvent(position);
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
        layoutAttended.setBackgroundResource((mViewMode == ViewMode.ATTENDED) ? R.drawable.ic_tab_bg : android.R.color.transparent);
        layoutHosted.setBackgroundResource((mViewMode == ViewMode.HOSTED) ? R.drawable.ic_tab_bg : android.R.color.transparent);

        updateUI();
    }

    private void updateUI() {
        if (sortMode == SORT_NONE)    // clear filter
        {
            tvSortMode.setVisibility(View.GONE);
        } else {
            tvSortMode.setVisibility(View.VISIBLE);
            tvSortMode.setText(eventSortOptions[sortMode]);
        }

        // Reset Data
        mEvents.clear();

        ArrayList<fbEvent> events = DataManager.getInstance().getAllEvents();
        for(Iterator<fbEvent> it = events.iterator(); it.hasNext();) {
            fbEvent event = it.next();

            if (mViewMode == ViewMode.ATTENDED) {
                if (event.getHostingType() == HostingType.ATTENDED)
                    mEvents.add(event);
            }
            else if (mViewMode == ViewMode.HOSTED) {
                if (event.getHostingType() == HostingType.HOSTED)
                    mEvents.add(event);
            }
            else {
                mEvents.add(event);
            }
        }

        Collections.reverse(mEvents);

        if (sortMode == SORT_A2Z)
            Collections.sort(mEvents, new AZComparator());
        else if (sortMode == SORT_Z2A)
            Collections.sort(mEvents, new ZAComparator());
        else if (sortMode == SORT_NEWEST)
            Collections.sort(mEvents, new NewestComparator());
        else if (sortMode == SORT_OLDEST)
            Collections.sort(mEvents, new OldestComparator());

        mEventItemAdapter.setData(mEvents);

        tvNoEvents.setVisibility((mEvents.isEmpty()) ? View.VISIBLE : View.GONE);
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
                        requestUpdateEvent(position);
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
        final String[] deleteEventMenuArray = getResources().getStringArray(R.array.deleteEventMenu);
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        builder.setItems(deleteEventMenuArray, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                if (which == 0) {
                    deleteEvent(position);
                }
            }
        });
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
    }

    private void deleteEvent(int position) {
        final fbEvent event = mEvents.get(position);

        mWaitDialog.show();
        DataManager.getInstance().getEventRoot().child(event.getIdentifier()).removeValue(new DatabaseReference.CompletionListener() {
            @Override
            public void onComplete(DatabaseError databaseError, DatabaseReference databaseReference) {
                mWaitDialog.dismiss();
                mEvents.remove(event);
                mEventItemAdapter.notifyDataSetChanged();
            }
        });
    }
    
    /**
     * Update Gift
     *
     * @param position
     */
    private void requestUpdateEvent(int position) {
        fbEvent event = mEvents.get(position);

        Intent intent = new Intent(getActivity(), CreateEventActivity.class);
        intent.putExtra(BaseActivity.PARAM_ORIGINAL, event);
        startActivity(intent);
    }
    
    private void showSortOptions() {
        AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
        builder.setTitle("Sort");
        builder.setItems(eventSortOptions, new DialogInterface.OnClickListener() {
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
    public void onMessageEvent(EventChangedEvent event) {
        updateUI();
    }

    public class AZComparator implements Comparator<fbEvent>
    {
        public int compare(fbEvent left, fbEvent right) {
            return left.eventTitle.compareTo(right.eventTitle);
        }
    }

    public class ZAComparator implements Comparator<fbEvent>
    {
        public int compare(fbEvent left, fbEvent right) {
            return right.eventTitle.compareTo(left.eventTitle);
        }
    }

    public class NewestComparator implements Comparator<fbEvent>
    {
        public int compare(fbEvent left, fbEvent right) {
            return (left.dateStart < right.dateStart) ? 1 : -1;
        }
    }

    public class OldestComparator implements Comparator<fbEvent>
    {
        public int compare(fbEvent left, fbEvent right) {
            return (left.dateStart > right.dateStart) ? 1 : -1;
        }
    }
}