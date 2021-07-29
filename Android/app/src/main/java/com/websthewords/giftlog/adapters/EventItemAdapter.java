package com.websthewords.giftlog.adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import com.websthewords.giftlog.R;
import com.websthewords.giftlog.data.model.firebase.fbEvent;
import com.websthewords.giftlog.utils.StringUtils;

import java.util.ArrayList;

/**
 * @description     Event Item Adapter
 *
 * @author          Adrian
 */
public class EventItemAdapter<T> extends ArrayAdapter<fbEvent> {
    private Context mContext;
    private LayoutInflater mInflater;

    public EventItemAdapter(Context context) {
        super(context, R.layout.list_item_event);

        mContext = context;
        mInflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
    }

    /*
     * Set List Item Datas
     *
     */
    public void setData(ArrayList<fbEvent> data) {
        clear();
        if (data != null) {
            addAll(data);
        }
    }

    public View getView(final int position, View convertView, ViewGroup parent) {
        ViewHolder holder = null;
        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.list_item_event, null);

            holder = new ViewHolder();
            holder.rootView = convertView;
            holder.tvEventName = (TextView)convertView.findViewById(R.id.tvEventName);
            holder.tvStartDate = (TextView)convertView.findViewById(R.id.tvStartDate);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        fbEvent event = getItem(position);

        holder.tvEventName.setText(event.getEventTitle());
        holder.tvStartDate.setText(StringUtils.getDateFromMiliseconds(event.getDateStart()));

        return convertView;
    }

    public static class ViewHolder {
        public View rootView;
        public TextView tvEventName;
        public TextView tvStartDate;
    }
}