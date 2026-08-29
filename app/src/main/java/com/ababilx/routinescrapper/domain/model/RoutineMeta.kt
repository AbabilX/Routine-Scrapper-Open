package com.ababilx.routinescrapper.domain.model

data class RoutineMeta(
    val department: String,
    val version: String,
    val semester: String,
    val effectiveFrom: String,
    val sourcePdf: String,
)
