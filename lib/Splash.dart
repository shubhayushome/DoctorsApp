import 'package:doctors_app/appointment_list.dart';
import 'package:doctors_app/doctor_list.dart';
import 'package:doctors_app/gaurdian_list.dart';
import 'package:doctors_app/health_parameter.dart';
import 'package:doctors_app/live_location.dart';
import 'package:doctors_app/medicine_list.dart';
import 'package:doctors_app/patient_record.dart';
import 'package:doctors_app/safe_loaction.dart';
import 'package:flutter/material.dart';
//import 'package:url_launcher/url_launcher.dart';

class Splash extends StatefulWidget {
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          'Main Page',
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 8, 95, 48),
                Color.fromARGB(255, 4, 168, 95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.person, color: Colors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.menu_open, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 15, 154, 38),
              Color.fromARGB(255, 218, 245, 223),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  children: [
                    GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: screenWidth * 0.05,
                      mainAxisSpacing: screenHeight * 0.03,
                      children: [
                        buildCard(Icons.monitor_heart, 'Monitor Health Data',
                            context, screenWidth, screenHeight),
                        buildCard(Icons.history, 'Medical History', context,
                            screenWidth, screenHeight),
                        buildCard(Icons.security, 'Guardian List', context,
                            screenWidth, screenHeight),
                        buildCard(Icons.local_hospital, 'Doctor List', context,
                            screenWidth, screenHeight),
                        buildCard(Icons.location_on, 'Live Location', context,
                            screenWidth, screenHeight),
                        buildCard(Icons.location_city, 'Safe Locations',
                            context, screenWidth, screenHeight),
                        buildCard(Icons.calendar_today, 'Appointments', context,
                            screenWidth, screenHeight),
                        buildCard(Icons.medication, 'Medicine List', context,
                            screenWidth, screenHeight),
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
                          child: Center(
                            child: Text(
                              "Patient Details here",
                              style: TextStyle(fontSize: 20),
                            ),
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
      double screenWidth, double screenHeight) {
    return InkWell(
      onTap: () {
        if (text == 'Monitor Health Data') {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => HealthParameterScreen(),
          ));
        }
        if (text == 'Medical History') {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => PatientRecordScreen(),
          ));
        }
        if (text == 'Guardian List') {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => GuardianListScreen(),
          ));
        }
        if (text == 'Doctor List') {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => DoctorListScreen(),
          ));
        }
        if (text == 'Safe Locations') {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => SafeLocationListScreen(),
          ));
        }
        if (text == 'Appointments') {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => AppointmentsListScreen(),
          ));
        }
        if (text == 'Medicine List') {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => MedicineListScreen(),
          ));
        }
        if (text == 'Live Location') {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => LiveLocationListScreen(),
          ));
        }
      },
      child: MouseRegion(
        onEnter: (event) => _animationController?.forward(),
        onExit: (event) => _animationController?.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 48, 201, 55),
                Color.fromARGB(255, 218, 245, 223),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, screenHeight * 0.01),
                blurRadius: screenHeight * 0.02,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.025),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(iconData,
                      size: screenHeight * 0.04,
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
                      fontSize: screenHeight * 0.020,
                      fontStyle: FontStyle.italic,
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
