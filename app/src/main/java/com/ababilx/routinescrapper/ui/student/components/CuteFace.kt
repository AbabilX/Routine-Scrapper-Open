package com.ababilx.routinescrapper.ui.student.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.ababilx.routinescrapper.ui.theme.Ink
import com.ababilx.routinescrapper.ui.theme.Peach
import com.ababilx.routinescrapper.ui.theme.Surface

@Composable
fun CuteFace(
    modifier: Modifier = Modifier,
    size: Dp = 52.dp,
) {
    Box(
        modifier = modifier
            .size(size)
            .clip(CircleShape)
            .background(Peach),
    ) {
        Canvas(Modifier.matchParentSize()) {
            val w = this.size.width
            val h = this.size.height
            drawCircle(
                color = Surface,
                radius = w * 0.18f,
                center = Offset(w * 0.5f, h * 0.58f),
            )
            val eyeY = h * 0.42f
            val eyeR = w * 0.055f
            drawCircle(Ink, eyeR, Offset(w * 0.36f, eyeY))
            drawCircle(Ink, eyeR, Offset(w * 0.64f, eyeY))
            drawArc(
                color = Ink,
                startAngle = 20f,
                sweepAngle = 140f,
                useCenter = false,
                topLeft = Offset(w * 0.38f, h * 0.52f),
                size = Size(w * 0.24f, h * 0.18f),
                style = Stroke(width = w * 0.045f, cap = StrokeCap.Round),
            )
        }
    }
}
