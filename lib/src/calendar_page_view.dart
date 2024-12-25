import 'package:date_n_time/date_n_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'calendar_page_controller.dart';
import 'month_view.dart';

import 'dart:math' as math;

class CalendarPageView extends StatefulWidget {
  final Map<LocalDate, WidgetStateProperty<Color?>>? dayBackgroundColorMap;
  final Map<LocalDate, WidgetStateProperty<Color?>>? dayForegroundColorMap;
  final Color? rangeSelectionBackgroundColor;
  final LocalDate firstDate;
  final LocalDate lastDate;
  final LocalDate initialDate;
  final ValueChanged<LocalDate>? onDisplayedMonthChanged;
  final SelectableDatePredicate? selectableDayPredicate;
  final ScrollBehavior? scrollBehavior;
  final Axis scrollDirection;
  final CalendarPageController? controller;

  CalendarPageView({
    required this.firstDate,
    required this.lastDate,
    this.dayBackgroundColorMap,
    this.dayForegroundColorMap,
    this.rangeSelectionBackgroundColor,
    LocalDate? initialDate,
    this.onDisplayedMonthChanged,
    this.selectableDayPredicate,
    this.scrollBehavior,
    this.scrollDirection = Axis.horizontal,
    this.controller,
    super.key,
  }) : initialDate = initialDate ?? LocalDate.now();

  @override
  State<StatefulWidget> createState() => _CalenderPageViewState();
}

class _CalenderPageViewState extends State<CalendarPageView> {
  PageController? _pageController;
  late LocalDate _firstMonth;
  late int _monthOffset;
  LocalDate? _selectedStartDate;
  LocalDate? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _firstMonth = widget.firstDate.atStartOfMonth();
    final displayedMonth = widget.initialDate.atStartOfMonth();
    _monthOffset = Period.between(_firstMonth, displayedMonth).months;
  }

  @override
  Widget build(BuildContext context) {
    final totalMonths = Period.between(_firstMonth, widget.lastDate).months + 1;
    final double itemExtent = 42 * 7 + 32;

    final list = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        _pageController?.dispose();
        _pageController = PageController(
          initialPage: _monthOffset,
          viewportFraction: math.min(1, itemExtent / width),
        );
        _pageController!.addListener(_onScrollUpdate);
        widget.controller?.attach(_pageController!);

        return PageView.builder(
          scrollBehavior: widget.scrollBehavior,
          scrollDirection: widget.scrollDirection,
          controller: _pageController,
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: 42 * 7,
        child: MonthView(
          dayBackgroundColorMap: widget.dayBackgroundColorMap,
          dayForegroundColorMap: widget.dayForegroundColorMap,
          rangeSelectionBackgroundColor: widget.rangeSelectionBackgroundColor,
          month: month,
          selectedStartDate: _selectedStartDate,
          selectedEndDate: _selectedEndDate,
          selectableDayPredicate: widget.selectableDayPredicate,
          onChanged: _onChanged,
        ),
      ),
    );
  }

  _onChanged(LocalDate date) {
    setState(() {
      if (_selectedStartDate == null ||
          _selectedEndDate != null ||
          date < _selectedStartDate!) {
        _selectedStartDate = date;
        _selectedEndDate = null;
        return;
      }

      _selectedEndDate = date;
    });
  }

  _onScrollUpdate() {
    if (!_pageController!.hasClients) {
      return;
    }

    final newMonthOffset = _pageController!.page!.round();

    if (_monthOffset != newMonthOffset) {
      setState(() {
        _monthOffset = newMonthOffset;
        final month = _firstMonth.plus(_monthOffset, ChronoUnit.months);
        widget.onDisplayedMonthChanged?.call(month);
      });
    }
  }
}
