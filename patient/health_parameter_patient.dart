import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class HealthParameterScreen extends StatefulWidget {
  final Map<String, dynamic> patientData;
  final String userId;

  const HealthParameterScreen(
      {super.key, required this.userId, required this.patientData});

  @override
  _HealthParameterScreenState createState() => _HealthParameterScreenState();
}

class _HealthParameterScreenState extends State<HealthParameterScreen> {
  // Receiving patient data
  Map<String, dynamic> healthParameters = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //Timer? _timer;
  DateTime selectedDate = DateTime.now();
  bool isDayTime = true;

  @override
  void initState() {
    super.initState();
    fetchHealthData();
    // _timer = Timer.periodic(Duration(seconds: 10), (timer) {
    //   fetchHealthData();
    // });
  }

  @override
  void dispose() {
    //_timer?.cancel();
    super.dispose();
  }

  Future<void> fetchHealthData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Patients_data')
          .doc(widget.userId)
          .get();
      if (snapshot.exists) {
        setState(() {
          //print(healthParameters);
          healthParameters = snapshot.get('health') ?? {};
        });
      }
    } catch (e) {
      print("Error fetching health data: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime today = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: today.subtract(Duration(days: 180)),
      lastDate: today,
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _showCenteredPopup(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  void _showAddDataModal(BuildContext context) async {
    DateTime selectedDate2 = DateTime.now();
    bool isDay = true;
    TextEditingController bloodPressure = TextEditingController();
    TextEditingController pulse = TextEditingController();
    TextEditingController wbcCount = TextEditingController();
    TextEditingController bloodSugar = TextEditingController();
    TextEditingController haemoglobin = TextEditingController();
    TextEditingController oxygenLevel = TextEditingController();
    TextEditingController sodium = TextEditingController();

    Future<void> _submitData() async {
      final currentSession = isDay ? "Day" : "Night";
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate2);

      // Check for existing entry
      for (int i = 0; i < healthParameters['timestamp']?.length; i++) {
        if (healthParameters['timestamp']?[i] == formattedDate &&
            healthParameters['session']?[i] == currentSession) {
          // Entry already exists
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Data for this session already submitted.'),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
          return;
        }
      }
      RegExp bpPattern = RegExp(r'^\d{2,3}/\d{2,3}$');
      if (!bpPattern.hasMatch(bloodPressure.text)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Invalid Input"),
            content: const Text("Blood Pressure must be in the format x/y"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return;
      }

      List<MapEntry<String, TextEditingController>> fields = [
        MapEntry("Pulse", pulse),
        MapEntry("WBC Count", wbcCount),
        MapEntry("Blood Sugar", bloodSugar),
        MapEntry("Haemoglobin", haemoglobin),
        MapEntry("Oxygen Level", oxygenLevel),
        MapEntry("Na+/K+", sodium),
      ];

      for (var entry in fields) {
        if (entry.value.text.isEmpty ||
            double.tryParse(entry.value.text) == null) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Invalid Input"),
              content: Text("Please enter a valid number for ${entry.key}"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
          return;
        }
      }

      try {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          var patientRef =
              _firestore.collection('Patients_data').doc(widget.userId);

          await _firestore.runTransaction((transaction) async {
            var snapshot = await transaction.get(patientRef);

            Map<String, dynamic> data = snapshot.data()?['health'] ?? {};

            List<dynamic> getList(String key) => List.from(data[key] ?? []);

            transaction.update(patientRef, {
              'health.blood_sugar': [
                ...getList('blood_sugar'),
                double.tryParse(bloodSugar.text)
              ],
              'health.bp': [...getList('bp'), bloodPressure.text],
              'health.pulse': [
                ...getList('pulse'),
                double.tryParse(pulse.text)
              ],
              'health.na+': [...getList('na+'), double.tryParse(sodium.text)],
              'health.oxygen': [
                ...getList('oxygen'),
                double.tryParse(oxygenLevel.text)
              ],
              'health.haem': [
                ...getList('haem'),
                double.tryParse(haemoglobin.text)
              ],
              'health.wbc_count': [
                ...getList('wbc_count'),
                double.tryParse(wbcCount.text)
              ],
              'health.timestamp': [
                ...getList('timestamp'),
                DateFormat('yyyy-MM-dd').format(selectedDate2)
              ],
              'health.session': [
                ...getList('session'),
                isDay ? "Day" : "Night"
              ],
            });
          });
          //print(doctor['uid']);
        });

        if (!mounted) {
          if (!mounted) {
            _showCenteredPopup(context, "Something went wrong!");
            //Navigator.pop(context);
            return;
          }
        }
      } catch (e) {
        _showCenteredPopup(context, "Something went wrong!");
        //print("Error adding data: $e");
        return;
      }

      Navigator.pop(context);
      fetchHealthData();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: const Center(
            child: Text(
              'Add Record',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Date: ${DateFormat.yMMMMd().format(selectedDate2)}",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today, color: Colors.teal),
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate2,
                              firstDate:
                                  DateTime.now().subtract(Duration(days: 180)),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              setModalState(() {
                                selectedDate2 = pickedDate;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: bloodPressure,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                                labelText: "Blood Pressure (e.g. 120/80)"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: pulse,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: "Pulse"),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: wbcCount,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: "WBC Count"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: bloodSugar,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: "Blood Sugar"),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: haemoglobin,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: "Haemoglobin"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: oxygenLevel,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: "Oxygen Level"),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: sodium,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: "Na+/K+"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("N"),
                              Switch(
                                value: isDay,
                                onChanged: (value) {
                                  setModalState(() {
                                    isDay = value;
                                  });
                                },
                              ),
                              const Text("D"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                        ),
                        ElevatedButton(
                          onPressed: _submitData,
                          child: const Text("Submit"),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String getSafeValue(List<dynamic>? list, int index) {
    if (list != null &&
        index >= 0 &&
        index < list.length &&
        list[index] != null) {
      return list[index].toString();
    }
    return "--";
  }

  @override
  Widget build(BuildContext context) {
    int index = -1;

    try {
      // Check for timestamp/session presence and valid length
      if (healthParameters['timestamp'] != null &&
          healthParameters['session'] != null &&
          healthParameters['timestamp'].length ==
              healthParameters['session'].length) {
        for (int i = 0; i < healthParameters['timestamp'].length; i++) {
          final timestamp = healthParameters['timestamp'][i];
          final session = healthParameters['session'][i];

          if (timestamp == null || session == null) continue;

          DateTime recordDate = DateTime.tryParse(timestamp) ?? DateTime(1900);
          bool dateMatch = recordDate.year == selectedDate.year &&
              recordDate.month == selectedDate.month &&
              recordDate.day == selectedDate.day;
          bool sessionMatch = session == (isDayTime ? "Day" : "Night");

          if (dateMatch && sessionMatch) {
            index = i;
            break;
          }
        }
      }
    } catch (e) {
      index = -1;
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 145, 162, 235),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 26, 26, 156),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: GestureDetector(
          onTap: () => _selectDate(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('yyyy-MM-dd').format(selectedDate),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.calendar_today, color: Colors.white, size: 20),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              Text(isDayTime ? "Day" : "Night",
                  style: const TextStyle(color: Colors.white)),
              Switch(
                activeColor: Colors.orangeAccent,
                value: isDayTime,
                onChanged: (value) => setState(() => isDayTime = value),
              ),
            ],
          ),
        ],
      ),
      body: index == -1
          ? const Center(
              child: Text(
                "No Records Present",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Session: ${healthParameters['session'][index]}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Timestamp: ${healthParameters['timestamp'][index]}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ParameterCard(
                        parameterName: "Blood Pressure",
                        value: getSafeValue(healthParameters['bp'], index),
                        unit: "mmHg",
                        icon: Icons.favorite,
                        color: Colors.redAccent,
                      ),
                      ParameterCard(
                        parameterName: "Pulse",
                        value: getSafeValue(healthParameters['pulse'], index),
                        unit: "bpm",
                        icon: Icons.favorite_rounded,
                        color: Colors.pinkAccent,
                      ),
                      ParameterCard(
                        parameterName: "Oxygen Level",
                        value: getSafeValue(healthParameters['oxygen'], index),
                        unit: "%",
                        icon: Icons.bubble_chart,
                        color: Colors.blueAccent,
                      ),
                      ParameterCard(
                        parameterName: "Na+/K+ Level",
                        value: getSafeValue(healthParameters['na+'], index),
                        unit: "mmol/L",
                        icon: Icons.water_drop,
                        color: Colors.teal,
                      ),
                      ParameterCard(
                        parameterName: "Hemoglobin Level",
                        value: getSafeValue(healthParameters['haem'], index),
                        unit: "g/dL",
                        icon: Icons.bloodtype,
                        color: Colors.deepOrangeAccent,
                      ),
                      ParameterCard(
                        parameterName: "Blood Sugar Level",
                        value: getSafeValue(
                            healthParameters['blood_sugar'], index),
                        unit: "mg/dL",
                        icon: Icons.spa,
                        color: Colors.green,
                      ),
                      ParameterCard(
                        parameterName: "WBC & RBC Count",
                        value:
                            getSafeValue(healthParameters['wbc_count'], index),
                        unit: "million/mL",
                        icon: Icons.invert_colors,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => _showAddDataModal(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class ParameterCard extends StatelessWidget {
  final String parameterName;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const ParameterCard({
    super.key,
    required this.parameterName,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width *
          0.45, // Set to 45% width of the screen
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(height: 10),
          Text(
            parameterName,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "$value $unit",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
