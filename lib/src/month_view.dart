import 'package:date_n_time/date_n_time.dart';
import 'package:flutter/material.dart';

import 'day_view.dart';
import 'rendering/month_grid_delegate.dart';

class MonthView extends StatelessWidget {
  final Map<LocalDate, Color>? dayColorMap;
  final Map<LocalDate, Color>? dayTextColorMap;
  final LocalDate month;
  final LocalDateRange? selection;

  const MonthView({
    required this.month,
    this.dayColorMap,
    this.dayTextColorMap,
    this.selection,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final firstDateOfMonth = month.copyWith(dayOfMonth: 1);
    final lastDateOfMonth =
        month.plus(1, ChronoUnit.months).copyWith(dayOfMonth: 0);
    final range = LocalDateRange(firstDateOfMonth, lastDateOfMonth);
    final firstDayOffset =
        DateUtils.firstDayOffset(month.year, month.month, localizations);
    final initialDate = firstDateOfMonth - Period(days: firstDayOffset);
    final weeks = initialDate.until(lastDateOfMonth, ChronoUnit.weeks) + 2;

    return GridView.builder(
      scrollDirection: Axis.vertical,
      itemCount: weeks * 7,
      padding: const EdgeInsets.all(0),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCounts(columnCount: 7, rowCount: 7),
      itemBuilder: (context, index) {
        if (index < DateTime.daysPerWeek) {
          return _buildHeader(index, localizations);
        }

        index -= DateTime.daysPerWeek;
        final date = initialDate + Period(days: index);
        final inMonth = range.contains(date);
        return _buildDay(date, inMonth);
      },
    );
  }

  Widget _buildDay(LocalDate date, bool inMonth) {
    final isSelected = selection?.contains(date) ?? false;
    final isFirstDay = isSelected && date == selection!.start;
    final isLastDay = isSelected && date == selection!.end;

    return DayView(
      date: date,
      enabled: inMonth,
      isInsideSelectedRange: isSelected,
      isFirstDayOfSelectedRange: isFirstDay,
      isLastDayOfSelectedRange: isLastDay,
      backgroundColor: dayColorMap?[date],
      foregroundColor: dayTextColorMap?[date],
      highlightColor: Colors.pink,
      selectedColor: Colors.amber,
    );
  }

  Widget _buildHeader(int index, MaterialLocalizations localizations) {
    final dayOfWeek =
        (index + localizations.firstDayOfWeekIndex) % DateTime.daysPerWeek;
    final label = localizations.narrowWeekdays[dayOfWeek];

    return Center(
      child: Text(label),
    );
  }
}
