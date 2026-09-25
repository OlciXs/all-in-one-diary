import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/category_provider.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // Wartości początkowe nowych opcji
  Color _selectedColor = const Color(0xFF2196F3);
  bool _hasContent = true;
  bool _hasPhotos = true;
  bool _hasDate = true;
  bool _defaultToCurrentDate = true;
  bool _allowTimeRange = false;

  // Dostępne kolory do wyboru
  final List<Color> _availableColors = const [
    Color(0xFF2196F3), // Niebieski
    Color(0xFF4CAF50), // Zielony
    Color(0xFFE91E63), // Różowy - CZerwony
    Color.fromARGB(255, 245, 106, 203), // Różowy
    Color(0xFFFF9800), // Pomarańczowy
    Color(0xFF9C27B0), // Fioletowy
    Color(0xFF00BCD4), // Błękitny
    Color(0xFF795548), // Brązowy
    Color(0xFF607D8B), // Szary
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    // Przekazujemy wszystkie nowe pola do metody w providerze
    final success = await categoryProvider.addCategory(
      name: _nameController.text.trim(),
      color: _selectedColor,
      hasContent: _hasContent,
      hasPhotos: _hasPhotos,
      hasDate: _hasDate,
      defaultToCurrentDate: _defaultToCurrentDate,
      allowTimeRange: _allowTimeRange,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kategoria została pomyślnie dodany!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (categoryProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(categoryProvider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Nowa Kategoria')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Icon(
                      Icons.category_outlined,
                      size: 64,
                      color: _selectedColor, // Ikona dostosowuje się do wybranego koloru
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nazwa kategorii
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nazwa kategorii',
                      prefixIcon: Icon(Icons.folder_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Wpisz nazwę kategorii'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  //  Wybór koloru
                  const Text(
                    'Wybież kolor kategorii:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _availableColors.map((color) {
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 3)
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ) //tenteg
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),

                  //Opcje konfiguracji wpisów
                  const Text(
                    'Konfiguracja wpisów:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SwitchListTile(
                    title: const Text('Pozwól na opisy tekstowe'),
                    //subtitle: const Text('Wyłącz, jeśli kategoria ma zawierać tylko zdjęcia/daty'),
                    value: _hasContent,
                    onChanged: (val) => setState(() => _hasContent = val),
                  ),
                  SwitchListTile(
                    title: const Text('Pozwól na dodawanie zdjęć'),
                    value: _hasPhotos,
                    onChanged: (val) => setState(() => _hasPhotos = val),
                  ),
                  SwitchListTile(
                    title: const Text('Ustalaj datę we wpisach'),
                    value: _hasDate,
                    onChanged: (val) => setState(() => _hasDate = val),
                  ),
                  if (_hasDate) ...[
                    SwitchListTile(
                      title: const Text('Domyślnie ustawiaj dzisiejszą datę'),
                      value: _defaultToCurrentDate,
                      onChanged: (val) =>
                          setState(() => _defaultToCurrentDate = val),
                    ),
                    SwitchListTile(
                      title: const Text('Przedział czasowy (godziny OD - DO)'),
                      subtitle: const Text(
                        'Włącz dla wydarzeń, wyłącz dla pojedynczych dat',
                      ),
                      value: _allowTimeRange,
                      onChanged: (val) => setState(() => _allowTimeRange = val),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Przycisk Zapisu
                  SizedBox(
                    width: double.infinity,
                    child: categoryProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            icon: const Icon(Icons.save_outlined),
                            label: const Text(
                              'Zapisz kategorię',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
