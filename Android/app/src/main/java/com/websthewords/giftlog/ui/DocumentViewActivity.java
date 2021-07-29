package com.websthewords.giftlog.ui;

import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.TextView;

import com.websthewords.giftlog.R;
import com.websthewords.giftlog.ui.base.BaseActivity;

/**
 * @description     WebView Based Activity
 *
 * @author          Adrian
 */
public class DocumentViewActivity extends BaseActivity {
    public final String TAG = DocumentViewActivity.class.getName();

    public final static String PARAM_WHAT = "what";

    public final static int PAGE_FAQ = 0;
    public final static int PAGE_POLICY = 1;
    public final static int PAGE_TERMS = 2;
    public final static int PAGE_CONTACTUS = 3;

    // UI Members
    WebView webView;

    // Variables

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_document_view);

        String url = "", title = "";

        int what = getIntent().getIntExtra(PARAM_WHAT, 0);
        switch (what) {
            case 0:
                url = "https://www.giftlog.co.uk/faq/";
                title = getResources().getString(R.string.sm_faq);
                break;

            case 1:
                url = "https://www.giftlog.co.uk/privacy/";
                title = getResources().getString(R.string.sm_privacy_policy);
                break;

            case 2:
                url = "https://www.giftlog.co.uk/terms/";
                title = getResources().getString(R.string.sm_terms_conditions);
                break;

            case 3:
                url = "https://www.giftlog.co.uk/contact/";
                title = getResources().getString(R.string.sm_contact_us);
                break;
        }

        mWaitDialog.show();

        webView = (WebView) findViewById(R.id.webView);
        webView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                mWaitDialog.dismiss();
            }
        });

        webView.getSettings().setJavaScriptEnabled(true);
        webView.getSettings().setJavaScriptCanOpenWindowsAutomatically(true);
        webView.getSettings().setDatabaseEnabled(true);
        webView.getSettings().setDomStorageEnabled(true);
        webView.getSettings().setAllowFileAccess(true);

        webView.loadUrl(url);

        ((TextView)findViewById(R.id.tvTitle)).setText(title);
    }

}