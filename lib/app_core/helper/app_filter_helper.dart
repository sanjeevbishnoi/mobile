import 'package:tpos_mobile/app_core/template_models/app_filter_date_model.dart';

/// Lấy ngày lọc gợi ý mặc định
List<AppFilterDateModel> getFilterDateTemplates() {
  return List<AppFilterDateModel>()
    ..add(getTodayDateFilter())
    ..add(getYesterdayDateFilter())
    ..add(getDateFilterThisMonth())
    ..add(getDateFilterThisYear())
    ..add(getDateFilterLast7Day())
    ..add(getDateFilterLast30Day())
    ..add(getDateFilterLast90Day())
    ..add(getDateFilterCustom());
}

/// Lấy ngày lọc đơn gián (Hôm nay, hôm qua, tháng này, 7 ngày qua, 30 ngày qua)
List<AppFilterDateModel> getFilterDateTemplateSimple() {
  return List<AppFilterDateModel>()
    ..add(getTodayDateFilter())
    ..add(getYesterdayDateFilter())
    ..add(getDateFilterThisMonth())
    ..add(getDateFilterThisYear())
    ..add(getDateFilterLast7Day())
    ..add(getDateFilterLast30Day())
    ..add(getDateFilterLast90Day())
    ..add(getDateFilterCustom());
}

AppFilterDateModel getTodayDateFilter() {
  var now = DateTime.now();

  //Hôm nay
  var toDate = new AppFilterDateModel(
    name: "Hôm nay",
    fromDate: new DateTime(now.year, now.month, now.day, 0, 0, 0),
  );
  toDate.toDate = toDate.fromDate.add(Duration(days: 1)).add(
        (Duration(milliseconds: -1)),
      );

  return toDate;
}

AppFilterDateModel getYesterdayDateFilter() {
  var now = DateTime.now();
  return AppFilterDateModel()
    ..toDate =
        new DateTime(now.year, now.month, now.day - 1, 23, 59, 59, 999, 999)
    ..fromDate = new DateTime(now.year, now.month, now.day - 1, 0, 0, 0)
    ..name = "Hôm qua";
}

AppFilterDateModel getDateFilterThisWeek() {}

AppFilterDateModel getDateFilterThisMonth() {
  var now = DateTime.now();
  var thisMonth = AppFilterDateModel();
  thisMonth.fromDate = new DateTime(now.year, now.month, 1, 0, 0);
  thisMonth.toDate =
      new DateTime(now.year, now.month + 1, 1, 23, 59, 59, 999, 999)
          .add(Duration(days: -1));
  thisMonth.name = "Tháng này";
  return thisMonth;
}

/// Lấy khoảng thời gian năm này
/// Đầu năm-> Cuối năm
AppFilterDateModel getDateFilterThisYear() {
  var now = DateTime.now();
  var thisYearModel = AppFilterDateModel();

  thisYearModel.toDate = new DateTime(now.year, 12, 31, 23, 59, 59, 999, 999);

  thisYearModel.fromDate = new DateTime(now.year, 1, 1, 0, 0, 0);
  thisYearModel.name = "Năm nay";
  return thisYearModel;
}

AppFilterDateModel getDateFilterLast7Day() {
  var now = DateTime.now();
  var thisMonth = AppFilterDateModel();

  thisMonth.toDate =
      new DateTime(now.year, now.month, now.day, 23, 59, 59, 999, 999);
  var last7Date = now.add(Duration(days: -6));
  thisMonth.fromDate =
      new DateTime(last7Date.year, last7Date.month, last7Date.day, 0, 0, 0);
  thisMonth.name = "7 Ngày qua";
  return thisMonth;
}

AppFilterDateModel getDateFilterLast30Day() {
  var now = DateTime.now();
  var thisMonth = AppFilterDateModel();

  thisMonth.toDate =
      new DateTime(now.year, now.month, now.day, 23, 59, 59, 999, 999);
  var last7Date = now.add(Duration(days: -29));
  thisMonth.fromDate =
      new DateTime(last7Date.year, last7Date.month, last7Date.day, 0, 0, 0);
  thisMonth.name = "30 Ngày qua";
  return thisMonth;
}

AppFilterDateModel getDateFilterLast90Day() {
  var now = DateTime.now();
  var thisMonth = AppFilterDateModel();

  thisMonth.toDate =
      new DateTime(now.year, now.month, now.day, 23, 59, 59, 999, 999);
  var last7Date = now.add(Duration(days: -89));
  thisMonth.fromDate =
      new DateTime(last7Date.year, last7Date.month, last7Date.day, 0, 0, 0);
  thisMonth.name = "90 Ngày qua";
  return thisMonth;
}

AppFilterDateModel getDateFilterCustom() {
  var now = DateTime.now();
  var fromDate = new DateTime(now.year, now.month, now.day, 0, 0, 0);
  //Hôm nay
  return AppFilterDateModel(
      name: "Tùy chỉnh",
      fromDate: new DateTime(now.year, now.month, now.day, 0, 0, 0),
      toDate: fromDate.add(Duration(days: 1)).add(
            (Duration(milliseconds: -1)),
          ));
}
