import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/entry_provider.dart';
import '../providers/category_provider.dart';
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
    Future.microtask(() =>
        Provider.of<EntryProvider>(context, listen: false).fetchEntries());
  }

  Future<void> _confirmDeleteCategory(BuildContext context) async {
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

    if (confirmed == true && mounted) {
      final catProvider = Provider.of<CategoryProvider>(context, listen: false);
      final success = await catProvider.deleteCategory(widget.categoryId);

      if (!mounted) return;

      if (success) {
        Provider.of<EntryProvider>(context, listen: false).fetchEntries();

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
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryProvider>(context);
    final categoryEntries = entryProvider.getEntriesByCategoryId(widget.categoryId);

    categoryEntries.sort((a, b) => b.startDate.compareTo(a.startDate));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Usuń kategorię',
            onPressed: () => _confirmDeleteCategory(context),
          ),
        ],
      ),
      body: entryProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoryEntries.isEmpty
              ? const Center(
                  child: Text('Brak wpisów w tej kategorii.'),
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: categoryEntries.length,
                      itemBuilder: (context, index) {
                        final entry = categoryEntries[index];
                        final dateStr = entry.isAllDay
                            ? entry.startDate.toString().split(' ')[0]
                            : entry.startDate.toString().substring(0, 16);

                        // Wybranie miniaturki
                        final String? thumbPath = entry.thumbnailUrl ?? entry.photoUrl;
                        final String? fullThumbUrl = (thumbPath != null && thumbPath.isNotEmpty)
                            ? (thumbPath.startsWith('http')
                                ? thumbPath
                                : '$_baseUrl/${thumbPath.replaceAll('\\', '/')}')
                            : null;

                        return Card(
                          clipBehavior: Clip.antiAlias,
                          margin: const EdgeInsets.only(bottom: 12.0),
                          child: ListTile(
                            // Wyświetlenie miniaturki w polu leading
                            leading: fullThumbUrl != null
                                ? ClipRRect(
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
                                  )
                                : null,
                            title: Text(
                              entry.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (entry.content != null && entry.content!.isNotEmpty)
                                  Text(
                                    entry.content!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  dateStr,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EntryDetailScreen(entry: entry),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}