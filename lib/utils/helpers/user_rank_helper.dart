import '../constants/enums.dart';

UserRank getUserRankFromString(String name) {
  switch (name.toLowerCase()) {
    case 'bronze':
      return UserRank.bronze;
    case 'silver':
      return UserRank.silver;
    case 'gold':
      return UserRank.gold;
    case 'platinum':
      return UserRank.platinum;
    case 'protector':
      return UserRank.protector;
    case 'unrank':
    default:
      return UserRank.unrank;
  }
}
