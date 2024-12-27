import 'package:date_n_time/date_n_time.dart';
import 'package:flutter/widgets.dart';

class CalendarPageController extends ChangeNotifier {
  LocalDate? _firstMonth;
  PageController? _pageController;

  void attach(PageController pageController, LocalDate firstMonth) {
    _firstMonth = firstMonth;
    _pageController = pageController;
  }

  Future<void> previousMonth({
    required Duration duration,
    required Curve curve,
  }) {
    if (_pageController == null) {
      return Future<void>.value();
    }

    return _pageController!.previousPage(duration: duration, curve: curve);
  }

  Future<void> nextMonth({
    required Duration duration,
    required Curve curve,
  }) {
    if (_pageController == null) {
      return Future<void>.value();
    }

    return _pageController!.nextPage(duration: duration, curve: curve);
  }

  Future<void> toMonth(
    LocalDate month, {
    required Duration duration,
    required Curve curve,
  }) {
    if (_pageController == null || _firstMonth == null) {
      return Future<void>.value();
    }

    final offset = Period.between(_firstMonth!, month.atStartOfMonth());
    return _pageController!.animateToPage(
      offset.years * 12 + offset.months,
      duration: duration,
      curve: curve,
    );
  }
}
