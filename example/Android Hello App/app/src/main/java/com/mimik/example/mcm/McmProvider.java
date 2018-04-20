package com.mimik.example.mcm;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;

import okhttp3.Interceptor;
import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okio.BufferedSink;
import retrofit2.Call;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;
import retrofit2.http.Body;
import retrofit2.http.DELETE;
import retrofit2.http.GET;
import retrofit2.http.Multipart;
import retrofit2.http.POST;
import retrofit2.http.Part;
import retrofit2.http.Path;

public class McmProvider {

    public static final String MCM_URL = "http://127.0.0.1:8083/mcm/v1/";
    private final String mcmLicense;

    private final Gson gson = new GsonBuilder()
            .disableHtmlEscaping()
            .create();

    interface McmService {
        // Get a list of registered images
        @GET("images")
        Call<ContainerInfoList> getImages();

        // Get a list of registered containers
        @GET("containers")
        Call<ContainerInfoList> getContainers();

        // Add an image
        @Multipart
        @POST("images")
        Call<ContainerInfo> addImage(@Part MultipartBody.Part image);

        // Add a container from an existing image
        @POST("containers")
        Call<ContainerInfo> addContainer(@Body ContainerInfo param);

        // Delete a container
        @DELETE("containers/{containerName}")
        Call<ContainerInfo> deleteContainer(@Path("containerName") String containerId);

        // Delete an image
        @DELETE("images/{imageName}")
        Call<Void> deleteImage(@Path("imageName") String imageId);
    }

    public static class ContainerInfoList {
        public List<ContainerInfo> data;
    }

    public static class ContainerInfo {
        public String id;
        public String name;
        public String image;
        public String imageId;
        public transient long created;
        public transient long size;
        public Map<String, String> env;
        public String state;
        public transient String filename;
        public transient InputStream resourceStream;

        @Override
        public boolean equals(Object compareTo) {
            if (compareTo instanceof ContainerInfo && this.id != null) {
                return this.id.equals(((ContainerInfo) compareTo).id);
            }
            return false;
        }
    }

    public McmProvider(String mcmLicense) {
        this.mcmLicense = mcmLicense;
    }

    public McmService buildMcmService() {
        final OkHttpClient client = new OkHttpClient.Builder()
                .addInterceptor(new Interceptor() {
                    @Override
                    public Response intercept(final Chain chain) throws IOException {
                        Request newRequest = chain.request().newBuilder()
                                .addHeader("Authorization", "Bearer " + mcmLicense)
                                .build();
                        return chain.proceed(newRequest);
                    }
                })
                .build();

        String url = MCM_URL;
        Retrofit retrofit = new Retrofit.Builder()
                .baseUrl(url)
                .addConverterFactory(GsonConverterFactory.create(gson))
                .client(client)
                .build();

        return retrofit.create(McmService.class);
    }

    public Call<ContainerInfoList> getImageList() {
        return buildMcmService().getImages();
    }

    public Call<ContainerInfoList> getContainerList() {
        return buildMcmService().getContainers();
    }

    public Call<ContainerInfo> addImage(String filename, final InputStream image) {
        if (image == null) { return null; }

        // Code for reading the file stream
        final int contentLength;

        try {
            contentLength = image.available();
        } catch (IOException e) {
            return null;
        }

        RequestBody requestBody = new RequestBody() {
            @Override public long contentLength() throws IOException {
                return contentLength;
            }

            @Override
            public MediaType contentType() {
                return MediaType.parse("application/tar");
            }

            @Override
            public void writeTo(BufferedSink sink) throws IOException {
                byte[] buffer = new byte[4096];
                try {
                    int read;
                    while ((read = image.read(buffer)) != -1) {
                        sink.write(buffer, 0, read);
                    }
                } catch (Throwable throwable) {
                    throwable.printStackTrace();
                } finally {
                    image.close();
                }
            }
        };


        MultipartBody.Part filePart =
                MultipartBody.Part.createFormData(
                        "image", filename, requestBody);
        return buildMcmService().addImage(filePart);
    }

    public Call<ContainerInfo> addContainer(ContainerInfo info) {
        return buildMcmService().addContainer(info);
    }

    public Call<ContainerInfo> removeContainer(String containerId) {
        return buildMcmService().deleteContainer(containerId);
    }

    public Call<Void> removeImage(String imageId) {
        return buildMcmService().deleteImage(imageId);
    }
}
