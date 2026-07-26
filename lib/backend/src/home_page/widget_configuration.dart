import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/home_page/widget/widget.dart";

const descriptors = <WidgetDescriptor>[MenuWidget()];

final class HomePageWidgetConfiguration({
  required final WidgetDescriptor descriptor,
  required final Map<String, dynamic> entries,
}) {
  factory fromJson(Map<String, dynamic> json) {
    final descriptor = descriptors.firstWhere((e) => e.id == json.get("id"));
    final params = json.getM("params");

    return .new(
      descriptor: descriptor,
      entries: {
        for (final argument in descriptor.arguments)
          for (final parameter in argument.parameters)
            parameter.descriptor.id.code:
                params.has(parameter.descriptor.id.code)
                ? parameter.descriptor.read(
                    params.get(parameter.descriptor.id.code),
                  )
                : parameter.descriptor.defaultValue,
      },
    );
  }

  Map<String, dynamic> toJson() => {
    "id": descriptor.id,
    "params": {
      for (final argument in descriptor.arguments)
        for (final parameter in argument.parameters)
          parameter.descriptor.id.code: parameter.descriptor.write(
            entries.get(parameter.descriptor.id.code) ??
                parameter.descriptor.defaultValue,
          ),
    },
  };
}
