package com.ababilx.routinescrapper.ui.student.components

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.ababilx.routinescrapper.ui.theme.DIUTypography
import com.ababilx.routinescrapper.ui.theme.TextMuted

@Composable
fun StudentHeader(modifier: Modifier = Modifier) {
    Row(
        modifier = modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(14.dp),
    ) {
        CuteFace()
        Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
            Text("Hello", style = DIUTypography.headlineSmall)
            Text("আজকের ক্লাস খুঁজে নাও", style = DIUTypography.labelSmall, color = TextMuted)
        }
    }
}
