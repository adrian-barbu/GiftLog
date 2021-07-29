package com.websthewords.giftlog.ui;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.EditText;

import com.facebook.AccessToken;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.google.android.gms.auth.api.Auth;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.auth.api.signin.GoogleSignInResult;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FacebookAuthProvider;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.GoogleAuthProvider;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.websthewords.giftlog.R;
import com.websthewords.giftlog.data.manage.DataManager;
import com.websthewords.giftlog.data.model.firebase.fbUser;
import com.websthewords.giftlog.ui.base.BaseActivity;
import com.websthewords.giftlog.utils.StringUtils;

import org.json.JSONObject;

import java.util.Arrays;

/**
 * @description     Register Activity
 *
 * @author          Adrian
 */
public class RegisterActivity extends BaseActivity implements GoogleApiClient.OnConnectionFailedListener {

    public final String TAG = RegisterActivity.class.getName();
    public final int RC_SIGN_IN = 1000;

    // UI Members
    EditText etEmail, etPassword, etConfirmPassword;

    // Variables
    FirebaseAuth mAuth;
    CallbackManager mCallbackManager;
    GoogleApiClient mGoogleApiClient;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register);

        etEmail = (EditText) findViewById(R.id.etEmail);
        etPassword = (EditText) findViewById(R.id.etPassword);
        etConfirmPassword = (EditText) findViewById(R.id.etConfirmPassword);

        mAuth = FirebaseAuth.getInstance();

        mCallbackManager = CallbackManager.Factory.create();
        LoginManager.getInstance().registerCallback(mCallbackManager,
                new FacebookCallback<LoginResult>() {
                    @Override
                    public void onSuccess(LoginResult loginResult) {
                        Log.d("Success", "Login");
                        AccessToken token = loginResult.getAccessToken();
                        handleFacebookAccessToken(token);
                    }

                    @Override
                    public void onCancel() {
                        showToast("Login Cancel");
                    }

                    @Override
                    public void onError(FacebookException exception) {
                        showToast(exception.getMessage());
                    }
                });
        initializeGoogleService();
    }

    private void initializeGoogleService() {
        GoogleSignInOptions gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                .requestIdToken("166939248803-931ksv0g9pen2sm7qee6p5ct24i617eq.apps.googleusercontent.com")
                .requestEmail()
                .build();

        mGoogleApiClient = new GoogleApiClient.Builder(this)
                .enableAutoManage(this /* FragmentActivity */, this /* OnConnectionFailedListener */)
                .addApi(Auth.GOOGLE_SIGN_IN_API, gso)
                .build();

    }

    /**
     * Back Event Handler
     *
     * @param v
     */
    public void onBack(View v) {
        startActivity(new Intent(this, LoginActivity.class));
        finish();
    }

    /**
     * Register Event Handler
     *
     * @param v
     */
    public void onRegister(View v) {
        // Validate if all information was inputed

        final String email = etEmail.getText().toString();
        if (TextUtils.isEmpty(email)) {
            showToast(R.string.warning_all_field_required);
            return;
        } else if (!StringUtils.isEmailValid(email)) {
            showToast(R.string.wrong_invalid_email);
            return;
        }

        String password = etPassword.getText().toString();
        if (TextUtils.isEmpty(password)) {
            showToast(R.string.warning_all_field_required);
            return;
        }
        else if (password.length() < 6) {
            showToast(R.string.warning_weak_password);
            return;
        }

        String confirmPassword = etConfirmPassword.getText().toString();
        if (TextUtils.isEmpty(confirmPassword)) {
            showToast(R.string.warning_all_field_required);
            return;
        }
        else if (!confirmPassword.equals(password)) {
            showToast(R.string.wrong_password);
            return;
        }

        mWaitDialog.show();

        // Now, let register
        mAuth.createUserWithEmailAndPassword(email, password)
                .addOnCompleteListener(this, new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull Task<AuthResult> task) {
                        mWaitDialog.dismiss();

                        if (task.isSuccessful()) {
                            // Sign in success, update UI with the signed-in user's information
                            Log.d(TAG, "createUserWithEmail:success");
                            goMainActivity(null, null);
                        } else {
                            // If sign in fails, display a message to the user.
                            Log.w(TAG, "createUserWithEmail:failure", task.getException());
                            showToast(task.getException().getMessage());
                        }
                    }
                });
    }

    /**
     * Google Login Event Handler
     *
     * @param v
     */
    public void onGoogleLogin(View v) {
        Intent signInIntent = Auth.GoogleSignInApi.getSignInIntent(mGoogleApiClient);
        startActivityForResult(signInIntent, RC_SIGN_IN);

    }

    /**
     * Facebook Login Event Handler
     *
     * @param v
     */
    public void onFacebookLogin(View v) {
        LoginManager.getInstance().logInWithReadPermissions(this, Arrays.asList("public_profile", "email", "user_birthday", "user_friends"));
    }

    private void handleFacebookAccessToken(final AccessToken token) {
        Log.d(TAG, "handleFacebookAccessToken:" + token);

        final AuthCredential credential = FacebookAuthProvider.getCredential(token.getToken());
        mAuth.signInWithCredential(credential)
                .addOnCompleteListener(this, new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull Task<AuthResult> task) {
                        if (task.isSuccessful()) {
                            // Sign in success, update UI with the signed-in user's information
                            Log.d(TAG, "signInWithCredential:success");
                            mWaitDialog.show();
                            getFBUserProfile(token);
                        } else {
                            // If sign in fails, display a message to the user.
                            Log.w(TAG, "signInWithCredential:failure", task.getException());
                            showToast(task.getException().getMessage());
                        }
                    }
                });
    }

    private void getFBUserProfile(AccessToken token) {
        GraphRequest request = GraphRequest.newMeRequest(
                token,
                new GraphRequest.GraphJSONObjectCallback() {
                    @Override
                    public void onCompleted(JSONObject object, GraphResponse response) {
                        // goMainActivity
                        goMainActivity(object, null);
                    }

                });
        Bundle parameters = new Bundle();
        parameters.putString("fields", "id,email,first_name,last_name,gender");
        request.setParameters(parameters);
        request.executeAsync();
    }

    private void firebaseAuthWithGoogle(final GoogleSignInAccount acct) {
        Log.d(TAG, "firebaseAuthWithGoogle:" + acct.getId());

        AuthCredential credential = GoogleAuthProvider.getCredential(acct.getIdToken(), null);
        mAuth.signInWithCredential(credential)
                .addOnCompleteListener(this, new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull Task<AuthResult> task) {
                        if (task.isSuccessful()) {
                            // Sign in success, update UI with the signed-in user's information
                            Log.d(TAG, "signInWithCredential:success");
                            goMainActivity(null, acct);
                        } else {
                            // If sign in fails, display a message to the user.
                            Log.w(TAG, "signInWithCredential:failure", task.getException());
                            showToast(task.getException().getMessage());
                        }

                        // ...
                    }
                });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        // Result returned from launching the Intent from GoogleSignInApi.getSignInIntent(...);
        if (requestCode == RC_SIGN_IN) {
            GoogleSignInResult result = Auth.GoogleSignInApi.getSignInResultFromIntent(data);
            if (result.isSuccess()) {
                // Google Sign In was successful, authenticate with Firebase
                GoogleSignInAccount account = result.getSignInAccount();
                firebaseAuthWithGoogle(account);
            } else {
                // Google Sign In failed, update UI appropriately
                // ...
            }

            return;
        }

        if(mCallbackManager.onActivityResult(requestCode, resultCode, data)) {
            return;
        }
    }

    private void goMainActivity(JSONObject jsonObjectFromFB, GoogleSignInAccount gmailAccount) {
        DataManager.getInstance().initialize();

        // Register new user profile
        FirebaseUser user = DataManager.getInstance().getCurrentUser();

        String userId = user.getUid();
        fbUser thisUser = new fbUser();
        thisUser.email = user.getEmail();

        if (jsonObjectFromFB != null)   // From Facebook
        {
            String facebookId = "", firstName = "", lastName = "";
            try {
                facebookId = jsonObjectFromFB.getString("id").toString();
                firstName = jsonObjectFromFB.getString("first_name").toString();
                lastName = jsonObjectFromFB.getString("last_name").toString();
            } catch (Exception e) {
                e.printStackTrace();
            }

            thisUser.firstName = firstName;
            thisUser.lastName = lastName;
            thisUser.facebookId = facebookId;
            thisUser.avatar = user.getPhotoUrl().toString();
        }

        if (gmailAccount != null)       // From GPlus
        {
            thisUser.firstName = gmailAccount.getGivenName();
            thisUser.lastName = gmailAccount.getFamilyName();
            thisUser.avatar = gmailAccount.getPhotoUrl().toString();
            thisUser.gplusId = gmailAccount.getId();
        }

        mWaitDialog.show();
        DataManager.getInstance().getUsersRoot().child(userId).setValue(thisUser, new DatabaseReference.CompletionListener() {
            @Override
            public void onComplete(DatabaseError databaseError, DatabaseReference databaseReference) {
                mWaitDialog.dismiss();

                startActivity(new Intent(RegisterActivity.this, MainActivity.class));
                finish();
            }
        });
    }

    @Override
    public void onConnectionFailed(@NonNull ConnectionResult connectionResult) {

    }
}
