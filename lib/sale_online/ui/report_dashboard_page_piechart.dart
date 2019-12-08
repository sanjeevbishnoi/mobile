import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:random_color/random_color.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/fast_purchase_order/helper/data_helper.dart';
import 'package:tpos_mobile/fast_purchase_order/helper/widget_helper.dart';
import 'package:tpos_mobile/sale_online/viewmodels/report_dashboard_viewmodel.dart';

class PieChartPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  PieChartPage({@required this.scaffoldKey});
  @override
  _PieChartPageState createState() => _PieChartPageState();
}

class _PieChartPageState extends State<PieChartPage> {
  List<PieChartSectionData> pieChartRawSections;
  List<PieChartSectionData> showingSections;
  RandomColor _randomColor = RandomColor();
  StreamController<PieTouchResponse> pieTouchedResultStreamController;
  int touchedIndex;
  bool isLoading = true;
  int count;
  ReportDashboardViewModel _vm = locator<ReportDashboardViewModel>();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _showHeader(),
        _showDropDown(),
        _showPieChart(),
        Padding(
          padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
          child: Container(
            height: 1,
            width: double.infinity,
            color: Colors.grey.shade100,
          ),
        ),
        _showListProduct(),
      ],
    );
  }

  @override
  void dispose() {
    pieTouchedResultStreamController?.close();
    super.dispose();
  }

  Future loadData() async {
    isLoading = true;
    setState(() {});

    _vm.dataPieChart = new List<DataPieChart>();
    try {
      await _vm.getDataPieChart();
      setupChart(_vm.dataPieChart);
      isLoading = false;
      if (mounted) setState(() {});
    } catch (e) {
      print(e);
      isLoading = false;
      if (mounted) setState(() {});
      showCusSnackBar(
          currentState: widget.scaffoldKey.currentState,
          child: Text("${convertErrorToString(e)}"));
    }
  }

  void setupChart(List<DataPieChart> value) {
    var tong = 0;
    List<PieChartSectionData> items = [];
    List<DataPieChart> myListPieChart = [];
    for (DataPieChart data in value) {
      tong = tong + int.parse(data.quantity.toString().split(".")[0]);
      Color color =
          _randomColor.randomColor(colorBrightness: ColorBrightness.dark);
      data.colors = color;
      myListPieChart.add(data);
    }
    //Color(Random().nextInt(0xffffffff))
    for (var data in myListPieChart) {
      double value = (data.quantity / tong * 100).toDouble();

      items.add(
        PieChartSectionData(
          color: data.colors,
          value: value,
          title: "${value.toInt()}%",
          radius: 50,
          titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xffffffff),
          ),
        ),
      );
    }
    pieChartRawSections = items;

    showingSections = pieChartRawSections;

    pieTouchedResultStreamController = StreamController();
    pieTouchedResultStreamController.stream.distinct().listen((details) {
      if (details == null) {
        return;
      }

      touchedIndex = -1;
      if (details.sectionData != null) {
        touchedIndex = showingSections.indexOf(details.sectionData);
      }

      setState(() {
        if (details.touchInput is FlLongPressEnd) {
          touchedIndex = -1;
          showingSections = List.of(pieChartRawSections);
        } else {
          showingSections = List.of(pieChartRawSections);

          if (touchedIndex != -1) {
            final TextStyle style = showingSections[touchedIndex].titleStyle;
            showingSections[touchedIndex] =
                showingSections[touchedIndex].copyWith(
              titleStyle: style.copyWith(
                fontSize: 24,
              ),
              radius: 60,
            );
          }
        }
      });
    });
  }

  Widget _showDropDown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        DropdownButton(
          iconEnabledColor: Colors.lightBlue,
          underline: DropdownButtonHideUnderline(
            child: Text(
              _vm.currentPieChartOption != null
                  ? "".padLeft(_vm.currentPieChartOption.text.length + 1, "_")
                  : "",
              style: TextStyle(color: Colors.lightBlue),
            ),
          ),
          value: _vm.currentPieChartOption,
          onChanged: (value) {
            setState(() {
              _vm.currentPieChartOption = value;
            });
            _vm.setCurrentPieChartOption(value);
            loadData();
          },
          items: _vm.chartPieFilter
              .map(
                (f) => DropdownMenuItem(
                  value: f,
                  child: Text(
                    "${f.text.toUpperCase()[0]}${f.text.substring(1).toLowerCase()}",
                    style: TextStyle(
                        color: f == _vm.currentPieChartOption
                            ? Colors.lightBlue
                            : Colors.black),
                  ),
                ),
              )
              .toList(),
        ),
        DropdownButton(
          iconEnabledColor: Colors.lightBlue,
          underline: DropdownButtonHideUnderline(
            child: Text(
              _vm.currentDataPieChartOrderOption != null
                  ? "".padLeft(
                      _vm.currentDataPieChartOrderOption.text.length + 1, "_")
                  : "",
              style: TextStyle(color: Colors.lightBlue),
            ),
          ),
          value: _vm.currentDataPieChartOrderOption,
          onChanged: (value) {
            setState(() {
              _vm.currentDataPieChartOrderOption = value;
            });
            _vm.setCurrentDataPieChartOrderOption(value);
            loadData();
          },
          items: _vm.chartPieOrderFilter
              .map(
                (f) => DropdownMenuItem(
                  value: f,
                  child: Text(
                    "${f.text.toUpperCase()[0]}${f.text.substring(1).toLowerCase()}",
                    style: TextStyle(
                        color: f == _vm.currentDataPieChartOrderOption
                            ? Colors.lightBlue
                            : Colors.black),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _showPieChart() {
    return ScopedModel<ReportDashboardViewModel>(
      model: _vm,
      child: ScopedModelDescendant<ReportDashboardViewModel>(
        builder: (context, child, model) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: pieTouchedResultStreamController == null
                ? SizedBox()
                : AspectRatio(
                    aspectRatio: 1.5,
                    child: isLoading
                        ? loadingScreen()
                        : model.dataPieChart.isEmpty
                            ? Container(
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(
                                        FontAwesomeIcons.boxOpen,
                                        color: Colors.grey,
                                        size: 30,
                                      ),
                                      Text(
                                        "Không có dữ liệu \n"
                                        "${_vm.currentPieChartOption.text.toLowerCase()} "
                                        "${_vm.currentDataPieChartOrderOption.text.toLowerCase()} !",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : FlChart(
                                chart: PieChart(
                                  PieChartData(
                                    pieTouchData: PieTouchData(
                                        touchResponseStreamSink:
                                            pieTouchedResultStreamController
                                                .sink),
                                    borderData: FlBorderData(
                                      show: false,
                                    ),
                                    sectionsSpace: 0,
                                    centerSpaceRadius: 40,
                                    sections: showingSections,
                                  ),
                                ),
                              ),
                  ),
          );
        },
      ),
    );
  }

  Widget _showListProduct() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _vm.dataPieChart
          .map(
            (item) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Indicator(
                color: item.colors,
                textColor: _vm.dataPieChart.indexOf(item) == 0
                    ? Colors.lightBlue
                    : Colors.black,
                fontWeight: _vm.dataPieChart.indexOf(item) == 0
                    ? FontWeight.bold
                    : FontWeight.w300,
                text:
                    "#${_vm.dataPieChart.indexOf(item) + 1} ${item.nameProduct}",
                isSquare: true,
                value: money(item.quantity * 1.0),
              ),
            ),
          )
          .toList(),
    );
  }

  _showHeader() {
    return Column(
      children: <Widget>[
        Container(
          //color: Colors.grey.shade200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                  child: Text(
                    "Top 10 sản phẩm bán chạy ${_vm.currentPieChartOption.text.toLowerCase()}",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;
  final String value;
  final FontWeight fontWeight;

  const Indicator(
      {Key key,
      this.color,
      this.text,
      this.isSquare,
      this.size = 16,
      this.textColor = const Color(0xffffffff),
      this.value,
      this.fontWeight = FontWeight.w300})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        SizedBox(
          width: 4,
        ),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                      fontSize: 16, fontWeight: fontWeight, color: textColor),
                ),
              ),
              Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: fontWeight,
                    color: textColor.withOpacity(0.5)),
              )
            ],
          ),
        )
      ],
    );
  }
}
