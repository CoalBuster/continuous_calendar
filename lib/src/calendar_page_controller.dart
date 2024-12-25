import 'package:flutter/widgets.dart';

class CalendarPageController extends ChangeNotifier {
  PageController? _pageController;

  void attach(PageController pageController) =>
      _pageController = pageController;

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
}
