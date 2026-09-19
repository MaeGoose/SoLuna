/// Spacing scale for SoLuna, base unit 8px.
/// Always reach for one of these instead of a bare number in EdgeInsets /
/// SizedBox, so every gap in the app traces back to one file.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4; // tight
  static const double sm = 8; // standard
  static const double md = 16; // card padding
  static const double lg = 24; // screen edge
  static const double xl = 32; // gap between sections
}
