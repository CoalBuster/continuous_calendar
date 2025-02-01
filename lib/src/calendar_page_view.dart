import 'dart:math' as math;

import 'package:date_n_time/date_n_time.dart';
import 'package:flutter/material.dart';

import 'month_view.dart';

class CalendarPageController with ChangeNotifier {
  LocalDate _displayedMonth;
  LocalDate? _selectedStartDate;
  LocalDate? _selectedEndDate;

  CalendarPageController({LocalDate? initialMonth})
      : _displayedMonth =
            initialMonth?.atStartOfMonth() ?? LocalDate.now().atStartOfMonth();

  LocalDate get displayedMonth => _displayedMonth;
  LocalDate? get selectedStartDate => _selectedStartDate;
  LocalDate? get selectedEndDate => _selectedEndDate;

  void previousMonth() {
    _displayedMonth = _displayedMonth.minus(1, ChronoUnit.months);
    notifyListeners();
  }

  void nextMonth() {
    _displayedMonth = _displayedMonth.plus(1, ChronoUnit.months);
    notifyListeners();
  }

  void toMonth(LocalDate value) {
    _displayedMonth = value.atStartOfMonth();
    notifyListeners();
  }

  void setSelection(LocalDate? start, LocalDate? end) {
    _selectedStartDate = start;
    _selectedEndDate = end;
    notifyListeners();
  }

  void resetSelection() {
    _selectedStartDate = null;
    _selectedEndDate = null;
    notifyListeners();
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
  final TextStyle? dayTextStyle;
  final TextStyle? headerTextStyle;

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
    this.dayTextStyle,
    this.headerTextStyle,
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

  int get _offset =>
      Period.between(_firstMonth, _controller.displayedMonth).totalMonths;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        CalendarPageController(initialMonth: widget.initialDate);
    widget.controller?.addListener(_handleControllerChanged);
    _firstMonth = widget.firstDate.atStartOfMonth();
    _pageController = PageController(initialPage: _offset);
  }

  @override
  void didUpdateWidget(covariant CalendarPageView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller == null || _controller != widget.controller) {
      final displayedMonth = _controller.displayedMonth;
      _controller.dispose();
      _controller = widget.controller ??
          CalendarPageController(initialMonth: displayedMonth);
      widget.controller?.addListener(_handleControllerChanged);
      _handleControllerChanged();
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
          dayTextStyle: widget.dayTextStyle,
          headerTextStyle: widget.headerTextStyle,
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
        _controller.setSelection(_selectedStartDate, _selectedEndDate);
        widget.onSelectionChanged?.call(_selectedStartDate, _selectedEndDate);
        return;
      }

      _selectedEndDate = date;
      _controller.setSelection(_selectedStartDate, _selectedEndDate);
      widget.onSelectionChanged?.call(_selectedStartDate, _selectedEndDate);
    });
  }

  _handleControllerChanged() {
    if (_controller._selectedEndDate != _selectedEndDate ||
        _controller.selectedStartDate != _selectedStartDate) {
      setState(() {
        _selectedStartDate = _controller.selectedStartDate;
        _selectedEndDate = _controller.selectedEndDate;
      });
      widget.onSelectionChanged?.call(_selectedStartDate, _selectedEndDate);
    }

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
    _controller.toMonth(month);
    widget.onDisplayedMonthChanged?.call(month);
    _scrolling = false;
  }
}
