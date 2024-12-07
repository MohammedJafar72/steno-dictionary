import 'package:flutter/material.dart';

class SdTextField extends StatelessWidget {
  final String hintText;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final Widget? prefixIcon;
  final Widget? suffixIcon; // Changed type to `Widget?` for flexibility
  final EdgeInsets? contentPadding;
  final Color? backgroundColor;
  final double borderRadius;
  final Function(String)? onChanged;
  final TextEditingController controller;

  const SdTextField({
    super.key,
    this.hintText = 'Search...',
    this.hintStyle,
    this.textStyle,
    required this.suffixIcon, // Now expects a `Widget?`
    required this.contentPadding,
    this.backgroundColor,
    this.borderRadius = 5.0,
    this.onChanged,
    required this.prefixIcon,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[800], // Default background color
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: hintStyle ?? const TextStyle(color: Colors.white54),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon, // Directly assign the suffix widget
          border: InputBorder.none, // No border
          contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
        style: textStyle ?? const TextStyle(color: Colors.white),
        onChanged: onChanged,
      ),
    );
  }
}
