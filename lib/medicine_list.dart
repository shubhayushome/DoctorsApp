import 'package:flutter/material.dart';

class MedicineListScreen extends StatefulWidget {
  @override
  _MedicineListScreenState createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  // Dummy data for medicines
  final List<Map<String, dynamic>> medicineRecords = [
    {
      'name': 'Paracetamol',
      'timings': ['After Breakfast', 'After Dinner'],
    },
    {
      'name': 'Amoxicillin',
      'timings': ['After Breakfast', 'After Lunch', 'After Dinner'],
    },
    {
      'name': 'Ibuprofen',
      'timings': ['After Lunch'],
    },
    {
      'name': 'Cough Syrup',
      'timings': [
        'At Sunrise',
        'After Breakfast',
        'After Lunch',
        'After Dinner',
        'Bedtime'
      ],
    },
    {
      'name': 'Vitamin D',
      'timings': ['After Lunch', 'After Dinner', 'Morning'],
    },
    {
      'name': 'Pain Reliever',
      'timings': ['Morning', 'Afternoon', 'Evening', 'Bedtime'],
    },
  ];

  void _showAddModal(BuildContext context, Function addMedicine) {
    String newMedicineName = "";
    List<String> newTimings = [];
    TextEditingController nameController = TextEditingController();
    TextEditingController timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Center(
                child: Text(
                  "Add Medicine",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              content: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Medicine Name Input
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Medicine Name',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            newMedicineName = value;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      // Editable timings
                      Container(
                        height: 150,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.teal),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: newTimings
                                .map(
                                  (time) => Chip(
                                    label: Text(time),
                                    deleteIcon: Icon(Icons.close),
                                    onDeleted: () {
                                      setState(() {
                                        newTimings.remove(time);
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      // Add new time
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: timeController,
                              decoration: InputDecoration(
                                labelText: 'Add Time',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.add_circle, color: Colors.teal),
                            onPressed: () {
                              if (timeController.text.isNotEmpty) {
                                setState(() {
                                  newTimings.add(timeController.text);
                                  timeController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                // Add Button
                TextButton(
                  onPressed: () {
                    if (newMedicineName.isNotEmpty && newTimings.isNotEmpty) {
                      addMedicine({
                        'name': newMedicineName,
                        'timings': newTimings,
                      });
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Medicine name and timings cannot be empty!',
                          ),
                        ),
                      );
                    }
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

  void _showEditModal(BuildContext context, Map<String, dynamic> record,
      Function updateMedicine) {
    List<String> editableTimings = List<String>.from(record['timings']);
    TextEditingController timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Center(
                child: Text(
                  record['name'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Editable timings
                  Container(
                    height: 150,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.teal),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: editableTimings
                            .map(
                              (time) => Chip(
                                label: Text(time),
                                deleteIcon: Icon(Icons.close),
                                onDeleted: () {
                                  setState(() {
                                    editableTimings.remove(time);
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Add new time
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: timeController,
                          decoration: InputDecoration(
                            labelText: 'Add Time',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: Colors.teal),
                        onPressed: () {
                          if (timeController.text.isNotEmpty) {
                            setState(() {
                              editableTimings.add(timeController.text);
                              timeController.clear();
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
                    // Use the callback to update the parent widget's state
                    updateMedicine(record['name'], editableTimings);
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

  void addMedicine(Map<String, dynamic> record) {
    setState(() {
      medicineRecords.add(record);
    });
  }

  void _updateMedicine(String medicineName, List<String> updatedTimings) {
    setState(() {
      for (var record in medicineRecords) {
        if (record['name'] == medicineName) {
          record['timings'] = updatedTimings;
          break;
        }
      }
    });
  }

  void _undoDelete(Map<String, dynamic> record, int index) {
    setState(() {
      medicineRecords.insert(index, record);
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
        title: Text('Medicine List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddModal(context, addMedicine),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListView.builder(
          itemCount: medicineRecords.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> record = medicineRecords[index];
            return Dismissible(
              key: Key(record['name']!),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                final removedRecord = record;
                setState(() {
                  medicineRecords.removeAt(index);
                });
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Deleted ${removedRecord['name']}'),
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
              child: MedicineCard(
                name: record['name']!,
                timings: List<String>.from(record['timings']),
                onTap: () => _showEditModal(context, record, _updateMedicine),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MedicineCard extends StatelessWidget {
  final String name;
  final List<String> timings;
  final VoidCallback onTap;

  const MedicineCard({
    required this.name,
    required this.timings,
    required this.onTap,
  });

  List<List<String>> _splitTimings(List<String> timings) {
    List<List<String>> rows = [];
    int maxPerRow = 3;
    int i = 0;
    while (i < timings.length) {
      int rowCount =
          (timings.length - i > maxPerRow) ? maxPerRow : timings.length - i;
      rows.add(timings.sublist(i, i + rowCount));
      i += rowCount;
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    List<List<String>> timingRows = _splitTimings(timings);
    double maxTabHeight = 40.0; // Ensures uniform height

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
              // Medicine name (centered)
              Center(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700],
                  ),
                ),
              ),
              SizedBox(height: 12.0),
              // Timing rows
              ...timingRows.map((row) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: row.map((timing) {
                      return Flexible(
                        child: Container(
                          height: maxTabHeight, // Uniform height for all tabs
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: BoxDecoration(
                            color: Colors.teal[50],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.teal[200]!),
                          ),
                          child: Text(
                            timing,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.teal[900],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
