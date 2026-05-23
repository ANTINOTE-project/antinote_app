import "dart:async";
import "dart:convert";

import "package:antinote_app/frontend/extensions/colors.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/customs/field.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:http/http.dart" as http;
import "package:hugeicons_pro/hugeicons.dart";

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

  IconData get icon => switch (this) {
    city => HugeIconsSolid.building01,
    town => HugeIconsSolid.building02,
    village => HugeIconsSolid.home01,
    hamlet => HugeIconsSolid.house01,
    suburb => HugeIconsSolid.house04,
    municipality => HugeIconsSolid.city01,
    other => HugeIconsSolid.location01,
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

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json["name"] as String,
      latitude: double.parse(json["lat"] as String),
      longitude: double.parse(json["lon"] as String),
      postalCode: json["display_name"] != null
          ? RegExp(r"\b\d{5}\b").firstMatch(json["display_name"] as String)?.group(0) ?? ""
          : "",
      placeType: PlaceType.fromString(json["addresstype"] as String?),
    );
  }
}

class LoginSearchCityScreen extends StatefulWidget {
  const LoginSearchCityScreen({super.key});

  @override
  State<LoginSearchCityScreen> createState() => _LoginSearchCityScreenState();
}

class _LoginSearchCityScreenState extends State<LoginSearchCityScreen> {
  final _controller = TextEditingController();

  List<City> _cities = [];
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();

    super.dispose();
  }

  void _onQueryChanged() {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (_controller.text.trim().length >= 3) {
        _searchCities(_controller.text.trim());
      } else {
        setState(() => _cities = []);
      }
    });
  }

  Future<void> _searchCities(String query) async {
    if (query.length <= 3) return;

    final uri = Uri.https("nominatim.openstreetmap.org", "/search", {
      "q": query,
      "format": "json",
      "limit": "15",
      "countrycodes": "fr",
      "featuretype": "settlement",
    });

    final response = await http.get(uri, headers: {"User-Agent": "Antinote/1.0"});
    final data = jsonDecode(response.body) as List;

    if (mounted) {
      setState(() => _cities = data.map((e) => City.fromJson(e)).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: context.l10n.loginCity),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Padding(
            padding: const EdgeInsets.all(12),

            child: FieldWidget(
              controller: _controller,
              hintText: context.l10n.loginCitySubtitle,
              onChanged: (_) => _onQueryChanged(),
            ),
          ),

          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),

      child: CustomScrollView(
        slivers: [
          SliverList.builder(
            itemCount: _cities.length,

            itemBuilder: (_, index) {
              final city = _cities[index];

              return Pressable(
                onPressed: () {
                  context.push(
                    Routes.auth.search.school,
                    extra: {"lat": city.latitude, "long": city.longitude},
                  );
                },

                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),

                    child: Row(
                      spacing: 10,

                      children: [
                        Icon(city.placeType.icon),

                        Expanded(
                          child: Text(
                            city.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),

                        Text(
                          city.postalCode,
                          style: TextStyle(color: context.c.inversePrimary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
