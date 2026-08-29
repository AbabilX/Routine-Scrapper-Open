package com.ababilx.routinescrapper.data

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.studentDataStore by preferencesDataStore(name = "student_prefs")

/** Remembers the last valid batch search so reopen feels instant. */
class StudentPrefs(private val context: Context) {
    val lastQuery: Flow<String> = context.studentDataStore.data.map { prefs ->
        prefs[KEY_LAST_QUERY].orEmpty()
    }

    suspend fun saveQuery(query: String) {
        val cleaned = query.trim().uppercase()
        context.studentDataStore.edit { prefs ->
            if (cleaned.isEmpty()) {
                prefs.remove(KEY_LAST_QUERY)
            } else {
                prefs[KEY_LAST_QUERY] = cleaned
            }
        }
    }

    companion object {
        private val KEY_LAST_QUERY = stringPreferencesKey("last_query")
    }
}
