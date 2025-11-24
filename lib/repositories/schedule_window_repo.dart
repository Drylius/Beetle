import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:beetle/models/schedule_window_model.dart';

class ScheduleWindowRepository {
  final FirebaseFirestore firestore;

  ScheduleWindowRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<ScheduleWindow?> getActiveWindow() async {
    final doc = await firestore
        .collection('app_config')
        .doc('schedule_window')
        .get();

    if (!doc.exists) return null;

    return ScheduleWindow.fromMap(doc.data()!);
  }

  Future<void> updateWindow(DateTime start, DateTime end) async {
    await firestore
        .collection('app_config')
        .doc('schedule_window')
        .set({
          'startDate': start,
          'endDate': end,
        });
  }
}
