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
import com.websthewords.giftlog.data.manage.DataManager;
import com.websthewords.giftlog.data.model.enums.InOutType;
import com.websthewords.giftlog.data.model.firebase.fbContact;
import com.websthewords.giftlog.data.model.firebase.fbGift;
import com.websthewords.giftlog.data.model.firebase.fbGiftImage;
import com.websthewords.giftlog.data.model.firebase.fbPreloader;
import com.websthewords.giftlog.utils.ImageUtil;

import java.util.ArrayList;

/**
 * @description     Gift Item Adapter
 *
 * @author          Adrian
 */
public class GiftItemAdapter<T> extends ArrayAdapter<fbGift> {
    private Context mContext;
    private LayoutInflater mInflater;

    public GiftItemAdapter(Context context) {
        super(context, R.layout.list_item_gift);

        mContext = context;
        mInflater = (LayoutInflater) mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
    }

    /*
     * Set List Item Datas
     *
     */
    public void setData(ArrayList<fbGift> data) {
        clear();
        if (data != null) {
            addAll(data);
        }
    }

    public View getView(final int position, View convertView, ViewGroup parent) {
        ViewHolder holder = null;
        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.list_item_gift, null);

            holder = new ViewHolder();
            holder.rootView = convertView;
            holder.tvGiftName = (TextView)convertView.findViewById(R.id.tvGiftName);
            holder.ivGiftImage = (ImageView)convertView.findViewById(R.id.ivGiftImage);
            holder.tvGiftDescription = (TextView)convertView.findViewById(R.id.tvGiftDescription);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        fbGift gift = getItem(position);

        holder.tvGiftName.setText(gift.getName());

        String description = "";
        if (gift.getInOutType() == InOutType.GIVEN)
            description = "To ";
        else
            description = "From ";

        ArrayList<fbContact> fContactList = new ArrayList<>();

        if (gift.getContacts() != null) {
            fbContact fContact;
            for (fbPreloader preloader : gift.getContacts()) {
                fContact = DataManager.getInstance().getContactById(preloader.getIdentifier());
                if (fContact != null)
                    fContactList.add(fContact);
            }
        }

        if (fContactList.size() == 0)
            description = "";
        else if (fContactList.size() > 1)
            description += String.format("%s and other(s)", fContactList.get(0).getFullName());
        else
            description += fContactList.get(0).getFullName();
        holder.tvGiftDescription.setText(description);

        ArrayList<fbGiftImage> images = gift.images;
        if (images != null && !images.isEmpty())
            ImageUtil.displayUserImage(holder.ivGiftImage, gift.images.get(0).getUrl(), null);
        else
            holder.ivGiftImage.setImageResource(R.drawable.ic_gift_item);

        return convertView;
    }

    public static class ViewHolder {
        public View rootView;
        public TextView tvGiftName;
        public ImageView ivGiftImage;
        public TextView tvGiftDescription;
    }
}