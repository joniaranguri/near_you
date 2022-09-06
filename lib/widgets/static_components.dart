import 'package:flutter/material.dart';

class StaticComponents {
  get inputBorder => OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xffCECECE)),
      borderRadius: BorderRadius.circular(10));

  get littleInputBorder => OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFF999999)),
      borderRadius: BorderRadius.circular(5));

  get middleInputBorder => OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFF999999)),
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

  getLittleInputDecoration(String hint) {
    return InputDecoration(
        filled: true,
        fillColor: Color(0xFFF1F1F1),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
        enabledBorder: littleInputBorder,
        border: littleInputBorder,
        focusedBorder: littleInputBorder);
  }

  getMiddleInputDecoration(String hint) {
    return InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
        enabledBorder: middleInputBorder,
        border: middleInputBorder,
        focusedBorder: middleInputBorder);
  }
}
