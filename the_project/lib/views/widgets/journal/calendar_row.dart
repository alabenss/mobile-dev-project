import 'package:flutter/material.dart';
import 'package:the_project/l10n/app_localizations.dart';

import '../../themes/style_simple/colors.dart';

class CalendarRow extends StatefulWidget {
  final int month;
  final int year;
  final DateTime? selectedDate;
  final Map<String, int> entriesByDate; // Map uses dateKey (YYYY-MM-DD)
  final Function(DateTime date) onDateTap;

  const CalendarRow({
    super.key,
    required this.month,
    required this.year,
    this.selectedDate,
    required this.entriesByDate,
    required this.onDateTap,
  });

  @override
  State<CalendarRow> createState() => _CalendarRowState();
}

class _CalendarRowState extends State<CalendarRow> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToToday = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }

  @override
  void didUpdateWidget(CalendarRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month != widget.month || oldWidget.year != widget.year) {
      _hasScrolledToToday = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToToday();
      });
    }
  }

  void _scrollToToday() {
    if (_hasScrolledToToday || !_scrollController.hasClients) return;

    final now = DateTime.now();
    if (widget.month == now.month && widget.year == now.year) {
      final todayIndex = now.day - 1;
      final scrollPosition = todayIndex * 78.0;
      final offset = (scrollPosition - (MediaQuery.of(context).size.width / 2) + 39).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );

      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      _hasScrolledToToday = true;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final daysInMonth = DateTime(widget.year, widget.month + 1, 0).day;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return SizedBox(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: daysInMonth,
        itemBuilder: (context, index) {
          final day = index + 1;
          final date = DateTime(widget.year, widget.month, day);
          final dateKey = _getDateKey(date);
          final hasEntries = widget.entriesByDate.containsKey(dateKey);
          final entryCount = widget.entriesByDate[dateKey] ?? 0;
          final isSelected = widget.selectedDate != null && _isSameDay(widget.selectedDate!, date);
          final isFuture = date.isAfter(today);

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Opacity(
              opacity: isFuture ? 0.4 : 1.0,
              child: GestureDetector(
                onTap: isFuture ? null : () => widget.onDateTap(date),
                child: Container(
                  width: 70,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentBlue.withOpacity(0.2)
                        : AppColors.card.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: AppColors.accentBlue, width: 2)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getWeekdayShort(date.weekday, l10n),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isFuture ? AppColors.textSecondary.withOpacity(0.6) : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        day.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isFuture ? AppColors.textSecondary.withOpacity(0.6) : AppColors.textPrimary,
                        ),
                      ),
                      if (hasEntries && !isFuture) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            entryCount.toString(),
                            style: const TextStyle(
                              color: AppColors.card,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getWeekdayShort(int w, AppLocalizations l10n) {
    final weekdays = [
      l10n.journalCalendarMon,
      l10n.journalCalendarTue,
      l10n.journalCalendarWed,
      l10n.journalCalendarThu,
      l10n.journalCalendarFri,
      l10n.journalCalendarSat,
      l10n.journalCalendarSun
    ];
    return weekdays[w - 1];
  }
}