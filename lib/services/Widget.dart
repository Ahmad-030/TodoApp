import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/todo_model.dart';
import 'package:flutter/services.dart';

class WidgetService {
  static const platform = MethodChannel('com.example.todo_app/widget');

  static Future<void> initialize() async {
    print('Widget service initialized');
  }

  static Future<void> updateWidget(List<Todo> todos) async {
    try {
      // Save todos to SharedPreferences for widget to read
      final prefs = await SharedPreferences.getInstance();
      final jsonList = todos.map((todo) => todo.toJson()).toList();
      await prefs.setString('todos', jsonEncode(jsonList));

      // Notify Android widget to update
      try {
        await platform.invokeMethod('updateWidget');
      } catch (e) {
        print('Platform channel error: $e');
      }

      print('Widget updated successfully - ${todos.length} tasks');
    } catch (e) {
      print('Error updating widget: $e');
    }
  }
}