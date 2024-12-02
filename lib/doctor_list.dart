import 'package:flutter/material.dart';
//import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DoctorListScreen extends StatefulWidget {
  @override
  _DoctorListScreenState createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  int _currentIndex = 0; // Tracks the current selected tab index

  // Dummy data for past and present doctors
  List<Map<String, String>> availableDoctors = [
    {
      'name': 'Dr. Deepender Singh',
      'specialization': 'Psychiatrist',
      'phone': '+1234789612',
      'email': 'deepsingh@example.com'
    },
    {
      'name': 'Dr. Robert Palmore',
      'specialization': 'Gynaecologist',
      'phone': '+1563276655',
      'email': 'robertpal@example.com'
    },
    {
      'name': 'Dr. John Smith',
      'specialization': 'Cardiologist',
      'phone': '+1234567890',
      'email': 'johnsmith@example.com'
    },
    {
      'name': 'Dr. Jane Doe',
      'specialization': 'Neurologist',
      'phone': '+9876543210',
      'email': 'janedoe@example.com'
    },
    {
      'name': 'Dr. Alice Brown',
      'specialization': 'Orthopedic',
      'phone': '+1122334455',
      'email': 'alicebrown@example.com'
    },
    {
      'name': 'Dr. Robert White',
      'specialization': 'Pediatrician',
      'phone': '+9988776655',
      'email': 'robertwhite@example.com'
    },
  ];
  List<Map<String, String>> pastDoctors = [
    {
      'name': 'Dr. John Smith',
      'specialization': 'Cardiologist',
      'phone': '+1234567890',
      'email': 'johnsmith@example.com'
    },
    {
      'name': 'Dr. Jane Doe',
      'specialization': 'Neurologist',
      'phone': '+9876543210',
      'email': 'janedoe@example.com'
    },
  ];

  List<Map<String, String>> presentDoctors = [
    {
      'name': 'Dr. Alice Brown',
      'specialization': 'Orthopedic',
      'phone': '+1122334455',
      'email': 'alicebrown@example.com'
    },
    {
      'name': 'Dr. Robert White',
      'specialization': 'Pediatrician',
      'phone': '+9988776655',
      'email': 'robertwhite@example.com'
    },
  ];

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

  void _moveCard(Map<String, String> record, int index, bool fromPresent) {
    setState(() {
      if (fromPresent) {
        presentDoctors.removeAt(index);
        pastDoctors.add(record); // Move to Past
      } else {
        pastDoctors.removeAt(index);
        presentDoctors.add(record); // Move to Present
      }
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(fromPresent ? 'Sent to Past' : 'Sent to Present'),
      ),
    );
  }

  void _undoDelete(Map<String, String> record, int index, bool fromPresent) {
    setState(() {
      if (fromPresent) {
        presentDoctors.insert(index, record);
      } else {
        pastDoctors.insert(index, record);
      }
    });
  }

  void _deleteCard(Map<String, String> record, int index, bool fromPresent) {
    setState(() {
      if (fromPresent) {
        presentDoctors.removeAt(index);
      } else {
        pastDoctors.removeAt(index);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${record['name']} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            _undoDelete(record, index, fromPresent);
          },
        ),
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _showAddDoctorModal(BuildContext context, Function addPresentDoctor) {
    Map<String, String>? selectedDoctor;
    String? selectedDoctorName;

    // Filter out doctors already in past or present lists
    List<Map<String, String>> availableForSelection = availableDoctors.where(
      (doctor) {
        final doctorName = doctor['name'];
        // Check if the doctor's name is in pastDoctors or presentDoctors
        final isInPast =
            pastDoctors.any((pastDoctor) => pastDoctor['name'] == doctorName);
        final isInPresent = presentDoctors
            .any((presentDoctor) => presentDoctor['name'] == doctorName);
        return !isInPast && !isInPresent;
      },
    ).toList();

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
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Doctor Name Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedDoctorName,
                    hint: Text('Select Doctor'),
                    items: availableForSelection.map((doctor) {
                      return DropdownMenuItem<String>(
                        value: doctor['name'],
                        child: Text(doctor['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDoctorName = value;
                        selectedDoctor = availableForSelection.firstWhere(
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
                      addPresentDoctor(selectedDoctor);
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

  void addPresentDoctor(Map<String, String> doctor) {
    setState(() {
      presentDoctors.add(doctor);
    });
  }

  Widget _buildDoctorList(
      String title, List<Map<String, String>> doctors, bool isPresent) {
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
              Map<String, String> doctor = doctors[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                child: Dismissible(
                  key: Key(doctor['name']!),
                  direction: DismissDirection.horizontal,
                  onDismissed: (direction) {
                    if (direction == DismissDirection.startToEnd) {
                      _moveCard(doctor, index, isPresent);
                    } else if (direction == DismissDirection.endToStart) {
                      _deleteCard(doctor, index, isPresent);
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
              _showAddDoctorModal(context, addPresentDoctor);
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
