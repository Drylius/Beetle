import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:beetle/controllers/schedule_window_controller.dart';

class AdminScheduleWindowScreen extends StatefulWidget {
  const AdminScheduleWindowScreen({super.key});

  @override
  State<AdminScheduleWindowScreen> createState() =>
      _AdminScheduleWindowScreenState();
}

class _AdminScheduleWindowScreenState
    extends State<AdminScheduleWindowScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  final dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleWindowController>().loadWindow();
    });
  }

  Future<void> pickStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selected != null) {
      setState(() => _startDate = selected);

      if (_endDate != null && selected.isAfter(_endDate!)) {
        _endDate = selected;
      }
    }
  }

  Future<void> pickEndDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selected != null) {
      setState(() => _endDate = selected);
    }
  }

  Future<void> saveWindow() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap pilih tanggal mulai & akhir")),
      );
      return;
    }

    final ok = await context
        .read<ScheduleWindowController>()
        .updateWindow(_startDate!, _endDate!);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menyimpan jadwal")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Jadwal berhasil diperbarui")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ScheduleWindowController>();

    if (controller.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final window = controller.window;

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Pengaturan Jendela Pendaftaran"),
      //   backgroundColor: Colors.teal,
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 🔵 CURRENT WINDOW CARD
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: window == null
                    ? const Text(
                        "Belum ada jadwal aktif.\nSilakan buat jadwal baru.",
                        style: TextStyle(fontSize: 16),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Jadwal Saat Ini",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text("Mulai: ${dateFormat.format(window.startDate)}"),
                          Text("Akhir: ${dateFormat.format(window.endDate)}"),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // 🔵 UPDATE WINDOW CARD
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "Perbarui Jadwal Pendaftaran",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // START DATE PICKER
                    ListTile(
                      title: const Text("Tanggal Mulai"),
                      subtitle: Text(
                        _startDate == null
                            ? "Belum dipilih"
                            : dateFormat.format(_startDate!),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: pickStartDate,
                    ),

                    // END DATE PICKER
                    ListTile(
                      title: const Text("Tanggal Akhir"),
                      subtitle: Text(
                        _endDate == null
                            ? "Belum dipilih"
                            : dateFormat.format(_endDate!),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: pickEndDate,
                    ),

                    if (_startDate != null &&
                        _endDate != null &&
                        _endDate!.isBefore(_startDate!))
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          "Tanggal akhir tidak boleh sebelum tanggal mulai",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // SAVE BUTTON
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                      ),
                      onPressed: saveWindow,
                      child: const Text(
                        "Simpan Jadwal",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
