package com.codegy.ioswearconnect;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.widget.CompoundButton;
import android.widget.Switch;
import android.widget.TextView;

import java.lang.reflect.Method;
import java.util.ArrayList;

public class MainActivity extends Activity {

    private static final String TAG_LOG = "BLE_wear";
    private static final int REQUEST_BLE_PERMISSIONS = 100;
    private static final String PERMISSION_FINE_LOCATION = "android.permission.ACCESS_FINE_LOCATION";
    private static final String PERMISSION_BLUETOOTH_SCAN = "android.permission.BLUETOOTH_SCAN";
    private static final String PERMISSION_BLUETOOTH_CONNECT = "android.permission.BLUETOOTH_CONNECT";

    private Switch mServiceSwitch;
    private Switch mColorBackgroundsSwitch;
    private Switch mBatteryUpdatesSwitch;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Log.d(TAG_LOG, "-=-=-=-=-=-=-=-= onCreate MainActivity -=-=-=-=-=-=-=-=-=");

        if (!getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)) {
            Log.d(TAG_LOG, "not supported ble");
            finish();
        }

        requestBlePermissionsIfNeeded();

        mServiceSwitch = (Switch) findViewById(R.id.serviceSwitch);
        mColorBackgroundsSwitch = (Switch) findViewById(R.id.colorBackgroundsSwitch);
        mBatteryUpdatesSwitch = (Switch) findViewById(R.id.batteryUpdatesSwitch);

        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(MainActivity.this);
        final boolean colorBackgrounds = sp.getBoolean(Constants.SPK_COLOR_BACKGROUNDS, false);
        final boolean batteryUpdates = sp.getBoolean(Constants.SPK_BATTERY_UPDATES, true);
        final boolean serviceRunning = isServiceRunning();

        mServiceSwitch.setChecked(serviceRunning);
        mServiceSwitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    startService(new Intent(MainActivity.this, BLEService.class));
                } else {
                    stopService(new Intent(MainActivity.this, BLEService.class));
                }
            }
        });

        mColorBackgroundsSwitch.setChecked(colorBackgrounds);
        mColorBackgroundsSwitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(MainActivity.this);
                sp.edit().putBoolean(Constants.SPK_COLOR_BACKGROUNDS, isChecked).apply();

                MainActivity.this.sendBroadcast(new Intent(Constants.IA_COLOR_BACKGROUNDS_CHANGED));
            }
        });

        mBatteryUpdatesSwitch.setChecked(batteryUpdates);
        mBatteryUpdatesSwitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(MainActivity.this);
                sp.edit().putBoolean(Constants.SPK_BATTERY_UPDATES, isChecked).apply();

                MainActivity.this.sendBroadcast(new Intent(Constants.IA_BATTERY_UPDATES_CHANGED));
            }
        });

        TextView modelTextView = (TextView) findViewById(R.id.modelTextView);
        modelTextView.setText(Build.MODEL);
    }

    @Override
    protected void onDestroy(){
        super.onDestroy();
        Log.d(TAG_LOG, "-=-=-=-=-=-=-=-= onDestroy MainActivity -=-=-=-=-=-=-=-=-=");
    }

    @Override
    protected void onResume() {
        super.onResume();

        if (mServiceSwitch != null) {
            final boolean serviceRunning = isServiceRunning();
            mServiceSwitch.setChecked(serviceRunning);
        }
    }

    private boolean isServiceRunning() {
        ActivityManager manager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
        for (ActivityManager.RunningServiceInfo service : manager.getRunningServices(Integer.MAX_VALUE)) {
            if (BLEService.class.getName().equals(service.service.getClassName())) {
                return true;
            }
        }
        return false;
    }

    private void requestBlePermissionsIfNeeded() {
        if (Build.VERSION.SDK_INT < 23) {
            return;
        }

        ArrayList<String> missingPermissions = new ArrayList<>();

        if (!hasPermission(PERMISSION_FINE_LOCATION)) {
            missingPermissions.add(PERMISSION_FINE_LOCATION);
        }

        if (Build.VERSION.SDK_INT >= 31) {
            if (!hasPermission(PERMISSION_BLUETOOTH_SCAN)) {
                missingPermissions.add(PERMISSION_BLUETOOTH_SCAN);
            }
            if (!hasPermission(PERMISSION_BLUETOOTH_CONNECT)) {
                missingPermissions.add(PERMISSION_BLUETOOTH_CONNECT);
            }
        }

        if (missingPermissions.size() == 0) {
            return;
        }

        try {
            Method requestPermissions = Activity.class.getMethod("requestPermissions", String[].class, int.class);
            requestPermissions.invoke(this, missingPermissions.toArray(new String[missingPermissions.size()]), REQUEST_BLE_PERMISSIONS);
        }
        catch (Exception e) {
            Log.w(TAG_LOG, "Unable to request BLE permissions", e);
        }
    }

    private boolean hasPermission(String permission) {
        try {
            Method checkSelfPermission = Context.class.getMethod("checkSelfPermission", String.class);
            Integer result = (Integer) checkSelfPermission.invoke(this, permission);
            return result == PackageManager.PERMISSION_GRANTED;
        }
        catch (Exception e) {
            return checkCallingOrSelfPermission(permission) == PackageManager.PERMISSION_GRANTED;
        }
    }
}
