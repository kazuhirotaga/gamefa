enum QuestType { daily, weekly, story, event }
enum QuestStatus { active, completed, claimed }

class Quest {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final String targetAction;
  final int targetCount;
  final int rewardExp;
  final int rewardCoins;

  const Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetAction,
    required this.targetCount,
    required this.rewardExp,
    required this.rewardCoins,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      type: _parseType(json['type'] as String?),
      targetAction: json['target_action'] as String? ?? '',
      targetCount: json['target_count'] as int? ?? 1,
      rewardExp: json['reward_exp'] as int? ?? 0,
      rewardCoins: json['reward_coins'] as int? ?? 0,
    );
  }

  static QuestType _parseType(String? type) {
    if (type == null) return QuestType.daily;
    return QuestType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => QuestType.daily,
    );
  }
}

class UserQuest {
  final String id;
  final String userId;
  final String questId;
  final QuestStatus status;
  final int currentProgress;
  final Quest? quest; // Joined quest data

  const UserQuest({
    required this.id,
    required this.userId,
    required this.questId,
    required this.status,
    required this.currentProgress,
    this.quest,
  });

  factory UserQuest.fromJson(Map<String, dynamic> json) {
    Quest? questData;
    if (json['quests'] != null) {
      questData = Quest.fromJson(json['quests'] as Map<String, dynamic>);
    }

    return UserQuest(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      questId: json['quest_id'] as String,
      status: _parseStatus(json['status'] as String?),
      currentProgress: json['current_progress'] as int? ?? 0,
      quest: questData,
    );
  }

  static QuestStatus _parseStatus(String? status) {
    if (status == null) return QuestStatus.active;
    return QuestStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => QuestStatus.active,
    );
  }
}
