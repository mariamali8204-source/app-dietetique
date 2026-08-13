import 'package:flutter/foundation.dart';

class NavigationViewModel extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void updateIndex(int newIndex) {
    if (newIndex < 0 || newIndex > 4) {
      return;
    }

    if (_currentIndex == newIndex) {
      return;
    }

    _currentIndex = newIndex;

    notifyListeners();
  }
}
