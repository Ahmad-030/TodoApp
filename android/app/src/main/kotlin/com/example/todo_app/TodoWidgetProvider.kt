package com.example.todo_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

class TodoWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        // Called when the widget needs to be updated
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.todo_widget)

            // Example content
            views.setTextViewText(R.id.pending_count, "3")
            views.setTextViewText(R.id.task_title, "Buy groceries")
            views.setTextViewText(R.id.task_time, "Today, 6:00 PM")

            // Apply the update
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
