package com.ababilx.routinescrapper.ui.student.components

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.ababilx.routinescrapper.domain.model.StudentSummary
import com.ababilx.routinescrapper.ui.icons.AppIcons
import com.ababilx.routinescrapper.ui.theme.Ink
import com.ababilx.routinescrapper.ui.theme.OnInk
import com.ababilx.routinescrapper.ui.theme.Peach
import com.ababilx.routinescrapper.ui.theme.RdiuTypography
import com.ababilx.routinescrapper.ui.theme.TextMuted

@Composable
fun SummaryCard(
    summary: StudentSummary,
    onDownload: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val title = if (summary.section == "All") summary.batch else "${summary.batch}  ${summary.section}"
    Surface(
        modifier = modifier.fillMaxWidth(),
        color = Peach,
        shape = RoundedCornerShape(32.dp),
    ) {
        Row(
            modifier = Modifier.padding(22.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween,
        ) {
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(6.dp),
            ) {
                Text(title, style = RdiuTypography.headlineSmall)
                Text(
                    "${summary.totalCourses} courses  ·  ${summary.classesPerWeek} classes",
                    style = RdiuTypography.bodyMedium,
                    color = TextMuted,
                )
            }
            Surface(
                modifier = Modifier
                    .size(52.dp)
                    .clickable(onClick = onDownload),
                color = Ink,
                shape = CircleShape,
            ) {
                Icon(
                    imageVector = AppIcons.Download,
                    contentDescription = "Download PDF",
                    tint = OnInk,
                    modifier = Modifier.padding(14.dp),
                )
            }
        }
    }
}
