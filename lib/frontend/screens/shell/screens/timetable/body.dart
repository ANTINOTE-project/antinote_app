import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/shell/screens/timetable/class.dart";
import "package:antinote_app/frontend/screens/shell/screens/timetable/class_block.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";

class TimetableBlockSliver extends StatefulWidget {
  final SpecificInstanceParameters displayParameters;
  final DateTime day;
  final ClassBlock block;

  const TimetableBlockSliver({
    super.key,
    required this.displayParameters,
    required this.day,
    required this.block,
  });

  @override
  State<TimetableBlockSliver> createState() => _TimetableBlockSliverState();
}

class _TimetableBlockSliverState extends State<TimetableBlockSliver> {
  int configurationIndex = 0;

  Widget _buildSliverConfiguration(
    BuildContext context,
    List<Class> configuration,
  ) {
    return SliverList.builder(
      key: ValueKey(configurationIndex),
      itemBuilder: (context, index) {
        return ClassWidget(
          clazz: configuration[index],
          connectRight: widget.block.configurations.length > 1,
        );
      },
      itemCount: configuration.length,
    );
  }

  Widget _buildWidgetConfiguration(
    BuildContext context,
    List<Class> configuration,
  ) {
    return Column(
      key: ValueKey(configurationIndex),
      children: [
        for (final clazz in configuration)
          ClassWidget(
            clazz: clazz,
            connectRight: widget.block.configurations.length > 1,
          ),
      ],
    );
  }

  Widget _buildPicker(BuildContext context) {
    return Container(
      clipBehavior: .antiAlias,
      decoration: BoxDecoration(
        color: context.c.surfaceContainerLow,
        borderRadius: .horizontal(left: .zero, right: const .circular(20)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < widget.block.configurations.length; i++)
            Expanded(
              child: Pressable(
                onPressed: () {
                  setState(() {
                    configurationIndex = i;
                  });
                },
                child: Container(
                  margin: .only(
                    left: 4,
                    right: 4,
                    top: i > 0 ? 1 : 4,
                    bottom: i == widget.block.configurations.length - 1 ? 4 : 1,
                  ),
                  decoration: BoxDecoration(
                    color: i == configurationIndex
                        ? context.c.tertiaryContainer
                        : null,
                    borderRadius: .only(
                      topRight: i == widget.block.configurations.length - 1
                          ? .zero
                          : const .circular(16),
                      bottomRight: i == 0 ? .zero : const .circular(16),
                    ),
                  ),
                  alignment: .center,
                  child: Text((i + 1).toString()),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.block.configurations.length == 1) {
      return _buildSliverConfiguration(
        context,
        widget.block.configurations.single,
      );
    }

    // TODO: Do something fancy here
    return SliverToBoxAdapter(
      // TODO: Avoid using this
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: .stretch,
          children: [
            const Expanded(child: Placeholder()),
            Expanded(
              flex: 8,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                alignment: .topCenter,
                curve: Curves.fastOutSlowIn,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  reverseDuration: const Duration(milliseconds: 50),
                  switchInCurve: Curves.fastOutSlowIn,
                  switchOutCurve: const ReversedCurve(Curves.fastOutSlowIn),
                  child: _buildWidgetConfiguration(
                    context,
                    widget.block.configurations[configurationIndex],
                  ),
                ),
              ),
            ),
            Expanded(child: _buildPicker(context)),
          ],
        ),
      ),
    );
  }
}
