package com.ababilx.routinescrapper.ui.student.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.unit.dp
import com.ababilx.routinescrapper.ui.theme.Lavender
import com.ababilx.routinescrapper.ui.theme.Mint
import com.ababilx.routinescrapper.ui.theme.Peach

@Composable
fun DecorBlobs(modifier: Modifier = Modifier) {
    Canvas(modifier.fillMaxSize()) {
        val mint = Mint.copy(alpha = 0.42f)
        val peach = Peach.copy(alpha = 0.38f)
        val lavender = Lavender.copy(alpha = 0.32f)
        drawCircle(mint, 160.dp.toPx(), Offset(size.width * 0.92f, 40.dp.toPx()))
        drawCircle(lavender, 130.dp.toPx(), Offset(-10.dp.toPx(), size.height * 0.42f))
        drawCircle(peach, 110.dp.toPx(), Offset(size.width * 0.88f, size.height * 0.78f))
    }
}
