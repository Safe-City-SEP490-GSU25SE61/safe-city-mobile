import 'package:flutter/material.dart';

import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/helpers/user_rank_gradient.dart';

class TRankProfileMenu extends StatelessWidget {
  final String title;
  final UserRank rank;

  const TRankProfileMenu({super.key, required this.title, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                gradient: getRankGradient(rank),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Image.asset(getRankImage(rank), width: 28, height: 28),
                  const SizedBox(width: 6),
                  Text(
                    getRankText(rank),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),

                ],
              ),
            ),
          ),

          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}
