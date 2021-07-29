package com.websthewords.giftlog.adapters;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.websthewords.giftlog.R;
import com.websthewords.giftlog.data.model.firebase.fbContact;
import com.websthewords.giftlog.utils.ImageUtil;

import java.util.ArrayList;

/**
 * @description     Contact Item Selectable Adapter
 *
 * @author          Adrian
 */
public class ContactItemSelectableAdapter<T> extends ArrayAdapter<fbContact> {
    private Context mContext;
    private LayoutInflater mInflater;
    private OnItemSelectedListener mOnItemSelectedListener;
    private ArrayList<fbContact> mSelectedContacts;

    public interface OnItemSelectedListener {
        void onItemSelected(fbContact contact);
        void onItemUnSelected(fbContact contact);
    }

    public ContactItemSelectableAdapter(Context context, OnItemSelectedListener listener) {
        super(context, R.layout.list_item_contact_selectable);

        mContext = context;
        mInflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        mOnItemSelectedListener = listener;
    }

    /*
     * Set List Item Datas
     *
     */
    public void setData(ArrayList<fbContact> data, ArrayList<fbContact> selectedContacts) {
        clear();
        if (data != null) {
            addAll(data);
        }

        mSelectedContacts = selectedContacts;
    }

    public View getView(final int position, View convertView, ViewGroup parent) {
        ViewHolder holder = null;
        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.list_item_contact_selectable, null);

            holder = new ViewHolder();
            holder.rootView = convertView;
            holder.ivPhoto = (ImageView) convertView.findViewById(R.id.ivPhoto);
            holder.tvName = (TextView)convertView.findViewById(R.id.tvName);
            holder.tvPhoneNumber = (TextView)convertView.findViewById(R.id.tvPhoneNumber);
            holder.ivSelect = (ImageView)convertView.findViewById(R.id.ivSelect);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        final fbContact contact = getItem(position);

        final boolean isSelected = isExistInAddedContacts(contact);

        holder.tvName.setText(contact.getFullName());
        holder.tvPhoneNumber.setText(contact.getPhoneNumber());

        if (!TextUtils.isEmpty(contact.getAvatar()))
            ImageUtil.displayPhotoImage(holder.ivPhoto, contact.getAvatar(), null);
        else
            holder.ivPhoto.setImageResource(R.drawable.ic_contact_item);

        holder.ivSelect.setImageResource(isSelected ? R.drawable.ic_select : R.drawable.ic_unselect);

        holder.rootView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mOnItemSelectedListener != null) {
                    if (!isSelected)
                        mOnItemSelectedListener.onItemSelected(contact);
                    else
                        mOnItemSelectedListener.onItemUnSelected(contact);
                }
            }
        });
        return convertView;
    }

    private boolean isExistInAddedContacts(fbContact contact) {
        boolean exist = false;
        for (fbContact contact1 : mSelectedContacts) {
            if (contact1.getIdentifier().equals(contact.getIdentifier())) {
                exist = true;
                break;
            }
        }
        return exist;
    }

    public static class ViewHolder {
        public View rootView;
        public ImageView ivPhoto;
        public TextView tvName;
        public TextView tvPhoneNumber;
        public ImageView ivSelect;
    }
}