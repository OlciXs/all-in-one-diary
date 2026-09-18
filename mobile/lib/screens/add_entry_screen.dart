import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/entry_provider.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // Pobieramy kategorie, jeśli lista jest pusta
    Future.microtask(() {
      final catProvider = Provider.of<CategoryProvider>(context, listen: false);
      if (catProvider.categories.isEmpty) {
        catProvider.fetchCategories();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final entryProvider = Provider.of<EntryProvider>(context, listen: false);

    final success = await entryProvider.addEntry(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      categoryId: _selectedCategoryId!,
    );

    if (!mounted) return;

    if (success) {
/*
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wpis został pomyślnie dodany!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
*/
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
    final theme = Theme.of(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final entryProvider = Provider.of<EntryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nowy Wpis'),
      ),
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
                  // Pole Tytułu
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Tytuł wpisu',
                      prefixIcon: Icon(Icons.title_outlined),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Wpisz tytuł'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Dropdown z Kategoriami
                  DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Wybierz kategorię',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: categoryProvider.categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategoryId = val;
                      });
                    },
                    validator: (val) =>
                        val == null ? 'Wybierz kategorię' : null,
                  ),
                  const SizedBox(height: 16),

                  // Pole Treści (wieloliniowe)
                  TextFormField(
                    controller: _contentController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Treść wpisu',
                      //prefixIcon: Icon(Icons.notes_outlined),
                      alignLabelWithHint: true,
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Wpisz treść'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // Przycisk Zapisu
                  entryProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          onPressed: _submit,
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