package com.ababilx.routinescrapper.ui.student.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
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
import androidx.compose.ui.unit.dp
import com.ababilx.routinescrapper.domain.model.ClassStatus
import com.ababilx.routinescrapper.domain.model.NowNextHint
import com.ababilx.routinescrapper.ui.theme.Ink
import com.ababilx.routinescrapper.ui.theme.Mint
import com.ababilx.routinescrapper.ui.theme.DIUTypography
import com.ababilx.routinescrapper.ui.theme.Sky
import com.ababilx.routinescrapper.ui.theme.TextMuted

@Composable
fun NextClassBanner(
    hint: NowNextHint?,
    modifier: Modifier = Modifier,
) {
    AnimatedVisibility(
        visible = hint != null,
        enter = fadeIn() + slideInVertically { it / 3 },
        exit = fadeOut(),
        modifier = modifier,
    ) {
        val data = hint ?: return@AnimatedVisibility
        val isNow = data.status == ClassStatus.NOW
        Surface(
            modifier = Modifier.fillMaxWidth(),
            color = if (isNow) Mint else Sky,
            shape = RoundedCornerShape(28.dp),
        ) {
            Row(
                modifier = Modifier.padding(horizontal = 20.dp, vertical = 16.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween,
            ) {
                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text(
                        if (isNow) "এখন চলছে" else "পরের ক্লাস",
                        style = DIUTypography.labelSmall,
                        color = TextMuted,
                    )
                    Text(data.block.course, style = DIUTypography.titleLarge, color = Ink)
                }
                Column(horizontalAlignment = Alignment.End) {
                    Text(
                        "${data.block.start} – ${data.block.end}",
                        style = DIUTypography.labelLarge,
                    )
                    Text(data.block.room, style = DIUTypography.labelSmall, color = TextMuted)
                }
            }
        }
    }
}
