class CompanyCurrentInfo {
  String currentCompany;
  DateTime dateExpired;
  int expiredIn;
  List<OtherCompanyInfo> companies;

  String get expiredInDay {
    int expiredInSecond = expiredIn ?? 0;
    var dur = Duration(seconds: expiredInSecond);

    int day = dur.inDays;
    int hour = (dur - Duration(days: day)).inHours;
    int minute = (dur - Duration(days: day, hours: hour)).inMinutes;

    String dayString = "$day ngày";
    String hourString = "$hour giờ";
    String minuteString = "$minute phút";

    return "${day != 0 ? dayString : ""} ${hour != 0 ? hourString : ""} $minuteString";
  }

  String get expiredInShort {
    int expiredInSecond = expiredIn ?? 0;
    if (expiredInSecond < 3600) {
      var minute = expiredInSecond ~/ 60;
      return "$minute phút";
    } else if (expiredInSecond < 86400) {
      var hour = expiredInSecond ~/ 3600;
      return "$hour giờ";
    } else if (expiredInSecond < 2592000) {
      var day = expiredInSecond ~/ 86400;
      return "$day ngày";
    } else if (expiredInSecond < 31536000) {
      var month = expiredInSecond ~/ 2592000;
      return "$month tháng";
    } else {
      var year = expiredInSecond ~/ 31536000;
      return "$year năm";
    }
  }

  CompanyCurrentInfo(
      {this.currentCompany, this.dateExpired, this.expiredIn, this.companies});

  CompanyCurrentInfo.fromJson(Map<String, dynamic> json) {
    currentCompany = json["CurrentCompany"];
    expiredIn = json["ExpiredIn"];
    if (json["Companies"] != null) {
      companies = (json["Companies"] as List)
          .map((f) => OtherCompanyInfo.fromJson(f))
          .toList();
    }
  }
}

class OtherCompanyInfo {
  String value;
  String text;
  OtherCompanyInfo({this.value, this.text});

  OtherCompanyInfo.fromJson(Map<String, dynamic> json) {
    value = json["Value"];
    text = json["Text"];
  }
}
