import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/helpers/app_helper.dart';
import 'package:tpos_mobile/app_core/helper/string_helper.dart';
import 'package:tpos_mobile/src/tpos_apis/models/report_order.dart';
import 'package:tpos_mobile/src/tpos_apis/models/company_of_user.dart';
import 'package:tpos_mobile/src/tpos_apis/models/date_filter_template.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner.dart';
import 'package:tpos_mobile/src/tpos_apis/models/user_report_staff.dart';
import 'package:tpos_mobile/sale_online/ui/partner_search_page.dart';
import 'package:tpos_mobile/sale_online/ui/report_sale_order_info_page.dart';
import 'package:tpos_mobile/app_core/ui_base/ui_vm_base.dart';
import 'package:tpos_mobile/sale_online/viewmodels/report_sale_order_viewmodel.dart';

class ReportSaleOrderPage extends StatefulWidget {
  @override
  _ReportSaleOrderPageState createState() => _ReportSaleOrderPageState();
}

class _ReportSaleOrderPageState extends State<ReportSaleOrderPage> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _scrollControllerGeneral = new ScrollController();
  ScrollController _scrollControllerDetail = new ScrollController();
  ReportSaleOrderViewModel viewModel = new ReportSaleOrderViewModel();

  bool isTablet = false;
  double deviceWidth;
  double columnWidth;

  TextStyle defaultTextStyle = new TextStyle(
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    deviceWidth = MediaQuery.of(context).size.width;
    print(deviceWidth);
    columnWidth = (deviceWidth - 40) / 10;
    if (deviceWidth > 700)
      isTablet = true;
    else
      isTablet = false;
    return ScopedModel<ReportSaleOrderViewModel>(
      model: viewModel,
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        key: _scaffoldKey,
        appBar: new AppBar(
          title: Text("Thống kê hóa đơn"),
          actions: <Widget>[
            Text(""),
          ],
        ),
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: <Widget>[
              new Container(
                color: Colors.white,
                constraints: BoxConstraints(maxHeight: 40.0),
                child: new TabBar(
                  indicatorColor: Colors.green,
                  labelColor: Colors.green,
                  tabs: [
                    new Tab(
                      text: "Tổng quan",
                    ),
                    new Tab(
                      text: "Chi tiết",
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(children: <Widget>[
                  _buildGeneral(),
                  _buildDetail(),
                ]),
              ),
            ],
          ),
        ),
        endDrawer: _showDrawerRight(context),
      ),
    );
  }

  Widget _buildGeneral() {
    return UIViewModelBase(
      viewModel: viewModel,
      child: RefreshIndicator(
          child: ScopedModelDescendant<ReportSaleOrderViewModel>(
        builder: (context, child, model) {
          return Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                padding: EdgeInsets.only(left: 8, right: 8),
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    gradient: LinearGradient(colors: [
                      Color(0xff07B1FF),
                      Color(0xff07EDE3),
                    ])),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
//                            child: Icon(
//                              Icons.sort_by_alpha,
//                              color: Colors.white,
//                            ),
                          ),
                          DropdownButtonHideUnderline(
                            child: new DropdownButton<DateFilterTemplate>(
                              style: TextStyle(color: Colors.black),
                              hint: Text("Chọn thời gian"),
                              value: viewModel.selectedFilterByDate,
                              onChanged: (value) {
                                viewModel.selectFilterByDateCommand(value);
                                viewModel.filter();
                              },
                              items: viewModel.filterByDates
                                  ?.map(
                                    (f) => DropdownMenuItem<DateFilterTemplate>(
                                      child: Text(
                                        "${f.name}",
                                      ),
                                      value: f,
                                    ),
                                  )
                                  ?.toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: new GestureDetector(
                        onTap: () {
                          _scaffoldKey.currentState.openEndDrawer();
                        },
                        child: Badge(
                          badgeColor: Colors.redAccent,
                          badgeContent: Text(
                            "${viewModel.filterCount}",
                            style: TextStyle(color: Colors.white),
                          ),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "Lọc",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              Icon(
                                Icons.filter_list,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment(0.85, 0.85),
                  children: <Widget>[
                    Scrollbar(
                      child: CustomScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        controller: _scrollControllerGeneral,
                        slivers: <Widget>[
                          SliverList(
                              delegate: SliverChildListDelegate([
                            !isTablet
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: 5.0,
                                                right: 5.0,
                                                bottom: 5.0,
                                                left: 10.0),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                gradient:
                                                    LinearGradient(colors: [
                                                  Color(0xffFF9190),
                                                  Color(0xffFEBE7E),
                                                ])),
                                            width: (deviceWidth - 25) / 2,
                                            height: 90,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      stops: [0.1, 1],
                                                      colors: [
                                                        Color(0xffFF9190),
                                                        Color(0xffFEBE7E),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.monetization_on,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Số lượng HĐ',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                    '${viewModel.sumReportSaleGeneral?.totalOrder ?? 0}',
                                                    style: defaultTextStyle
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                gradient:
                                                    LinearGradient(colors: [
                                                  Color(0xff07B1FF),
                                                  Color(0xff07EDE3),
                                                ])),
                                            width: (deviceWidth - 25) / 2,
                                            height: 90,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      stops: [0.1, 1],
                                                      colors: [
                                                        Color(0xff07B1FF),
                                                        Color(0xff07EDE3),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.monetization_on,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Bán hàng',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                    '${vietnameseCurrencyFormat(viewModel.sumReportSaleGeneral?.totalSale) ?? 0}',
                                                    style: defaultTextStyle
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(left: 10.0),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                gradient:
                                                    LinearGradient(colors: [
                                                  Color(0xff00DA90),
                                                  Color(0xff52FDAE),
                                                ])),
                                            width: (deviceWidth - 25) / 2,
                                            height: 90,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      stops: [0.1, 1],
                                                      colors: [
                                                        Color(0xff00DA90),
                                                        Color(0xff52FDAE),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.monetization_on,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Khuyến mãi + chiết khấu',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                    '${vietnameseCurrencyFormat(viewModel.amountGeneralCKKM) ?? 0}',
                                                    style: defaultTextStyle
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 5.0),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                gradient:
                                                    LinearGradient(colors: [
                                                  Color(0xffA47CFF),
                                                  Color(0xffFD7BF5),
                                                ])),
                                            width: (deviceWidth - 25) / 2,
                                            height: 90,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      stops: [0.1, 1],
                                                      colors: [
                                                        Color(0xffA47CFF),
                                                        Color(0xffFD7BF5),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.monetization_on,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Tổng tiền',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.right,
                                                ),
                                                Text(
                                                    '${vietnameseCurrencyFormat(viewModel.sumReportSaleGeneral?.totalAmount) ?? 0}',
                                                    style: defaultTextStyle
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: 5.0,
                                                right: 5.0,
                                                bottom: 5.0,
                                                left: 10.0),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                gradient:
                                                    LinearGradient(colors: [
                                                  Color(0xffFF9190),
                                                  Color(0xffFEBE7E),
                                                ])),
                                            width: (deviceWidth - 35) / 4,
                                            height: 90,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      stops: [0.1, 1],
                                                      colors: [
                                                        Color(0xffFF9190),
                                                        Color(0xffFEBE7E),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.monetization_on,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Số lượng hóa đơn',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                    '${viewModel.sumReportSaleGeneral?.totalOrder ?? 0}',
                                                    style: defaultTextStyle
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                gradient:
                                                    LinearGradient(colors: [
                                                  Color(0xff07B1FF),
                                                  Color(0xff07EDE3),
                                                ])),
                                            width: (deviceWidth - 35) / 4,
                                            height: 90,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      stops: [0.1, 1],
                                                      colors: [
                                                        Color(0xff07B1FF),
                                                        Color(0xff07EDE3),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.monetization_on,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Bán hàng',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                    '${vietnameseCurrencyFormat(viewModel.sumReportSaleGeneral?.totalSale) ?? 0}',
                                                    style: defaultTextStyle
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 5.0),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                gradient:
                                                    LinearGradient(colors: [
                                                  Color(0xff00DA90),
                                                  Color(0xff52FDAE),
                                                ])),
                                            width: (deviceWidth - 35) / 4,
                                            height: 90,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      stops: [0.1, 1],
                                                      colors: [
                                                        Color(0xff00DA90),
                                                        Color(0xff52FDAE),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.monetization_on,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Khuyến mãi + chiết khấu',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                    '${vietnameseCurrencyFormat(viewModel.amountGeneralCKKM) ?? 0}',
                                                    style: defaultTextStyle
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: 5.0, right: 10),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                gradient:
                                                    LinearGradient(colors: [
                                                  Color(0xffA47CFF),
                                                  Color(0xffFD7BF5),
                                                ])),
                                            width: (deviceWidth - 35) / 4,
                                            height: 90,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      stops: [0.1, 1],
                                                      colors: [
                                                        Color(0xffA47CFF),
                                                        Color(0xffFD7BF5),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.monetization_on,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Tổng tiền',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.right,
                                                ),
                                                Text(
                                                    '${vietnameseCurrencyFormat(viewModel.sumReportSaleGeneral?.totalAmount) ?? 0}',
                                                    style: defaultTextStyle
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                          ])),
                          isTablet
                              ? SliverList(
                                  delegate: SliverChildListDelegate([
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        horizontalMargin: 20,
                                        sortColumnIndex:
                                            viewModel.sortColumnIndex,
                                        sortAscending: viewModel.sortAscending,
                                        columns: <DataColumn>[
                                          DataColumn(
                                            label: Container(
                                              width: 50,
                                              child: const Text('Ngày'),
                                            ),
                                            onSort: (int columnIndex,
                                                    bool ascending) =>
                                                viewModel.sortGeneral<DateTime>(
                                              (ReportSaleOrderGeneralInfo d) =>
                                                  d.date,
                                              ascending,
                                              columnIndex,
                                            ),
                                          ),
                                          DataColumn(
                                            label: Container(
                                                width: 50,
                                                child: const Text(
                                                    'Số lượng hóa đơn')),
                                          ),
                                          DataColumn(
                                            numeric: true,
                                            label: Container(
                                                width: columnWidth,
                                                child: const Text('Bán hàng')),
                                            onSort: (int columnIndex,
                                                    bool ascending) =>
                                                viewModel.sortGeneral<num>(
                                              (ReportSaleOrderGeneralInfo d) =>
                                                  d.totalAmountBeforeCK,
                                              ascending,
                                              columnIndex,
                                            ),
                                          ),
                                          DataColumn(
                                              label: Container(
                                                width: columnWidth,
                                                child: const Text(
                                                  'Tiền CK',
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                              onSort: (int columnIndex,
                                                      bool ascending) =>
                                                  viewModel.sortGeneral<num>(
                                                    (ReportSaleOrderGeneralInfo
                                                            d) =>
                                                        d.totalCK,
                                                    ascending,
                                                    columnIndex,
                                                  ),
                                              numeric: true),
                                          DataColumn(
                                            label: Container(
                                              width: columnWidth,
                                              child: const Text(
                                                'Khuyến mãi',
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                            numeric: true,
                                            onSort: (int columnIndex,
                                                    bool ascending) =>
                                                viewModel.sortGeneral<num>(
                                              (ReportSaleOrderGeneralInfo d) =>
                                                  d.totalKM,
                                              ascending,
                                              columnIndex,
                                            ),
                                          ),
                                          DataColumn(
                                              label: Container(
                                                width: columnWidth,
                                                child: const Text('Tổng tiền'),
                                              ),
                                              onSort: (int columnIndex,
                                                      bool ascending) =>
                                                  viewModel.sortGeneral<num>(
                                                    (ReportSaleOrderGeneralInfo
                                                            d) =>
                                                        d.totalAmount,
                                                    ascending,
                                                    columnIndex,
                                                  ),
                                              numeric: true),
                                        ],
                                        rows: viewModel
                                                .reportSaleOrderGeneral?.value
                                                ?.map(
                                                  (itemRow) => DataRow(
                                                    cells: [
                                                      DataCell(
                                                        Text(
                                                            '${DateFormat("dd/MM/yyyy").format(itemRow.date) ?? ''}'),
                                                      ),
                                                      DataCell(
                                                        Text(
                                                          '${itemRow.countOrder ?? ''}',
                                                          textAlign:
                                                              TextAlign.right,
                                                        ),
                                                      ),
                                                      DataCell(
                                                          Text(
                                                              '${vietnameseCurrencyFormat(
                                                                    itemRow
                                                                        .totalAmountBeforeCK,
                                                                  ) ?? ''}'),
                                                          onTap: () {}),
                                                      DataCell(
                                                          Text(
                                                            '${vietnameseCurrencyFormat(
                                                                  itemRow
                                                                      .totalCK,
                                                                ) ?? ''}',
                                                            textAlign:
                                                                TextAlign.right,
                                                          ),
                                                          onTap: () {}),
                                                      DataCell(
                                                        Text(
                                                          '${vietnameseCurrencyFormat(
                                                            itemRow.totalKM,
                                                          )}',
                                                          textAlign:
                                                              TextAlign.right,
                                                        ),
                                                        onTap: () {},
                                                      ),
                                                      DataCell(
                                                        Text(
                                                          '${vietnameseCurrencyFormat(
                                                            itemRow.totalAmount,
                                                          )}',
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: defaultTextStyle
                                                              .copyWith(
                                                                  color: Colors
                                                                      .red),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                                ?.toList() ??
                                            [],
                                      ),
                                    ),
                                  ]),
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      return Container(
                                        margin: EdgeInsets.only(
                                            left: 10, right: 10, top: 8.0),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: Colors.white70,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            ListTile(
                                              onTap: () async {},
                                              contentPadding: EdgeInsets.only(
                                                  left: 10.0, right: 10.0),
                                              subtitle: Column(
                                                children: <Widget>[
                                                  // title
                                                  Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Text(
                                                            "${DateFormat("dd/MM/yyyy").format(viewModel.reportSaleOrderGeneral.value[index].date)}",
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16)),
                                                      ),
                                                      Text(
                                                        "${vietnameseCurrencyFormat(
                                                          viewModel
                                                              .reportSaleOrderGeneral
                                                              .value[index]
                                                              .totalAmount,
                                                        )}",
                                                        style: TextStyle(
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16),
                                                        textAlign:
                                                            TextAlign.right,
                                                      ),
                                                    ],
                                                  ),
                                                  Wrap(
                                                    children: <Widget>[
                                                      Text(
                                                        "Số lượng hóa đơn: ",
                                                      ),
                                                      Text(
                                                        "${vietnameseCurrencyFormat(
                                                          viewModel
                                                              .reportSaleOrderGeneral
                                                              .value[index]
                                                              .countOrder
                                                              .toDouble(),
                                                        )}",
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Text(
                                                        "Bán hàng: ",
                                                      ),
                                                      Text(
                                                        "${vietnameseCurrencyFormat(
                                                          viewModel
                                                              .reportSaleOrderGeneral
                                                              .value[index]
                                                              .totalAmountBeforeCK,
                                                        )}",
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Text(
                                                        "Tiền CK: ",
                                                      ),
                                                      Text(
                                                        "${vietnameseCurrencyFormat(viewModel.reportSaleOrderGeneral.value[index].totalCK)}",
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Text(
                                                        "Khuyến mãi: ",
                                                      ),
                                                      Text(
                                                        "${vietnameseCurrencyFormat(viewModel.reportSaleOrderGeneral.value[index].totalKM)}",
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    childCount: viewModel.reportSaleOrderGeneral
                                            ?.value?.length ??
                                        0,
                                  ),
                                ),
                        ],
                      ),
                    ),
//                    IconButton(
//                      icon: Icon(
//                        FontAwesomeIcons.solidArrowAltCircleUp,
//                        size: 50,
//                      ),
//                      color: Colors.green,
//                      onPressed: () {
//                        scrollToTop(controller: _scrollControllerGeneral);
//                      },
//                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ), onRefresh: () async {
        await viewModel.filter();
        return true;
      }),
    );
  }

  Widget _buildDetail() {
    return UIViewModelBase(
      viewModel: viewModel,
      child: RefreshIndicator(
          child: ScopedModelDescendant<ReportSaleOrderViewModel>(
        builder: (context, child, model) {
          return Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                padding: EdgeInsets.only(left: 8, right: 8),
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    gradient: LinearGradient(colors: [
                      Color(0xff07B1FF),
                      Color(0xff07EDE3),
                    ])),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.sort_by_alpha,
                              color: Colors.white,
                            ),
                          ),
                          DropdownButtonHideUnderline(
                            child: new DropdownButton<DateFilterTemplate>(
                              style: TextStyle(color: Colors.black),
                              hint: Text("Chọn thời gian"),
                              value: viewModel.selectedFilterByDate,
                              onChanged: (value) {
                                viewModel.selectFilterByDateCommand(value);
                                viewModel.filter();
                              },
                              items: viewModel.filterByDates
                                  ?.map(
                                    (f) => DropdownMenuItem<DateFilterTemplate>(
                                      child: Text(
                                        "${f.name}",
                                      ),
                                      value: f,
                                    ),
                                  )
                                  ?.toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: new GestureDetector(
                        onTap: () {
                          _scaffoldKey.currentState.openEndDrawer();
                        },
                        child: Badge(
                          badgeColor: Colors.redAccent,
                          badgeContent: Text(
                            "${viewModel.filterCount}",
                            style: TextStyle(color: Colors.white),
                          ),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "Lọc",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              Icon(
                                Icons.filter_list,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment(0.85, 0.9),
                  children: <Widget>[
                    Scrollbar(
                      child: CustomScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        controller: _scrollControllerDetail,
                        slivers: <Widget>[
                          SliverList(
                              delegate: SliverChildListDelegate([
                            !isTablet
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: 10.0,
                                                right: 5.0,
                                                bottom: 5.0,
                                                top: 5.0),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                gradient:
                                                    LinearGradient(colors: [
                                                  Color(0xffFF9190),
                                                  Color(0xffFEBE7E),
                                                ])),
                                            width: (deviceWidth - 25) / 2,
                                            height: 170,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      stops: [0.1, 1],
                                                      colors: [
                                                        Color(0xffFF9190),
                                                        Color(0xffFEBE7E),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.monetization_on,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Bán hàng',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                    '${vietnameseCurrencyFormat(viewModel.sumAmountReportSale.sumAmountBeforeDiscountFastOrder + viewModel.sumAmountReportSale.sumAmountBeforeDiscountPostOrder)}',
                                                    style: defaultTextStyle
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20)),
                                                SizedBox(
                                                  width: deviceWidth / 3,
                                                  height: 5,
                                                  child: Divider(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Điểm bán hàng:\n ${vietnameseCurrencyFormat(viewModel.sumAmountReportSale.sumAmountBeforeDiscountPostOrder)}',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  'Bán hàng nhanh:\n ${vietnameseCurrencyFormat(viewModel.sumAmountReportSale.sumAmountBeforeDiscountFastOrder)}',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                gradient:
                                                    LinearGradient(colors: [
                                                  Color(0xff07B1FF),
                                                  Color(0xff07EDE3),
                                                ])),
                                            width: (deviceWidth - 25) / 2,
                                            height: 170,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      stops: [0.1, 1],
                                                      colors: [
                                                        Color(0xff07B1FF),
                                                        Color(0xff07EDE3),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.monetization_on,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Khuyến mãi + chiết khấu',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                    '${vietnameseCurrencyFormat(viewModel.sumAmountReportSale.sumDecreateAmountFastOrder + viewModel.sumAmountReportSale.sumDiscountAmountFastOrder + viewModel.sumAmountReportSale.sumDecreateAmountPostOrder + viewModel.sumAmountReportSale.sumDiscountAmountPostOrder)}',
                                                    style: defaultTextStyle
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20)),
                                                SizedBox(
                                                  width: deviceWidth / 3,
                                                  height: 5,
                                                  child: Divider(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Điểm bán hàng:\n ${vietnameseCurrencyFormat(viewModel.sumAmountReportSale.sumPaidtSaleOrder)}',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  'Bán hàng nhanh:\n ${vietnameseCurrencyFormat(viewModel.sumReportSaleGeneral.totalKM + viewModel.sumReportSaleGeneral.totalCk)}',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(left: 10.0),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                gradient:
                                                    LinearGradient(colors: [
                                                  Color(0xff00DA90),
                                                  Color(0xff52FDAE),
                                                ])),
                                            width: (deviceWidth - 25) / 2,
                                            height: 170,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      stops: [0.1, 1],
                                                      colors: [
                                                        Color(0xff00DA90),
                                                        Color(0xff52FDAE),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.monetization_on,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Tổng tiền',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.right,
                                                ),
                                                Text(
                                                  '${vietnameseCurrencyFormat(
                                                    viewModel
                                                            .sumAmountReportSale
                                                            .sumAmountFastOrder +
                                                        viewModel
                                                            .sumAmountReportSale
                                                            .sumAmountPostOrder,
                                                  )}',
                                                  style:
                                                      defaultTextStyle.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20),
                                                ),
                                                SizedBox(
                                                  width: deviceWidth / 3,
                                                  height: 5,
                                                  child: Divider(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Điểm bán hàng:\n ${vietnameseCurrencyFormat(viewModel.sumAmountReportSale.sumAmountPostOrder)}',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  'Bán hàng nhanh:\n ${vietnameseCurrencyFormat(viewModel.sumAmountReportSale.sumAmountFastOrder)}',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 5.0),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                gradient:
                                                    LinearGradient(colors: [
                                                  Color(0xffA47CFF),
                                                  Color(0xffFD7BF5),
                                                ])),
                                            width: (deviceWidth - 25) / 2,
                                            height: 170,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      stops: [0.1, 1],
                                                      colors: [
                                                        Color(0xffA47CFF),
                                                        Color(0xffFD7BF5),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.monetization_on,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Nợ',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                    '${vietnameseCurrencyFormat(viewModel.sumAmountReportSale.sumPaidFastOrder)}',
                                                    style: defaultTextStyle
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20)),
                                                SizedBox(
                                                  width: deviceWidth / 3,
                                                  height: 5,
                                                  child: Divider(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Điểm bán hàng:\n ${vietnameseCurrencyFormat(viewModel.sumAmountReportSale.sumPaidPostOrder)}',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  'Bán hàng nhanh:\n ${vietnameseCurrencyFormat(viewModel.sumAmountReportSale.sumPaidFastOrder)}',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: 10.0,
                                                right: 5.0,
                                                bottom: 5.0,
                                                top: 5.0),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                gradient:
                                                    LinearGradient(colors: [
                                                  Color(0xffFF9190),
                                                  Color(0xffFEBE7E),
                                                ])),
                                            width: (deviceWidth - 35) / 4,
                                            height: 170,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      stops: [0.1, 1],
                                                      colors: [
                                                        Color(0xffFF9190),
                                                        Color(0xffFEBE7E),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.monetization_on,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Bán hàng',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                    '${vietnameseCurrencyFormat(viewModel.sumAmountReportSale.sumAmountBeforeDiscountFastOrder + viewModel.sumAmountReportSale.sumAmountBeforeDiscountPostOrder)}',
                                                    style: defaultTextStyle
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20)),
                                                SizedBox(
                                                  width: deviceWidth / 3,
                                                  height: 5,
                                                  child: Divider(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Điểm bán hàng:\n ${vietnameseCurrencyFormat(viewModel.sumAmountReportSale.sumAmountBeforeDiscountPostOrder)}',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  'Bán hàng nhanh:\n ${vietnameseCurrencyFormat(viewModel.sumAmountReportSale.sumAmountBeforeDiscountFastOrder)}',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                gradient:
                                                    LinearGradient(colors: [
                                                  Color(0xff07B1FF),
                                                  Color(0xff07EDE3),
                                                ])),
                                            width: (deviceWidth - 35) / 4,
                                            height: 170,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      stops: [0.1, 1],
                                                      colors: [
                                                        Color(0xff07B1FF),
                                                        Color(0xff07EDE3),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.monetization_on,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Khuyến mãi + chiết khấu',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                    '${vietnameseCurrencyFormat(viewModel.sumAmountReportSale.sumDecreateAmountFastOrder + viewModel.sumAmountReportSale.sumDiscountAmountFastOrder + viewModel.sumAmountReportSale.sumDecreateAmountPostOrder + viewModel.sumAmountReportSale.sumDiscountAmountPostOrder)}',
                                                    style: defaultTextStyle
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20)),
                                                SizedBox(
                                                  width: deviceWidth / 3,
                                                  height: 5,
                                                  child: Divider(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Điểm bán hàng:\n ${vietnameseCurrencyFormat(viewModel.sumAmountReportSale.sumPaidtSaleOrder)}',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  'Bán hàng nhanh:\n ${vietnameseCurrencyFormat(viewModel.sumReportSaleGeneral.totalKM + viewModel.sumReportSaleGeneral.totalCk)}',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 5.0),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                gradient:
                                                    LinearGradient(colors: [
                                                  Color(0xff00DA90),
                                                  Color(0xff52FDAE),
                                                ])),
                                            width: (deviceWidth - 35) / 4,
                                            height: 170,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      stops: [0.1, 1],
                                                      colors: [
                                                        Color(0xff00DA90),
                                                        Color(0xff52FDAE),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.monetization_on,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Tổng tiền',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.right,
                                                ),
                                                Text(
                                                    '${vietnameseCurrencyFormat(viewModel.sumAmountReportSale.sumAmountFastOrder + viewModel.sumAmountReportSale.sumAmountPostOrder)}',
                                                    style: defaultTextStyle
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20)),
                                                SizedBox(
                                                  width: deviceWidth / 3,
                                                  height: 5,
                                                  child: Divider(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Điểm bán hàng:\n ${vietnameseCurrencyFormat(viewModel.sumAmountReportSale.sumAmountPostOrder)}',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  'Bán hàng nhanh:\n ${vietnameseCurrencyFormat(viewModel.sumAmountReportSale.sumAmountFastOrder)}',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 5.0),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                gradient:
                                                    LinearGradient(colors: [
                                                  Color(0xffA47CFF),
                                                  Color(0xffFD7BF5),
                                                ])),
                                            width: (deviceWidth - 35) / 4,
                                            height: 170,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      stops: [0.1, 1],
                                                      colors: [
                                                        Color(0xffA47CFF),
                                                        Color(0xffFD7BF5),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.monetization_on,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Nợ',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                    '${vietnameseCurrencyFormat(viewModel.sumAmountReportSale.sumPaidFastOrder)}',
                                                    style: defaultTextStyle
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20)),
                                                SizedBox(
                                                  width: deviceWidth / 3,
                                                  height: 5,
                                                  child: Divider(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  'Điểm bán hàng:\n ${vietnameseCurrencyFormat(viewModel.sumAmountReportSale.sumPaidPostOrder)}',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                                Text(
                                                  'Bán hàng nhanh:\n ${vietnameseCurrencyFormat(viewModel.sumAmountReportSale.sumPaidFastOrder)}',
                                                  style: defaultTextStyle,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ])),
                          isTablet
                              ? SliverList(
                                  delegate: SliverChildListDelegate([
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        horizontalMargin: 20,
                                        sortColumnIndex:
                                            viewModel.sortColumnIndex,
                                        sortAscending: viewModel.sortAscending,
                                        columns: <DataColumn>[
                                          DataColumn(
                                            label: Container(
                                              width: columnWidth,
                                              child: const Text('Chứng từ'),
                                            ),
                                            onSort: (int columnIndex,
                                                    bool ascending) =>
                                                viewModel.sortDetail<String>(
                                                    (ReportSaleOrderInfo d) =>
                                                        d.name,
                                                    columnIndex,
                                                    ascending),
                                          ),
                                          DataColumn(
                                            label: Container(
                                                width: columnWidth,
                                                child:
                                                    const Text('Khách hàng')),
                                          ),
                                          DataColumn(
                                            label: Container(
                                                width: columnWidth,
                                                child: const Text('Người bán')),
                                            onSort: (int columnIndex,
                                                    bool ascending) =>
                                                viewModel.sortDetail<String>(
                                                    (ReportSaleOrderInfo d) =>
                                                        d.userName,
                                                    columnIndex,
                                                    ascending),
                                          ),
                                          DataColumn(
                                            label: Container(
                                                width: columnWidth,
                                                child:
                                                    const Text('Trạng thái')),
                                            onSort: (int columnIndex,
                                                    bool ascending) =>
                                                viewModel.sortDetail<String>(
                                                    (ReportSaleOrderInfo d) =>
                                                        d.showState,
                                                    columnIndex,
                                                    ascending),
                                          ),
                                          DataColumn(
                                            label: Container(
                                                width: columnWidth,
                                                child: const Text(
                                                  'Tổng tiền',
                                                  textAlign: TextAlign.right,
                                                )),
                                            numeric: true,
                                            onSort: (int columnIndex,
                                                    bool ascending) =>
                                                viewModel.sortDetail<num>(
                                                    (ReportSaleOrderInfo d) =>
                                                        d.amountTotal,
                                                    columnIndex,
                                                    ascending),
                                          ),
                                          DataColumn(
                                            label: Container(
                                                width: columnWidth,
                                                child: const Text('Ngày tạo')),
                                            onSort: (int columnIndex,
                                                    bool ascending) =>
                                                viewModel.sortDetail<DateTime>(
                                                    (ReportSaleOrderInfo d) =>
                                                        d.dateOrder,
                                                    columnIndex,
                                                    ascending),
                                          ),
                                        ],
                                        rows: viewModel.reportSaleOrder?.value
                                                ?.map(
                                                  (itemRow) => DataRow(
                                                    cells: [
                                                      DataCell(
                                                          Text(
                                                              '${itemRow.name ?? ''}'),
                                                          onTap: () {
                                                        navigatorDetail(
                                                            itemRow);
                                                      }),
                                                      DataCell(
                                                          Text(
                                                              '${itemRow.partnerDisplayName ?? ''}'),
                                                          onTap: () {
                                                        navigatorDetail(
                                                            itemRow);
                                                      }),
                                                      DataCell(
                                                          Text(
                                                              '${itemRow.userName ?? ''}'),
                                                          onTap: () {
                                                        navigatorDetail(
                                                            itemRow);
                                                      }),
                                                      DataCell(
                                                          Text(
                                                              '${itemRow.showState ?? ''}'),
                                                          onTap: () {
                                                        navigatorDetail(
                                                            itemRow);
                                                      }),
                                                      DataCell(
                                                          Text(
                                                              '${vietnameseCurrencyFormat(itemRow.amountTotal)}'),
                                                          onTap: () {
                                                        navigatorDetail(
                                                            itemRow);
                                                      }),
                                                      DataCell(Text(
                                                          '${DateFormat("dd/MM/yyyy HH:mm", "en_US").format(itemRow.dateOrder)}')),
                                                    ],
                                                  ),
                                                )
                                                ?.toList() ??
                                            [],
                                      ),
                                    ),
                                  ]),
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      return Container(
                                        margin: EdgeInsets.only(
                                            left: 12, right: 12, top: 8),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: Colors.white70,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            ListTile(
                                              onTap: () async {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return ReportSaleOrderInfoPage(
                                                    order: viewModel
                                                        .reportSaleOrder
                                                        .value[index],
                                                  );
                                                }));
                                              },
                                              contentPadding: EdgeInsets.only(
                                                  left: 15.0, right: 15.0),
                                              subtitle: Column(
                                                children: <Widget>[
                                                  // title
                                                  Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Text(
                                                            "${viewModel.reportSaleOrder?.value[index]?.name ?? ""}",
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .orange,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16)),
                                                      ),
                                                      Text(
                                                        "${vietnameseCurrencyFormat(viewModel.reportSaleOrder?.value[index]?.amountTotal) ?? ""}",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.orange,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  ),
                                                  Wrap(
                                                    children: <Widget>[
                                                      Text(
                                                        "Khách hàng: ",
                                                      ),
                                                      Text(
                                                        "${viewModel.reportSaleOrder?.value[index]?.partnerDisplayName ?? ""}",
                                                        style: TextStyle(
                                                            color: Colors.blue),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Text(
                                                        "Nợ: ",
                                                      ),
                                                      Text(
                                                        "${vietnameseCurrencyFormat(viewModel.reportSaleOrder?.value[index]?.residual ?? "")}",
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                      Text(
                                                        " | Trạng thái: ",
                                                      ),
                                                      Text(
                                                        "${viewModel.reportSaleOrder?.value[index]?.showState}",
                                                        style: TextStyle(
                                                            color: getFastSaleOrderStateOption(
                                                                    state: viewModel
                                                                        .reportSaleOrder
                                                                        ?.value[
                                                                            index]
                                                                        ?.state)
                                                                .textColor),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Text(
                                                        "",
                                                      ),
                                                      Text(
                                                        "${DateFormat("dd/MM/yyyy HH:mm", "en_US").format(viewModel.reportSaleOrder?.value[index]?.dateOrder)}",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.green),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    "${viewModel.reportSaleOrder?.value[index]?.companyName}",
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Text(
                                                        "Người bán: ",
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          "${viewModel.reportSaleOrder?.value[index]?.userName}",
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    childCount: viewModel
                                            .reportSaleOrder?.value?.length ??
                                        0,
                                  ),
                                ),
                        ],
                      ),
                    ),
//                    IconButton(
//                      icon: Icon(
//                        FontAwesomeIcons.solidArrowAltCircleUp,
//                        size: 50,
//                      ),
//                      color: Colors.green,
//                      onPressed: () {
//                        scrollToTop(controller: _scrollControllerDetail);
//                      },
//                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ), onRefresh: () async {
        await viewModel.filter();
        return true;
      }),
    );
  }

  /// Lọc
  Widget _showDrawerRight(BuildContext context) {
    var theme = Theme.of(context);
    return ScopedModelDescendant<ReportSaleOrderViewModel>(
      builder: (context, child, model) {
        return SafeArea(
          right: true,
          left: true,
          bottom: true,
          top: true,
          child: Drawer(
            child: Column(
              children: <Widget>[
                Container(
                    width: double.infinity,
                    height: 35,
                    alignment: Alignment.center,
                    color: Colors.green.shade100,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            "ĐIỀU KIỆN LỌC",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    )),
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  "Người bán: ",
                                ),
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: new DropdownButton<UserReportStaff>(
                                      style: TextStyle(color: Colors.black),
                                      hint: Text("Chọn người bán"),
                                      value: viewModel.selectedUserReportStaff,
                                      onChanged: (value) {
                                        viewModel
                                            .setCommandUserReportStaff(value);
                                      },
                                      items: viewModel.userReportStaffs
                                          ?.map(
                                            (f) => DropdownMenuItem<
                                                UserReportStaff>(
                                              child: Text(
                                                "${f.text}",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.green),
                                              ),
                                              value: f,
                                            ),
                                          )
                                          ?.toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                  "Loại hóa đơn: ",
                                ),
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: new DropdownButton<String>(
                                      isDense: true,
                                      hint: new Text("Chọn loại hóa đơn"),
                                      value: viewModel.selectedOrderType,
                                      onChanged: (String newValue) {
                                        setState(() {
                                          viewModel.selectedOrderType =
                                              newValue;
                                        });
                                      },
                                      items: viewModel.orderType.map((Map map) {
                                        return new DropdownMenuItem<String>(
                                          value: map["value"],
                                          child: new Text(
                                            map["name"],
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.green),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                  "Công ty: ",
                                ),
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: new DropdownButton<CompanyOfUser>(
                                      style: TextStyle(color: Colors.black),
                                      hint: Text("Chọn công ty"),
                                      value: viewModel.selectedCompanyOfUser,
                                      onChanged: (value) {
                                        viewModel.setCommandCompanyUser(value);
                                      },
                                      items: viewModel.companyOfUsers
                                          ?.map(
                                            (f) =>
                                                DropdownMenuItem<CompanyOfUser>(
                                              child: Text(
                                                "${f.text}",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.green),
                                              ),
                                              value: f,
                                            ),
                                          )
                                          ?.toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                            ListTile(
                              contentPadding:
                                  EdgeInsets.only(left: 2, right: 2),
                              title: Text("Khách hàng"),
                              subtitle: Text(
                                "${viewModel.partner?.name ?? "Chọn khách hàng"}",
                                style: TextStyle(color: Colors.green),
                              ),
                              trailing: Icon(Icons.keyboard_arrow_right),
                              onTap: () async {
                                Partner result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return PartnerSearchPage();
                                    },
                                  ),
                                );
                                if (result != null) {
                                  viewModel.selectPartnerCommand(result);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      // Ngày tháng
                      new ExpansionTile(
                          title: Text("Lọc theo ngày"),
                          initiallyExpanded: true,
                          children: <Widget>[
                            ListView.builder(
                              itemExtent: 40,
                              padding: EdgeInsets.only(
                                  top: 0, bottom: 0, left: 0, right: 0),
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: viewModel.filterByDates?.length ?? 0,
                              itemBuilder: (_, index) {
                                return new ListTile(
                                  selected: viewModel.selectedFilterByDate ==
                                      viewModel.filterByDates[index],
                                  title: Text(
                                      "${viewModel.filterByDates[index].name}"),
                                  onTap: () {
                                    viewModel.selectFilterByDateCommand(
                                        viewModel.filterByDates[index]);
                                  },
                                );
                              },
                            ),
                            Divider(),
                            ListTile(
                              contentPadding:
                                  EdgeInsets.only(left: 10, right: 5),
                              leading: Text("Từ: "),
                              title: OutlineButton(
                                textColor: Colors.green,
                                child: Text(
                                  "${viewModel.fromDate != null ? DateFormat("dd/MM/yyyy").format(viewModel.fromDate) : ""}",
                                ),
                                onPressed: () async {
                                  var selectedDate = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          viewModel.fromDate ?? DateTime.now(),
                                      firstDate: DateTime.now()
                                          .add(new Duration(days: -3650)),
                                      lastDate: DateTime.now());
                                  if (selectedDate != null) {
                                    viewModel
                                        .updateFromDateCommand(selectedDate);
                                  }
                                },
                              ),
                              trailing: SizedBox(
                                width: 75,
                                child: OutlineButton(
                                  padding: EdgeInsets.all(0),
                                  child: Text(
                                    "${viewModel.fromDate != null ? DateFormat("HH:mm").format(viewModel.fromDate) : ""}",
                                  ),
                                  onPressed: () async {
                                    var selectedTime = await showTimePicker(
                                        context: context,
                                        initialTime:
                                            new TimeOfDay(hour: 0, minute: 0));

                                    if (selectedTime != null) {
                                      viewModel.updateFromDateTimeCommand(
                                          selectedTime);
                                    }
                                  },
                                ),
                              ),
                            ),
                            ListTile(
                              contentPadding:
                                  EdgeInsets.only(left: 10, right: 5),
                              leading: Text("Tới: "),
                              title: OutlineButton(
                                padding: EdgeInsets.all(0),
                                textColor: Colors.green,
                                child: Text(
                                  "${viewModel.toDate != null ? DateFormat("dd/MM/yyyy").format(viewModel.toDate) : ""}",
                                ),
                                onPressed: () async {
                                  var selectedDate = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          viewModel.fromDate ?? DateTime.now(),
                                      firstDate: DateTime.now()
                                          .add(new Duration(days: -60)),
                                      lastDate: DateTime.now());
                                  if (selectedDate != null) {
                                    viewModel.updateToDateCommand(selectedDate);
                                  }
                                },
                              ),
                              trailing: SizedBox(
                                width: 75,
                                child: OutlineButton(
                                  padding: EdgeInsets.all(0),
                                  child: Text(
                                    "${viewModel.toDate != null ? DateFormat("HH:mm").format(viewModel.toDate) : ""}",
                                  ),
                                  onPressed: () async {
                                    var selectedTime = await showTimePicker(
                                        context: context,
                                        initialTime:
                                            new TimeOfDay(hour: 0, minute: 0));

                                    if (selectedTime != null) {
                                      viewModel.updateToDateTimeCommand(
                                          selectedTime);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ]),
                    ],
                  ),
                ),
                new Row(
                  children: <Widget>[
                    new Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: new RaisedButton.icon(
                          shape: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 1, color: Colors.green),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.white,
                          textColor: Theme.of(context).primaryColor,
                          icon: Icon(Icons.refresh),
                          label: Text(
                            "Thiết lập lại",
                          ),
                          onPressed: () {
                            viewModel.removeFilter();
                          },
                        ),
                      ),
                    ),
                    new Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: new RaisedButton.icon(
                          color: theme.primaryColor,
                          textColor: Colors.white,
                          icon: Icon(Icons.check),
                          shape: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide:
                                BorderSide(width: 1, color: theme.primaryColor),
                          ),
                          label: Text(
                            "Áp dụng",
                          ),
                          onPressed: () {
                            viewModel.filter();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void scrollToTop({ScrollController controller}) {
    controller.animateTo(
      0,
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeIn,
    );
  }

  void navigatorDetail(ReportSaleOrderInfo value) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (ctx) => ReportSaleOrderInfoPage(
                order: value,
              )),
    );
  }

  @override
  void initState() {
    super.initState();
    viewModel.initCommand();
    _scrollControllerGeneral.addListener(() {
      if (_scrollControllerGeneral.position.atEdge) {
        if (_scrollControllerGeneral.position.pixels != 0) if (viewModel
            .canLoadMore) viewModel.loadMoreReportSaleOrderGeneral();
      }
    });
    _scrollControllerDetail.addListener(() {
      if (_scrollControllerDetail.position.atEdge) {
        if (_scrollControllerDetail.position.pixels != 0) if (viewModel
            .canLoadMoreSaleOrder) viewModel.loadMoreReportSaleOrder();
      }
    });
  }
}
