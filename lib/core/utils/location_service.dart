import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Simple test method to check location service status
  static Future<void> testLocationService() async {
    print('🔍 Testing location service...');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('🔍 Location service enabled: $serviceEnabled');
    
    LocationPermission permission = await Geolocator.checkPermission();
    print('🔍 Current permission: $permission');
  }

  /// Force show location dialog for testing
  static Future<void> forceShowLocationDialog(BuildContext context) async {
    print('🚀 Force showing location dialog...');
    await _showLocationServiceDialog(context);
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// Mandatory location - forces user to enable location services
  static Future<Position> getCurrentLocationMandatory(BuildContext context) async {
    print('🚀 Starting mandatory location process...');
    
    while (true) {
      // FIRST: Always check location service status
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('🔍 Location service enabled: $serviceEnabled');
      
      if (!serviceEnabled) {
        print('❌ Location service is OFF - showing dialog');
        await _showLocationServiceDialog(context);
        await Geolocator.openLocationSettings();
        
        // Wait for user to return from settings and enable location
        print('🔄 Waiting for user to enable location...');
        await _waitForLocationEnabled();
        continue;
      }

      // SECOND: Check permission only if service is enabled
      LocationPermission permission = await Geolocator.checkPermission();
      print('🔍 Current permission: $permission');
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print('🔍 After request permission: $permission');
        if (permission == LocationPermission.denied) {
          await _showPermissionDialog(context);
          continue;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Permission denied forever');
        bool? result = await _showSettingsDialog(context);
        if (result == true) {
          await Geolocator.openAppSettings();
        }
        await Future.delayed(Duration(seconds: 2));
        continue;
      }

      // THIRD: Try to get location only if both service and permission are OK
      try {
        print('✅ Trying to get location...');
        
        // Double check service before getting location
        bool serviceStillEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceStillEnabled) {
          print('❌ Location service turned OFF during process');
          continue; // Go back to start of loop
        }
        
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 0,
          ),
        ).timeout(Duration(seconds: 15));
        
        print('✅ Location obtained: ${position.latitude}, ${position.longitude}');
        return position;
        
      } catch (e) {
        print('❌ Location error: $e');
        
        // Check if error is due to location service being turned off
        bool serviceCheck = await Geolocator.isLocationServiceEnabled();
        if (!serviceCheck) {
          print('❌ Error because location service is OFF');
          continue; // Go back to start of loop
        }
        
        // Try with medium accuracy
        try {
          print('🔄 Trying with medium accuracy...');
          Position position = await Geolocator.getCurrentPosition(
            locationSettings: LocationSettings(
              accuracy: LocationAccuracy.medium,
              distanceFilter: 0,
            ),
          ).timeout(Duration(seconds: 10));
          
          print('✅ Location obtained with medium accuracy');
          return position;
          
        } catch (e2) {
          print('❌ Medium accuracy failed: $e2');
          
          // Final check for location service
          bool finalServiceCheck = await Geolocator.isLocationServiceEnabled();
          if (!finalServiceCheck) {
            print('❌ Location service turned OFF');
            continue; // Go back to start
          }
          
          // Show error dialog only if service is ON but still failing
          await _showErrorDialog(context);
          await Future.delayed(Duration(seconds: 2));
          continue;
        }
      }
    }
  }

  static Future<void> _showLocationServiceDialog(BuildContext context) async {
    print('💬 Showing location service dialog');
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Location Required'),
        content: Text('Please enable location service:\n\n1. Tap "Open Settings" below\n2. Turn ON "Location" or "GPS"\n3. Come back to app\n\nApp will automatically detect when location is enabled.'),
        actions:[
          TextButton(
            onPressed: () {
              print('💬 Dialog OK pressed');
              Navigator.pop(context);
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
    print('💬 Dialog closed');
  }

  static Future<void> _showPermissionDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Required'),
        content: Text('Please grant location permission to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  static Future<bool?> _showSettingsDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Denied'),
        content: Text('Location permission is permanently denied.\n\nPlease enable it from app settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  static Future<void> _showErrorDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Location Error'),
        content: Text('Unable to get location. Please check:\n\n• GPS is turned ON\n• You are not indoors\n• Internet connection is available\n\nTrying again...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Wait for location service to be enabled
  static Future<void> _waitForLocationEnabled() async {
    // Check every second for up to 30 seconds
    for (int i = 0; i < 30; i++) {
      await Future.delayed(Duration(seconds: 1));
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('🔍 Check $i: Location enabled: $serviceEnabled');
      
      if (serviceEnabled) {
        print('✅ Location service enabled by user!');
        return;
      }
    }
    print('⏰ Timeout waiting for location service');
  }
}