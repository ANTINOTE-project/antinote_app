import 'dart:async';
import 'dart:math';

import 'package:antinote_app/data/src/accounts/place.dart';
import 'package:antinote_app/data/src/session/wrapper.dart';
import 'package:antinote_app/ui/screens/auth/search_schools.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/bottom_padding.dart';
import 'package:antinote_app/ui/widgets/customs/app_bar.dart';
import 'package:antinote_app/ui/widgets/customs/field.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

import 'account_type.dart';

class SearchCitiesScreen extends StatefulWidget {
  final AccountType accountType;

  const SearchCitiesScreen({super.key, required this.accountType});

  @override
  State<SearchCitiesScreen> createState() => _SearchCitiesScreenState();
}

class _SearchCitiesScreenState extends State<SearchCitiesScreen> {
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
      appBar: AppBarWidget(
        title: Text(context.l10n.loginCity),
        subtitle: Text(context.l10n.loginCitySubtitle),
      ),

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
                hintText: context.l10n.loginCityHint,
                onChanged: (_) => _onQueryChanged(),
                prefixIcon: const Icon(HugeIconsSolid.globalSearch),
                autofocus: true,
              ),
            ),

            Expanded(
              child: FutureBuilder(
                future: _cities,

                builder: (context, snapshot) {
                  if (snapshot.connectionState == .none) {
                    return const SizedBox.shrink();
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
                          return TileWidget(
                            borderRadius: borderRadius,

                            onPressed: () async {
                              final result =
                                  await Navigator.push<RegisterableAccount>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return SearchSchoolsScreen(
                                          lat: city.latitude,
                                          long: city.longitude,
                                          accountType: widget.accountType,
                                        );
                                      },
                                    ),
                                  );

                              if (result != null && context.mounted) {
                                Navigator.pop(context, result);
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
