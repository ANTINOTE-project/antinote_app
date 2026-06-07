import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/shell/tabs/home/widgets/widget.dart";
import "package:antinote_app/frontend/widgets/customs/list.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";
import "package:intl/intl.dart";

class AttendanceWidget extends StatelessWidget {
  final VieScolaire data;

  const AttendanceWidget({super.key, required this.data});

  static final _dateFormat = DateFormat(DateFormat.MONTH_WEEKDAY_DAY);
  static final _timeFormat = DateFormat("HH'h'mm");

  String _formatDate(DateTime? date) {
    return date != null ? _dateFormat.format(date) : "—";
  }

  String _formatTime(DateTime? date) {
    return date != null ? _timeFormat.format(date) : "—";
  }

  @override
  Widget build(BuildContext context) {
    return HomeWidget(
      onShowMorePressed: () {},

      label: data.absences.length > 5
          ? "${context.l10n.homeAttendance} (+${data.absences.length - 5})"
          : context.l10n.homeAttendance,

      content: ListWidget(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        isSliver: false,
        isColumn: true,

        items: data.absences.take(5).toList(),

        itemBuilder: (context, absence, borderRadius) {
          final isJustified = absence.reasons.isNotEmpty;
          final title = isJustified
              ? absence.reasons.map((e) => e.name).join(", ")
              : context.l10n.absenceNotJustified;

          final date = _formatDate(absence.start);
          final startTime = _formatTime(absence.start);
          final endTime = _formatTime(absence.end);

          return ItemWidget(
            backgroundColor: context.c.surfaceContainerHigh,
            borderRadius: borderRadius,

            leading: Icon(
              isJustified ? HugeIconsSolid.tick03 : HugeIconsSolid.cancel02,
              color: isJustified ? context.c.primary : context.c.errorContainer,
            ),

            title: Text(title),
            subtitle: Text(
              context.l10n.absenceDuration(date, endTime, startTime),
            ),
          );
        },
      ),
    );
  }
}
