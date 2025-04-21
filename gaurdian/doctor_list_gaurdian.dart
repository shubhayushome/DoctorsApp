import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DoctorListScreen extends StatefulWidget {
  final Map<String, dynamic> patientData; // Receiving patient data
  final String userId;
  const DoctorListScreen(
      {super.key, required this.patientData, required this.userId});
  @override
  _DoctorListScreenState createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  int _currentIndex = 0; // Tracks the current selected tab index
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Dummy data for past and present doctors
  List<Map<String, dynamic>> availableDoctors = [];
  List<Map<String, dynamic>> presentDoctors = [];
  List<Map<String, dynamic>> pastDoctors = [];

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    try {
      var availableSnapshot = await _firestore.collection('Doctors_data').get();
      var patientDoc =
          await _firestore.collection('Patients_data').doc(widget.userId).get();

      if (!mounted) return;

      List<String> presentDoctorIds =
          List<String>.from(patientDoc.data()?['present_doctors'] ?? []);
      List<String> pastDoctorIds =
          List<String>.from(patientDoc.data()?['past_doctors'] ?? []);

      List<Map<String, dynamic>> allDoctors =
          availableSnapshot.docs.map((doc) => doc.data()).toList();

      // print(presentDoctorIds);
      // print(pastDoctorIds);
      // print(allDoctors);

      setState(() {
        presentDoctors = allDoctors
            .where((doc) => presentDoctorIds.contains(doc['uid']))
            .toList();
        pastDoctors = allDoctors
            .where((doc) => pastDoctorIds.contains(doc['uid']))
            .toList();
        availableDoctors = allDoctors
            .where((doc) =>
                !presentDoctorIds.contains(doc['uid']) &&
                !pastDoctorIds.contains(doc['uid']))
            .toList();
      });
    } catch (e) {
      print("Error fetching doctors: $e");
    }
  }

  Future<void> _addDoctorToPresent(Map<String, dynamic> doctor) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var patientRef =
            _firestore.collection('Patients_data').doc(widget.userId);
        transaction.update(patientRef, {
          'present_doctors': FieldValue.arrayUnion([doctor['uid']])
        });
        //print(doctor['uid']);
        var doctorRef =
            _firestore.collection('Doctors_data').doc(doctor['uid']);
        //print(doctorRef);
        transaction.update(doctorRef, {
          'patient': FieldValue.arrayUnion([widget.userId])
        });
      });

      if (!mounted) return;
      setState(() {
        presentDoctors.add(doctor);
        availableDoctors.removeWhere((d) => d['uid'] == doctor['uid']);
      });
    } catch (e) {
      print("Error adding doctor: $e");
    }
  }

  final PageController _pageController = PageController();

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _moveDoctor(
      Map<String, dynamic> doctor, bool fromPresent) async {
    try {
      String fromCollection = fromPresent ? 'present_doctors' : 'past_doctors';
      String toCollection = fromPresent ? 'past_doctors' : 'present_doctors';
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var patientRef =
            _firestore.collection('Patients_data').doc(widget.userId);
        transaction.update(patientRef, {
          fromCollection: FieldValue.arrayRemove([doctor['uid']]),
          toCollection: FieldValue.arrayUnion([doctor['uid']])
        });
      });

      if (!mounted) return;
      setState(() {
        if (fromPresent) {
          presentDoctors.remove(doctor);
          pastDoctors.add(doctor);
        } else {
          pastDoctors.remove(doctor);
          presentDoctors.add(doctor);
        }
      });
    } catch (e) {
      print("Error moving doctor: $e");
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(fromPresent ? 'Sent to Past' : 'Sent to Present'),
      ),
    );
  }

  // void _undoDelete(Map<String, String> record, int index, bool fromPresent) {
  //   setState(() {
  //     if (fromPresent) {
  //       presentDoctors.insert(index, record);
  //     } else {
  //       pastDoctors.insert(index, record);
  //     }
  //   });
  // }

  Future<void> _deleteDoctor(
      Map<String, dynamic> doctor, bool isPresent) async {
    try {
      String collection = isPresent ? 'present_doctors' : 'past_doctors';
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var patientRef =
            _firestore.collection('Patients_data').doc(widget.userId);
        transaction.update(patientRef, {
          collection: FieldValue.arrayRemove([doctor['uid']])
        });
        var doctorRef =
            _firestore.collection('Doctors_data').doc(doctor['uid']);
        transaction.update(doctorRef, {
          'patient': FieldValue.arrayRemove([widget.userId])
        });
      });

      if (!mounted) return;
      setState(() {
        isPresent ? presentDoctors.remove(doctor) : pastDoctors.remove(doctor);
        availableDoctors.add(doctor);
      });
    } catch (e) {
      print("Error deleting doctor: $e");
    }
  }

  void _showAddDoctorModal(BuildContext context) {
    Map<String, dynamic>? selectedDoctor;
    String? selectedDoctorName;

    // Filter out doctors already in past or present lists

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Center(
                child: Text(
                  'Add Doctor',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Doctor Name Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedDoctorName,
                      hint: Text('Select Doctor'),
                      items: availableDoctors.map((doctor) {
                        return DropdownMenuItem<String>(
                          value: doctor['name'],
                          child: Text(doctor['name']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDoctorName = value;
                          selectedDoctor = availableDoctors.firstWhere(
                            (doctor) => doctor['name'] == value,
                          );
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    // Specialization Field
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Specialization',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: selectedDoctor?['specialization'] ?? '',
                      ),
                      readOnly: true,
                    ),
                    SizedBox(height: 16),
                    // Phone Field
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: selectedDoctor?['phone'] ?? '',
                      ),
                      readOnly: true,
                    ),
                    SizedBox(height: 16),
                    // Email Field
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: selectedDoctor?['email'] ?? '',
                      ),
                      readOnly: true,
                    ),
                  ],
                ),
              ),
              actions: [
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
                // Update Button
                TextButton(
                  onPressed: () {
                    if (selectedDoctor != null) {
                      //print(selectedDoctor);
                      _addDoctorToPresent(selectedDoctor!);
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a doctor!')),
                      );
                    }
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDoctorList(
      String title, List<Map<String, dynamic>> doctors, bool isPresent) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Text(
          title,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              var doctor = doctors[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                child: Dismissible(
                  key: Key(doctor['name']!),
                  direction: DismissDirection.horizontal,
                  onDismissed: (direction) {
                    if (direction == DismissDirection.startToEnd) {
                      _moveDoctor(doctor, isPresent);
                    } else if (direction == DismissDirection.endToStart) {
                      _deleteDoctor(doctor, isPresent);
                    }
                  },
                  background: Stack(
                    children: [
                      Container(
                        color: Colors.green,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_forward, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'To ${isPresent ? 'Past' : 'Present'}',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  secondaryBackground: Stack(
                    children: [
                      Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Delete',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.delete, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                  child: DoctorRecordCard(
                    name: doctor['name']!,
                    specialization: doctor['specialization']!,
                    phone: doctor['phone']!,
                    email: doctor['email']!,
                    onTap: () => _showOptions(
                        context, doctor['phone']!, doctor['email']!),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 145, 162, 235),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 26, 26, 156),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(_currentIndex == 0 ? 'Present Doctors' : 'Past Doctors'),
        actions: [
          IconButton(
            onPressed: () {
              _showAddDoctorModal(context);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          _buildDoctorList('Present Doctors', presentDoctors, true),
          _buildDoctorList('Past Doctors', pastDoctors, false),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        selectedItemColor: const Color.fromARGB(255, 26, 26, 156),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Present Doctors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Past Doctors',
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context, String phone, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.phone, color: Colors.green),
              title: Text('Call $phone'),
              onTap: () async {
                try {
                  launchUrlString('tel://$phone');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.email, color: Colors.blue),
              title: Text('Send Email to $email'),
              onTap: () async {
                try {
                  launchUrlString('mailto:$email');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.message, color: Colors.orange),
              title: Text('Send Message to $phone'),
              onTap: () async {
                try {
                  launchUrlString('sms://$phone');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

class DoctorRecordCard extends StatelessWidget {
  final String name;
  final String specialization;
  final String phone;
  final String email;
  final VoidCallback onTap;

  const DoctorRecordCard({
    required this.name,
    required this.specialization,
    required this.phone,
    required this.email,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: const Color.fromARGB(255, 34, 116, 240).withOpacity(0.8),
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    specialization,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    phone,
                    style: TextStyle(
                      fontSize: 14,
                    ),
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
