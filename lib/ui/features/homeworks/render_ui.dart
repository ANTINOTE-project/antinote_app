import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

extension HomeworkRenderUi on Homework {
  String renderLabel(BuildContext context) => switch (assignmentToRenderType) {
    .remoteRender => context.l10n.homeworkRenderPronote,
    .noRender => context.l10n.homeworkRenderNone,
    .paperRender => context.l10n.homeworkRenderPaper,
    .kiosqueRender => context.l10n.homeworkRenderKiosque, // unknown
    .remoteAudioRecordingRender => context.l10n.homeworkRenderPronoteAudio,
  };

  IconData? get renderIcon => switch (assignmentToRenderType) {
    .remoteRender => HugeIconsSolid.fileUpload,
    .noRender => null,
    .paperRender => HugeIconsSolid.course,
    .kiosqueRender => HugeIconsSolid.note01, // unknown
    .remoteAudioRecordingRender => HugeIconsSolid.mic01,
  };
}
