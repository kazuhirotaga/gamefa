import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_quest/providers.dart';
import 'package:real_quest/models/item.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userItemsAsync = ref.watch(userItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('持ち物'),
      ),
      body: userItemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('アイテムを持っていません'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final item = items[index];
              final template = item.template;
              if (template == null) return const SizedBox.shrink();

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  child: const Icon(Icons.backpack, color: Colors.blue),
                ),
                title: Text(template.name),
                subtitle: Text(template.description ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('x${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implement use item
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${template.name} を使いました（仮）')),
                        );
                      },
                      child: const Text('使う'),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
    );
  }
}
