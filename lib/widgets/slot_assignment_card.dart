// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/shuttle_slot_model.dart';
import '../../controllers/slot_assignment_controller.dart';
// import '../../repositories/slot_repository.dart';
// import 'package:provider/provider.dart';

class SlotAssignmentCard extends StatelessWidget {
  final ShuttleSlot slot;
  final List<Map<String, dynamic>> drivers;
  final bool editable;
  final SlotAssignmentController controller;
  final bool isSaving;

  const SlotAssignmentCard({
    super.key,
    required this.slot,
    required this.drivers,
    required this.editable,
    required this.controller,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    // Membuat list driver termasuk opsi "Clear Assignment"
    final driverItems = [
      const DropdownMenuItem<String?>(value: null, child: Text("Unassigned")),
      ...drivers.map(
        (d) => DropdownMenuItem<String>(
          value: d["id"].toString(),
          child: Text(d["name"]),
        ),
      ),
    ];
    
    // Bus options
    final busItems = [
      const DropdownMenuItem<String?>(value: null, child: Text("Unassigned")),
      "Bus Elf", "Bus 1", "Bus 2", 
    ].map((bus) {
      if (bus is String) {
        return DropdownMenuItem<String>(value: bus, child: Text(bus));
      }
      return bus as DropdownMenuItem<String?>;
    }).toList();


    // Cek apakah slot telah diubah dari nilai awal (atau dari null)
    final initialDriverId = slot.driverId; // Anggap nilai dari controller adalah nilai saat ini
    final initialBus = slot.bus; 
    
    // Dalam implementasi ini, kita berasumsi bahwa jika driverId atau bus diisi, 
    // berarti ada yang perlu disimpan.
    final changed = initialDriverId != null || initialBus != null;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ─────────────────────────────────────────────
            /// 🔵 SLOT HEADER
            /// ─────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    "${slot.route.originCampus.name} → ${slot.route.destinationCampus.name}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    slot.schedule.departureTime,
                    style: TextStyle(
                      color: Colors.deepPurple.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            /// Seats indicator
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Booked: ${slot.totalSeats - slot.availableSeats} / ${slot.totalSeats}",
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// ─────────────────────────────────────────────
            /// DRIVER Dropdown
            /// ─────────────────────────────────────────────
            const Text(
              "Driver",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),

            DropdownButtonFormField<String?>(
              value: slot.driverId,
              items: driverItems,
              onChanged: editable
                  ? (value) {
                      // ⭐️ Panggil method di Controller untuk update state
                      controller.updateSlotData(slot.id, value, slot.bus);
                    }
                  : null,
              decoration: InputDecoration(
                filled: true,
                fillColor: editable ? Colors.white : Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 18),

            /// ─────────────────────────────────────────────
            /// BUS Dropdown
            /// ─────────────────────────────────────────────
            const Text(
              "Bus",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),

            DropdownButtonFormField<String?>(
              value: slot.bus,
              items: busItems,
              onChanged: editable
                  ? (value) {
                      // ⭐️ Panggil method di Controller untuk update state
                      controller.updateSlotData(slot.id, slot.driverId, value);
                    }
                  : null,
              decoration: InputDecoration(
                filled: true,
                fillColor: editable ? Colors.white : Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ─────────────────────────────────────────────
            /// SAVE BUTTON
            /// ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: changed ? Colors.green : Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: changed ? 4 : 0,
                ),
                onPressed: editable && changed && !isSaving
                    ? () async {
                        final success = await controller.saveSlot(slot);

                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Slot updated successfully!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // ⭐️ Refresh data setelah save (opsional, tergantung kebutuhan)
                          controller.load(); 
                        } else if (!success && context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Failed to update slot."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    : null,
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        changed ? "Save Changes" : "No Changes",
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),

            if (!editable)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "Editing allowed only after 14:00",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}