package com.ababilx.routinescrapper.ui.student

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.animation.togetherWith
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
import com.ababilx.routinescrapper.domain.model.ClassStatus
import com.ababilx.routinescrapper.domain.model.RoutineDay
import com.ababilx.routinescrapper.ui.student.components.ClassTimeline
import com.ababilx.routinescrapper.ui.student.components.DateStrip
import com.ababilx.routinescrapper.ui.student.components.DecorBlobs
import com.ababilx.routinescrapper.ui.student.components.EmptyHint
import com.ababilx.routinescrapper.ui.student.components.NextClassBanner
import com.ababilx.routinescrapper.ui.student.components.QuickChips
import com.ababilx.routinescrapper.ui.student.components.SearchRow
import com.ababilx.routinescrapper.ui.student.components.StudentHeader
import com.ababilx.routinescrapper.ui.student.components.SummaryCard
import com.ababilx.routinescrapper.ui.theme.Bg
import com.ababilx.routinescrapper.ui.theme.Lavender
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
                onQueryChange = viewModel::onQueryChange,
            )
            if (state.suggestions.isNotEmpty() &&
                (state.queryText.isBlank() || state.parsedQuery?.section.isNullOrEmpty())
            ) {
                QuickChips(
                    chips = state.suggestions,
                    onSelect = viewModel::onChipSelected,
                )
            }

            AnimatedContent(
                targetState = contentKey(state),
                transitionSpec = {
                    (fadeIn() + slideInVertically { it / 8 }) togetherWith
                        (fadeOut() + slideOutVertically { -it / 10 })
                },
                label = "studentBody",
            ) { key ->
                when (key) {
                    BodyKey.Blank -> EmptyHint(
                        title = "শুরু করো",
                        body = "ব্যাচ লিখো, অথবা নিচের চিপ ট্যাপ করো — যেমন 68_C",
                        tint = Peach,
                    )
                    BodyKey.Invalid -> EmptyHint(
                        title = "উফ, ফরম্যাট মিলেনি",
                        body = "চেষ্টা করো: 68_C  বা শুধু  68",
                        tint = Rose,
                    )
                    BodyKey.NoMatch -> EmptyHint(
                        title = "কেউ নেই",
                        body = "এই ব্যাচ/সেকশনের ক্লাস রুটিনে পাওয়া যায়নি — অন্য চিপ চেষ্টা করো",
                        tint = Sky,
                    )
                    BodyKey.Ready -> ReadyBody(
                        state = state,
                        onDaySelected = viewModel::onDaySelected,
                        onDownload = { PdfExporter.share(context) },
                    )
                }
            }
            Spacer(Modifier.height(28.dp))
        }
    }
}

@Composable
private fun ReadyBody(
    state: StudentUiState,
    onDaySelected: (RoutineDay) -> Unit,
    onDownload: () -> Unit,
) {
    Column(verticalArrangement = Arrangement.spacedBy(18.dp)) {
        DateStrip(
            selected = state.selectedDay,
            today = state.today,
            onSelect = onDaySelected,
            modifier = Modifier.fillMaxWidth(),
        )
        state.summary?.let { summary ->
            SummaryCard(summary = summary, onDownload = onDownload)
        }
        NextClassBanner(hint = state.nowNext)
        when {
            state.timeline.isEmpty() -> EmptyHint(
                title = "Off day",
                body = "এই দিনে ক্লাস নেই — অন্য দিনে তাকাও",
                tint = Mint,
            )
            state.selectedDay == state.today &&
                state.nowNext == null &&
                state.classStatuses.values.all { it == ClassStatus.DONE } -> {
                EmptyHint(
                    title = "দিন শেষ",
                    body = "আজকের সব ক্লাস হয়ে গেছে — কাল দেখা হবে",
                    tint = Lavender,
                )
                ClassTimeline(
                    items = state.timeline,
                    statuses = state.classStatuses,
                )
            }
            else -> ClassTimeline(
                items = state.timeline,
                statuses = state.classStatuses,
            )
        }
    }
}

private enum class BodyKey { Blank, Invalid, NoMatch, Ready }

private fun contentKey(state: StudentUiState): BodyKey = when {
    state.queryText.isBlank() -> BodyKey.Blank
    state.invalidQuery -> BodyKey.Invalid
    !state.hasMatches -> BodyKey.NoMatch
    else -> BodyKey.Ready
}
