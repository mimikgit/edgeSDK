package com.mimik.example;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.Log;

import com.mimik.edgeservice.EdgeServiceParcelable;
import com.mimik.edgeservice.IEdgeService;

import java.util.Map;

public class EdgeServiceModule {

    IEdgeService mService = null;

    private final Context context;
    private final String licenseString;

    private final Map<String, String> options;

    private boolean mBound;

    private ServiceConnection mConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder binder) {
            mService = IEdgeService.Stub.asInterface(binder);
            EdgeServiceParcelable parcelable = new EdgeServiceParcelable();
            parcelable.setLicenseString(licenseString);
            parcelable.setOptions(options);

            try {
                mService.start(parcelable);
                mBound = true;
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {

        }
    };

    public EdgeServiceModule(Context context,
                           String licenseString,
                           Map<String, String> options) {
        this.context = context;
        this.licenseString = licenseString;
        this.options = options;
        this.mBound = false;
    }

    public void start() {
        if (!mBound) {
            Intent intent = new Intent("com.mimik.edgeservice.ACTION_BIND");
            intent.setPackage("com.mimik.edgeservice");
            context.getApplicationContext().bindService(intent, mConnection, Context.BIND_AUTO_CREATE);
        }
    }

    public void stop() {
        if (mBound) {
            try {
                mService.stop();
            } catch (RemoteException e) {
                e.printStackTrace();
            }
            context.getApplicationContext().unbindService(mConnection);
            mBound = false;
        }
    }

    public String getMcmLicense() {
        if (mBound) {
            String ret = null;
            try {
                ret = mService.getMcmLicense();
            } catch (RemoteException e) {
                e.printStackTrace();
            }
            return ret;
        }
        return null;
    }
}
