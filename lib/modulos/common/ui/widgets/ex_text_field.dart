import 'package:flutter/material.dart';

class ExTextField extends StatelessWidget {
  final String hintText;

  const ExTextField({
    Key? key,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        decoration: InputDecoration(hintText: hintText));
  }
}
