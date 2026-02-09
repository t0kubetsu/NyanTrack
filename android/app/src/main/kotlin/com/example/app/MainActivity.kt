package com.example.app

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.TelephonyManager
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "device_collector"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "collectDeviceData" -> result.success(collectDeviceData())
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("ERROR", e.message, null)
            }
        }
    }

    private fun collectDeviceData(): Map<String, Any?> {
        val data = HashMap<String, Any?>()

        data["manufacturer"] = Build.MANUFACTURER
        data["model"] = Build.MODEL
        data["brand"] = Build.BRAND
        data["device"] = Build.DEVICE
        data["product"] = Build.PRODUCT
        data["android_version"] = Build.VERSION.RELEASE
        data["sdk"] = Build.VERSION.SDK_INT

        data["is_emulator"] = (Build.FINGERPRINT.startsWith("generic")
                || Build.MODEL.contains("Emulator")
                || Build.MANUFACTURER.contains("Genymotion"))

        data["timezone"] = java.util.TimeZone.getDefault().id
        data["language"] = java.util.Locale.getDefault().language
        data["screen_density"] = resources.displayMetrics.density

        val tm = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager

        data["sim_operator"] = tm.simOperatorName
        data["sim_country"] = tm.simCountryIso
        data["network_operator"] = tm.networkOperatorName

        data["phone_number"] = if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.READ_PHONE_STATE
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            try { tm.line1Number } catch (e: Exception) { null }
        } else {
            null
        }

        return data
    }
}
