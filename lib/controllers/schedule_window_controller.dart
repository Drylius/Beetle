import 'package:flutter/material.dart';
import 'package:beetle/repositories/schedule_window_repo.dart';
import 'package:beetle/models/schedule_window_model.dart';

class ScheduleWindowController extends ChangeNotifier {
  final ScheduleWindowRepository repo;

  ScheduleWindowController(this.repo);

  ScheduleWindow? window;
  bool loading = false;
  String state = "loading"; // loading | active | empty | error

  Future<void> loadWindow() async {
    loading = true;
    notifyListeners();

    try {
      window = await repo.getActiveWindow();

      if (window == null) {
        state = "empty";
      } else {
        state = "active";
      }
    } catch (e) {
      state = "error";
    }

    loading = false;
    notifyListeners();
  }

  Future<bool> updateWindow(DateTime start, DateTime end) async {
    try {
      await repo.updateWindow(start, end);
      await loadWindow();
      return true;
    } catch (e) {
      return false;
    }
  }
}
