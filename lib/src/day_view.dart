import 'package:date_n_time/date_n_time.dart';
import 'package:flutter/material.dart';

class DayView extends StatelessWidget {
  final LocalDate date;
  final bool enabled;
  final bool isInsideSelectedRange;
  final bool isFirstDayOfSelectedRange;
  final bool isLastDayOfSelectedRange;
  final WidgetStateProperty<Color?>? backgroundColor;
  final WidgetStateProperty<Color?>? foregroundColor;
  final Color? rangeSelectionBackgroundColor;
  final ValueChanged<LocalDate>? onChanged;

  const DayView({
    required this.date,
    required this.enabled,
    required this.isInsideSelectedRange,
    required this.isFirstDayOfSelectedRange,
    required this.isLastDayOfSelectedRange,
    this.backgroundColor,
    this.foregroundColor,
    this.rangeSelectionBackgroundColor,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final calendarTheme = DatePickerTheme.of(context);
    final calendarDefaultTheme = DatePickerTheme.defaults(context);
    final cardTheme = CardTheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    final Set<WidgetState> states = {
      if (!enabled) WidgetState.disabled,
      if (isFirstDayOfSelectedRange || isLastDayOfSelectedRange)
        WidgetState.selected,
    };

    final resolvedBackgroundColor = backgroundColor?.resolve(states) ??
        calendarTheme.dayBackgroundColor?.resolve(states) ??
        calendarDefaultTheme.dayBackgroundColor?.resolve(states);
    final resolvedForegroundColor =
        (isInsideSelectedRange ? null : foregroundColor?.resolve(states)) ??
            calendarTheme.dayForegroundColor?.resolve(states) ??
            calendarDefaultTheme.dayForegroundColor?.resolve(states);
    final resolvedRangeSelectionBackgroundColor =
        rangeSelectionBackgroundColor ??
            calendarTheme.rangeSelectionBackgroundColor ??
            calendarDefaultTheme.rangeSelectionBackgroundColor;
    final resolvedOverlayColor =
        calendarTheme.dayOverlayColor ?? calendarDefaultTheme.dayOverlayColor;

    TextStyle? dayTextStyle =
        textTheme.bodyMedium?.apply(color: resolvedForegroundColor);

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

    if (onChanged != null) {
      widget = InkWell(
        overlayColor: resolvedOverlayColor,
        onTap: () => onChanged!(date),
        child: widget,
      );
    }

    final showCard = isFirstDayOfSelectedRange ||
        isLastDayOfSelectedRange ||
        !isInsideSelectedRange;
    final isSingleSelectedDay =
        isFirstDayOfSelectedRange && isLastDayOfSelectedRange;
    final showLeft = !isSingleSelectedDay &&
        !isFirstDayOfSelectedRange &&
        isInsideSelectedRange;
    final showRight = !isSingleSelectedDay &&
        !isLastDayOfSelectedRange &&
        isInsideSelectedRange;

    widget = Card.filled(
      color: (showCard ? resolvedBackgroundColor : null) ?? Colors.transparent,
      margin: const EdgeInsets.all(2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      clipBehavior: Clip.antiAlias,
      child: widget,
    );

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
                  color:
                      showLeft ? resolvedRangeSelectionBackgroundColor : null,
                ),
              ),
              Expanded(
                child: Container(
                  color:
                      showRight ? resolvedRangeSelectionBackgroundColor : null,
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
