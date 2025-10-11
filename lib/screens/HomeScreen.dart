import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo_model.dart';
import '../services/Storage Service.dart';

import '../services/notification_service.dart';
import '../widgets/add_todo.dart';
import '../widgets/todo_card.dart';
import '../widgets/stats_card.dart';
import 'Setting_Screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Todo> _todos = [];
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadTodos();
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _loadTodos() {
    setState(() {
      _todos = StorageService.loadTodos();
    });
  }

  void _saveTodos() {
    StorageService.saveTodos(_todos);
  }

  void _addTodo(String title, String description, DateTime dueDate) {
    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      notificationId: notificationId,
    );

    setState(() {
      _todos.insert(0, todo);
    });

    NotificationService.scheduleNotification(todo);
    _saveTodos();
  }

  void _editTodo(String id, String title, String description, DateTime dueDate) {
    setState(() {
      final index = _todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        _todos[index] = _todos[index].copyWith(
          title: title,
          description: description,
          dueDate: dueDate,
        );
        NotificationService.scheduleNotification(_todos[index]);
      }
    });
    _saveTodos();
  }

  void _toggleTodo(String id) {
    setState(() {
      final todo = _todos.firstWhere((t) => t.id == id);
      todo.isCompleted = !todo.isCompleted;
      if (todo.isCompleted && todo.notificationId != null) {
        NotificationService.cancelNotification(todo.notificationId!);
      } else if (!todo.isCompleted && todo.notificationId != null) {
        NotificationService.scheduleNotification(todo);
      }
    });
    _saveTodos();
  }

  void _deleteTodo(String id) {
    final todo = _todos.firstWhere((t) => t.id == id);
    if (todo.notificationId != null) {
      NotificationService.cancelNotification(todo.notificationId!);
    }
    setState(() {
      _todos.removeWhere((t) => t.id == id);
    });
    _saveTodos();
  }

  void _showAddTodoDialog({Todo? editTodo}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTodoDialog(
        editTodo: editTodo,
        onSave: (title, description, dueDate) {
          if (editTodo == null) {
            _addTodo(title, description, dueDate);
          } else {
            _editTodo(editTodo.id, title, description, dueDate);
          }
        },
      ),
    );
  }

  void _showTodoDetails(Todo todo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      todo.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Due: ${DateFormat('MMM dd, yyyy').format(todo.dueDate)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                todo.description.isEmpty ? 'No description' : todo.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddTodoDialog(editTodo: todo);
                    },
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteTodo(todo.id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedTodos = _todos.where((t) => t.isCompleted).length;
    final pendingTodos = _todos.length - completedTodos;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('My Tasks'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF673AB7), Color(0xFF9C27B0)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            StatsCard(
                              label: 'Pending',
                              count: pendingTodos,
                              icon: Icons.pending_actions,
                            ),
                            StatsCard(
                              label: 'Completed',
                              count: completedTodos,
                              icon: Icons.check_circle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: _todos.isEmpty
                ? SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 100,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tasks yet',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to add a new task',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            )
                : SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final todo = _todos[index];
                  return TweenAnimationBuilder(
                    duration: Duration(
                      milliseconds: 200 + (index * 50),
                    ),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Opacity(
                          opacity: value,
                          child: TodoCard(
                            todo: todo,
                            onToggle: () => _toggleTodo(todo.id),
                            onTap: () => _showTodoDetails(todo),
                            onDelete: () => _deleteTodo(todo.id),
                          ),
                        ),
                      );
                    },
                  );
                },
                childCount: _todos.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _fabController,
            curve: Curves.elasticOut,
          ),
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddTodoDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Add Task'),
        ),
      ),
    );
  }
}