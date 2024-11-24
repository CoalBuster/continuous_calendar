import 'package:date_n_time/date_n_time.dart';
import 'package:flutter/material.dart';

class DayView extends StatelessWidget {
  final LocalDate date;
  // final LocalDateRange? selection;
  final bool enabled;
  final bool isInsideSelectedRange;
  final bool isFirstDayOfSelectedRange;
  final bool isLastDayOfSelectedRange;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color highlightColor;
  final Color? selectedColor;

  const DayView({
    required this.date,
    required this.enabled,
    // this.selection,
    required this.isInsideSelectedRange,
    required this.isFirstDayOfSelectedRange,
    required this.isLastDayOfSelectedRange,
    this.backgroundColor,
    this.foregroundColor,
    required this.highlightColor,
    this.selectedColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cardTheme = CardTheme.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    TextStyle? dayTextStyle = textTheme.bodyMedium
        ?.apply(color: enabled ? foregroundColor : theme.disabledColor);

    // final isSelected = selection?.contains(date) ?? false;
    // final isFirstDay = isSelected && date == selection!.start;
    // final isLastDay = isSelected && date == selection!.end;

    final localizations = MaterialLocalizations.of(context);

    final dayText = localizations.formatDecimal(date.dayOfMonth);

    Widget widget = Center(
      child: Text(
        dayText,
        style: dayTextStyle,
      ),
    );

    if (!enabled) {
      return widget;
    }

    if (isFirstDayOfSelectedRange ||
        isLastDayOfSelectedRange ||
        !isInsideSelectedRange) {
      widget = Card.filled(
        color: isInsideSelectedRange ? selectedColor : backgroundColor,
        margin: const EdgeInsets.all(2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: widget,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding:
              EdgeInsets.symmetric(vertical: cardTheme.margin?.vertical ?? 4.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  color: !isFirstDayOfSelectedRange && isInsideSelectedRange
                      ? highlightColor
                      : null,
                ),
              ),
              Expanded(
                child: Container(
                  color: !isLastDayOfSelectedRange && isInsideSelectedRange
                      ? highlightColor
                      : null,
                ),
              ),
            ],
          ),
        ),
        widget,
      ],
    );
  }
}
