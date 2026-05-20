/// Time-of-day greeting for the Home tab.
String timeGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'morning';
  if (hour < 17) return 'afternoon';
  return 'evening';
}
