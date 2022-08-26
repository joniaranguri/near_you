import 'package:flutter/material.dart';

class StaticComponents {
  get inputBorder => OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xffCECECE)),
      borderRadius: BorderRadius.circular(10));

  getInputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: Color(0xffCECECE)),
      contentPadding: const EdgeInsets.all(15),
      enabledBorder: inputBorder,
      border: inputBorder,
    );
  }
}
