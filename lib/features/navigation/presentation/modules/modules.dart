import 'package:flutter/material.dart';

class HomePageModule {
  void movePageTo(PageController controller, int index) {
    controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
  }
}
