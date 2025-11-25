// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import '../../models/shuttle_slot_model.dart';
import '../../controllers/slot_assignment_controller.dart';
import '../../repositories/slot_repository.dart';
import 'package:provider/provider.dart';
import 'package:beetle/widgets/slot_assignment_card.dart';


class AdminSlotAssignmentScreen extends StatefulWidget {
  const AdminSlotAssignmentScreen({super.key});

  @override
  State<AdminSlotAssignmentScreen> createState() =>
      _AdminSlotAssignmentScreenState();
}

class _AdminSlotAssignmentScreenState extends State<AdminSlotAssignmentScreen> {
  @override
  Widget build(BuildContext context) {
    // ⭐️ Sediakan Controller di atas UI Anda
    return ChangeNotifierProvider(
      create: (_) => SlotAssignmentController(SlotRepository())..load(),
      child: Scaffold(
        // appBar: AppBar(
        //   title: const Text("Assign Driver & Bus"),
        //   elevation: 1,
        //   backgroundColor: Colors.deepPurple,
        // ),
        // ⭐️ Consumer akan merebuild body ketika controller.notifyListeners() dipanggil
        body: Consumer<SlotAssignmentController>(
          builder: (context, controller, child) {
            
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final slots = controller.slots;
            final drivers = controller.drivers;
            final editable = controller.canEdit;

            if (slots.isEmpty) {
              return const Center(
                child: Text(
                  "No booked slots for tomorrow.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: slots.length,
              itemBuilder: (context, index) {
                final slot = slots[index];
                
                // Cek apakah slot ini perlu disimpan (misalnya, driver/bus telah diubah)
                // Catatan: Logika 'changed' lebih baik diimplementasikan di model
                // atau di controller, tapi kita akan gunakan cek sederhana.
                // bool changed = slot.driverId != null || slot.bus != null;


                return SlotAssignmentCard(
                  slot: slot,
                  drivers: drivers,
                  editable: editable,
                  controller: controller, // Pass controller down
                  isSaving: controller.isSaving,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
