package com.ababilx.routinescrapper.domain.model

enum class ClassStatus {
    NOW,
    NEXT,
    LATER,
    DONE,
}

data class NowNextHint(
    val status: ClassStatus,
    val block: ClassBlock,
)
