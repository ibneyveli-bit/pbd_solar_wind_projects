import 'package:flutter/material.dart';

class NavigationUtils {
  // Fast slide transition for better performance
  static Route<T> createFastRoute<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, _) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.fastOutSlowIn;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 300),
    );
  }

  // Fade transition for lighter pages
  static Route<T> createFadeRoute<T extends Object?>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, _) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: Duration(milliseconds: 250),
    );
  }

  // Optimized navigation method
  static Future<T?> navigateTo<T extends Object?>(BuildContext context, Widget page, {bool useFade = false}) {
    return Navigator.push<T>(
      context,
      useFade ? createFadeRoute<T>(page) : createFastRoute<T>(page),
    );
  }
}