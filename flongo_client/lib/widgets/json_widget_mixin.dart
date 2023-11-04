import 'package:flutter/material.dart';

mixin JSON_Widget_Mixin {
  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  dynamic convertToRawType(String value) {
    if (value.toLowerCase() == 'true') {
      return true;
    } else if (value.toLowerCase() == 'false') {
      return false;
    } else if (int.tryParse(value) != null) {
      return int.parse(value);
    } else {
      return value;
    }
  }
}
