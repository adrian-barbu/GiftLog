package com.websthewords.giftlog.ui.creation;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.annotation.NonNull;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.LinearInterpolator;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.PopupMenu;
import android.widget.ScrollView;
import android.widget.TextView;

import com.github.aakira.expandablelayout.ExpandableLinearLayout;
import com.github.aakira.expandablelayout.ExpandableRelativeLayout;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;
import com.websthewords.giftlog.R;
import com.websthewords.giftlog.data.manage.DataManager;
import com.websthewords.giftlog.data.model.enums.InOutType;
import com.websthewords.giftlog.data.model.firebase.fbContact;
import com.websthewords.giftlog.data.model.firebase.fbContactDate;
import com.websthewords.giftlog.data.model.firebase.fbGift;
import com.websthewords.giftlog.data.model.firebase.fbGiftImage;
import com.websthewords.giftlog.data.model.firebase.fbPreloader;
import com.websthewords.giftlog.data.model.firebase.fbUser;
import com.websthewords.giftlog.phototaker.PhotoTaker;
import com.websthewords.giftlog.ui.base.BaseActivity;
import com.websthewords.giftlog.utils.ImageUtil;
import com.websthewords.giftlog.utils.StringUtils;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;

import butterknife.Bind;
import butterknife.ButterKnife;

/**
 * @description     Create Contact Activity
 *
 * @author          Adrian
 */
public class CreateContactActivity extends BaseActivity {
    public final static int REQUEST_SELECT_GIFT = 2000;

    // Variables
    boolean isRequestReturn;
    boolean isCreateRequestedWithGift;   // the case when the gift is already set
    
    fbContact mContact;
    fbContact mOrgContact;

    ArrayList<fbContactDate>            mContactDates;
    ArrayList<fbPreloader>              mSelectedGifts;

    LayoutInflater mLayoutInflater;
    PhotoTaker photoTaker;
    Bitmap userPhotoBitmap;

    // UI Controls
    @Bind(R.id.tvContactNameT)          TextView tvContactNameT;
    @Bind(R.id.ivDelete)                ImageView ivDelete;

    @Bind(R.id.ivUserImage)             ImageView ivUserImage;
    @Bind(R.id.etFirstName)             EditText etFirstName;
    @Bind(R.id.etLastName)              EditText etLastName;
    @Bind(R.id.etNickName)              EditText etNickName;
    @Bind(R.id.etEmailAddress)          EditText etEmailAddress;
    @Bind(R.id.etPhoneNumber)           EditText etPhoneNumber;
    @Bind(R.id.layoutInviteToApp)       View layoutInviteToApp;

    @Bind(R.id.etLikes)                 EditText etLikes;
    @Bind(R.id.etDislikes)              EditText etDislikes;

    @Bind(R.id.layoutDateList)          ViewGroup layoutDateList;
    @Bind(R.id.layoutGiftList)          ViewGroup layoutGiftList;

    @Bind(R.id.scrollView)              ScrollView scrollView;

    @Bind(R.id.layoutInfo)              View layoutInfo;
    @Bind(R.id.layoutExpInfo)           ExpandableRelativeLayout layoutExpInfo;

    @Bind(R.id.layoutDates)             View layoutDates;
    @Bind(R.id.layoutExpDates)          ExpandableLinearLayout layoutExpDates;

    @Bind(R.id.layoutGiftsInfo)         View layoutGiftsInfo;
    @Bind(R.id.layoutExpGiftsInfo)      ExpandableLinearLayout layoutExpGiftsInfo;

    @Bind(R.id.layoutWishList)          View layoutWishList;
    @Bind(R.id.layoutExpWishList)       ExpandableRelativeLayout layoutExpWishList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_create_contact);

        ButterKnife.bind(this);

        mLayoutInflater = (LayoutInflater) getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        isRequestReturn = getIntent().getBooleanExtra(PARAM_REQUEST_RETURN, false);

        mContactDates = new ArrayList<>();
        mSelectedGifts = new ArrayList<>();

        photoTaker = new PhotoTaker(this);

        initUI();

        mOrgContact = getIntent().getParcelableExtra(PARAM_ORIGINAL);
        if (mOrgContact != null) {
            mContact = fbContact.clone(mOrgContact);
            bindUI();
        }
        else {
            // Create new event here
            mContact = new fbContact();
            mContact.ownerId = getUserId();
            mContact.identifier = DataManager.getInstance().getEventRoot().push().getKey();
        }

        isCreateRequestedWithGift = getIntent().getParcelableExtra(PARAM_SELECTED_GIFT) != null;
        if (isCreateRequestedWithGift) {
            fbGift gift = getIntent().getParcelableExtra(PARAM_SELECTED_GIFT);

            boolean isAlreadyAdded = false;
            for (fbPreloader preloader : mSelectedGifts) {
                if (preloader.getIdentifier().equals(gift.getIdentifier())) {
                    isAlreadyAdded = true;
                    break;
                }
            }

            if (!isAlreadyAdded)
                mSelectedGifts.add(new fbPreloader(gift.getIdentifier()));

        }

        initExpandableControls();

        layoutExpWishList.collapse();
    }

    private void initUI() {
        etFirstName.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                tvContactNameT.setText(String.format("%s %s", etFirstName.getText().toString(), etLastName.getText().toString()));
                mContact.firstName = etFirstName.getText().toString().trim();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });

        etLastName.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                tvContactNameT.setText(String.format("%s %s", etFirstName.getText().toString(), etLastName.getText().toString()));
                mContact.lastName = etLastName.getText().toString().trim();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    private void bindUI() {
        if (mContact == null)
            return;

        ivDelete.setVisibility(View.VISIBLE);
        tvContactNameT.setText(mContact.getFullName());
        etFirstName.setText(mContact.getFirstName());
        etLastName.setText(mContact.getLastName());
        etNickName.setText(mContact.getNickName());
        etEmailAddress.setText(mContact.getEmail());
        etPhoneNumber.setText(mContact.getPhoneNumber());
        etLikes.setText(mContact.getLikes());
        etDislikes.setText(mContact.getDislikes());
        ImageUtil.displayPhotoImage(ivUserImage, mContact.getAvatar(), null);

        if (mContact.getGifts() != null)
            mSelectedGifts = mContact.getGifts();
        updateGiftListLayout(false);

        mContactDates = mContact.getDates();
        updateDateLayout(false);
    }

    public void onDone(View v) {
        // Validation
        if (!validation())
            return;

        pushTo();

        mWaitDialog.show();
        DataManager.getInstance().getContactRoot().child(mContact.getIdentifier()).setValue(mContact, new DatabaseReference.CompletionListener() {
            @Override
            public void onComplete(DatabaseError databaseError, DatabaseReference databaseReference) {
                mWaitDialog.dismiss();

                mOrgContact = fbContact.clone(mContact);

                if (isRequestReturn || isCreateRequestedWithGift)
                {
                    Intent returnIntent = new Intent();
                    returnIntent.putExtra("result", mContact);
                    setResult(Activity.RESULT_OK, returnIntent);
                    finish();
                }
            }
        });
    }

    private void pushTo() {
        mContact.firstName = etFirstName.getText().toString().trim();
        mContact.lastName = etLastName.getText().toString().trim();
        mContact.nickName = etNickName.getText().toString().trim();
        mContact.email = etEmailAddress.getText().toString().trim();
        mContact.phoneNumber = etPhoneNumber.getText().toString().trim();

        mContact.likes = etLikes.getText().toString().trim();
        mContact.dislikes = etDislikes.getText().toString().trim();

        if (mContactDates != null && !mContactDates.isEmpty())
            mContact.dates = mContactDates;

        if (mSelectedGifts != null && !mSelectedGifts.isEmpty())
            mContact.gifts = mSelectedGifts;
    }

    protected boolean validation() {
        if (TextUtils.isEmpty(etFirstName.getText().toString().trim())) {
            showWarningDialog(R.string.warning_create_contact_1_text, R.string.warning_create_contact_1);
            return false;
        }

        String email = etEmailAddress.getText().toString().trim();
        if (!TextUtils.isEmpty(email) && !StringUtils.isEmailValid(email)) {
            showToast(R.string.wrong_invalid_email);
            return false;
        }

        return true;
    }

    public void onDelete(View v) {
        final String[] deleteContactMenuArray = getResources().getStringArray(R.array.deleteContactMenu);
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setItems(deleteContactMenuArray, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                if (which == 0) {
                    deleteContact();
                }
            }
        });
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
    }

    private void deleteContact() {
        mWaitDialog.show();
        DataManager.getInstance().getContactRoot().child(mContact.getIdentifier()).removeValue(new DatabaseReference.CompletionListener() {
            @Override
            public void onComplete(DatabaseError databaseError, DatabaseReference databaseReference) {
                mWaitDialog.dismiss();
                finish();
            }
        });
    }

    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.ivUserImage:
                requestAddPhoto(v);
                break;

            case R.id.ivAddDate:
                //showTypeItems();
                DateSelectionDialog dialog = new DateSelectionDialog(this, new DateSelectionDialog.OnDateSelectedListener() {
                    @Override
                    public void onDateSelected(String title, int year, int month, int day) {
                        Date newDate = new Date(year - 1900, month - 1, day);

                        fbContactDate date = new fbContactDate(title, newDate.getTime() / 1000);
                        if (mContactDates == null)
                            mContactDates = new ArrayList<>();

                        mContactDates.add(date);

                        updateDateLayout(true);
                    }
                });
                dialog.show();
                break;

            case R.id.ivAddGift:
                requestAddGift();
                break;

            case R.id.layoutInviteToApp:
                requestInviteMessage();
                break;
        }
    }

    public void updateDateLayout(boolean withScroll) {
        layoutDateList.removeAllViews();

        if (mContactDates != null && !mContactDates.isEmpty()) {
            View itemView;
            for (final fbContactDate date : mContactDates) {
                itemView = mLayoutInflater.inflate(R.layout.list_item_date, null);

                ((TextView) itemView.findViewById(R.id.tvName)).setText(date.getName());
                ((TextView) itemView.findViewById(R.id.tvDate)).setText(StringUtils.getDateFromMiliseconds1(date.getTimeStamp()));

                View layoutDelete = (View) itemView.findViewById(R.id.layoutDelete);
                layoutDelete.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        mContactDates.remove(date);
                        updateDateLayout(true);
                    }
                });

                layoutDateList.addView(itemView);
            }
        }

        layoutExpDates.initLayout();

        if (withScroll) {
            layoutExpDates.expand(0, new LinearInterpolator());
            layoutGiftsInfo.getParent().requestChildFocus(layoutGiftsInfo, layoutGiftsInfo);
        }
    }

    /**
     * Request Add Gift
     */
    private void requestAddGift() {
        if (!validation())
            return;

        Intent intent = new Intent(this, CreateGiftActivity.class);
        intent.putExtra(PARAM_REQUEST_RETURN, true);
        intent.putExtra(PARAM_SELECTED_CONTACT, mContact);
        startActivityForResult(intent, REQUEST_SELECT_GIFT);
    }

    /**
     * Send Invite Message
     */
    private void requestInviteMessage() {
        fbUser user = DataManager.getInstance().getUserProfile();
        String name = user.getFirstName() + " " + user.getLastName();

        String message = String.format("%s%s\n\n", getResources().getString(R.string.invite_message), name);
        message += getResources().getString(R.string.download_app_text);
        doShare(message);
    }

    public void initExpandableControls() {
        layoutInfo.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                layoutExpInfo.toggle();

                if (!layoutExpInfo.isExpanded())
                    ((ImageView)findViewById(R.id.ivArrowIcon)).setImageResource(R.drawable.ic_arrow_up);
                else
                    ((ImageView)findViewById(R.id.ivArrowIcon)).setImageResource(R.drawable.ic_arrow_down);
            }
        });

        layoutDates.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                layoutExpDates.toggle();

                if (!layoutExpDates.isExpanded())
                    ((ImageView)findViewById(R.id.ivDateArrowIcon)).setImageResource(R.drawable.ic_arrow_up);
                else
                    ((ImageView)findViewById(R.id.ivDateArrowIcon)).setImageResource(R.drawable.ic_arrow_down);
            }
        });

        layoutGiftsInfo.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (isCreateRequestedWithGift) {
                    // If gift was set when requesting, there is no need to expand
                    showToast(R.string.warning_gift_info_already_set);
                    return;
                }

                layoutExpGiftsInfo.toggle();

                if (!layoutExpGiftsInfo.isExpanded())
                    ((ImageView)findViewById(R.id.ivGiftArrowIcon)).setImageResource(R.drawable.ic_arrow_up);
                else
                    ((ImageView)findViewById(R.id.ivGiftArrowIcon)).setImageResource(R.drawable.ic_arrow_down);
            }
        });

        layoutWishList.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                layoutExpWishList.toggle();

                if (!layoutExpWishList.isExpanded()) {
                    ((ImageView) findViewById(R.id.ivWishListArrowIcon)).setImageResource(R.drawable.ic_arrow_up);

                    final int scrollY = (int)scrollView.getX() + scrollView.getHeight();
                    scrollView.postDelayed(new Runnable() {
                        public void run() {
                            scrollView.smoothScrollTo(0, scrollY);
                        }
                    }, 250);
                }
                else
                    ((ImageView)findViewById(R.id.ivWishListArrowIcon)).setImageResource(R.drawable.ic_arrow_down);
            }
        });
    }

    protected void requestAddPhoto(View v) {
        // Popup menu
        final PopupMenu popup = new PopupMenu(this, v);
        //Inflating the Popup using xml file
        popup.getMenuInflater().inflate(R.menu.popup_add_image, popup.getMenu());

        //registering popup with OnMenuItemClickListener
        popup.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
            public boolean onMenuItemClick(MenuItem item) {
                switch (item.getItemId()) {
                    case R.id.take_picture:
                        photoTaker.setCropfinishListener(new PhotoTaker.OnCropFinishListener() {
                            @Override
                            public boolean OnCropFinish(Uri uri) {
                                if (uri != null) {
                                    // String path = CommonUtils.getPathFromUri(ChatActivity.this, uri);
                                    String decodedUri = Uri.decode(uri.toString());
                                    try {
                                        //ImageUtil.displayUserImageWithNoCache(ivUserImage, "file://" + decodedUri, null);
                                        userPhotoBitmap = MediaStore.Images.Media.getBitmap(getContentResolver(), uri);
                                        if (userPhotoBitmap != null)
                                            uploadImageData(userPhotoBitmap);
                                    } catch (IOException e) {
                                        e.printStackTrace();
                                    }
                                }
                                return false;
                            }
                        });
                        photoTaker.doImageCapture();
                        break;

                    case R.id.choose_photo:
                        photoTaker.setCropfinishListener(new PhotoTaker.OnCropFinishListener() {
                            @Override
                            public boolean OnCropFinish(Uri uri) {
                                if (uri != null) {
                                    // String path = CommonUtils.getPathFromUri(ChatActivity.this, uri);
                                    String path = uri.toString();
                                    try {
                                        //ImageUtil.displayUserImageWithNoCache(ivUserImage, path, null);
                                        userPhotoBitmap = MediaStore.Images.Media.getBitmap(getContentResolver(), uri);
                                        if (userPhotoBitmap != null)
                                            uploadImageData(userPhotoBitmap);
                                    } catch (IOException e) {
                                        e.printStackTrace();
                                    }
                                }
                                return false;
                            }
                        });
                        photoTaker.doPickImage();
                        break;

                    case R.id.cancel:
                        popup.dismiss();
                        break;
                }

                return true;
            }
        });

        popup.show(); //showing popup menu
    }

    /**
     * Upload Image Data
     *
     * @throws IOException
     */
    private void uploadImageData(Bitmap bitmap) throws IOException {
        final String identifier = mContact.getIdentifier();
        String filePath = String.format("images/contact/%s.jpg", identifier);
        FirebaseStorage storage = FirebaseStorage.getInstance();
        StorageReference storageRef = storage.getReference();
        StorageReference mountainImagesRef = storageRef.child(filePath);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, 30, baos);
        byte[] data = baos.toByteArray();

        mWaitDialog.show();

        UploadTask uploadTask = mountainImagesRef.putBytes(data);
        uploadTask.addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception exception) {
                // Handle unsuccessful uploads
                mWaitDialog.dismiss();
            }
        }).addOnSuccessListener(new OnSuccessListener<UploadTask.TaskSnapshot>() {
            @Override
            public void onSuccess(UploadTask.TaskSnapshot taskSnapshot) {
                mWaitDialog.dismiss();

                final Uri downloadUrl = taskSnapshot.getDownloadUrl();
                mContact.avatar = downloadUrl.toString();
                ImageUtil.displayPhotoImage(ivUserImage, downloadUrl.toString(), null);
            }
        });
    }

    @Override
    public void onBackPressed() {
        pushTo();

        if (mOrgContact != null && mContact.equals(mOrgContact)) {
            super.onBackPressed();
            return;
        }

        final String[] backMenuArray = getResources().getStringArray(R.array.backMenu);
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(R.string.warning_gift_no_saved_message);
//        builder.setMessage(R.string.warning_gift_no_saved_message);
        builder.setItems(backMenuArray, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                switch (which) {
                    case 0:     // continue
                        dialog.dismiss();
                        break;

                    case 1:     // save
                        dialog.dismiss();
                        isRequestReturn = true;
                        onDone(null);
                        break;

                    case 2:     // discard
                        dialog.dismiss();
                        mContact = null;
                        finish();
                        break;
                }

            }
        });
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (photoTaker != null)
            photoTaker.onActivityResult(requestCode, resultCode, data);

        if (requestCode == REQUEST_SELECT_GIFT) {
            if (resultCode == Activity.RESULT_OK) {
                try {
                    fbGift gift = data.getParcelableExtra("result");
                    if (gift != null) {
                        mSelectedGifts.add(new fbPreloader(gift.getIdentifier()));
                        updateGiftListLayout(true);
                    }
                } catch (Exception e) {}
            } else if (resultCode == Activity.RESULT_CANCELED) {

            }
        }
    }

    /**
     * Update Gift List Layout
     */
    public void updateGiftListLayout(boolean withScroll) {
        layoutGiftList.removeAllViews();

        if (!mSelectedGifts.isEmpty()) {

            View itemView;
            for (final fbPreloader preloader : mSelectedGifts) {
                final fbGift gift = DataManager.getInstance().getGiftById(preloader.getIdentifier());

                if (gift == null)
                    continue;

                itemView = mLayoutInflater.inflate(R.layout.list_item_gift_deletable, null);

                ((TextView) itemView.findViewById(R.id.tvGiftName)).setText(gift.getName());

                ImageView ivGiftImage = (ImageView) itemView.findViewById(R.id.ivGiftImage);

                ArrayList<fbGiftImage> images = gift.images;
                if (images != null && !images.isEmpty())
                    ImageUtil.displayUserImage(ivGiftImage, gift.images.get(0).getUrl(), null);
                else
                    ivGiftImage.setImageResource(R.drawable.ic_gift_item);

                setGiftItemDescription(itemView, gift);

                View layoutDelete = (View) itemView.findViewById(R.id.layoutDelete);
                layoutDelete.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        mSelectedGifts.remove(preloader);
                        updateGiftListLayout(true);
                    }
                });

                itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Intent intent = new Intent(CreateContactActivity.this, CreateGiftActivity.class);
                        intent.putExtra(BaseActivity.PARAM_ORIGINAL, gift);
                        intent.putExtra(PARAM_SELECTED_CONTACT, mContact);
                        startActivity(intent);
                    }
                });

                layoutGiftList.addView(itemView);
            }
        }

        layoutExpGiftsInfo.initLayout();

        if (withScroll) {
            layoutExpGiftsInfo.expand(0, new LinearInterpolator());
            layoutWishList.getParent().requestChildFocus(layoutWishList, layoutWishList);
        }
    }

    private void setGiftItemDescription(View itemView, fbGift gift) {
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

        ((TextView) itemView.findViewById(R.id.tvGiftDescription)).setText(description);
    }
}
