package com.ababilx.routinescrapper.ui.student

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
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
import com.ababilx.routinescrapper.ui.student.components.DecorBlobs
import com.ababilx.routinescrapper.ui.student.components.EmptyHint
import com.ababilx.routinescrapper.ui.student.components.SearchRow
import com.ababilx.routinescrapper.ui.student.components.StudentHeader
import com.ababilx.routinescrapper.ui.student.components.SummaryCard
import com.ababilx.routinescrapper.ui.theme.Bg
import com.ababilx.routinescrapper.ui.theme.Mint
import com.ababilx.routinescrapper.ui.theme.Peach
import com.ababilx.routinescrapper.ui.theme.Rose
import com.ababilx.routinescrapper.ui.theme.Sky

@Composable
fun StudentScreen(
    viewModel: StudentViewModel = viewModel(),
) {
    val state by viewModel.state.collectAsState()
    val context = LocalContext.current

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Bg),
    ) {
        DecorBlobs()
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 22.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(18.dp),
        ) {
            StudentHeader()
            SearchRow(
                query = state.queryText,
                department = state.meta?.department ?: "CSE",
                onQueryChange = viewModel::onQueryChange,
            )
            when {
                state.queryText.isBlank() -> EmptyHint(
                    title = "HELLO!",
                    body = "ব্যাচ লিখো — যেমন 68_C",
                    tint = Peach,
                )
                state.invalidQuery -> EmptyHint(
                    title = "উফ",
                    body = "ফরম্যাট: 68_C অথবা শুধু 68",
                    tint = Rose,
                )
                !state.hasMatches -> EmptyHint(
                    title = "খালি",
                    body = "এই ব্যাচের কোনো ক্লাস পাওয়া যায়নি",
                    tint = Sky,
                )
                else -> {
                    DateStrip(
                        selected = state.selectedDay,
                        onSelect = viewModel::onDaySelected,
                        modifier = Modifier.fillMaxWidth(),
                    )
                    state.summary?.let { summary ->
                        SummaryCard(
                            summary = summary,
                            onDownload = { PdfExporter.share(context) },
                        )
                    }
                    if (state.timeline.isEmpty()) {
                        EmptyHint(
                            title = "Off day",
                            body = "এই দিনে ক্লাস নেই",
                            tint = Mint,
                        )
                    } else {
                        ClassTimeline(state.timeline)
                    }
                }
            }
            Spacer(Modifier.height(28.dp))
        }
    }
}
