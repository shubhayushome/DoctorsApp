import 'package:flutter/material.dart';

class PatientRecordScreen extends StatefulWidget {
  @override
  _PatientRecordScreenState createState() => _PatientRecordScreenState();
}

class _PatientRecordScreenState extends State<PatientRecordScreen> {
  List<String> doctors = ['Dr. Blanch', 'Dr. Edward', 'Dr. Hippin'];
  // Dummy data
  List<Map<String, String>> patientRecords = [
    {
      'name': 'Record A',
      'date': '2024-11-01',
      'doctor': 'Dr. Smith',
      'link': 'https://www.example.com/fileA.pdf'
    },
    {
      'name': 'Record B',
      'date': '2024-11-05',
      'doctor': 'Dr. Jones',
      'link': 'https://www.example.com/fileB.pdf'
    },
    {
      'name': 'Record C',
      'date': '2024-11-10',
      'doctor': 'Dr. Brown',
      'link': 'https://www.example.com/fileC.pdf'
    },
    {
      'name': 'Record D',
      'date': '2024-11-15',
      'doctor': 'Dr. White',
      'link': 'https://www.example.com/fileD.pdf'
    },
    {
      'name': 'Record E',
      'date': '2024-11-20',
      'doctor': 'Dr. Black',
      'link': 'https://www.example.com/fileE.pdf'
    },
  ];

  void _undoDelete(Map<String, String> record, int index) {
    setState(() {
      patientRecords.insert(index, record);
    });
  }

  void _openAddRecordModal(BuildContext context, Function addpatientrecord) {
    // Controllers for fields
    TextEditingController nameController = TextEditingController();
    TextEditingController linkController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String? selectedDoctor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Center(
            child: Text(
              'Add Record',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name Field
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Date Picker Field
                      GestureDetector(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setModalState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            "${selectedDate.toLocal()}".split(' ')[0],
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Doctor Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedDoctor,
                        items: doctors.map((String doctor) {
                          return DropdownMenuItem<String>(
                            value: doctor,
                            child: Text(doctor),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Doctor',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setModalState(() {
                            selectedDoctor = value;
                          });
                        },
                      ),
                      SizedBox(height: 16),

                      // Link Field
                      TextField(
                        controller: linkController,
                        decoration: InputDecoration(
                          labelText: 'Link',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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
            // Add Button
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    selectedDoctor != null &&
                    linkController.text.isNotEmpty) {
                  Map<String, String> newRecord = {
                    'name': nameController.text,
                    'date': "${selectedDate.toLocal()}".split(' ')[0],
                    'doctor': selectedDoctor!,
                    'link': linkController.text,
                  };

                  addpatientrecord(newRecord);

                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill in all fields'),
                    ),
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
  }

  void addpatientrecord(Map<String, String> newRecord) {
    setState(() {
      patientRecords.add(newRecord);
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
        title: Text('Patient Records'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Placeholder for add functionality
              _openAddRecordModal(context, addpatientrecord);
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: patientRecords.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, String> record = entry.value;

              return Dismissible(
                key: Key(record['name']!),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  final removedRecord = record;
                  setState(() {
                    patientRecords.removeAt(index);
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
                child: PatientRecordCard(
                  name: record['name']!,
                  date: record['date']!,
                  doctor: record['doctor']!,
                  link: record['link']!,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class PatientRecordCard extends StatelessWidget {
  final String name;
  final String date;
  final String doctor;
  final String link;

  const PatientRecordCard({
    required this.name,
    required this.date,
    required this.doctor,
    required this.link,
  });

  void _downloadFile(String url, String filename, BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading $filename'),
        duration: Duration(seconds: 4),
      ),
    );
    // Implement actual download logic here
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _downloadFile(link, name, context),
      child: Card(
        color: const Color.fromARGB(255, 34, 116, 240).withOpacity(0.8),
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date: $date',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Doctor: $doctor',
                    style: TextStyle(fontSize: 14),
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
