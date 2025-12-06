import 'package:flutter/material.dart';
import 'package:the_project/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    
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
                    child: Text(_getMonthName(month, l10n)),
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

  String _getMonthName(int month, AppLocalizations l10n) {
    final months = [
      l10n.journalMonthJanuary,
      l10n.journalMonthFebruary,
      l10n.journalMonthMarch,
      l10n.journalMonthApril,
      l10n.journalMonthMayFull,
      l10n.journalMonthJune,
      l10n.journalMonthJuly,
      l10n.journalMonthAugust,
      l10n.journalMonthSeptember,
      l10n.journalMonthOctober,
      l10n.journalMonthNovember,
      l10n.journalMonthDecember
    ];
    return months[month - 1];
  }
}