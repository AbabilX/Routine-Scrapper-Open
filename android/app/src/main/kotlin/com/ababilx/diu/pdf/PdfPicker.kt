package com.ababilx.diu.pdf

import android.content.ContentResolver
import android.net.Uri
import android.provider.OpenableColumns
import java.io.File
import java.io.IOException

data class PickedPdf(
    val path: String,
    val name: String,
) {
    fun toMap(): Map<String, String> = mapOf(
        "path" to path,
        "name" to name,
    )
}

/** Copies a SAF [Uri] into cache so Dart can read a real file path. */
class PdfPicker(
    private val resolver: ContentResolver,
    private val cacheDir: File,
) {
    fun copyFrom(uri: Uri): PickedPdf {
        val name = displayName(uri) ?: "routine.pdf"
        val dest = File(cacheDir, "picked_${System.currentTimeMillis()}.pdf")
        resolver.openInputStream(uri).use { input ->
            if (input == null) throw IOException("empty stream")
            dest.outputStream().use { input.copyTo(it) }
        }
        if (!dest.exists() || dest.length() == 0L) {
            dest.delete()
            throw IOException("empty pdf")
        }
        return PickedPdf(path = dest.absolutePath, name = name)
    }

    private fun displayName(uri: Uri): String? {
        resolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)
            ?.use { cursor ->
                if (!cursor.moveToFirst()) return@use
                val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (index < 0) return@use
                val value = cursor.getString(index)?.trim().orEmpty()
                if (value.isNotEmpty()) return value
            }
        return uri.lastPathSegment?.substringAfterLast('/')
    }
}
