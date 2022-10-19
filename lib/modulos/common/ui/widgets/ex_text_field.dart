import 'package:flutter/material.dart';

class ExTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;

  const ExTextField({
    Key? key,
    required this.hintText,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        decoration: InputDecoration(hintText: hintText));
  }
}
