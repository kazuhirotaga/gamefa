import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:real_quest/models/card.dart';
import 'package:real_quest/models/quest.dart';
import 'package:real_quest/providers.dart';
import 'package:real_quest/widgets/card_widget.dart';
import 'package:real_quest/services/supabase_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final userCardsAsync = ref.watch(userCardsProvider);
    final userQuestsAsync = ref.watch(userQuestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Real Quest'),
        actions: [
          IconButton(
            icon: const Icon(Icons.backpack_outlined),
            onPressed: () => context.push('/inventory'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SupabaseService().signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Status Section
            userProfileAsync.when(
              data: (profile) => _buildStatusCard(context, profile),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => _buildStatusCard(context, null), // Fallback to mock/empty
            ),
            const SizedBox(height: 24),
            
            // Active Quests
            Text('今日のクエスト', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            userQuestsAsync.when(
              data: (userQuests) {
                final activeQuests = userQuests
                    .where((q) => q.status == QuestStatus.active)
                    .take(3)
                    .toList();
                
                if (activeQuests.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('現在進行中のクエストはありません'),
                    ),
                  );
                }

                return Column(
                  children: activeQuests.map((uq) {
                    final quest = uq.quest;
                    if (quest == null) return const SizedBox.shrink();
                    return _buildQuestItem(
                      quest.title,
                      quest.description,
                      uq.currentProgress / quest.targetCount,
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => const Text('クエスト読み込みエラー'),
            ),
            const SizedBox(height: 24),

            // Recent Cards
            Text('最近獲得したカード', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: userCardsAsync.when(
                data: (cards) {
                  if (cards.isEmpty) {
                    return const Center(child: Text('カードがありません'));
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: cards.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return CardWidget(card: cards[index]);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => const Center(child: Text('読み込みエラー')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, Map<String, dynamic>? profile) {
    if (profile == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('ステータス読み込み中...')),
        ),
      );
    }

    final name = profile['display_name'] ?? '勇者タナカ';
    final level = (profile['level'] as int?) ?? 1;
    final hp = (profile['hp'] as int?) ?? 80;
    final maxHp = (profile['max_hp'] as int?) ?? 100;
    final mp = (profile['mp'] as int?) ?? 20;
    final maxMp = (profile['max_mp'] as int?) ?? 50;
    final exp = (profile['exp'] as int?) ?? 0;
    final coins = (profile['coins'] as int?) ?? 0;

    // Calculate EXP progress (Mock formula matching DB: 50 * L * (L+1) for next level)
    // Required EXP for current level L: 50 * (L-1) * L
    // Required EXP for next level L+1: 50 * L * (L+1)
    final currentLevelReq = 50 * (level - 1) * level;
    final nextLevelReq = 50 * level * (level + 1);
    final expProgress = (exp - currentLevelReq) / (nextLevelReq - currentLevelReq);
    final safeProgress = expProgress.clamp(0.0, 1.0);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 30, backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Lv. $level', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text('$coins G', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.amber[800])),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProgressBar('HP', hp / maxHp, Colors.red, '$hp / $maxHp'),
            const SizedBox(height: 8),
            _buildProgressBar('MP', mp / maxMp, Colors.blue, '$mp / $maxMp'),
            const SizedBox(height: 8),
            _buildProgressBar('EXP', safeProgress, Colors.green, '$exp / $nextLevelReq'),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, Color color, [String? textLabel]) {
    return Row(
      children: [
        SizedBox(width: 30, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
        Expanded(
          child: Stack(
            children: [
              LinearProgressIndicator(
                value: value,
                color: color,
                backgroundColor: color.withOpacity(0.2),
                minHeight: 16,
                borderRadius: BorderRadius.circular(4),
              ),
              if (textLabel != null)
                Center(
                  child: Text(
                    textLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 2, color: Colors.black)]),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestItem(String title, String desc, double progress) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.assignment, color: Colors.green),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(desc),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: progress, minHeight: 4),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
