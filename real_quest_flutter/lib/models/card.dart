enum Rarity { common, uncommon, rare, epic, legendary }
enum CardCategory { nature, artifact, location, creature, other }

class GameCard {
  final String id;
  final String name;
  final String description;
  final Rarity rarity;
  final CardCategory category;
  final String imageUrl;
  final int attack;
  final int defense;
  final int speed;
  final int utility;
  final String? characterName;

  const GameCard({
    required this.id,
    required this.name,
    required this.description,
    required this.rarity,
    required this.category,
    required this.imageUrl,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.utility,
    this.characterName,
  });

  // Mock data factory
  factory GameCard.mock({
    String? id,
    String? name,
    Rarity? rarity,
  }) {
    return GameCard(
      id: id ?? 'mock_id',
      name: name ?? 'Mock Card',
      description: 'This is a mock card description.',
      rarity: rarity ?? Rarity.common,
      category: CardCategory.nature,
      imageUrl: 'https://placehold.co/300x400',
      attack: 50,
      defense: 50,
      speed: 50,
      utility: 50,
    );
  }
    // Factory for Supabase JSON
  // Factory for Supabase JSON
  factory GameCard.fromJson(Map<String, dynamic> json) {
    final template = json['card_templates'] as Map<String, dynamic>? ?? json;
    
    return GameCard(
      id: json['id'] as String,
      name: template['name'] as String? ?? 'Unknown Card',
      description: template['description'] as String? ?? '',
      rarity: _parseRarity(template['rarity'] as String?),
      category: _parseCategory(template['category'] as String?),
      imageUrl: template['image_url'] as String? ?? 'https://placehold.co/300x400',
      attack: (json['current_attack'] as int?) ?? (template['base_attack'] as int?) ?? 0,
      defense: (json['current_defense'] as int?) ?? (template['base_defense'] as int?) ?? 0,
      speed: (json['current_speed'] as int?) ?? (template['base_speed'] as int?) ?? 0,
      utility: (json['current_utility'] as int?) ?? (template['base_utility'] as int?) ?? 0,
      characterName: template['character_name'] as String?,
    );
  }

  static Rarity _parseRarity(String? rarity) {
    if (rarity == null) return Rarity.common;
    return Rarity.values.firstWhere(
      (e) => e.name == rarity,
      orElse: () => Rarity.common,
    );
  }

  static CardCategory _parseCategory(String? category) {
    if (category == null) return CardCategory.other;
    return CardCategory.values.firstWhere(
      (e) => e.name == category,
      orElse: () => CardCategory.other,
    );
  }
}
