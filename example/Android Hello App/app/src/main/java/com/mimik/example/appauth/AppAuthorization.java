package com.mimik.example.appauth;

import android.app.PendingIntent;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.support.annotation.Nullable;
import android.util.Log;

import com.mimik.example.BuildConfig;

import net.openid.appauth.AuthState;
import net.openid.appauth.AuthorizationException;
import net.openid.appauth.AuthorizationRequest;
import net.openid.appauth.AuthorizationResponse;
import net.openid.appauth.AuthorizationService;
import net.openid.appauth.AuthorizationServiceConfiguration;
import net.openid.appauth.TokenRequest;
import net.openid.appauth.TokenResponse;

import java.util.HashMap;
import java.util.Map;

/**
 * Wrapper around AppAuth for simple mimik login
 */

public class AppAuthorization {
    public static final String TAG = "AppAuthorization";

    // Constants for setting up callbacks
    public static final String INTENT_POSTACTION = "INTENT_POSTACTION";
    public static final String INTENT_POSTACTIONCLASS = "INTENT_POSTACTIONCLASS";
    public static final String INTENT_USERTOKEN = "userToken";
    public static final String INTENT_EDGETOKEN = "edgeToken";
    public static final String INTENT_UNASSOCIATETOKEN = "unassociateToken";

    // Redirect URI and client ID registered with mimik developer portal
    public static final String REDIRECT_URI = "com.mimik.example.appauth://oauth2callback";
    public static final String CLIENT_ID = "5471af66-e7eb-4104-befc-d4c1e2ca5508";

    // Token scopes requested
    public static final String LOGIN_SCOPE = "openid edge:mcm edge:clusters edge:account:associate";
    public static final String UNASSOCIATE_SCOPE = "openid edge:account:unassociate";

    // OAuth endpoints
    public static final String TOKEN_ENDPOINT = BuildConfig.MID_URL + "/token";
    public static final String AUTH_ENDPOINT = BuildConfig.MID_URL + "/auth";

    // Extra parameters
    public static final String AUDIENCE = "generic-edge";
    public static final String GRANT_TYPE = "exchange_edge_token";
    public static final String EDGE_ID_TOKEN = "edge_id_token";

    // Intents used for AppAuth callbacks
    public static final String INTENT_POSTAUTHORIZATION_EDGE = "com.mimik.example.appauth.HANDLE_AUTHORIZATION_RESPONSE_EDGE";
    public static final String INTENT_POSTAUTHORIZATION_UNASSOCIATE = "com.mimik.example.appauth.HANDLE_AUTHORIZATION_RESPONSE_UNASSOCIATE";

    private static AuthorizationService mAuthService;
    private static String mEdgeToken;
    private static String mUserToken;

    private static Context mParentContext;

    private static String mEdgeIdToken = "";

    // Login method
    // postIntent and postIntentClass are used for callback
    // edgeIdtoken can be acquired from EdgeActions, used for activity monitoring
    public static void login(final String postIntent, final Class postIntentClass, String edgeIdToken, final Context context) {
        mParentContext = context;

        AuthorizationService authService = getAuthorizationService(context);

        AuthorizationServiceConfiguration serviceConfiguration = new AuthorizationServiceConfiguration(
                Uri.parse(AUTH_ENDPOINT) /* auth endpoint */,
                Uri.parse(TOKEN_ENDPOINT) /* token endpoint */
        );

        String clientId = CLIENT_ID;
        Uri redirectUri = Uri.parse(REDIRECT_URI);
        String responseType = "code";
        AuthorizationRequest.Builder requestBuilder = new AuthorizationRequest.Builder(
                serviceConfiguration,
                clientId,
                responseType,
                redirectUri
        );
        Map<String, String> edgeIdTokenMap = new HashMap<>();
        edgeIdTokenMap.put(EDGE_ID_TOKEN, edgeIdToken);
        requestBuilder.setAdditionalParameters(edgeIdTokenMap);
        requestBuilder.setScopes(LOGIN_SCOPE);

        Map<String, String> additionalParams = new HashMap<>();
        additionalParams.put("audience", AUDIENCE);
        additionalParams.put("edge_id_token", getEdgeIdToken());
        requestBuilder.setAdditionalParameters(additionalParams);

        AuthorizationRequest request = requestBuilder.build();

        Log.d(TAG, "AuthorizationRequest = " + request.jsonSerializeString());

        Intent postAuthorizationIntent = new Intent(context, HandleAuthorizationActivity.class);
        postAuthorizationIntent.setAction(INTENT_POSTAUTHORIZATION_EDGE);
        postAuthorizationIntent.putExtra(INTENT_POSTACTION, postIntent);
        postAuthorizationIntent.putExtra(INTENT_POSTACTIONCLASS, postIntentClass.getCanonicalName());
        PendingIntent pendingIntent = PendingIntent.getActivity(context, request.hashCode(), postAuthorizationIntent, 0);
        authService.performAuthorizationRequest(request, pendingIntent);
    }

    // Acquire unassociation token for use with EdgeActions
    // postIntent and postIntentClass are used for callback
    // edgeIdtoken can be acquired from EdgeAcctions, used for activity monitoring
    public static void getUnassociationToken(final String postIntent, final Class postIntentClass, String edgeIdToken, final Context context) {
        mParentContext = context;

        AuthorizationService authService = getAuthorizationService(context);

        AuthorizationServiceConfiguration serviceConfiguration = new AuthorizationServiceConfiguration(
                Uri.parse(AUTH_ENDPOINT) /* auth endpoint */,
                Uri.parse(TOKEN_ENDPOINT) /* token endpoint */
        );

        String clientId = CLIENT_ID;
        Uri redirectUri = Uri.parse(REDIRECT_URI);
        String responseType = "code";
        AuthorizationRequest.Builder requestBuilder = new AuthorizationRequest.Builder(
                serviceConfiguration,
                clientId,
                responseType,
                redirectUri
        );
        Map<String, String> edgeIdTokenMap = new HashMap<>();
        edgeIdTokenMap.put(EDGE_ID_TOKEN, edgeIdToken);
        requestBuilder.setAdditionalParameters(edgeIdTokenMap);
        requestBuilder.setScopes(UNASSOCIATE_SCOPE);

        Map<String, String> additionalParams = new HashMap<>();
        additionalParams.put("audience", AUDIENCE);
        additionalParams.put("edge_id_token", getEdgeIdToken());
        requestBuilder.setAdditionalParameters(additionalParams);

        AuthorizationRequest request = requestBuilder.build();

        Intent postAuthorizationIntent = new Intent(context, HandleAuthorizationActivity.class);
        postAuthorizationIntent.setAction(INTENT_POSTAUTHORIZATION_UNASSOCIATE);
        postAuthorizationIntent.putExtra(INTENT_POSTACTION, postIntent);
        postAuthorizationIntent.putExtra(INTENT_POSTACTIONCLASS, postIntentClass.getCanonicalName());
        PendingIntent pendingIntent = PendingIntent.getActivity(context, request.hashCode(), postAuthorizationIntent, 0);
        authService.performAuthorizationRequest(request, pendingIntent);
    }

    // Parse the response for edge token request, and send callback or continue with fetching user token
    public static void handleEdgeAuthorizationResponse(final Intent intent, final Context context) {
        AuthorizationResponse response = AuthorizationResponse.fromIntent(intent);
        AuthorizationException error = AuthorizationException.fromIntent(intent);
        final AuthState authState;
        try {
            authState = new AuthState(response, error);
        } catch (IllegalArgumentException ex) {
            ex.printStackTrace();
            return;
        }
        if (response != null) {
            TokenRequest tr = response.createTokenExchangeRequest();
            AuthorizationService authService = getAuthorizationService(context);
            authService.performTokenRequest(tr, new AuthorizationService.TokenResponseCallback() {
                @Override
                public void onTokenRequestCompleted(@Nullable final TokenResponse response, @Nullable final AuthorizationException ex) {
                    if (ex != null) {
                        String action = intent.getStringExtra(INTENT_POSTACTION);
                        Map<String, String> extras = new HashMap<>();
                        extras.put(INTENT_EDGETOKEN, "");
                        extras.put(INTENT_USERTOKEN, "");
                        ComponentName cn = new ComponentName(context, intent.getStringExtra(INTENT_POSTACTIONCLASS));
                        Intent retIntent = buildCallbackIntent(action, extras, cn);
                        mParentContext.startActivity(retIntent);
                    } else {
                        if (response != null) {
                            authState.update(response, ex);
                            mEdgeToken = authState.getAccessToken();
                            getUserToken(mEdgeToken, authState, intent, context);
                        }
                    }
                }
            });
        } else {
            Log.d(TAG, "Authorization error " + error.toJsonString());
        }
    }

    // Parse the response for user token request, and send callback
    public static void getUserToken(final String edgeAccessToken, final AuthState authState, final Intent intent, final Context context) {
        AuthorizationServiceConfiguration serviceConfiguration = new AuthorizationServiceConfiguration(
                Uri.parse(AUTH_ENDPOINT) /* auth endpoint */,
                Uri.parse(TOKEN_ENDPOINT) /* token endpoint */
        );
        TokenRequest.Builder builder = new TokenRequest.Builder(serviceConfiguration, CLIENT_ID);
        builder.setGrantType(GRANT_TYPE);
        Map<String, String> additionalParams = new HashMap<>();
        additionalParams.put("token", edgeAccessToken);
        additionalParams.put("edge_id_token", getEdgeIdToken());
        builder.setAdditionalParameters(additionalParams);
        TokenRequest tr = builder.build();
        AuthorizationService authService = getAuthorizationService(context);
        authService.performTokenRequest(tr, new AuthorizationService.TokenResponseCallback() {
            @Override
            public void onTokenRequestCompleted(@Nullable final TokenResponse response, @Nullable final AuthorizationException ex) {
                if (ex != null) {
                    String action = intent.getStringExtra(INTENT_POSTACTION);
                    Map<String, String> extras = new HashMap<>();
                    extras.put(INTENT_EDGETOKEN, "");
                    extras.put(INTENT_USERTOKEN, "");
                    ComponentName cn = new ComponentName(context, intent.getStringExtra(INTENT_POSTACTIONCLASS));
                    Intent retIntent = buildCallbackIntent(action, extras, cn);
                    mParentContext.startActivity(retIntent);
                } else {
                    if (response != null) {
                        authState.update(response, ex);
                        mUserToken = authState.getAccessToken();
                        String action = intent.getStringExtra(INTENT_POSTACTION);
                        Map<String, String> extras = new HashMap<>();
                        extras.put(INTENT_USERTOKEN, mUserToken);
                        extras.put(INTENT_EDGETOKEN, mEdgeToken);
                        ComponentName cn = new ComponentName(context, intent.getStringExtra(INTENT_POSTACTIONCLASS));
                        Intent retIntent = buildCallbackIntent(action, extras, cn);
                        mParentContext.startActivity(retIntent);
                    }
                }
            }
        });
    }

    // Parse the response for unassociation token request, and send callback
    public static void handleUnassociateTokenResponse(final Intent intent, final Context context) {
        AuthorizationResponse response = AuthorizationResponse.fromIntent(intent);
        AuthorizationException error = AuthorizationException.fromIntent(intent);
        final AuthState authState;
        try {
            authState = new AuthState(response, error);
        } catch (IllegalArgumentException ex) {
            ex.printStackTrace();
            return;
        }
        if (response != null) {
            TokenRequest tr = response.createTokenExchangeRequest();
            AuthorizationService authService = getAuthorizationService(context);
            authService.performTokenRequest(tr, new AuthorizationService.TokenResponseCallback() {
                @Override
                public void onTokenRequestCompleted(@Nullable final TokenResponse response, @Nullable final AuthorizationException ex) {
                    if (ex != null) {
                        String action = intent.getStringExtra(INTENT_POSTACTION);
                        Map<String, String> extras = new HashMap<>();
                        extras.put(INTENT_UNASSOCIATETOKEN, "");
                        ComponentName cn = new ComponentName(context, intent.getStringExtra(INTENT_POSTACTIONCLASS));
                        Intent retIntent = buildCallbackIntent(action, extras, cn);
                        mParentContext.startActivity(retIntent);
                    } else {
                        if (response != null) {
                            authState.update(response, ex);
                            String unassociateToken = authState.getAccessToken();
                            String action = intent.getStringExtra(INTENT_POSTACTION);
                            Map<String, String> extras = new HashMap<>();
                            extras.put(INTENT_UNASSOCIATETOKEN, unassociateToken);
                            ComponentName cn = new ComponentName(context, intent.getStringExtra(INTENT_POSTACTIONCLASS));
                            Intent retIntent = buildCallbackIntent(action, extras, cn);
                            mParentContext.startActivity(retIntent);
                        }
                    }
                }
            });
        } else {
            Log.d(TAG, "Authorization error " + error.toJsonString());
        }
    }

    // Utility function to build callback intent
    private static Intent buildCallbackIntent(
            String action,
            Map<String, String> extras,
            ComponentName component) {
        Intent retIntent = new Intent();
        retIntent.setAction(action);
        retIntent.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
        for (Map.Entry<String, String> entry : extras.entrySet()) {
            retIntent.putExtra(entry.getKey(), entry.getValue());
        }
        retIntent.setComponent(component);
        return retIntent;
    }

    private static AuthorizationService getAuthorizationService(Context context) {
        if (mAuthService == null) {
            mAuthService = new AuthorizationService(context);
        }
        return mAuthService;
    }

    public static String getEdgeIdToken() {
        return mEdgeIdToken;
    }

    public static void setEdgeIdToken(String edgeIdToken) {
        mEdgeIdToken = edgeIdToken;
    }
}
