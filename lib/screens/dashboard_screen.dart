import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_street_light/theme_and_store.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Realtime Stream 
  final Stream<List<Map<String, dynamic>>> _dataStream = Supabase.instance.client
      .from('streetlight_data')
      .stream(primaryKey: ['id'])
      .order('id', ascending: false);

  String? _lastStreetStatus;
  
  // Refresh Mode 
  bool _isAutoRefresh = true; 
  List<Map<String, dynamic>>? _manualData; 
  bool _isManualLoading = false;

  @override
  void initState() {
    super.initState();
    if (!_isAutoRefresh) {
      _fetchManualData();
    }
  }

  // Manual Refresh 
  Future<void> _fetchManualData() async {
    setState(() {
      _isManualLoading = true;
    });
    try {
      final data = await Supabase.instance.client
          .from('streetlight_data')
          .select()
          .order('id', ascending: false);
      
      setState(() {
        _manualData = List<Map<String, dynamic>>.from(data);
        _isManualLoading = false;
      });
    } catch (e) {
      setState(() {
        _isManualLoading = false;
      });
      print("Manual Fetch Error: $e");
    }
  }

  Color _getIndicatorColor(String rgbStatus) {
    if (rgbStatus.contains('GREEN')) return Colors.green;
    if (rgbStatus.contains('BLUE')) return Colors.blue;
    if (rgbStatus.contains('RED')) return Colors.red;
    return AppColors.primary;
  }

  void _checkForAlert(BuildContext context, String currentStatus) {
    if (_lastStreetStatus != null && _lastStreetStatus != currentStatus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  currentStatus == "ON" ? Icons.lightbulb : Icons.lightbulb_outline,
                  color: currentStatus == "ON" ? Colors.amber : Colors.white70,
                ),
                const SizedBox(width: 12),
                Text(
                  "Street Light turned $currentStatus!",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: currentStatus == "ON" ? Colors.green.shade700 : Colors.blueGrey.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }
    _lastStreetStatus = currentStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('LUMEN DASHBOARD', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
        backgroundColor: AppColors.bg,
        elevation: 0,
        actions: [
          // 🎛️ Auto/Manual Toggle Switch
          Row(
            children: [
              Text(
                _isAutoRefresh ? "AUTO" : "MANUAL",
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
              ),
              Switch(
                value: _isAutoRefresh,
                activeColor: Colors.greenAccent,
                inactiveThumbColor: Colors.orangeAccent,
                onChanged: (value) {
                  setState(() {
                    _isAutoRefresh = value;
                    if (!_isAutoRefresh) {
                      _fetchManualData(); // Manual
                    }
                  });
                },
              ),
            ],
          ),
          
          // Manual Refresh Button 
          if (!_isAutoRefresh)
            IconButton(
              onPressed: _isManualLoading ? null : _fetchManualData,
              icon: _isManualLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber),
                    )
                  : const Icon(Icons.refresh, color: AppColors.text),
            ),

          // Log out Button
          IconButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/signin');
              }
            },
            icon: const Icon(Icons.logout, color: AppColors.textMuted),
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      body: _isAutoRefresh
          ? StreamBuilder<List<Map<String, dynamic>>>(
              stream: _dataStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3));
                }
                if (snapshot.hasError) return _buildErrorWidget(snapshot.error.toString());
                if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildNoDataWidget();

                return _buildDashboardContent(snapshot.data!);
              },
            )
          : (_isManualLoading && _manualData == null
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3))
              : (_manualData == null || _manualData!.isEmpty
                  ? _buildNoDataWidget()
                  : _buildDashboardContent(_manualData!))),
    );
  }

  Widget _buildDashboardContent(List<Map<String, dynamic>> allData) {
    final latestData = allData.first;
    
    final int intensity = latestData['intensity'] ?? 0;
    final String streetStatus = latestData['streetStatus']?.toString() ?? "OFF";
    final String rgbStatus = latestData['rgbStatus']?.toString() ?? "UNKNOWN";

    // Alert Logic 
    _checkForAlert(context, streetStatus);

    String timestamp = "N/A";
    if (latestData['created_at'] != null) {
      DateTime dateTime = DateTime.parse(latestData['created_at']).toLocal();
      timestamp =
          "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} "
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
    }

    final Color indicatorColor = _getIndicatorColor(rgbStatus);
    final bool isLightOn = streetStatus == "ON";

    return RefreshIndicator(
      onRefresh: () async {
        if (!_isAutoRefresh) await _fetchManualData();
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // -------- Light Intensity Card --------
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.card, AppColors.card.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "AMBIENT LIGHT",
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Icon(
                        Icons.wb_sunny_outlined,
                        color: indicatorColor.withValues(alpha: 0.8),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "$intensity%",
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: intensity / 100,
                      minHeight: 10,
                      backgroundColor: AppColors.bg,
                      valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // -------- Status Grid --------
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isLightOn ? Colors.amber.withValues(alpha: 0.3) : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isLightOn ? Colors.amber.withValues(alpha: 0.1) : AppColors.bg,
                            shape: BoxShape.circle,
                            boxShadow: isLightOn ? [
                              BoxShadow(
                                color: Colors.amber.withValues(alpha: 0.2),
                                blurRadius: 12,
                                spreadRadius: 2,
                              )
                            ] : [],
                          ),
                          child: Icon(
                            isLightOn ? Icons.lightbulb : Icons.lightbulb_outline,
                            color: isLightOn ? Colors.amber : AppColors.textMuted,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          "STREET LIGHT",
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          streetStatus,
                          style: TextStyle(
                            color: isLightOn ? Colors.amber : AppColors.text,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: indicatorColor.withValues(alpha: 0.4), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: indicatorColor,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          "RGB LED",
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rgbStatus,
                          style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // -------- Realtime / Historical Graph --------
            Container(
              padding: const EdgeInsets.all(20),
              height: 220,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 54, 68, 89),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isAutoRefresh ? "INTENSITY TREND (REALTIME)" : "INTENSITY TREND (CACHED)",
                    style: const TextStyle(
                      color: Color.fromARGB(255, 97, 135, 189),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false), 
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: allData.take(7).toList().reversed.map((data) {
                              int index = allData.take(7).toList().reversed.toList().indexOf(data);
                              double yVal = (data['intensity'] ?? 0).toDouble();
                              return FlSpot(index.toDouble(), yVal);
                            }).toList(),
                            isCurved: true,
                            barWidth: 3,
                            color: indicatorColor,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: indicatorColor.withValues(alpha: 0.15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // -------- Last Updated --------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history, color: AppColors.textDim, size: 16),
                const SizedBox(width: 6),
                Text(
                  "Last Updated: $timestamp",
                  style: const TextStyle(
                    color: Color.fromARGB(255, 169, 178, 191),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Error Widget
  Widget _buildErrorWidget(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Text(
          "Supabase Error:\n\n$error",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.redAccent, fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  // No Data Widget
  Widget _buildNoDataWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.gpp_bad_outlined, color: AppColors.textMuted, size: 48),
          SizedBox(height: 12),
          Text("No streetlight data received yet.", style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
        ],
      ),
    );
  }
}