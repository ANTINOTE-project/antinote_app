import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/data/src/session/wrapper.dart';
import 'package:antinote_app/ui/screens/auth/methods/qr_code.dart';
import 'package:antinote_app/ui/screens/auth/methods/search/search_cities.dart';
import 'package:antinote_app/ui/screens/auth/methods/url.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/customs/app_bar.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:antinote_app/ui/widgets/text_icon.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

typedef Method = ({
  IconData icon,
  String title,
  String subtitle,
  VoidCallback onPressed,
});

class MethodsListScreen extends StatelessWidget with WidgetsBindingObserver {
  const MethodsListScreen({super.key});

  List<Method> buildOptions(BuildContext context) {
    return [
      (
        icon: HugeIconsSolid.mapsSearch,

        title: context.l10n.loginCity,
        subtitle: context.l10n.loginCitySubtitle,

        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const SearchCitiesMethodScreen();
              },
            ),
          );
          if (result != null && context.mounted) {
            Navigator.pop(context, result);
          }
        },
      ),
      (
        icon: HugeIconsSolid.qrCode01,

        title: context.l10n.loginQrCode,
        subtitle: context.l10n.loginQrCodeSubtitle,

        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const QRCodeMethodScreen();
              },
            ),
          );
          if (result != null && context.mounted) {
            Navigator.pop(context, result);
          }
        },
      ),
      (
        icon: HugeIconsSolid.link04,

        title: context.l10n.loginUrl,
        subtitle: context.l10n.loginUrlSubtitle,

        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const UrlMethodScreen();
              },
            ),
          );
          if (result != null && context.mounted) {
            Navigator.pop(context, result);
          }
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final options = buildOptions(context);

    return Scaffold(
      appBar: AppBarWidget(title: Text(context.l10n.addAnAccount)),

      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const .symmetric(horizontal: 12),

            sliver: SliverMainAxisGroup(
              slivers: [
                ListWidget(
                  shrinkWrap: true,
                  items: options,

                  itemBuilder: (context, item, borderRadius) {
                    return TileWidget(
                      borderRadius: borderRadius,
                      onPressed: item.onPressed,

                      leading: Icon(item.icon),
                      title: Text(item.title, maxLines: 3),
                      subtitle: Text(item.subtitle, maxLines: 3),

                      trailing: Skeleton.ignore(
                        child: Icon(
                          HugeIconsSolid.arrowRight01,
                          color: context.c.outline,
                        ),
                      ),
                    );
                  },
                ),

                SliverTextIcon(label: context.l10n.loginDemoText),

                SliverToBoxAdapter(
                  child: TileWidget(
                    borderRadius: const .all(ListWidget.radius),
                    onPressed: () async {
                      final credentials = PasswordCredentials(
                        username: 'demonstration',
                        password: 'pronotevs',

                        workspace: .studentMobile,

                        deviceUuid: Credentials.generateDeviceUuid(),
                        baseUrl: Uri.parse(
                          'https://demo.index-education.net/pronote',
                        ),
                        cookies: [],
                      );

                      final result = await credentials.login(
                        options: context.s.networking.sessionOptions,
                      );

                      if (!context.mounted) return;

                      final entry = SessionWrapper.register(
                        result,
                        credentials,
                      );
                      Navigator.pop(context, entry);
                    },

                    leading: const Icon(HugeIconsSolid.testTube02),

                    title: Text(context.l10n.loginDemo, maxLines: 3),

                    subtitle: Text(context.l10n.loginDemoSubtitle, maxLines: 3),

                    trailing: Skeleton.ignore(
                      child: Icon(
                        HugeIconsSolid.arrowRight01,
                        color: context.c.outline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
