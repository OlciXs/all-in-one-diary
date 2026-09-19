import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<EntryProvider>(context, listen: false).fetchEntries());
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryProvider>(context);
    final categoryEntries = entryProvider.getEntriesByCategoryId(widget.categoryId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
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
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          margin: const EdgeInsets.only(bottom: 12.0),
                          child: ListTile(
                            title: Text(
                              entry.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              entry.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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