import 'package:flutter/material.dart';

class StaticComponents {
  get emptyBox => const SizedBox(
        height: 0,
      );

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
        fillColor: const Color(0xFFF1F1F1),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
        enabledBorder: littleInputBorder,
        border: littleInputBorder,
        focusedBorder: littleInputBorder);
  }

  getMiddleInputDecoration(String hint) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
      enabledBorder: middleInputBorder,
      border: middleInputBorder,
      focusedBorder: middleInputBorder,
    );
  }

  getMiddleInputDecorationDisabled() {
    return InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        filled: true,
        enabled: false,
        fillColor: const Color(0xffD9D9D9),
        enabledBorder: middleInputBorder,
        border: middleInputBorder,
        focusedBorder: middleInputBorder);
  }

  getMiddleInputDecorationDisabledRoutine() {
    return InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        filled: true,
        enabled: false,
        fillColor: const Color(0xffF1F1F1),
        enabledBorder: middleInputBorder,
        border: middleInputBorder,
        focusedBorder: middleInputBorder);
  }

  getBigInputDecoration(String hint) {
    return InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
        enabledBorder: middleInputBorder,
        border: middleInputBorder,
        focusedBorder: middleInputBorder);
  }

  getBigInputDecorationDisabled() {
    return InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        filled: true,
        enabled: false,
        enabledBorder: middleInputBorder,
        border: middleInputBorder,
        focusedBorder: middleInputBorder);
  }

  getBigInputDecorationDisabledRoutine() {
    return InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        filled: true,
        enabled: false,
        fillColor: const Color(0xffF1F1F1),
        enabledBorder: middleInputBorder,
        border: middleInputBorder,
        focusedBorder: middleInputBorder);
  }
}
