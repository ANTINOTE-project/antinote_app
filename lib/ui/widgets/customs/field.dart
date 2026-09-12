import 'package:antinote_app/ui/utils/utils.dart';
import 'package:material_ui/material_ui.dart';

class FieldWidget extends StatelessWidget {
  final TextEditingController controller;

  final Function(String)? onChanged;
  final Function(String)? onSubmitted;

  final bool? autoCorrect;
  final Iterable<String>? autofillHints;

  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? inputAction;
  final bool obscureText;
  final bool autofocus;

  final Widget? leading;
  final Widget? trailing;

  const FieldWidget({
    super.key,
    required this.controller,

    this.onChanged,
    this.onSubmitted,

    this.autoCorrect,
    this.autofillHints,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.inputAction,
    this.autofocus = false,

    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: const .all(.circular(18)),
      ),

      child: TextField(
        controller: controller,

        onChanged: onChanged,
        onSubmitted: onSubmitted,

        autocorrect: autoCorrect,
        autofillHints: autofillHints,
        keyboardType: keyboardType,
        obscureText: obscureText,
        autofocus: autofocus,

        textAlignVertical: .center,
        style: const TextStyle(fontWeight: .w600),

        decoration: InputDecoration(
          contentPadding: const .symmetric(horizontal: 16, vertical: 12),
          enabledBorder: .none,
          focusedBorder: .none,

          hintStyle: TextStyle(color: context.c.outline, fontWeight: .w600),
          hintText: hintText,
          hintMaxLines: 1,

          prefixIcon: leading,
          prefixIconConstraints: const BoxConstraints(minWidth: 48),

          suffixIcon: trailing,
          suffixIconConstraints: const BoxConstraints(minWidth: 48),
        ),
      ),
    );
  }
}
