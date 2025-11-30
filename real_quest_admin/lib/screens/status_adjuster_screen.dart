import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:data_table_2/data_table_2.dart';

class StatusAdjusterScreen extends ConsumerStatefulWidget {
  const StatusAdjusterScreen({super.key});

  @override
  ConsumerState<StatusAdjusterScreen> createState() => _StatusAdjusterScreenState();
}

class _StatusAdjusterScreenState extends ConsumerState<StatusAdjusterScreen> {
  String _searchQuery = '';
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;

  Future<void> _searchUsers() async {
    setState(() => _isLoading = true);
    try {
      // Search by ID or Email (using ilike for partial match on email)
      // Note: 'email' column was added to public.users.
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .ilike('email', '%$_searchQuery%')
          .limit(20);
      
      setState(() {
        _users = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await Supabase.instance.client.from('users').update(updates).eq('id', userId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User Updated')));
      _searchUsers(); // Refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating: $e')));
    }
  }

  void _showEditDialog(Map<String, dynamic> user) {
    final levelCtrl = TextEditingController(text: user['level'].toString());
    final expCtrl = TextEditingController(text: user['exp'].toString());
    final coinsCtrl = TextEditingController(text: user['coins'].toString());
    final hpCtrl = TextEditingController(text: user['hp'].toString());
    final maxHpCtrl = TextEditingController(text: user['max_hp'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit User: ${user['email'] ?? user['id']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: levelCtrl, decoration: const InputDecoration(labelText: 'Level'), keyboardType: TextInputType.number),
              TextField(controller: expCtrl, decoration: const InputDecoration(labelText: 'EXP'), keyboardType: TextInputType.number),
              TextField(controller: coinsCtrl, decoration: const InputDecoration(labelText: 'Coins'), keyboardType: TextInputType.number),
              TextField(controller: hpCtrl, decoration: const InputDecoration(labelText: 'Current HP'), keyboardType: TextInputType.number),
              TextField(controller: maxHpCtrl, decoration: const InputDecoration(labelText: 'Max HP'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              _updateUser(user['id'], {
                'level': int.tryParse(levelCtrl.text) ?? user['level'],
                'exp': int.tryParse(expCtrl.text) ?? user['exp'],
                'coins': int.tryParse(coinsCtrl.text) ?? user['coins'],
                'hp': int.tryParse(hpCtrl.text) ?? user['hp'],
                'max_hp': int.tryParse(maxHpCtrl.text) ?? user['max_hp'],
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status Adjuster')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Search Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search by Email',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => _searchQuery = v,
                    onSubmitted: (_) => _searchUsers(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _searchUsers,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Results Table
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DataTable2(
                      columnSpacing: 12,
                      horizontalMargin: 12,
                      minWidth: 800,
                      columns: const [
                        DataColumn2(label: Text('ID'), size: ColumnSize.S),
                        DataColumn2(label: Text('Email'), size: ColumnSize.L),
                        DataColumn2(label: Text('Level'), size: ColumnSize.S),
                        DataColumn2(label: Text('EXP'), size: ColumnSize.S),
                        DataColumn2(label: Text('Coins'), size: ColumnSize.S),
                        DataColumn2(label: Text('Actions'), size: ColumnSize.S),
                      ],
                      rows: _users.map((user) {
                        return DataRow(cells: [
                          DataCell(Text(user['id'].toString().substring(0, 8) + '...')),
                          DataCell(Text(user['email'] ?? 'No Email')),
                          DataCell(Text(user['level'].toString())),
                          DataCell(Text(user['exp'].toString())),
                          DataCell(Text(user['coins'].toString())),
                          DataCell(IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditDialog(user),
                          )),
                        ]);
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
