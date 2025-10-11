import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo_model.dart';

class PendingTasksWidget extends StatelessWidget {
  final List<Todo> todos;
  final Function(Todo) onTodoTap;

  const PendingTasksWidget({
    Key? key,
    required this.todos,
    required this.onTodoTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final upcomingTodos = todos.where((t) => !t.isOverdue).take(3).toList();
    final overdueTodos = todos.where((t) => t.isOverdue).toList();

    if (upcomingTodos.isEmpty && overdueTodos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (overdueTodos.isNotEmpty) ...[
          _buildSectionHeader(
            'Overdue Tasks',
            overdueTodos.length,
            Colors.red,
            Icons.warning_amber_rounded,
          ),
          const SizedBox(height: 12),
          ...overdueTodos.map((todo) => _buildPendingTaskCard(context, todo, true)),
          const SizedBox(height: 20),
        ],
        if (upcomingTodos.isNotEmpty) ...[
          _buildSectionHeader(
            'Upcoming Tasks',
            upcomingTodos.length,
            const Color(0xFF2196F3),
            Icons.upcoming_rounded,
          ),
          const SizedBox(height: 12),
          ...upcomingTodos.map((todo) => _buildPendingTaskCard(context, todo, false)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingTaskCard(BuildContext context, Todo todo, bool isOverdue) {
    final hoursUntil = todo.hoursUntilDue;
    String timeText;

    if (isOverdue) {
      final hoursOverdue = -hoursUntil;
      if (hoursOverdue < 24) {
        timeText = '$hoursOverdue hours overdue';
      } else {
        timeText = '${hoursOverdue ~/ 24} days overdue';
      }
    } else if (todo.isDueToday) {
      timeText = 'Due today at ${todo.dueTime.format(context)}';
    } else if (hoursUntil < 24) {
      timeText = 'Due in $hoursUntil hours';
    } else {
      final days = hoursUntil ~/ 24;
      timeText = 'Due in $days day${days > 1 ? 's' : ''}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTodoTap(todo),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isOverdue
                    ? [Colors.red.shade50, Colors.red.shade100]
                    : todo.isDueToday
                    ? [Colors.orange.shade50, Colors.orange.shade100]
                    : [Colors.blue.shade50, Colors.blue.shade100],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isOverdue
                    ? Colors.red.withOpacity(0.3)
                    : todo.isDueToday
                    ? Colors.orange.withOpacity(0.3)
                    : Colors.blue.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isOverdue
                        ? Colors.red.withOpacity(0.2)
                        : todo.isDueToday
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isOverdue
                        ? Icons.error_outline
                        : todo.isDueToday
                        ? Icons.today
                        : Icons.schedule,
                    color: isOverdue
                        ? Colors.red.shade700
                        : todo.isDueToday
                        ? Colors.orange.shade700
                        : Colors.blue.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeText,
                        style: TextStyle(
                          fontSize: 13,
                          color: isOverdue
                              ? Colors.red.shade700
                              : todo.isDueToday
                              ? Colors.orange.shade700
                              : Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(todo.dueDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}