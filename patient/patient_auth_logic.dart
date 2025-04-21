import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Enums for structured data
enum Specialization { Surgeon, Medicine, Others }

extension SpecializationExtension on String {
  Specialization toSpecialization() {
    switch (this) {
      case 'Surgeon':
        return Specialization.Surgeon;
      case 'Medicine':
        return Specialization.Medicine;
      default:
        return Specialization.Others;
    }
  }
}

enum Session { Day, Night, Others }

extension SessionExtension on String {
  Session toSession() {
    switch (this) {
      case 'Day':
        return Session.Day;
      case 'Night':
        return Session.Night;
      default:
        return Session.Others;
    }
  }
}

enum Hours { Open_24_7, Mon_Fri, Others }

extension HoursExtension on String {
  Hours toHours() {
    switch (this) {
      case 'Open_24_7':
        return Hours.Open_24_7;
      case 'Mon_Fri':
        return Hours.Mon_Fri;
      default:
        return Hours.Others;
    }
  }
}

enum LocationType { home, work, school, other }

extension LocationTypeExtension on String {
  LocationType toLocationType() {
    switch (this) {
      case 'home':
        return LocationType.home;
      case 'work':
        return LocationType.work;
      case 'school':
        return LocationType.school;
      default:
        return LocationType.other;
    }
  }
}

enum Gender { male, female }

class PatientDatabase {
  final _fire = FirebaseFirestore.instance;

  // Function to add patient data to Firestore
  Future<String?> addPatientDataFirestore(String uid, String name, String email,
      String password, String gender, int age, String phone) async {
    try {
      final docRef = await _fire.collection("Patients_data").doc(uid).set({
        "uid": uid,
        "name": name,
        "email": email,
        "password": password,
        "gender": gender,
        "age": age,
        "phone": phone,
        "health": {
          "bp": [],
          "pulse": [],
          "oxygen": [],
          "na+": [],
          "haem": [],
          "blood_sugar": [],
          "wbc_count": [],
          "timestamp": [],
          "session": [],
          "count": 0,
        },
        //"medical_record": [],
        "guardian": [],
        "present_doctors": [],
        "past_doctors": [],
        "safeLocations": [],
        "live_location": {"latitude": 0.0, "longitude": 0.0},
        "appointments": [],
        "medicineRecords": []
      });

      return uid;
    } catch (e) {
      log("Error adding patient data: \$e");
      return null;
    }
  }

  // Function to fetch patient data from Firestore
  Future<Map<String, dynamic>?> getPatientData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _fire.collection("Patients_data").doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      log("Error fetching patient data: \$e");
    }
    return null;
  }
}

class AuthService {
  final _auth = FirebaseAuth.instance;

  // Function to register a new user
  Future<String?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user?.uid;
    } catch (e) {
      log("Error during registration: \$e");
      return null;
    }
  }

  // Function to log in an existing user
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      // 👇 This line is important — it tells the caller exactly what went wrong
      throw e;
    }
  }

  // Function to log out user
  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Error during logout: \$e");
    }
  }
}

// Model for Appointment Data
class Appointment {
  DateTime date;
  String doctorName;
  String doctorId;
  String patientId;
  Specialization specialization;
  DateTime time;

  Appointment({
    required this.date,
    required this.doctorName,
    required this.doctorId,
    required this.specialization,
    required this.time,
    required this.patientId,
  });

  Map<String, dynamic> toJson() => {
        "date": date.toIso8601String(),
        "doctorName": doctorName,
        "doctorId": doctorId,
        "patientId": patientId,
        "specialization": specialization.toString().split('.').last,
        "time": time.toIso8601String(),
      };
}

// Model for Medical Record Data
class MedicalRecord {
  DateTime date;
  String doctor;
  String link;
  String name;

  MedicalRecord({
    required this.date,
    required this.doctor,
    required this.link,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
        "date": date.toIso8601String(),
        "doctor": doctor,
        "link": link,
        "name": name,
      };
}

// Model for Medicine Data
class Medicine {
  String name;
  String timings;

  Medicine({required this.name, required this.timings});

  Map<String, dynamic> toJson() => {
        "name": name,
        "timings": timings,
      };
}

class Gaurdian {
  String gaurdianId;
  String relationship;
  Gaurdian({required this.gaurdianId, required this.relationship});
  Map<String, dynamic> toJson() => {
        "gaurdianId": gaurdianId,
        "relationship": relationship,
      };
}

// Model for Safe Locations
class SafeLocation {
  Hours hours;
  String image;
  double latitude;
  double longitude;
  String name;
  LocationType type;

  SafeLocation({
    required this.hours,
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        "hours": hours.toString().split('.').last,
        "image": image,
        "latitude": latitude,
        "longitude": longitude,
        "name": name,
        "type": type.toString().split('.').last,
      };
}
