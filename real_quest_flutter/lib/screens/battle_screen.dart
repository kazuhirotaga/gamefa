import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_quest/providers.dart';

class BattleScreen extends ConsumerStatefulWidget {
  const BattleScreen({super.key});

  @override
  ConsumerState<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends ConsumerState<BattleScreen> {
  bool _isLoading = false;
  List<String> _battleLog = ['野生のモンスターが現れた！'];
  
  // Mock Battle State
  int _enemyHp = 100;
  int _maxEnemyHp = 100;
  int _userHp = 100;
  int _maxUserHp = 100;
  bool _isBattleOver = false;

  Future<void> _performAction(String action) async {
    if (_isLoading || _isBattleOver) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ref.read(supabaseServiceProvider).performBattleAction(
        battleId: 'mock-battle-id',
        action: action,
        targetId: 'mock-enemy-id',
      );

      final damageDealt = result['damageDealt'] as int;
      final damageTaken = result['damageTaken'] as int;
      final isWin = result['isWin'] as bool;
      final rewards = result['rewards'];

      setState(() {
        _enemyHp = (_enemyHp - damageDealt).clamp(0, _maxEnemyHp);
        _battleLog.add('あなたの攻撃！ $damageDealt のダメージ！');

        if (isWin) {
          _enemyHp = 0;
          _isBattleOver = true;
          _battleLog.add('モンスターを倒した！');
          if (rewards != null) {
             _battleLog.add('経験値 ${rewards['exp']} と コイン ${rewards['coins']} を獲得！');
          }
        } else {
          _userHp = (_userHp - damageTaken).clamp(0, _maxUserHp);
          _battleLog.add('モンスターの反撃！ $damageTaken のダメージ！');
          if (_userHp <= 0) {
            _isBattleOver = true;
            _battleLog.add('あなたは倒れてしまった...');
          }
        }
      });

      // Update Quest Progress (outside setState)
      if (isWin) {
        final userId = ref.read(userIdProvider);
        if (userId != null) {
          await ref.read(questServiceProvider).updateProgress(userId, 'battle');
          await ref.read(questServiceProvider).updateProgress(userId, 'battle_win');
          ref.refresh(userQuestsProvider);
          ref.refresh(userProfileProvider); // Refresh User Stats (EXP, Coins)
        }
      }

    } catch (e) {
      setState(() {
        _battleLog.add('エラーが発生しました: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetBattle() {
    setState(() {
      _enemyHp = 100;
      _userHp = 100;
      _isBattleOver = false;
      _battleLog = ['野生のモンスターが現れた！'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('バトル')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Enemy Section
            const Icon(Icons.bug_report, size: 80, color: Colors.purple),
            const Text('スライム', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _enemyHp / _maxEnemyHp,
              color: Colors.red,
              backgroundColor: Colors.grey[300],
              minHeight: 10,
            ),
            Text('HP: $_enemyHp / $_maxEnemyHp'),
            
            const Spacer(),

            // Battle Log
            Container(
              height: 150,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: ListView.builder(
                itemCount: _battleLog.length,
                reverse: true, // Show newest at bottom (actually listview reverse means bottom is 0 index? No, reverse means start from bottom)
                // Let's just use reverse: true and reverse the list or just scroll to bottom.
                // Simpler: just show list normally but use reverse: true so index 0 is at bottom?
                // Actually, let's just reverse the list in builder
                itemBuilder: (context, index) {
                  final logIndex = _battleLog.length - 1 - index;
                  return Text(_battleLog[logIndex]);
                },
              ),
            ),
            
            const Spacer(),

            // User Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('勇者 (Lv.15)', style: Theme.of(context).textTheme.titleMedium),
                Text('HP: $_userHp / $_maxUserHp'),
              ],
            ),
            LinearProgressIndicator(
              value: _userHp / _maxUserHp,
              color: Colors.green,
              backgroundColor: Colors.grey[300],
              minHeight: 10,
            ),
            const SizedBox(height: 16),

            // Actions
            if (_isBattleOver)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _resetBattle,
                  child: const Text('次のバトルへ'),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _performAction('attack'),
                    icon: const Icon(Icons.flash_on),
                    label: const Text('こうげき'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _performAction('skill'),
                    icon: const Icon(Icons.star),
                    label: const Text('スキル'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
