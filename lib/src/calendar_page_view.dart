import 'dart:math' as math;

import 'package:date_n_time/date_n_time.dart';
import 'package:flutter/material.dart';

import 'month_view.dart';

class CalendarPageController extends ValueNotifier<LocalDate> {
  CalendarPageController({LocalDate? initialMonth})
      : super(
            initialMonth?.atStartOfMonth() ?? LocalDate.now().atStartOfMonth());

  void previousMonth() {
    value = value.minus(1, ChronoUnit.months);
  }

  void nextMonth() {
    value = value.plus(1, ChronoUnit.months);
  }

  void toMonth(LocalDate value) {
    this.value = value.atStartOfMonth();
  }
}

class CalendarPageView extends StatefulWidget {
  final Map<LocalDate, WidgetStateProperty<Color?>>? dayBackgroundColorMap;
  final Map<LocalDate, WidgetStateProperty<Color?>>? dayForegroundColorMap;
  final Color? rangeSelectionBackgroundColor;
  final LocalDate firstDate;
  final LocalDate lastDate;
  final LocalDate initialDate;
  final ValueChanged<LocalDate>? onDisplayedMonthChanged;
  final void Function(LocalDate? start, LocalDate? end)? onSelectionChanged;
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
    this.onSelectionChanged,
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
  late CalendarPageController _controller;
  late PageController _pageController;
  late LocalDate _firstMonth;

  bool _animating = false;
  bool _scrolling = false;
  LocalDate? _selectedStartDate;
  LocalDate? _selectedEndDate;

  int get _offset => Period.between(_firstMonth, _controller.value).totalMonths;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        CalendarPageController(initialMonth: widget.initialDate);
    _controller.addListener(_onMonthChanged);
    _firstMonth = widget.firstDate.atStartOfMonth();
    _pageController = PageController(initialPage: _offset);
  }

  @override
  void didUpdateWidget(covariant CalendarPageView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != null && _controller != widget.controller) {
      final displayedMonth = _controller.value;
      _controller.dispose();
      _controller = widget.controller ??
          CalendarPageController(initialMonth: displayedMonth);
      _controller.addListener(_onMonthChanged);
      _onMonthChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalMonths =
        Period.between(_firstMonth, widget.lastDate).totalMonths + 1;
    final double itemExtent = 42 * 7 + 32;

    final list = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        _pageController.dispose();
        _pageController = PageController(
          initialPage: _offset,
          viewportFraction: math.min(1, itemExtent / width),
        );

        return PageView.builder(
          scrollBehavior: widget.scrollBehavior,
          scrollDirection: widget.scrollDirection,
          controller: _pageController,
          itemCount: totalMonths,
          itemBuilder: (context, index) {
            final month = _firstMonth + Period(months: index);
            return _buildMonth(month);
          },
          onPageChanged: _onPageChanged,
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
        widget.onSelectionChanged?.call(_selectedStartDate, _selectedEndDate);
        return;
      }

      _selectedEndDate = date;
      widget.onSelectionChanged?.call(_selectedStartDate, _selectedEndDate);
    });
  }

  _onMonthChanged() {
    if (_scrolling) {
      return;
    }

    final month = _firstMonth.plus(_offset, ChronoUnit.months);
    final future = _pageController.animateToPage(
      _offset,
      duration: kTabScrollDuration,
      curve: Curves.easeInOut,
    );
    _animating = true;
    future.then((_) => _animating = false);
    widget.onDisplayedMonthChanged?.call(month);
  }

  _onPageChanged(int offset) {
    if (_animating) {
      return;
    }

    final month = _firstMonth.plus(offset, ChronoUnit.months);
    _scrolling = true;
    _controller.value = month;
    widget.onDisplayedMonthChanged?.call(month);
    _scrolling = false;
  }
}
