import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:real_quest_admin/models/monster.dart';

class MonsterGeneratorScreen extends ConsumerStatefulWidget {
  const MonsterGeneratorScreen({super.key});

  @override
  ConsumerState<MonsterGeneratorScreen> createState() => _MonsterGeneratorScreenState();
}

class _MonsterGeneratorScreenState extends ConsumerState<MonsterGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _name = '';
  String _description = '';
  String _element = 'fire';
  int _hp = 100;
  int _attack = 10;
  int _defense = 5;
  int _expReward = 10;
  int _coinReward = 10;
  String _prompt = '';
  
  bool _isGenerating = false;
  String? _generatedImageUrl;

  Future<void> _generateImage() async {
    if (_prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a prompt')));
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'admin-generate-image',
        body: { 'prompt': _prompt },
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        setState(() {
          _generatedImageUrl = data['imageUrl'];
        });
      } else {
        throw Exception(data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _saveMonster() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      await Supabase.instance.client.from('monster_templates').insert({
        'name': _name,
        'description': _description,
        'element': _element,
        'hp': _hp,
        'attack': _attack,
        'defense': _defense,
        'exp_reward': _expReward,
        'coin_reward': _coinReward,
        'image_url': _generatedImageUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Monster Created!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monster Generator')),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                      onSaved: (v) => _name = v!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Description'),
                      onSaved: (v) => _description = v ?? '',
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _element,
                      decoration: const InputDecoration(labelText: 'Element'),
                      items: ['fire', 'water', 'wind', 'earth', 'light', 'dark']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _element = v!),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildIntField('HP', (v) => _hp = v)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildIntField('Attack', (v) => _attack = v)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildIntField('Defense', (v) => _defense = v)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildIntField('EXP Reward', (v) => _expReward = v)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildIntField('Coin Reward', (v) => _coinReward = v)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Image Prompt'),
                      onChanged: (v) => _prompt = v,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isGenerating ? null : _generateImage,
                      icon: const Icon(Icons.image),
                      label: Text(_isGenerating ? 'Generating...' : 'Generate Image'),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveMonster,
                        child: const Text('Save Monster'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text('Preview', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 24),
                  if (_generatedImageUrl != null)
                    Image.network(_generatedImageUrl!, height: 300)
                  else
                    const Icon(Icons.bug_report, size: 100, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntField(String label, Function(int) onSaved) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      initialValue: '10',
      onSaved: (v) => onSaved(int.tryParse(v ?? '') ?? 0),
    );
  }
}
