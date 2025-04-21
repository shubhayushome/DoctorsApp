import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctors_app/doctor/Health_report_doctor.dart';
import 'package:doctors_app/doctor/appointment_list_doctor.dart';
import 'package:doctors_app/doctor/doctor_list_doctor.dart';
import 'package:doctors_app/doctor/gaurdian_list_doctor.dart';
import 'package:doctors_app/doctor/health_parameter_doctor.dart';
import 'package:doctors_app/doctor/live_location_doctor.dart';
import 'package:doctors_app/doctor/medicine_list_doctor.dart';
//import 'package:doctors_app/doctor/patient_record_doctor.dart';
//import 'package:doctors_app/doctor/patient_auth_logic.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:url_launcher/url_launcher.dart';

class Splash extends StatefulWidget {
  final Map<String, dynamic> doctorData; // Receiving patient data
  final List<String> patientIds;
  const Splash({super.key, required this.doctorData, required this.patientIds});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  late Future<List<Map<String, dynamic>>> patientData;
  int index = 0;
  @override
  void initState() {
    super.initState();
    patientData = _fetchPatients();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchPatients() async {
    List<Map<String, dynamic>> patients = [];
    for (String id in widget.patientIds) {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection('Patients_data')
          .doc(id)
          .get();
      if (doc.exists) {
        patients.add(doc.data()!);
      }
    }
    return patients;
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color primaryColor = isDarkMode ? Colors.tealAccent : Colors.green;
    Color backgroundColor = isDarkMode ? Colors.black : Colors.white;
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    bool isPortrait = screenWidth < 600;
    String patientName =
        widget.doctorData['name'] ?? 'Patient'; // Fetch patient name
    int patientAge = widget.doctorData['age'] ?? 0;
    String patientPhone = widget.doctorData['phone'] ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            User? currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null &&
                currentUser.uid == widget.doctorData['uid']) {
              await FirebaseAuth.instance
                  .signOut(); // Sign out user if it's the correct one
              Navigator.pop(context);
            }
          },
          icon: Icon(Icons.logout, color: Colors.white),
        ),
        title: Text('Welcome, ${widget.doctorData['name'] ?? 'Doctor'}'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor:
                    Colors.transparent, // Transparent to allow rounded corners
                builder: (context) {
                  // Schedule automatic close after 5 seconds
                  Future.delayed(Duration(seconds: 5), () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  });

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () =>
                        Navigator.of(context).pop(), // Tap outside to close
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Material(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: FutureBuilder<List<Map<String, dynamic>>>(
                              future: patientData,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child:
                                          Text("Error loading patient data"));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Center(
                                      child: Text("No patient data available"));
                                }

                                var patientList = snapshot.data!;
                                var patient = patientList[
                                    index]; // Ensure index is within bounds

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Patient Information",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Name: ${patient['name'] ?? 'Unknown'}",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Age: ${patient['age'] ?? 'N/A'}",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "Phone: ${patient['phone'] ?? 'N/A'}",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            icon: Icon(Icons.person, color: Colors.white),
          ),
          Builder(builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context)
                    .openEndDrawer(); // ✅ Opens right-side drawer
              },
              icon: Icon(Icons.menu_open, color: Colors.white),
            );
          }),
        ],
      ),
      // ✅ Right-side drawer added correctly
      endDrawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 150, // ✅ Makes header take full width
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 8, 95, 48),
                    Color.fromARGB(255, 4, 168, 95)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  'Patient List',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: patientData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error loading patients"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No patients found"));
                  }

                  List<Map<String, dynamic>> patientList = snapshot.data!;

                  return ListView.builder(
                    itemCount: patientList.length,
                    itemBuilder: (context, i) {
                      bool isSelected = i == index;
                      return ListTile(
                        leading: Icon(Icons.account_circle,
                            color: isSelected ? Colors.green : Colors.black),
                        title: Text(
                          patientList[i]['name'] ?? "Unknown",
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? Colors.green : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                            "Gender: ${patientList[i]['gender'] ?? 'N/A'}"),
                        tileColor:
                            isSelected ? Colors.green.withOpacity(0.2) : null,
                        onTap: () {
                          setState(() {
                            index = i;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.withOpacity(0.8), backgroundColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: patientData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error loading patient data"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("No patient data available"));
                    }

                    List<Map<String, dynamic>> patientList = snapshot.data!;

                    return GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: isPortrait ? 2 : 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        buildCard(
                            Icons.monitor_heart,
                            'Monitor Health Data',
                            context,
                            screenWidth,
                            screenHeight,
                            HealthParameterScreen(
                                patientData: patientList[index],
                                userId: patientList[index]['uid'])),
                        buildCard(
                            Icons.history,
                            'Medical History',
                            context,
                            screenWidth,
                            screenHeight,
                            HealthReportScreen(
                              patientData: patientList[index],
                              userId: patientList[index]['uid'],
                            )),
                        buildCard(
                            Icons.security,
                            'Guardian List',
                            context,
                            screenWidth,
                            screenHeight,
                            GuardianListScreen(
                                patientData: patientList[index],
                                userId: patientList[index]['uid'])),
                        buildCard(
                            Icons.local_hospital,
                            'Doctor List',
                            context,
                            screenWidth,
                            screenHeight,
                            DoctorListScreen(
                                patientData: patientList[index],
                                userId: patientList[index]['uid'])),
                        buildCard(
                            Icons.location_on,
                            'Live Location',
                            context,
                            screenWidth,
                            screenHeight,
                            LiveLocationListScreen(
                                patientData: patientList[index],
                                userId: patientList[index]['uid'])),
                        buildCard(
                            Icons.calendar_today,
                            'Appointment',
                            context,
                            screenWidth,
                            screenHeight,
                            AppointmentsListScreen(
                              patientData: patientList[index],
                              userId: patientList[index]['uid'],
                              doctorData: widget.doctorData,
                            )),
                        buildCard(
                            Icons.medication,
                            'Medicine List',
                            context,
                            screenWidth,
                            screenHeight,
                            MedicineListScreen(
                                patientData: patientList[index],
                                userId: patientList[index]['uid'])),
                      ],
                    );
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.primaryDelta! < -10) {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          height: screenHeight * 0.3,
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Name: $patientName",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              Text("Age: $patientAge",
                                  style: TextStyle(fontSize: 18)),
                              SizedBox(height: 10),
                              Text("Phone: $patientPhone",
                                  style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
                child: Container(
                  width: screenWidth * 0.2,
                  height: screenHeight * 0.01,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard(IconData iconData, String text, BuildContext context,
      double screenWidth, double screenHeight, Widget screen) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => screen,
        ));
      },
      child: MouseRegion(
        onEnter: (event) => _animationController?.forward(),
        onExit: (event) => _animationController?.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(2, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(iconData,
                      size: 40,
                      color: Colors.black87), // More contrast in the icon
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(
                      left: screenWidth * 0.02, bottom: screenHeight * 0.01),
                  child: Text(
                    text,
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
