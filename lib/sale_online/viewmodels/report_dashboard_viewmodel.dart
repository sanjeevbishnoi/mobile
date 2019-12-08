import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:tpos_mobile/fast_purchase_order/helper/data_helper.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/src/tpos_apis/models/DashboardReport.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';
import 'dart:async';

import '../../app_service_locator.dart';

class ReportDashboardViewModel extends ViewModel {
  ITposApiService _tposApi;
  Logger _log = new Logger("ReportDashboardViewModel");

  List<DataLineChart> dataLines = new List<DataLineChart>();
  List<DataPieChart> dataPieChart = new List<DataPieChart>();

  ReportDashboardViewModel({ITposApiService tposApi}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
    onStateAdd(false);

    _selectedOverviewOption = _overviewFilter.first;
    currentPieChartOption = chartPieFilter[2];
    currentDataPieChartOrderOption = chartPieOrderFilter[2];
  }
  DashboardReport report;
  bool _isInit = false;

  List<DashboardReportDataOverviewOption> _overviewFilter = [
    DashboardReportDataOverviewOption(value: "T", text: "HÔM NAY"),
    DashboardReportDataOverviewOption(value: "Yesterday", text: "HÔM QUA"),
    DashboardReportDataOverviewOption(value: "M", text: "THÁNG NÀY"),
    DashboardReportDataOverviewOption(value: "Y", text: "NĂM NÀY"),
  ];
  List<DataLineOption> chartLineFilter = [
    DataLineOption(value: "WNWP", text: "TUẦN NÀY"),
    DataLineOption(value: "MNMP", text: "THÁNG NÀY"),
    DataLineOption(value: "YQNYQP", text: "QUÝ CỦA NĂM NÀY"),
    DataLineOption(value: "YNYP", text: "NĂM NÀY"),
    //DataDataLineOption(value: "O", text: "KHÁC"),
  ];
  DataLineOption currentChartLine =
      new DataLineOption(value: "WNWP", text: "TUẦN NÀY");
  void setCurrentChartLine(DataLineOption option) {
    currentChartLine = option;
  }

  List<DataColumnOption> chartColumnFilter = [
    DataColumnOption(value: "W", text: "TUẦN NÀY"),
    DataColumnOption(value: "CM", text: "THÁNG NÀY"),
    DataColumnOption(value: "PM", text: "THÁNG TRƯỚC"),
  ];
  DataColumnOption currentChartColumn =
      DataColumnOption(value: "W", text: "TUẦN NÀY");
  void setCurrentChartColumn(DataColumnOption option) {
    currentChartColumn = option;
    notifyListeners();
  }

  ///PIE CHART
  List<DataPieChartOption> chartPieFilter = [
    DataPieChartOption(value: "W", text: "TUẦN NÀY"),
    DataPieChartOption(value: "CM", text: "THÁNG NÀY"),
    DataPieChartOption(value: "PM", text: "THÁNG TRƯỚC"),
  ];
  DataPieChartOption currentPieChartOption;
  void setCurrentPieChartOption(DataPieChartOption option) {
    currentPieChartOption = option;
  }

  List<DataPieChartOrderOption> chartPieOrderFilter = [
    DataPieChartOrderOption(value: 1, text: "THEO DOANH SỐ"),
    DataPieChartOrderOption(value: 2, text: "THEO DOANH THU"),
    DataPieChartOrderOption(value: 3, text: "THEO SỐ LƯỢNG"),
  ];
  DataPieChartOrderOption currentDataPieChartOrderOption;
  void setCurrentDataPieChartOrderOption(DataPieChartOrderOption option) {
    currentDataPieChartOrderOption = option;
  }

  DashboardReportDataOverviewOption _selectedOverviewOption;
  List<DashboardReportDataOverviewOption> get overviewFilter => _overviewFilter;
  DashboardReportDataOverviewOption get selectedOverviewOption =>
      _selectedOverviewOption;
  set selectedOverviewOption(DashboardReportDataOverviewOption value) {
    _selectedOverviewOption = value;
    notifyListeners();
  }

  Future<void> initCommand() async {
    if (_isInit) return;
    try {
      await _getDashboardReport();
      notifyListeners();
      _isInit = true;
    } catch (e, s) {
      _log.severe("", e, s);
    }
  }

  Future<void> refreshReportCommand() async {
    try {
      _getDashboardReport();
      notifyListeners();
    } catch (e, s) {
      _log.severe("", e, s);
    }
  }

  Future<void> reloadOverviewCommand() async {
    onStateAdd(true);
    try {
      var overview = await _tposApi.getDashboardReportOverview(
          overViewValue: _selectedOverviewOption?.value,
          overViewText: _selectedOverviewOption?.text);

      if (overview != null) {
        this.report.overview = overview;
      }
      notifyListeners();
    } catch (e, s) {
      _log.severe("", e, s);
    }
    onStateAdd(false);
  }

  Future<void> _getDashboardReport() async {
    report = await _tposApi.getDashboardReport(
        overViewText: _selectedOverviewOption?.text,
        overViewValue: _selectedOverviewOption?.value);
  }

  Future getDataLinesChart() async {
    dataLines = new List<DataLineChart>();
    try {
      dataLines = await _tposApi.getDashBoardChart(
        chartType: "GetDataLine",
        lineChartText: currentChartLine.text,
        lineChartValue: currentChartLine.value,
      );
    } catch (e) {
      onDialogMessageAdd(OldDialogMessage.flashMessage(
        convertErrorToString(e),
      ));
    }
    notifyListeners();
  }

  List<DataColumnChart> dataColumns = new List<DataColumnChart>();

  Future getDataColumnChart() async {
    dataColumns = await _tposApi.getDashBoardChart(
      chartType: "GetSales",
      columnCharText: currentChartColumn.text,
      columnChartValue: currentChartColumn.value,
    );
    notifyListeners();
  }

  Future getDataPieChart() async {
    dataPieChart = new List<DataPieChart>();
    notifyListeners();
    try {
      var values = await _tposApi.getDashBoardChart(
        chartType: "GetSales2",
        barChartValue: currentPieChartOption.value,
        barChartText: currentPieChartOption.text,
        barChartOrderValue: currentDataPieChartOrderOption.value,
        barChartOrderText: currentDataPieChartOrderOption.text,
      );
      dataPieChart = [...values];
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}

///LINE CHART
class DataLineChart {
  String name;
  double current;
  double last;
  DataLineChart({this.name, this.current, this.last});
  DataLineChart.fromJson(List<dynamic> json) {
    name = json[0];
    current = double.parse(json[1].toString().replaceAll(",", "."));
    last = double.parse(json[2].toString().replaceAll(",", "."));
  }
}

class DataLineOption {
  String text;
  String value;
  DataLineOption({this.text, this.value});
}

///COLUMN CHART
class DataColumnChart {
  String name;
  List<double> listValue = new List<double>();
  List<String> listCompanyName = new List<String>();

  DataColumnChart({this.name, this.listValue, this.listCompanyName});

  DataColumnChart.fromJson(List<dynamic> json, List<dynamic> listCompanyName) {
    this.name = json[0];
    json.length;
    for (int i = 0; i <= listCompanyName.length - 1; i++) {
      this.listCompanyName.add(listCompanyName[i]["CompanyName"].toString());
    }
    for (int i = 1; i <= json.length - 1; i++) {
      this.listValue.add(double.parse(json[i].toString().replaceAll(",", ".")));
    }
  }
}

class DataColumnOption {
  String text;
  String value;
  DataColumnOption({this.text, this.value});
}

///PIE CHART
class DataPieChart {
  String nameProduct;
  dynamic quantity;
  dynamic type;
  Color colors;

  DataPieChart({this.nameProduct, this.quantity, this.type, this.colors});

  factory DataPieChart.fromJson(Map<String, dynamic> json) => new DataPieChart(
        nameProduct: json["NameProduct"],
        quantity: json["Quantity"],
        type: json["Type"],
      );

  Map<String, dynamic> toJson() => {
        "NameProduct": nameProduct,
        "Quantity": quantity,
        "Type": type,
      };
}

class DataPieChartOption {
  String value;
  String text;
  DataPieChartOption({
    this.value,
    this.text,
  });
}

class DataPieChartOrderOption {
  int value;
  String text;

  DataPieChartOrderOption({this.value, this.text});
}
