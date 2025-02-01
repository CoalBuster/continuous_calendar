import 'package:continuous_calendar/continuous_calendar.dart';
import 'package:date_n_time/date_n_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'src/material_drag_scroll_behavior.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example App',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHome(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: const [
        Locale('nl'),
      ],
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<StatefulWidget> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  // LocalDate displayedMonth = LocalDate.now().atStartOfMonth();
  CalendarPageController controller = CalendarPageController();

  @override
  Widget build(BuildContext context) {
    final today = LocalDate.now();
    final firstDate = today.minus(2, ChronoUnit.months);
    final lastDate = today.plus(2, ChronoUnit.months);

    final availability = _generateAvailability();
    final colorMap = availability.map((key, value) => MapEntry(
        key,
        switch (value) {
          Availability.available => _colorAvailable,
          Availability.blocked => _colorBlocked,
          Availability.booked => _colorBooked,
          Availability.unavailable => _colorUnavailable,
        }));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Example App'),
        actions: [
          IconButton(
            onPressed: () => showDateRangePicker(
              context: context,
              firstDate: firstDate.atStartOfDay().atZone(ZoneId.system),
              lastDate: lastDate.atStartOfDay().atZone(ZoneId.system),
            ),
            icon: Icon(Icons.calendar_month),
          ),
          IconButton(
            onPressed: () => showDatePicker(
              context: context,
              firstDate: firstDate.atStartOfDay().atZone(ZoneId.system),
              lastDate: lastDate.atStartOfDay().atZone(ZoneId.system),
            ),
            icon: Icon(Icons.calendar_today),
          ),
        ],
      ),
      body: Column(
        children: [
          CalendarPageView(
            firstDate: firstDate,
            lastDate: lastDate,
            dayBackgroundColorMap: colorMap,
            rangeSelectionBackgroundColor: Colors.blue[200],
            scrollBehavior: MaterialDragScrollBehavior(),
            scrollDirection: Axis.horizontal,
            controller: controller,
            // onDisplayedMonthChanged: (date) =>
            //     setState(() => displayedMonth = date),
            selectableDayPredicate:
                (date, selectedStartDate, selectedEndDate) =>
                    availability[date] == Availability.available,
          ),
          ListenableBuilder(
            listenable: controller,
            builder: (context, child) {
              final localizations = MaterialLocalizations.of(context);
              final monthText = localizations.formatMonthYear(
                  controller.value.atStartOfDay().atZone(ZoneId.utc));

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: controller.previousMonth,
                    icon: Icon(Icons.chevron_left),
                  ),
                  Text(monthText),
                  IconButton(
                    onPressed: controller.nextMonth,
                    icon: Icon(Icons.chevron_right),
                  ),
                  IconButton(
                    onPressed: () => controller
                        .toMonth(controller.value.plus(2, ChronoUnit.months)),
                    icon: Icon(Icons.fast_forward),
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Map<LocalDate, Availability> _generateAvailability() {
    final locale = Localizations.localeOf(context);
    final today = LocalDate.now();
    final startOfWeek = today.atStartOfWeek(locale.toString());
    final endOfWeek = startOfWeek.plus(6, ChronoUnit.days);
    final startOfNearWeek = startOfWeek.minus(1, ChronoUnit.weeks);
    final endOfNearWeek = endOfWeek.plus(1, ChronoUnit.weeks);
    final startOfPrevMonth = today.minus(1, ChronoUnit.months).atStartOfMonth();
    final endOfNextMonth = today.plus(1, ChronoUnit.months).atEndOfMonth();
    final firstDate = today.minus(2, ChronoUnit.months);
    final lastDate = today.plus(2, ChronoUnit.months);

    final visibleRange = LocalDateRange(firstDate, lastDate);
    final totalRange = LocalDateRange(startOfPrevMonth, endOfNextMonth);
    final nearRange = LocalDateRange(startOfNearWeek, endOfNearWeek);
    final weekRange = LocalDateRange(startOfWeek, endOfWeek);

    var visibleMap = {
      for (var date in visibleRange.toLocalDates())
        date: Availability.unavailable
    };

    var totalMap = {
      for (var date in totalRange.toLocalDates()) date: Availability.available
    };

    var nearMap = {
      for (var date in nearRange.toLocalDates()) date: Availability.blocked
    };

    var weekMap = {
      for (var date in weekRange.toLocalDates()) date: Availability.booked
    };

    visibleMap
      ..addAll(totalMap)
      ..addAll(nearMap)
      ..addAll(weekMap);

    return visibleMap;
  }

  static const _colorAvailable = WidgetStateColor.fromMap({
    WidgetState.selected: Color(0xFF2E7D32),
    WidgetState.any: Color(0xFFA5D6A7),
  });
  static const _colorBlocked = WidgetStateColor.fromMap({
    WidgetState.selected: Color(0xFFEF6C00),
    WidgetState.any: Color(0xFFFFCC80),
  });
  static const _colorBooked = WidgetStateColor.fromMap({
    WidgetState.selected: Color(0xFFC62828),
    WidgetState.any: Color(0xFFEF9A9A),
  });
  static const _colorUnavailable = WidgetStateColor.fromMap({
    WidgetState.any: Color(0xFFE0E0E0),
  });
}

enum Availability {
  unavailable,
  booked,
  blocked,
  available;
}
