import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:data_table_2/data_table_2.dart';

class DatabaseViewerScreen extends ConsumerStatefulWidget {
  const DatabaseViewerScreen({super.key});

  @override
  ConsumerState<DatabaseViewerScreen> createState() => _DatabaseViewerScreenState();
}

class _DatabaseViewerScreenState extends ConsumerState<DatabaseViewerScreen> {
  String _selectedTable = 'users';
  List<Map<String, dynamic>> _data = [];
  List<String> _columns = [];
  bool _isLoading = false;

  final List<String> _tables = [
    'users',
    'card_templates',
    'user_cards',
    'item_templates',
    'user_items',
    'monster_templates',
    'quests',
    'user_quests',
    'checkins',
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from(_selectedTable)
          .select()
          .limit(50)
          .order('created_at', ascending: false); // Assuming most tables have created_at
      
      final List<Map<String, dynamic>> rows = List<Map<String, dynamic>>.from(response);
      
      setState(() {
        _data = rows;
        if (rows.isNotEmpty) {
          _columns = rows.first.keys.toList();
        } else {
          _columns = [];
        }
      });
    } catch (e) {
      // Some tables might not have created_at, retry without order if fail? 
      // Or just catch.
      try {
         // Retry without sort
        final response = await Supabase.instance.client
            .from(_selectedTable)
            .select()
            .limit(50);
        setState(() {
          _data = List<Map<String, dynamic>>.from(response);
          if (_data.isNotEmpty) _columns = _data.first.keys.toList();
        });
      } catch (e2) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e2')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database Viewer')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Controls
            Row(
              children: [
                DropdownButton<String>(
                  value: _selectedTable,
                  items: _tables.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedTable = v);
                      _fetchData();
                    }
                  },
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _fetchData,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Data Grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _data.isEmpty
                      ? const Center(child: Text('No Data'))
                      : DataTable2(
                          columnSpacing: 12,
                          horizontalMargin: 12,
                          minWidth: _columns.length * 100.0,
                          columns: _columns.map((c) => DataColumn2(label: Text(c), size: ColumnSize.M)).toList(),
                          rows: _data.map((row) {
                            return DataRow(
                              cells: _columns.map((c) => DataCell(
                                Text(row[c]?.toString() ?? 'null', overflow: TextOverflow.ellipsis),
                              )).toList(),
                            );
                          }).toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
