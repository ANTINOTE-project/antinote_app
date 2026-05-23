import "dart:async";
import "dart:convert";

import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/customs/field.dart";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;

class City {
  final String name;
  final double latitude;
  final double longitude;

  const City({required this.name, required this.latitude, required this.longitude});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json["display_name"] as String,
      latitude: double.parse(json["lat"] as String),
      longitude: double.parse(json["lon"] as String),
    );
  }
}

class LoginSearchScreen extends StatefulWidget {
  const LoginSearchScreen({super.key});

  @override
  State<LoginSearchScreen> createState() => _LoginSearchScreenState();
}

class _LoginSearchScreenState extends State<LoginSearchScreen> {
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
    final uri = Uri.https("nominatim.openstreetmap.org", "/search", {
      "q": query,
      "format": "json",
      "limit": "10",
      "countrycodes": "fr",
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
      appBar: AppBarWidget(title: context.l10n.loginSearch),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Padding(
            padding: const EdgeInsets.all(12),

            child: FieldWidget(
              controller: _controller,
              hintText: context.l10n.loginSearchSubtitle,
              onChanged: (_) => _onQueryChanged(),
            ),
          ),

          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: _cities.length,
      itemBuilder: (_, index) {
        final city = _cities[index];

        return ListTile(
          title: Text(city.name),
          onTap: () {
            // TODO Select screen
          },
        );
      },
    );
  }
}
