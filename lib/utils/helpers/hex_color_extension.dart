import 'package:flutter/material.dart';

extension HexColor on Color {
  static Color fromHex(String hexString) {
    if (hexString.isEmpty || !RegExp(r'^#?([0-9a-fA-F]{6})$').hasMatch(hexString)) {
      return Colors.blueGrey;
    }

    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Create a darker version of a color
  Color darken([double amount = .2]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final darkened = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkened.toColor();
  }
}
