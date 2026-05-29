import "dart:async";
import "dart:math";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/accounts/place.dart";
import "package:antinote_app/frontend/extensions/colors.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/customs/field.dart";
import "package:antinote_app/frontend/widgets/customs/list.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";
import "package:skeletonizer/skeletonizer.dart";

class LoginFindCityScreen extends StatefulWidget {
  const LoginFindCityScreen({super.key});

  @override
  State<LoginFindCityScreen> createState() => _LoginFindCityScreenState();
}

class _LoginFindCityScreenState extends State<LoginFindCityScreen> {
  final List<City> _mockCities = List.generate(15, (i) {
    final r = Random(i);

    return City(
      name: String.fromCharCodes(
        List.generate(r.nextInt(10) + 12, (_) => r.nextInt(26) + 97),
      ),

      address: String.fromCharCodes(
        List.generate(r.nextInt(15) + 20, (_) => r.nextInt(26) + 97),
      ),

      latitude: 0,
      longitude: 0,

      region: "",
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
            padding: const .all(12),

            // TODO: Faire en sorte que ça n'overflow pas.
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

                  final cities = _isLoading(snapshot)
                      ? _mockCities
                      : snapshot.requireData;

                  return Skeletonizer(
                    enabled: _isLoading(snapshot),

                    child: CustomScrollView(
                      slivers: [
                        ListWidget(
                          items: cities,

                          itemBuilder: (context, city, borderRadius) {
                            return ItemWidget(
                              borderRadius: borderRadius,

                              onPressed: () async {
                                final result = await context.push<LoginResult>(
                                  Routes.auth.school,

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

                              trailing: Icon(
                                HugeIconsSolid.arrowRight01,
                                color: context.c.outline,
                              ),

                              title: Text(
                                city.name,

                                overflow: .ellipsis,
                                maxLines: 1,

                                style: TextStyle(
                                  fontWeight: .w800,
                                  color: context.c.onPrimary,
                                ),
                              ),

                              subtitle: Text(
                                city.address,

                                overflow: .ellipsis,
                                maxLines: 1,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
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
