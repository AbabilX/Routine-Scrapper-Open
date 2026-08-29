package com.ababilx.routinescrapper.ui.student

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.ababilx.routinescrapper.data.PdfExporter
import com.ababilx.routinescrapper.ui.student.components.ClassTimeline
import com.ababilx.routinescrapper.ui.student.components.DateStrip
import com.ababilx.routinescrapper.ui.student.components.SearchRow
import com.ababilx.routinescrapper.ui.student.components.StudentHeader
import com.ababilx.routinescrapper.ui.student.components.SummaryCard
import com.ababilx.routinescrapper.ui.theme.Bg
import com.ababilx.routinescrapper.ui.theme.RdiuTypography
import com.ababilx.routinescrapper.ui.theme.TextMuted

@Composable
fun StudentScreen(
    viewModel: StudentViewModel = viewModel(),
) {
    val state by viewModel.state.collectAsState()
    val context = LocalContext.current

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Bg)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp, vertical = 16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
    ) {
        StudentHeader()
        SearchRow(
            query = state.queryText,
            department = state.meta?.department ?: "CSE",
            onQueryChange = viewModel::onQueryChange,
        )
        when {
            state.queryText.isBlank() -> Hint("ব্যাচ সার্চ করো — যেমন 68_C")
            state.invalidQuery -> Hint("ফরম্যাট: 68_C অথবা শুধু 68")
            !state.hasMatches -> Hint("এই ব্যাচের কোনো ক্লাস পাওয়া যায়নি")
            else -> {
                state.summary?.let { summary ->
                    SummaryCard(
                        summary = summary,
                        onDownload = { PdfExporter.share(context) },
                    )
                }
                DateStrip(
                    selected = state.selectedDay,
                    onSelect = viewModel::onDaySelected,
                    modifier = Modifier.fillMaxWidth(),
                )
                if (state.timeline.isEmpty()) {
                    Hint("এই দিনে ক্লাস নেই")
                } else {
                    ClassTimeline(state.timeline)
                }
            }
        }
        Spacer(Modifier.height(24.dp))
    }
}

@Composable
private fun Hint(text: String) {
    Text(text, style = RdiuTypography.bodyMedium, color = TextMuted)
}
