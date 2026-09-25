import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/category_provider.dart';
import '../providers/entry_provider.dart';
import 'entry_detail_screen.dart';

class CategoryEntriesScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryEntriesScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryEntriesScreen> createState() => _CategoryEntriesScreenState();
}

class _CategoryEntriesScreenState extends State<CategoryEntriesScreen> {
  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<EntryProvider>(context, listen: false).fetchEntries();
    });
  }

  Future<void> _confirmDeleteCategory() async {
    final catProvider = Provider.of<CategoryProvider>(context, listen: false);
    final entryProvider = Provider.of<EntryProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Usuń kategorię'),
        content: Text(
          'Czy na pewno chcesz usunąć kategorię "${widget.categoryName}" wraz ze wszystkimi jej wpisami? Ta operacja jest nieodwracalna.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;

    final success = await catProvider.deleteCategory(widget.categoryId);

    if (!mounted) return;

    if (success) {
      entryProvider.fetchEntries();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kategoria została usunięta.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else if (catProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(catProvider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryProvider>(context);
    final categoryEntries = entryProvider.getEntriesByCategoryId(
      widget.categoryId,
    );

    categoryEntries.sort((a, b) => b.startDate.compareTo(a.startDate));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Usuń kategorię',
            onPressed: () => _confirmDeleteCategory(),
          ),
        ],
      ),
      body: entryProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoryEntries.isEmpty
          ? const Center(child: Text('Brak wpisów w tej kategorii.'))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20.0,
                  ),
                  itemCount: categoryEntries.length,
                  itemBuilder: (context, index) {
                    final entry = categoryEntries[index];
                    final dateStr = entry.isAllDay
                        ? entry.startDate.toString().split(' ')[0]
                        : entry.startDate.toString().substring(0, 16);

                    final String? thumbPath =
                        entry.thumbnailUrl ?? entry.photoUrl;
                    final String? fullThumbUrl =
                        (thumbPath != null && thumbPath.isNotEmpty)
                        ? (thumbPath.startsWith('http')
                              ? thumbPath
                              : '$_baseUrl/${thumbPath.replaceAll('\\', '/')}')
                        : null;

                    return Card(
                      clipBehavior: Clip.none,
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.0),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EntryDetailScreen(entry: entry),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              if (fullThumbUrl != null) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    fullThumbUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey[200],
                                        child: Icon(
                                          Icons.broken_image_outlined,
                                          size: 24,
                                          color: Colors.grey[500],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      entry.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            height: 1.3,
                                          ),
                                    ),
                                    if (entry.content != null &&
                                        entry.content!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        entry.content!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(height: 1.2),
                                      ),
                                    ],
                                    const SizedBox(height: 6),
                                    Text(
                                      dateStr,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}