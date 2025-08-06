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

enum ReportRange { day,week, month, year }

extension ReportRangeExtension on ReportRange {
  String get value => toString().split('.').last;

  String get label {
    switch (this) {
      case ReportRange.day:
        return 'Hôm nay';
      case ReportRange.week:
        return 'Tuần này';
      case ReportRange.month:
        return 'Tháng này';
      case ReportRange.year:
        return 'Năm nay';
    }
  }
}

enum ReportSort { newest, oldest, urgent }

extension ReportSortExtension on ReportSort {
  String get value => toString().split('.').last;

  String get label {
    switch (this) {
      case ReportSort.newest:
        return 'Mới nhất';
      case ReportSort.oldest:
        return 'Cũ nhất';
      case ReportSort.urgent:
        return 'Khẩn cấp';
    }
  }
}

enum ReportPriority { low, medium, high, critical }

extension ReportPriorityExtension on ReportPriority {
  String get value => toString().split('.').last;

  String get label {
    switch (this) {
      case ReportPriority.low:
        return 'Thấp';
      case ReportPriority.medium:
        return 'Trung bình';
      case ReportPriority.high:
        return 'Cao';
      case ReportPriority.critical:
        return 'Khẩn cấp';
    }
  }

  Color get color {
    switch (this) {
      case ReportPriority.low:
        return Colors.green;
      case ReportPriority.medium:
        return Colors.orange;
      case ReportPriority.high:
        return Colors.deepOrange;
      case ReportPriority.critical:
        return Colors.red;
    }
  }
}


BlogType? mapBlogToType(String? input) {
  switch (input) {
    case 'Cảnh báo':
      return BlogType.alert;
    case 'Mẹo vặt':
      return BlogType.tip;
    case 'Sự kiện':
      return BlogType.event;
    case 'Tin tức':
      return BlogType.news;
    default:
      return null;
  }
}

enum BlogType { alert, tip, event, news }

extension BlogTypeExtension on BlogType {
  String get viLabel {
    switch (this) {
      case BlogType.alert:
        return 'Cảnh báo';
      case BlogType.tip:
        return 'Mẹo vặt';
      case BlogType.event:
        return 'Sự kiện';
      case BlogType.news:
        return 'Tin tức';
    }
  }

  String get apiValue {
    switch (this) {
      case BlogType.alert:
        return 'Alert';
      case BlogType.tip:
        return 'Tip';
      case BlogType.event:
        return 'Event';
      case BlogType.news:
        return 'News';
    }
  }

  static BlogType? fromViLabel(String? label) {
    switch (label) {
      case 'Cảnh báo':
        return BlogType.alert;
      case 'Mẹo vặt':
        return BlogType.tip;
      case 'Sự kiện':
        return BlogType.event;
      case 'Tin tức':
        return BlogType.news;
      default:
        return null;
    }
  }
}

enum FilterStatus {
  initial,
  idle,
  loadingFilters,
  loadingProvinces,
  loadingCommunes,
  success,
  error, ready,
}

String convertTimeToApiRange(String? time) {
  switch (time) {
    case "Tuần":
      return "week";
    case "Tháng":
      return "month";
    case "Quý":
      return "quarter";
    default:
      return "quarter";
  }
}

String convertStatusToApiValue(String? status) {
  switch (status) {
    case "Giao thông":
      return "Traffic";
    case "An ninh":
      return "Security";
    case "Hạ tầng":
      return "Infrastructure";
    case "Môi trường":
      return "Environment";
    case "Khác":
      return "Other";
    default:
      return "";
  }
}


