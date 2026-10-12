/// Human-friendly date formatting shared across the UI
/// (e.g. "12 Oct 2026", "12 – 14 Oct 2026", "09:30").
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String monthShort(DateTime d) => _months[d.month - 1];

String formatDate(DateTime d) => '${d.day} ${monthShort(d)} ${d.year}';

String formatTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String formatDateTime(DateTime d) => '${formatDate(d)} · ${formatTime(d)}';

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// "12 Oct 2026" for a single day, otherwise the shortest unambiguous range:
/// "12 – 14 Oct 2026", "28 Oct – 2 Nov 2026" or "30 Dec 2026 – 2 Jan 2027".
String formatDateRange(DateTime start, DateTime end) {
  if (isSameDay(start, end)) return formatDate(start);
  if (start.year != end.year) {
    return '${formatDate(start)} – ${formatDate(end)}';
  }
  if (start.month != end.month) {
    return '${start.day} ${monthShort(start)} – ${formatDate(end)}';
  }
  return '${start.day} – ${formatDate(end)}';
}

String greetingFor(DateTime now) {
  if (now.hour < 12) return 'Good morning';
  if (now.hour < 17) return 'Good afternoon';
  return 'Good evening';
}
