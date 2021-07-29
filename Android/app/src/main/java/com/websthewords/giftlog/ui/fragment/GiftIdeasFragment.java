package com.websthewords.giftlog.ui.fragment;

import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.websthewords.giftlog.R;

import butterknife.Bind;

/**
 * @description     Gift Ideas Fragment
  *
 * @author          Adrian
 */
public class GiftIdeasFragment extends BaseFragment {
    private final static String TAG = GiftIdeasFragment.class.getSimpleName();

    private final static String mUrl = "https://www.giftlog.co.uk/giftideas/";

    // UI Members
    @Bind(R.id.webView) WebView webView;

    // Variables

    @Override
    protected int getLayoutId() {
        return R.layout.fragment_gift_ideas;
    }

    @Override
    protected void initViews() {
        mWaitDialog.show();

        webView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                mWaitDialog.dismiss();
            }
        });

        webView.getSettings().setJavaScriptEnabled(true); // enable javascript
        webView.loadUrl(mUrl);
    }
}