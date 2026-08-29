package com.ababilx.routinescrapper.domain

data class StudentQuery(
    val batch: String,
    val section: String,
) {
    val label: String
        get() = if (section.isEmpty()) batch else "${batch}_$section"

    fun matches(group: String): Boolean {
        val g = group.uppercase()
        if (section.isEmpty()) {
            return g == batch || g.startsWith("${batch}_")
        }
        val exact = "${batch}_$section"
        if (g == exact) return true
        return g.startsWith(exact) && g.length > exact.length && g[exact.length].isDigit()
    }

    companion object {
        private val FULL = Regex("""^(\d{2,3})_?([A-Z]\d?)$""")
        private val BATCH_ONLY = Regex("""^(\d{2,3})$""")

        fun parse(raw: String): StudentQuery? {
            val cleaned = raw.trim().uppercase().replace(" ", "")
            if (cleaned.isEmpty()) return null
            FULL.matchEntire(cleaned)?.let {
                return StudentQuery(it.groupValues[1], it.groupValues[2])
            }
            BATCH_ONLY.matchEntire(cleaned)?.let {
                return StudentQuery(it.groupValues[1], "")
            }
            return null
        }
    }
}
