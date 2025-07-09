import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../models/todo_model.dart';


class TodoProvider extends ChangeNotifier {
  final List<TodoModel> _todos = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isInitialized = false;

  List<TodoModel> get todos => _todos;
  bool get isInitialized => _isInitialized;

  Future<void> initializeDatabase() async {
    if (_isInitialized) return;
    
    try {
      final todosFromDb = await _dbHelper.getAllTodos();
      _todos.clear();
      _todos.addAll(todosFromDb);
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing database: $e');
    }
  }

  Future<void> addTodo(TodoModel todo) async {
    try {
      await _dbHelper.insertTodo(todo);
      _todos.add(todo);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding todo: $e');
    }
  }

  Future<void> updateTodo(TodoModel updatedTodo) async {
    try {
      await _dbHelper.updateTodo(updatedTodo);
      final index = _todos.indexWhere((todo) => todo.id == updatedTodo.id);
      if (index != -1) {
        _todos[index] = updatedTodo;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating todo: $e');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _dbHelper.deleteTodo(id);
      _todos.removeWhere((todo) => todo.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting todo: $e');
    }
  }

  Future<void> toggleComplete(String id) async {
    try {
      final todoIndex = _todos.indexWhere((todo) => todo.id == id);
      if (todoIndex != -1) {
        final todo = _todos[todoIndex];
        final updatedTodo = todo.copyWith(
          isCompleted: !todo.isCompleted,
          completedAt: !todo.isCompleted ? DateTime.now() : null,
        );
        
        await _dbHelper.updateTodo(updatedTodo);
        _todos[todoIndex] = updatedTodo;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling todo completion: $e');
    }
  }

  List<TodoModel> getHistory() {
    return _todos.where((todo) => todo.isCompleted).toList();
  }
}