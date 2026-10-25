import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

// ==========================================
// GOOGLE MAPS SERVICE
// Handles launching Google Maps navigation, pinpoints,
// and GIS coordinate parsing for civic incidents
// ==========================================

class GoogleMapsService {
  GoogleMapsService._();

  /// Parses strings like "23.0365° N, 72.5126° E (Ward 4)" into [lat, lng]
  static MapEntry<double, double>? parseGpsCoordinates(String gpsString) {
    try {
      final clean = gpsString.replaceAll('°', '').replaceAll('N', '').replaceAll('E', '').replaceAll('S', '-').replaceAll('W', '-');
      final parts = clean.split(',');
      if (parts.length >= 2) {
        final latStr = parts[0].replaceAll(RegExp(r'[^0-9\.\-]'), '').trim();
        final lngPart = parts[1].split('(')[0];
        final lngStr = lngPart.replaceAll(RegExp(r'[^0-9\.\-]'), '').trim();
        final lat = double.tryParse(latStr);
        final lng = double.tryParse(lngStr);
        if (lat != null && lng != null) {
          return MapEntry(lat, lng);
        }
      }
    } catch (e) {
      debugPrint('! Error parsing GPS coords "$gpsString": $e');
    }
    // Fallback coordinates for Ahmedabad Central Zone (AMC HQ)
    return const MapEntry(23.0225, 72.5714);
  }

  /// Opens Google Maps with a marker pin at the given coordinates
  static Future<bool> openMapLocation({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final encodedLabel = Uri.encodeComponent(label ?? 'Civic Complaint Location');
    // Universal Google Maps URL schema
    final urlString = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude($encodedLabel)';
    final uri = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('! Could not launch Google Maps: $e');
      return false;
    }
  }

  /// Opens Google Maps with turn-by-turn directions from user's current location to the incident
  static Future<bool> openDirections({
    required double destinationLat,
    required double destinationLng,
    String travelMode = 'driving', // driving, walking, bicycling, transit
  }) async {
    final urlString = 'https://www.google.com/maps/dir/?api=1&destination=$destinationLat,$destinationLng&travelmode=$travelMode';
    final uri = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('! Could not launch Google Maps directions: $e');
      return false;
    }
  }

  /// Opens Google Maps with a free-form search query (e.g. area name, landmark or complaint location)
  static Future<bool> openSearch(String query) async {
    final encoded = Uri.encodeComponent(query);
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('! Could not launch Google Maps search: $e');
      return false;
    }
  }

  /// Constructs a Google Static Maps URL for lightweight previews
  static String buildStaticMapUrl({
    required double latitude,
    required double longitude,
    int zoom = 15,
    int width = 600,
    int height = 240,
    String? apiKey,
  }) {
    if (apiKey != null && apiKey.isNotEmpty) {
      return 'https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=$zoom&size=${width}x$height&markers=color:red%7Clabel:C%7C$latitude,$longitude&key=$apiKey';
    }
    // Fallback static map representation
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=$zoom&size=${width}x$height&markers=color:red%7C$latitude,$longitude';
  }
}
