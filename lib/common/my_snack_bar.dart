import 'package:flutter/material.dart';

showMySnackBar({
  required BuildContext context,
  required String message,
  Color? color,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: TextStyle(fontSize: 23)),
      behavior: SnackBarBehavior.floating,
      backgroundColor: color ?? Color(0xFFFFAE37),
      duration: Duration(seconds: 2),
    ),
  );
}
