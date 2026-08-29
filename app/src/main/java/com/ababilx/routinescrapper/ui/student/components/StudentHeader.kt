package com.ababilx.routinescrapper.ui.student.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import com.ababilx.routinescrapper.ui.icons.AppIcons
import com.ababilx.routinescrapper.ui.theme.Accent
import com.ababilx.routinescrapper.ui.theme.RdiuTypography
import com.ababilx.routinescrapper.ui.theme.SurfaceRaised
import com.ababilx.routinescrapper.ui.theme.TextPrimary

@Composable
fun StudentHeader(modifier: Modifier = Modifier) {
    Row(
        modifier = modifier,
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        Box(
            modifier = Modifier
                .size(36.dp)
                .clip(CircleShape)
                .background(SurfaceRaised),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                imageVector = AppIcons.Student,
                contentDescription = null,
                tint = Accent,
                modifier = Modifier.size(20.dp),
            )
        }
        Text("Student", style = RdiuTypography.titleLarge, color = TextPrimary)
    }
}
