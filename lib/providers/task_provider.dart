import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  // FIXED: The key prefix is constant, but the full key will append the username
  static const String _storageKeyPrefix = 'portfolio_tasks_key_';
  final String? _currentUsername;
  
  final List<TaskModel> _tasks = [];
  bool _isLoading = false;

  List<TaskModel> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;

  // The dynamic full key derived from the active username node
  String get _userStorageKey => '$_storageKeyPrefix${_currentUsername ?? "guest"}';

  // FIXED: Constructor now accepts the current logged-in username
  TaskProvider(this._currentUsername) {
    if (_currentUsername != null) {
      _loadTasksFromStorage();
    }
  }

  Future<void> _loadTasksFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      // FIXED: Uses user-specific storage slot
      final List<String>? serializedTasks = prefs.getStringList(_userStorageKey);

      _tasks.clear();
      if (serializedTasks != null) {
        for (final taskJson in serializedTasks) {
          _tasks.add(TaskModel.fromJson(taskJson));
        }
      }
    } catch (e) {
      debugPrint('Error loading user specific tasks: $e');
    } finally {
      _isLoading = false;
      if (hasListeners) notifyListeners();
    }
  }

  Future<void> _saveTasksToStorage() async {
    if (_currentUsername == null) return;
    final prefs = await SharedPreferences.getInstance();
    final List<String> serializedTasks = _tasks.map((task) => task.toJson()).toList();
    // FIXED: Commits only to this user's array track
    await prefs.setStringList(_userStorageKey, serializedTasks);
  }

  Future<void> addTask(TaskModel task) async {
    _tasks.add(task);
    notifyListeners();
    await _saveTasksToStorage();
  }

  Future<void> toggleTaskStatus(String id) async {
    final int index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final currentTask = _tasks[index];
      _tasks[index] = currentTask.copyWith(isCompleted: !currentTask.isCompleted);
      notifyListeners();
      await _saveTasksToStorage();
    }
  }

  Future<void> updateTask(TaskModel updatedTask) async {
    final int index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
      await _saveTasksToStorage();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
    await _saveTasksToStorage();
  }
}