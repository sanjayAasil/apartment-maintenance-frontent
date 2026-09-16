import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF4F6BED);
  static const secondary = Color(0xFF7C5CFC);
  static const background = Color(0xFFF5F7FC);
  static const ink = Color(0xFF202D45);
  static const muted = Color(0xFF617089);
  static const border = Color(0xFFE2E7F0);
}

enum AppTone {
  blue(Color(0xFF334DBB), Color(0xFFEEF2FF)),
  purple(Color(0xFF6540C7), Color(0xFFF2EEFF)),
  success(Color(0xFF167348), Color(0xFFEAF7EF)),
  warning(Color(0xFF945300), Color(0xFFFFF4E2)),
  danger(Color(0xFFB52B36), Color(0xFFFFEFF0)),
  info(Color(0xFF087580), Color(0xFFE9F8FA)),
  neutral(Color(0xFF536176), Color(0xFFF0F3F7));

  const AppTone(this.foreground, this.background);
  final Color foreground, background;
}

abstract final class AppSpacing {
  static const xs = 4.0, sm = 8.0, md = 12.0, lg = 16.0, xl = 24.0, xxl = 32.0;
}
