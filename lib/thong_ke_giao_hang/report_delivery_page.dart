import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/app_core/helper/string_helper.dart';
import 'package:tpos_mobile/src/tpos_apis/models/delivery_carrier.dart';
import 'package:tpos_mobile/src/tpos_apis/models/date_filter_template.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner.dart';
import 'package:tpos_mobile/sale_online/ui/partner_search_page.dart';
import 'package:tpos_mobile/app_core/ui_base/ui_vm_base.dart';
import 'package:tpos_mobile/thong_ke_giao_hang/report_delivery.dart';
import 'package:tpos_mobile/thong_ke_giao_hang/report_delivery_info_page.dart';
import 'package:tpos_mobile/thong_ke_giao_hang/report_delivery_viewmodel.dart';

class ReportDeliveryPage extends StatefulWidget {
  @override
  _ReportDeliveryPageState createState() => _ReportDeliveryPageState();
}

class _ReportDeliveryPageState extends State<ReportDeliveryPage> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _scrollController = new ScrollController();
  ReportDeliveryViewModel viewModel = new ReportDeliveryViewModel();

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
    columnWidth = (deviceWidth - 40) / 11;
    if (deviceWidth > 700)
      isTablet = true;
    else
      isTablet = false;
    return ScopedModel<ReportDeliveryViewModel>(
      model: viewModel,
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        key: _scaffoldKey,
        appBar: new AppBar(
          title: Text("Thống kê giao hàng"),
          actions: <Widget>[
            Text(""),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: _buildGeneral(),
            ),
          ],
        ),
        endDrawer: _showDrawerRight(context),
      ),
    );
  }

  Widget _buildGeneral() {
    return UIViewModelBase(
      viewModel: viewModel,
      child: RefreshIndicator(
          child: ScopedModelDescendant<ReportDeliveryViewModel>(
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
                        controller: _scrollController,
                        slivers: <Widget>[
                          SliverList(
                              delegate: SliverChildListDelegate([
                            !isTablet
                                ? buildMobileHeader()
                                : buildTabletHeader(),
                          ])),
                          isTablet ? buildListTablet() : buildMobileList(),
                        ],
                      ),
                    ),
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
    return ScopedModelDescendant<ReportDeliveryViewModel>(
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
                                  "Trạng thái: ",
                                ),
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: new DropdownButton<String>(
                                      isDense: true,
                                      hint: new Text("Chọn đối tác giao hàng"),
                                      value: viewModel.selectedShipState,
                                      onChanged: (String newValue) {
                                        setState(() {
                                          viewModel.selectedShipState =
                                              newValue;
                                        });
                                      },
                                      items: viewModel.shipState.map((Map map) {
                                        return new DropdownMenuItem<String>(
                                          value: map["value"],
                                          child: new Text(
                                            map["name"],
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.green),
                                            textAlign: TextAlign.right,
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
                                  "Đối tác GH: ",
                                ),
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: new DropdownButton<DeliveryCarrier>(
                                      style: TextStyle(color: Colors.black),
                                      value: viewModel.selectedDeliveryCarrier,
                                      onChanged: (value) {
                                        viewModel
                                            .setCommandDeliveryCarrier(value);
                                      },
                                      items: viewModel.deliveryCarriers
                                          ?.map(
                                            (f) => DropdownMenuItem<
                                                DeliveryCarrier>(
                                              child: Text(
                                                "${f.name}",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.green),
                                                textAlign: TextAlign.right,
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
                            Divider(
                              height: 2,
                            ),
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

  Widget buildMobileHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                  top: 5.0, right: 5.0, bottom: 5.0, left: 10.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  gradient: LinearGradient(colors: [
                    Color(0xffFF9190),
                    Color(0xffFEBE7E),
                  ])),
              width: (deviceWidth - 25) / 2,
              height: 90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
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
                    '${viewModel.sumDeliveryReport?.sumQuantityCollectionOrder ?? 0} hóa đơn',
                    style: defaultTextStyle,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                      '${vietnameseCurrencyFormat(viewModel.sumDeliveryReport?.sumCollectionAmount) ?? 0}',
                      style: defaultTextStyle.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                  Text(
                    'Tiền thu hộ',
                    style: defaultTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  gradient: LinearGradient(colors: [
                    Color(0xff07B1FF),
                    Color(0xff07EDE3),
                  ])),
              width: (deviceWidth - 25) / 2,
              height: 90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
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
                    '${viewModel.sumDeliveryReport?.sumQuantityPaymentOrder ?? 0} hóa đơn',
                    style: defaultTextStyle,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                      '${vietnameseCurrencyFormat(viewModel.sumDeliveryReport?.sumPaymentAmount) ?? 0}',
                      style: defaultTextStyle.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                  Text(
                    'Đã thanh toán',
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
                  borderRadius: BorderRadius.circular(8.0),
                  gradient: LinearGradient(colors: [
                    Color(0xff00DA90),
                    Color(0xff52FDAE),
                  ])),
              width: (deviceWidth - 25) / 2,
              height: 90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.1, 1],
                        colors: [
                          Color(0xff00DA90),
                          Color(0xff52FDAE),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${viewModel.sumDeliveryReport?.sumQuantityRefundedOrder ?? 0} hóa đơn',
                    style: defaultTextStyle,
                    textAlign: TextAlign.center,
                  ),
                  Text('${viewModel.sumDeliveryReport?.sumRefundedAmount ?? 0}',
                      style: defaultTextStyle.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                  Text(
                    'Trả hàng',
                    style: defaultTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 5.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  gradient: LinearGradient(colors: [
                    Color(0xffA47CFF),
                    Color(0xffFD7BF5),
                  ])),
              width: (deviceWidth - 25) / 2,
              height: 90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
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
                    '${viewModel.sumDeliveryReport?.sumQuantityDelivering ?? 0} hóa đơn',
                    style: defaultTextStyle,
                    textAlign: TextAlign.right,
                  ),
                  Text(
                      '${vietnameseCurrencyFormat(viewModel.sumDeliveryReport?.sumDeliveringAmount) ?? 0}',
                      style: defaultTextStyle.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                  Text(
                    'Đang giao',
                    style: defaultTextStyle,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildMobileList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Container(
            margin: EdgeInsets.only(left: 10, right: 10, top: 8.0),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white70,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: <Widget>[
                ListTile(
                  onTap: () async {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ReportDeliveryInfoPage(
                        order: viewModel.reportDelivery.data[index],
                      );
                    }));
                  },
                  contentPadding: EdgeInsets.only(left: 10.0, right: 10.0),
                  subtitle: Column(
                    children: <Widget>[
                      // title
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                                "${viewModel.reportDelivery.data[index].partnerDisplayName}",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.orangeAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ),
                          Text(
                            "${vietnameseCurrencyFormat(
                              viewModel
                                  .reportDelivery.data[index].cashOnDelivery,
                            )}",
                            style: TextStyle(
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                      Wrap(
                        children: <Widget>[
                          Text(
                            "${viewModel.reportDelivery.data[index].number} | ",
                            style: TextStyle(color: Colors.blue),
                          ),
                          Text(
                            "${DateFormat("dd/MM/yyyy").format(viewModel.reportDelivery.data[index].dateInvoice)}",
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Tổng tiền: ",
                          ),
                          Text(
                            "${vietnameseCurrencyFormat(
                              viewModel.reportDelivery.data[index].amountTotal,
                            )}",
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            " | Ship: ",
                          ),
                          Text(
                            "${vietnameseCurrencyFormat(
                                  viewModel
                                      .reportDelivery.data[index].deliveryPrice,
                                ) ?? 0}",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                      Wrap(
                        children: <Widget>[
                          Text(
                            "${viewModel.reportDelivery.data[index].carrierName ?? ""} | ",
                            style: TextStyle(color: Colors.green),
                          ),
                          Text(
                            "${viewModel.reportDelivery.data[index].trackingRef ?? ""} | ",
                            style: TextStyle(color: Colors.green),
                          ),
                          Text(
                            "${viewModel.reportDelivery.data[index].shipPaymentStatus ?? ""}",
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "Đối soát GH: ",
                          ),
                          Text(
                            "${viewModel.reportDelivery.data[index].showShipStatus}",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
              ],
            ),
          );
        },
        childCount: viewModel.reportDelivery?.data?.length ?? 0,
      ),
    );
  }

  Widget buildTabletHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                  top: 5.0, right: 5.0, bottom: 5.0, left: 10.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  gradient: LinearGradient(colors: [
                    Color(0xffFF9190),
                    Color(0xffFEBE7E),
                  ])),
              width: (deviceWidth - 35) / 4,
              height: 90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
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
                    '${viewModel.sumDeliveryReport?.sumQuantityCollectionOrder ?? 0} hóa đơn',
                    style: defaultTextStyle,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                      '${vietnameseCurrencyFormat(viewModel.sumDeliveryReport?.sumCollectionAmount) ?? 0}',
                      style: defaultTextStyle.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                  Text(
                    'Tiền thu hộ',
                    style: defaultTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  gradient: LinearGradient(colors: [
                    Color(0xff07B1FF),
                    Color(0xff07EDE3),
                  ])),
              width: (deviceWidth - 35) / 4,
              height: 90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
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
                    '${viewModel.sumDeliveryReport?.sumQuantityPaymentOrder ?? 0} hóa đơn',
                    style: defaultTextStyle,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                      '${vietnameseCurrencyFormat(viewModel.sumDeliveryReport?.sumPaymentAmount) ?? 0}',
                      style: defaultTextStyle.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                  Text(
                    'Đã thanh toán',
                    style: defaultTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 5.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  gradient: LinearGradient(colors: [
                    Color(0xff00DA90),
                    Color(0xff52FDAE),
                  ])),
              width: (deviceWidth - 35) / 4,
              height: 90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.1, 1],
                        colors: [
                          Color(0xff00DA90),
                          Color(0xff52FDAE),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${viewModel.sumDeliveryReport?.sumQuantityRefundedOrder ?? 0} hóa đơn',
                    style: defaultTextStyle,
                    textAlign: TextAlign.center,
                  ),
                  Text('${viewModel.sumDeliveryReport?.sumRefundedAmount ?? 0}',
                      style: defaultTextStyle.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                  Text(
                    'Trả hàng',
                    style: defaultTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 5.0, right: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  gradient: LinearGradient(colors: [
                    Color(0xffA47CFF),
                    Color(0xffFD7BF5),
                  ])),
              width: (deviceWidth - 35) / 4,
              height: 90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
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
                    '${viewModel.sumDeliveryReport?.sumQuantityDelivering ?? 0} hóa đơn',
                    style: defaultTextStyle,
                    textAlign: TextAlign.right,
                  ),
                  Text(
                      '${vietnameseCurrencyFormat(viewModel.sumDeliveryReport?.sumDeliveringAmount) ?? 0}',
                      style: defaultTextStyle.copyWith(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                  Text(
                    'Đang giao',
                    style: defaultTextStyle,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildListTablet() {
    return SliverList(
      delegate: SliverChildListDelegate([
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            horizontalMargin: 20,
            sortColumnIndex: viewModel.sortColumnIndex,
            sortAscending: viewModel.sortAscending,
            columns: <DataColumn>[
              DataColumn(
                label: Container(
                  width: columnWidth,
                  child: const Text('Khách hàng'),
                ),
                onSort: (int columnIndex, bool ascending) =>
                    viewModel.sortGeneral<String>(
                  (ReportDeliveryInfo d) => d.partnerDisplayName,
                  ascending,
                  columnIndex,
                ),
              ),
              DataColumn(
                label:
                    Container(width: columnWidth, child: const Text('Ngày HĐ')),
                onSort: (int columnIndex, bool ascending) =>
                    viewModel.sortGeneral<DateTime>(
                  (ReportDeliveryInfo d) => d.dateInvoice,
                  ascending,
                  columnIndex,
                ),
              ),
              DataColumn(
                label: Container(
                  width: columnWidth,
                  child: const Text(
                    'Số',
                  ),
                ),
                onSort: (int columnIndex, bool ascending) =>
                    viewModel.sortGeneral<String>(
                  (ReportDeliveryInfo d) => d.number,
                  ascending,
                  columnIndex,
                ),
              ),
              DataColumn(
                label: Container(
                  width: columnWidth,
                  child: const Text(
                    'Tổng tiền',
                    textAlign: TextAlign.right,
                  ),
                ),
                numeric: true,
                onSort: (int columnIndex, bool ascending) =>
                    viewModel.sortGeneral<num>(
                  (ReportDeliveryInfo d) => d.amountTotal,
                  ascending,
                  columnIndex,
                ),
              ),
              DataColumn(
                  label: Container(
                    width: columnWidth,
                    child: const Text('Thu hộ', textAlign: TextAlign.right),
                  ),
                  onSort: (int columnIndex, bool ascending) =>
                      viewModel.sortGeneral<num>(
                        (ReportDeliveryInfo d) => d.cashOnDelivery,
                        ascending,
                        columnIndex,
                      ),
                  numeric: true),
              DataColumn(
                  label: Container(
                    width: columnWidth,
                    child: const Text(
                      'Phí ship',
                      textAlign: TextAlign.right,
                    ),
                  ),
                  onSort: (int columnIndex, bool ascending) =>
                      viewModel.sortGeneral<num>(
                        (ReportDeliveryInfo d) => d.deliveryPrice,
                        ascending,
                        columnIndex,
                      ),
                  numeric: true),
              DataColumn(
                  label: Container(
                    width: columnWidth,
                    child: const Text('Tiền cọc', textAlign: TextAlign.right),
                  ),
                  onSort: (int columnIndex, bool ascending) =>
                      viewModel.sortGeneral<num>(
                        (ReportDeliveryInfo d) => d.amountDeposit,
                        ascending,
                        columnIndex,
                      ),
                  numeric: true),
              DataColumn(
                label: Container(
                    width: columnWidth, child: const Text('Đối tác GH')),
                onSort: (int columnIndex, bool ascending) =>
                    viewModel.sortGeneral<String>(
                  (ReportDeliveryInfo d) => d.carrierName,
                  ascending,
                  columnIndex,
                ),
              ),
              DataColumn(
                label: Container(
                    width: columnWidth, child: const Text('Mã vận đơn')),
                onSort: (int columnIndex, bool ascending) =>
                    viewModel.sortGeneral<String>(
                  (ReportDeliveryInfo d) => d.trackingRef,
                  ascending,
                  columnIndex,
                ),
              ),
              DataColumn(
                label: Container(
                    width: columnWidth, child: const Text('Trạng thái GH')),
                onSort: (int columnIndex, bool ascending) =>
                    viewModel.sortGeneral<String>(
                  (ReportDeliveryInfo d) => d.shipPaymentStatus,
                  ascending,
                  columnIndex,
                ),
              ),
              DataColumn(
                label: Container(
                    width: columnWidth, child: const Text('Đối soát GH')),
                onSort: (int columnIndex, bool ascending) =>
                    viewModel.sortGeneral<String>(
                  (ReportDeliveryInfo d) => d.showShipStatus,
                  ascending,
                  columnIndex,
                ),
              ),
            ],
            rows: viewModel.reportDelivery?.data
                    ?.map(
                      (itemRow) => DataRow(
                        cells: [
                          DataCell(Text('${itemRow.partnerDisplayName ?? ''}'),
                              onTap: () {
                            navigatorDetail(itemRow);
                          }),
//                  DataCell(
//                    Text(
//                      '${itemRow.address ?? ''}',
//                      textAlign:
//                      TextAlign.right,
//                    ),
//                  ),
                          DataCell(
                              Text(
                                  '${DateFormat("dd/MM/yyyy").format(itemRow.dateInvoice) ?? ''}'),
                              onTap: () {
                            navigatorDetail(itemRow);
                          }),
                          DataCell(Text('${itemRow.number ?? ''}'), onTap: () {
                            navigatorDetail(itemRow);
                          }),
                          DataCell(
                              Text(
                                '${vietnameseCurrencyFormat(
                                      itemRow.amountTotal,
                                    ) ?? ''}',
                                textAlign: TextAlign.right,
                                style: defaultTextStyle.copyWith(
                                    color: Colors.red),
                              ), onTap: () {
                            navigatorDetail(itemRow);
                          }),
                          DataCell(
                            Text(
                              '${vietnameseCurrencyFormat(
                                itemRow.cashOnDelivery,
                              )}',
                              textAlign: TextAlign.right,
                              style:
                                  defaultTextStyle.copyWith(color: Colors.red),
                            ),
                            onTap: () {
                              navigatorDetail(itemRow);
                            },
                          ),
                          DataCell(
                              Text(
                                '${vietnameseCurrencyFormat(
                                  itemRow.deliveryPrice,
                                )}',
                                textAlign: TextAlign.right,
                                style: defaultTextStyle.copyWith(
                                    color: Colors.red),
                              ), onTap: () {
                            navigatorDetail(itemRow);
                          }),
                          DataCell(
                              Text(
                                '${vietnameseCurrencyFormat(
                                  itemRow.amountDeposit,
                                )}',
                                textAlign: TextAlign.right,
                                style: defaultTextStyle.copyWith(
                                    color: Colors.red),
                              ), onTap: () {
                            navigatorDetail(itemRow);
                          }),
                          DataCell(Text('${itemRow.carrierName ?? ''}'),
                              onTap: () {
                            navigatorDetail(itemRow);
                          }),
                          DataCell(Text('${itemRow.trackingRef ?? ''}'),
                              onTap: () {
                            navigatorDetail(itemRow);
                          }),
                          DataCell(Text('${itemRow.shipPaymentStatus ?? ''}'),
                              onTap: () {
                            navigatorDetail(itemRow);
                          }),
                          DataCell(Text('${itemRow.showShipStatus ?? ''}'),
                              onTap: () {
                            navigatorDetail(itemRow);
                          }),
                        ],
                      ),
                    )
                    ?.toList() ??
                [],
          ),
        ),
      ]),
    );
  }

  void scrollToTop({ScrollController controller}) {
    controller.animateTo(
      0,
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeIn,
    );
  }

  void navigatorDetail(ReportDeliveryInfo value) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (ctx) => ReportDeliveryInfoPage(
                order: value,
              )),
    );
  }

  @override
  void initState() {
    super.initState();
    viewModel.initCommand();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels != 0) if (viewModel.canLoadMore)
          viewModel.loadMoreReportDelivery();
      }
    });
  }
}
