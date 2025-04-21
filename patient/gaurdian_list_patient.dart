import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher_string.dart';

class GuardianListScreen extends StatefulWidget {
  final Map<String, dynamic> patientData; // Receiving patient data
  final String userId;
  const GuardianListScreen(
      {super.key, required this.patientData, required this.userId});
  @override
  _GuardianListScreenState createState() => _GuardianListScreenState();
}

class _GuardianListScreenState extends State<GuardianListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> availableGuardian = [];
  List<Map<String, dynamic>> presentGuardian = [];
  List<Map<String, dynamic>> presentGuardianList = [];

  @override
  void initState() {
    super.initState();
    _fetchGuardians();
  }

  Future<void> _fetchGuardians() async {
    try {
      var availableSnapshot =
          await _firestore.collection('Gaurdians_data').get();
      var guardianDoc =
          await _firestore.collection('Patients_data').doc(widget.userId).get();

      if (!mounted) return;

      presentGuardianList = List<Map<String, dynamic>>.from(
          guardianDoc.data()?['guardian'] ?? []);

      //print(presentGuardianList);

      List<String> presentGuardianIds =
          presentGuardianList.map((g) => g['guardianId'].toString()).toList();

      //print(presentGuardianIds);

      List<Map<String, dynamic>> allGuardians =
          availableSnapshot.docs.map((doc) => doc.data()).toList();

      //print(allGuardians);

      setState(() {
        presentGuardian = allGuardians
            .where((doc) => presentGuardianIds.contains(doc['uid']))
            .toList();
        availableGuardian = allGuardians
            .where((doc) => !presentGuardianIds.contains(doc['uid']))
            .toList();
        // print(availableGuardian);
        // print(presentGuardian);
        // print(presentGuardianList);
      });
    } catch (e) {
      print("Error fetching guardians: $e");
    }
  }

  void _showAddGuardianModal(BuildContext context) {
    Map<String, dynamic>? selectedGuardian;
    String? selectedGuardianName;

    final relationShipcontroller = TextEditingController();

    // Filter out doctors already in past or present lists

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
                      items: availableGuardian.map((guardian) {
                        return DropdownMenuItem<String>(
                          value: guardian['name'],
                          child: Text(guardian['name']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGuardianName = value;
                          selectedGuardian = availableGuardian.firstWhere(
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
                      _addGuardianToPresent(
                          relationShipcontroller.text.trim(), selectedGuardian);
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

  Future<void> _addGuardianToPresent(
      String relationship, Map<String, dynamic>? guardian) async {
    try {
      print(guardian);
      print(relationship);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var patientRef =
            _firestore.collection('Patients_data').doc(widget.userId);
        // print(patientRef);
        transaction.update(patientRef, {
          'guardian': FieldValue.arrayUnion([
            {'guardianId': guardian?['uid'], 'relationship': relationship}
          ])
        });

        var guardianRef =
            _firestore.collection('Gaurdians_data').doc(guardian!['uid']);
        // print(guardianRef);
        transaction.update(guardianRef, {
          'patient_gaurdian': FieldValue.arrayUnion([
            {'userId': widget.userId, 'relationship': relationship}
          ])
        });
      });

      if (!mounted) return;
      setState(() {
        presentGuardian.add(guardian!);
        presentGuardianList
            .add({'guardianId': guardian['uid'], 'relationship': relationship});
        availableGuardian.removeWhere((g) => g['uid'] == guardian['uid']);
      });
    } catch (e) {
      print("Error adding guardian: $e");
    }
  }

  Future<void> _deleteGuardianFromPatient(Map<String, dynamic> guardian,
      Map<String, dynamic> relationship, int index) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var patientRef =
            _firestore.collection('Patients_data').doc(widget.userId);
        transaction.update(patientRef, {
          'guardian': FieldValue.arrayRemove([
            {
              'guardianId': guardian['uid'],
              'relationship': relationship['relationship']
            }
          ])
        });

        var guardianRef =
            _firestore.collection('Gaurdians_data').doc(guardian['uid']);
        transaction.update(guardianRef, {
          'patient_gaurdian': FieldValue.arrayRemove([
            {
              'userId': widget.userId,
              'relationship': relationship['relationship']
            }
          ])
        });
      });

      if (!mounted) return;
      setState(() {
        presentGuardian.removeWhere((g) => g['uid'] == guardian['uid']);
        presentGuardianList.removeAt(index);
        availableGuardian.add(guardian);
      });
    } catch (e) {
      print("Error deleting guardian: $e");
    }
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
              _showAddGuardianModal(context);
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: presentGuardian.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic>? record = entry.value;
              Map<String, dynamic>? relationship = presentGuardianList[index];
              return Dismissible(
                key: Key(record['name']!),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  final removedRecord = record;
                  _deleteGuardianFromPatient(record, relationship, index);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${removedRecord['name']} deleted'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          //_undoDelete(removedRecord, index);
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
                  relationship: relationship['relationship']!,
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
