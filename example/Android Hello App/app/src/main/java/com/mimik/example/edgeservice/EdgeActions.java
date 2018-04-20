package com.mimik.example.edgeservice;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;

/**
 * Wrapper for edge JsonRPC and edge Android service actions
 */

public class EdgeActions {

    public static final String TAG = "EdgeActions";

    // Intent extra fields to put results
    public static final String INTENT_EXTRA_ASSOCIATED = "INTENT_EXTRA_ASSOCIATED";
    public static final String INTENT_EXTRA_UNASSOCIATED = "INTENT_EXTRA_UNASSOCIATED";
    public static final String INTENT_EXTRA_GETME = "INTENT_EXTRA_GETME";
    public static final String INTENT_EXTRA_GETEDGEIDTOKEN = "INTENT_EXTRA_GETEDGEIDTOKEN";

    private static EdgeServiceModule mEdgeService = null;

    // Associate the running edge service to an account
    public static void associate(String edgeAccessToken, Context context, String callbackIntentAction, ComponentName callbackComponentName) {
        Intent callbackIntent = new Intent();
        callbackIntent.setAction(callbackIntentAction);
        callbackIntent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
        callbackIntent.setComponent(callbackComponentName);
        new EdgeAccountProvider().associate(edgeAccessToken, context, callbackIntent);
    }

    // Unassociate the running edge service from an account
    public static void unassociate(String edgeAccessToken, Context context, String callbackIntentAction, ComponentName callbackComponentName) {
        Intent callbackIntent = new Intent();
        callbackIntent.setAction(callbackIntentAction);
        callbackIntent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
        callbackIntent.setComponent(callbackComponentName);
        new EdgeAccountProvider().unassociate(edgeAccessToken, context, callbackIntent);
    }

    // Get edge ID token for use with OAuth
    public static void getEdgeIdToken(Context context, String callbackIntentAction, ComponentName callbackComponentName) {
        Intent callbackIntent = new Intent();
        callbackIntent.setAction(callbackIntentAction);
        callbackIntent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
        callbackIntent.setComponent(callbackComponentName);
        new EdgeAccountProvider().getEdgeIdToken(context, callbackIntent);
    }

    // Start the edge service
    public static EdgeServiceModule startEdge(Context context) {
        if (mEdgeService == null) {
            // initialize the mimik edge service with example parameters
            Map<String, String> options = new HashMap<>();
            options.put("port", "" + 8083);
            options.put("capability", "" + 3);
            options.put("nodeName", "testNode");
            //options.put("license", mEdgeLicense);

            mEdgeService = new EdgeServiceModule(
                    context,
                    "",
                    options);
            mEdgeService.start();
        }
        return mEdgeService;
    }

    // Stop the edge service
    public static void stopEdge() {
        Log.d(TAG, "stopEdge");
        if (mEdgeService != null) {
            mEdgeService.stop();
            mEdgeService = null;
        }
    }
}
