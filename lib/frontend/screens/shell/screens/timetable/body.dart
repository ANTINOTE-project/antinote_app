import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/shell/screens/timetable/class.dart";
import "package:antinote_app/frontend/screens/shell/screens/timetable/class_block.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";

class TimetableBlockWidget extends StatefulWidget {
  final SpecificInstanceParameters displayParameters;
  final DateTime day;
  final ClassBlock block;

  const TimetableBlockWidget({
    super.key,
    required this.displayParameters,
    required this.day,
    required this.block,
  });

  @override
  State<TimetableBlockWidget> createState() => _TimetableBlockWidgetState();
}

class _TimetableBlockWidgetState extends State<TimetableBlockWidget> {
  int configurationIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    if (widget.block.configurations.length == 1) {
      return _buildWidgetConfiguration(
        context,
        widget.block.configurations.single,
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: .stretch,

        children: [
          Expanded(
            flex: 89,

            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              reverseDuration: const Duration(milliseconds: 50),

              switchInCurve: Curves.fastOutSlowIn,
              switchOutCurve: const ReversedCurve(Curves.fastOutSlowIn),

              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },

              child: IndexedStack(
                key: ValueKey(configurationIndex),
                index: configurationIndex,

                children: [
                  for (final configuration in widget.block.configurations)
                    _buildWidgetConfiguration(context, configuration),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 11,

            child: Container(
              padding: const .only(left: 4),

              decoration: BoxDecoration(
                borderRadius: .horizontal(right: const .circular(20)),
                color: context.c.surfaceContainerLow,
              ),

              clipBehavior: .antiAlias,

              child: Column(
                children: [
                  ...widget.block.configurations.asMap().entries.map((entry) {
                    final i = entry.key;

                    final borderRadius = BorderRadius.only(
                      bottomRight: i == 0 ? .zero : const .circular(16),
                      topLeft: i == 0 ? const .circular(4) : .zero,
                      topRight: i == widget.block.configurations.length - 1
                          ? .zero
                          : const .circular(16),
                      bottomLeft: i == widget.block.configurations.length - 1
                          ? const .circular(4)
                          : .zero,
                    );

                    return Expanded(
                      child: Pressable(
                        borderRadius: borderRadius,

                        onPressed: () {
                          if (i == configurationIndex) return;

                          setState(() => configurationIndex = i);
                        },

                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius: borderRadius,
                            color: i == configurationIndex
                                ? context.c.secondaryContainer
                                : null,
                          ),

                          child: Container(
                            alignment: .center,

                            child: Text(
                              (i + 1).toString(),
                              style: const TextStyle(fontWeight: .w800),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
