import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_model.dart';

class StorageService {
  static late SharedPreferences _prefs;
  static const String _todosKey = 'todos';

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save todos
  static Future<void> saveTodos(List<Todo> todos) async {
    final jsonList = todos.map((todo) => todo.toJson()).toList();
    await _prefs.setString(_todosKey, jsonEncode(jsonList));
  }

  // Load todos
  static List<Todo> loadTodos() {
    final jsonString = _prefs.getString(_todosKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => Todo.fromJson(json as Map<String, dynamic>)).toList();
  }

  // Clear all todos
  static Future<void> clearTodos() async {
    await _prefs.remove(_todosKey);
  }
}