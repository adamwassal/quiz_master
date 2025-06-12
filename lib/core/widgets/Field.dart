import 'package:flutter/material.dart';

class CustomField extends StatefulWidget {
  const CustomField({
    super.key,
    this.hintText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.icon = Icons.text_fields,
    this.suffixIcon,
    this.validator,
  });

  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool? obscureText;
  final IconData? icon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  State<CustomField> createState() => _CustomFieldState();
}

class _CustomFieldState extends State<CustomField> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      width: MediaQuery.of(context).size.width * 0.9, // Increased width for better fit
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText ?? false,
        validator: widget.validator,
        style: TextStyle(
          fontSize: 16,
          color: theme.textTheme.bodyLarge?.color ?? Colors.black87,
        ),
        cursorColor: theme.primaryColor,
        cursorHeight: 24,
        cursorWidth: 2,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          icon: Icon(widget.icon, color: theme.iconTheme.color?.withOpacity(0.7)),
          border: InputBorder.none,
          hintText: widget.hintText ?? 'Enter text',
          hintMaxLines: 1,
          hintStyle: TextStyle(color: Colors.grey[600]),
          suffixIcon: widget.suffixIcon,
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        ),
      ),
    );
  }
}