package com.websthewords.giftlog.adapters;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.websthewords.giftlog.R;
import com.websthewords.giftlog.data.manage.DataManager;
import com.websthewords.giftlog.data.model.firebase.fbContact;
import com.websthewords.giftlog.data.model.firebase.fbUser;
import com.websthewords.giftlog.utils.ImageUtil;

import java.util.ArrayList;

/**
 * @description     Contact Item Adapter
 *
 * @author          Adrian
 */
public class ContactItemAdapter<T> extends ArrayAdapter<fbContact> {
    private Context mContext;
    private LayoutInflater mInflater;

    public ContactItemAdapter(Context context) {
        super(context, R.layout.list_item_contact);

        mContext = context;
        mInflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
    }

    /*
     * Set List Item Datas
     *
     */
    public void setData(ArrayList<fbContact> data) {
        clear();
        if (data != null) {
            addAll(data);
        }
    }

    public View getView(final int position, View convertView, ViewGroup parent) {
        ViewHolder holder = null;
        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.list_item_contact, null);

            holder = new ViewHolder();
            holder.rootView = convertView;
            holder.ivPhoto = (ImageView) convertView.findViewById(R.id.ivPhoto);
            holder.tvName = (TextView)convertView.findViewById(R.id.tvName);
            holder.tvPhoneNumber = (TextView)convertView.findViewById(R.id.tvPhoneNumber);
            holder.layoutShare = (View)convertView.findViewById(R.id.layoutShare);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        fbContact contact = getItem(position);

        holder.tvName.setText(contact.getFullName());
        holder.tvPhoneNumber.setText(contact.getPhoneNumber());

        if (!TextUtils.isEmpty(contact.getAvatar()))
            ImageUtil.displayPhotoImage(holder.ivPhoto, contact.getAvatar(), null);
        else
            holder.ivPhoto.setImageResource(R.drawable.ic_contact_item);

        holder.layoutShare.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                requestInviteMessage();
            }
        });

        return convertView;
    }

    /**
     * Send Invite Message
     */
    private void requestInviteMessage() {
        fbUser user = DataManager.getInstance().getUserProfile();
        String name = user.getFirstName() + " " + user.getLastName();

        String message = String.format("%s%s\n\n", mContext.getResources().getString(R.string.invite_message), name);
        message += mContext.getResources().getString(R.string.download_app_text);

        Intent shareIntent = new Intent();
        shareIntent.setAction(Intent.ACTION_SEND);
        shareIntent.putExtra(android.content.Intent.EXTRA_TEXT, message);

        shareIntent.setType("text/plain");

        // Launch sharing dialog for image
        mContext.startActivity(Intent.createChooser(shareIntent, "Share App"));
    }

    public static class ViewHolder {
        public View rootView;
        public ImageView ivPhoto;
        public TextView tvName;
        public TextView tvPhoneNumber;
        public View layoutShare;
    }
}