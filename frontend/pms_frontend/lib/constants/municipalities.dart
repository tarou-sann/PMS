import 'package:flutter/material.dart';

class Municipalities {
  static const List<String> municipalityOptions = [
    'Pila',
    'Sta Cruz',
    'Victoria',
    'Pagsanjan',
    'Nagcarlan',
    'Magdalena',
    'Calamba',
  ];

  static List<DropdownMenuItem<String>> getDropdownItems() {
    return municipalityOptions.map((municipality) => DropdownMenuItem(
      value: municipality,
      child: Text(municipality),
    )).toList();
  }
}