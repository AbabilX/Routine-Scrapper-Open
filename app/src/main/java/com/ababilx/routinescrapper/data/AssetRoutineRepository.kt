package com.ababilx.routinescrapper.data

import android.content.Context
import com.ababilx.routinescrapper.domain.model.ClassSlot
import com.ababilx.routinescrapper.domain.model.RoutineDay
import com.ababilx.routinescrapper.domain.model.RoutineMeta
import kotlinx.serialization.json.Json

class AssetRoutineRepository(context: Context) {
    private val json = Json { ignoreUnknownKeys = true }
    private val file: RoutineFileDto = context.assets
        .open(ASSET_PATH)
        .bufferedReader()
        .use { reader -> json.decodeFromString(reader.readText()) }

    val meta: RoutineMeta = RoutineMeta(
        department = file.meta.department,
        version = file.meta.version,
        semester = file.meta.semester,
        effectiveFrom = file.meta.effectiveFrom,
        sourcePdf = file.meta.sourcePdf,
    )

    val slots: List<ClassSlot> = file.slots.map { dto ->
        ClassSlot(
            day = RoutineDay.fromName(dto.day),
            slot = dto.slot,
            start = dto.start,
            end = dto.end,
            course = dto.course,
            group = dto.group,
            teacher = dto.teacher,
            room = dto.room,
        )
    }

    companion object {
        const val ASSET_PATH = "routine/cse_summer_2026_v5.json"
        const val PDF_ASSET = "routine/cse_summer_2026_v5.pdf"
    }
}
