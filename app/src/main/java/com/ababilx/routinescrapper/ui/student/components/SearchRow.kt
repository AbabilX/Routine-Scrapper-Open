package com.ababilx.routinescrapper.ui.student.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.unit.dp
import com.ababilx.routinescrapper.ui.icons.AppIcons
import com.ababilx.routinescrapper.ui.theme.Ink
import com.ababilx.routinescrapper.ui.theme.RdiuTypography
import com.ababilx.routinescrapper.ui.theme.Surface
import com.ababilx.routinescrapper.ui.theme.TextMuted

@Composable
fun SearchRow(
    query: String,
    onQueryChange: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .height(56.dp)
            .background(Surface, RoundedCornerShape(28.dp))
            .padding(horizontal = 18.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        Icon(
            imageVector = AppIcons.Search,
            contentDescription = null,
            tint = TextMuted,
            modifier = Modifier.size(22.dp),
        )
        BasicTextField(
            value = query,
            onValueChange = onQueryChange,
            singleLine = true,
            textStyle = RdiuTypography.bodyLarge,
            cursorBrush = SolidColor(Ink),
            modifier = Modifier.weight(1f),
            decorationBox = { inner ->
                if (query.isEmpty()) {
                    Text("68_C", style = RdiuTypography.bodyMedium)
                }
                inner()
            },
        )
    }
}
