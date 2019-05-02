package com.mimik.example;

import android.Manifest;
import android.app.PendingIntent;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.Location;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.tasks.OnSuccessListener;
import com.mimik.edgeappauth.EdgeAppAuth;
import com.mimik.edgeappauth.authobject.AuthConfig;
import com.mimik.edgeappauth.authobject.AuthResponse;
import com.mimik.edgeappops.EdgeAppOps;
import com.mimik.edgeappops.edgeservice.EdgeConfig;
import com.mimik.edgeappops.edgeservice.EdgeInfoResponse;
import com.mimik.edgeappops.edgeservice.EdgeLocationResponse;
import com.mimik.edgeappops.microserviceobjects.MicroserviceContainer;
import com.mimik.edgeappops.microserviceobjects.MicroserviceDeploymentConfig;
import com.mimik.edgeappops.microserviceobjects.MicroserviceDeploymentStatus;
import com.mimik.edgeappcommon.EdgeRequestStatus;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import retrofit2.Response;

public class NodeListActivity extends AppCompatActivity {
    private static final String TAG = "NodeListActivity";

    private static final int EDGE_PORT = 8083;

    // Intents used to receive information from modules
    private final String MIMIK_LOGIN_ACTION =
            "com.mimik.example.appauth.HANDLE_AUTHORIZATION_FINISHED";
    private final String MIMIK_UNASSOCIATE_ACTION =
            "com.mimik.example.appauth.HANDLE_UNASSOCIATION_FINISHED";
    private final String MIMIK_INFO_ACTION =
            "com.mimik.example.appops.HANDLE_INFO_FINISHED";
    private final String MIMIK_LOCATION_ACTION =
            "com.mimik.example.appops.HANDLE_LOCATION_FINISHED";

    private final String REDIRECT_URI =
            "com.mimik.example.appauth://oauth2callback";

    private final String SCOPE_GPS = //"";
            "edge:gps:update";

    // Arbitrary code
    private final int GPS_PERMISSION_CODE = 23;

    private String mApiRoot = "";

    // Views
    ListView mListView;
    TextView mTextView;
    ProgressBar mProgressBar;
    Button mStartButton;
    Button mInfoButton;
    Button mGpsButton;
    Button mLoginButton;
    Button mMcmButton;
    Button mNetworkScanButton;
    Button mProximityScanButton;
    Button mMcmRemoveButton;
    Button mUnassociateButton;
    Button mStopButton;

    // ListView management
    List<Device> mDevices;
    DeviceAdapter mAdapter;

    // User access tokens
    private String mEdgeAccessToken;

    // Initial state of buttons
    private EdgeState mEdgeState = EdgeState.INITIAL;

    // List of AsyncTasks to end when app is suspended
    private List<AsyncTask> mTaskList;

    private FusedLocationProviderClient mFusedLocationProviderClient;

    EdgeAppOps mAppOps;

    public enum EdgeState {
        INITIAL,
        STARTED,
        LOGGEDIN,
        ASSOCIATED,
        MCM,
        MCMREMOVED,
        UNASSOCIATED,
        STOPPED,
        DISABLED
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_node_list);
        mListView = findViewById(R.id.listView);
        mTextView = findViewById(R.id.textView);
        mProgressBar = findViewById(R.id.progressBar);
        mProgressBar.setVisibility(View.GONE);
        mStartButton = findViewById(R.id.button_start);
        mInfoButton = findViewById(R.id.button_info);
        mGpsButton = findViewById(R.id.button_addgps);
        mLoginButton = findViewById(R.id.button_login);
        mMcmButton = findViewById(R.id.button_mcm);
        mNetworkScanButton = findViewById(R.id.button_network_scan);
        mProximityScanButton = findViewById(R.id.button_proximity_scan);
        mMcmRemoveButton = findViewById(R.id.button_mcm_remove);
        mUnassociateButton = findViewById(R.id.button_unassociate);
        mStopButton = findViewById(R.id.button_stop);

        mDevices = new ArrayList<>();
        mAdapter = new DeviceAdapter(this, mDevices);
        mListView.setAdapter(mAdapter);

        mTaskList = new ArrayList<>();

        // Button clicks
        mStartButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                onStartButton();
            }
        });
        mInfoButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                onInfoButton();
            }
        });
        mGpsButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                onGpsButton();
            }
        });
        mLoginButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                onLoginButton();
            }
        });
        mMcmButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                onMcmButton();
            }
        });
        mNetworkScanButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                onNetworkScanButton();
            }
        });
        mProximityScanButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                onProximityScanButton();
            }
        });
        mMcmRemoveButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                onMcmRemoveButton();
            }
        });
        mUnassociateButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                onUnassociateButton();
            }
        });
        mStopButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                onStopButton();
            }
        });

        // List item click
        mListView.setOnItemClickListener(
                new AdapterView.OnItemClickListener() {
                    @Override
                    public void onItemClick(AdapterView<?> parent, View view,
                                            int position, long id) {
                        final Device device =
                                (Device) mListView.getItemAtPosition(position);
                        onListItem(device);
                    }
                });

        mFusedLocationProviderClient =
                LocationServices.getFusedLocationProviderClient(this);

        updateState(EdgeState.INITIAL);

        EdgeConfig config = new EdgeConfig(EDGE_PORT);
        mAppOps = new EdgeAppOps(this, config);
    }

    @Override
    protected void onPause() {
        // Cancel async tasks that are still running
        for (AsyncTask task : mTaskList) {
            if (task != null
                    && task.getStatus() != AsyncTask.Status.FINISHED) {
                task.cancel(true);
            }
        }
        mFusedLocationProviderClient.flushLocations();
        super.onPause();
    }

    // Handles incoming intents
    @Override
    protected void onNewIntent(Intent intent) {
        if (intent != null) {
            if (intent.getAction() != null) {
                String action = intent.getAction();
                if (action.equals(MIMIK_LOGIN_ACTION)) {
                    // Login intent
                    handleIntentLogin(intent);
                } else if (action.equals(MIMIK_UNASSOCIATE_ACTION)) {
                    // Edge unassociation intent
                    handleIntentUnassociateAction(intent);
                } else if (action.equals(MIMIK_INFO_ACTION)) {
                    // Edge unassociation intent
                    handleIntentInfoAction(intent);
                } else if (action.equals(MIMIK_LOCATION_ACTION)) {
                    // Edge unassociation intent
                    handleIntentLocationAction(intent);
                }
            }
        }
    }


    private void handleIntentLogin(Intent intent) {
        // Login intent
        EdgeRequestStatus<AuthResponse> requestStatus = EdgeRequestStatus.fromIntent(intent, AuthResponse.class);
        if (requestStatus.response != null
                && requestStatus.response.getAccessToken() != null
                && !requestStatus.response.getAccessToken().isEmpty()) {
            // Successful, store access tokens
            Log.d(TAG, "associateToken = " + requestStatus.response.getAccessToken());
            mEdgeAccessToken = requestStatus.response.getAccessToken();
            toast(getResources().getString(R.string.toast_login));
            updateState(EdgeState.ASSOCIATED);
        } else {
            // Failed
            toast(getResources().getString(R.string.toast_failed_login));
            revertState();
        }
    }

    private void handleIntentUnassociateAction(Intent intent) {
        EdgeRequestStatus<AuthResponse> requestStatus = EdgeRequestStatus.fromIntent(intent, AuthResponse.class);
        if (requestStatus.response != null
                && requestStatus.response.getAccessToken() != null
                && !requestStatus.response.getAccessToken().isEmpty()) {
            // Successful
            Log.d(TAG, "unassociateToken = " + requestStatus.response.getAccessToken());
            toast(getResources().getString(R.string.toast_unassociate));
            updateState(EdgeState.UNASSOCIATED);
        } else {
            // Failed
            toast(getResources().getString(R.string.toast_failed_unassociate));
            revertState();
        }
    }

    private void handleIntentInfoAction(Intent intent) {
        Log.d(TAG, "handleIntentInfoAction");
        logIntent("handleIntentInfoAction", intent);
        EdgeRequestStatus<EdgeInfoResponse> status = EdgeRequestStatus.fromIntent(intent, EdgeInfoResponse.class);
        if (status.response != null) {
            toast(getResources().getString(R.string.toast_info));
            Log.d(TAG, "handleIntentInfoAction " + status.response.toJson());
            mTextView.setText(status.response.toJson());
        } else {
            toast(getResources().getString(R.string.toast_failed_info) + ": " + status.error.getErrorMessage());
        }
        revertState();
    }

    private void handleIntentLocationAction(Intent intent) {
        Log.d(TAG, "handleIntentLocationAction");
        EdgeRequestStatus<EdgeLocationResponse> status = EdgeRequestStatus.fromIntent(intent, EdgeLocationResponse.class);
        if (status.response != null) {
            toast("" + status.response.getStatus());
        } else {
            toast(getResources().getString(R.string.toast_failed_gps) + ": " + status.error.getErrorMessage());
        }
        revertState();
    }

    // Return UI to previous state, used when a call fails
    private void revertState() {
        updateState(mEdgeState);
    }

    // Update state of buttons, and update stored state for revert
    private void updateState(EdgeState state) {
        boolean start, info, login, mcm, scan, mcmRemove, unassociate, stop, progress, gps;
        start = info = login = mcm = scan = mcmRemove = unassociate = stop = progress = gps = false;
        switch (state) {
            case INITIAL:
                start = true;
                break;
            case STARTED:
                info = login = stop = true;
                break;
            case LOGGEDIN:
                info = mcm = stop = true;
                break;
            case ASSOCIATED:
                info = mcm = unassociate = stop = gps = true;
                break;
            case MCM:
                info = scan = mcmRemove = unassociate = stop = gps = true;
                break;
            case UNASSOCIATED:
                info = login = stop = true;
                break;
            case STOPPED:
                start = true;
                break;
            case DISABLED:
            default:
                break;
        }
        mStartButton.setEnabled(start);
        mInfoButton.setEnabled(info);
        mLoginButton.setEnabled(login);
        mMcmButton.setEnabled(mcm);
        mNetworkScanButton.setEnabled(scan);
        mProximityScanButton.setEnabled(scan);
        mMcmRemoveButton.setEnabled(mcmRemove);
        mUnassociateButton.setEnabled(unassociate);
        mStopButton.setEnabled(stop);
        mGpsButton.setEnabled(gps);
        mProgressBar.setVisibility(progress ? View.VISIBLE : View.GONE);
        if (state != EdgeState.DISABLED) {
            mEdgeState = state;
        }
    }

    // Launch task to acquire device list
    private void refreshDeviceList(ExampleProvider.DeviceFilter filter) {
        mProgressBar.setVisibility(View.VISIBLE);
        new RefreshDeviceListTask().execute(filter);
    }

    // Button Actions
    // Start edge service
    public void onStartButton() {
        updateState(EdgeState.DISABLED);
        if (!mAppOps.isPackageInstalled()) {
           toast(getString(R.string.toast_failed_install));
           revertState();
        } else if (mAppOps.startEdge()) {
            toast(getString(R.string.toast_start));
            updateState(EdgeState.STARTED);
        } else {
            toast(getString(R.string.toast_failed_start));
            updateState(EdgeState.INITIAL);
        }
    }

    // Get edge service info
    public void onInfoButton() {
        updateState(EdgeState.DISABLED);
        Intent postInfoIntent = new Intent(
                this,
                NodeListActivity.class);
        postInfoIntent.setAction(MIMIK_INFO_ACTION);
        postInfoIntent.setFlags(
                Intent.FLAG_ACTIVITY_CLEAR_TOP
                        | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        PendingIntent pendingIntent = PendingIntent.getActivity(
                this,
                1,
                postInfoIntent,
                0);
        mAppOps.getInfo(pendingIntent);
    }

    // Handle Location permission interaction
    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == GPS_PERMISSION_CODE) {
            onGpsButton();
        }
    }

    // Submit gps log to edge
    public void onGpsButton() {
        Log.d(TAG, "onGpsButton");
        updateState(EdgeState.DISABLED);
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
                != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(
                    this,
                    new String[] {Manifest.permission.ACCESS_FINE_LOCATION},
                    GPS_PERMISSION_CODE);
            return;
        }
        mFusedLocationProviderClient.getLastLocation()
                .addOnSuccessListener(this, new OnSuccessListener<Location>() {
            @Override
            public void onSuccess(Location location) {
                // Got last known location. In some rare situations this can be null.
                if (location != null) {
                    Log.d(TAG, "onGpsButton location " + location.toString());
                    // Logic to handle location object
                    Intent postLocationIntent = new Intent(
                            getApplicationContext(),
                            NodeListActivity.class);
                    postLocationIntent.setAction(MIMIK_LOCATION_ACTION);
                    postLocationIntent.setFlags(
                            Intent.FLAG_ACTIVITY_CLEAR_TOP
                                    | Intent.FLAG_ACTIVITY_SINGLE_TOP);
                    PendingIntent pendingIntent = PendingIntent.getActivity(
                            getApplicationContext(),
                            1,
                            postLocationIntent,
                            0);
                    mAppOps.reportLocation(mEdgeAccessToken, location, pendingIntent);
                } else {
                    toast(getString(R.string.toast_failed_gps_off));
                    revertState();
                }
            }
        });
    }

    // Get edge ID token for tracking, then perform OAuth login
    public void onLoginButton() {
        updateState(EdgeState.DISABLED);
        AuthConfig config = new AuthConfig();
        config.setClientId(BuildConfig.APPAUTH_CLIENT_ID);
        config.setRedirectUri(Uri.parse(REDIRECT_URI));
        List<String> additionalScopes = new ArrayList<String>();
        additionalScopes.add(SCOPE_GPS);
        config.setAdditionalScopes(additionalScopes);
        config.setAuthorizationRootUri(Uri.parse(BuildConfig.MID_URL));
        Intent postAuthorizationIntent = new Intent(
                this,
                NodeListActivity.class);
        postAuthorizationIntent.setAction(MIMIK_LOGIN_ACTION);
        postAuthorizationIntent.setFlags(
                Intent.FLAG_ACTIVITY_CLEAR_TOP
                | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        PendingIntent pendingIntent = PendingIntent.getActivity(
                this,
                1,
                postAuthorizationIntent,
                0);
        EdgeAppAuth.authorize(this, config, pendingIntent);
    }

    // Add image and register container with mimik Docker container manager
    public void onMcmButton() {
        updateState(EdgeState.DISABLED);
        McmAddContainerTask task = new McmAddContainerTask();
        mTaskList.add(task);
        task.execute();
    }

    // Use example microservice to scan for other local network devices
    public void onNetworkScanButton() {
        updateState(EdgeState.DISABLED);
        toast(getResources().getString(R.string.toast_network_scan));
        refreshDeviceList(ExampleProvider.DeviceFilter.NETWORK);
    }

    // Use example microservice to scan for other nearby devices
    public void onProximityScanButton() {
        updateState(EdgeState.DISABLED);
        toast(getResources().getString(R.string.toast_proximity_scan));
        refreshDeviceList(ExampleProvider.DeviceFilter.PROXIMITY);
    }

    // Unregister container and remove image from mimik Docker container manager
    public void onMcmRemoveButton() {
        updateState(EdgeState.DISABLED);
        McmRemoveContainerTask task = new McmRemoveContainerTask();
        mTaskList.add(task);
        task.execute();
    }

    // Unassociate edge service from the logged in user
    public void onUnassociateButton() {
        updateState(EdgeState.DISABLED);
        AuthConfig config = new AuthConfig();
        config.setClientId(BuildConfig.APPAUTH_CLIENT_ID);
        config.setRedirectUri(Uri.parse(REDIRECT_URI));
        config.setAuthorizationRootUri(Uri.parse(BuildConfig.MID_URL));
        Intent postAuthorizationIntent = new Intent(
                this,
                NodeListActivity.class);
        postAuthorizationIntent.setAction(MIMIK_UNASSOCIATE_ACTION);
        postAuthorizationIntent.setFlags(
                Intent.FLAG_ACTIVITY_CLEAR_TOP
                | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        PendingIntent pendingIntent =
                PendingIntent.getActivity(
                        this,
                        2,
                        postAuthorizationIntent,
                        0);
        EdgeAppAuth.unauthorize(this, config, pendingIntent);
    }

    // Stop edge service
    public void onStopButton() {
        updateState(EdgeState.DISABLED);
        mAdapter.clear();
        mAdapter.notifyDataSetChanged();
        mAppOps.stopEdge();
        toast(getResources().getString(R.string.toast_stop));
        updateState(EdgeState.STOPPED);
    }

    // List item action
    // Get hello message from remote device
    public void onListItem(Device device) {
        mProgressBar.setVisibility(View.VISIBLE);
        GetDeviceMessageTask task = new GetDeviceMessageTask();
        mTaskList.add(task);
        task.execute(device);
    }

    // Toast message display
    private void toast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }

    // Perform work to add the example container to the mimik container manager
    // (docker)
    private class McmAddContainerTask extends AsyncTask<
            Void,
            Void,
            MicroserviceDeploymentStatus> {
        @Override
        protected MicroserviceDeploymentStatus doInBackground(
                final Void... voids) {
            MicroserviceDeploymentConfig config =
                    new MicroserviceDeploymentConfig();
            config.setName("example-v1");
            config.setFilename("example.tar");
            config.setResourceStream(getResources().openRawResource(
                    R.raw.example));
            config.setApiRootUri(Uri.parse("/example/v1"));
            Map<String, String> env = new HashMap<>();
            env.put("uMDS", "http://127.0.0.1:8083/mds/v1");
            env.put("MCM.WEBSOCKET_SUPPORT", "false");
            config.setEnvVariables(env);
            return mAppOps.deployEdgeMicroservice(
                    mEdgeAccessToken,
                    config);
        }

        @Override
        protected void onPostExecute(final MicroserviceDeploymentStatus ret) {
            if (ret.response != null) {
                toast(getResources().getString(R.string.toast_mcm));
                MicroserviceContainer container = ret.response.getContainer();
                mApiRoot = container.getApiRootUri().toString();
                if (!mApiRoot.startsWith("/")) { mApiRoot = "/" + mApiRoot; }
                if (!mApiRoot.endsWith("/")) { mApiRoot = mApiRoot + "/"; }
                updateState(EdgeState.MCM);
            } else {
                toast(getResources().getString(R.string.toast_failed_mcm));
                revertState();
            }
        }
    }

    // Perform work to remove the example container from mimik Container
    // Manager
    private class McmRemoveContainerTask extends AsyncTask<
            Void,
            Void,
            MicroserviceDeploymentStatus> {
        @Override
        protected MicroserviceDeploymentStatus doInBackground(
                final Void... voids) {
            MicroserviceDeploymentConfig config =
                    new MicroserviceDeploymentConfig();
            config.setName("example-v1");
            return mAppOps.removeEdgeMicroservice(
                    mEdgeAccessToken,
                    config);
        }

        @Override
        protected void onPostExecute(final MicroserviceDeploymentStatus ret) {
            if (ret.response != null) {
                toast(getResources().getString(R.string.toast_mcm_remove));
                updateState(EdgeState.ASSOCIATED);
            } else {
                toast(getResources().getString(R.string.toast_failed_mcm_remove));
                revertState();
            }
        }
    }

    // Perform work to get a device list from the example service
    private class RefreshDeviceListTask extends AsyncTask<
            ExampleProvider.DeviceFilter,
            Void,
            List<Device>> {
        @Override
        protected List<Device> doInBackground(
                final ExampleProvider.DeviceFilter... filterType) {
            List<Device> ret = null;
            try {
                if (filterType != null && filterType.length == 1) {
                    Response<DeviceListObject> response =
                            ExampleProvider.getDevices(
                                    filterType[0],
                                    mEdgeAccessToken,
                                    mApiRoot).execute();
                    if (response.isSuccessful() && response.body() != null) {
                        ret = response.body().data;
                    }
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
            return ret;
        }

        @Override
        protected void onPostExecute(final List<Device> deviceList) {
            mProgressBar.setVisibility(View.GONE);
            if (deviceList == null) {
                toast(getResources().getString(R.string.toast_scan_retry));
            } else {
                mAdapter.clear();
                mAdapter.addAll(deviceList);
                mAdapter.notifyDataSetChanged();
            }
            updateState(EdgeState.MCM);
        }
    }

    // Perform work to get a message from a nearby device
    private class GetDeviceMessageTask extends AsyncTask<
            Device,
            Void,
            String> {
        StringBuilder builder;

        @Override
        protected String doInBackground(final Device... devices) {
            builder = new StringBuilder("");
            try {
                for (Device device : devices) {
                    if (device != null) {
                        // Establish a tunnel to the device
                        Response<Device> deviceResponse =
                                ExampleProvider.checkNodePresence(
                                        device.id,
                                        mEdgeAccessToken,
                                        mApiRoot).execute();
                        if (deviceResponse.isSuccessful()
                                && deviceResponse.body() != null) {
                            // New device object has a working url
                            Device newDevice = deviceResponse.body();
                            if (newDevice != null
                                    && newDevice.url != null
                                    && !newDevice.url.isEmpty()) {
                                String deviceUrl = newDevice.url;
                                if (!deviceUrl.endsWith("/")) {
                                    deviceUrl = deviceUrl + "/";
                                }
                                Response<HelloMessage> response =
                                        ExampleProvider.getMessage(deviceUrl, mApiRoot)
                                                .execute();
                                if (response.isSuccessful()
                                        && response.body() != null) {
                                    builder.append(device.name)
                                            .append(" responded with ")
                                            .append(response.body().
                                                    JSONMessage);
                                } else {
                                    builder.append(device.name)
                                            .append(" failed to respond");
                                }
                                break;
                            }
                        } else {
                            builder.append(device.name)
                                    .append(" failed to respond");
                        }
                    }
                }
            } catch (IOException e) {
                e.printStackTrace();
            }

            return builder.toString();
        }

        @Override
        protected void onPostExecute(final String response) {
            mTextView.setText(response);
            mProgressBar.setVisibility(View.GONE);
        }
    }

    public void logIntent(String tag, Intent intent) {
        if (intent != null) {
            Log.d(tag, "action " + intent.getAction());
            Log.d(tag, "data " + intent.getData());
            Log.d(tag, "datastring " + intent.getDataString());
            Log.d(tag, "scheme " + intent.getScheme());
            Log.d(tag, "type " + intent.getType());
            Log.d(tag, "package " + intent.getPackage());
            if (intent.getExtras() != null) {
                for (String key : intent.getExtras().keySet()) {
                    Log.d(tag, "extra(" + key + ") "
                            + intent.getExtras().get(key).toString());
                }
            }
        }
    }
}
