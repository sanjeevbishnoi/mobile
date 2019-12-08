import 'package:intl/intl.dart';

const String TIME_TRACTIONAL_SECOND_PARTERN = "(?<=\\.)\\d+";
const String TIME_ZONE_PARTERN = "(?<=\\.)\\d+";

DateTime convertStringToDateTime(String input) {
  var date = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(input);
  String tractionalSecond =
      RegExp(TIME_TRACTIONAL_SECOND_PARTERN).stringMatch(input);

  //String timeZone = RegExp(TIME_ZONE_PARTERN).stringMatch(input);

  int milisecond = 0;
  int microSecond = 0;

  if (tractionalSecond != null) {
    if (tractionalSecond.length < 3) {
      milisecond = int.parse(tractionalSecond);
    } else {
      milisecond = int.parse(tractionalSecond.substring(0, 3));
    }

    if (tractionalSecond.length > 3) {
      microSecond = int.parse(tractionalSecond.substring(3));
    }
  }

  var result =
      date.add(Duration(milliseconds: milisecond, microseconds: microSecond));

  return result;
}

String _printDuration(Duration duration) {
  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));

  return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
}

convertDatetimeToString(DateTime input) {
  if (input==null) return null;
  String result = DateFormat("yyyy-MM-ddTHH:mm:ss.SSSSSSS").format(input);
  if (input.timeZoneOffset > new Duration()) {
    result = "$result+${_printDuration(input.timeZoneOffset)}";
  } else {
    result = "$result${_printDuration(input.timeZoneOffset)}";
  }

  return result;
}
