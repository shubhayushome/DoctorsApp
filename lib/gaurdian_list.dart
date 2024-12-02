import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher_string.dart';

class GuardianListScreen extends StatefulWidget {
  @override
  _GuardianListScreenState createState() => _GuardianListScreenState();
}

class _GuardianListScreenState extends State<GuardianListScreen> {
  List<Map<String, String>> availableGuardian = [
    {
      'name': 'John Doe',
      //'relationship': 'Father',
      'phone': '+1234567890',
      'email': 'johndoe@example.com',
    },
    {
      'name': 'Jane Smith',
      //'relationship': 'Mother',
      'phone': '+9876543210',
      'email': 'janesmith@example.com',
    },
    {
      'name': 'Robert Brown',
      //'relationship': 'Guardian',
      'phone': '+1122334455',
      'email': 'robertbrown@example.com',
    },
    {
      'name': 'Emily White',
      //'relationship': 'Aunt',
      'phone': '+9988776655',
      'email': 'emilywhite@example.com',
    },
    {
      'name': 'Michael Black',
      //'relationship': 'Uncle',
      'phone': '+7766554433',
      'email': 'michaelblack@example.com',
    },
    {
      'name': 'Emily Blanch',
      //'relationship': 'Aunt',
      'phone': '+9784589655',
      'email': 'emilyblanch@example.com',
    },
    {
      'name': 'Michael Jordan',
      //'relationship': 'Uncle',
      'phone': '+7766554433',
      'email': 'michaeljordan@example.com',
    },
  ];
  // Dummy data
  List<Map<String, String>> guardianRecords = [
    {
      'name': 'John Doe',
      'relationship': 'Father',
      'phone': '+1234567890',
      'email': 'johndoe@example.com',
    },
    {
      'name': 'Jane Smith',
      'relationship': 'Mother',
      'phone': '+9876543210',
      'email': 'janesmith@example.com',
    },
    {
      'name': 'Robert Brown',
      'relationship': 'Guardian',
      'phone': '+1122334455',
      'email': 'robertbrown@example.com',
    },
    {
      'name': 'Emily White',
      'relationship': 'Aunt',
      'phone': '+9988776655',
      'email': 'emilywhite@example.com',
    },
    {
      'name': 'Michael Black',
      'relationship': 'Uncle',
      'phone': '+7766554433',
      'email': 'michaelblack@example.com',
    },
  ];

  void _undoDelete(Map<String, String> record, int index) {
    setState(() {
      guardianRecords.insert(index, record);
    });
  }

  void _showAddGuardianModal(
      BuildContext context, Function addPresentGuardian) {
    Map<String, String>? selectedGuardian;
    String? selectedGuardianName;
    final relationShipcontroller = TextEditingController();

    // Filter out doctors already in past or present lists
    List<Map<String, String>> availableForSelection = availableGuardian.where(
      (guardian) {
        final guardianName = guardian['name'];
        // Check if the doctor's name is in pastDoctors or presentDoctors
        final isInPast = guardianRecords
            .any((pastguardian) => pastguardian['name'] == guardianName);
        return !isInPast;
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
                  'Add Guardian',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Doctor Name Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedGuardianName,
                      hint: Text('Select Guardian'),
                      items: availableForSelection.map((guardian) {
                        return DropdownMenuItem<String>(
                          value: guardian['name'],
                          child: Text(guardian['name']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGuardianName = value;
                          selectedGuardian = availableForSelection.firstWhere(
                            (guardian) => guardian['name'] == value,
                          );
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    // Specialization Field
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Relationship',
                        border: OutlineInputBorder(),
                      ),
                      controller: relationShipcontroller,
                    ),
                    SizedBox(height: 16),
                    // Phone Field
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: selectedGuardian?['phone'] ?? '',
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
                        text: selectedGuardian?['email'] ?? '',
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
                    if (selectedGuardian != null &&
                        !relationShipcontroller.text.isEmpty &&
                        relationShipcontroller.text.trim().length > 0) {
                      Map<String, String> pickedGurdian = {
                        'name': selectedGuardian!['name'].toString(),
                        'relationship': relationShipcontroller.text,
                        'phone': selectedGuardian!['phone'].toString(),
                        'email': selectedGuardian!['email'].toString(),
                      };
                      addPresentGuardian(pickedGurdian);
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a Gaurdian!')),
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

  void addPresentGuardian(Map<String, String> guardian) {
    setState(() {
      guardianRecords.add(guardian);
    });
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
        title: Text('Guardian List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Placeholder for add functionality
              _showAddGuardianModal(context, addPresentGuardian);
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: guardianRecords.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, String> record = entry.value;

              return Dismissible(
                key: Key(record['name']!),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  final removedRecord = record;
                  setState(() {
                    guardianRecords.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${removedRecord['name']} deleted'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          _undoDelete(removedRecord, index);
                        },
                      ),
                      duration: Duration(seconds: 4),
                    ),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                child: GuardianRecordCard(
                  name: record['name']!,
                  relationship: record['relationship']!,
                  phone: record['phone']!,
                  email: record['email']!,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class GuardianRecordCard extends StatelessWidget {
  final String name;
  final String relationship;
  final String phone;
  final String email;

  const GuardianRecordCard({
    required this.name,
    required this.relationship,
    required this.phone,
    required this.email,
  });

  void _showOptions(BuildContext context) {
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
                //final Uri callUri = Uri(scheme: 'tel', path: phone);
                try {
                  launchUrlString('tel://$phone');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
                // try {
                //   if (await canLaunchUrl(callUri)) {
                //     await launchUrl(callUri);
                //   } else {
                //     throw 'Could not launch phone app';
                //   }
                // } catch (e) {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(content: Text(e.toString())),
                //   );
                // }
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptions(context),
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
                    relationship,
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
