package com.ababilx.routinescrapper.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val LightColors = lightColorScheme(
    primary = Ink,
    onPrimary = OnInk,
    background = Bg,
    onBackground = Ink,
    surface = Surface,
    onSurface = Ink,
    surfaceVariant = Peach,
    onSurfaceVariant = TextMuted,
    outline = Line,
    secondary = Mint,
    tertiary = Lavender,
)

@Composable
fun DIUTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = LightColors,
        typography = DIUTypography,
        content = content,
    )
}
