import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import '../models/todo_model.dart';

class WidgetService {
  static Future<void> updateWidget(List<Todo> todos) async {
    try {
      final pendingTodos = todos.where((t) => !t.isCompleted).toList();
      final pendingCount = pendingTodos.length;

      await HomeWidget.saveWidgetData<int>('pending_count', pendingCount);

      if (pendingTodos.isNotEmpty) {
        // Sort by due date to get the next task
        pendingTodos.sort((a, b) {
          final aDateTime = DateTime(
            a.dueDate.year,
            a.dueDate.month,
            a.dueDate.day,
            a.dueTime.hour,
            a.dueTime.minute,
          );
          final bDateTime = DateTime(
            b.dueDate.year,
            b.dueDate.month,
            b.dueDate.day,
            b.dueTime.hour,
            b.dueTime.minute,
          );
          return aDateTime.compareTo(bDateTime);
        });

        final nextTask = pendingTodos.first;
        await HomeWidget.saveWidgetData<String>('task_title', nextTask.title);

        // Format time manually without BuildContext
        final hour = nextTask.dueTime.hour;
        final minute = nextTask.dueTime.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        final timeString = '$hour12:$minute $period';

        await HomeWidget.saveWidgetData<String>(
          'task_time',
          'Due: ${DateFormat('MMM dd').format(nextTask.dueDate)} at $timeString',
        );
      } else {
        await HomeWidget.saveWidgetData<String>('task_title', 'No pending tasks');
        await HomeWidget.saveWidgetData<String>('task_time', 'All done! 🎉');
      }

      await HomeWidget.updateWidget(
        name: 'TodoWidgetProvider',
        androidName: 'TodoWidgetProvider',
      );
    } catch (e) {
      print('Error updating widget: $e');
    }
  }

  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId('com.example.todo_app');
  }
}