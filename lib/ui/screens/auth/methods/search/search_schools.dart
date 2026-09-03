import 'dart:math';

import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/screens/auth/lists/workspaces.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/bottom_padding.dart';
import 'package:antinote_app/ui/widgets/customs/app_bar.dart';
import 'package:antinote_app/ui/widgets/customs/field.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

class SearchSchoolsMethodScreen extends StatefulWidget {
  final double lat;
  final double long;

  const SearchSchoolsMethodScreen({
    super.key,
    required this.lat,
    required this.long,
  });

  @override
  State<SearchSchoolsMethodScreen> createState() =>
      _SearchSchoolsMethodScreenState();
}

class _SearchSchoolsMethodScreenState extends State<SearchSchoolsMethodScreen> {
  final _controller = TextEditingController();

  final List<GeolocatedInstance> _mockInstances = List.generate(20, (i) {
    final r = Random(i);

    return GeolocatedInstance(
      baseUrl: Uri(),

      name: String.fromCharCodes(
        List.generate(r.nextInt(20) + 15, (_) => r.nextInt(26) + 97),
      ),

      postalCode: '00000',

      latitude: 0,
      longitude: 0,
      distance: 0,
    );
  });

  List<GeolocatedInstance>? _filteredInstances;
  List<GeolocatedInstance>? _instances;

  Future<void> _geolocateInstances() async {
    final instances = await findNearbyInstances(widget.lat, widget.long);

    setState(() {
      _filteredInstances = instances;
      _instances = instances;
    });
  }

  void _onSearch(String query) {
    setState(() {
      _filteredInstances = _instances
          ?.where(
            (element) => element.name.toLowerCase().trim().contains(
              query.trim().toLowerCase(),
            ),
          )
          .toList(growable: false);
    });
  }

  @override
  void initState() {
    super.initState();
    _geolocateInstances();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: Text(context.l10n.loginSchool)),

      body: Padding(
        padding: const .symmetric(horizontal: 12),

        child: Column(
          crossAxisAlignment: .start,

          children: [
            Padding(
              padding: const .only(bottom: 12),

              child: FieldWidget(
                controller: _controller,
                hintText: context.l10n.loginCitySubtitle,
                onChanged: _onSearch,
              ),
            ),

            Expanded(
              child: CustomScrollView(
                slivers: [
                  ListWidget(
                    items: _filteredInstances == null
                        ? _mockInstances
                        : _filteredInstances!,
                    isLoading: _filteredInstances == null,

                    itemBuilder: (context, instance, borderRadius) {
                      return TileWidget(
                        borderRadius: borderRadius,

                        onPressed: () async {
                          try {
                            final parameters =
                                await MobileInstanceParameters.fetch(
                                  instance.baseUrl,
                                );

                            if (context.mounted) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return WorkspacesListScreen(
                                      parameters: parameters!,
                                    );
                                  },
                                ),
                              );
                            }

                            // catch
                          } catch (e, st) {
                            logger.severe(
                              'Error during fetch of parameters',
                              e,
                              st,
                            );
                          }
                        },

                        leading: const Icon(HugeIconsSolid.school),

                        title: Text(instance.name),
                        subtitle: Text(
                          '${instance.distance.toStringAsFixed(2)} km',
                        ),

                        trailing: Icon(
                          HugeIconsSolid.arrowRight01,
                          color: context.c.outline,
                        ),
                      );
                    },
                  ),

                  const BottomPadding(padding: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
