import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentsListScreen extends StatefulWidget {
  @override
  _AppointmentsListScreenState createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen> {
  final List<Map<String, dynamic>> appointments = [
    {
      'doctorName': 'Dr. Alice',
      'specialization': 'Cardiologist',
      'date': DateTime.now(),
      'time': TimeOfDay.now(),
    },
    {
      'doctorName': 'Dr. Bob',
      'specialization': 'Dermatologist',
      'date': DateTime.now().add(Duration(days: 2)),
      'time': TimeOfDay(hour: 15, minute: 30),
    },
    {
      'doctorName': 'Dr. Charlie',
      'specialization': 'Neurologist',
      'date': DateTime.now().add(Duration(days: 5)),
      'time': TimeOfDay(hour: 10, minute: 0),
    },
  ];

  void _showAddModal(BuildContext context, Function addAppointment) {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    String doctorName = "Dr. Blake";
    String specialization = "Nephrologist";
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
                    specialization,
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
                    addAppointment({
                      'doctorName': doctorName,
                      'specialization': specialization,
                      'date': selectedDate,
                      'time': selectedTime,
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

  void _showEditModal(BuildContext context, Map<String, dynamic> appointment,
      Function updateAppointment) {
    DateTime selectedDate = appointment['date'];
    TimeOfDay selectedTime = appointment['time'];

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
                    updateAppointment(
                      appointment['doctorName'],
                      selectedDate,
                      selectedTime,
                    );
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

  void _updateAppointment(String doctorName, DateTime date, TimeOfDay time) {
    setState(() {
      for (var appointment in appointments) {
        if (appointment['doctorName'] == doctorName) {
          appointment['date'] = date;
          appointment['time'] = time;
          break;
        }
      }
    });
  }

  void addAppointment(Map<String, dynamic> appointment) {
    setState(() {
      appointments.add(appointment);
    });
  }

  void _undoDelete(Map<String, dynamic> appointment, int index) {
    setState(() {
      appointments.insert(index, appointment);
    });
  }

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
              _showAddModal(context, addAppointment);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> appointment = appointments[index];
            return Dismissible(
              key: Key(appointment['doctorName']),
              direction: DismissDirection.startToEnd,
              onDismissed: (direction) {
                final removedAppointment = appointment;
                setState(() {
                  appointments.removeAt(index);
                });
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Deleted appointment with ${removedAppointment['doctorName']}'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        _undoDelete(removedAppointment, index);
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
                date: appointment['date'],
                time: appointment['time'],
                onTap: () =>
                    _showEditModal(context, appointment, _updateAppointment),
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
