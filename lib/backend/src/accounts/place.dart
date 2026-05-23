import "dart:convert";

import "package:antinote/antinote.dart";
import "package:http/http.dart" as http;

enum PlaceType {
  city,
  town,
  village,
  hamlet,
  suburb,
  municipality,
  other;

  static PlaceType fromString(String? value) => switch (value) {
    "city" => city,
    "town" => town,
    "village" => village,
    "hamlet" => hamlet,
    "suburb" => suburb,
    "municipality" => municipality,
    _ => other,
  };
}

class City {
  final String name;
  final double latitude;
  final double longitude;
  final String postalCode;
  final PlaceType placeType;

  const City({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.postalCode,
    this.placeType = PlaceType.other,
  });

  static Future<List<City>> fetchCitiesAroundPlace(String query) async {
    final uri = Uri.https("nominatim.openstreetmap.org", "/search", {
      "q": query,
      "format": "json",
      "limit": "15",
      "countrycodes": "fr",
      "featuretype": "settlement",
      "addressdetails": "1",
    });

    final response = await http.get(
      uri,
      headers: {"User-Agent": "Antinote/1.0"},
    );

    try {
      return (jsonDecode(response.body) as ListJsonNavigator)
          .cast<MapJsonNavigator>()
          .mapL((e) => (e).asCity());
    } catch (_) {
      return [];
    }
  }
}

extension AsCity on MapJsonNavigator {
  City asCity() {
    return City(
      name: get("name"),
      latitude: get("lat"),
      longitude: get("lon"),
      postalCode: getM("address").get("postcode"),
      placeType: PlaceType.fromString(get("addresstype")),
    );
  }
}
