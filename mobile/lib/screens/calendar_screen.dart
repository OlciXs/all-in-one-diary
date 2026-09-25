import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/category.dart';
import '../models/entry.dart';
import '../providers/category_provider.dart';
import '../providers/entry_provider.dart';
import 'entry_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<EntryProvider>(context, listen: false).fetchEntries();
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  List<Entry> _getEntriesForDay(DateTime day, List<Entry> allEntries) {
    return allEntries.where((entry) {
      final entryDate = entry.startDate;
      final isSameDayYear = isSameDay(entryDate, day);

      if (!isSameDayYear) return false;

      if (_selectedCategoryId != null) {
        return entry.categoryId == _selectedCategoryId;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final allEntries = entryProvider.entries;
    final categories = categoryProvider.categories;

    final selectedDayEntries = _selectedDay != null
        ? _getEntriesForDay(_selectedDay!, allEntries)
        : <Entry>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalendarz'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: DropdownButton<int?>(
              value: _selectedCategoryId,
              dropdownColor: Theme.of(context).cardColor,
              underline: const SizedBox(),
              icon: const Icon(Icons.filter_list, color: Colors.white),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: const Text('Wszystko'),
                  ),
                ),
                ...categories.map((cat) {
                  return DropdownMenuItem<int?>(
                    value: cat.id,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: Text(cat.name),
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
            ),
          ),
        ],
      ),
      body: entryProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar<Entry>(
                  key: ValueKey(_selectedCategoryId),
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2035, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  eventLoader: (day) => _getEntriesForDay(day, allEntries),
                  
                  calendarBuilders: CalendarBuilders(
                    // kropki
                    markerBuilder: (context, date, events) => const SizedBox.shrink(),

                    // komórki
                    defaultBuilder: (context, day, focusedDay) {
                      return _buildCalendarCell(day, allEntries, categories);
                    },

                    // Zaznaczony dzień
                    selectedBuilder: (context, day, focusedDay) {
                      return _buildCalendarCell(day, allEntries, categories, isSelected: true);
                    },

                    // Dzisiejszy dzień
                    todayBuilder: (context, day, focusedDay) {
                      return _buildCalendarCell(day, allEntries, categories, isToday: true);
                    },

                    // Dni z poprzedniego/następnego miesiąca
                    outsideBuilder: (context, day, focusedDay) {
                      return Opacity(
                        opacity: 0.3,
                        child: _buildCalendarCell(day, allEntries, categories),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: selectedDayEntries.isEmpty
                      ? const Center(
                          child: Text('Brak wpisów w wybranym dniu.'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: selectedDayEntries.length,
                          itemBuilder: (context, index) {
                            final entry = selectedDayEntries[index];
                            final category = categories.firstWhere(
                              (c) => c.id == entry.categoryId,
                              orElse: () => Category(
                                id: 0,
                                name: 'Inne',
                                color: Colors.grey,
                              ),
                            );

                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: category.color,
                                  child: Text(
                                    category.name.isNotEmpty
                                        ? category.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  entry.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Kategoria: ${category.name}',
                                  maxLines: 1,
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
              ],
            ),
    );
  }

  Widget _buildCalendarCell(
    DateTime day,
    List<Entry> allEntries,
    List<Category> categories, {
    bool isSelected = false,
    bool isToday = false,
  }) {
    final dayEntries = _getEntriesForDay(day, allEntries);

    Entry? entryWithPhoto;
    if (_selectedCategoryId != null && dayEntries.isNotEmpty) {
      try {
        final cat = categories.firstWhere((c) => c.id == _selectedCategoryId);
        if (cat.hasPhotos) {
          entryWithPhoto = dayEntries.firstWhere(
            (e) => (e.thumbnailUrl != null && e.thumbnailUrl!.isNotEmpty) ||
                   (e.photoUrl != null && e.photoUrl!.isNotEmpty),
          );
        }
      } catch (_) {
        entryWithPhoto = null;
      }
    }

    return Container(
      margin: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: isSelected
            ? Border.all(color: Theme.of(context).primaryColor, width: 2.5)
            : isToday
                ? Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 1.5)
                : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (entryWithPhoto != null) ...[
              Image.network(
                _getImageUrl(entryWithPhoto),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 16),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(6.0),
                    ),
                  ),
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ] else ...[
              Container(
                color: isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.2)
                    : Colors.transparent,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (dayEntries.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 2.0,
                          runSpacing: 2.0,
                          children: dayEntries.take(3).map((entry) {
                            Color dotColor = Colors.blue;
                            try {
                              final cat = categories.firstWhere((c) => c.id == entry.categoryId);
                              dotColor = cat.color;
                            } catch (_) {}

                            return Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: dotColor,
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getImageUrl(Entry entry) {
    final path = entry.thumbnailUrl ?? entry.photoUrl ?? '';
    if (path.startsWith('http')) return path;
    return '$_baseUrl/${path.replaceAll('\\', '/')}';
  }
}