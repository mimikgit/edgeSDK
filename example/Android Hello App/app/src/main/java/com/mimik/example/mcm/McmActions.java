package com.mimik.example.mcm;

import android.content.Context;

import com.mimik.example.R;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;

import retrofit2.Response;

public class McmActions {
    // Add Mcm docker image and container for mimik example service
    public static boolean addContainers(String mcmLicense, Context context) {
        McmProvider.ContainerInfo exampleContainer = createContainer(context);
        McmProvider provider = new McmProvider(mcmLicense);
        try {
            // Check for the image first
            Response<McmProvider.ContainerInfoList> imageResp = provider.getImageList().execute();
            List<McmProvider.ContainerInfo> imageList = imageResp.body().data;
            if (!imageList.contains(exampleContainer)) {
                // Image isn't registered with mimik container manager, so register both the image and the container
                provider.addImage(exampleContainer.filename, exampleContainer.resourceStream).execute();
                provider.addContainer(exampleContainer).execute();
            } else {
//                // Image is registered with mimik container manager,
//                // so just check if the container is as well, and if it isn't, register it
                Response<McmProvider.ContainerInfoList> resp = provider.getContainerList().execute();
                List<McmProvider.ContainerInfo> containerList = resp.body().data;
                if (!containerList.contains(exampleContainer)) {
                    // Container isn't registered with mimik container manager, so register it
                    provider.addContainer(exampleContainer).execute();
                }
            }
            Response<McmProvider.ContainerInfoList> finalContainerResp = provider.getContainerList().execute();
            List<McmProvider.ContainerInfo> finalContainerList = finalContainerResp.body().data;
            return finalContainerList.contains(exampleContainer);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Create an object for the example service
    private static McmProvider.ContainerInfo createContainer(Context context) {
        McmProvider.ContainerInfo container = new McmProvider.ContainerInfo();
        container.id = "example-v1";
        container.name = "example-v1";
        container.image = "example-v1";
        container.imageId = "example-v1";
        container.filename = "example.tar";
        container.env = new HashMap<>();
        container.env.put("MCM.BASE_API_PATH", "/example/v1");
        container.env.put("uMDS", "http://127.0.0.1:8083/mds/v1");
        container.resourceStream = context.getResources().openRawResource(R.raw.example);
        return container;
    }
}
