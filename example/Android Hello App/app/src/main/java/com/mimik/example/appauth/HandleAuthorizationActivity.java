package com.mimik.example.appauth;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

/**
 * Activity to handle AppAuth callback intents
 */

public class HandleAuthorizationActivity extends Activity {
    @Override
    public void onCreate(Bundle savedInstanceBundle) {
        super.onCreate(savedInstanceBundle);
        Intent intent = getIntent();

        if (intent.getAction().equals(AppAuthorization.INTENT_POSTAUTHORIZATION_EDGE)) {
            AppAuthorization.handleEdgeAuthorizationResponse(intent, getApplicationContext());
        } else if (intent.getAction().equals(AppAuthorization.INTENT_POSTAUTHORIZATION_UNASSOCIATE)) {
            AppAuthorization.handleUnassociateTokenResponse(intent, getApplicationContext());
        }
        finish();
    }
}
