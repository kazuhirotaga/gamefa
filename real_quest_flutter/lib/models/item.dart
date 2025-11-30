class ItemTemplate {
  final String id;
  final String name;
  final String? description;
  final String type;
  final String? effectType;
  final int? effectValue;
  final String? imageUrl;

  ItemTemplate({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    this.effectType,
    this.effectValue,
    this.imageUrl,
  });

  factory ItemTemplate.fromJson(Map<String, dynamic> json) {
    return ItemTemplate(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      effectType: json['effect_type'],
      effectValue: json['effect_value'],
      imageUrl: json['image_url'],
    );
  }
}

class UserItem {
  final String id;
  final String userId;
  final String templateId;
  final int quantity;
  final ItemTemplate? template;

  UserItem({
    required this.id,
    required this.userId,
    required this.templateId,
    required this.quantity,
    this.template,
  });

  factory UserItem.fromJson(Map<String, dynamic> json) {
    return UserItem(
      id: json['id'],
      userId: json['user_id'],
      templateId: json['template_id'],
      quantity: json['quantity'],
      template: json['item_templates'] != null
          ? ItemTemplate.fromJson(json['item_templates'])
          : null,
    );
  }
}
