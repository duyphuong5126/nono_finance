import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

DateTime? getUpdatedTime(Map<String, dynamic> data) {
  final dateTimeFrags =
      data['updatedTime'].toString().split(' ').whereNot((e) => e.isEmpty);

  String dateString = '';
  String timeString = '';
  for (final frag in dateTimeFrags) {
    if (frag.contains(':')) {
      timeString = frag;
    } else if (frag.contains('/')) {
      dateString = frag;
    }
  }

  final datetimeFormat = DateFormat("hh:mm:ss dd/MM/yyyy");

  return dateString.isNotEmpty && timeString.isNotEmpty
      ? datetimeFormat.parse('$timeString $dateString')
      : null;
}
