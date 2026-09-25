import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/category_provider.dart';
import '../providers/entry_provider.dart';

class AddEntryScreen extends StatefulWidget {
  final int? initialCategoryId;

  const AddEntryScreen({super.key, this.initialCategoryId});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  int? _selectedCategoryId;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isAllDay = true;

  XFile? _pickedFile;
  Uint8List? _webImageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      final catProvider = Provider.of<CategoryProvider>(context, listen: false);
      if (catProvider.categories.isEmpty) {
        await catProvider.fetchCategories();
      }

      if (catProvider.categories.isNotEmpty && mounted) {
        setState(() {
          final targetId = widget.initialCategoryId;
          if (targetId != null &&
              catProvider.categories.any((c) => c.id == targetId)) {
            _selectedCategoryId = targetId;
          } else {
            _selectedCategoryId = catProvider.categories.first.id;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _pickedFile = pickedFile;
          _webImageBytes = bytes;
        });
      } else {
        setState(() {
          _pickedFile = pickedFile;
        });
      }
    }
  }

  Future<void> _selectStartDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      if (_isAllDay) {
        setState(() => _startDate = pickedDate);
      } else {
        if (!mounted) return;
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_startDate),
        );
        if (pickedTime != null) {
          setState(() {
            _startDate = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
          });
        }
      }
    }
  }

  Future<void> _selectEndDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      if (_isAllDay) {
        setState(() => _endDate = pickedDate);
      } else {
        if (!mounted) return;
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_endDate ?? _startDate),
        );
        if (pickedTime != null) {
          setState(() {
            _endDate = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
          });
        }
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) return;

    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final entryProvider = Provider.of<EntryProvider>(context, listen: false);

    final selectedCategory = categoryProvider.categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => categoryProvider.categories.first,
    );

    final startDateUtc = _startDate.toUtc();
    final endDateUtc = _endDate?.toUtc();

    final success = await entryProvider.addEntry(
      title: _titleController.text.trim(),
      content:
          selectedCategory.hasContent &&
              _contentController.text.trim().isNotEmpty
          ? _contentController.text.trim()
          : null,
      startDate: startDateUtc,
      endDate: selectedCategory.allowTimeRange ? endDateUtc : null,
      isAllDay: _isAllDay,
      categoryId: selectedCategory.id,
      photoFile: _pickedFile,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wpis został pomyślnie dodany!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (entryProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(entryProvider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final entryProvider = Provider.of<EntryProvider>(context);

    Category? currentCategory;
    if (categoryProvider.categories.isNotEmpty) {
      if (_selectedCategoryId != null) {
        final matches = categoryProvider.categories.where(
          (c) => c.id == _selectedCategoryId,
        );
        currentCategory = matches.isNotEmpty
            ? matches.first
            : categoryProvider.categories.first;
      } else {
        currentCategory = categoryProvider.categories.first;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Nowy Wpis')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: currentCategory?.id,
                    decoration: const InputDecoration(
                      labelText: 'Wybierz kategorię',
                      prefixIcon: Icon(Icons.category_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: categoryProvider.categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category.id,
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: category.color,
                              radius: 8,
                            ),
                            const SizedBox(width: 8),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategoryId = val;
                        _pickedFile = null;
                        _webImageBytes = null;
                      });
                    },
                    validator: (val) =>
                        val == null ? 'Wybierz kategorię' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Tytuł wpisu',
                      prefixIcon: Icon(Icons.title_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Wpisz tytuł'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  if (currentCategory?.hasContent ?? true) ...[
                    TextFormField(
                      controller: _contentController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Treść wpisu',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (currentCategory?.hasDate ?? true) ...[
                    const Divider(),
                    if (currentCategory?.allowTimeRange ?? false)
                      SwitchListTile(
                        title: const Text('Wydarzenie całodniowe'),
                        value: _isAllDay,
                        onChanged: (val) => setState(() => _isAllDay = val),
                      ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: Text(
                        _isAllDay
                            ? 'Data: ${_startDate.toString().split(' ')[0]}'
                            : 'Początek: ${_startDate.toString().substring(0, 16)}',
                      ),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: _selectStartDate,
                    ),
                    if (currentCategory?.allowTimeRange ?? false)
                      ListTile(
                        leading: const Icon(Icons.event_available_outlined),
                        title: Text(
                          _endDate == null
                              ? 'Koniec: Brak'
                              : _isAllDay
                              ? 'Koniec: ${_endDate!.toString().split(' ')[0]}'
                              : 'Koniec: ${_endDate!.toString().substring(0, 16)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_endDate != null)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () =>
                                    setState(() => _endDate = null),
                              ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                        onTap: _selectEndDate,
                      ),
                    const Divider(),
                    const SizedBox(height: 16),
                  ],
                  if (currentCategory?.hasPhotos ?? false) ...[
                    if (_pickedFile != null)
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: kIsWeb
                                ? Image.memory(
                                    _webImageBytes!,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(_pickedFile!.path),
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                _pickedFile = null;
                                _webImageBytes = null;
                              });
                            },
                          ),
                        ],
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_a_photo_outlined),
                        label: const Text('Dodaj zdjęcie do wpisu'),
                      ),
                    const SizedBox(height: 16),
                  ],
                  entryProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: const Icon(Icons.save_outlined),
                          label: const Text(
                            'Zapisz wpis',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
