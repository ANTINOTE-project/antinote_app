import "dart:async";
import "dart:developer";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/accounts/place.dart";
import "package:antinote_app/frontend/extensions/colors.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/screens/auth/search/widgets/item.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/customs/field.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";

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

    final cities = await City.fetchCitiesAroundPlace(query);

    setState(() {
      _cities = cities;
    });

    log(_cities.length.toString());
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

              return ListItemCard(
                onPressed: () async {
                  final result = await context.push<LoginResult>(
                    Routes.auth.search.school,
                    extra: {"lat": city.latitude, "long": city.longitude},
                  );

                  if (result != null && mounted) {
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

                label: city.name,
                trailing: Text(
                  city.postalCode,
                  style: TextStyle(
                    color: context.c.inversePrimary,
                    fontWeight: FontWeight.w500,
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
