package com.mimik.example;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.io.IOException;

import okhttp3.Interceptor;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Call;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;
import retrofit2.http.GET;
import retrofit2.http.Path;
import retrofit2.http.Query;

public class ExampleProvider {

    public static final String API_URL = "http://127.0.0.1:8083/example/v1/";
    private static final Gson gson = new GsonBuilder()
            .disableHtmlEscaping()
            .create();

    public enum DeviceFilter {
        NETWORK,
        PROXIMITY,
        ACCOUNT
    }

    // Get list of devices
    public static Call<DeviceListObject> getDevices(final DeviceFilter filter, final String edgeAccessToken) {
        final HttpLoggingInterceptor logging = new HttpLoggingInterceptor();
        logging.setLevel(HttpLoggingInterceptor.Level.BODY);
        final OkHttpClient client = new OkHttpClient.Builder()
                .addInterceptor(logging)
                .addInterceptor(new Interceptor() {
                    @Override
                    public Response intercept(final Chain chain) throws IOException {
                        Request newRequest = chain.request().newBuilder()
                                .addHeader("Authorization", "Bearer " + edgeAccessToken)
                                .build();
                        return chain.proceed(newRequest);
                    }
                })
                .build();

        Retrofit retrofit = new Retrofit.Builder()
                .baseUrl(API_URL)
                .addConverterFactory(GsonConverterFactory.create(gson))
                .client(client)
                .build();

        MimikExampleService service = retrofit.create(MimikExampleService.class);
        String type;
        switch (filter) {
            case PROXIMITY:
                type = "proximity";
                break;
            case ACCOUNT:
                type = "account";
                break;
            case NETWORK:
            default:
                type = "nearby";
        }
        return service.getDevices(type);
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

    public static Call<Device> checkNodePresence(final String deviceId, final String edgeAccessToken, final String userAccessToken) {
        final HttpLoggingInterceptor logging = new HttpLoggingInterceptor();
        logging.setLevel(HttpLoggingInterceptor.Level.BODY);
        final OkHttpClient client = new OkHttpClient.Builder()
                .addInterceptor(logging)
                .addInterceptor(new Interceptor() {
                    @Override
                    public Response intercept(final Chain chain) throws IOException {
                        Request newRequest = chain.request().newBuilder()
                                .addHeader("Authorization", "Bearer " + edgeAccessToken)
                                .build();
                        return chain.proceed(newRequest);
                    }
                })
                .build();

        Retrofit retrofit = new Retrofit.Builder()
                .baseUrl(API_URL)
                .addConverterFactory(GsonConverterFactory.create(gson))
                .client(client)
                .build();

        MimikExampleService service = retrofit.create(MimikExampleService.class);
        return service.getPresence(deviceId, userAccessToken);
    }

    interface MimikExampleService {
        // Get a list of nearby devices
        @GET("drives")
        Call<DeviceListObject> getDevices(@Query("type") String type);

        // Get a message from a device
        @GET("example/v1/hello")
        Call<HelloMessage> getMessage();

        @GET("nodes/{id}")
        Call<Device> getPresence(@Path("id") String id, @Query("userAccessToken") String userToken);
    }
}
