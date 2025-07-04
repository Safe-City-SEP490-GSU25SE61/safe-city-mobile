import 'package:flutter/cupertino.dart';

import '../constants/enums.dart';

LinearGradient getRankGradient(UserRank rank) {
  switch (rank) {
    case UserRank.bronze:
      return const LinearGradient(
        colors: [Color(0xFFCD7F32), Color(0xFFAD6F25)],
      );
    case UserRank.silver:
      return const LinearGradient(
        colors: [Color(0xFFC0C0C0), Color(0xFFAAAAAA)],
      );
    case UserRank.gold:
      return const LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFFFC000)],
      );
    case UserRank.platinum:
      return const LinearGradient(
        colors: [Color(0xFFE5E4E2), Color(0xFFB0C4DE)],
      );
    case UserRank.protector:
      return const LinearGradient(
        colors: [Color(0xFF00C9A7), Color(0xFF00796B)],
      );
    case UserRank.unrank:
    return const LinearGradient(
        colors: [Color(0xFF888888), Color(0xFF666666)],
      );
  }
}
