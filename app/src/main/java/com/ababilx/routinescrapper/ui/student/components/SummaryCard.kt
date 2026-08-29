package com.ababilx.routinescrapper.ui.student.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.unit.dp
import com.ababilx.routinescrapper.domain.model.StudentSummary
import com.ababilx.routinescrapper.ui.icons.AppIcons
import com.ababilx.routinescrapper.ui.theme.Accent
import com.ababilx.routinescrapper.ui.theme.Line
import com.ababilx.routinescrapper.ui.theme.RdiuTypography
import com.ababilx.routinescrapper.ui.theme.Surface
import com.ababilx.routinescrapper.ui.theme.TextMuted
import com.ababilx.routinescrapper.ui.theme.TextPrimary

@Composable
fun SummaryCard(
    summary: StudentSummary,
    onDownload: () -> Unit,
    modifier: Modifier = Modifier,
) {
    var expanded by rememberSaveable { mutableStateOf(true) }
    Surface(
        modifier = modifier.fillMaxWidth(),
        color = Surface,
        shape = RoundedCornerShape(20.dp),
    ) {
        Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { expanded = !expanded },
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text("Enrolled Courses", style = RdiuTypography.titleMedium, color = Accent)
                Icon(
                    imageVector = AppIcons.Expand,
                    contentDescription = null,
                    tint = TextMuted,
                    modifier = Modifier
                        .size(22.dp)
                        .rotate(if (expanded) 0f else -90f),
                )
            }
            AnimatedVisibility(visible = expanded) {
                Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    InfoGrid(summary)
                    HorizontalDivider(color = Line)
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable(onClick = onDownload)
                            .padding(vertical = 4.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Text(
                            "Download PDF for ${
                                if (summary.section == "All") summary.batch
                                else "${summary.batch}_${summary.section}"
                            }",
                            style = RdiuTypography.bodyMedium,
                            color = TextPrimary,
                        )
                        Icon(
                            imageVector = AppIcons.Download,
                            contentDescription = "Download PDF",
                            tint = Accent,
                            modifier = Modifier.size(20.dp),
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun InfoGrid(summary: StudentSummary) {
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            InfoCell("Batch", summary.batch, Modifier.weight(1f))
            InfoCell("Section", summary.section, Modifier.weight(1f))
        }
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            InfoCell("Total Courses", summary.totalCourses.toString(), Modifier.weight(1f))
            InfoCell("Routine", summary.routineVersion, Modifier.weight(1f))
        }
        InfoCell("Classes per Week", summary.classesPerWeek.toString())
    }
}

@Composable
private fun InfoCell(label: String, value: String, modifier: Modifier = Modifier) {
    Column(modifier = modifier, verticalArrangement = Arrangement.spacedBy(2.dp)) {
        Text(label, style = RdiuTypography.labelSmall)
        Text(value, style = RdiuTypography.bodyLarge, color = TextPrimary)
    }
}
