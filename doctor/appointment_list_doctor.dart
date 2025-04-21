import 'package:doctors_app/patient/patient_auth_logic.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AppointmentsListScreen extends StatefulWidget {
  final Map<String, dynamic> patientData; // Receiving patient data
  final Map<String, dynamic> doctorData;
  final String userId;
  const AppointmentsListScreen(
      {super.key,
      required this.patientData,
      required this.userId,
      required this.doctorData});
  @override
  _AppointmentsListScreenState createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen> {
  List<Map<String, dynamic>>? appointments = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      var patientDoc =
          await _firestore.collection('Patients_data').doc(widget.userId).get();
      if (!mounted) return;
      setState(() {
        appointments = List<Map<String, dynamic>>.from(
            patientDoc.data()?['appointments'] ?? []);
      });
    } catch (e) {
      print("Error fetching doctors: $e");
    }
  }

  Future<void> _addAppointment(Map<String, dynamic>? appointment) async {
    try {
      await _firestore.runTransaction((transaction) async {
        var patientRef =
            _firestore.collection('Patients_data').doc(widget.userId);
        print(patientRef);
        transaction.update(patientRef, {
          'appointments': FieldValue.arrayUnion([appointment])
        });
        if (!mounted) return;
        setState(() {
          appointments?.add(appointment!);
        });
      });
    } catch (e) {
      print("Error $e");
    }
  }

  Future<void> _removeAppointment(
      Map<String, dynamic>? appointment, int index) async {
    try {
      await _firestore.runTransaction((transaction) async {
        var patientRef =
            _firestore.collection('Patients_data').doc(widget.userId);
        transaction.update(patientRef, {
          'appointments': FieldValue.arrayRemove([appointment])
        });
        if (!mounted) return;
        setState(() {
          appointments?.removeAt(index);
        });
      });
    } catch (e) {
      print("Error $e");
    }
  }

  Future<void> _modifyAppointment(Map<String, dynamic>? newAppointment,
      int index, Map<String, dynamic>? oldAppointment) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var patientRef =
            _firestore.collection('Patients_data').doc(widget.userId);
        transaction.update(patientRef, {
          'appointments': FieldValue.arrayRemove([oldAppointment])
        });
        transaction.update(patientRef, {
          'appointments': FieldValue.arrayUnion([newAppointment])
        });
      });

      if (!mounted) return;
      setState(() {
        appointments![index] = newAppointment!;
      });
    } catch (e) {
      print("Error updating location: $e");
    }
  }

  void _showAddModal(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    String doctorName = widget.doctorData['name'];
    Specialization specialization =
        (widget.doctorData['specialization'] as String).toSpecialization();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Center(
                child: Text(
                  doctorName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Doctor Details
                  Text(
                    specialization.name.toUpperCase(),
                    style: TextStyle(fontSize: 16, color: Colors.teal[700]),
                  ),
                  SizedBox(height: 16),
                  // Date Picker
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Date: ${DateFormat.yMMMMd().format(selectedDate)}",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today, color: Colors.teal),
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  // Time Picker
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Time: ${selectedTime.format(context)}",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.access_time, color: Colors.teal),
                        onPressed: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (pickedTime != null) {
                            setState(() {
                              selectedTime = pickedTime;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                // Update Button
                TextButton(
                  onPressed: () {
                    _addAppointment({
                      'doctorName': doctorName,
                      'specialization':
                          specialization.toString().split('.').last,
                      'date': DateFormat('yyyy-MM-dd').format(selectedDate),
                      'time': '${selectedTime.hour}:${selectedTime.minute}',
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
                // Close Button
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Close',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditModal(
      BuildContext context, Map<String, dynamic> appointment, int index) {
    DateTime selectedDate = DateTime.parse(appointment['date']);
    List<String> timeParts = appointment['time'].split(':');
    TimeOfDay selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Center(
                child: Text(
                  appointment['doctorName'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Doctor Details
                  Text(
                    appointment['specialization'],
                    style: TextStyle(fontSize: 16, color: Colors.teal[700]),
                  ),
                  SizedBox(height: 16),
                  // Date Picker
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Date: ${DateFormat.yMMMMd().format(selectedDate)}",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today, color: Colors.teal),
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  // Time Picker
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Time: ${selectedTime.format(context)}",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.access_time, color: Colors.teal),
                        onPressed: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (pickedTime != null) {
                            setState(() {
                              selectedTime = pickedTime;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                // Update Button
                TextButton(
                  onPressed: () {
                    _modifyAppointment({
                      'doctorName': appointment['doctorName'],
                      'specialization': appointment['specialization'],
                      'date': DateFormat('yyyy-MM-dd').format(selectedDate),
                      'time': '${selectedTime.hour}:${selectedTime.minute}'
                    }, index, appointment);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Update',
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
                // Close Button
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Close',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // void _undoDelete(Map<String, dynamic> appointment, int index) {
  //   setState(() {
  //     appointments.insert(index, appointment);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 239, 241),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Appointments List'),
        actions: [
          IconButton(
            onPressed: () {
              _showAddModal(context);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListView.builder(
          itemCount: appointments!.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> appointment = appointments![index];
            return Dismissible(
              key: Key(appointment['doctorName']),
              direction: DismissDirection.startToEnd,
              onDismissed: (direction) {
                final removedAppointment = appointment;
                _removeAppointment(appointment, index);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Deleted appointment with ${removedAppointment['doctorName']}'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        //_undoDelete(removedAppointment, index);
                      },
                    ),
                    duration: Duration(seconds: 4),
                  ),
                );
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              child: AppointmentCard(
                doctorName: appointment['doctorName'],
                specialization: appointment['specialization'],
                date: DateTime.parse(appointment['date']),
                time: TimeOfDay(
                    hour: int.parse(appointment['time'].split(':')[0]),
                    minute: int.parse(appointment['time'].split(':')[1])),
                onTap: () => _showEditModal(context, appointment, index),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final String doctorName;
  final String specialization;
  final DateTime date;
  final TimeOfDay time;
  final VoidCallback onTap;

  const AppointmentCard({
    required this.doctorName,
    required this.specialization,
    required this.date,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.teal[200],
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    doctorName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                  ),
                  Text(
                    specialization,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.teal[900],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Date: ${DateFormat.yMMMMd().format(date)}",
                    style: TextStyle(fontSize: 14, color: Colors.teal[500]),
                  ),
                  Text(
                    "Time: ${time.format(context)}",
                    style: TextStyle(fontSize: 14, color: Colors.teal[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
