import 'dart:ui';

extension ColorInt on Color {
  int toArgbInt() {
    final a = (this.a * 255).round() & 0xff;
    final r = (this.r * 255).round() & 0xff;
    final g = (this.g * 255).round() & 0xff;
    final b = (this.b * 255).round() & 0xff;
    return (a << 24) | (r << 16) | (g << 8) | b;
  }
}
