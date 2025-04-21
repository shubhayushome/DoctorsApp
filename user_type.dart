import 'package:doctors_app/doctor/doctor_auth.dart';
import 'package:doctors_app/gaurdian/gaurdian_auth.dart';
import 'package:doctors_app/patient/patient_auth.dart';
import 'package:flutter/material.dart';

class UserTypePage extends StatefulWidget {
  @override
  _UserTypePageState createState() => _UserTypePageState();
}

class _UserTypePageState extends State<UserTypePage> {
  // Dropdown selected value
  String _selectedUserType = 'Patient';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
          255, 145, 162, 235), // Mauve background color for the page
      appBar: AppBar(
        title: const Text(
          'User Type',
          style: TextStyle(color: Colors.white), // White color for AppBar title
        ),
        backgroundColor: const Color.fromARGB(
            255, 26, 26, 156), // Purple color for AppBar background
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Displaying the logo image
            Image.asset(
              'assets/images/logo.png',
              width: 200,
              height: 300,
              //color: const Color.fromARGB(201, 189, 160, 224),
            ),
            const SizedBox(height: 20),

            // Dropdown with rounded border and checkbox indication
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 26, 26, 156),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                    color: const Color.fromARGB(255, 145, 162, 235),
                    width: 1.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedUserType,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: const Color.fromARGB(255, 145, 162, 235),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'Patient',
                      child: Row(
                        children: [
                          Checkbox(
                            value: _selectedUserType == 'Patient',
                            onChanged: (value) {},
                            activeColor:
                                const Color.fromARGB(255, 145, 162, 235),
                          ),
                          Text(
                            'Patient',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 145, 162, 235),
                            ),
                          ),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Doctor',
                      child: Row(
                        children: [
                          Checkbox(
                            value: _selectedUserType == 'Doctor',
                            onChanged: (value) {},
                            activeColor:
                                const Color.fromARGB(255, 145, 162, 235),
                          ),
                          Text(
                            'Doctor',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 145, 162, 235),
                            ),
                          ),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Guardian',
                      child: Row(
                        children: [
                          Checkbox(
                            value: _selectedUserType == 'Guardian',
                            onChanged: (value) {},
                            activeColor:
                                const Color.fromARGB(255, 145, 162, 235),
                          ),
                          Text(
                            'Guardian',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 145, 162, 235),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedUserType = value!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Proceed button with text and icon, and rounded borders
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to the respective page based on selection
                if (_selectedUserType == 'Doctor') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const DoctorAuthScreen(),
                    ),
                  );
                } else if (_selectedUserType == 'Guardian') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const GaurdianAuthScreen(),
                    ),
                  );
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const PatientAuthScreen(),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.forward, color: Colors.white),
              label:
                  const Text('Proceed', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Color.fromARGB(255, 26, 26, 156), // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
