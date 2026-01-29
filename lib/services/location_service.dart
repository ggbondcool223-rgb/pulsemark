import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

class LocationService {
  static Future<bool> checkPermission() async {
    final status = await Permission.location.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.location.request();
      return result.isGranted;
    }

    return false;
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        return null;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<String> getLocationName(
    double latitude,
    double longitude,
  ) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'format': 'json',
          'accept-language': 'en',
          'addressdetails': 1,
          'zoom': 10,
        },
        options: Options(
          headers: {
            'User-Agent': 'PulseMark/1.0',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        print('data: $data');
        final address = data['address'];

        final parts = <String>[];

        if (address['city'] != null && address['city'].toString().isNotEmpty) {
          parts.add(address['city']);
        } else if (address['town'] != null &&
            address['town'].toString().isNotEmpty) {
          parts.add(address['town']);
        } else if (address['village'] != null &&
            address['village'].toString().isNotEmpty) {
          parts.add(address['village']);
        } else if (address['county'] != null &&
            address['county'].toString().isNotEmpty) {
          parts.add(address['county']);
        } else if (address['state'] != null &&
            address['state'].toString().isNotEmpty) {
          parts.add(address['state']);
        }

        if (address['country'] != null &&
            address['country'].toString().isNotEmpty) {
          parts.add(address['country']);
        }

        if (parts.isNotEmpty) {
          return parts.join(', ');
        }
      }

      return await _getLocationNameFallback(latitude, longitude);
    } catch (e) {
      print('LocationService: Nominatim API error: $e');
      return await _getLocationNameFallback(latitude, longitude);
    }
  }

  static Future<String> _getLocationNameFallback(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        return 'Unknown Location';
      }

      final place = placemarks.first;

      final parts = <String>[];

      if (place.locality != null && place.locality!.isNotEmpty) {
        parts.add(place.locality!);
      } else if (place.subAdministrativeArea != null &&
          place.subAdministrativeArea!.isNotEmpty) {
        parts.add(place.subAdministrativeArea!);
      } else if (place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty) {
        parts.add(place.administrativeArea!);
      }

      if (place.country != null && place.country!.isNotEmpty) {
        parts.add(place.country!);
      }

      return parts.isNotEmpty ? parts.join(', ') : 'Unknown Location';
    } catch (e) {
      return 'Unknown Location';
    }
  }

  static Future<Map<String, dynamic>> getLocationInfo() async {
    try {
      print('LocationService: Starting location fetch...');

      final position = await getCurrentPosition();

      if (position == null) {
        print('LocationService: Failed to get position');
        return {
          'success': false,
          'latitude': 0.0,
          'longitude': 0.0,
          'location': 'Unknown Location',
          'error':
              'Could not get location. Please check permissions and location services.',
        };
      }

      print(
        'LocationService: Got position: ${position.latitude}, ${position.longitude}',
      );

      final locationName = await getLocationName(
        position.latitude,
        position.longitude,
      );

      print('LocationService: Location name: $locationName');

      return {
        'success': true,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'location': locationName,
      };
    } catch (e) {
      print('LocationService: Error: $e');
      return {
        'success': false,
        'latitude': 0.0,
        'longitude': 0.0,
        'location': 'Unknown Location',
        'error': e.toString(),
      };
    }
  }
}
