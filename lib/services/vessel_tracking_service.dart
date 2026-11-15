
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class VesselTrackingService {
  final int personnelId;
  final int vesselId;

  StreamSubscription<Position>? positionSubscription;

  bool isTracking = false;

  VesselTrackingService({
    required this.personnelId,
    required this.vesselId,
  });

  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost/lantsapp_api';
    }

    return 'http://10.0.2.2/lantsapp_api';
  }

  Future<bool> startTracking() async {
    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return false;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('Location permission was denied.');
        return false;
      }

      Position position =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final success = await sendLocation(
        position.latitude,
        position.longitude,
        'start',
      );

      if (!success) return false;

      isTracking = true;

      positionSubscription =
          Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position newPosition) async {
        if (!isTracking) return;

        await sendLocation(
          newPosition.latitude,
          newPosition.longitude,
          'update',
        );
      });

      return true;
    } catch (e) {
      debugPrint('Start tracking error: $e');
      return false;
    }
  }

  Future<bool> sendLocation(
    double latitude,
    double longitude,
    String action,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_vessel_location.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personnel_id': personnelId,
          'vessel_id': vesselId,
          'latitude': latitude,
          'longitude': longitude,
          'action': action,
        }),
      );

      debugPrint('Location response: ${response.body}');

      if (response.statusCode != 200) {
        return false;
      }

      final data = jsonDecode(response.body);

      return data['success'] == true;
    } catch (e) {
      debugPrint('Send location error: $e');
      return false;
    }
  }

  Future<void> stopTracking() async {
    isTracking = false;

    await positionSubscription?.cancel();
    positionSubscription = null;

    try {
      await http.post(
        Uri.parse('$baseUrl/update_vessel_location.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personnel_id': personnelId,
          'vessel_id': vesselId,
          'action': 'stop',
        }),
      );
    } catch (e) {
      debugPrint('Stop tracking error: $e');
    }
  }

  Future<void> dispose() async {
    await stopTracking();
  }
}
