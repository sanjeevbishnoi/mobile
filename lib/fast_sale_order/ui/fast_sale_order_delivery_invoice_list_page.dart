/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 7/5/19 4:54 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 7/5/19 8:45 AM
 *
 */

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/app_core/template_models/app_filter_date_model.dart';
import 'package:tpos_mobile/app_core/template_ui/app_filter_datetime.dart';
import 'package:tpos_mobile/app_core/template_ui/app_filter_drawer.dart';
import 'package:tpos_mobile/app_core/template_ui/app_filter_panel.dart';
import 'package:tpos_mobile/app_core/template_ui/app_list_empty_notify.dart';
import 'package:tpos_mobile/app_core/template_ui/app_load_more_button.dart';
import 'package:tpos_mobile/app_core/ui_base/ui_base.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/fast_sale_order/viewmodels/fast_sale_order_delivery_invoice_info_viewmodel.dart';
import 'package:tpos_mobile/fast_sale_order/viewmodels/fast_sale_order_delivery_invoice_list_viewmodel.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/main_app.dart';
import 'package:tpos_mobile/src/tpos_apis/models/date_filter_template.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_sale_order.dart';
import 'package:tpos_mobile/fast_sale_order/ui/fast_sale_order_info_page.dart';
import 'package:tpos_mobile/widgets/ModalWaitingWidget.dart';
import 'package:tpos_mobile/widgets/appbar_search_widget.dart';
import 'package:tpos_mobile/widgets/custom_widget.dart';
import 'package:tpos_mobile/widgets/listview_data_error_info_widget.dart';

class FastSaleDeliveryInvoicePage extends StatefulWidget {
  @override
  _FastSaleDeliveryInvoicePageState createState() =>
      _FastSaleDeliveryInvoicePageState();
}

class _FastSaleDeliveryInvoicePageState
    extends State<FastSaleDeliveryInvoicePage> {
  Key refreshIndicatorKey = new Key("refreshIndicator");
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  FastSaleDeliveryInvoiceViewModel viewModel =
      new FastSaleDeliveryInvoiceViewModel();

  bool _isEnableSearch = false;

  @override
  void initState() {
    viewModel.init();
    viewModel.initData();
    super.initState();
    viewModel.dialogMessageController.listen((data) {
      registerDialogToView(context, data,
          scaffState: _scaffoldKey.currentState);
    });
    viewModel.notifyPropertyChangedController.listen((notify) {
      if (mounted) setState(() {});
    });

    viewModel.eventController.listen((event) {
      if (event.eventName == "GO_BACK") {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UIViewModelBase<FastSaleDeliveryInvoiceViewModel>(
      viewModel: viewModel,
      child: new Scaffold(
        backgroundColor: Colors.grey.shade300,
        key: _scaffoldKey,
        endDrawer: _showDrawerRight(context),
        appBar: new AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: _isEnableSearch
                ? AppbarSearchWidget(
                    autoFocus: true,
                    keyword: viewModel.keyword,
                    onTextChange: (value) {
                      viewModel.searchOrderCommand(value);
                    },
                  )
                : Text("HĐ giao hàng"),
          ),
          actions: <Widget>[
            new IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isEnableSearch = !_isEnableSearch;
                });
              },
            ),
            new IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(
                    context, AppRoute.fast_sale_order_add_edit_full,
                    arguments: {});
              },
            ),
            new PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text("Cập nhật trạng thái GH tất cả"),
                  value: "update_delivery_state",
                ),
                PopupMenuItem(
                  child: Text("Cấu hình"),
                  value: "option",
                ),
              ],
              onSelected: (selected) {
                switch (selected) {
                  case "update_delivery_state":
                    viewModel.updateDeliveryState();
                    break;
                  case "option":
                    Navigator.pushNamed(
                      context,
                      AppRoute.setting,
                      arguments: {},
                    );
                    break;
                }
              },
            ),
          ],
        ),
        body: ScopedModelDescendant<FastSaleDeliveryInvoiceViewModel>(
          builder: (_, __, ___) => Column(
            children: <Widget>[
              _showSearchResult(),
              if (viewModel.isSelectEnable) _showSelectMenu(),
              new Expanded(
                child: new Scrollbar(
                  child: _showListFastSaleOrder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Menu khi chọn nhiều item
  Widget _showSelectMenu() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: viewModel.isSelectAll,
            onChanged: (value) => viewModel.isSelectAll = value,
          ),
          Text("${viewModel.selectedCount}"),
          Spacer(),
          PopupMenuButton(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Padding(
                padding: const EdgeInsets.all(7.0),
                child: Row(children: <Widget>[
                  Text("Chọn thao tác"),
                  Icon(Icons.arrow_drop_down),
                ]),
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text("In hóa đơn"),
                value: "PRINT_INVOICE",
              ),
              PopupMenuItem(
                child: Text("In phiếu ship"),
                value: "PRINT_SHIP",
              ),
              PopupMenuItem(
                child: Text("Cập nhật trạng thái giao hàng"),
                value: "REFRESH_DELIVERY_STATUS",
              ),
              PopupMenuItem(
                child: Text("Hủy vận đơn"),
                value: "CANCEL_SHIP",
              ),
              PopupMenuItem(
                child: Text("Hủy hóa đơn"),
                value: "CANCEL_INVOICE",
              ),
            ],
            onSelected: (value) async {
              switch (value) {
                case "PRINT_INVOICE":
                  viewModel.printOrders();
                  break;
                case "PRINT_SHIP":
                  viewModel.printShips();
                  break;
                case "REFRESH_DELIVERY_STATUS":
                  var dialogResult = await showQuestion(
                      context: context,
                      title: "Vui lòng xác nhận",
                      message:
                          "Bạn có muốn cập nhật trạng thái giao hàng các hóa đơn đang chọn?");

                  if (dialogResult == OldDialogResult.Yes) {
                    viewModel.updateDeliveryInfo(null);
                  }
                  break;
                case "CANCEL_SHIP":
                  var dialogResult = await showQuestion(
                      context: context,
                      title: "Vui lòng xác nhận",
                      message: "Phiếu ship sẽ bị hủy. Bạn có đồng ý không?");

                  if (dialogResult == OldDialogResult.Yes) {
                    viewModel.cancelShips(null);
                  }

                  break;
                case "CANCEL_INVOICE":
                  var dialogResult = await showQuestion(
                      context: context,
                      title: "Vui lòng xác nhận",
                      message:
                          "Các hóa đơn được chọn sẽ bị hủy? Bạn có đồng ý không?");

                  if (dialogResult == OldDialogResult.Yes) {
                    viewModel.canncelInvoices(null);
                  }

                  break;
              }
            },
          ),
          const SizedBox(
            width: 10,
          ),
          OutlineButton(
            textColor: Colors.red,
            child: Text("Đóng"),
            onPressed: () {
              viewModel.isSelectEnable = false;
            },
          ),
        ],
      ),
    );
  }

  Widget _showSearchResult() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.grey,
          blurRadius: 1,
        ),
      ]),
      height: 50,
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: DropdownButtonHideUnderline(
              child: new DropdownButton<String>(
                value: viewModel.fastSaleDeliveryInvoiceSort.orderBy,
                onChanged: (String newValue) {
                  setState(() {
                    switch (newValue) {
                      case "DateInvoice":
                        viewModel.selectSoftCommand("DateInvoice");
                        break;
                      case "AmountTotal":
                        viewModel.selectSoftCommand("AmountTotal");
                        break;
                      case "Number":
                        viewModel.selectSoftCommand("Number");
                        break;
                    }
                  });
                },
                items: [
                  DropdownMenuItem<String>(
                      value: "DateInvoice",
                      child: Row(children: <Widget>[
                        Text("Ngày lập"),
                        viewModel.fastSaleDeliveryInvoiceSort.value == "asc" &&
                                viewModel.fastSaleDeliveryInvoiceSort.orderBy ==
                                    "DateInvoice"
                            ? Icon(Icons.arrow_upward)
                            : Icon(Icons.arrow_downward)
                      ])),
                  DropdownMenuItem<String>(
                      value: "AmountTotal",
                      child: Row(children: <Widget>[
                        Text("Tổng tiền"),
                        viewModel.fastSaleDeliveryInvoiceSort.value == "asc" &&
                                viewModel.fastSaleDeliveryInvoiceSort.orderBy ==
                                    "AmountTotal"
                            ? Icon(Icons.arrow_upward)
                            : Icon(Icons.arrow_downward)
                      ])),
                  DropdownMenuItem<String>(
                      value: "Number",
                      child: Row(children: <Widget>[
                        Text("Mã hóa đơn"),
                        viewModel.fastSaleDeliveryInvoiceSort.value == "asc" &&
                                viewModel.fastSaleDeliveryInvoiceSort.orderBy ==
                                    "Number"
                            ? Icon(Icons.arrow_upward)
                            : Icon(Icons.arrow_downward)
                      ])),
                ],
              ),
            ),
          ),
          Expanded(
            child: Text(
              "Σ: ${NumberFormat("###,###,###,###").format(viewModel.totalAmount)}",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0),
              textAlign: TextAlign.center,
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
                  "${viewModel.filterCount ?? 0}",
                  style: TextStyle(color: Colors.white),
                ),
                child: Row(
                  children: <Widget>[
                    Text("Lọc"),
                    Icon(
                      Icons.filter_list,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showListFastSaleOrder() {
    return ScopedModelDescendant<FastSaleDeliveryInvoiceViewModel>(
      builder: (context, _, __) => RefreshIndicator(
          key: refreshIndicatorKey,
          onRefresh: () async {
            return await viewModel.initData();
          },
          child: viewModel.orderCount > 0
              ? _buildListItem()
              : _buildListItemNull()),
    );
  }

  Widget _buildListItem() {
    return ListView.separated(
      padding: EdgeInsets.only(right: 8, left: 8, top: 8, bottom: 8),
      itemCount: viewModel.orderCount + 1,
      separatorBuilder: (ctx, index) {
        if ((index + 1) % viewModel.take == 0) {
          return Container(
            margin: EdgeInsets.only(top: 8, bottom: 8),
            padding: EdgeInsets.all(8),
            color: Colors.blue.shade100,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "Trang ${(index + 1) ~/ viewModel.take + 1}",
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                Text(
                  "${index + 2} -> ${index + 1 + viewModel.take}]",
                  style: const TextStyle(color: Colors.blue),
                ),
              ],
            ),
          );
        }

        return SizedBox(
          height: 8,
        );
      },
      itemBuilder: (context, index) {
        if (index == viewModel.orderCount) if (viewModel.canLoadMore)
          return AppLoadMoreButton(
            label: "Tải thêm...",
            onPressed: viewModel.loadMoreItem,
            onLongPressed: viewModel.loadAllMoreItem,
            isLoading: viewModel.isLoadingMore,
          );
        else
          return SizedBox();

        return _showItem(viewModel.fastSaleDeliveryInvoices[index]);
      },
    );
  }

  Widget _buildListItemNull() {
    if (viewModel.isBusy) return SizedBox();
    return AppListEmptyNotify(
      title: Text(
        "Không có dữ liệu",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      message: Text(viewModel.dataNotifyString),
      actions: <Widget>[
        if (viewModel.filterCount > 0)
          OutlineButton(
            child: Text("Tùy chọn lọc"),
            onPressed: () {
              _scaffoldKey.currentState.openEndDrawer();
            },
          ),
        OutlineButton.icon(
          icon: Icon(Icons.refresh),
          label: Text("Thử lại"),
          onPressed: () {
            viewModel.initData();
          },
        ),
      ],
    );
  }

  Widget _showItem(FastSaleOrder item) {
    var theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          width: 1,
          color: Colors.grey.shade200,
        ),
      ),
      padding: EdgeInsets.only(left: 8, right: 0, bottom: 8),
      child: new ListTile(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              FastSaleOrderInfoPage orderDetailPage = new FastSaleOrderInfoPage(
                order: item,
              );
              return orderDetailPage;
            }),
          );
        },
        leading: viewModel.isSelectEnable
            ? Checkbox(
                value: item.isSelected,
                onChanged: (value) {
                  setState(() {
                    item.isSelected = value;
                  });
                },
              )
            : null,
        contentPadding: EdgeInsets.only(right: 12),
        title: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 10),
          child: Row(
            children: <Widget>[
              new Expanded(
                child: Text(
                  "${item.number}",
                  style: TextStyle(
                    color: getFastSaleOrderStateOption(state: item.state)
                        .textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              new Text(
                "${vietnameseCurrencyFormat(item.cashOnDelivery ?? 0) ?? ""}",
                textAlign: TextAlign.start,
                style: TextStyle(
                  color:
                      getFastSaleOrderStateOption(state: item.state).textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              InkWell(
                child: Icon(Icons.more_horiz),
                onTap: () {
                  _showBottomMenu(context, item);
                },
              ),
            ],
          ),
        ),
        subtitle: Column(
          children: <Widget>[
            new Text(
              "${item.partnerDisplayName}",
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(
              height: 5,
            ),
            new RichText(
              text: TextSpan(
                  text:
                      "${item.carrierName} ${item.trackingRef != null ? "Mã vận đơn: ${item.trackingRef}" : ""}",
                  style: theme.primaryTextTheme.body1
                      .copyWith(color: Colors.black54),
                  children: [
                    TextSpan(
                      text: " (${item.shipPaymentStatus ?? "n/a"})",
                      style: TextStyle(color: Colors.blue),
                    )
                  ]),
            ),
            new SizedBox(
              height: 10,
            ),
            new Row(
              children: <Widget>[
                Text(
                  "${item.showState ?? ""}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: getFastSaleOrderStateOption(state: item.state)
                          .textColor),
                  textAlign: TextAlign.left,
                ),
                Expanded(
                  child: Text(
                    "${DateFormat("dd/MM/yyyy HH:mm").format(item.dateInvoice)}",
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        onLongPress: () {
          if (viewModel.isSelectEnable == false) {
            viewModel.isSelectEnable = true;
          }
          setState(() {
            item.isSelected = true;
          });
        },
      ),
    );
  }

  Widget _showDrawerRight(BuildContext context) {
    var theme = Theme.of(context);
    return AppFilterDrawerContainer(
      onApply: viewModel.applyFilter,
      onRefresh: viewModel.resetFilter,
      child: ScopedModelDescendant<FastSaleDeliveryInvoiceViewModel>(
        builder: (context, _, __) => Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    AppFilterDateTime(
                      fromDate: viewModel.filterFromDate,
                      toDate: viewModel.filterToDate,
                      isSelected: viewModel.isFilterByDate,
                      initDateRange: viewModel.filterDateRange,
                      onSelectChange: (value) =>
                          viewModel.isFilterByDate = value,
                      onFromDateChanged: (value) => viewModel.fromDate = value,
                      onToDateChanged: (value) => viewModel.toDate = value,
                      dateRangeChanged: (value) {
                        viewModel.filterDateRange = value;
                      },
                    ),
                    AppFilterPanel(
                      isSelected: viewModel.isFilterByStatus,
                      title: Text("Lọc theo trạng thái"),
                      onSelectedChange: (value) =>
                          viewModel.isFilterByStatus = value,
                      children: <Widget>[
                        ListView.builder(
                            padding: EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 0, right: 8, top: 8, bottom: 8),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(viewModel.filterStatus?.name ==
                                              viewModel
                                                  .deliveryStatus[index].name
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Text(
                                          "${viewModel.deliveryStatus[index].name} (${viewModel.deliveryStatus[index].count})",
                                        ),
                                      ),
                                      Text(
                                        vietnameseCurrencyFormat(viewModel
                                                .deliveryStatus[index]
                                                ?.totalAmount
                                                ?.toDouble() ??
                                            0),
                                        style:
                                            const TextStyle(color: Colors.red),
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  viewModel.status =
                                      viewModel.deliveryStatus[index];
                                },
                              );
                            },
                            itemCount: viewModel.deliveryStatus?.length ?? 0),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                        "${viewModel.fastSaleDeliveryInvoices?.length ?? 0} / ${viewModel.listCount} HĐ"),
                  ),
                  Text(
                    "${FlutterMoneyFormatter(
                      amount: viewModel.totalAmount,
                      settings: MoneyFormatterSettings(
                          symbol: "đ",
                          thousandSeparator: ".",
                          decimalSeparator: ",",
                          fractionDigits: 0),
                    ).output.nonSymbol}",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBottomMenu(BuildContext context, FastSaleOrder order) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return ListView(
          shrinkWrap: true,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.print),
              title: Text("In phiếu ship"),
              onTap: () {
                Navigator.pop(context);
                viewModel.printShipOrderCommand(order.id);
              },
            ),
            Divider(
              height: 1,
            ),
            ListTile(
              leading: Icon(Icons.print),
              title: Text("In hóa đơn"),
              onTap: () {
                Navigator.pop(context);
                viewModel.printInvoiceCommand(order.id);
              },
            ),
          ],
        );
      },
    );
  }
}
