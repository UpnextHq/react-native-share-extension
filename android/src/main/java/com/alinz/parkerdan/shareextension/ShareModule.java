package com.alinz.parkerdan.shareextension;

import com.alinz.parkerdan.shareextension.RealPathUtil;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.Arguments;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;


public class ShareModule extends ReactContextBaseJavaModule {

    public ShareModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "ReactNativeShareExtension";
    }

    @ReactMethod
    public void close() {
        Activity currentActivity = getCurrentActivity();
        if (currentActivity != null) {
            currentActivity.finish();
        }
    }

    @ReactMethod
    public void data(Promise promise) {
        try {
            promise.resolve(processIntent());
        } catch (Throwable t) {
            promise.reject(t);
        }
    }

    public WritableArray processIntent() {
        WritableArray sharedData = Arguments.createArray();

        Activity currentActivity = getCurrentActivity();

        if (currentActivity != null) {
            Intent intent = currentActivity.getIntent();
            if (!Intent.ACTION_SEND.equals(intent.getAction())) {
                return sharedData;
            }

            sharedData.pushString(intent.getStringExtra(Intent.EXTRA_TEXT));
            sharedData.pushString(intent.getDataString());
            sharedData.pushString(intent.getStringExtra(Intent.EXTRA_SUBJECT));
            sharedData.pushString(intent.getStringExtra(Intent.EXTRA_TITLE));

            Uri uri = (Uri) intent.getParcelableExtra(Intent.EXTRA_STREAM);
            if (uri != null) {
                sharedData.pushString("file://" + RealPathUtil.getRealPathFromURI(currentActivity, uri));
            }
        }

        return sharedData;
    }
}
