import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:real_quest_admin/models/card.dart';
import 'package:image_picker/image_picker.dart';

class CardGeneratorScreen extends ConsumerStatefulWidget {
  const CardGeneratorScreen({super.key});

  @override
  ConsumerState<CardGeneratorScreen> createState() => _CardGeneratorScreenState();
}

class _CardGeneratorScreenState extends ConsumerState<CardGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form Fields
  String _name = '';
  String _description = '';
  String _rarity = 'common';
  String _category = 'nature';
  String _element = 'fire';
  int _attack = 10;
  int _defense = 10;
  int _speed = 10;
  int _utility = 10;
  String _specialEffect = '';
  String _prompt = '';
  
  bool _isGenerating = false;
  String? _generatedImageUrl;
  String? _debugInfo;
  
  // Reference Image
  Uint8List? _referenceImageBytes;
  String? _referenceImageName;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _referenceImageBytes = bytes;
        _referenceImageName = pickedFile.name;
      });
    }
  }

  Future<void> _generateCard() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isGenerating = true;
      _debugInfo = null;
    });

    try {
      String? referenceImageBase64;
      if (_referenceImageBytes != null) {
        referenceImageBase64 = base64Encode(_referenceImageBytes!);
      }

      // 1. Call Edge Function to generate image
      final response = await Supabase.instance.client.functions.invoke(
        'admin-generate-card',
        body: {
          'prompt': _prompt,
          'referenceImage': referenceImageBase64,
        },
      );

      final data = response.data as Map<String, dynamic>;
      
      if (data['error'] != null) {
        throw Exception('Server Error: ${data['error']} ${data['details'] ?? ''}');
      }

      final imageUrl = data['imageUrl'] as String?;
      final debugData = data['debug'];

      if (imageUrl != null) {
        setState(() {
          _generatedImageUrl = imageUrl;
          _debugInfo = debugData.toString();
        });
      } else {
        throw Exception('No image URL returned');
      }

      // 2. Save to Database
      await Supabase.instance.client.from('card_templates').insert({
        'name': _name,
        'description': _description,
        'rarity': _rarity,
        'category': _category,
        'element': _element,
        'base_attack': _attack,
        'base_defense': _defense,
        'base_speed': _speed,
        'base_utility': _utility,
        'special_effect': _specialEffect,
        'image_url': imageUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card Created Successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card Generator')),
      body: Row(
        children: [
          // Form Section
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Card Name'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                      onSaved: (v) => _name = v!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      onSaved: (v) => _description = v ?? '',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _rarity,
                            decoration: const InputDecoration(labelText: 'Rarity'),
                            items: ['common', 'uncommon', 'rare', 'epic', 'legendary']
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) => setState(() => _rarity = v!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _category,
                            decoration: const InputDecoration(labelText: 'Category'),
                            items: ['nature', 'artifact', 'location', 'creature', 'other']
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) => setState(() => _category = v!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _element,
                            decoration: const InputDecoration(labelText: 'Element'),
                            items: ['fire', 'water', 'wind', 'earth', 'light', 'dark']
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) => setState(() => _element = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Status Inputs
                    Row(
                      children: [
                        Expanded(child: _buildIntField('Attack', (v) => _attack = v)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildIntField('Defense', (v) => _defense = v)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildIntField('Speed', (v) => _speed = v)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildIntField('Utility', (v) => _utility = v)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Special Effect'),
                      onSaved: (v) => _specialEffect = v ?? '',
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    // Image Generation Section
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'AI Prompt'),
                      maxLines: 3,
                      validator: (v) => v!.isEmpty ? 'Required for Image Gen' : null,
                      onSaved: (v) => _prompt = v!,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text('Select Reference Image'),
                        ),
                        const SizedBox(width: 16),
                        if (_referenceImageName != null)
                          Text('Selected: $_referenceImageName')
                        else
                          const Text('No image selected'),
                      ],
                    ),
                    if (_referenceImageBytes != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Image.memory(_referenceImageBytes!, height: 100),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isGenerating ? null : _generateCard,
                        icon: _isGenerating
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.auto_awesome),
                        label: const Text('Generate Card'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Preview Section
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
                    Column(
                      children: [
                        Card(
                          elevation: 8,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_generatedImageUrl!.startsWith('data:'))
                                Image.memory(
                                  base64Decode(_generatedImageUrl!.split(',').last),
                                  height: 300,
                                  width: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
                                )
                              else
                                Image.network(
                                  _generatedImageUrl!,
                                  height: 300,
                                  width: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(_name.isNotEmpty ? _name : 'Card Name', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SelectableText('URL: ${_generatedImageUrl!.length > 50 ? _generatedImageUrl!.substring(0, 50) : _generatedImageUrl}...'),
                        const SizedBox(height: 8),
                        const Text('Debug Info:', style: TextStyle(fontWeight: FontWeight.bold)),
                        if (_debugInfo != null)
                          Container(
                            height: 200,
                            padding: const EdgeInsets.all(8),
                            color: Colors.grey[200],
                            child: SingleChildScrollView(
                              child: SelectableText(_debugInfo!),
                            ),
                          ),
                      ],
                    )
                  else
                    const Center(child: Text('Generated image will appear here')),
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
