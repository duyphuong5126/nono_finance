import 'package:intl/intl.dart';

String formatUpdatedTime(DateTime dateTime) {
  final formatter = DateFormat.Hms('en_US').add_yMd();
  return formatter.format(dateTime);
}
