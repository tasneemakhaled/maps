import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({super.key, required this.textEditingController, this.focusNode});
  final TextEditingController textEditingController;
  final FocusNode? focusNode;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      controller: textEditingController,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 24),
        hintText: 'Search here',
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
