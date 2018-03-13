package com.mimik.example;

import android.graphics.Color;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import retrofit2.Response;

public class NodeListActivity extends AppCompatActivity {
    ListView mListView;
    TextView mTextView;
    ProgressBar mProgressBar;

    List<Device> mDevices;
    DeviceAdapter mAdapter;

    // Handle for McmAddContainerTask
    McmAddContainerTask mTask;

    // Insert the edge license string here
    private final String mEdgeLicense = "";

    // mimik container manager license will be acquired from the edge service once it is running
    String mMcmLicense = "";

    EdgeServiceModule mEdgeService;

    // Perform work to add the example container to the mimik container manager
    private class McmAddContainerTask extends AsyncTask<Void, Void, Void> {
        @Override
        protected Void doInBackground(final Void... voids) {

            // First, we need to grab the container manager license
            String mcmLicense = null;
            while (mcmLicense == null) {
                try {
                    if (isCancelled()) {
                        return null;
                    }
                    Thread.sleep(1000);
                    mcmLicense = mEdgeService.getMcmLicense();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
            mMcmLicense = mcmLicense;

            // Next, we check if out example service is already registered,
            // and if it isn't, we add it
            McmProvider provider = new McmProvider(mMcmLicense);
            try {
                McmProvider.ContainerInfo exampleContainer = createContainer();
                // Check for the image first
                Response<McmProvider.ContainerInfoList> imageResp = provider.getImageList().execute();
                List<McmProvider.ContainerInfo> imageList = imageResp.body().data;
                if (!imageList.contains(exampleContainer)) {
                    // Image isn't registered with mimik container manager, so register both the image and the container
                    provider.addImage(exampleContainer.filename, exampleContainer.resourceStream).execute();
                    provider.addContainer(exampleContainer).execute();
                } else {
                    // Image is registered with mimik container manager,
                    // so just check if the container is as well, and if it isn't, register it
                    Response<McmProvider.ContainerInfoList> resp = provider.getContainerList().execute();
                    List<McmProvider.ContainerInfo> containerList = resp.body().data;
                    if (!containerList.contains(exampleContainer)) {
                        // Container isn't registered with mimik container manager, so register it
                        provider.addContainer(exampleContainer).execute();
                    }
                }

            } catch (IOException e) {
                e.printStackTrace();
            }
            return null;
        }

        @Override
        protected void onPostExecute(final Void voids) {
            if (!isCancelled()) {
                // Once the service is registered, we trigger a device list refresh
                refreshDeviceList();
            }
        }
    }

    // Perform work to get a nearby device list from the example service
    private class RefreshDeviceListTask extends AsyncTask<Void, Void, List<Device>> {
        @Override
        protected List<Device> doInBackground(final Void... voids) {
            List<Device> ret = new ArrayList<>();
            try {
                Response<DeviceListObject> response = ExampleProvider.getDevices().execute();
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
        }


    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_node_list);
        mListView = findViewById(R.id.listView);
        mTextView = findViewById(R.id.textView);
        mProgressBar = findViewById(R.id.progressBar);

        mDevices = new ArrayList<>();

        mAdapter = new DeviceAdapter(this, mDevices);
        mListView.setAdapter(mAdapter);

        mListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view,
                                    int position, long id) {
                final Device device = (Device) mListView.getItemAtPosition(position);
                new GetDeviceMessageTask().execute(device);
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (mEdgeLicense.isEmpty()) {
            mTextView.setText(R.string.missing_license);
            mTextView.setTextColor(Color.RED);
            mProgressBar.setVisibility(View.GONE);
        } else {
            if (mEdgeService == null) {
                // initialize the mimik edge service with example parameters
                Map<String, String> options = new HashMap<>();
                options.put("port", "" + 8083);
                options.put("capability", "" + 3);
                options.put("nodeName", "testNode");
                //options.put("license", mEdgeLicense);

                mEdgeService = new EdgeServiceModule(
                        this,
                        mEdgeLicense,
                        options);
                mEdgeService.start();

                // Register the example service with the mimik container manager
                mTask = new McmAddContainerTask();
                mTask.execute();
            } else {
                refreshDeviceList();
            }
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mTask != null && mTask.getStatus() != AsyncTask.Status.FINISHED) {
            mTask.cancel(true);
        }
    }

    // Create an object for the example service
    private McmProvider.ContainerInfo createContainer() {
        McmProvider.ContainerInfo container = new McmProvider.ContainerInfo();
        // TODO: need to use different strings for everything once mcm if fixed to handle them correctly
        container.id = "example-v1";
        container.name = "example-v1";
        container.image = "example-v1";
        container.imageId = "example-v1";
        container.filename = "example.tar";
        container.env = new HashMap<>();
        container.env.put("MCM.BASE_API_PATH", "/example/v1");
        container.env.put("uMDS", "http://127.0.0.1:8083/mds/v1");
        container.resourceStream = this.getResources().openRawResource(R.raw.example);
        return container;
    }

    private void refreshDeviceList() {
        mProgressBar.setVisibility(View.VISIBLE);
        new RefreshDeviceListTask().execute();
    }
}
