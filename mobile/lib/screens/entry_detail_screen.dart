import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/entry.dart';
import '../providers/entry_provider.dart';

class EntryDetailScreen extends StatelessWidget {
  final Entry entry;

  const EntryDetailScreen({super.key, required this.entry});

  Future<void> _confirmDeleteEntry(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Usuń wpis'),
        content: Text(
          'Czy na pewno chcesz usunąć wpis "${entry.title}"? Ta operacja jest nieodwracalna.',
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

    if (confirmed == true && context.mounted) {
      final entryProvider = Provider.of<EntryProvider>(context, listen: false);
      final success = await entryProvider.deleteEntry(entry.id);

      if (!context.mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wpis został usunięty.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Powrót do listy wpisów
      } else if (entryProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(entryProvider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final startDateStr = entry.isAllDay
        ? entry.startDate.toString().split(' ')[0]
        : entry.startDate.toString().substring(0, 16);

    final endDateStr = entry.endDate != null
        ? (entry.isAllDay
            ? entry.endDate!.toString().split(' ')[0]
            : entry.endDate!.toString().substring(0, 16))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Usuń wpis',
            onPressed: () => _confirmDeleteEntry(context),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Icon(Icons.calendar_today_outlined, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        endDateStr != null
                            ? '$startDateStr  —  $endDateStr'
                            : startDateStr,
                        softWrap: true,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Divider(),
                const SizedBox(height: 16.0),
                if (entry.content != null && entry.content!.isNotEmpty)
                  Text(
                    entry.content!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                else
                  Text(
                    'Brak dodatkowego opisu.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}