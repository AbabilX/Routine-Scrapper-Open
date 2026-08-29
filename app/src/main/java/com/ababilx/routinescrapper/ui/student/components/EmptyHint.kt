package com.ababilx.routinescrapper.ui.student.components

import androidx.compose.animation.animateContentSize
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.ababilx.routinescrapper.ui.theme.Lavender
import com.ababilx.routinescrapper.ui.theme.RdiuTypography
import com.ababilx.routinescrapper.ui.theme.TextMuted

@Composable
fun EmptyHint(
    title: String,
    body: String,
    tint: Color = Lavender,
    faceSize: Dp = 44.dp,
    modifier: Modifier = Modifier,
) {
    Surface(
        modifier = modifier
            .fillMaxWidth()
            .animateContentSize(),
        color = tint,
        shape = RoundedCornerShape(32.dp),
    ) {
        Row(
            Modifier.padding(22.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(14.dp),
        ) {
            CuteFace(size = faceSize)
            Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                Text(title, style = RdiuTypography.titleLarge)
                Text(body, style = RdiuTypography.bodyMedium, color = TextMuted)
            }
        }
    }
}
