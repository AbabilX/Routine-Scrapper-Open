package com.ababilx.diu

import android.app.Activity
import android.content.Intent
import com.ababilx.diu.pdf.PdfPicker
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method != "pickPdf") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                if (pendingResult != null) {
                    result.error("busy", "Picker already open", null)
                    return@setMethodCallHandler
                }
                pendingResult = result
                openDocument()
            }
    }

    private fun openDocument() {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/pdf"
        }
        try {
            startActivityForResult(intent, REQUEST_PICK_PDF)
        } catch (error: Exception) {
            finishPending { it.error("no_picker", error.message, null) }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != REQUEST_PICK_PDF) {
            super.onActivityResult(requestCode, resultCode, data)
            return
        }
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            finishPending { it.success(null) }
            return
        }
        try {
            val picked = PdfPicker(contentResolver, cacheDir).copyFrom(uri)
            finishPending { it.success(picked.toMap()) }
        } catch (error: Exception) {
            finishPending { it.error("read_failed", error.message, null) }
        }
    }

    private fun finishPending(block: (MethodChannel.Result) -> Unit) {
        val result = pendingResult ?: return
        pendingResult = null
        block(result)
    }

    private companion object {
        const val CHANNEL = "com.ababilx.diu/pdf_picker"
        const val REQUEST_PICK_PDF = 7301
    }
}
