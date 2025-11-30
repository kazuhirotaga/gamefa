class MonsterTemplate {
  final String id;
  final String name;
  final String? description;
  final String? element;
  final String? imageUrl;
  final int hp;
  final int attack;
  final int defense;
  final int speed;
  final int expReward;
  final int coinReward;

  MonsterTemplate({
    required this.id,
    required this.name,
    this.description,
    this.element,
    this.imageUrl,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.expReward,
    required this.coinReward,
  });

  factory MonsterTemplate.fromJson(Map<String, dynamic> json) {
    return MonsterTemplate(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      element: json['element'],
      imageUrl: json['image_url'],
      hp: json['hp'] ?? 100,
      attack: json['attack'] ?? 10,
      defense: json['defense'] ?? 5,
      speed: json['speed'] ?? 10,
      expReward: json['exp_reward'] ?? 10,
      coinReward: json['coin_reward'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'element': element,
      'image_url': imageUrl,
      'hp': hp,
      'attack': attack,
      'defense': defense,
      'speed': speed,
      'exp_reward': expReward,
      'coin_reward': coinReward,
    };
  }
}
