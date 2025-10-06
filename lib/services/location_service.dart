import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Checks if location services are enabled.
  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  /// Checks the current location permission status.
  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  /// Requests location permission from the user.
  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();

  /// Gets the current position or throws a descriptive exception.
  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Prompt the user to enable location services.
      await Geolocator.openLocationSettings();
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, prompt to open app settings.
      await Geolocator.openAppSettings();
      throw Exception('Location permissions are permanently denied');
    }

    // Return the current device position.
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  /// Converts coordinates into a human-readable address string.
  Future<String> getAddressFromLatLng(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isEmpty) return '$lat, $lon';
      final p = placemarks.first;
      return '${p.street ?? ''}, ${p.locality ?? ''}, ${p.administrativeArea ?? ''}, ${p.country ?? ''}'
          .replaceAll(RegExp(r'(, ){2,}'), ', ')
          .trim();
    } catch (e) {
      // If reverse geocoding fails, fall back to coordinates.
      return '$lat, $lon';
    }
  }

  /// Stream that continuously provides location updates.
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) {
    final locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
}
