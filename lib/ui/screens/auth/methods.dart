import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/data/src/accounts/geolocation.dart';
import 'package:antinote_app/data/src/session/wrapper.dart';
import 'package:antinote_app/ui/screens/auth/account_type.dart';
import 'package:antinote_app/ui/screens/auth/qr_code.dart';
import 'package:antinote_app/ui/screens/auth/search_cities.dart';
import 'package:antinote_app/ui/screens/auth/url.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/bottom_padding.dart';
import 'package:antinote_app/ui/widgets/customs/app_bar.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:antinote_app/ui/widgets/customs/loading.dart';
import 'package:antinote_app/ui/widgets/text_icon.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'search_schools.dart';

typedef Method = ({
  IconData icon,
  String title,
  String subtitle,
  VoidCallback onPressed,
  bool loading,
});

class LoginMethodsScreen extends StatefulWidget {
  final AccountType accountType;

  const LoginMethodsScreen({super.key, required this.accountType});

  @override
  State<LoginMethodsScreen> createState() => _LoginMethodsScreenState();
}

class _LoginMethodsScreenState extends State<LoginMethodsScreen> {
  bool _geolocationLoading = false;

  List<Method> buildLocationOptions(BuildContext context) {
    return [
      (
        icon: HugeIconsSolid.location04,
        title: context.l10n.loginGeolocation,
        subtitle: context.l10n.loginGeolocationSubtitle,
        loading: _geolocationLoading,

        onPressed: () async {
          if (_geolocationLoading) return;
          setState(() => _geolocationLoading = true);

          final position = await fetchPosition();
          if (!context.mounted) return;

          if (position == null) {
            setState(() => _geolocationLoading = false);
            return;
          }

          final result = await Navigator.push<RegisterableAccount>(
            context,
            MaterialPageRoute(
              builder: (context) => SearchSchoolsScreen(
                lat: position.latitude,
                long: position.longitude,
                accountType: widget.accountType,
              ),
            ),
          );

          if (!context.mounted) return;
          setState(() => _geolocationLoading = false);

          if (result != null && context.mounted) {
            Navigator.pop(context, result);
          }
        },
      ),
      (
        icon: HugeIconsSolid.mapsSearch,
        title: context.l10n.loginCity,
        subtitle: context.l10n.loginCitySubtitle,
        loading: false,

        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return SearchCitiesScreen(accountType: widget.accountType);
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

  List<Method> buildAlternativeOptions(BuildContext context) {
    return [
      (
        icon: HugeIconsSolid.qrCode01,
        title: context.l10n.loginQrCode,
        subtitle: context.l10n.loginQrCodeSubtitle,
        loading: false,

        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const QRCodeLoginScreen();
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
        loading: false,

        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return UrlLoginScreen(accountType: widget.accountType);
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

  Method buildDemoOption(BuildContext context) {
    return (
      icon: HugeIconsSolid.testTube02,
      title: context.l10n.loginDemo,
      subtitle: context.l10n.loginDemoSubtitle,
      loading: false,

      onPressed: () async {
        final credentials = PasswordCredentials(
          username: 'demonstration',
          password: 'pronotevs',

          workspace: widget.accountType == .parent
              ? .parentMobile
              : .studentMobile,

          deviceUuid: Credentials.generateDeviceUuid(),
          baseUrl: Uri.parse('https://demo.index-education.net/pronote'),
          cookies: [],
        );

        final result = await credentials.login(
          options: context.s.networking.sessionOptions,
        );

        if (!context.mounted) return;

        final entry = SessionWrapper.register(result, credentials);
        Navigator.pop(context, entry);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationOptions = buildLocationOptions(context);
    final alternativeOptions = buildAlternativeOptions(context);

    return Scaffold(
      appBar: AppBarWidget(
        title: Text(context.l10n.loginMethodsTitle),
        subtitle: Text(context.l10n.loginMethodsSubtitle),
      ),

      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),

        slivers: [
          SliverPadding(
            padding: const .symmetric(horizontal: 12),

            sliver: SliverMainAxisGroup(
              slivers: [
                ListWidget(
                  items: locationOptions,
                  shrinkWrap: true,
                  itemBuilder: (context, item, borderRadius) {
                    return _Item(item: item, borderRadius: borderRadius);
                  },
                ),

                const SliverPadding(padding: .only(top: 16)),
                SliverTextIcon(label: context.l10n.loginAlternativeLabel),

                ListWidget(
                  items: alternativeOptions,
                  shrinkWrap: true,
                  itemBuilder: (context, item, borderRadius) {
                    return _Item(item: item, borderRadius: borderRadius);
                  },
                ),

                const SliverPadding(padding: .only(top: 16)),
                SliverTextIcon(label: context.l10n.loginDemoLabel),

                SliverToBoxAdapter(
                  child: _Item(
                    item: buildDemoOption(context),
                    borderRadius: const .all(ListWidget.radius),
                  ),
                ),

                const BottomPadding(padding: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final Method item;
  final BorderRadius borderRadius;

  const _Item({required this.item, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return TileWidget(
      borderRadius: borderRadius,
      onPressed: item.onPressed,

      leading: Icon(item.icon),
      title: Text(item.title, maxLines: 3),
      subtitle: Text(item.subtitle, maxLines: 3),

      trailing: Skeleton.ignore(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,

          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },

          child: item.loading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 20,
                  height: 20,
                  child: LoadingWidget(size: 15),
                )
              : SizedBox(
                  key: const ValueKey('arrow'),
                  width: 20,
                  height: 20,
                  child: Icon(
                    HugeIconsSolid.arrowRight01,
                    color: context.c.outline,
                  ),
                ),
        ),
      ),
    );
  }
}
