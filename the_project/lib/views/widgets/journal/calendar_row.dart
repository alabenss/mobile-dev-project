import 'package:flutter/material.dart';

class CalendarRow extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: daysInMonth,
        itemBuilder: (context, index) {
          final day = index + 1;
          final date = DateTime(year, month, day);
          final dateLabel = _formatDateLabel(date);
          final hasEntries = entriesByDate.containsKey(dateLabel);
          final entryCount = entriesByDate[dateLabel] ?? 0;
          final isSelected = selectedDateLabel == dateLabel;
          final isFuture = date.isAfter(today);

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Opacity(
              opacity: isFuture ? 0.4 : 1.0,
              child: GestureDetector(
                onTap: isFuture ? null : () => onDateTap(dateLabel),
                child: Container(
                  width: 70,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: Colors.blue, width: 2)
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
                          color: isFuture ? Colors.grey[400] : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        day.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isFuture ? Colors.grey[400] : Colors.black,
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
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            entryCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
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