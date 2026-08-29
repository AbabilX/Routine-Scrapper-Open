package com.ababilx.diu

import androidx.activity.result.contract.ActivityResultContracts
import com.ababilx.diu.pdf.PdfPicker
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingResult: MethodChannel.Result? = null

    private val pickPdf = registerForActivityResult(
        ActivityResultContracts.OpenDocument(),
    ) { uri ->
        val result = pendingResult
        pendingResult = null
        if (result == null) return@registerForActivityResult
        if (uri == null) {
            result.success(null)
            return@registerForActivityResult
        }
        try {
            val picked = PdfPicker(contentResolver, cacheDir).copyFrom(uri)
            result.success(picked.toMap())
        } catch (error: Exception) {
            result.error("read_failed", error.message, null)
        }
    }

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
                pickPdf.launch(arrayOf("application/pdf"))
            }
    }

    private companion object {
        const val CHANNEL = "com.ababilx.diu/pdf_picker"
    }
}
