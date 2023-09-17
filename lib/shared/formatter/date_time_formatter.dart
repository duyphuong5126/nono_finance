import 'package:intl/intl.dart';

String formatUpdatedTime(DateTime dateTime) {
  final formatter = DateFormat('hh:mm:ss - dd/MM/yyyy');
  return formatter.format(dateTime);
}
