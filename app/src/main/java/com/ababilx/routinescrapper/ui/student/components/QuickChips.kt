package com.ababilx.routinescrapper.ui.student.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.unit.dp
import com.ababilx.routinescrapper.ui.theme.Lavender
import com.ababilx.routinescrapper.ui.theme.Peach
import com.ababilx.routinescrapper.ui.theme.DIUTypography
import com.ababilx.routinescrapper.ui.theme.Sky

@Composable
fun QuickChips(
    chips: List<String>,
    onSelect: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    val haptic = LocalHapticFeedback.current
    val tints = listOf(Peach, Lavender, Sky, Peach.copy(alpha = 0.85f))

    AnimatedVisibility(
        visible = chips.isNotEmpty(),
        enter = fadeIn(),
        exit = fadeOut(),
        modifier = modifier,
    ) {
        LazyRow(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            items(chips, key = { it }) { chip ->
                val tint = tints[chip.hashCode().and(Int.MAX_VALUE) % tints.size]
                Text(
                    text = chip,
                    style = DIUTypography.labelLarge,
                    modifier = Modifier
                        .background(tint, RoundedCornerShape(22.dp))
                        .clickable {
                            haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                            onSelect(chip)
                        }
                        .padding(horizontal = 16.dp, vertical = 12.dp),
                )
            }
        }
    }
}
