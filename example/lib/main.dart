import 'package:continuous_calendar/continuous_calendar.dart';
import 'package:date_n_time/date_n_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
  LocalDate displayedMonth = LocalDate.now().atStartOfMonth();

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final monthText = localizations
        .formatMonthYear(displayedMonth.atStartOfDay().atZone(ZoneId.utc));

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
            onDisplayedMonthChanged: (date) =>
                setState(() => displayedMonth = date),
            selectableDayPredicate:
                (date, selectedStartDate, selectedEndDate) =>
                    availability[date] == Availability.available,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: null, icon: Icon(Icons.chevron_left)),
              Text(monthText),
              IconButton(onPressed: null, icon: Icon(Icons.chevron_right)),
            ],
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

  final _colorAvailable = WidgetStateColor.fromMap({
    WidgetState.selected: Colors.green[800]!,
    WidgetState.any: Colors.green[200]!,
  });
  final _colorBlocked = WidgetStateColor.fromMap({
    WidgetState.selected: Colors.orange[800]!,
    WidgetState.any: Colors.orange[200]!,
  });
  final _colorBooked = WidgetStateColor.fromMap({
    WidgetState.selected: Colors.red[800]!,
    WidgetState.any: Colors.red[200]!,
  });
  final _colorUnavailable = WidgetStateColor.fromMap({
    WidgetState.any: Colors.grey[300]!,
  });
  final _colorText = WidgetStateColor.fromMap({
    WidgetState.selected: Colors.white,
    WidgetState.any: Colors.black,
  });

  // dayBackgroundColorMap: dayColorMap?.map(
  //           (key, value) => MapEntry(
  //             key,
  //             WidgetStateColor.fromMap({WidgetState.any: value}),
  //           ),
  //         ),
  //         dayForegroundColorMap: dayTextColorMap?.map(
  //           (key, value) => MapEntry(
  //             key,
  //             WidgetStateColor.fromMap({WidgetState.any: value}),
  //           ),
  //         ),
}

enum Availability {
  unavailable,
  booked,
  blocked,
  available;
}
