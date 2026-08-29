package com.ababilx.routinescrapper.ui.student.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.unit.dp
import com.ababilx.routinescrapper.domain.model.RoutineDay
import com.ababilx.routinescrapper.ui.theme.Accent
import com.ababilx.routinescrapper.ui.theme.AccentDeep
import com.ababilx.routinescrapper.ui.theme.RdiuTypography
import com.ababilx.routinescrapper.ui.theme.SurfaceRaised
import com.ababilx.routinescrapper.ui.theme.TextMuted
import com.ababilx.routinescrapper.ui.theme.TextPrimary
import java.util.Calendar

data class DayChip(
    val day: RoutineDay,
    val date: Int,
)

@Composable
fun DateStrip(
    selected: RoutineDay,
    onSelect: (RoutineDay) -> Unit,
    modifier: Modifier = Modifier,
) {
    LazyRow(
        modifier = modifier,
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        items(weekChips(), key = { it.day }) { chip ->
            val active = chip.day == selected
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(16.dp))
                    .background(
                        if (active) {
                            Brush.verticalGradient(listOf(Accent, AccentDeep))
                        } else {
                            Brush.verticalGradient(listOf(SurfaceRaised, SurfaceRaised))
                        },
                    )
                    .clickable { onSelect(chip.day) }
                    .padding(horizontal = 14.dp, vertical = 10.dp),
                contentAlignment = Alignment.Center,
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        "${chip.date}",
                        style = RdiuTypography.titleMedium,
                        color = if (active) TextPrimary else TextMuted,
                    )
                    Text(
                        chip.day.shortLabel,
                        style = RdiuTypography.labelSmall,
                        color = if (active) TextPrimary else TextMuted,
                    )
                }
            }
        }
    }
}

fun weekChips(): List<DayChip> {
    val start = Calendar.getInstance()
    val daysFromSaturday =
        (start.get(Calendar.DAY_OF_WEEK) - Calendar.SATURDAY + 7) % 7
    start.add(Calendar.DAY_OF_YEAR, -daysFromSaturday)
    return RoutineDay.entries.mapIndexed { index, day ->
        val dayCal = start.clone() as Calendar
        dayCal.add(Calendar.DAY_OF_YEAR, index)
        DayChip(day, dayCal.get(Calendar.DAY_OF_MONTH))
    }
}
