package com.ababilx.routinescrapper

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.ui.Modifier
import com.ababilx.routinescrapper.ui.student.StudentScreen
import com.ababilx.routinescrapper.ui.theme.RdiuTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            RdiuTheme {
                Box(
                    Modifier
                        .fillMaxSize()
                        .systemBarsPadding(),
                ) {
                    StudentScreen()
                }
            }
        }
    }
}
