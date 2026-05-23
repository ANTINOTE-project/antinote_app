import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/extensions/colors.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:antinote_app/main.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";

class LoginSearchSchoolScreen extends StatefulWidget {
  final double lat;
  final double long;

  const LoginSearchSchoolScreen({super.key, required this.lat, required this.long});

  @override
  State<LoginSearchSchoolScreen> createState() => _LoginSearchSchoolScreenState();
}

class _LoginSearchSchoolScreenState extends State<LoginSearchSchoolScreen> {
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

            itemBuilder: (_, index) {
              final instance = _instances[index];

              return Pressable(
                onPressed: () async {
                  try {
                    final parameters = MobileInstanceParameters.fetch(instance.baseUrl);
                    context.push(Routes.auth.search.select, extra: {"parameters": parameters});

                    // catch
                  } catch (e, st) {
                    talker.error("Error during fetch of parameters", e, st);
                  }
                },

                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),

                    child: Row(
                      spacing: 10,

                      children: [
                        const Icon(HugeIconsSolid.school),

                        Expanded(
                          child: Text(
                            instance.name.trim(),

                            maxLines: 1,
                            overflow: .ellipsis,

                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),

                        Text(
                          "${instance.distance.toStringAsFixed(2)} km",
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
