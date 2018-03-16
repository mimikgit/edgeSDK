package com.mimik.example;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import okhttp3.OkHttpClient;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Call;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;
import retrofit2.http.GET;
import retrofit2.http.Query;

public class ExampleProvider {

    public static final String API_URL = "http://127.0.0.1:8083/example/v1/";
    private static final Gson gson = new GsonBuilder()
            .disableHtmlEscaping()
            .create();

    interface MimikExampleService {
        // Get a list of nearby devices
        @GET("drives")
        Call<DeviceListObject> getDevices(@Query("type") String type);

        // Get a message from a device
        @GET("example/v1/hello")
        Call<HelloMessage> getMessage();
    }

    // Get list of devices
    public static Call<DeviceListObject> getDevices() {
        //TODO: Refactor the service builder (url can be a parameter)
            // Choosing not to, since the api url should not need to be passed in every time
        final HttpLoggingInterceptor logging = new HttpLoggingInterceptor();
        logging.setLevel(HttpLoggingInterceptor.Level.BODY);
        final OkHttpClient client = new OkHttpClient.Builder()
                .addInterceptor(logging)
                .build();

        Retrofit retrofit = new Retrofit.Builder()
                .baseUrl(API_URL)
                .addConverterFactory(GsonConverterFactory.create(gson))
                .client(client)
                .build();

        MimikExampleService service = retrofit.create(MimikExampleService.class);
        return service.getDevices("nearby");
    }

    // Get message from a device
    public static Call<HelloMessage> getMessage(String url) {
        final HttpLoggingInterceptor logging = new HttpLoggingInterceptor();
        logging.setLevel(HttpLoggingInterceptor.Level.BODY);
        final OkHttpClient client = new OkHttpClient.Builder()
                .addInterceptor(logging)
                .build();

        Retrofit retrofit = new Retrofit.Builder()
                .baseUrl(url)
                .addConverterFactory(GsonConverterFactory.create(gson))
                .client(client)
                .build();

        MimikExampleService service = retrofit.create(MimikExampleService.class);
        return service.getMessage();
    }
}
