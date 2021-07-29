package com.websthewords.giftlog.controls;

import android.app.Dialog;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.view.Window;
import android.widget.ProgressBar;

/**
 * waiting popup window
 */
public class WaitDialog extends Dialog {

	public WaitDialog(Context context) {
		super(context);
		initUI(context);
	}

	private void initUI(Context context) {
		this.requestWindowFeature(Window.FEATURE_NO_TITLE);
		this.getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
		ProgressBar progress = new ProgressBar(context);
		this.setContentView(progress);
	}

	@Override
	public void show() {
		try {
			setCancelable(false);
			setCanceledOnTouchOutside(false);

			super.show();
		} catch(Exception e) {
		}
	}

	@Override
	public void dismiss() {
		try {
			super.dismiss();
		} catch(Exception e) {
		}
	}

	@Override
	public void cancel() {
		try {
			super.cancel();
		} catch(Exception e) {
		}
	}

}
