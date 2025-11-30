import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:real_quest_admin/models/item.dart';

class ItemGeneratorScreen extends ConsumerStatefulWidget {
  const ItemGeneratorScreen({super.key});

  @override
  ConsumerState<ItemGeneratorScreen> createState() => _ItemGeneratorScreenState();
}

class _ItemGeneratorScreenState extends ConsumerState<ItemGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _name = '';
  String _description = '';
  String _type = 'consumable';
  String _effectType = 'heal_hp';
  int _effectValue = 0;
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

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      await Supabase.instance.client.from('item_templates').insert({
        'name': _name,
        'description': _description,
        'type': _type,
        'effect_type': _effectType,
        'effect_value': _effectValue,
        'image_url': _generatedImageUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item Created!')));
        // Reset form or navigate back
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item Generator')),
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
                      value: _type,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: ['consumable', 'material', 'key_item']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _type = v!),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _effectType,
                            decoration: const InputDecoration(labelText: 'Effect Type'),
                            items: ['heal_hp', 'heal_mp', 'buff_atk', 'none']
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) => setState(() => _effectType = v!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Effect Value'),
                            keyboardType: TextInputType.number,
                            initialValue: '0',
                            onSaved: (v) => _effectValue = int.tryParse(v ?? '') ?? 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
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
                        onPressed: _saveItem,
                        child: const Text('Save Item'),
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
                    Image.network(_generatedImageUrl!, height: 200)
                  else
                    const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
