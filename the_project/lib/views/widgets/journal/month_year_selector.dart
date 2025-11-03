import 'package:flutter/material.dart';
import '../../themes/style_simple/colors.dart';

class MonthYearSelector extends StatelessWidget {
  final int selectedMonth;
  final int selectedYear;
  final Function(int month, int year) onChanged;

  const MonthYearSelector({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedMonth,
                isExpanded: true,
                items: List.generate(12, (index) {
                  final month = index + 1;
                  return DropdownMenuItem(
                    value: month,
                    child: Text(_getMonthName(month)),
                  );
                }),
                onChanged: (month) {
                  if (month != null) onChanged(month, selectedYear);
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedYear,
                isExpanded: true,
                items: List.generate(10, (index) {
                  final year = DateTime.now().year - 5 + index;
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  );
                }),
                onChanged: (year) {
                  if (year != null) onChanged(selectedMonth, year);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}