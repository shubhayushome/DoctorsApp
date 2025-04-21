import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctors_app/patient/appointment_list_patient.dart';
import 'package:doctors_app/patient/doctor_list_patient.dart';
import 'package:doctors_app/patient/gaurdian_list_patient.dart';
import 'package:doctors_app/patient/health_parameter_patient.dart';
import 'package:doctors_app/patient/live_location_patient.dart';
import 'package:doctors_app/patient/medicine_list_patient.dart';
//import 'package:doctors_app/patient/patient_record_patient.dart';
import 'package:doctors_app/patient/safe_loaction_patient.dart';
//import 'package:doctors_app/patient/patient_auth_logic.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:url_launcher/url_launcher.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:doctors_app/patient/Health_report_patient.dart';
import 'dart:async';

class Splash extends StatefulWidget {
  final Map<String, dynamic> patientData; // Receiving patient data
  final String userId;
  const Splash({super.key, required this.patientData, required this.userId});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  Location location = new Location();
  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  AnimationController? _animationController;
  Timer? _locationTimer;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _requestLocationPermission();
    _startLocationUpdates();
  }

  void _requestLocationPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _updateLocation();
    });
  }

  Future<void> _updateLocation() async {
    //print("updating");
    try {
      _locationData = await location.getLocation();
      //print(_locationData?.latitude);

      await _firestore
          .collection('Patients_data')
          .doc(widget.userId) // Store by user ID
          .update({
        "live_location.latitude": _locationData?.latitude,
        "live_location.longitude": _locationData?.longitude
      });

      //print("Location updated: $locationData");
    } catch (e) {
      print("Failed to get location: $e");
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _locationTimer?.cancel();
    super.dispose();
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
        widget.patientData['name'] ?? 'Patient'; // Fetch patient name
    int patientAge = widget.patientData['age'] ?? 0;
    String patientPhone = widget.patientData['phone'] ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            User? currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null && currentUser.uid == widget.userId) {
              await FirebaseAuth.instance
                  .signOut(); // Sign out user if it's the correct one
              Navigator.pop(context);
            }
          },
          icon: Icon(Icons.logout, color: Colors.white),
        ),
        title: Text('Welcome, ${widget.patientData['name'] ?? 'Doctor'}'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       _showAddModal(context);
        //     },
        //     icon: Icon(Icons.add_box_outlined, color: Colors.white),
        //   ),
        //   //   // IconButton(
        //   //   //   onPressed: () {},
        //   //   //   icon: Icon(Icons.menu_open, color: Colors.white),
        //   //   // ),
        // ],
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
                child: Column(
                  children: [
                    GridView.count(
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
                                patientData: widget.patientData,
                                userId: widget.userId)),
                        buildCard(
                            Icons.history,
                            'Medical History',
                            context,
                            screenWidth,
                            screenHeight,
                            HealthReportScreen(
                                patientData: widget.patientData,
                                userId: widget.userId)),
                        buildCard(
                            Icons.security,
                            'Guardian List',
                            context,
                            screenWidth,
                            screenHeight,
                            GuardianListScreen(
                                patientData: widget.patientData,
                                userId: widget.userId)),
                        buildCard(
                            Icons.local_hospital,
                            'Doctor List',
                            context,
                            screenWidth,
                            screenHeight,
                            DoctorListScreen(
                                patientData: widget.patientData,
                                userId: widget.userId)),
                        buildCard(
                            Icons.location_on,
                            'Live Location',
                            context,
                            screenWidth,
                            screenHeight,
                            LiveLocationListScreen(
                                patientData: widget.patientData,
                                userId: widget.userId)),
                        buildCard(
                            Icons.location_city,
                            'Safe Locations',
                            context,
                            screenWidth,
                            screenHeight,
                            SafeLocationListScreen(
                                patientData: widget.patientData,
                                userId: widget.userId)),
                        buildCard(
                            Icons.calendar_today,
                            'Appointment',
                            context,
                            screenWidth,
                            screenHeight,
                            AppointmentsListScreen(
                                patientData: widget.patientData,
                                userId: widget.userId)),
                        buildCard(
                            Icons.medication,
                            'Medicine List',
                            context,
                            screenWidth,
                            screenHeight,
                            MedicineListScreen(
                                patientData: widget.patientData,
                                userId: widget.userId)),
                      ],
                    ),
                  ],
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
                      fontWeight: FontWeight.bold,
                    ),
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
