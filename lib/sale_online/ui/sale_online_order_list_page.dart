/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 7/4/19 6:25 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 7/4/19 10:58 AM
 *
 */

import 'package:auto_size_text/auto_size_text.dart';
import 'package:badges/badges.dart';

///Trang hiển thị Danh sách đơn hàng
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/app_core/template_ui/app_filter_datetime.dart';
import 'package:tpos_mobile/app_core/template_ui/app_filter_drawer.dart';
import 'package:tpos_mobile/app_core/template_ui/app_filter_object.dart';
import 'package:tpos_mobile/app_core/template_ui/app_filter_panel.dart';
import 'package:tpos_mobile/app_core/template_ui/app_list_empty_notify.dart';
import 'package:tpos_mobile/fast_sale_order/ui/fast_sale_order_quick_create_from_sale_online_order_page.dart';
import 'package:tpos_mobile/helpers/app_helper.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/helpers/messenger_helper.dart';
import 'package:tpos_mobile/helpers/ui_help.dart';
import 'package:tpos_mobile/main_app.dart';
import 'package:tpos_mobile/sale_online/ui/partner_search_page.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_channel_list_page.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_edit_order_page.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_live_campaign_select_page.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_order_info_page.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_order_status_list_page.dart';
import 'package:tpos_mobile/sale_online/viewmodels/sale_online_order_list_viewmodel.dart';
import 'package:tpos_mobile/src/tpos_apis/models/status_extra.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';
import 'package:tpos_mobile/widgets/custom_widget.dart';
import 'package:tpos_mobile/widgets/listview_data_error_info_widget.dart';

class SaleOnlineOrderListPage extends StatefulWidget {
  static const routeName = "home/sale_online_order/list";
  final String postId;
  final Partner partner;
  SaleOnlineOrderListPage({this.postId, this.partner});

  @override
  _SaleOnlineOrderListPageState createState() =>
      _SaleOnlineOrderListPageState();
}

class _SaleOnlineOrderListPageState extends State<SaleOnlineOrderListPage> {
  final orderViewModel = new SaleOnlineOrderListViewModel();
  Key refreshIndicatorKey = new Key("refreshIndicator");
  bool _isSearchEnable = false;
  @override
  void initState() {
    orderViewModel.init(filterPartner: widget.partner, postId: widget.postId);
    super.initState();
    orderViewModel.initCommand();

    orderViewModel.notifyPropertyChangedController.mergeWith([
      orderViewModel.filterViewModel.notifyPropertyChangedController
    ]).listen((data) {
      if (mounted) setState(() {});
    });

    orderViewModel.dialogMessageController.mergeWith([
      orderViewModel.filterViewModel.dialogMessageController
    ]).listen((data) {
      registerDialogToView(context, data,
          scaffState: _scaffoldKey.currentState);
    });

    orderViewModel.eventController.listen((event) {
      if (event.eventName == SaleOnlineOrderListViewModel.EVENT_GOBACK) {
        Navigator.pop(context);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    orderViewModel.dispose();
    super.dispose();
  }

  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ScopedModel<SaleOnlineOrderListViewModel>(
      model: orderViewModel,
      child: ViewBaseWidget(
        isBusyStream: orderViewModel.isBusyController,
        child: new Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.grey.shade200,
            endDrawer: _buildFilterPanel(),
            appBar: widget.partner == null
                ? new AppBar(
                    title: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: _isSearchEnable
                          ? AppbarSearchWidget(
                              autoFocus: true,
                              keyword: orderViewModel.keyword,
                              onTextChange: (value) {
                                orderViewModel.searchOrderCommand(value);
                              },
                            )
                          : Text("Đơn hàng bán online"),
                    ),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          setState(() {
                            _isSearchEnable = !_isSearchEnable;
                          });
                        },
                      )
                    ],
                  )
                : null,
            body: ScopedModelDescendant<SaleOnlineOrderListViewModel>(
              builder: (context, child, index) => Column(
                children: <Widget>[
                  _showFilterPanel(),
                  if (orderViewModel.isSelectEnable) _showSelectedPanel(),
                  Expanded(
                    child: _showListOrder(),
                  ),
                  if (orderViewModel.isFetchingOrder &&
                      orderViewModel.isBusy == false)
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: <Widget>[
                          CircularProgressIndicator(),
                          SizedBox(
                            width: 20,
                          ),
                          Text(orderViewModel.tempOrders.length.toString()),
                          SizedBox(
                            width: 20,
                          ),
                          Text("Vẫn đang tải thêm..."),
                        ],
                      ),
                    ),
                ],
              ),
            )),
      ),
    );
  }

  Widget _buildFilterPanel() {
    return ScopedModelDescendant<SaleOnlineOrderListViewModel>(
      builder: (_, __, ___) => AppFilterDrawerContainer(
        closeWhenConfirm: true,
        onApply: orderViewModel.initCommand,
        onRefresh: widget.partner != null || widget.postId != null
            ? null
            : orderViewModel.resetFilter,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              AppFilterDateTime(
                isSelected: orderViewModel.isFilterByDate,
                initDateRange: orderViewModel.filterDateRange,
                onSelectChange: (value) {
                  orderViewModel.isFilterByDate = value;
                },
                fromDate: orderViewModel.filterFromDate,
                toDate: orderViewModel.filterToDate,
                dateRangeChanged: (value) {
                  orderViewModel.filterDateRange = value;
                },
                onFromDateChanged: (value) {
                  orderViewModel.filterFromDate = value;
                },
                onToDateChanged: (value) {
                  orderViewModel.filterToDate = value;
                },
              ),
              AppFilterPanel(
                  title: Text("Lọc theo trạng thái"),
                  isSelected: orderViewModel.isFilterByStatus,
                  onSelectedChange: (bool value) =>
                      orderViewModel.isFilterByStatus = value,
                  children: <Widget>[
                    Builder(
                      builder: (context) {
                        if (orderViewModel.filterStatusList == null) {
                          {
                            orderViewModel.loadFilterStatusList();
                          }
                        }

                        return Wrap(
                          runSpacing: 0,
                          runAlignment: WrapAlignment.start,
                          spacing: 1,
                          children: orderViewModel.filterStatusList
                                  ?.map(
                                    (f) => FilterChip(
                                      label: Text(
                                        f.text,
                                        style: TextStyle(
                                            color: f.selected
                                                ? Colors.white
                                                : Colors.grey),
                                      ),
                                      selected: f.selected,
                                      selectedColor: Colors.green,
                                      onSelected: (bool value) {
                                        setState(() {
                                          f.selected = value;
                                        });
                                      },
                                    ),
                                  )
                                  ?.toList() ??
                              new List<Widget>(),
                        );
                      },
                    )
                  ]),
              AppFilterObject(
                title: Text("Lọc theo chiến dịch live"),
                isSelected: orderViewModel.isFilterByLiveCampaign,
                onSelectChange: (bool value) =>
                    orderViewModel.isFilterByLiveCampaign = value,
                hint: "Chọn chiến dịch",
                content: orderViewModel.filterLiveCampaign?.name,
                onSelect: () async {
                  var campaign = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SaleOnlineLiveCampaignSelectPage(),
                    ),
                  );

                  if (campaign != null) {
                    orderViewModel.filterLiveCampaign = campaign;
                  }
                },
              ),
              AppFilterObject(
                title: Text("Lọc theo kênh"),
                isSelected: orderViewModel.isFilterByCrmTeam,
                hint: "Chọn kênh bán",
                content: orderViewModel.filterCrmTeam?.name,
                onSelectChange: (bool value) =>
                    orderViewModel.isFilterByCrmTeam = value,
                onSelect: () async {
                  var crmTeam = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SaleOnlineChannelListPage(
                        isSearchMode: true,
                      ),
                    ),
                  );

                  if (crmTeam != null) {
                    orderViewModel.filterCrmTeam = crmTeam;
                  }
                },
              ),
              AppFilterObject(
                title: Text("Lọc theo khách hàng"),
                isSelected: orderViewModel.isFilterByPartner,
                hint: "Chọn khách hàng",
                content: orderViewModel.filterPartner?.name,
                isEnable: widget.partner == null,
                onSelectChange: (bool value) {
                  orderViewModel.isFilterByPartner = value;
                },
                onSelect: () async {
                  var partner = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PartnerSearchPage()));

                  if (partner != null) {
                    orderViewModel.filterPartner = partner;
                  }
                },
              ),
              AppFilterPanel(
                title: Text("Lọc theo id bài LIVE"),
                isSelected: orderViewModel.isFilterByPostId,
                onSelectedChange: (bool value) =>
                    orderViewModel.isFilterByPostId = value,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller:
                          TextEditingController(text: orderViewModel.postId),
                      onChanged: (text) {
                        orderViewModel.filterPostId = text;
                      },
                    ),
                  ),
                ],
                isEnable: widget.postId == null,
              )
            ],
          ),
        ),
        bottomContent: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(child: Text("${orderViewModel.itemCount} ĐH")),
              Text(
                  "Tổng: ${vietnameseCurrencyFormat(orderViewModel.amountTotal)}")
            ],
          ),
        ),
      ),
    );
  }

  Widget _showFilterPanel() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 1,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: EdgeInsets.only(left: 10),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(Icons.sort_by_alpha),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              hint: Text("Sắp xếp"),
              value:
                  "${orderViewModel.filterViewModel.sort?.field ?? "DateCreated"}_${orderViewModel.filterViewModel.sort?.dir ?? "desc"}",
              onChanged: (String value) async {
                await orderViewModel.filterViewModel.setSortCommand(value);
                await orderViewModel.amplyFilterCommand();
              },
              items: [
                DropdownMenuItem<String>(
                  value: "DateCreated_desc",
                  child: Text("Ngày (Mới đến cũ)"),
                ),
                DropdownMenuItem<String>(
                  value: "DateCreated_asc",
                  child: Text("Ngày (Cũ  tới mới)"),
                ),
                DropdownMenuItem<String>(
                  value: "SessionIndex_asc",
                  child: Text("STT (thấp đến cao)"),
                ),
                DropdownMenuItem<String>(
                  value: "SessionIndex_desc",
                  child: Text("STT (Cao xuống thấp)"),
                )
              ],
            ),
          ),
          Expanded(
            child: Text(""),
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
                  "${orderViewModel.filterCount ?? 0}",
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

  Widget _showListOrder() {
    return RefreshIndicator(
      key: refreshIndicatorKey,
      onRefresh: () async {
        return await orderViewModel.refreshOrdersCommand();
      },
      child: StreamBuilder<List<SaleOnlineOrder>>(
          stream: orderViewModel.ordersObservable,
          initialData: orderViewModel.orders,
          builder: (context, ordersSnapshot) {
            if (ordersSnapshot.hasError) {
              return ListViewDataErrorInfoWidget(
                errorMessage:
                    "Đã xảy ra lỗi! \n" + ordersSnapshot.error.toString(),
              );
            }

            if (ordersSnapshot.hasData == false) {
              return SizedBox();
            }

            if ((orderViewModel.orders?.length ?? 0) == 0 &&
                orderViewModel.isBusy == false) {
              return AppListEmptyNotifyDefault(
                onRefresh: orderViewModel.initCommand,
              );
            }

            return Scrollbar(
              child: ListView.separated(
                padding: EdgeInsets.only(
                  left: 8,
                  top: 8,
                  right: 8,
                  bottom: 8,
                ),
                itemCount: (ordersSnapshot.data?.length ?? 0),
                separatorBuilder: (context, position) {
                  return SizedBox(
                    height: 8,
                  );
                },
                itemBuilder: (context, position) {
                  return SaleOnlineOrderItemView(
                    item: ordersSnapshot.data[position],
                    onLongPress: () {
                      orderViewModel
                          .enableSelectedCommand(ordersSnapshot.data[position]);
                    },
                  );
                },
              ),
            );
          }),
    );
  }

  // Dc chọn
  Widget _showSelectedPanel() {
    return Container(
      child: Row(
        children: <Widget>[
          Checkbox(
            onChanged: (bool value) {
              orderViewModel.selectAllItemCommand();
            },
            value: orderViewModel.isCheckAll,
          ),
          new Expanded(child: Text("(${orderViewModel.selectedItemCount})")),
          new Padding(
            padding: const EdgeInsets.only(right: 3.0),
            child: SizedBox(
              width: 45,
              child: OutlineButton(
                textColor: Colors.blue,
                child: Text(
                  "In",
                ),
                onPressed: () async {
                  var showConfirmResult = await showQuestion(
                      context: context,
                      title: "Xác nhận",
                      message: "In toàn bộ phiếu đã chọn");

                  if (showConfirmResult == OldDialogResult.Yes) {
                    orderViewModel.printAllSelect();
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: RaisedButton(
              textColor: Colors.white,
              child: AutoSizeText(
                "Tạo HĐ\nSP mặc định",
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        fastSaleOrderQuickCreateFromSaleOnlineOrderPage(
                      saleOnlineIds: orderViewModel.selectedIds,
                    ),
                  ),
                );

                orderViewModel.updateAfterCreateInvoiceCommand();
              },
            ),
          ),
          new Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SizedBox(
              width: 70,
              child: RaisedButton(
                padding: EdgeInsets.all(5),
                child: Text(
                  "Tạo HĐ",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if (orderViewModel.selectedIds == null ||
                      orderViewModel.selectedIds.length == 0) {
                    showWarning(
                        context: context,
                        title: "Chưa chọn đơn hàng nào!",
                        message:
                            "Vui lòng chọn 1 hoặc nhiều đơn hàng có cùng tên facebook để tiếp tục");
                    return;
                  }

                  if (orderViewModel.selectedOrders.any((f) =>
                      f.facebookAsuid !=
                      orderViewModel.selectedOrders.first.facebookAsuid)) {
                    showWarning(
                        context: context,
                        title: "Các đơn đã chọn không cùng 1 facebook",
                        message:
                            "Vui lòng chọn các đơn hàng có cùng tên facebook");
                    return;
                  }

                  await Navigator.pushNamed(
                    context,
                    AppRoute.fast_sale_order_add_edit_full,
                    arguments: {
                      "saleOnlineIds": orderViewModel.selectedIds,
                      "partnerId":
                          orderViewModel.selectedOrders?.first?.partnerId ??
                              null,
                      "onEditCompleted": (order) {
                        if (order != null) {
                          orderViewModel.updateAfterCreateInvoiceCommand();
                        }
                      }
                    },
                  );
                  orderViewModel.unSelectAllCommand();
                },
              ),
            ),
          ),
          if (orderViewModel.selectedItemCount == 0)
            new SizedBox(
                width: 40,
                child: IconButton(
                    icon: Icon(Icons.close),
                    color: Colors.red,
                    onPressed: () {
                      orderViewModel.closeSelectPanelCommand();
                    })),
        ],
      ),
    );
  }

  void showDialogProducts(
      List<SaleOnlineOrderDetail> items, BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(0),
            title: Text("Sản phẩm trong đơn hàng"),
            content: Container(
              width: 1000,
              padding: EdgeInsets.all(12),
              child: Scrollbar(
                child: ListView.separated(
                    shrinkWrap: false,
                    itemCount: items?.length ?? 0,
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    itemBuilder: (context, index) {
                      return new Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                "${items[index].productName}",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                  "${NumberFormat("###,###,###,###", "en_US").format(items[index].quantity ?? "")} (${items[index].uomName})"),
                              Text(
                                " x ${NumberFormat("###,###,###,###", "en_US").format(items[index].price ?? "")}",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "${NumberFormat("###,###,###,###", "en_US").format((items[index].price ?? 0) * (items[index].quantity ?? 0) ?? "")}",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("ĐÓNG"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }
}

class SaleOnlineOrderListPageArgument {
  String postId;

  SaleOnlineOrderListPageArgument({this.postId});
}

class SaleOnlineOrderItemView extends StatelessWidget {
  final SaleOnlineOrder item;
  final VoidCallback onLongPress;
  final VoidCallback onPress;
  final VoidCallback onMenuPress;
  final VoidCallback onSelect;
  final Key key;
  SaleOnlineOrderItemView(
      {@required this.item,
      this.key,
      this.onLongPress,
      this.onPress,
      this.onMenuPress,
      this.onSelect})
      : super(key: key);

  void _showItemMenu(BuildContext context) {
    var vm = ScopedModel.of<SaleOnlineOrderListViewModel>(context);
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (ctx) {
        return BottomSheet(
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            borderSide: BorderSide(width: 0),
          ),
          onClosing: () {},
          builder: (context) => ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.print),
                title: Text("In phiếu"),
                onTap: () {
                  Navigator.pop(context);
                  vm.printSaleOnlineTag(item);
                },
              ),
              ListTile(
                leading: Icon(Icons.remove_red_eye),
                title: Text("Xem thông tin đơn hàng"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (ctx) => SaleOnlineOrderInfoPage(
                                orderId: item.id,
                              )));
                },
              ),
              ListTile(
                leading: Icon(Icons.add),
                title: Text("Tạo hóa đơn giao hàng"),
                onTap: () {
                  Navigator.pop(context);
                  vm.enableSelectedCommand(item);
                },
              ),
              if (item.telephone != null && item.telephone != "")
                ListTile(
                  leading: Icon(Icons.call),
                  title: Text(
                    "Gọi cho số: ${item.telephone}",
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    urlLauch(
                      "tel: ${item.telephone}",
                    );
                  },
                ),
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: Text(
                  "Xóa",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  var dialogResult = await showQuestion(
                      context: context,
                      title: "Xác nhận",
                      message: "Bạn muốn xóa đơn hàng ${item.code}");

                  if (dialogResult == OldDialogResult.Yes) {
                    vm.deleteOrder(item);

                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDialogProducts(
      List<SaleOnlineOrderDetail> items, BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(0),
            title: Text("Sản phẩm trong đơn hàng"),
            content: Container(
              width: 1000,
              padding: EdgeInsets.all(12),
              child: Scrollbar(
                child: ListView.separated(
                    shrinkWrap: false,
                    itemCount: items?.length ?? 0,
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    itemBuilder: (context, index) {
                      return new Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                "${items[index].productName}",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                  "${NumberFormat("###,###,###,###", "en_US").format(items[index].quantity ?? "")} (${items[index].uomName})"),
                              Text(
                                " x ${NumberFormat("###,###,###,###", "en_US").format(items[index].price ?? "")}",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "${NumberFormat("###,###,###,###", "en_US").format((items[index].price ?? 0) * (items[index].quantity ?? 0) ?? "")}",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("ĐÓNG"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        splashColor: Colors.grey,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200, width: 0.5),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white),
          padding: EdgeInsets.only(bottom: 8, top: 8, left: 8),
          child: ScopedModelDescendant<SaleOnlineOrderListViewModel>(
            builder: (context, child, vm) => Row(
              children: <Widget>[
                if (vm.isSelectEnable)
                  Checkbox(
                    value: item.checked,
                    onChanged: (value) {
                      vm.changeCheckItem(item);
                    },
                  ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Tên
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "${item.sessionIndex != null && item.sessionIndex != 0 ? "#${item.sessionIndex}. " : ""}${item.code}",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: getSaleOnlineOrderColor(item.statusText),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            "${item.name}",
                            style: TextStyle(
                              color: getSaleOnlineOrderColor(item.statusText),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 30,
                            child: new IconButton(
                              padding:
                                  EdgeInsets.only(left: 0, top: 0, bottom: 0),
                              icon: Icon(Icons.more_horiz),
                              onPressed: () {
                                _showItemMenu(context);
                              },
                            ),
                          )
                        ],
                      ),
                      // Địa chỉ, số điện thoại
                      RichText(
                        maxLines: 2,
                        text: TextSpan(
                          text: "${item.telephone ?? " <Chưa có SĐT>"} |",
                          style: const TextStyle(color: Colors.black87),
                          children: [
                            TextSpan(
                              text: "${item.address ?? " <Chưa có địa chỉ>"}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "${DateFormat("dd/MM/yyyy HH:mm", "en_US").format(item.dateCreated)}",
                      ),

                      Divider(
                        color: Colors.grey.shade200,
                        height: 1,
                      ),
                      //Trạng thái đơn hàng
                      Row(
                        children: <Widget>[
                          InkWell(
                            child: Padding(
                              padding:
                                  EdgeInsets.only(left: 8, top: 8, right: 8),
                              child: Row(
                                children: <Widget>[
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: getSaleOnlineOrderColor(
                                                  item.statusText)
                                              .withOpacity(0.8),
                                          blurRadius: 8,
                                          offset: Offset(0, 0),
                                        )
                                      ],
                                      color: getSaleOnlineOrderColor(
                                          item.statusText),
                                      shape: BoxShape.circle,
                                    ),
                                    child: SizedBox(
                                      height: 8,
                                      width: 8,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    item.statusText,
                                    style: TextStyle(
                                        color: getSaleOnlineOrderColor(
                                            item.statusText)),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () async {
                              StatusExtra status = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  contentPadding: EdgeInsets.all(0),
                                  content: SaleOnlineOrderStatusListPage(
                                    isSearchMode: true,
                                    isCloseWhenSelect: true,
                                    isDialogMode: true,
                                    selectedValue: item.statusText,
                                  ),
                                ),
                              );

                              if (status != null) {
                                vm.changeStatus(item, status.name);
                              }

//                              Navigator.push(
//                                context,
//                                MaterialPageRoute(
//                                  builder: (context) =>
//                                      _SaleOnlineOrderStatusListPage(),
//                                ),
//                              );
                            },
                          ),
                          InkWell(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8, top: 8, right: 8),
                              child: Text(
                                "${NumberFormat("###,###,###").format(item.totalQuantity ?? 0)} Sản phẩm",
                                style: const TextStyle(color: Colors.blue),
                              ),
                            ),
                            onTap: () async {
                              vm.onIsBusyAdd(true);
                              //try {
                              var products = await vm.getProductById(item);
                              _showDialogProducts(products, context);
                              //} catch (e, s) {
                              //print(s);
                              //}
                              vm.onIsBusyAdd(false);
                            },
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                "${vietnameseCurrencyFormat(item.totalAmount)}",
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () async {
          // show Edit
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              SaleOnlineEditOrderPage orderDetailPage =
                  new SaleOnlineEditOrderPage(
                orderId: item.id,
              );
              return orderDetailPage;
            }),
          );
        },
        onLongPress: onLongPress);
  }
}
