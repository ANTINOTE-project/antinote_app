import "dart:async";
import "dart:math";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/accounts/place.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/screens/auth/search/widgets/item.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/customs/field.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";
import "package:skeletonizer/skeletonizer.dart";

class LoginSearchCityScreen extends StatefulWidget {
  const LoginSearchCityScreen({super.key});

  @override
  State<LoginSearchCityScreen> createState() => _LoginSearchCityScreenState();
}

class _LoginSearchCityScreenState extends State<LoginSearchCityScreen> {
  final _mockCities = List.generate(15, (i) {
    final r = Random(i);

    return (
      title: String.fromCharCodes(
        List.generate(r.nextInt(8) + 6, (_) => r.nextInt(26) + 97),
      ),
      subtitle: String.fromCharCodes(
        List.generate(r.nextInt(12) + 8, (_) => r.nextInt(26) + 97),
      ),
    );
  });

  final _controller = TextEditingController();

  Future<List<City>>? _cities;
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
        setState(() => _cities = null);
      }
    });
  }

  Future<void> _searchCities(String query) async {
    if (query.length < 3) return;

    setState(() {
      _cities = City.fetchCitiesAroundPlace(query);
    });
  }

  static bool _isLoading(AsyncSnapshot snapshot) {
    return snapshot.connectionState == .waiting ||
        snapshot.connectionState == .active ||
        !snapshot.hasData;
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

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),

              child: FutureBuilder(
                future: _cities,

                builder: (context, snapshot) {
                  if (snapshot.connectionState == .none) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: .center,
                        spacing: 6,

                        children: [
                          const Icon(HugeIconsSolid.mapsSearch, size: 48),

                          Text(
                            context.l10n.loginCity,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }

                  if (_isLoading(snapshot)) {
                    return Skeletonizer(
                      child: CustomScrollView(
                        slivers: [
                          SliverList.builder(
                            itemCount: _mockCities.length,

                            itemBuilder: (context, index) {
                              final mock = _mockCities[index];

                              return ListItemCard(
                                isLoading: true,
                                onPressed: null,

                                leading: const Icon(HugeIconsSolid.aspectRatio),

                                title: mock.title,
                                subtitle: mock.subtitle,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  final cities = snapshot.requireData;

                  return CustomScrollView(
                    slivers: [
                      SliverList.builder(
                        itemCount: cities.length,

                        itemBuilder: (context, index) {
                          final city = cities[index];

                          return ListItemCard(
                            onPressed: () async {
                              final result = await context.push<LoginResult>(
                                Routes.auth.search.school,
                                extra: {
                                  "lat": city.latitude,
                                  "long": city.longitude,
                                },
                              );

                              if (result != null && context.mounted) {
                                context.pop(result);
                              }
                            },

                            leading: Icon(switch (city.placeType) {
                              .city => HugeIconsSolid.building01,
                              .town => HugeIconsSolid.building02,
                              .village => HugeIconsSolid.home01,
                              .hamlet => HugeIconsSolid.house01,
                              .suburb => HugeIconsSolid.house04,
                              .municipality => HugeIconsSolid.city01,
                              .other => HugeIconsSolid.location01,
                            }),

                            title: city.name,
                            subtitle: city.address,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
