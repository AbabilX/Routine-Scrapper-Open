package com.ababilx.routinescrapper.ui.student.components

import androidx.compose.animation.animateContentSize
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import com.ababilx.routinescrapper.domain.RoutineQueries
import com.ababilx.routinescrapper.domain.model.ClassBlock
import com.ababilx.routinescrapper.domain.model.ClassStatus
import com.ababilx.routinescrapper.domain.model.TimelineItem
import com.ababilx.routinescrapper.ui.icons.AppIcons
import com.ababilx.routinescrapper.ui.theme.CardPastels
import com.ababilx.routinescrapper.ui.theme.Ink
import com.ababilx.routinescrapper.ui.theme.Mint
import com.ababilx.routinescrapper.ui.theme.RdiuTypography
import com.ababilx.routinescrapper.ui.theme.Sky
import com.ababilx.routinescrapper.ui.theme.TextMuted

@Composable
fun ClassTimeline(
    items: List<TimelineItem>,
    statuses: Map<ClassBlock, ClassStatus> = emptyMap(),
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier.animateContentSize(tween(280)),
        verticalArrangement = Arrangement.spacedBy(14.dp),
    ) {
        var classIndex = 0
        items.forEach { item ->
            when (item) {
                is TimelineItem.Class -> {
                    val status = statuses[item.block] ?: ClassStatus.LATER
                    ClassCard(
                        block = item.block,
                        tint = CardPastels[classIndex % CardPastels.size],
                        status = status,
                    )
                    classIndex += 1
                }
                is TimelineItem.Break -> BreakChip(item)
            }
        }
    }
}

@Composable
private fun ClassCard(
    block: ClassBlock,
    tint: Color,
    status: ClassStatus,
) {
    val faded = status == ClassStatus.DONE
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .alpha(if (faded) 0.55f else 1f),
        color = tint,
        shape = RoundedCornerShape(32.dp),
    ) {
        Column(
            Modifier.padding(horizontal = 22.dp, vertical = 20.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(block.course, style = RdiuTypography.headlineSmall)
                StatusPill(status)
            }
            MetaRow(AppIcons.Time, "${block.start}  –  ${block.end}")
            MetaRow(AppIcons.Room, block.room)
            Text(block.teacher, style = RdiuTypography.titleMedium)
            Text("Section ${block.group}", style = RdiuTypography.labelSmall)
        }
    }
}

@Composable
private fun StatusPill(status: ClassStatus) {
    val (label, color) = when (status) {
        ClassStatus.NOW -> "এখন" to Mint
        ClassStatus.NEXT -> "পরের" to Sky
        ClassStatus.DONE -> "শেষ" to Ink.copy(alpha = 0.18f)
        ClassStatus.LATER -> return
    }
    Surface(color = color, shape = RoundedCornerShape(14.dp)) {
        Text(
            label,
            style = RdiuTypography.labelSmall,
            color = if (status == ClassStatus.DONE) TextMuted else Ink,
            modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp),
        )
    }
}

@Composable
private fun BreakChip(item: TimelineItem.Break) {
    val label = RoutineQueries.formatDuration(item.minutes)
    Surface(
        modifier = Modifier.fillMaxWidth(),
        color = Mint.copy(alpha = 0.55f),
        shape = RoundedCornerShape(22.dp),
    ) {
        Text(
            "$label break  ·  ${item.start} – ${item.end}",
            style = RdiuTypography.labelLarge,
            modifier = Modifier.padding(horizontal = 18.dp, vertical = 12.dp),
        )
    }
}

@Composable
private fun MetaRow(icon: ImageVector, text: String) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Icon(icon, contentDescription = null, tint = Ink, modifier = Modifier.size(18.dp))
        Text(text, style = RdiuTypography.bodyLarge, color = TextMuted)
    }
}
