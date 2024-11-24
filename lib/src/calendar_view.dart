import 'package:date_n_time/date_n_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'material_drag_scroll_behavior.dart';
import 'month_view.dart';
import 'paged_scroll_physics.dart';

import 'dart:math' as math;

class CalendarView extends StatefulWidget {
  final Color Function(LocalDate)? dayColorBuilder;
  final Color Function(LocalDate)? dayTextColorBuilder;
  final LocalDate initialDate;
  final ValueChanged<LocalDate>? onDisplayedMonthChanged;

  CalendarView({
    this.dayColorBuilder,
    this.dayTextColorBuilder,
    LocalDate? initialDate,
    this.onDisplayedMonthChanged,
    super.key,
  }) : initialDate = initialDate ?? LocalDate.now();

  @override
  State<StatefulWidget> createState() => _CalenderViewState();
}

class _CalenderViewState extends State<CalendarView> {
  final _center = UniqueKey();
  late PageController _controller;
  var _monthOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _controller.addListener(_onScrollUpdate);
  }

  @override
  Widget build(BuildContext context) {
    final double itemExtent = 42 * 7 + 32;

    final list = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return CustomScrollView(
          scrollBehavior: MaterialDragScrollBehavior(),
          scrollDirection: Axis.horizontal,
          physics: PagedScrollPhysics(itemDimension: itemExtent),
          controller: _controller,
          center: _center,
          anchor: math.max(0, 0.5 - itemExtent / width / 2),
          slivers: [
            SliverList.builder(
              itemBuilder: (context, index) {
                final month = widget.initialDate - Period(months: index + 1);
                return _buildMonth(month);
              },
            ),
            SliverToBoxAdapter(
              key: _center,
              child: _buildMonth(widget.initialDate),
            ),
            SliverList.builder(
              itemBuilder: (context, index) {
                final month = widget.initialDate + Period(months: index + 1);
                return _buildMonth(month);
              },
            ),
          ],
        );
      },
    );

    return SizedBox(
      height: 7 * 42,
      child: list,
    );
  }

  Widget _buildMonth(LocalDate month) {
    final startDate = month.copyWith(dayOfMonth: 1);
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
    if (!_controller.hasClients) {
      return;
    }

    final newMonthOffset = _controller.page!.round();

    if (_monthOffset != newMonthOffset) {
      setState(() {
        _monthOffset = newMonthOffset;
        final month = widget.initialDate.plus(_monthOffset, ChronoUnit.months);
        widget.onDisplayedMonthChanged?.call(month);
      });
    }
  }
}
