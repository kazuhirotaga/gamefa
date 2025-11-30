import 'package:flutter/material.dart';
import 'package:real_quest/models/card.dart';

class CardWidget extends StatelessWidget {
  final GameCard card;
  final VoidCallback? onTap;
  final bool isSmall;

  const CardWidget({
    required this.card,
    this.onTap,
    this.isSmall = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isSmall ? 80 : 160,
        height: isSmall ? 110 : 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getRarityColor(card.rarity),
            width: 2,
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: Container(
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.image, color: Colors.grey)),
                  // In real app: Image.network(card.imageUrl, fit: BoxFit.cover),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmall ? 10 : 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isSmall)
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < _getRarityStars(card.rarity) ? Icons.star : Icons.star_border,
                            size: 12,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRarityColor(Rarity rarity) {
    switch (rarity) {
      case Rarity.legendary: return Colors.amber;
      case Rarity.epic: return Colors.purple;
      case Rarity.rare: return Colors.blue;
      case Rarity.uncommon: return Colors.green;
      case Rarity.common: return Colors.grey;
    }
  }

  int _getRarityStars(Rarity rarity) {
    switch (rarity) {
      case Rarity.legendary: return 5;
      case Rarity.epic: return 4;
      case Rarity.rare: return 3;
      case Rarity.uncommon: return 2;
      case Rarity.common: return 1;
    }
  }
}
