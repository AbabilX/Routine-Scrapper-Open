package com.ababilx.routinescrapper.data

import android.content.Context
import android.content.Intent
import androidx.core.content.FileProvider
import java.io.File

object PdfExporter {
    fun share(context: Context, fileName: String = "CSE_Routine_V5.pdf") {
        val out = File(context.cacheDir, fileName)
        context.assets.open(AssetRoutineRepository.PDF_ASSET).use { input ->
            out.outputStream().use { input.copyTo(it) }
        }
        val uri = FileProvider.getUriForFile(
            context,
            "${context.packageName}.files",
            out,
        )
        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "application/pdf"
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        context.startActivity(Intent.createChooser(intent, "Share routine PDF"))
    }
}
