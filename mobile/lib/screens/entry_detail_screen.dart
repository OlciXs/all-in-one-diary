import 'package:flutter/material.dart';
import '../models/entry.dart';

class EntryDetailScreen extends StatelessWidget {
  final Entry entry;

  const EntryDetailScreen({super.key, required this.entry});

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