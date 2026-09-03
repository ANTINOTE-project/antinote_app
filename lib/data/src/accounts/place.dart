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
  other;

  static PlaceType fromString(String? value) => switch (value) {
    'city' => city,
    'town' => town,
    'village' => village,
    'hamlet' => hamlet,
    'suburb' => suburb,
    'municipality' => municipality,
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
  factory decode(Map<String, dynamic> nav) => .new(
    name: nav.get('name'),
    address: nav.get('display_name'),
    latitude: double.parse(nav.get('lat')),
    longitude: double.parse(nav.get('lon')),
    region: nav.getM('address').get('region'),
    placeType: PlaceType.fromString(nav.get('addresstype')),
  );

  static Future<List<City>> fetchCitiesAroundPlace(String query) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'json',
      'limit': '15',
      'featuretype': 'settlement',
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
