import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_quest/models/quest.dart';
import 'package:real_quest/providers.dart';

class QuestScreen extends ConsumerWidget {
  const QuestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userQuestsAsync = ref.watch(userQuestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('クエスト')),
      body: userQuestsAsync.when(
        data: (userQuests) {
          if (userQuests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('クエストがありません'),
                  ElevatedButton(
                    onPressed: () async {
                      // Initialize quests for user (mock logic for prototype)
                      final userId = ref.read(userIdProvider);
                      if (userId != null) {
                        final service = ref.read(questServiceProvider);
                        final allQuests = await service.getQuests();
                        for (final q in allQuests) {
                          await service.startQuest(userId, q.id);
                        }
                        ref.refresh(userQuestsProvider);
                      }
                    },
                    child: const Text('クエストを開始する'),
                  ),
                ],
              ),
            );
          }

          // Group by type or status if needed
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: userQuests.length,
            itemBuilder: (context, index) {
              final uq = userQuests[index];
              return QuestItemWidget(userQuest: uq);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
    );
  }
}

class QuestItemWidget extends ConsumerWidget {
  final UserQuest userQuest;

  const QuestItemWidget({super.key, required this.userQuest});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quest = userQuest.quest;
    if (quest == null) return const SizedBox.shrink();

    final progress = userQuest.currentProgress / quest.targetCount;
    final isCompleted = userQuest.status == QuestStatus.completed;
    final isClaimed = userQuest.status == QuestStatus.claimed;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    quest.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                if (isClaimed)
                  const Chip(label: Text('受取済み'), backgroundColor: Colors.grey)
                else if (isCompleted)
                  ElevatedButton(
                    onPressed: () async {
                      await ref.read(questServiceProvider).claimReward(userQuest.id);
                      ref.refresh(userQuestsProvider);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text('報酬を受け取る'),
                  )
                else
                  Text('${userQuest.currentProgress} / ${quest.targetCount}'),
              ],
            ),
            const SizedBox(height: 8),
            Text(quest.description),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              color: isCompleted ? Colors.green : Colors.blue,
            ),
            const SizedBox(height: 8),
            Text(
              '報酬: ${quest.rewardCoins}コイン / ${quest.rewardExp}EXP',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
