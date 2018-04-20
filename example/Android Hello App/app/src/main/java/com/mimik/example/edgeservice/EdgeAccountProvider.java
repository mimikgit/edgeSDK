package com.mimik.example.edgeservice;

import android.content.Context;
import android.content.Intent;
import android.util.Base64;
import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.mimik.example.jsonrpc.JsonRpcMessage;
import com.mimik.example.jsonrpc.JsonRpcResponse;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.WebSocket;
import okhttp3.WebSocketListener;

import static com.mimik.example.edgeservice.EdgeAccountProvider.EdgeCommand.ASSOCIATE;
import static com.mimik.example.edgeservice.EdgeAccountProvider.EdgeCommand.GETEDGEIDTOKEN;
import static com.mimik.example.edgeservice.EdgeAccountProvider.EdgeCommand.UNASSOCIATE;

/**
 * Implementation for mimik edge JsonRPC interface, which is responsible for account association tasks
 */

public class EdgeAccountProvider {

    public static final String TAG = "EdgeAccountProvider";

    // JsonRPC commands
    public static final String COMMAND_GETME = "getMe";
    public static final String COMMAND_ASSOCIATE = "associateAccount";
    public static final String COMMAND_UNASSOCIATE = "unassociateAccount";
    public static final String COMMAND_GETEDGEIDTOKEN = "getEdgeIdToken";

    // JsonRPC mimik error code
    public static final int JSONRPC_MIMIK_ERROR_CODE = -32603;

    static long id = 0;

    private final String url = "ws://127.0.0.1:8083/ws/edge-service-api/v1";

    private final Gson gson = new GsonBuilder()
            .setDateFormat("yyyy-MM-dd'T'HH:mm:ssZ")
            .disableHtmlEscaping()
            .create();

    // Parses the jwt styled access token to acquire the "sub" field
    private static String getAccountIdFromIdToken(String idToken) {
        if (idToken == null) {
            return "";
        }
        String[] split = idToken.split(Pattern.quote("."));
        if (split.length < 2) {
            return "";
        }
        String body = new String(Base64.decode(split[1], Base64.DEFAULT));
        Gson gson = new Gson();
        IdToken token = gson.fromJson(body, IdToken.class);
        return token.sub;
    }

    // Initialize the websocket and send message
    private void send(EdgeCommand command, List<Object> options, Context context, Intent callbackIntent) throws UnsupportedOperationException {
        long tId = id++;
        OkHttpClient client = new OkHttpClient();
        Request request = new Request.Builder().url(url).build();
        EdgeAccountEvent listener = new EdgeAccountEvent(command, tId, options, context, callbackIntent);
        client.newWebSocket(request, listener);
        client.dispatcher().executorService().shutdown();
    }

    // Get information on the edge service
    public void getMe(Context context, Intent callbackIntent) {
        send(EdgeCommand.GETME, new ArrayList<>(), context, callbackIntent);
    }

    // Associate with an access token
    public void associate(String accessToken, Context context, Intent callbackIntent) {
        List<Object> options = new ArrayList<>();
        options.add(accessToken);
        send(EdgeCommand.ASSOCIATE, options, context, callbackIntent);
    }

    // Unassociate with an access token
    public void unassociate(String accessToken, Context context, Intent callbackIntent) {
        List<Object> options = new ArrayList<>();
        options.add(accessToken);
        send(UNASSOCIATE, options, context, callbackIntent);
    }

    public void getEdgeIdToken(Context context, Intent callbackIntent) {
        send(GETEDGEIDTOKEN, new ArrayList<>(), context, callbackIntent);
    }

    public enum EdgeCommand {
        GETME,
        ASSOCIATE,
        UNASSOCIATE,
        GETEDGEIDTOKEN
    }

    // Web socket handler for sending and receiving
    private final class EdgeAccountEvent extends WebSocketListener {
        private static final int NORMAL_CLOSURE_STATUS = 1000;
        final EdgeCommand mCommand;
        final long mId;
        List<Object> mOptions;
        Intent mCallbackIntent;
        Context mContext;

        EdgeAccountEvent(EdgeCommand command, long id, List<Object> options, Context context, Intent callbackIntent) {
            mCommand = command;
            mId = id;
            mOptions = options;
            mContext = context;
            mCallbackIntent = callbackIntent;
        }

        // Send JsonRpc command upon opening
        @Override
        public void onOpen(WebSocket webSocket, Response response) {
            String commandString;
            switch (mCommand) {
                case GETME:
                    commandString = COMMAND_GETME;
                    break;
                case ASSOCIATE:
                    commandString = COMMAND_ASSOCIATE;
                    break;
                case UNASSOCIATE:
                    commandString = COMMAND_UNASSOCIATE;
                    break;
                case GETEDGEIDTOKEN:
                    commandString = COMMAND_GETEDGEIDTOKEN;
                    break;
                default:
                    webSocket.close(NORMAL_CLOSURE_STATUS, "Failed!");
                    return;
            }
            JsonRpcMessage jrpcMessage = new JsonRpcMessage(commandString, mOptions, mId);
            String text = gson.toJson(jrpcMessage);
            webSocket.send(text);
            webSocket.close(NORMAL_CLOSURE_STATUS, "Finished");
        }

        // Receive a response
        @Override
        public void onMessage(WebSocket webSocket, String text) {
            Log.d(TAG, "onTextMessage: " + text);
            JsonRpcResponse resp = gson.fromJson(text, JsonRpcResponse.class);
            if (resp.id == mId) {
                String ret;
                if (resp.error != null) {
                    if (resp.error.code == JSONRPC_MIMIK_ERROR_CODE) {
                        if (mCommand == ASSOCIATE && resp.error.data.toString().contains("already")) {
                            ret = getAccountIdFromIdToken((String) mOptions.get(0));
                        } else {
                            ret = "";
                        }
                    } else {
                        // dropping unaccounted for errors, for this purpose they don't affect the flow
                        return;
                    }
                } else {
                    switch (mCommand) {
                        case GETEDGEIDTOKEN:
                            ret = resp.result.get("id_token").toString();
                            break;
                        default:
                            ret = resp.result.get("accountId").toString();
                            break;
                    }

                }
                Intent intent = mCallbackIntent;
                switch (mCommand) {
                    case GETME:
                        intent.putExtra(EdgeActions.INTENT_EXTRA_GETME, ret);
                        break;
                    case ASSOCIATE:
                        intent.putExtra(EdgeActions.INTENT_EXTRA_ASSOCIATED, ret);
                        break;
                    case UNASSOCIATE:
                        intent.putExtra(EdgeActions.INTENT_EXTRA_UNASSOCIATED, ret);
                        break;
                    case GETEDGEIDTOKEN:
                        intent.putExtra(EdgeActions.INTENT_EXTRA_GETEDGEIDTOKEN, ret);
                        break;
                    default:
                        intent.putExtra(EdgeActions.INTENT_EXTRA_ASSOCIATED, "");
                        webSocket.close(NORMAL_CLOSURE_STATUS, "Failed!");
                        return;
                }
                intent.setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
                mContext.startActivity(intent);
            }
        }

        @Override
        public void onClosing(WebSocket webSocket, int code, String reason) {
            webSocket.close(NORMAL_CLOSURE_STATUS, null);
        }
    }

    public class IdToken {
        String sub;
    }
}
