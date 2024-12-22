import 'package:date_n_time/date_n_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'material_drag_scroll_behavior.dart';
import 'month_view.dart';

import 'dart:math' as math;

class CalendarPageView extends StatefulWidget {
  final Color Function(LocalDate)? dayColorBuilder;
  final Color Function(LocalDate)? dayTextColorBuilder;
  final LocalDate firstDate;
  final LocalDate lastDate;
  final LocalDate initialDate;
  final ValueChanged<LocalDate>? onDisplayedMonthChanged;

  CalendarPageView({
    required this.firstDate,
    required this.lastDate,
    this.dayColorBuilder,
    this.dayTextColorBuilder,
    LocalDate? initialDate,
    this.onDisplayedMonthChanged,
    super.key,
  }) : initialDate = initialDate ?? LocalDate.now();

  @override
  State<StatefulWidget> createState() => _CalenderPageViewState();
}

class _CalenderPageViewState extends State<CalendarPageView> {
  PageController? _controller;
  late LocalDate _firstMonth;
  late int _monthOffset;

  @override
  void initState() {
    super.initState();
    _firstMonth = widget.firstDate.atStartOfMonth();
    _monthOffset = Period.between(_firstMonth, widget.initialDate).months;
  }

  @override
  Widget build(BuildContext context) {
    final totalMonths = Period.between(_firstMonth, widget.lastDate).months + 1;
    final double itemExtent = 42 * 7 + 32;

    final list = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        _controller?.dispose();
        _controller = PageController(
          initialPage: _monthOffset,
          viewportFraction: math.min(1, itemExtent / width),
        );
        _controller!.addListener(_onScrollUpdate);

        return PageView.builder(
          scrollBehavior: MaterialDragScrollBehavior(),
          scrollDirection: Axis.horizontal,
          controller: _controller,
          itemCount: totalMonths,
          itemBuilder: (context, index) {
            final month = _firstMonth + Period(months: index);
            return _buildMonth(month);
          },
        );
      },
    );

    return SizedBox(
      height: 7 * 42,
      child: list,
    );
  }

  Widget _buildMonth(LocalDate month) {
    final startDate = month.atStartOfMonth();
    final endDate = month.plus(1, ChronoUnit.months).copyWith(dayOfMonth: 0);
    final range = LocalDateRange(startDate, endDate);
    Map<LocalDate, Color>? dayColorMap;
    Map<LocalDate, Color>? dayTextColorMap;

    if (widget.dayColorBuilder != null) {
      dayColorMap = {
        for (var date in range.toLocalDates())
          date: widget.dayColorBuilder!(date)
      };
    }

    if (widget.dayTextColorBuilder != null) {
      dayTextColorMap = {
        for (var date in range.toLocalDates())
          date: widget.dayTextColorBuilder!(date)
      };
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: 42 * 7,
        child: MonthView(
          dayColorMap: dayColorMap,
          dayTextColorMap: dayTextColorMap,
          month: month,
        ),
      ),
    );
  }

  _onScrollUpdate() {
    if (!_controller!.hasClients) {
      return;
    }

    final newMonthOffset = _controller!.page!.round();

    if (_monthOffset != newMonthOffset) {
      setState(() {
        _monthOffset = newMonthOffset;
        final month = _firstMonth.plus(_monthOffset, ChronoUnit.months);
        widget.onDisplayedMonthChanged?.call(month);
      });
    }
  }
}
