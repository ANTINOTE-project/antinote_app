import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/extensions/colors.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/screens/auth/search/widgets/item.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/main.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";

class LoginSelectSchoolScreen extends StatefulWidget {
  final double lat;
  final double long;

  const LoginSelectSchoolScreen({
    super.key,
    required this.lat,
    required this.long,
  });

  @override
  State<LoginSelectSchoolScreen> createState() =>
      _LoginSelectSchoolScreenState();
}

class _LoginSelectSchoolScreenState extends State<LoginSelectSchoolScreen> {
  List<GeolocatedInstance> _instances = [];

  Future<void> geolocateInstances() async {
    final instances = await findNearbyInstances(widget.lat, widget.long);

    setState(() {
      _instances = instances;
    });
  }

  @override
  void initState() {
    super.initState();
    geolocateInstances();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: context.l10n.loginSchool),
      body: _buildList(),
    );
  }

  Widget _buildList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),

      child: CustomScrollView(
        slivers: [
          SliverList.builder(
            itemCount: _instances.length,

            itemBuilder: (context, index) {
              final instance = _instances[index];

              return ListItemCard(
                onPressed: () async {
                  try {
                    final parameters = await MobileInstanceParameters.fetch(
                      instance.baseUrl,
                    );
                    if (!context.mounted) return;

                    final result = await context.push<LoginResult>(
                      Routes.auth.workspace,
                      extra: {"parameters": parameters},
                    );

                    if (result != null && context.mounted) {
                      context.pop(result);
                    }

                    // catch
                  } catch (e, st) {
                    talker.error("Error during fetch of parameters", e, st);
                  }
                },

                leading: const Icon(HugeIconsSolid.school),
                title: instance.name,

                trailing: Text(
                  "${instance.distance.toStringAsFixed(2)} km",
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
