package com.ababilx.routinescrapper.domain.model

enum class RoutineDay(val shortLabel: String, val fullLabel: String) {
    SATURDAY("Sat", "Saturday"),
    SUNDAY("Sun", "Sunday"),
    MONDAY("Mon", "Monday"),
    TUESDAY("Tue", "Tuesday"),
    WEDNESDAY("Wed", "Wednesday"),
    THURSDAY("Thu", "Thursday");

    companion object {
        fun fromName(raw: String): RoutineDay =
            entries.firstOrNull { it.name == raw.uppercase() } ?: SATURDAY
    }
}
