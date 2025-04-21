import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LiveLocationListScreen extends StatefulWidget {
  final Map<String, dynamic> patientData; // Receiving patient data
  final String userId;
  const LiveLocationListScreen(
      {super.key, required this.patientData, required this.userId});
  @override
  _LiveLocationListScreenState createState() => _LiveLocationListScreenState();
}

class _LiveLocationListScreenState extends State<LiveLocationListScreen> {
  // Dummy data for Safe Locations
  List<Map<String, dynamic>> safeLocations = [];
  Map<String, dynamic> live_location = {};
  Timer? _timer;

  // Dummy starting location
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchLocationData();
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchLocationData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchLocationData() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('Patients_data')
          .doc(widget.userId)
          .get();
      if (snapshot.exists) {
        setState(() {
          live_location = snapshot.get('live_location') ?? {};
          safeLocations = List<Map<String, dynamic>>.from(
              snapshot.data()?['safeLocations'] ?? []);
          // print(live_location);
          // print(safeLocations);
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void _openDirections(double destinationLatitude, double destinationLongitude,
      String location_name) async {
    double? startlat = live_location['latitude'];
    double? startlng = live_location['longitude'];
    double? destlat = destinationLatitude;
    double? destlng = destinationLongitude;

    if (startlat != null && startlng != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NavigationMapScreen(
                startLatitude: startlat,
                startLongitude: startlng,
                destinationLatitude: destlat,
                destinationLongitude: destlng,
                locationName: location_name)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid latitude or longitude"),
        ),
      );
    }
  }

  void _openMaps(BuildContext context) async {
    // User's current location (hardcoded for demo purposes)
    double? lat = live_location['latitude'];
    double? lng = live_location['longitude'];

    print(lat);
    print(lng);

    if (lat != null && lng != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(
            latitude: lat,
            longitude: lng,
            locationName: 'Live Location',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid latitude or longitude"),
        ),
      );
    }
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
        title: Text('Live Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.location_on),
            onPressed: () {
              // Placeholder for add functionality
              _openMaps(context);
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.builder(
          itemCount: safeLocations.length,
          itemBuilder: (context, index) {
            final location = safeLocations[index];
            return SizedBox(
              child: GestureDetector(
                onTap: () => _openDirections(location['latitude']!,
                    location['longitude']!, location['name']!),
                child: Card(
                  color: Colors.teal[200],
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Network Image
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12.0),
                        ),
                        child: Image.network(
                          location['image']!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Location Name
                            Text(
                              location['name']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal[700],
                              ),
                            ),
                            SizedBox(height: 4),
                            // Location Type
                            Text(
                              location['type']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.teal[500],
                              ),
                            ),
                            SizedBox(height: 4),
                            // Hours
                            Text(
                              location['hours']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.teal[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const MapScreen({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Marker> hospitalMarkers = [];

  @override
  void initState() {
    super.initState();
    fetchNearbyHospitals();
  }

  Future<void> fetchNearbyHospitals() async {
    final query =
        "[out:json];node[amenity=hospital](around:5000,${widget.latitude},${widget.longitude});out;";
    final url =
        Uri.parse('https://overpass-api.de/api/interpreter?data=$query');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Marker> markers = data['elements'].map<Marker>((element) {
          return Marker(
            point: LatLng(element['lat'], element['lon']),
            width: 40.0,
            height: 40.0,
            child: const Icon(
              Icons.local_hospital,
              color: Colors.blue,
              size: 40.0,
            ),
          );
        }).toList();

        setState(() {
          hospitalMarkers = markers;
        });
      }
    } catch (e) {
      print("Error fetching hospitals: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map for ${widget.locationName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(widget.latitude, widget.longitude),
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.doctors_app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(widget.latitude, widget.longitude),
                width: 40.0,
                height: 40.0,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40.0,
                ),
              ),
              ...hospitalMarkers,
            ],
          ),
        ],
      ),
    );
  }
}

class NavigationMapScreen extends StatefulWidget {
  final double startLatitude;
  final double startLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final String locationName;

  const NavigationMapScreen({
    Key? key,
    required this.startLatitude,
    required this.startLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.locationName,
  }) : super(key: key);

  @override
  _NavigationMapScreenState createState() => _NavigationMapScreenState();
}

class _NavigationMapScreenState extends State<NavigationMapScreen> {
  List<List<LatLng>> routes = [];
  List<double> travelTimes = [];
  List<LatLng> healthCenters = [];

  @override
  void initState() {
    super.initState();
    _fetchRoutes();
    _fetchHealthCenters();
  }

  Future<void> _fetchRoutes() async {
    final String osrmUrl =
        'https://router.project-osrm.org/route/v1/driving/${widget.startLongitude},${widget.startLatitude};${widget.destinationLongitude},${widget.destinationLatitude}?alternatives=true&overview=full&geometries=geojson';
    try {
      final response = await http.get(Uri.parse(osrmUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          routes = (data['routes'] as List)
              .map((route) => (route['geometry']['coordinates'] as List)
                  .map((coord) => LatLng(coord[1], coord[0]))
                  .toList())
              .toList();
          travelTimes = (data['routes'] as List)
              .map<double>(
                  (route) => (route['duration'] as num).toDouble() / 60)
              .toList();
        });
      } else {
        throw Exception("Failed to load routes");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _fetchHealthCenters() async {
    String overpassQuery =
        '[out:json];node[amenity=hospital](around:5000,${widget.destinationLatitude},${widget.destinationLongitude});out;';
    String overpassUrl =
        'https://overpass-api.de/api/interpreter?data=$overpassQuery';

    try {
      final response = await http.get(Uri.parse(overpassUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          healthCenters.addAll((data['elements'] as List)
              .map((node) => LatLng(node['lat'], node['lon'])));
        });
      }
    } catch (e) {
      print(e);
    }
    overpassQuery =
        '[out:json];node[amenity=hospital](around:5000,${widget.startLatitude},${widget.startLongitude});out;';
    overpassUrl = 'https://overpass-api.de/api/interpreter?data=$overpassQuery';

    try {
      final response = await http.get(Uri.parse(overpassUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          healthCenters.addAll((data['elements'] as List)
              .map((node) => LatLng(node['lat'], node['lon'])));
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Color getTrafficColor(double duration) {
    if (duration > 30) {
      return Colors.red;
    } else if (duration > 15) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    double _calculateTextWidth(String text) {
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(fontSize: 12),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();

      return textPainter.width;
    }

    return Scaffold(
      appBar: AppBar(title: Text('Route to ${widget.locationName}')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(widget.startLatitude, widget.startLongitude),
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          if (routes.isNotEmpty)
            PolylineLayer(
              polylines: List.generate(routes.length, (index) {
                return Polyline(
                  points: routes[index],
                  color: getTrafficColor(travelTimes[index]),
                  strokeWidth: 5.0,
                );
              }),
            ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(widget.startLatitude, widget.startLongitude),
                width: 40.0,
                height: 40.0,
                child: const Icon(Icons.location_pin,
                    color: Colors.green, size: 40.0),
              ),
              Marker(
                point: LatLng(
                    widget.destinationLatitude, widget.destinationLongitude),
                width: 40.0,
                height: 40.0,
                child: const Icon(Icons.location_pin,
                    color: Colors.red, size: 40.0),
              ),
              for (int i = 0; i < routes.length; i++)
                Marker(
                  point: routes[i][routes[i].length ~/ 2],
                  width: _calculateTextWidth(
                          "${travelTimes[i].toStringAsFixed(1)} min") +
                      16,
                  height: 30,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "${travelTimes[i].toStringAsFixed(1)} min",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              for (LatLng center in healthCenters)
                Marker(
                  point: center,
                  width: 30.0,
                  height: 30.0,
                  child: const Icon(Icons.local_hospital,
                      color: Colors.blue, size: 30.0),
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.teal,
        child: Text(
          "Multiple Routes Available - Estimated Travel Time Varies",
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
