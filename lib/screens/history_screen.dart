import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_street_light/theme_and_store.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Stream<List<Map<String, dynamic>>> _historyStream = Supabase.instance.client
      .from('streetlight_data')
      .stream(primaryKey: ['id'])
      .order('id', ascending: false);

  // Variables for Filter 
  String _timeFilter = 'All'; // 'All', 'Today', 'Week'
  String _statusFilter = 'All'; // 'All', 'ON', 'OFF'

  Color _getIndicatorColor(String rgbStatus) {
    if (rgbStatus.contains('GREEN')) return Colors.green;
    if (rgbStatus.contains('BLUE')) return Colors.blue;
    if (rgbStatus.contains('RED')) return Colors.red;
    return AppColors.primary;
  }

  // execute Filter Logic 
  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> originalLogs) {
    DateTime now = DateTime.now();
    DateTime todayStart = DateTime(now.year, now.month, now.day);
    DateTime weekStart = todayStart.subtract(const Duration(days: 7));

    return originalLogs.where((log) {
      // check Time Filter 
      if (log['created_at'] != null) {
        DateTime logTime = DateTime.parse(log['created_at']).toLocal();
        if (_timeFilter == 'Today' && logTime.isBefore(todayStart)) return false;
        if (_timeFilter == 'Week' && logTime.isBefore(weekStart)) return false;
      }

      // check Status Filter 
      final String streetStatus = log['streetStatus'] ?? 'OFF';
      if (_statusFilter == 'ON' && streetStatus != 'ON') return false;
      if (_statusFilter == 'OFF' && streetStatus != 'OFF') return false;

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('LOG HISTORY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: AppColors.bg,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Buttons Row 
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Time Filter Dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _timeFilter,
                        dropdownColor: AppColors.card,
                        style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w500),
                        icon: const Icon(Icons.calendar_today, size: 16, color: AppColors.textMuted),
                        items: ['All', 'Today', 'Week'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _timeFilter = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Status Filter Dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _statusFilter,
                        dropdownColor: AppColors.card,
                        style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w500),
                        icon: const Icon(Icons.lightbulb_outline, size: 18, color: AppColors.textMuted),
                        items: ['All', 'ON', 'OFF'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text("Street: $value"),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _statusFilter = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Log List View Area
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _historyStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No logs found.', style: TextStyle(color: AppColors.textMuted)));
                }

                // Filter Logic 
                final filteredLogs = _applyFilters(snapshot.data!);

                if (filteredLogs.isEmpty) {
                  return const Center(
                    child: Text('No logs match the selected filters.', style: TextStyle(color: AppColors.textMuted)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredLogs.length,
                  itemBuilder: (context, index) {
                    final log = filteredLogs[index];
                    final int intensity = log['intensity'] ?? 0;
                    final String streetStatus = log['streetStatus'] ?? 'OFF';
                    final String rgbStatus = log['rgbStatus'] ?? 'UNKNOWN';
                    
                    String time = 'N/A';

                    if (log['created_at'] != null) {
                      DateTime dateTime = DateTime.parse(log['created_at']).toLocal();

                      time =
                      "${dateTime.day}/${dateTime.month}/${dateTime.year}  "
                      "${dateTime.hour.toString().padLeft(2, '0')}:"
                      "${dateTime.minute.toString().padLeft(2, '0')}";
                    }

                    return Card(
                      color: AppColors.card,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getIndicatorColor(rgbStatus).withValues(alpha: 0.8),
                          child: Icon(
                            Icons.lightbulb, 
                            color: streetStatus == 'ON' ? Colors.amber : _getIndicatorColor(rgbStatus),
                          ),
                        ),
                        title: Text('Intensity: $intensity%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
                        subtitle: Text('Street: $streetStatus | RGB: $rgbStatus', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                        trailing: Text(time, style: const TextStyle(color: AppColors.textDim, fontSize: 12)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}