package com.websthewords.giftlog.ui.creation;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.annotation.NonNull;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.LinearInterpolator;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.PopupMenu;
import android.widget.ScrollView;
import android.widget.TextView;

import com.baoyz.swipemenulistview.SwipeMenu;
import com.baoyz.swipemenulistview.SwipeMenuItem;
import com.baoyz.swipemenulistview.SwipeMenuLayout;
import com.baoyz.swipemenulistview.SwipeMenuView;
import com.github.aakira.expandablelayout.ExpandableLinearLayout;
import com.github.aakira.expandablelayout.ExpandableRelativeLayout;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.ValueEventListener;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;
import com.websthewords.giftlog.R;
import com.websthewords.giftlog.data.GLPreference;
import com.websthewords.giftlog.data.manage.DataManager;
import com.websthewords.giftlog.data.manage.ReminderManager;
import com.websthewords.giftlog.data.model.enums.InOutType;
import com.websthewords.giftlog.data.model.firebase.fbContact;
import com.websthewords.giftlog.data.model.firebase.fbContactDate;
import com.websthewords.giftlog.data.model.firebase.fbEvent;
import com.websthewords.giftlog.data.model.firebase.fbGift;
import com.websthewords.giftlog.data.model.firebase.fbPreloader;
import com.websthewords.giftlog.data.model.firebase.fbUser;
import com.websthewords.giftlog.phototaker.PhotoTaker;
import com.websthewords.giftlog.ui.LoginActivity;
import com.websthewords.giftlog.ui.base.BaseActivity;
import com.websthewords.giftlog.utils.ImageUtil;
import com.websthewords.giftlog.utils.StringUtils;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.Date;

import belka.us.androidtoggleswitch.widgets.BaseToggleSwitch;
import belka.us.androidtoggleswitch.widgets.ToggleSwitch;
import butterknife.Bind;
import butterknife.ButterKnife;

/**
 * @description     Create Profile Activity
 *
 * @author          Adrian
 */
public class CreateProfileActivity extends BaseActivity {

    // Variables
    fbUser mUserProfile;                // if edit mode
    fbUser mOrgUserProfile;             // if edit mode

    String mUserId;
    ArrayList<fbContactDate>            mContactDates;

    LayoutInflater mLayoutInflater;
    PhotoTaker photoTaker;

    boolean isRequestReturn = false;

    // UI Controls
    @Bind(R.id.tvContactNameT)          TextView tvContactNameT;
    @Bind(R.id.ivDelete)                ImageView ivDelete;

    @Bind(R.id.etFirstName)             EditText etFirstName;
    @Bind(R.id.etLastName)              EditText etLastName;
    @Bind(R.id.etNickName)              EditText etNickName;
    @Bind(R.id.etEmailAddress)          EditText etEmailAddress;
    @Bind(R.id.etPhoneNumber)           EditText etPhoneNumber;

    @Bind(R.id.etLikes)                 EditText etLikes;
    @Bind(R.id.etDislikes)              EditText etDislikes;

    @Bind(R.id.ivUserImage)             ImageView ivUserImage;

    @Bind(R.id.layoutDateList)          ViewGroup layoutDateList;

    @Bind(R.id.scrollView)              ScrollView scrollView;

    @Bind(R.id.layoutInfo)              View layoutInfo;
    @Bind(R.id.layoutExpInfo)           ExpandableRelativeLayout layoutExpInfo;

    @Bind(R.id.layoutDates)             View layoutDates;
    @Bind(R.id.layoutExpDates)          ExpandableLinearLayout layoutExpDates;

    @Bind(R.id.layoutWishList)          View layoutWishList;
    @Bind(R.id.layoutExpWishList)       ExpandableRelativeLayout layoutExpWishList;

    @Bind(R.id.layoutActions)         View layoutActions;
    @Bind(R.id.layoutExpActions)      ExpandableRelativeLayout layoutExpActions;

    @Bind(R.id.toggleNotification)      ToggleSwitch toggleNotification;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_create_profile);

        ButterKnife.bind(this);

        mLayoutInflater = (LayoutInflater) getSystemService(Context.LAYOUT_INFLATER_SERVICE);

        mUserId = DataManager.getInstance().getCurrentUserID();

        mOrgUserProfile = DataManager.getInstance().getUserProfile();
        if (mOrgUserProfile == null)
            mOrgUserProfile = new fbUser();

        mUserProfile = fbUser.clone(mOrgUserProfile);

        mContactDates = new ArrayList<>();

        photoTaker = new PhotoTaker(this);

        initUI();
        bindUI();
        initExpandableControls();
    }

    private void initUI() {
        etFirstName.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                tvContactNameT.setText(String.format("%s %s", etFirstName.getText().toString(), etLastName.getText().toString()));
                mUserProfile.firstName = etFirstName.getText().toString().trim();
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
                mUserProfile.lastName = etLastName.getText().toString().trim();
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });
    }

    private void bindUI() {
        if (!TextUtils.isEmpty(mUserProfile.getFirstName()) || !TextUtils.isEmpty(mUserProfile.getFirstName()))
            tvContactNameT.setText(mUserProfile.getFirstName() + " " + mUserProfile.getLastName());
        else
            tvContactNameT.setText(R.string.username);

        etFirstName.setText(mUserProfile.getFirstName());
        etLastName.setText(mUserProfile.getLastName());
        etNickName.setText(mUserProfile.getNickName());
        etEmailAddress.setText(mUserProfile.getEmail());
        etPhoneNumber.setText(mUserProfile.getPhoneNumber());
        etLikes.setText(mUserProfile.getLikes());
        etDislikes.setText(mUserProfile.getDislikes());
        ImageUtil.displayPhotoImage(ivUserImage, mUserProfile.getAvatar(), null);

        boolean isUseNotification = GLPreference.isUseNotification();
        toggleNotification.setCheckedTogglePosition(isUseNotification ? 0 : 1);
        toggleNotification.setOnToggleSwitchChangeListener(new BaseToggleSwitch.OnToggleSwitchChangeListener() {
            @Override
            public void onToggleSwitchChangeListener(int position, boolean isChecked) {
                if (position == 0) {
                    GLPreference.setUseNotification(true);
                    ReminderManager.saveLocalNotificationsForEvents();
                }
                else {
                    GLPreference.setUseNotification(false);
                    ReminderManager.removeLocalNotificationsForEvents();
                }
            }
        });
    }

    public void onDone(View v) {
        // Validation
        if (TextUtils.isEmpty(etFirstName.getText().toString())) {
            showWarningDialog(R.string.warning_create_contact_1_text, R.string.warning_create_contact_1);
            return;
        }

        String email = etEmailAddress.getText().toString().trim();
        if (!TextUtils.isEmpty(email) && !StringUtils.isEmailValid(email)) {
            showToast(R.string.wrong_invalid_email);
            return;
        }

        pushTo();

        mWaitDialog.show();
        DataManager.getInstance().getUsersRoot().child(mUserId).setValue(mUserProfile, new DatabaseReference.CompletionListener() {
            @Override
            public void onComplete(DatabaseError databaseError, DatabaseReference databaseReference) {
                mWaitDialog.dismiss();

                mOrgUserProfile = fbUser.clone(mUserProfile);

                if (isRequestReturn)
                    finish();
            }
        });
    }

    private void pushTo() {
        mUserProfile.firstName = etFirstName.getText().toString().trim();
        mUserProfile.lastName = etLastName.getText().toString().trim();
        mUserProfile.nickName = etNickName.getText().toString().trim();
        mUserProfile.email = etEmailAddress.getText().toString().trim();
        mUserProfile.phoneNumber = etPhoneNumber.getText().toString().trim();

        mUserProfile.likes = etLikes.getText().toString().trim();
        mUserProfile.dislikes = etDislikes.getText().toString().trim();
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
                        mContactDates.add(date);

                        updateDateLayout();
                    }
                });
                dialog.show();
                break;

            case R.id.layoutLogout:
                requestLogOut();
                break;

            case R.id.layoutEmailGiftData:
                requestSendEmailGift();
                break;

            case R.id.layoutDeleteProfile:
                deleteProfile();
                break;
        }
    }

    protected void deleteProfile() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(R.string.warning_delete_account);
        builder.setPositiveButton(R.string.delete, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                mWaitDialog.show();
                String uid = DataManager.getInstance().getCurrentUserID();

                DataManager.getInstance().getUsersRoot().child(uid).removeValue();
                FirebaseAuth.getInstance().getCurrentUser().delete().addOnCompleteListener(new OnCompleteListener<Void>() {
                    @Override
                    public void onComplete(@NonNull Task<Void> task) {
                        mWaitDialog.dismiss();
                        startActivity(new Intent(CreateProfileActivity.this, LoginActivity.class));
                        finish();
                    }
                });
            }
        });
        builder.setNegativeButton(android.R.string.cancel, null);
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
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
                                        uploadImageData(uri);
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
                                        uploadImageData(uri);
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

    protected void requestLogOut() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(R.string.logout_confirm);
        builder.setPositiveButton(R.string.logout, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                DataManager.getInstance().signOut();
                startActivity(new Intent(CreateProfileActivity.this, LoginActivity.class));
                finish();
            }
        });
        builder.setNegativeButton(android.R.string.cancel, null);
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
    }

    public void updateDateLayout() {
        layoutDateList.removeAllViews();

        if (mContactDates.size() > 0) {
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
                        updateDateLayout();
                    }
                });

                layoutDateList.addView(itemView);
            }
        }

        layoutExpDates.initLayout();
        layoutExpDates.expand(0, new LinearInterpolator());

        layoutActions.getParent().requestChildFocus(layoutActions, layoutActions);
    }

    /**
     * Upload Image Data
     *
     * @param fileUri
     * @throws IOException
     */
    private void uploadImageData(Uri fileUri) throws IOException {
        Bitmap bitmap = MediaStore.Images.Media.getBitmap(getContentResolver(), fileUri);

        String filePath = String.format("images/user/%s.jpg", DataManager.getInstance().getCurrentUserID());
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
                // taskSnapshot.getMetadata() contains file metadata such as size, content-type, and download URL.
                final Uri downloadUrl = taskSnapshot.getDownloadUrl();

                // save to user data
                if (mUserProfile != null) {
                    mUserProfile.avatar = downloadUrl.toString();
                    DataManager.getInstance().getUsersRoot().child(mUserId).setValue(mUserProfile, new DatabaseReference.CompletionListener() {
                        @Override
                        public void onComplete(DatabaseError databaseError, DatabaseReference databaseReference) {
                            mWaitDialog.dismiss();
                            ImageUtil.displayPhotoImage(ivUserImage, downloadUrl.toString(), null);
                        }
                    });
                } else {
                    mWaitDialog.dismiss();
                }
            }
        });
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

        layoutActions.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                layoutExpActions.toggle();

                if (!layoutExpActions.isExpanded()) {
                    ((ImageView) findViewById(R.id.ivActionArrowIcon)).setImageResource(R.drawable.ic_arrow_up);

                    final int scrollY = (int)scrollView.getX() + scrollView.getHeight();
                    scrollView.postDelayed(new Runnable() {
                        public void run() {
                            scrollView.smoothScrollTo(0, scrollY);
                        }
                    }, 250);
                }
                else
                    ((ImageView)findViewById(R.id.ivActionArrowIcon)).setImageResource(R.drawable.ic_arrow_down);
            }
        });

        layoutWishList.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                layoutExpWishList.toggle();

                if (!layoutExpWishList.isExpanded())
                    ((ImageView)findViewById(R.id.ivWishListArrowIcon)).setImageResource(R.drawable.ic_arrow_up);
                else
                    ((ImageView)findViewById(R.id.ivWishListArrowIcon)).setImageResource(R.drawable.ic_arrow_down);
            }
        });
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (photoTaker != null)
            photoTaker.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onBackPressed() {
        pushTo();

        if (mUserProfile.equals(mOrgUserProfile)) {
            // No changed
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
                        finish();
                        break;
                }

            }
        });
        AlertDialog alertDialog = builder.create();
        alertDialog.show();
    }

    String[]                            giftTypesArray;
    String[]                            giftStatusArray;

    /**
     * Send Gift via Email
     */
    private void requestSendEmailGift() {
        ArrayList<fbGift> allGifts = DataManager.getInstance().getAllGifts();

        giftTypesArray = getResources().getStringArray(R.array.giftTypes);
        giftStatusArray = getResources().getStringArray(R.array.giftStatus);

        String csvText = "Name,In/Out,Gift type,Description,Value,Reciept type,Status,Event,Contacts\n";
        String inOutString, typeString, receiptString, statusString, eventTitle, eventStarts, eventEnds;
        String contactsString = "";
        for (fbGift gift : allGifts) {

            if (gift.getInOutType() == InOutType.RECEIVED)
                inOutString = "Received";
            else
                inOutString = "Given";

            if (gift.getType() > 0)
                typeString = giftTypesArray[gift.getType()];
            else
                typeString = "-";

            if (gift.getStatus() > 0)
                statusString = giftStatusArray[gift.getStatus()];
            else
                statusString = "-";

            if (gift.getRecieptType() == 0)
                receiptString = "No";
            else
                receiptString = "Yes";

            eventTitle = "-";
            eventStarts = "-";
            eventEnds = "-";

            if (gift.getEventPreloader() != null) {
                fbEvent event = DataManager.getInstance().getEventById(gift.getEventPreloader().getIdentifier());
                eventTitle = event.getEventTitle();
                eventStarts = StringUtils.getDateFromMiliseconds(event.getDateStart());
                eventEnds = StringUtils.getDateFromMiliseconds(event.getDateEnd());
            }

            csvText += String.format("%s,%s,%s,%s,%s,%s,%s,",
                    gift.getName(), inOutString, typeString, gift.getDescription(), gift.price,
                    receiptString, statusString);

            // add event text
            csvText += String.format("Name: %s Starts: %s Ends: %s,", eventTitle, eventStarts, eventEnds);

            // add contacts
            if (gift.getContacts() != null && gift.getContacts().size() > 0) {
                contactsString = "";
                for (fbPreloader preloader : gift.getContacts()) {
                    fbContact contact = DataManager.getInstance().getContactById(preloader.getIdentifier());
                    contactsString += String.format("Name: %s Number: %s; ", contact.getFullName(), contact.getPhoneNumber());
                }
            }
            else {
                contactsString = "-";
            }

            csvText += String.format("%s\n", contactsString);
        }

        // Now ready to send email
        String fileName = "giftLogFile.csv";

        File csvFile = new File(Environment.getExternalStorageDirectory()  + "/" + fileName);

        try {
            FileOutputStream fos = new FileOutputStream (csvFile);
            OutputStreamWriter outputStream  = new OutputStreamWriter(fos);
            outputStream.write(csvText);
            outputStream.close();
        } catch (Exception e) {
            e.printStackTrace();
        }

        sendViaEmail(csvFile);
    }

    private void sendViaEmail(File file) {
        try {
            Intent intent = new Intent(Intent.ACTION_SEND);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.setType("vnd.android.cursor.item/email");
            intent.putExtra(Intent.EXTRA_EMAIL, new String[] {"email@example.com"});
            Uri fileUri = Uri.fromFile(file);
            intent.putExtra(android.content.Intent.EXTRA_STREAM, Uri.parse("file://" + fileUri));
            intent.putExtra(Intent.EXTRA_SUBJECT, "");
            intent.putExtra(Intent.EXTRA_TEXT, "CSV File from GiftLog App");
            startActivity(intent);
        } catch(Exception e)  {
            System.out.println("is exception raises during sending mail"+e);
        }
    }

}