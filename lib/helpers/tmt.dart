import 'dart:io';

const String TIME_TRACTIONAL_SECOND_PARTERN = "(?<=\\.)\\d+";
const String TIME_ZONE_PARTERN = "(?<=\\.)\\d+";

class Tmt {
  static String locate = "vi_VN";

  ///Convert String number to double type with locate input. Defaut is en_US locate
  ///Null[null] and empty [""] will convert to 0
  static double convertToDouble(String value, String locate) {
    String temp = value;
    if (value == null) return 0;
    if (value == null || value == "") temp = "0";
    switch (locate) {
      case "vi_VN":
        temp = temp.replaceAll(".", "").replaceAll(",", ".");
        break;
      case "en_US":
        temp = temp.replaceAll(",", "");
        break;
      default:
        temp = temp;
        break;
    }

    return double.parse(temp);
  }

  static String getErrorString(Object exception) {
    if (exception is SocketException) {
      return "Không có kết nối mạng hoặc máy chủ không khả dụng";
    } else {
      return exception.toString();
    }
  }
}
