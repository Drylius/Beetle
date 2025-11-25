import 'package:flutter/material.dart'; // for ChangeNotifier and debugPrint
// import 'package:provider/provider.dart';
import 'package:beetle/repositories/slot_repository.dart';
import '../../models/shuttle_slot_model.dart';

class SlotAssignmentController extends ChangeNotifier {
  final SlotRepository repo;

  SlotAssignmentController(this.repo);

  // Private state variables (conventionally prefixed with underscore)
  List<ShuttleSlot> _slots = [];
  List<Map<String, dynamic>> _drivers = [];
  bool _isLoading = true;
  bool _isSaving = false; // Added saving state for UI control
  bool _canEdit = false;

  // Public Getters to access the state
  List<ShuttleSlot> get slots => _slots;
  List<Map<String, dynamic>> get drivers => _drivers;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving; // Public getter for isSaving
  bool get canEdit => _canEdit;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    await loadDrivers();
    await loadSlots();

    _canEdit = canEditNow();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadDrivers() async {
    _drivers = await repo.getDrivers();
  }

  Future<void> loadSlots() async {
    final now = DateTime.now();
    // Assuming the intent is to load slots for tomorrow's schedule
    final tomorrow = now.add(const Duration(days: 1));

    final start = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    final end = start.add(const Duration(days: 1));

    final allSlots = await repo.getSlotsInRange(start, end);

    // Only keep slots that have at least one booking
    _slots = allSlots.where((s) => s.availableSeats < s.totalSeats).toList();
  }

  bool canEditNow() {
    // Editing allowed after 14:00 (2 PM)
    return DateTime.now().hour >= 4;
  }

  Future<bool> saveSlot(ShuttleSlot slot) async {
    _isSaving = true;
    notifyListeners(); // Show loading indicator in UI

    try {
      await repo.updateSlot(slot.id, slot.driverId, slot.bus);
      debugPrint('Slot ${slot.id} saved successfully.');
      return true;
    } catch (e) {
      debugPrint("Error saving slot ${slot.id}: $e");
      return false;
    } finally {
      _isSaving = false;
      notifyListeners(); // Hide loading indicator
    }
  }

  /// Updates the driverId and/or bus for a specific slot in the controller's local state.
  void updateSlotData(String slotId, String? newDriverId, String? newBus) {
    debugPrint('Updating slot $slotId: Driver=$newDriverId, Bus=$newBus');

    // 1. Find the index of the slot to update using the correct private variable _slots
    final index = _slots.indexWhere((slot) => slot.id == slotId);

    if (index != -1) {
      // 2. Get the existing slot
      final currentSlot = _slots[index];

      // 3. Create a new ShuttleSlot instance with the updated values (immutability).
      final updatedSlot = currentSlot.copyWith(
        driverId: newDriverId,
        bus: newBus,
      );

      // 4. Replace the old slot object with the new one in the list
      _slots[index] = updatedSlot;

      // 5. Notify listeners (the UI) to rebuild and display the new state
      notifyListeners();
      debugPrint('Slot $slotId state updated successfully in controller.');
    } else {
      debugPrint('Error: Slot with ID $slotId not found.');
    }
  }
}