import 'dart:convert';

import 'package:antinote_api/antinote_api.dart';
import 'package:http/http.dart' as http;

enum PlaceType {
  city,
  town,
  village,
  hamlet,
  suburb,
  municipality,
  neighbourhood,
  locality,
  region,
  other;

  static PlaceType fromString(String? value) => switch (value) {
    'city' => city,
    'town' => town,
    'village' => village,
    'hamlet' => hamlet,
    'suburb' => suburb,
    'municipality' => municipality,
    'neighbourhood' ||
    'quarter' ||
    'city_district' ||
    'borough' => neighbourhood,
    'locality' || 'isolated_dwelling' => locality,
    'state' || 'region' || 'county' || 'state_district' => region,
    _ => other,
  };
}

final class const City({
  required final String name,
  required final String address,
  required final double latitude,
  required final double longitude,
  required final String? region,
  final PlaceType placeType = .other,
}) {
  factory decode(Map<String, dynamic> nav) {
    final addr = nav.getM('address');

    return .new(
      name:
          addr.get('city') ??
          addr.get('town') ??
          addr.get('village') ??
          addr.get('municipality') ??
          addr.get('hamlet') ??
          nav.get('name'),
      address: [addr.get('state'), addr.get('country')].nonNulls.join(', '),
      latitude: double.parse(nav.get('lat')),
      longitude: double.parse(nav.get('lon')),
      region: addr.get('state'),
      placeType: PlaceType.fromString(nav.get('type')),
    );
  }

  static Future<List<City>> fetchCitiesAroundPlace(String query) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'json',
      'limit': '15',
      'featureType': 'settlement',
      'addressdetails': '1',
    });

    final response = await http.get(
      uri,
      headers: {'User-Agent': 'Antinote/1.0'},
    );

    try {
      return (jsonDecode(response.body) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .mapL((e) => .decode(e));
    } catch (e, st) {
      logger.severe('Failed to decode request', e, st);
      return [];
    }
  }
}
