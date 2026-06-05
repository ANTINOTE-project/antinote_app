import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/screens/tab.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/customs/button.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TabMixin<HomeScreen> {
  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
  ) {
    return buildRefreshIndicator(
      child: Scaffold(
        appBar: AppBarWidget(
          backButton: false,

          actions: [
            IconButton(
              onPressed: () => context.push(Routes.settings),
              icon: const Icon(HugeIconsSolid.settings01),
            ),
          ],
        ),

        body: Padding(
          padding: const .symmetric(horizontal: 16),

          child: Column(
            mainAxisAlignment: .center,

            children: [
              // TODO remove this temporary button
              ButtonWidget(
                onPressed: () => context.push(Routes.auth.accounts),
                label: "Page de connexion",
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  FutureOr<void> loadActiveDataFromSession(PronoteSession session) {
    // TODO: implement loadActiveDataFromSession
  }
}
