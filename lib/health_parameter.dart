import 'package:flutter/material.dart';

class HealthParameterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 145, 162, 235),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 26, 26, 156),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Health Parameters'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ParameterCard(
                parameterName: "Blood Pressure",
                value: "120/80",
                unit: "mmHg",
                icon: Icons.favorite,
                color: Colors.redAccent,
              ),
              ParameterCard(
                parameterName: "Pulse",
                value: "72",
                unit: "bpm",
                icon: Icons.favorite_rounded,
                color: Colors.pinkAccent,
              ),
              ParameterCard(
                parameterName: "Oxygen Level",
                value: "98",
                unit: "%",
                icon: Icons.bubble_chart,
                color: Colors.blueAccent,
              ),
              ParameterCard(
                parameterName: "Na+/K+ Level",
                value: "140/4",
                unit: "mmol/L",
                icon: Icons.water_drop,
                color: Colors.teal,
              ),
              ParameterCard(
                parameterName: "Hemoglobin Level",
                value: "13.5",
                unit: "g/dL",
                icon: Icons.bloodtype,
                color: Colors.deepOrangeAccent,
              ),
              ParameterCard(
                parameterName: "Blood Sugar Level",
                value: "90",
                unit: "mg/dL",
                icon: Icons.spa,
                color: Colors.green,
              ),
              ParameterCard(
                parameterName: "WBC & RBC Count",
                value: "5.5 / 4.7",
                unit: "million/mL",
                icon: Icons.invert_colors,
                color: Colors.purple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ParameterCard extends StatelessWidget {
  final String parameterName;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const ParameterCard({
    super.key,
    required this.parameterName,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width *
          0.45, // Set to 45% width of the screen
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(height: 10),
          Text(
            parameterName,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "$value $unit",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
