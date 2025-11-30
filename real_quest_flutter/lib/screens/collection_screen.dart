import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_quest/providers.dart';
import 'package:real_quest/widgets/card_widget.dart';

class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCardsAsync = ref.watch(userCardsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('図鑑')),
      body: userCardsAsync.when(
        data: (cards) {
          if (cards.isEmpty) {
            return const Center(child: Text('カードをまだ持っていません'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              return CardWidget(
                card: cards[index],
                isSmall: true,
                onTap: () {
                  // Show detail modal
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(child: Text('読み込みエラー')),
      ),
    );
  }
}
