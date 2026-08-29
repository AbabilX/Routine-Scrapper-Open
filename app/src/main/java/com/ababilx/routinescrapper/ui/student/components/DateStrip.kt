package com.ababilx.routinescrapper.ui.student.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.unit.dp
import com.ababilx.routinescrapper.domain.model.RoutineDay
import com.ababilx.routinescrapper.ui.theme.Ink
import com.ababilx.routinescrapper.ui.theme.Line
import com.ababilx.routinescrapper.ui.theme.Mint
import com.ababilx.routinescrapper.ui.theme.OnInk
import com.ababilx.routinescrapper.ui.theme.DIUTypography
import com.ababilx.routinescrapper.ui.theme.TextMuted
import java.util.Calendar

data class DayChip(
    val day: RoutineDay,
    val date: Int,
    val isToday: Boolean,
)

@Composable
fun DateStrip(
    selected: RoutineDay,
    today: RoutineDay,
    onSelect: (RoutineDay) -> Unit,
    modifier: Modifier = Modifier,
) {
    val chips = weekChips(today)
    val listState = rememberLazyListState()
    val haptic = LocalHapticFeedback.current

    LaunchedEffect(today) {
        val index = chips.indexOfFirst { it.isToday }.coerceAtLeast(0)
        listState.animateScrollToItem(index)
    }

    LazyRow(
        modifier = modifier,
        state = listState,
        horizontalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        items(chips, key = { it.day }) { chip ->
            val active = chip.day == selected
            val circleColor by animateColorAsState(
                targetValue = when {
                    active -> Ink
                    chip.isToday -> Mint
                    else -> Line.copy(alpha = 0.45f)
                },
                animationSpec = tween(220),
                label = "dayCircle",
            )
            Column(
                modifier = Modifier
                    .clip(RoundedCornerShape(22.dp))
                    .clickable {
                        haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
                        onSelect(chip.day)
                    }
                    .padding(horizontal = 4.dp, vertical = 2.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(6.dp),
            ) {
                Box(
                    modifier = Modifier
                        .size(48.dp)
                        .clip(CircleShape)
                        .background(circleColor)
                        .then(
                            if (chip.isToday && !active) {
                                Modifier.border(2.dp, Ink.copy(alpha = 0.25f), CircleShape)
                            } else {
                                Modifier
                            },
                        ),
                    contentAlignment = Alignment.Center,
                ) {
                    Text(
                        "${chip.date}",
                        style = DIUTypography.titleMedium,
                        color = if (active) OnInk else Ink,
                    )
                }
                Text(
                    if (chip.isToday) "আজ" else chip.day.shortLabel.uppercase(),
                    style = DIUTypography.labelSmall,
                    color = if (active || chip.isToday) Ink else TextMuted,
                )
            }
        }
    }
}

fun weekChips(today: RoutineDay = RoutineDay.SATURDAY): List<DayChip> {
    val start = Calendar.getInstance()
    val daysFromSaturday =
        (start.get(Calendar.DAY_OF_WEEK) - Calendar.SATURDAY + 7) % 7
    start.add(Calendar.DAY_OF_YEAR, -daysFromSaturday)
    return RoutineDay.entries.mapIndexed { index, day ->
        val dayCal = start.clone() as Calendar
        dayCal.add(Calendar.DAY_OF_YEAR, index)
        DayChip(day, dayCal.get(Calendar.DAY_OF_MONTH), isToday = day == today)
    }
}
