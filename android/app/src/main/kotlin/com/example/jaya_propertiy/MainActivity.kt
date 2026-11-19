package com.example.jaya_propertiy

import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Kunci layar untuk mode layar pelanggan terpisah (V165): sematkan
        // aplikasi (screen pinning) supaya pelanggan tidak bisa keluar ke
        // beranda / aplikasi lain, dan jaga layar tetap menyala.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "hipos/kunci_layar")
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "kunci" -> {
                            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                            startLockTask()
                            result.success(true)
                        }
                        "buka" -> {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                            try {
                                stopLockTask()
                            } catch (_: Exception) {
                                // Tidak sedang disematkan.
                            }
                            result.success(true)
                        }
                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    result.error("KUNCI_LAYAR", e.message, null)
                }
            }
    }
}
