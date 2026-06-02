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

  Widget _buildPicker(BuildContext context) {
    return Container(
      clipBehavior: .antiAlias,

      decoration: BoxDecoration(
        borderRadius: .horizontal(right: const .circular(20)),
        color: context.c.surfaceContainerLow,
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
            flex: 9,

            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              reverseDuration: const Duration(milliseconds: 50),

              switchInCurve: Curves.fastOutSlowIn,
              switchOutCurve: const ReversedCurve(Curves.fastOutSlowIn),

              child: IndexedStack(
                index: configurationIndex,

                children: [
                  for (final configuration in widget.block.configurations)
                    _buildWidgetConfiguration(context, configuration),
                ],
              ),
            ),
          ),

          Expanded(child: _buildPicker(context)),
        ],
      ),
    );
  }
}
