package com.ababilx.routinescrapper.ui.student.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.ababilx.routinescrapper.domain.RoutineQueries
import com.ababilx.routinescrapper.domain.model.ClassBlock
import com.ababilx.routinescrapper.domain.model.TimelineItem
import com.ababilx.routinescrapper.ui.theme.Accent
import com.ababilx.routinescrapper.ui.theme.BreakFill
import com.ababilx.routinescrapper.ui.theme.BreakStripe
import com.ababilx.routinescrapper.ui.theme.RdiuTypography
import com.ababilx.routinescrapper.ui.theme.Surface
import com.ababilx.routinescrapper.ui.theme.TeacherLink
import com.ababilx.routinescrapper.ui.theme.TextMuted
import com.ababilx.routinescrapper.ui.theme.TextPrimary

@Composable
fun ClassTimeline(
    items: List<TimelineItem>,
    modifier: Modifier = Modifier,
) {
    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(12.dp)) {
        items.forEach { item ->
            when (item) {
                is TimelineItem.Class -> ClassRow(item.block)
                is TimelineItem.Break -> BreakRow(item)
            }
        }
    }
}

@Composable
private fun ClassRow(block: ClassBlock) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(IntrinsicSize.Min),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        TimeRail(block.start, block.end)
        Surface(
            modifier = Modifier.weight(1f),
            color = Surface,
            shape = RoundedCornerShape(18.dp),
        ) {
            Column(
                Modifier.padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                Text(block.course, style = RdiuTypography.titleLarge, color = TextPrimary)
                Detail("Section", block.group)
                Detail("Teacher", block.teacher, valueColor = TeacherLink)
                Detail("Room", block.room)
            }
        }
    }
}

@Composable
private fun BreakRow(item: TimelineItem.Break) {
    val label = RoutineQueries.formatDuration(item.minutes)
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(56.dp)
            .clip(RoundedCornerShape(16.dp)),
    ) {
        Canvas(Modifier.matchParentSize()) {
            drawRect(BreakFill)
            val step = 18.dp.toPx()
            var x = -size.height
            while (x < size.width + size.height) {
                drawLine(
                    color = BreakStripe,
                    start = Offset(x, 0f),
                    end = Offset(x + size.height, size.height),
                    strokeWidth = 8.dp.toPx(),
                )
                x += step
            }
        }
        Text(
            "${item.start} – ${item.end}  ($label Break)",
            style = RdiuTypography.labelLarge,
            color = TextMuted,
            modifier = Modifier.align(Alignment.Center),
        )
    }
}

@Composable
private fun TimeRail(start: String, end: String) {
    Column(
        modifier = Modifier
            .width(52.dp)
            .fillMaxHeight(),
        horizontalAlignment = Alignment.End,
        verticalArrangement = Arrangement.SpaceBetween,
    ) {
        Text(start, style = RdiuTypography.labelSmall, color = Accent)
        Text(end, style = RdiuTypography.labelSmall, color = TextMuted)
    }
}

@Composable
private fun Detail(
    label: String,
    value: String,
    valueColor: Color = TextPrimary,
) {
    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        Text(label, style = RdiuTypography.labelSmall, modifier = Modifier.width(64.dp))
        Text(value, style = RdiuTypography.bodyMedium, color = valueColor)
    }
}
