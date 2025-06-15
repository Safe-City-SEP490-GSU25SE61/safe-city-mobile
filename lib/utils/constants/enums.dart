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