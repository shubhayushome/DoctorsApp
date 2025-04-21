import 'package:doctors_app/patient/patient_auth_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
//import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class SafeLocationListScreen extends StatefulWidget {
  final Map<String, dynamic> patientData; // Receiving patient data
  final String userId;
  const SafeLocationListScreen(
      {super.key, required this.patientData, required this.userId});
  @override
  _SafeLocationListScreenState createState() => _SafeLocationListScreenState();
}

class _SafeLocationListScreenState extends State<SafeLocationListScreen> {
  List<Map<String, dynamic>> safeLocations = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchLocationData();
  }

  Future<void> fetchLocationData() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('Patients_data')
          .doc(widget.userId)
          .get();
      if (snapshot.exists) {
        setState(() {
          //live_location = snapshot.get('live_location') ?? {};
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

  Future<void> _addSafeLocation(Map<String, dynamic>? location) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var patientRef =
            _firestore.collection('Patients_data').doc(widget.userId);
        print(patientRef);
        transaction.update(patientRef, {
          'safeLocations': FieldValue.arrayUnion([location])
        });
        print(patientRef);
      });
      if (!mounted) return;
      setState(() {
        safeLocations.add(location!);
      });
    } catch (e) {
      print("Error $e");
    }
  }

  Future<void> _deleteSafeLocation(
      Map<String, dynamic>? location, int index) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var patientRef =
            _firestore.collection('Patients_data').doc(widget.userId);
        transaction.update(patientRef, {
          'safeLocations': FieldValue.arrayRemove([location])
        });
      });
      if (!mounted) return;
      setState(() {
        safeLocations.removeAt(index);
      });
    } catch (e) {
      print("Error $e");
    }
  }

  Future<void> _modifySafeLocation(Map<String, dynamic>? newLocation, int index,
      Map<String, dynamic>? oldLocation) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        var patientRef =
            _firestore.collection('Patients_data').doc(widget.userId);
        transaction.update(patientRef, {
          'safeLocations': FieldValue.arrayRemove([oldLocation])
        });
        transaction.update(patientRef, {
          'safeLocations': FieldValue.arrayUnion([newLocation])
        });
      });

      if (!mounted) return;
      setState(() {
        safeLocations[index] = newLocation!;
      });
    } catch (e) {
      print("Error updating location: $e");
    }
  }

  void _openLocationPicker() async {
    final LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LocationPickerScreen()),
    );

    if (selectedLocation != null &&
        !safeLocations.any((loc) =>
            loc['latitude'] == selectedLocation.latitude &&
            loc['longitude'] == selectedLocation.longitude)) {
      _showLocationDetailsModal(selectedLocation);
    } else if (selectedLocation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a new location.")),
      );
      _openLocationPicker();
    }
  }

  void _openMapForEdit(int index) async {
    final LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditableMapScreen(
          latitude: safeLocations[index]['latitude']!,
          longitude: safeLocations[index]['longitude']!,
          locationName: safeLocations[index]['name']!,
        ),
      ),
    );

    if (selectedLocation != null &&
        !safeLocations.any((loc) =>
            loc['latitude'] == selectedLocation.latitude &&
            loc['longitude'] == selectedLocation.longitude)) {
      _showLocationDetailsModal2(selectedLocation, index);
    } else if (selectedLocation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a new location.")),
      );
      _openMapForEdit(index);
    }
  }

  void _showLocationDetailsModal2(LatLng selectedLocation, int index) {
    String locationName = safeLocations[index]['name']!;
    LocationType selectedType =
        (safeLocations[index]['type'] as String).toLocationType();
    Hours selectedHours = (safeLocations[index]['hours']! as String).toHours();
    TextEditingController _locationController =
        TextEditingController(text: locationName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Modify Safe Location",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: "Location Name"),
                  onChanged: (value) => locationName = value,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField(
                  value: selectedType,
                  items: LocationType.values
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.name.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) selectedType = value;
                  },
                  decoration: const InputDecoration(labelText: "Type"),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField(
                  value: selectedHours,
                  items: Hours.values
                      .map((hours) => DropdownMenuItem(
                            value: hours,
                            child: Text(hours.name.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) selectedHours = value;
                  },
                  decoration: const InputDecoration(labelText: "Hours"),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (locationName.isNotEmpty) {
                          setState(() {
                            _modifySafeLocation({
                              'name': locationName,
                              'type': selectedType.toString().split('.').last,
                              'hours': selectedHours.toString().split('.').last,
                              'latitude': selectedLocation.latitude,
                              'longitude': selectedLocation.longitude,
                              'image': 'https://via.placeholder.com/150',
                            }, index, safeLocations[index]);
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLocationDetailsModal(LatLng selectedLocation) {
    String locationName = '';
    LocationType selectedType = LocationType.home;
    Hours selectedHours = Hours.Mon_Fri;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Add Safe Location",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(labelText: "Location Name"),
                  onChanged: (value) => locationName = value,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField(
                  value: selectedType,
                  items: LocationType.values
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.name.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) selectedType = value;
                  },
                  decoration: const InputDecoration(labelText: "Type"),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField(
                  value: selectedHours,
                  items: Hours.values
                      .map((hours) => DropdownMenuItem(
                            value: hours,
                            child: Text(hours.name.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) selectedHours = value;
                  },
                  decoration: const InputDecoration(labelText: "Hours"),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (locationName.isNotEmpty) {
                          setState(() {
                            _addSafeLocation({
                              'name': locationName,
                              'type': selectedType.toString().split('.').last,
                              'hours': selectedHours.toString().split('.').last,
                              'latitude': selectedLocation.latitude,
                              'longitude': selectedLocation.longitude,
                              'image': 'https://via.placeholder.com/150',
                            });
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
        title: Text('Safe Location List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _openLocationPicker, // Opens the map picker
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.builder(
          itemCount: safeLocations.length,
          itemBuilder: (context, index) {
            final location = safeLocations[index];
            return Dismissible(
              key: Key(location['name']!),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                final removedLocation = location;
                //safeLocations.removeAt(index);
                _deleteSafeLocation(location, index);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${removedLocation['name']} deleted'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        //_undoDelete(removedLocation, index);
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
              child: GestureDetector(
                onTap: () => _openMapForEdit(index),
                child: Card(
                  color: Colors.teal[200],
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            Text(
                              location['type']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.teal[500],
                              ),
                            ),
                            SizedBox(height: 4),
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

class LocationPickerScreen extends StatefulWidget {
  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng selectedLocation =
      LatLng(37.7749, -122.4194); // Default to San Francisco
  TextEditingController searchController = TextEditingController();
  List<dynamic> searchResults = [];
  final MapController _mapController =
      MapController(); // ✅ Added for map control

  // 🔍 Search for Locations
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=$query');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          searchResults = data;
        });
      }
    } catch (e) {
      print("Error searching location: $e");
    }
  }

  // 📍 Update Map When Location is Selected
  void _updateLocation(double lat, double lon) {
    setState(() {
      selectedLocation = LatLng(lat, lon);
      searchResults.clear(); // ✅ Clears results after selection
      searchController.clear();

      // 🎯 Move map to new location smoothly
      _mapController.move(selectedLocation, 14.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a Location'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController, // ✅ Added controller to move map
            options: MapOptions(
              initialCenter: selectedLocation,
              initialZoom: 12.0,
              onTap: (tapPosition, point) {
                setState(() {
                  selectedLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.your_app_name',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: selectedLocation,
                    width: 40.0,
                    height: 40.0,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40.0,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 🔍 Search Bar Positioned Above Map
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Search Location",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) => _searchLocation(value),
                ),

                // 📍 Search Results Dropdown
                if (searchResults.isNotEmpty)
                  Container(
                    color: Colors.white,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final result = searchResults[index];
                        return ListTile(
                          title: Text(result['display_name']),
                          onTap: () {
                            double lat = double.parse(result['lat']);
                            double lon = double.parse(result['lon']);
                            _updateLocation(lat, lon);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // ✅ Select Location Button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, selectedLocation);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Select Location'),
            ),
          ),
        ],
      ),
    );
  }
}

class EditableMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  EditableMapScreen({
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });
  @override
  _EditableMapScreenState createState() => _EditableMapScreenState();
}

class _EditableMapScreenState extends State<EditableMapScreen> {
  late LatLng _selectedLocation; // Default to San Francisco
  late TextEditingController _searchController;
  List<dynamic> searchResults = [];
  late MapController _mapController; // ✅ Added for map control

  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _mapController = MapController();
    _selectedLocation = LatLng(widget.latitude, widget.longitude);
  }

  // 🔍 Search for Locations
  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=$query');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          searchResults = data;
        });
      }
    } catch (e) {
      print("Error searching location: $e");
    }
  }

  // 📍 Update Map When Location is Selected
  void _updateLocation(double lat, double lon) {
    setState(() {
      _selectedLocation = LatLng(lat, lon);
      searchResults.clear(); // ✅ Clears results after selection
      _searchController.clear();

      // 🎯 Move map to new location smoothly
      _mapController.move(_selectedLocation, 14.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a Location'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController, // ✅ Added controller to move map
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 12.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.your_app_name',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 40.0,
                    height: 40.0,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40.0,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 🔍 Search Bar Positioned Above Map
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Search Location",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) => _searchLocation(value),
                ),

                // 📍 Search Results Dropdown
                if (searchResults.isNotEmpty)
                  Container(
                    color: Colors.white,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final result = searchResults[index];
                        return ListTile(
                          title: Text(result['display_name']),
                          onTap: () {
                            double lat = double.parse(result['lat']);
                            double lon = double.parse(result['lon']);
                            _updateLocation(lat, lon);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // ✅ Select Location Button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _selectedLocation);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Select Location'),
            ),
          ),
        ],
      ),
    );
  }
}
