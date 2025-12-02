import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:real_quest_admin/models/card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';

class CardGeneratorScreen extends ConsumerStatefulWidget {
  const CardGeneratorScreen({super.key});

  @override
  ConsumerState<CardGeneratorScreen> createState() => _CardGeneratorScreenState();
}

class _CardGeneratorScreenState extends ConsumerState<CardGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _specialEffectController;
  late TextEditingController _promptController;
  late TextEditingController _attackController;
  late TextEditingController _defenseController;
  late TextEditingController _speedController;
  late TextEditingController _utilityController;

  // Form Fields State
  String? _editingCardId; // ID of the card being edited, null if creating new
  String _rarity = 'common';
  String _category = 'nature';
  String _element = 'fire';
  
  bool _isGenerating = false;
  bool _isLoading = false;
  String? _generatedImageUrl;
  String? _debugInfo;
  
  // Reference Image
  Uint8List? _referenceImageBytes;
  String? _referenceImageName;

  // List of existing cards
  List<GameCard> _existingCards = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _specialEffectController = TextEditingController();
    _promptController = TextEditingController();
    _attackController = TextEditingController(text: '10');
    _defenseController = TextEditingController(text: '10');
    _speedController = TextEditingController(text: '10');
    _utilityController = TextEditingController(text: '10');
    
    _loadCards();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _specialEffectController.dispose();
    _promptController.dispose();
    _attackController.dispose();
    _defenseController.dispose();
    _speedController.dispose();
    _utilityController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('card_templates')
          .select()
          .order('created_at', ascending: false);
      
      final cards = (response as List).map((e) => GameCard.fromJson(e)).toList();
      setState(() {
        _existingCards = cards;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading cards: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _selectCardToEdit(GameCard card) {
    setState(() {
      _editingCardId = card.id;
      _nameController.text = card.name;
      _descriptionController.text = card.description;
      _rarity = card.rarity.name;
      _category = card.category.name;
      // Element is not in GameCard, will be fetched or default
      
      _attackController.text = card.attack.toString();
      _defenseController.text = card.defense.toString();
      _speedController.text = card.speed.toString();
      _utilityController.text = card.utility.toString();
      
      // Special effect not in GameCard, will be fetched or default
      _generatedImageUrl = card.imageUrl;
      _promptController.text = ''; // Reset prompt
      _referenceImageBytes = null;
      _referenceImageName = null;
      _debugInfo = null;
    });
    
    _fetchCardDetails(card.id);
  }

  Future<void> _fetchCardDetails(String id) async {
    try {
      final data = await Supabase.instance.client
          .from('card_templates')
          .select()
          .eq('id', id)
          .single();
      
      setState(() {
        _element = data['element'] ?? 'fire';
        _specialEffectController.text = data['special_effect'] ?? '';
      });
    } catch (e) {
      // Ignore error, keep defaults
    }
  }

  void _resetForm() {
    setState(() {
      _editingCardId = null;
      _nameController.clear();
      _descriptionController.clear();
      _rarity = 'common';
      _category = 'nature';
      _element = 'fire';
      _attackController.text = '10';
      _defenseController.text = '10';
      _speedController.text = '10';
      _utilityController.text = '10';
      _specialEffectController.clear();
      _promptController.clear();
      _generatedImageUrl = null;
      _referenceImageBytes = null;
      _referenceImageName = null;
      _debugInfo = null;
    });
  }

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

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;
    
    // No need to save form state as we use controllers directly

    setState(() {
      _isGenerating = true;
      _debugInfo = null;
    });

    try {
      String? imageUrl = _generatedImageUrl;

      // Only generate image if prompt is provided
      if (_promptController.text.isNotEmpty) {
        String? referenceImageBase64;
        if (_referenceImageBytes != null) {
          referenceImageBase64 = base64Encode(_referenceImageBytes!);
        }

        // 1. Call Edge Function to generate image
        final response = await Supabase.instance.client.functions.invoke(
          'admin-generate-card',
          body: {
            'prompt': _promptController.text,
            'referenceImage': referenceImageBase64,
            'name': _nameController.text,
            'rarity': _rarity,
            'element': _element,
            'stats': {
              'attack': int.tryParse(_attackController.text) ?? 0,
              'defense': int.tryParse(_defenseController.text) ?? 0,
              'speed': int.tryParse(_speedController.text) ?? 0,
              'utility': int.tryParse(_utilityController.text) ?? 0,
            },
            'special_effect': _specialEffectController.text,
          },
        );

        final data = response.data as Map<String, dynamic>;
        
        if (data['error'] != null) {
          throw Exception('Server Error: ${data['error']} ${data['details'] ?? ''}');
        }

        imageUrl = data['imageUrl'] as String?;
        final debugData = data['debug'];

        if (imageUrl != null) {
          setState(() {
            _generatedImageUrl = imageUrl;
            _debugInfo = debugData.toString();
          });
        } else {
          throw Exception('No image URL returned');
        }
      }

      // 2. Save to Database (Insert or Update)
      final cardData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'rarity': _rarity,
        'category': _category,
        'element': _element,
        'base_attack': int.tryParse(_attackController.text) ?? 0,
        'base_defense': int.tryParse(_defenseController.text) ?? 0,
        'base_speed': int.tryParse(_speedController.text) ?? 0,
        'base_utility': int.tryParse(_utilityController.text) ?? 0,
        'special_effect': _specialEffectController.text,
        if (imageUrl != null) 'image_url': imageUrl,
      };

      if (_editingCardId != null) {
        // Update
        await Supabase.instance.client
            .from('card_templates')
            .update(cardData)
            .eq('id', _editingCardId!);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Card Updated Successfully!')),
          );
        }
      } else {
        // Insert
        await Supabase.instance.client.from('card_templates').insert(cardData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Card Created Successfully!')),
          );
        }
      }

      await _loadCards();
      _resetForm();

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

  Future<void> _deleteCard() async {
    if (_editingCardId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: const Text('Are you sure you want to delete this card? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isGenerating = true);

    try {
      await Supabase.instance.client
          .from('card_templates')
          .delete()
          .eq('id', _editingCardId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card Deleted Successfully!')),
        );
      }
      
      await _loadCards();
      _resetForm();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting card: $e')),
        );
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _importCsv() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true, // Needed for web/desktop to get bytes
      );

      if (result == null || result.files.isEmpty) return;

      final fileBytes = result.files.first.bytes;
      if (fileBytes == null) return;

      final csvString = utf8.decode(fileBytes);
      final List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);

      if (rows.isEmpty) return;

      // Assume first row is header if it contains 'name'
      int startIndex = 0;
      if (rows.first.isNotEmpty && rows.first[0].toString().toLowerCase().contains('name')) {
        startIndex = 1;
      }

      setState(() => _isGenerating = true);
      int successCount = 0;
      int failCount = 0;

      for (int i = startIndex; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty) continue;

        try {
          // Expected format: name, description, rarity, category, element, attack, defense, speed, utility, special_effect, prompt
          String getVal(int index) => index < row.length ? row[index].toString().trim() : '';
          int getInt(int index) => int.tryParse(getVal(index)) ?? 0;

          final cardData = {
            'name': getVal(0),
            'description': getVal(1),
            'rarity': getVal(2).toLowerCase(),
            'category': getVal(3).toLowerCase(),
            'element': getVal(4).toLowerCase(),
            'base_attack': getInt(5),
            'base_defense': getInt(6),
            'base_speed': getInt(7),
            'base_utility': getInt(8),
            'special_effect': getVal(9),
          };
          
          if (cardData['name'].toString().isEmpty) continue;

          await Supabase.instance.client.from('card_templates').insert(cardData);
          successCount++;
        } catch (e) {
          print('Error importing row $i: $e');
          failCount++;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import complete: $successCount success, $failCount failed')),
        );
      }
      
      await _loadCards();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing CSV: $e')),
        );
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingCardId != null ? 'Edit Card' : 'Card Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _isGenerating ? null : _importCsv,
            tooltip: 'Import from CSV',
          ),
          if (_editingCardId != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _resetForm,
              tooltip: 'Create New Card',
            ),
        ],
      ),
      body: Row(
        children: [
          // Card List Sidebar
          Container(
            width: 250,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Cards',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Implement search filter if needed
                    },
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: _existingCards.length,
                          itemBuilder: (context, index) {
                            final card = _existingCards[index];
                            final isSelected = card.id == _editingCardId;
                            return ListTile(
                              selected: isSelected,
                              selectedTileColor: Colors.blue.shade50,
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(card.imageUrl),
                                onBackgroundImageError: (_, __) {},
                                child: const Icon(Icons.image_not_supported, size: 16),
                              ),
                              title: Text(card.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text(card.rarity.name, style: const TextStyle(fontSize: 12)),
                              onTap: () => _selectCardToEdit(card),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          
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
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Card Name'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                      onChanged: (v) => setState(() {}), // Rebuild for preview
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        final rarities = ['common', 'uncommon', 'rare', 'epic', 'legendary'];
                        final categories = ['nature', 'artifact', 'location', 'creature', 'other'];
                        final elements = ['fire', 'water', 'wind', 'earth', 'light', 'dark'];

                        // Debug prints
                        print('Build Dropdowns: Rarity=$_rarity, Category=$_category, Element=$_element');

                        // Helper to safely get value
                        String safeValue(String current, List<String> options) {
                          final trimmed = current.trim();
                          if (options.contains(trimmed)) return trimmed;
                          print('Warning: Invalid value "$current" (trimmed: "$trimmed") not in $options. Fallback to ${options.first}');
                          return options.first;
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                key: ValueKey('rarity_$_rarity'),
                                value: safeValue(_rarity, rarities),
                                decoration: const InputDecoration(labelText: 'Rarity'),
                                items: rarities
                                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (v) => setState(() => _rarity = v!),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                key: ValueKey('category_$_category'),
                                value: safeValue(_category, categories),
                                decoration: const InputDecoration(labelText: 'Category'),
                                items: categories
                                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (v) => setState(() => _category = v!),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                key: ValueKey('element_$_element'),
                                value: safeValue(_element, elements),
                                decoration: const InputDecoration(labelText: 'Element'),
                                items: elements
                                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (v) => setState(() => _element = v!),
                              ),
                            ),
                          ],
                        );
                      }
                    ),
                    const SizedBox(height: 16),
                    // Status Inputs
                    Row(
                      children: [
                        Expanded(child: _buildIntField('Attack', _attackController)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildIntField('Defense', _defenseController)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildIntField('Speed', _speedController)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildIntField('Utility', _utilityController)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _specialEffectController,
                      decoration: const InputDecoration(labelText: 'Special Effect'),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    // Image Generation Section
                    TextFormField(
                      controller: _promptController,
                      decoration: const InputDecoration(labelText: 'AI Prompt (Leave empty to keep existing image)'),
                      maxLines: 3,
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
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _isGenerating ? null : _saveCard,
                              icon: _isGenerating
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                  : Icon(_editingCardId != null ? Icons.save : Icons.auto_awesome),
                              label: Text(_editingCardId != null ? 'Update Card' : 'Generate & Save Card'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _editingCardId != null ? Colors.orange : null,
                              ),
                            ),
                          ),
                        ),
                        if (_editingCardId != null) ...[
                          const SizedBox(width: 16),
                          SizedBox(
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: _isGenerating ? null : _deleteCard,
                              icon: const Icon(Icons.delete),
                              label: const Text('Delete'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ],
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
                                child: Text(_nameController.text.isNotEmpty ? _nameController.text : 'Card Name', style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildIntField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
    );
  }
}
