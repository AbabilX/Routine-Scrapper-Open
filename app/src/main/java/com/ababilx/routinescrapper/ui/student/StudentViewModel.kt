package com.ababilx.routinescrapper.ui.student

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.ababilx.routinescrapper.data.AssetRoutineRepository
import com.ababilx.routinescrapper.data.StudentPrefs
import com.ababilx.routinescrapper.domain.RoutineQueries
import com.ababilx.routinescrapper.domain.StudentQuery
import com.ababilx.routinescrapper.domain.model.ClassBlock
import com.ababilx.routinescrapper.domain.model.ClassStatus
import com.ababilx.routinescrapper.domain.model.NowNextHint
import com.ababilx.routinescrapper.domain.model.RoutineDay
import com.ababilx.routinescrapper.domain.model.RoutineMeta
import com.ababilx.routinescrapper.domain.model.StudentSummary
import com.ababilx.routinescrapper.domain.model.TimelineItem
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

data class StudentUiState(
    val queryText: String = "",
    val parsedQuery: StudentQuery? = null,
    val selectedDay: RoutineDay = RoutineQueries.todayOrSaturday(),
    val today: RoutineDay = RoutineQueries.todayOrSaturday(),
    val summary: StudentSummary? = null,
    val timeline: List<TimelineItem> = emptyList(),
    val classStatuses: Map<ClassBlock, ClassStatus> = emptyMap(),
    val nowNext: NowNextHint? = null,
    val suggestions: List<String> = emptyList(),
    val hasMatches: Boolean = false,
    val meta: RoutineMeta? = null,
    val invalidQuery: Boolean = false,
    val restored: Boolean = false,
)

class StudentViewModel(application: Application) : AndroidViewModel(application) {
    private val repository = AssetRoutineRepository(application)
    private val prefs = StudentPrefs(application)

    private val _state = MutableStateFlow(
        StudentUiState(
            meta = repository.meta,
            suggestions = RoutineQueries.suggestChips(repository.slots, ""),
        ),
    )
    val state: StateFlow<StudentUiState> = _state

    private var saveJob: Job? = null

    init {
        viewModelScope.launch {
            val saved = prefs.lastQuery.first()
            if (saved.isNotBlank()) {
                applyQuery(saved, persist = false)
            }
            _state.update { it.copy(restored = true) }
        }
        viewModelScope.launch {
            while (isActive) {
                delay(30_000)
                rebuild()
            }
        }
    }

    fun onQueryChange(value: String) {
        applyQuery(value, persist = true)
    }

    fun onChipSelected(chip: String) {
        applyQuery(chip, persist = true)
    }

    fun onDaySelected(day: RoutineDay) {
        _state.update { it.copy(selectedDay = day) }
        rebuild()
    }

    private fun applyQuery(value: String, persist: Boolean) {
        val parsed = StudentQuery.parse(value)
        _state.update { current ->
            current.copy(
                queryText = value,
                parsedQuery = parsed,
                invalidQuery = value.isNotBlank() && parsed == null,
                suggestions = RoutineQueries.suggestChips(repository.slots, value),
            )
        }
        rebuild()
        if (persist && parsed != null) {
            saveJob?.cancel()
            saveJob = viewModelScope.launch {
                delay(350)
                prefs.saveQuery(parsed.label)
            }
        }
    }

    private fun rebuild() {
        val today = RoutineQueries.todayOrSaturday()
        val parsed = _state.value.parsedQuery
        if (parsed == null) {
            _state.update {
                it.copy(
                    today = today,
                    summary = null,
                    timeline = emptyList(),
                    classStatuses = emptyMap(),
                    nowNext = null,
                    hasMatches = false,
                )
            }
            return
        }
        val matched = RoutineQueries.forStudent(repository.slots, parsed)
        val selectedDay = _state.value.selectedDay
        val daySlots = matched.filter { it.day == selectedDay }
        _state.update {
            it.copy(
                today = today,
                summary = RoutineQueries.summary(matched, parsed, repository.meta.version),
                timeline = RoutineQueries.timeline(daySlots),
                classStatuses = RoutineQueries.statusesForDay(daySlots, selectedDay, today),
                nowNext = RoutineQueries.nowOrNext(daySlots, selectedDay, today),
                hasMatches = matched.isNotEmpty(),
            )
        }
    }
}
