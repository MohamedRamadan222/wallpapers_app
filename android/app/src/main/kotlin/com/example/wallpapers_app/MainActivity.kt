package com.example.wallpapers_app

import android.app.WallpaperManager
import android.content.ContentValues
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val channelName = "wallpapers_app/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                val bytes = call.argument<ByteArray>("bytes")
                if (bytes == null) {
                    result.error("bad_args", "Missing image bytes.", null)
                    return@setMethodCallHandler
                }
                when (call.method) {
                    "setWallpaper" -> runAsync(result) {
                        setWallpaper(bytes, call.argument<String>("target") ?: "both")
                    }
                    "saveToGallery" -> runAsync(result) {
                        saveToGallery(bytes, call.argument<String>("title") ?: "wallpaper")
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun runAsync(result: MethodChannel.Result, block: () -> Unit) {
        Thread {
            try {
                block()
                runOnUiThread { result.success(null) }
            } catch (e: Exception) {
                runOnUiThread { result.error("native_error", e.message, null) }
            }
        }.start()
    }

    private fun setWallpaper(bytes: ByteArray, target: String) {
        val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
            ?: throw IllegalArgumentException("Could not decode image.")
        val wm = WallpaperManager.getInstance(this)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            if (target == "home" || target == "both") {
                wm.setBitmap(bitmap, null, true, WallpaperManager.FLAG_SYSTEM)
            }
            if (target == "lock" || target == "both") {
                wm.setBitmap(bitmap, null, true, WallpaperManager.FLAG_LOCK)
            }
        } else {
            wm.setBitmap(bitmap)
        }
    }

    private fun saveToGallery(bytes: ByteArray, title: String) {
        val fileName = "${sanitize(title)}.jpg"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
                put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
                put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/Wallpapers")
                put(MediaStore.Images.Media.IS_PENDING, 1)
            }
            val resolver = contentResolver
            val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                ?: throw IllegalStateException("Could not create gallery entry.")
            resolver.openOutputStream(uri)?.use { it.write(bytes) }
                ?: throw IllegalStateException("Could not write image.")
            values.clear()
            values.put(MediaStore.Images.Media.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
        } else {
            @Suppress("DEPRECATION")
            val dir = File(
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES),
                "Wallpapers",
            )
            if (!dir.exists()) dir.mkdirs()
            FileOutputStream(File(dir, fileName)).use { it.write(bytes) }
        }
    }

    private fun sanitize(title: String): String {
        val clean = title.replace(Regex("[^A-Za-z0-9]+"), "_").trim('_')
        return "wallpaper_${if (clean.isEmpty()) "image" else clean}_${System.currentTimeMillis()}"
    }
}
