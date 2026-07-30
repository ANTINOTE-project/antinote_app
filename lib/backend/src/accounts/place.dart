import 'dart:convert';

import 'package:antinote/antinote.dart';
import 'package:flutter/cupertino.dart';
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

class City {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? region;
  final PlaceType placeType;

  const City({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.region,
    this.placeType = PlaceType.other,
  });

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
      return (jsonDecode(response.body) as ListJsonNavigator)
          .cast<MapJsonNavigator>()
          .mapL((e) => (e).asCity());
    } catch (e, st) {
      debugPrintStack(stackTrace: st, label: e.toString());
      print(response.body);
      return [];
    }
  }
}

extension AsCity on MapJsonNavigator {
  City asCity() {
    return City(
      name: get('name'),
      address: get('display_name'),
      latitude: double.parse(get('lat')),
      longitude: double.parse(get('lon')),
      region: getM('address').get('region'),
      placeType: PlaceType.fromString(get('addresstype')),
    );
  }
}
