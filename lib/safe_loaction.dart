import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
//import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SafeLocationListScreen extends StatefulWidget {
  @override
  _SafeLocationListScreenState createState() => _SafeLocationListScreenState();
}

class _SafeLocationListScreenState extends State<SafeLocationListScreen> {
  List<Map<String, String>> safeLocations = [
    {
      'name': 'City Hospital',
      'type': 'Hospital',
      'hours': 'Open 24/7',
      'latitude': '37.7749',
      'longitude': '-122.4194',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Uncle John’s House',
      'type': 'Hospital',
      'hours': 'Custom Hours',
      'latitude': '34.0522',
      'longitude': '-118.2437',
      'image': 'https://via.placeholder.com/150',
    },
  ];

  void _undoDelete(Map<String, String> location, int index) {
    setState(() {
      safeLocations.insert(index, location);
    });
  }

  void _openLocationPicker() async {
    final LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LocationPickerScreen()),
    );

    if (selectedLocation != null) {
      _showLocationDetailsModal(selectedLocation);
    }
  }

  void _openMapForEdit(int index) async {
    final LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditableMapScreen(
          latitude: double.parse(safeLocations[index]['latitude']!),
          longitude: double.parse(safeLocations[index]['longitude']!),
          locationName: safeLocations[index]['name']!,
        ),
      ),
    );

    if (selectedLocation != null) {
      _showLocationDetailsModal2(selectedLocation, index);
    }
  }

  void _showLocationDetailsModal2(LatLng selectedLocation, int index) {
    String locationName = safeLocations[index]['name']!;
    String selectedType = safeLocations[index]['type']!;
    String selectedHours = safeLocations[index]['hours']!;
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
                DropdownButtonFormField<String>(
                  value: selectedType,
                  items: ["Hospital", "Med Centre", "Friend/Family House"]
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) selectedType = value;
                  },
                  decoration: const InputDecoration(labelText: "Type"),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedHours,
                  items: ["Open 24/7", "Custom Hours"]
                      .map((hours) => DropdownMenuItem(
                            value: hours,
                            child: Text(hours),
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
                            safeLocations[index] = {
                              'name': locationName,
                              'type': selectedType,
                              'hours': selectedHours,
                              'latitude': selectedLocation.latitude.toString(),
                              'longitude':
                                  selectedLocation.longitude.toString(),
                              'image': 'https://via.placeholder.com/150',
                            };
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
    String selectedType = 'Hospital';
    String selectedHours = 'Open 24/7';

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
                DropdownButtonFormField<String>(
                  value: selectedType,
                  items: ["Hospital", "Med Centre", "Friend/Family House"]
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) selectedType = value;
                  },
                  decoration: const InputDecoration(labelText: "Type"),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedHours,
                  items: ["Open 24/7", "Custom Hours"]
                      .map((hours) => DropdownMenuItem(
                            value: hours,
                            child: Text(hours),
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
                            safeLocations.add({
                              'name': locationName,
                              'type': selectedType,
                              'hours': selectedHours,
                              'latitude': selectedLocation.latitude.toString(),
                              'longitude':
                                  selectedLocation.longitude.toString(),
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
                setState(() {
                  safeLocations.removeAt(index);
                });
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${removedLocation['name']} deleted'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        _undoDelete(removedLocation, index);
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
