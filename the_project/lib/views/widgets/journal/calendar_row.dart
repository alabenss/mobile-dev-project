import 'package:flutter/material.dart';
import '../../themes/style_simple/colors.dart';

class CalendarRow extends StatefulWidget {
  final int month;
  final int year;
  final String? selectedDateLabel;
  final Map<String, int> entriesByDate;
  final Function(String dateLabel) onDateTap;

  const CalendarRow({
    super.key,
    required this.month,
    required this.year,
    this.selectedDateLabel,
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
    // Scroll to today after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }

  @override
  void didUpdateWidget(CalendarRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset scroll flag if month/year changed
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
    // Only auto-scroll if we're viewing the current month
    if (widget.month == now.month && widget.year == now.year) {
      final todayIndex = now.day - 1;
      // Calculate position: each item is 70 width + 8 padding
      final scrollPosition = todayIndex * 78.0;
      // Scroll to center the current day
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
          final dateLabel = _formatDateLabel(date);
          final hasEntries = widget.entriesByDate.containsKey(dateLabel);
          final entryCount = widget.entriesByDate[dateLabel] ?? 0;
          final isSelected = widget.selectedDateLabel == dateLabel;
          final isFuture = date.isAfter(today);

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Opacity(
              opacity: isFuture ? 0.4 : 1.0,
              child: GestureDetector(
                onTap: isFuture ? null : () => widget.onDateTap(dateLabel),
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
                        _getWeekdayShort(date.weekday),
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

  String _formatDateLabel(DateTime date) {
    return '${_getWeekdayFull(date.weekday)}, ${_getMonthShort(date.month)} ${date.day}';
  }

  String _getWeekdayShort(int w) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][w - 1];

  String _getWeekdayFull(int w) => [
        'Monday', 'Tuesday', 'Wednesday', 'Thursday',
        'Friday', 'Saturday', 'Sunday'
      ][w - 1];

  String _getMonthShort(int m) => [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m - 1];
}