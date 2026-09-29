import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Lets desktop/web users click-and-drag to scroll horizontal lists (like
/// Today's Memory Collections row) with a plain mouse. Flutter's default
/// scroll behavior only allows drag-scrolling from touch/stylus/trackpad,
/// which makes horizontal lists effectively unscrollable for anyone on a
/// PC with just a mouse and no trackpad.
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}
