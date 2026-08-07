import 'package:antinote_api/antinote_api.dart';
import 'package:flutter/material.dart';

class const MenuWidgetSliver({super.key, required final Menu value})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(child: Text('Menu'));
  }
}
