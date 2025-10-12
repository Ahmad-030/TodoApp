package com.example.todo_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

class TodoWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (widgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, widgetId)
        }
    }

    companion object {
        fun updateWidget(context: Context, appWidgetManager: AppWidgetManager, widgetId: Int) {
            val views = RemoteViews(context.packageName, R.layout.todo_widget)

            try {
                val prefs: SharedPreferences = context.getSharedPreferences(
                    "FlutterSharedPreferences",
                    Context.MODE_PRIVATE
                )

                // Read todos from SharedPreferences
                val todosJson = prefs.getString("flutter.todos", null)

                if (todosJson != null && todosJson.isNotEmpty()) {
                    val todosArray = JSONArray(todosJson)

                    // Count pending tasks
                    var pendingCount = 0
                    var nextTask: JSONObject? = null
                    var nextTaskTime: Long = Long.MAX_VALUE

                    for (i in 0 until todosArray.length()) {
                        val todo = todosArray.getJSONObject(i)
                        val isCompleted = todo.optBoolean("isCompleted", false)

                        if (!isCompleted) {
                            pendingCount++

                            // Find the next upcoming task
                            val dueDateStr = todo.optString("dueDate", "")
                            if (dueDateStr.isNotEmpty()) {
                                try {
                                    val dueDate = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
                                        .parse(dueDateStr.substring(0, 19))

                                    if (dueDate != null && dueDate.time < nextTaskTime && dueDate.time > System.currentTimeMillis()) {
                                        nextTaskTime = dueDate.time
                                        nextTask = todo
                                    }
                                } catch (e: Exception) {
                                    e.printStackTrace()
                                }
                            }
                        }
                    }

                    // Update widget UI
                    views.setTextViewText(R.id.pending_count, "$pendingCount pending tasks")

                    if (nextTask != null) {
                        val title = nextTask.optString("title", "No upcoming tasks")
                        val hour = nextTask.optInt("dueTimeHour", 9)
                        val minute = nextTask.optInt("dueTimeMinute", 0)
                        val timeStr = String.format(Locale.getDefault(), "%02d:%02d", hour, minute)

                        views.setTextViewText(R.id.task_title, title)
                        views.setTextViewText(R.id.task_time, "Next: $timeStr")
                    } else {
                        views.setTextViewText(R.id.task_title, "No upcoming tasks")
                        views.setTextViewText(R.id.task_time, "All caught up!")
                    }
                } else {
                    // No tasks
                    views.setTextViewText(R.id.pending_count, "0 pending tasks")
                    views.setTextViewText(R.id.task_title, "No tasks")
                    views.setTextViewText(R.id.task_time, "Add a task to get started")
                }

            } catch (e: Exception) {
                e.printStackTrace()
                // Error handling
                views.setTextViewText(R.id.pending_count, "Error loading tasks")
                views.setTextViewText(R.id.task_title, "Please open the app")
                views.setTextViewText(R.id.task_time, "")
            }

            // Update the widget
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}