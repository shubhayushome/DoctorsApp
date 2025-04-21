import 'dart:io';
//import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart' as ex;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'dart:async';
import 'package:pdf/widgets.dart' as pw;

import 'package:permission_handler/permission_handler.dart';

class HealthReportScreen extends StatefulWidget {
  final Map<String, dynamic> patientData;
  final String userId;

  const HealthReportScreen(
      {super.key, required this.userId, required this.patientData});

  @override
  _HealthReportScreenState createState() => _HealthReportScreenState();
}

class _HealthReportScreenState extends State<HealthReportScreen> {
  Map<String, dynamic> healthParameters = {};
  Map<String, dynamic> allData = {};
  //Timer? _timer;
  String selectedRange = '7D';
  final List<String> ranges = ['7D', '14D', '28D', '84D', '180D'];
  final GlobalKey _chartKey = GlobalKey();

  // List<FlSpot> get spots {
  //   return List.generate(
  //       widget.yValues.length, (i) => FlSpot(i.toDouble(), widget.yValues[i]));
  // }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    await fetchHealthData(); // Wait for data to be fetched
    filterDataByRange('7D'); // Then filter it
  }

  @override
  void dispose() {
    //_timer?.cancel();
    super.dispose();
  }

  void filterDataByRange(String range) {
    int days;
    switch (range) {
      case '7D':
        days = 7;
        break;
      case '14D':
        days = 14;
        break;
      case '28D':
        days = 30;
        break;
      case '84D':
        days = 84;
        break;
      case '180D':
        days = 180;
        break;
      default:
        days = 7;
    }

    final DateTime now = DateTime.now();
    final DateTime thresholdDate = now.subtract(Duration(days: days));

    // Check if timestamps exist
    if (allData['timestamp'] == null || allData['timestamp'].isEmpty) {
      setState(() {
        healthParameters = {}; // Or show error message
      });
      return;
    }

    // Convert timestamps
    List<DateTime> timestamps =
        List<DateTime>.from(allData['timestamp'].map((t) {
      if (t is String) return DateTime.parse(t);
      if (t is int) return DateTime.fromMillisecondsSinceEpoch(t);
      return t as DateTime;
    }));

    List<int> validIndices = [];

    for (int i = 0; i < timestamps.length; i++) {
      if (timestamps[i].isAfter(thresholdDate)) {
        validIndices.add(i);
      }
    }

    // Now build filtered map
    Map<String, dynamic> filteredData = {};

    for (String key in allData.keys) {
      var list = allData[key];
      if (list == null || list is! List) continue;

      filteredData[key] = validIndices.map((i) => list[i]).toList();
    }
    //print(filteredData);
    setState(() {
      //selectedRange = range;
      healthParameters = filteredData;
    });
  }

  Future<void> fetchHealthData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Patients_data')
          .doc(widget.userId)
          .get();
      if (snapshot.exists) {
        setState(() {
          allData = snapshot.get('health') ?? {};
          List<Map<String, dynamic>> combinedData = [];

          int length = allData['timestamp']?.length ?? 0;
          for (int i = 0; i < length; i++) {
            combinedData.add({
              'timestamp': allData['timestamp'][i],
              'session': allData['session'][i],
              'bp': allData['bp'][i],
              'pulse': allData['pulse'][i],
              'blood_sugar': allData['blood_sugar'][i],
              'oxygen': allData['oxygen'][i],
              'na+': allData['na+'][i],
              'haem': allData['haem'][i],
              'wbc_count': allData['wbc_count'][i],
            });
          }

          combinedData.sort((a, b) {
            int dateCompare = a['timestamp'].compareTo(b['timestamp']);
            if (dateCompare != 0) return dateCompare;
            if (a['session'] == b['session']) return 0;
            return a['session'] == 'Day' ? -1 : 1;
          });

          allData = {
            'timestamp': [],
            'session': [],
            'bp': [],
            'pulse': [],
            'blood_sugar': [],
            'oxygen': [],
            'na+': [],
            'haem': [],
            'wbc_count': [],
          };

          for (var entry in combinedData) {
            allData['timestamp'].add(entry['timestamp']);
            allData['session'].add(entry['session']);
            allData['bp'].add(entry['bp']);
            allData['pulse'].add(entry['pulse']);
            allData['blood_sugar'].add(entry['blood_sugar']);
            allData['oxygen'].add(entry['oxygen']);
            allData['na+'].add(entry['na+']);
            allData['haem'].add(entry['haem']);
            allData['wbc_count'].add(entry['wbc_count']);
          }
        });
        //print(allData);
      }
    } catch (e) {
      print("Error fetching health data: $e");
    }
  }

  DateTime getRangeStartDate() {
    int days = int.tryParse(selectedRange.replaceAll('D', '')) ?? 7;
    return DateTime.now().subtract(Duration(days: days));
  }

  Widget _buildHealthChart(String key, String label) {
    List timestamps = healthParameters['timestamp'];
    List values = healthParameters[key];
    List sessions = healthParameters['session'];

    List<double> allYValues = [];

    if (key == 'bp') {
      allYValues = values.expand<double>((bp) {
        List<String> parts = bp.split('/');
        return [double.tryParse(parts[0]) ?? 0, double.tryParse(parts[1]) ?? 0];
      }).toList();
    } else {
      allYValues = values
          .map<double>((v) => double.tryParse(v.toString()) ?? 0)
          .toList();
    }

    double maxY = (allYValues.reduce((a, b) => a > b ? a : b)) + 10;
    double minY = (allYValues.reduce((a, b) => a < b ? a : b)) - 10;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildLegendDot(Colors.green, 'Day'),
              const SizedBox(width: 8),
              _buildLegendDot(Colors.purple, 'Night'),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: 800,
              height: 300,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  titlesData: FlTitlesData(
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index < 0 || index >= timestamps.length)
                            return const SizedBox();
                          dynamic tsRaw = timestamps[index];
                          DateTime date;
                          if (tsRaw is Timestamp) {
                            date = tsRaw.toDate();
                          } else if (tsRaw is String) {
                            date = DateTime.tryParse(tsRaw) ?? DateTime.now();
                          } else {
                            date = DateTime.now();
                          }
                          return Text('${date.day}/${date.month}',
                              style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(color: Colors.black, width: 1),
                      bottom: BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  lineBarsData: key == 'bp'
                      ? _buildBpLines(values, sessions)
                      : [_buildSingleLine(values, sessions)],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.black.withOpacity(0.7),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((LineBarSpot spot) {
                          return LineTooltipItem(
                            spot.y.toStringAsFixed(1),
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  // No touch tooltips
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 20, height: 3, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  LineChartBarData _buildSingleLine(List values, List sessions) {
    List<FlSpot> spots = List.generate(values.length, (index) {
      double y = double.tryParse(values[index].toString()) ?? 0;
      return FlSpot(index.toDouble(), y);
    });

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: Colors.teal,
      barWidth: 3,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, _, __, ___) {
          String session = sessions[spot.x.toInt()];
          Color color = session == 'Day' ? Colors.green : Colors.purple;
          return FlDotCirclePainter(
            radius: 4,
            color: color,
            strokeWidth: 1,
            strokeColor: Colors.black,
          );
        },
      ),
      // Add value label at each point
      showingIndicators: [],
      belowBarData: BarAreaData(show: false),
      // spots: FlSpotLine(
      //   show: true,
      //   flSpotLine: (spot) => null, // Disable drop lines
      // ),
      // Custom tooltips rendered as static widgets on the graph
      // This trick uses `extraLinesData` to simulate always-visible values
    );
  }

  List<LineChartBarData> _buildBpLines(List bpValues, List sessions) {
    List<FlSpot> systolicSpots = [];
    List<FlSpot> diastolicSpots = [];

    for (int i = 0; i < bpValues.length; i++) {
      List<String> parts = bpValues[i].split('/');
      if (parts.length == 2) {
        double sys = double.tryParse(parts[0]) ?? 0;
        double dia = double.tryParse(parts[1]) ?? 0;
        systolicSpots.add(FlSpot(i.toDouble(), sys));
        diastolicSpots.add(FlSpot(i.toDouble(), dia));
      }
    }

    LineChartBarData createLine(List<FlSpot> spots, Color color) {
      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: 3,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, _, __, ___) {
            String session = sessions[spot.x.toInt()];
            Color sessionColor =
                session == 'Day' ? Colors.green : Colors.purple;
            return FlDotCirclePainter(
              radius: 4,
              color: sessionColor,
              strokeWidth: 1,
              strokeColor: Colors.black,
            );
          },
        ),
        showingIndicators: [],
        belowBarData: BarAreaData(show: false),
      );
    }

    return [
      createLine(systolicSpots, Colors.redAccent),
      createLine(diastolicSpots, Colors.blueAccent),
    ];
  }

  Future<void> _exportAsPDF() async {
    final pdf = pw.Document();

    // Define table headers
    final headers = [
      'Date',
      'Blood Pressure',
      'Blood Sugar',
      'Haemoglobin',
      'Oxygen Level',
      'Pulse',
      'Sodium',
      'WBC Count',
      'Session'
    ];

    try {
      // Build table rows
      final List<List<String>> dataRows = [];

      for (int i = 0; i < healthParameters['timestamp']?.length; i++) {
        dataRows.add([
          DateFormat('yyyy-MM-dd')
              .format(DateTime.parse(healthParameters['timestamp'][i])),
          '${healthParameters['bp'][i]}',
          '${healthParameters['blood_sugar'][i]}',
          '${healthParameters['haem'][i]}',
          '${healthParameters['oxygen'][i]}',
          '${healthParameters['pulse'][i]}',
          '${healthParameters['na+'][i]}',
          '${healthParameters['wbc_count'][i]}',
          '${healthParameters['session'][i]}',
        ]);
      }

      pdf.addPage(
        pw.MultiPage(
          build: (pw.Context context) => [
            pw.Text('Health Report', style: pw.TextStyle(fontSize: 22)),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: headers,
              data: dataRows,
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 10),
              columnWidths: {
                0: const pw.FixedColumnWidth(70), // Date
                1: const pw.FixedColumnWidth(80), // BP
                // customize others as needed
              },
            ),
          ],
        ),
      );

      final dir = Directory('/storage/emulated/0/Download');
      final file = File('${dir.path}/Health_Report.pdf');
      await file.writeAsBytes(await pdf.save());
      OpenFile.open(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF report downloaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting PDF')),
      );
      print('PDF Export Error: $e');
    }
  }

  Future<void> _exportAsExcel() async {
    final excel = ex.Excel.createExcel();
    final ex.Sheet sheet = excel['Sheet1'];
    sheet.appendRow([
      'Date',
      'Blood Pressure',
      'Blood Sugar',
      'Haemoglobin',
      'Oxygen Level',
      'Pulse',
      'Sodium',
      'WBC_COUNT',
      'Session'
    ]);

    for (int i = 0; i < healthParameters['timestamp']?.length; i++) {
      sheet.appendRow([
        DateFormat('yyyy-MM-dd')
            .format(DateTime.parse(healthParameters['timestamp'][i])),
        healthParameters['bp'][i],
        healthParameters['blood_sugar'][i],
        healthParameters['haem'][i],
        healthParameters['oxygen'][i],
        healthParameters['pulse'][i],
        healthParameters['na+'][i],
        healthParameters['wbc_count'][i],
        healthParameters['session'][i],
      ]);
    }

    final dir = Directory('/storage/emulated/0/Download');
    final file = File('${dir.path}/Report.xlsx');
    try {
      await file.writeAsBytes(excel.encode()!);
      OpenFile.open(file.path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excel report downloaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to downloaded Excel report')),
      );
    }
  }

  Future<void> _handleDownload(String? value) async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      // Use MANAGE_EXTERNAL_STORAGE for Android 11+
      if (await Permission.manageExternalStorage.isGranted == false) {
        status = await Permission.manageExternalStorage.request();
      } else {
        status = PermissionStatus.granted;
      }
    } else {
      status = await Permission.storage.request();
    }

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Storage permission denied. Please enable it in settings.')),
      );
      openAppSettings(); // Optional
      return;
    }

    if (value == 'pdf') {
      await _exportAsPDF();
    } else if (value == 'excel') {
      await _exportAsExcel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Health Chart'),
        actions: [
          DropdownButton<String>(
            hint: const Text("Download"),
            icon: const Icon(Icons.download),
            items: const [
              DropdownMenuItem(value: 'pdf', child: Text('PDF')),
              DropdownMenuItem(value: 'excel', child: Text('Excel')),
            ],
            onChanged: _handleDownload,
          )
        ],
      ),
      body: SizedBox(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Center(
                child: Text(
                  'Time-Series Graphs',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            Expanded(
              child: healthParameters['timestamp'] == null ||
                      healthParameters['timestamp'].isEmpty
                  ? const Center(
                      child: Text(
                      'No Records Available',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                    ))
                  : Scrollbar(
                      thumbVisibility: true,
                      child: ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          _buildHealthChart('bp', 'Blood Pressure'),
                          _buildHealthChart('pulse', 'Pulse'),
                          _buildHealthChart('blood_sugar', 'Blood Sugar'),
                          _buildHealthChart('oxygen', 'Oxygen Level'),
                          _buildHealthChart('na+', 'Sodium (Na+)'),
                          _buildHealthChart('haem', 'Haemoglobin'),
                          _buildHealthChart('wbc_count', 'WBC Count'),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.teal[100],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ranges.map((range) {
            bool isSelected = selectedRange == range;
            return GestureDetector(
              onTap: () {
                selectedRange = range;
                filterDataByRange(range);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.teal : Colors.white,
                  border: Border.all(
                    color: isSelected ? Colors.teal : Colors.grey,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.4),
                            spreadRadius: 1,
                            blurRadius: 8,
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  range,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
