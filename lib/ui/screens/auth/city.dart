import 'dart:async';
import 'dart:math';

import 'package:antinote/antinote.dart';
import 'package:antinote_app/data/src/accounts/place.dart';
import 'package:antinote_app/ui/routing/routes.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/bottom_padding.dart';
import 'package:antinote_app/ui/widgets/customs/app_bar.dart';
import 'package:antinote_app/ui/widgets/customs/field.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons_pro/hugeicons.dart';

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

      region: '',
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
      appBar: AppBarWidget(title: Text(context.l10n.loginCity)),

      body: Padding(
        padding: const .symmetric(horizontal: 12),

        child: Column(
          crossAxisAlignment: .start,

          children: [
            Padding(
              padding: const .only(bottom: 12),

              // TODO: Faire en sorte que ça n'overflow pas.
              child: FieldWidget(
                controller: _controller,
                hintText: context.l10n.loginCitySubtitle,
                onChanged: (_) => _onQueryChanged(),
              ),
            ),

            Expanded(
              child: FutureBuilder(
                future: _cities,

                builder: (context, snapshot) {
                  if (snapshot.connectionState == .none) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: .center,
                        spacing: 6,

                        children: [
                          Icon(
                            HugeIconsSolid.mapsSearch,
                            color: context.c.outlineVariant,
                            size: 48,
                          ),

                          Text(
                            context.l10n.loginCity,

                            style: TextStyle(
                              color: context.c.outlineVariant,
                              fontWeight: .bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final cities = _isLoading(snapshot)
                      ? _mockCities
                      : snapshot.requireData;

                  return CustomScrollView(
                    slivers: [
                      ListWidget(
                        isLoading: _isLoading(snapshot),
                        items: cities,

                        itemBuilder: (context, city, borderRadius) {
                          return ItemWidget(
                            borderRadius: borderRadius,

                            onPressed: () async {
                              final result = await context.push<LoginResult>(
                                Routes.auth.school,

                                extra: {
                                  'lat': city.latitude,
                                  'long': city.longitude,
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

                            title: Text(city.name),
                            subtitle: Text(city.address),
                          );
                        },
                      ),

                      const BottomPadding(padding: 10),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
