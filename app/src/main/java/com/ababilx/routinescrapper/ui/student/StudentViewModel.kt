package com.ababilx.routinescrapper.ui.student

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import com.ababilx.routinescrapper.data.AssetRoutineRepository
import com.ababilx.routinescrapper.domain.RoutineQueries
import com.ababilx.routinescrapper.domain.StudentQuery
import com.ababilx.routinescrapper.domain.model.RoutineDay
import com.ababilx.routinescrapper.domain.model.RoutineMeta
import com.ababilx.routinescrapper.domain.model.StudentSummary
import com.ababilx.routinescrapper.domain.model.TimelineItem
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update

data class StudentUiState(
    val queryText: String = "",
    val parsedQuery: StudentQuery? = null,
    val selectedDay: RoutineDay = RoutineQueries.todayOrSaturday(),
    val summary: StudentSummary? = null,
    val timeline: List<TimelineItem> = emptyList(),
    val hasMatches: Boolean = false,
    val meta: RoutineMeta? = null,
    val invalidQuery: Boolean = false,
)

class StudentViewModel(application: Application) : AndroidViewModel(application) {
    private val repository = AssetRoutineRepository(application)

    private val _state = MutableStateFlow(
        StudentUiState(meta = repository.meta),
    )
    val state: StateFlow<StudentUiState> = _state

    fun onQueryChange(value: String) {
        val parsed = StudentQuery.parse(value)
        _state.update { current ->
            current.copy(
                queryText = value,
                parsedQuery = parsed,
                invalidQuery = value.isNotBlank() && parsed == null,
            )
        }
        rebuild()
    }

    fun onDaySelected(day: RoutineDay) {
        _state.update { it.copy(selectedDay = day) }
        rebuild()
    }

    private fun rebuild() {
        val parsed = _state.value.parsedQuery
        if (parsed == null) {
            _state.update { it.copy(summary = null, timeline = emptyList(), hasMatches = false) }
            return
        }
        val matched = RoutineQueries.forStudent(repository.slots, parsed)
        val daySlots = matched.filter { it.day == _state.value.selectedDay }
        _state.update {
            it.copy(
                summary = RoutineQueries.summary(matched, parsed, repository.meta.version),
                timeline = RoutineQueries.timeline(daySlots),
                hasMatches = matched.isNotEmpty(),
            )
        }
    }
}
