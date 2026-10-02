import 'package:flutter/services.dart';

import '../constants.dart';
import 'package:flutter/material.dart';

class CustomTextformfield extends StatelessWidget {
  const CustomTextformfield({
    super.key,
    required this.validator,
    required this.onSaved,
    this.controller,
    this.isObscure = false,
    required this.fontSize,
    required this.fontColor,
    this.hintTextSize = 12,
    this.hintText = '',
    this.fillColor = Colors.black12,
    required this.height,
    required this.width,
    this.keyboardType = TextInputType.text,
    this.maxLength = 200,
    this.toggleIcon,
  });

  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final TextEditingController? controller;
  final bool isObscure;
  final double fontSize;
  final Color fontColor;
  final double height, width;
  final double hintTextSize;
  final String hintText;
  final Color fillColor;
  final TextInputType keyboardType;
  final int maxLength;
  final VoidCallback? toggleIcon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final outlineColor = colors.onSurface.withValues(alpha: 0.16);

    return TextFormField(
      validator: validator,
      onSaved: onSaved,
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
      style: TextStyle(fontSize: fontSize, color: fontColor),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(width, height, width, height),
        focusColor: FB_LIGHT_PRIMARY,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: outlineColor),
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.error),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        errorStyle: const TextStyle(fontFamily: 'Frutiger'),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.error, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: FB_PRIMARY, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        filled: true,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: hintTextSize,
          fontFamily: 'Frutiger',
        ),
        hintText: hintText,
        fillColor: fillColor,
        suffixIcon: toggleIcon != null
            ? IconButton(
                icon: Icon(
                  isObscure ? Icons.visibility_off : Icons.visibility,
                  color: fontColor,
                ),
                onPressed: toggleIcon,
              )
            : null,
      ),
    );
  }
}
