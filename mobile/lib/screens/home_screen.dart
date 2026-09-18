import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'login_screen.dart';
import 'add_category_screen.dart';
import 'add_entry_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          // Przełącznik motywu
          IconButton(
            icon: Icon(
            themeProvider.isDarkMode(context)
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            tooltip: 'Zmień motyw',
            onPressed: () {
              themeProvider.toggleTheme(); 
            },
          ),
          // Przyciski wylogowania
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Wyloguj się',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // GÓRNA CZĘŚĆ
            Expanded(
              child: Stack(
                children: [
                  // Tło / Znak wodny
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Opacity(
                      opacity: 0.08,
                      child: Icon(
                        Icons.visibility_outlined,
                        size: 140,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  // Content
                  // Górna część - Przeglądanie wpisów napis
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Przeglądaj wpisy',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () {
                                // TODO: Podpięcie widoku Kategorii
                              },
                              icon: const Icon(Icons.category_outlined),
                              label: const Text('Kategorie'),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                // TODO: Podpięcie widoku Kalendarza
                              },
                              icon: const Icon(Icons.calendar_month_outlined),
                              label: const Text('Kalendarz'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // SEPARATOR "LUB"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'LUB',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
            ),

            // DOLNA CZĘŚĆ - Tworzenie / Pisanie (Znak wodny: Ołówek/Pisanie)
            Expanded(
              child: Stack(
                children: [
                  // Tło / Znak wodny
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Opacity(
                      opacity: 0.08, // Subtelny akcent znaku wodnego
                      child: Icon(
                        Icons.edit_note_outlined, // Lub ikona/emotikona pisania ✍️
                        size: 140,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Dodaj coś nowego',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const AddEntryScreen(),
                                ),
                              );
                              },
                              icon: const Icon(Icons.note_add_outlined),
                              label: const Text('Wpisy'),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const AddCategoryScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.create_new_folder_outlined),
                              label: const Text('Kategorie'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}