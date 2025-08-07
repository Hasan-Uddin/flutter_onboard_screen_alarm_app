import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:onboard_screen_alarm_app/constants/DirStrings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 600), () {
      _checkLocationPermission();
    });
  }

  Future<void> _checkLocationPermission() async {
    setState(() {});

    final status = await Permission.location.request();

    if (status == PermissionStatus.granted) {
      // Navigate to next screen or show location-based UI
      //Navigator.pushReplacementNamed(context, '/alarm');
      fetchAndSaveLocation();
    } else {
      setState(() {});
    }
  }

  Future<void> fetchAndSaveLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks.first;
      String address =
          '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_location', address);

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print('Error getting location: $e');
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome! Your\nPersonalized Alarm",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Allow us to sync your sunset alarm\nbased on your location.",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),
              Center(child: Image.asset(DirStrings.onBoarding_img_4)),
              SizedBox(height: 20),
              Container(
                //height: 60,
                margin: const EdgeInsets.all(40),
                width: MediaQuery.of(context).size.width * 1,
                child: Column(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        fetchAndSaveLocation();
                      },
                      //_checkingPermission ? null: _checkLocationPermission,
                      label: Text(
                        "Use Current Location",
                        style: TextStyle(fontSize: 20),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        minimumSize: Size(double.infinity, 53),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: Icon(Icons.location_on),
                      iconAlignment: IconAlignment.end,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      child: Text("Home", style: TextStyle(fontSize: 20)),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        minimumSize: Size(double.infinity, 53),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
  }
}
