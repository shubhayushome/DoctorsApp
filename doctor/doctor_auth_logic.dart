import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Enums for structured data
enum Specialization { Surgeon, Medicine }

enum Hours { Open_24_7, Mon_Fri }

enum LocationType { Family_House, Friend_House }

enum Gender { male, female }

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

class DoctorDatabase {
  final _fire = FirebaseFirestore.instance;

  // Function to add patient data to Firestore
  Future<String?> addDoctorDataFirestore(
      String uid,
      String name,
      String email,
      String password,
      String gender,
      String specialization,
      int age,
      String phone,
      int exp,
      String reg_no) async {
    try {
      final docRef = await _fire.collection("Doctors_data").doc(uid).set({
        "uid": uid,
        "name": name,
        "email": email,
        "password": password,
        "gender": gender,
        "age": age,
        "phone": phone,
        "experience": exp,
        "specialization": specialization,
        "registration_no": reg_no,
        "patient": [],
        "appointments": [],
      });

      return uid;
    } catch (e) {
      log("Error adding patient data: \$e");
      return null;
    }
  }

  // Function to fetch patient data from Firestore
  Future<Map<String, dynamic>?> getDoctorData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _fire.collection("Doctors_data").doc(uid).get();
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
