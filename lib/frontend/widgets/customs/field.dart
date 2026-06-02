import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";

class FieldWidget extends StatelessWidget {
  final TextEditingController controller;

  final Function(String)? onChanged;
  final Function(String)? onSubmitted;

  final bool autoCorrect;
  final Iterable<String> autofillHints;

  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;

  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const FieldWidget({
    super.key,
    required this.controller,

    this.onChanged,
    this.onSubmitted,

    this.autoCorrect = false,
    this.autofillHints = const <String>[],

    this.hintText = "",
    this.keyboardType = TextInputType.text,
    this.obscureText = false,

    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),

      child: TextField(
        controller: controller,

        onChanged: onChanged,
        onSubmitted: onSubmitted,

        autocorrect: autoCorrect,
        autofillHints: autofillHints,
        keyboardType: keyboardType,
        obscureText: obscureText,

        style: const TextStyle(fontWeight: .w600),

        decoration: InputDecoration(
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(horizontal: 16),

          hintStyle: TextStyle(color: context.c.outline, fontWeight: .w600),
          hintText: hintText,
          hintMaxLines: 1,

          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
