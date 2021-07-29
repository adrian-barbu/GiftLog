package com.websthewords.giftlog.ui.creation;

import android.app.Dialog;
import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.view.Window;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.websthewords.giftlog.R;

/**
 * @description     Date Selection Dialog
 *
 * @author          Adrian
 */
public class DateSelectionDialog extends Dialog {

    // UI Controls
    TextView tvDone, tvCancel;
    EditText etTitle;
    DatePicker datePicker;

    // Variables
    public interface OnDateSelectedListener {
        void onDateSelected(String title, int year, int month, int day);
    }

    OnDateSelectedListener mOnDateSelectedListener;

    public DateSelectionDialog(Context context, OnDateSelectedListener listener) {
        super(context);

        requestWindowFeature(Window.FEATURE_NO_TITLE); //before

        this.setContentView(R.layout.dialog_date_pick);

        mOnDateSelectedListener = listener;

        initUI();
    }

    private void initUI() {
        tvDone = (TextView) findViewById(R.id.tvDone);
        tvDone.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String title = etTitle.getText().toString();
                if (TextUtils.isEmpty(title)) {
                    Toast.makeText(getContext(), R.string.warning_no_date_title, Toast.LENGTH_SHORT).show();
                    return;
                }

                int day = datePicker.getDayOfMonth();
                int month = datePicker.getMonth() + 1;
                int year = datePicker.getYear();

                if (mOnDateSelectedListener != null)
                    mOnDateSelectedListener.onDateSelected(title, year, month, day);

                dismiss();
            }
        });

        tvCancel = (TextView) findViewById(R.id.tvCancel);
        tvCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
            }
        });

        etTitle = (EditText) findViewById(R.id.etTitle);
        datePicker = (DatePicker) findViewById(R.id.datePicker);
    }
}
