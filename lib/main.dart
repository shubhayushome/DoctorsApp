//import 'package:expenses_app/DoctorPage.dart';
import 'package:doctors_app/appointment_list.dart';
import 'package:doctors_app/doctor_list.dart';
import 'package:doctors_app/gaurdian_list.dart';
import 'package:doctors_app/health_parameter.dart';
import 'package:doctors_app/live_location.dart';
import 'package:doctors_app/medicine_list.dart';
import 'package:doctors_app/patient_record.dart';
import 'package:doctors_app/safe_loaction.dart';
import 'package:doctors_app/user_type.dart';
import 'package:flutter/material.dart';

var kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 145, 162, 235),
);

var darkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 145, 162, 235),
);
void main() {
  runApp(
    MaterialApp(
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: darkColorScheme,
        cardTheme: const CardTheme().copyWith(
            color: darkColorScheme.secondaryContainer,
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            )),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          backgroundColor: darkColorScheme.primaryContainer,
        )),
      ),
      theme: ThemeData().copyWith(
          colorScheme: kColorScheme,
          appBarTheme: const AppBarTheme().copyWith(
            backgroundColor: kColorScheme.onPrimaryContainer,
            foregroundColor: kColorScheme.primaryContainer,
          ),
          cardTheme: const CardTheme().copyWith(
              color: kColorScheme.secondaryContainer,
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              )),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
            backgroundColor: kColorScheme.primaryContainer,
          )),
          textTheme: ThemeData().textTheme.copyWith(
              titleLarge: TextStyle(
                fontWeight: FontWeight.bold,
                color: kColorScheme.onSecondaryContainer,
                fontSize: 18,
              ),
              titleMedium: TextStyle(
                fontWeight: FontWeight.normal,
                color: kColorScheme.onSecondaryContainer,
                fontSize: 14,
              ))),
      themeMode: ThemeMode.system,
      home: UserTypePage(),
      //home: PatientRecordScreen(),
      // home: GuardianListScreen(),
      //home: DoctorListScreen(),
      //home: MedicineListScreen(),
      //home : HealthParameterScreen(),
      //home: AppointmentsListScreen(),
      //home: LiveLocationScreen(),
      // home: SafeLocationListScreen(),
    ),
  );
}
