package com.mimik.edgeservice;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.HashMap;
import java.util.Map;

public class EdgeServiceParcelable implements Parcelable {
    private int version = 4;
    private String licenseString = "";
    private Map<String, String> options = new HashMap<>();

    public EdgeServiceParcelable() {

    }

    protected EdgeServiceParcelable(Parcel in) {
        version = in.readInt();
        licenseString = in.readString();
        int size = in.readInt();
        for (int i = 0; i < size; i++) {
            options.put(in.readString(), in.readString());
        }
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(version);
        dest.writeString(licenseString);
        dest.writeInt(options.size());
        for (Map.Entry<String, String> entry : options.entrySet()) {
            dest.writeString(entry.getKey());
            dest.writeString(entry.getValue());
        }
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<EdgeServiceParcelable> CREATOR = new Creator<EdgeServiceParcelable>() {
        @Override
        public EdgeServiceParcelable createFromParcel(Parcel in) {
            return new EdgeServiceParcelable(in);
        }

        @Override
        public EdgeServiceParcelable[] newArray(int size) {
            return new EdgeServiceParcelable[size];
        }
    };

    public String getLicenseString() {
        return licenseString;
    }

    public void setLicenseString(String tenantId) {
        this.licenseString = tenantId;
    }

    public Map<String, String> getOptions() {
        return options;
    }

    public void setOptions(Map<String, String> options) {
        this.options = options;
    }
}
