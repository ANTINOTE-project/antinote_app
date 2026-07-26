import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/shell/tab.dart";
import "package:flutter/material.dart";

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
    bool partial,
  ) {
    // TODO: implement buildLoaded
    throw UnimplementedError();
  }

  @override
  Stream<double?> load(RemoteSession session) async* {}
}
