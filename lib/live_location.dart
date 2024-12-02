import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveLocationListScreen extends StatefulWidget {
  @override
  _LiveLocationListScreenState createState() => _LiveLocationListScreenState();
}

class _LiveLocationListScreenState extends State<LiveLocationListScreen> {
  // Dummy data for Safe Locations
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
      'type': 'House of Relative',
      'hours': 'Daily 8 AM - 10 PM',
      'latitude': '34.0522',
      'longitude': '-118.2437',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Friend’s Apartment',
      'type': 'House of Friend',
      'hours': 'Mon-Fri 9 AM - 6 PM',
      'latitude': '40.7128',
      'longitude': '-74.0060',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'name': 'Family Safehouse',
      'type': 'Safe House',
      'hours': 'Daily 6 AM - 8 PM',
      'latitude': '48.8566',
      'longitude': '2.3522',
      'image': 'https://via.placeholder.com/150',
    },
  ];

  // Dummy starting location
  final String startLatitude = '37.7749';
  final String startLongitude = '-122.4194';

  void _undoDelete(Map<String, String> location, int index) {
    setState(() {
      safeLocations.insert(index, location);
    });
  }

  void _openDirections(
      String destinationLatitude, String destinationLongitude) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=$startLatitude,$startLongitude&destination=$destinationLatitude,$destinationLongitude&travelmode=driving';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open Google Maps for directions')),
      );
    }
  }

  void _openGoogleMaps(BuildContext context) async {
    // User's current location (hardcoded for demo purposes)
    double currentLat = 37.7749;
    double currentLng = -122.4194;

    // URL to center the map on the current location and add safe location markers
    String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$currentLat,$currentLng';

    // Launch Google Maps
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open Google Maps.')),
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
              _openGoogleMaps(context);
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
                onTap: () => _openDirections(
                  location['latitude']!,
                  location['longitude']!,
                ),
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
