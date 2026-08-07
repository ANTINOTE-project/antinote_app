import 'package:antinote_app/ui/utils/utils.dart';
import 'package:flutter/material.dart';

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

  final Widget? prefixIcon;
  final Widget? suffixIcon;

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

    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: .all(color: context.c.onInverseSurface),
      ),

      child: TextField(
        controller: controller,

        onChanged: onChanged,
        onSubmitted: onSubmitted,

        autocorrect: autoCorrect,
        autofillHints: autofillHints,
        keyboardType: keyboardType,
        obscureText: obscureText,

        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(fontWeight: FontWeight.w600),

        decoration: InputDecoration(
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),

          hintStyle: TextStyle(
            color: context.c.outline,
            fontWeight: FontWeight.w600,
          ),
          hintText: hintText,
          hintMaxLines: 1,

          prefixIcon: prefixIcon,
          prefixIconConstraints: const BoxConstraints(minWidth: 48),

          suffixIcon: suffixIcon,
          suffixIconConstraints: const BoxConstraints(minWidth: 48),
        ),
      ),
    );
  }
}
