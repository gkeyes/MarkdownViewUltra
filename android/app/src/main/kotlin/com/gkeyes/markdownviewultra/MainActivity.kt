package com.gkeyes.markdownviewultra

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.gkeyes.markdownviewultra/intent"
    private var pendingFilePath: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "getIntentFile" -> {
                        result.success(pendingFilePath ?: getFilePathFromIntent(intent))
                        pendingFilePath = null
                    }
                    else -> result.notImplemented()
                }
            }
        }

        // Handle initial intent
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        if (intent == null) return

        when (intent.action) {
            Intent.ACTION_VIEW -> {
                val filePath = getFilePathFromIntent(intent)
                if (filePath != null) {
                    pendingFilePath = filePath
                }
            }
        }
    }

    private fun getFilePathFromIntent(intent: Intent): String? {
        val uri = intent.data ?: return null
        return copyUriToCache(uri) ?: uri.path
    }

    private fun copyUriToCache(uri: Uri): String? {
        return try {
            val inputStream = contentResolver.openInputStream(uri) ?: return null
            val fileName = getFileName(uri) ?: "temp.md"
            val cacheFile = File(cacheDir, fileName)
            val outputStream = FileOutputStream(cacheFile)
            inputStream.copyTo(outputStream)
            inputStream.close()
            outputStream.close()
            cacheFile.absolutePath
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    private fun getFileName(uri: Uri): String? {
        var name: String? = null
        val cursor = contentResolver.query(uri, null, null, null, null)
        cursor?.use {
            if (it.moveToFirst()) {
                val nameIndex = it.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (nameIndex >= 0) {
                    name = it.getString(nameIndex)
                }
            }
        }
        return name
    }
}