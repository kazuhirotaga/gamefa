import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Real Quest Admin Dashboard')),
      body: GridView.count(
        padding: const EdgeInsets.all(24),
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildMenuCard(
            context,
            'Card Generator',
            Icons.style,
            Colors.blue,
            '/card-gen',
            'Create new cards with AI images',
          ),
          _buildMenuCard(
            context,
            'Item Generator',
            Icons.inventory_2,
            Colors.green,
            '/item-gen',
            'Create items with AI icons',
          ),
          _buildMenuCard(
            context,
            'Monster Generator',
            Icons.bug_report,
            Colors.red,
            '/monster-gen',
            'Create monsters with AI images',
          ),
          _buildMenuCard(
            context,
            'Status Adjuster',
            Icons.manage_accounts,
            Colors.orange,
            '/status-adj',
            'Edit user stats and inventory',
          ),
          _buildMenuCard(
            context,
            'Database Viewer',
            Icons.table_chart,
            Colors.purple,
            '/db-viewer',
            'Inspect raw database tables',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, String route, String desc) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push(route); 
          // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming Soon')));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(desc, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
