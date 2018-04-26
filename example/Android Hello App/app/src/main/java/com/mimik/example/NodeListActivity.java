package com.mimik.example;

import android.content.ComponentName;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.mimik.example.appauth.AppAuthorization;
import com.mimik.example.edgeservice.EdgeActions;
import com.mimik.example.mcm.McmActions;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import retrofit2.Response;

public class NodeListActivity extends AppCompatActivity {
    private static final String TAG = "NodeListActivity";

    // Intents used to receive information from modules
    private final String MIMIK_LOGIN_ACTION = "com.mimik.example.appauth.HANDLE_AUTHORIZATION_FINISHED";
    private final String MIMIK_ASSOCIATE_ACTION = "com.mimik.example.edgeservice.HANDLE_ASSOCIATION_FINISHED";
    private final String MIMIK_UNASSOCIATE_TOKEN = "com.mimik.example.edgeservice.HANDLE_UNASSOCIATION_TOKEN";
    private final String MIMIK_UNASSOCIATE_ACTION = "com.mimik.example.edgeservice.HANDLE_UNASSOCIATION_FINISHED";
    private final String MIMIK_EDGEID_TOKEN = "com.mimik.example.edgeservice.HANDLE_EDGEID_TOKEN";

    // Views
    ListView mListView;
    TextView mTextView;
    ProgressBar mProgressBar;
    Button mStartButton;
    Button mLoginButton;
    Button mAssociateButton;
    Button mMcmButton;
    Button mScanButton;
    Button mUnassociateButton;
    Button mStopButton;

    // ListView management
    List<Device> mDevices;
    DeviceAdapter mAdapter;

    // User access tokens
    private String mEdgeAccessToken;
    private String mUserAccessToken;

    // Initial state of buttons
    private EdgeState mEdgeState = EdgeState.INITIAL;

    // List of AsyncTasks to end when app is suspended
    private List<AsyncTask> mTaskList;

    public enum EdgeState {
        INITIAL,
        STARTED,
        LOGGEDIN,
        ASSOCIATED,
        MCM,
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
        mLoginButton = findViewById(R.id.button_login);
        mAssociateButton = findViewById(R.id.button_associate);
        mMcmButton = findViewById(R.id.button_mcm);
        mScanButton = findViewById(R.id.button_scan);
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
        mLoginButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                onLoginButton();
            }
        });
        mAssociateButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                onAssociateButton();
            }
        });
        mMcmButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                onMcmButton();
            }
        });
        mScanButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                onScanButton();
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
        mListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view,
                                    int position, long id) {
                final Device device = (Device) mListView.getItemAtPosition(position);
                onListItem(device);
            }
        });

        updateState(EdgeState.INITIAL);
    }

    @Override
    protected void onPause() {
        // Cancel async tasks that are still running
        for (AsyncTask task : mTaskList) {
            if (task != null && task.getStatus() != AsyncTask.Status.FINISHED) {
                task.cancel(true);
            }
        }
        super.onPause();
    }

    // Handles incoming intents
    @Override
    protected void onNewIntent(Intent intent) {
        if (intent != null && intent.getAction() != null) {
            String action = intent.getAction();
            if (action.equals(MIMIK_LOGIN_ACTION)) {
                // Login intent
                Log.d(TAG, MIMIK_LOGIN_ACTION);
                final String userToken = intent.getStringExtra(AppAuthorization.INTENT_USERTOKEN);
                final String edgeToken = intent.getStringExtra(AppAuthorization.INTENT_EDGETOKEN);
                if (userToken != null && !userToken.isEmpty() &&
                        edgeToken != null && !edgeToken.isEmpty()) {
                    // Successful, store access tokens
                    mUserAccessToken = userToken;
                    mEdgeAccessToken = edgeToken;
                    toast(getResources().getString(R.string.toast_login));
                    updateState(EdgeState.LOGGEDIN);
                } else {
                    // Failed
                    toast(getResources().getString(R.string.toast_failed_login));
                    revertState();
                }
            } else if (action.equals(MIMIK_UNASSOCIATE_TOKEN)) {
                // Unassociation token intent
                String unassociationToken = intent.getStringExtra(AppAuthorization.INTENT_UNASSOCIATETOKEN);
                Log.d(TAG, "unassociationToken = " + unassociationToken);
                if (unassociationToken != null && !unassociationToken.isEmpty()) {
                    // Successful, call edge unassociate
                    EdgeActions.unassociate(unassociationToken, this, MIMIK_UNASSOCIATE_ACTION, new ComponentName(this, getClass()));
                } else {
                    // Failed
                    toast(getResources().getString(R.string.toast_failed_unassociate));
                    revertState();
                }
            } else if (action.equals(MIMIK_EDGEID_TOKEN)) {
                // EdgeId token intent
                String edgeIdToken = intent.getStringExtra(EdgeActions.INTENT_EXTRA_GETEDGEIDTOKEN);
                if (edgeIdToken != null && !edgeIdToken.isEmpty()) {
                    // Successful, call appauth login
                    AppAuthorization.setEdgeIdToken(edgeIdToken);
                    AppAuthorization.login(MIMIK_LOGIN_ACTION, this.getClass(), "", this);
                } else {
                    // Failed
                    toast(getResources().getString(R.string.toast_failed_login));
                    revertState();
                }
            } else if (action.equals(MIMIK_ASSOCIATE_ACTION)) {
                // Edge association intent
                String associatedMessage = intent.getStringExtra(EdgeActions.INTENT_EXTRA_ASSOCIATED);
                if (associatedMessage != null && !associatedMessage.isEmpty()) {
                    // Successful
                    toast(getResources().getString(R.string.toast_associate));
                    updateState(EdgeState.ASSOCIATED);
                } else {
                    // Failed
                    toast(getResources().getString(R.string.toast_failed_associate));
                    revertState();
                }
            } else if (action.equals(MIMIK_UNASSOCIATE_ACTION)) {
                // Edge unassociation intent
                String unassociatedMessage = intent.getStringExtra(EdgeActions.INTENT_EXTRA_UNASSOCIATED);
                if (unassociatedMessage != null && !unassociatedMessage.isEmpty()) {
                    // Successful
                    toast(getResources().getString(R.string.toast_unassociate));
                    updateState(EdgeState.UNASSOCIATED);
                } else {
                    // Failed
                    toast(getResources().getString(R.string.toast_failed_unassociate));
                    revertState();
                }
            }
        }
    }

    // Return UI to previous state, used when a call fails
    private void revertState() {
        updateState(mEdgeState);
    }

    // Update state of buttons, and update stored state for revert
    private void updateState(EdgeState state) {
        boolean start, login, associate, mcm, scan, unassociate, stop, progress;
        start = login = associate = mcm = scan = unassociate = stop = progress = false;
        switch (state) {
            case INITIAL:
                start = true;
                break;
            case STARTED:
                login = stop = true;
                break;
            case LOGGEDIN:
                login = associate = stop = true;
                break;
            case ASSOCIATED:
                mcm = unassociate = stop = true;
                break;
            case MCM:
                scan = unassociate = stop = true;
                break;
            case UNASSOCIATED:
                associate = stop = true;
                break;
            case STOPPED:
                start = true;
                break;
            case DISABLED:
            default:
                break;
        }
        mStartButton.setEnabled(start);
        mLoginButton.setEnabled(login);
        mAssociateButton.setEnabled(associate);
        mMcmButton.setEnabled(mcm);
        mScanButton.setEnabled(scan);
        mUnassociateButton.setEnabled(unassociate);
        mStopButton.setEnabled(stop);
        mProgressBar.setVisibility(progress ? View.VISIBLE : View.GONE);
        if (state != EdgeState.DISABLED) {
            mEdgeState = state;
        }
    }

    // Launch task to acquire device list
    private void refreshDeviceList() {
        mProgressBar.setVisibility(View.VISIBLE);
        new RefreshDeviceListTask().execute();
    }

    // Button Actions
    // Start edge service
    public void onStartButton() {
        updateState(EdgeState.DISABLED);
        if (EdgeActions.startEdge(this) != null) {
            toast(getResources().getString(R.string.toast_start));
            updateState(EdgeState.STARTED);
        }
    }

    // Get edge ID token for tracking, then perform OAuth login
    public void onLoginButton() {
        updateState(EdgeState.DISABLED);
        EdgeActions.getEdgeIdToken(this, MIMIK_EDGEID_TOKEN, new ComponentName(this, getClass()));
    }

    // Associate edge service with the logged in user
    public void onAssociateButton() {
        updateState(EdgeState.DISABLED);
        EdgeActions.associate(mEdgeAccessToken, this, MIMIK_ASSOCIATE_ACTION, new ComponentName(this, getClass()));
    }

    // Add image and register container with mimik Docker container manager
    public void onMcmButton() {
        updateState(EdgeState.DISABLED);
        McmAddContainerTask task = new McmAddContainerTask();
        mTaskList.add(task);
        task.execute();
    }

    // Use example microservice to scan for other devices
    public void onScanButton() {
        updateState(EdgeState.DISABLED);
        toast(getResources().getString(R.string.toast_scan));
        refreshDeviceList();
    }

    // Unassociate edge service from the logged in user
    public void onUnassociateButton() {
        updateState(EdgeState.DISABLED);
        AppAuthorization.getUnassociationToken(MIMIK_UNASSOCIATE_TOKEN, this.getClass(), "", this);
    }

    // Stop edge service
    public void onStopButton() {
        updateState(EdgeState.DISABLED);
        mAdapter.clear();
        mAdapter.notifyDataSetChanged();
        EdgeActions.stopEdge();
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

    // Perform work to add the example container to the mimik container manager (docker)
    private class McmAddContainerTask extends AsyncTask<Void, Void, Boolean> {
        @Override
        protected Boolean doInBackground(final Void... voids) {
            return McmActions.addContainers(mEdgeAccessToken, getApplicationContext());
        }

        @Override
        protected void onPostExecute(final Boolean ret) {
            if (ret) {
                toast(getResources().getString(R.string.toast_mcm));
                updateState(EdgeState.MCM);
            } else {
                toast(getResources().getString(R.string.toast_failed_mcm));
                revertState();
            }
        }
    }

    // Perform work to get a nearby device list from the example service
    private class RefreshDeviceListTask extends AsyncTask<Void, Void, List<Device>> {
        @Override
        protected List<Device> doInBackground(final Void... voids) {
            List<Device> ret = new ArrayList<>();
            try {
                Response<DeviceListObject> response = ExampleProvider.getDevices(mEdgeAccessToken, mUserAccessToken).execute();
                if (response.isSuccessful() && response.body() != null) {
                    ret = response.body().data;
                } else {
                    // Error case, need to handle
                    ret = null;
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
            return ret;
        }

        @Override
        protected void onPostExecute(final List<Device> deviceList) {
            if (deviceList == null) {
                // Retry if query failed
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    // Most likely because the app was closed, don't retry
                    e.printStackTrace();
                    return;
                }
                refreshDeviceList();
                return;
            }
            mProgressBar.setVisibility(View.GONE);
            mAdapter.clear();
            mAdapter.addAll(deviceList);
            mAdapter.notifyDataSetChanged();
            updateState(EdgeState.MCM);
        }
    }

    // Perform work to get a message from a nearby device
    private class GetDeviceMessageTask extends AsyncTask<Device, Void, String> {
        StringBuilder builder;

        @Override
        protected String doInBackground(final Device... devices) {
            builder = new StringBuilder();
            try {
                for (Device device : devices) {
                    String deviceUrl = device.url + "/";
                    Response<HelloMessage> response = ExampleProvider.getMessage(deviceUrl).execute();
                    if (response.isSuccessful() && response.body() != null) {
                        builder.append(device.name).append(" responded with ")
                                .append(response.body().JSONMessage);
                    } else {
                        builder.append(device.name).append(" failed to respond");
                    }
                    break;
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
}
