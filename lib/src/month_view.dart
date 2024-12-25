import 'package:date_n_time/date_n_time.dart';
import 'package:flutter/material.dart';

import 'day_view.dart';
import 'rendering/month_grid_delegate.dart';

typedef SelectableDatePredicate = bool Function(
    LocalDate date, LocalDate? selectedStartDate, LocalDate? selectedEndDate);

class MonthView extends StatelessWidget {
  final Map<LocalDate, WidgetStateProperty<Color?>>? dayBackgroundColorMap;
  final Map<LocalDate, WidgetStateProperty<Color?>>? dayForegroundColorMap;
  final Color? rangeSelectionBackgroundColor;
  final LocalDate month;
  final LocalDate? selectedStartDate;
  final LocalDate? selectedEndDate;
  final SelectableDatePredicate? selectableDayPredicate;
  final void Function(LocalDate)? onChanged;

  const MonthView({
    required this.month,
    this.dayBackgroundColorMap,
    this.dayForegroundColorMap,
    this.rangeSelectionBackgroundColor,
    this.selectedStartDate,
    this.selectedEndDate,
    this.selectableDayPredicate,
    this.onChanged,
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
    final isSelected = selectedStartDate == null
        ? false
        : selectedEndDate == null
            ? date == selectedStartDate
            : LocalDateRange(selectedStartDate!, selectedEndDate!)
                .contains(date);
    final isFirstDay = date == selectedStartDate;
    final isLastDay = date == (selectedEndDate ?? selectedStartDate);

    return DayView(
      date: date,
      enabled: inMonth,
      isInsideSelectedRange: isSelected,
      isFirstDayOfSelectedRange: isFirstDay,
      isLastDayOfSelectedRange: isLastDay,
      backgroundColor: dayBackgroundColorMap?[date],
      foregroundColor: dayForegroundColorMap?[date],
      rangeSelectionBackgroundColor: rangeSelectionBackgroundColor,
      onChanged: (selectableDayPredicate?.call(
                  date, selectedStartDate, selectedEndDate) ??
              true)
          ? onChanged
          : null,
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
