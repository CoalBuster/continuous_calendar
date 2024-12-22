import 'package:continuous_calendar/continuous_calendar.dart';
import 'package:date_n_time/date_n_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // showDatePicker(
    //   context: context,
    //   firstDate: firstDate,
    //   lastDate: lastDate,
    // );

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Example App'),
      ),
      body: Column(
        children: [
          CalendarPageView(
            firstDate: firstDate,
            lastDate: lastDate,
            dayColorBuilder: _availabilityColor,
            dayTextColorBuilder: (date) => Colors.white,
            onDisplayedMonthChanged: (date) =>
                setState(() => displayedMonth = date),
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

  Color _availabilityColor(LocalDate date) {
    final locale = Localizations.localeOf(context);
    final today = LocalDate.now();
    final startOfWeek = today.atStartOfWeek(locale.toString());
    final endOfWeek = startOfWeek.plus(6, ChronoUnit.days);
    final startOfNearWeek = startOfWeek.minus(1, ChronoUnit.weeks);
    final endOfNearWeek = endOfWeek.plus(1, ChronoUnit.weeks);
    final startOfPrevMonth = today.minus(1, ChronoUnit.months).atStartOfMonth();
    final endOfNextMonth = today.plus(1, ChronoUnit.months).atEndOfMonth();

    final totalRange = LocalDateRange(startOfPrevMonth, endOfNextMonth);
    final nearRange = LocalDateRange(startOfNearWeek, endOfNearWeek);
    final weekRange = LocalDateRange(startOfWeek, endOfWeek);

    if (weekRange.contains(date)) {
      return Colors.red;
    }

    if (nearRange.contains(date)) {
      return Colors.orange;
    }

    if (totalRange.contains(date)) {
      return Colors.green;
    }

    return Colors.grey;
  }
}
