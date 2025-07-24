import 'package:flutter/material.dart';

import 'colors.dart';

enum TextSizes { small, medium, large }

enum PaymentMethods { payOS, visa, vnPay, moMo }

enum UserRank { unrank, bronze, silver, gold, platinum, protector }

String getRankText(UserRank rank) {
  switch (rank) {
    case UserRank.unrank:
      return 'Chưa xếp hạng';
    case UserRank.bronze:
      return 'Hạng Đồng';
    case UserRank.silver:
      return 'Hạng Bạc';
    case UserRank.gold:
      return 'Hạng Vàng';
    case UserRank.platinum:
      return 'Hạng Bạch Kim';
    case UserRank.protector:
      return 'Người bảo vệ';
  }
}

String getRankImage(UserRank rank) {
  switch (rank) {
    case UserRank.unrank:
      return "assets/images/ranking/unrank.png";
    case UserRank.bronze:
      return "assets/images/ranking/bronze-rank.png";
    case UserRank.silver:
      return "assets/images/ranking/silver-rank.png";
    case UserRank.gold:
      return "assets/images/ranking/gold-rank.png";
    case UserRank.platinum:
      return "assets/images/ranking/platinum-rank.png";
    case UserRank.protector:
      return "assets/images/ranking/protector-rank.png";
  }
}

enum ReportStatus { pending, verified, malicious, solved, cancelled, closed }

extension ReportStatusExtension on ReportStatus {
  String get value {
    return toString().split('.').last;
  }

  String get label {
    switch (this) {
      case ReportStatus.pending:
        return 'Đang chờ';
      case ReportStatus.verified:
        return 'Đã xác minh';
      case ReportStatus.malicious:
        return 'Báo cáo sai';
      case ReportStatus.solved:
        return 'Đã giải quyết';
      case ReportStatus.cancelled:
        return 'Đã hủy';
      case ReportStatus.closed:
        return 'Đã đóng';
    }
  }

  Color get color {
    switch (this) {
      case ReportStatus.pending:
        return TColors.warning;
      case ReportStatus.verified:
        return TColors.primary;
      case ReportStatus.malicious:
        return Colors.red;
      case ReportStatus.solved:
        return TColors.success;
      case ReportStatus.cancelled:
        return Colors.red;
      case ReportStatus.closed:
        return Colors.grey;
    }
  }
}

enum ReportRange { day, month, year }

extension ReportRangeExtension on ReportRange {
  String get value => toString().split('.').last;

  String get label {
    switch (this) {
      case ReportRange.day:
        return 'Hôm nay';
      case ReportRange.month:
        return 'Tháng này';
      case ReportRange.year:
        return 'Năm nay';
    }
  }
}
