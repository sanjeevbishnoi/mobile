import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/app_core/ui_base/app_bar_button.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/fast_purchase_order/helper/data_helper.dart';
import 'package:tpos_mobile/fast_purchase_order/helper/screen_helper.dart';
import 'package:tpos_mobile/fast_purchase_order/helper/widget_helper.dart';
import 'package:tpos_mobile/fast_purchase_order/ui/fast_purchase_order_addedit.dart';
import 'package:tpos_mobile/fast_purchase_order/ui/fast_purchase_order_details.dart';
import 'package:tpos_mobile/fast_purchase_order/view_model/fast_purchase_order_viewmodel.dart';
import 'package:tpos_mobile/app_core/helper/string_helper.dart';
import 'package:tpos_mobile/main_app.dart';
import 'package:tpos_mobile/sale_online/viewmodels/app_viewmodel.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_purchase_order.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

class FastPurchaseOrderListPage extends StatefulWidget {
  final bool isRefund;

  @override
  _FastPurchaseOrderListPageState createState() =>
      _FastPurchaseOrderListPageState();
  final FastPurchaseOrderViewModel vm;
  FastPurchaseOrderListPage({this.isRefund = false, this.vm});
}

class _FastPurchaseOrderListPageState extends State<FastPurchaseOrderListPage> {
  FastPurchaseOrderViewModel _viewModel;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  String sortValue;
  double topBarHeight = 100;
  ScrollController _scrollController;
  bool isOpenPickState = false;
  bool isOpenPickTime = false;
  double screenWidth;

  bool isShowSearchField = false;

  TextEditingController searchController = new TextEditingController();

  FocusNode searchFocusNode;

  @override
  void initState() {
    _viewModel =
        widget.vm == null ? locator<FastPurchaseOrderViewModel>() : widget.vm;
    //_viewModel.currentOrder = null;
    _viewModel.isRefund = widget.isRefund;

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _viewModel.init();
    _viewModel.loadData();

    super.initState();
  }

  _scrollListener() {}

  @override
  Widget build(BuildContext context) {
    updateScreenResolution(context);
    /*if (isShowSearchField) {
      FocusScope.of(context).requestFocus(searchFocusNode);
    }*/
    if (screenWidth == null) {
      screenWidth = MediaQuery.of(context).size.width;
    }

    return ScopedModel<FastPurchaseOrderViewModel>(
      model: _viewModel,
      child: Scaffold(
        body: !isTablet(context)
            ? _buildPage()
            : Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(
                    width: getHalfPortraitWidth(context),
                    child: _buildPage(),
                  ),
                  Container(
                    width: 1,
                    color: Colors.grey,
                  ),
                  ScopedModelDescendant<FastPurchaseOrderViewModel>(
                    builder: (context, child, model) {
                      return Expanded(
                        child: FastPurchaseOrderDetails(
                          vm: _viewModel,
                        ),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPage() {
    return ScopedModelDescendant<FastPurchaseOrderViewModel>(
      builder: (context, child, model) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.grey.shade200,
          appBar: _buildAppBar(model),
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    return Stack(
      children: <Widget>[
        _showListFastPurchaseOrders(),
        _showToolBar(),
      ],
    );
  }

  Widget _buildAppBar(FastPurchaseOrderViewModel model) {
    return model.isPickToDeleteMode
        ? AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            title: Text(
              _viewModel.listPickedItem.length.toString(),
              style: TextStyle(color: Colors.green),
            ),
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.green,
                ),
                onPressed: () {
                  setState(() {
                    model.isPickToDeleteMode = false;
                    _viewModel.turnOffEditMode();
                  });
                }),
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  model.deletePickedItem().then(
                    (result) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: Text("$result}"),
                          actions: <Widget>[
                            MaterialButton(
                              child: Text("OK"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
                icon: Icon(
                  Icons.delete_forever,
                  color: Colors.green,
                ),
              ),
            ],
          )
        : AppBar(
            title: !isShowSearchField
                ? Text(
                    "Phiếu ${widget.isRefund ? "trả hàng" : "nhập hàng"}",
                  )
                : Padding(
                    padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                      decoration: BoxDecoration(color: Colors.white),
                      child: TextField(
                        focusNode: searchFocusNode,
                        onTap: () {
                          setState(() {
                            isOpenPickState = false;
                            isOpenPickTime = false;
                          });
                        },
                        autofocus: true,
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: "Tìm kiếm...",
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              searchController.text = "";
                              _viewModel.loadData();
                            },
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                        ),
                        onChanged: (text) {
                          _viewModel.onChangeSearchText(text);
                        },
                      ),
                    ),
                  ),
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  isShowSearchField = !isShowSearchField;
                  isOpenPickState = false;
                  isOpenPickTime = false;

                  setState(() {});
                },
                icon: Icon(Icons.search),
              ),
              AppbarIconButton(
                isEnable: locator<IAppService>()
                    .getWebPermission(PERMISSION_PURCHASE_FAST_ORDER_INSERT),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FastPurchaseOrderAddEditPage(
                        vm: _viewModel,
                      ),
                    ),
                  );
                  setState(() {
                    isOpenPickState = false;
                    isOpenPickTime = false;
                  });
                },
                icon: Icon(Icons.add),
              ),
            ],
          );
  }

  Widget _showToolBar() {
    return Column(
      mainAxisSize: isOpenPickState || isOpenPickTime
          ? MainAxisSize.max
          : MainAxisSize.min,
      children: <Widget>[
        _buildDropDown(),
        _showCustomDivider(),
        isOpenPickState ? _showStateList() : SizedBox(),
        isOpenPickTime ? _showFilterDate() : SizedBox(),
        isOpenPickState || isOpenPickTime
            ? Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isOpenPickTime) {
                        isOpenPickTime = false;
                        _viewModel.onCloseTimeDropDown();
                      } else if (isOpenPickState) {
                        isOpenPickState = false;
                        _viewModel.onCloseStateDropDown();
                      }
                    });
                  },
                  child: Container(
                    color: Colors.black45,
                  ),
                ),
              )
            : SizedBox()
      ],
    );
  }

  Widget _showCustomDivider() {
    return ScopedModelDescendant<FastPurchaseOrderViewModel>(
      builder: (context, child, model) {
        return SizedBox(
          height: 1.5,
          child: Stack(
            children: <Widget>[
              Container(
                height: 1.5,
                color: (model.isFilterByState() && isOpenPickState) ||
                        (model.isFilterByTime() && isOpenPickTime)
                    ? Colors.green
                    : Colors.grey.shade200,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(9.5, 0, 9.5, 0),
                      child: Container(
                        height: 1.5,
                        color: isOpenPickState
                            ? Colors.white
                            : (model.isFilterByTime() && isOpenPickTime)
                                ? Colors.green
                                : Colors.grey.shade200,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(9.5, 0, 9.5, 0),
                      child: Container(
                        height: 1.5,
                        color: isOpenPickTime
                            ? Colors.white
                            : (model.isFilterByState() && isOpenPickState)
                                ? Colors.green
                                : Colors.grey.shade200,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildDropDown() {
    return ScopedModelDescendant<FastPurchaseOrderViewModel>(
      builder: (context, child, model) {
        return Container(
          color: Colors.white,
          height: 50,
          child: Row(
            children: <Widget>[
              Expanded(
                child: _showStateListDropDown(model),
              ),
              Expanded(
                child: _showDateListDropDown(model),
              ),
            ],
          ),
        );
      },
    );
  }

  _showStateListDropDown(FastPurchaseOrderViewModel model) {
    BorderSide borderSide = BorderSide(
        color: model.isFilterByState() ? Colors.green : Colors.grey.shade200,
        width: 1.5);
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 8, 8, isOpenPickState ? 0 : 8),
      child: Container(
        padding: EdgeInsets.only(bottom: isOpenPickState ? 8 : 0),
        decoration: BoxDecoration(
          border: isOpenPickState
              ? Border(right: borderSide, top: borderSide, left: borderSide)
              : Border(),
        ),
        child: Stack(
          children: <Widget>[
            MaterialButton(
              elevation: 0,
              onPressed: () {},
              color:
                  model.isFilterByState() ? Colors.green : Colors.grey.shade100,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Icon(
                Icons.check,
                size: 12,
                color: model.isFilterByState()
                    ? Colors.white
                    : Colors.grey.shade200,
              ),
            ),
            MaterialButton(
              elevation: 0,
              color: isOpenPickState || model.isFilterByState()
                  ? Colors.white
                  : Colors.grey.shade100,
              shape: BeveledRectangleBorder(
                side: BorderSide(
                    width: 0.5,
                    color: model.isFilterByState() && !isOpenPickState
                        ? Colors.green
                        : Colors.transparent),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isOpenPickState ? 0 : 18)),
              ),
              onPressed: () {
                setState(() {
                  isShowSearchField = false;
                  isOpenPickTime = false;
                  isOpenPickState = !isOpenPickState;
                  if (isOpenPickState == false) {
                    _viewModel.onCloseStateDropDown();
                  }
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      model.listFilterStateTemp.length == 0 || isOpenPickState
                          ? "Trạng thái"
                          : model.countState == 1
                              ? model.tempStateFilterName
                              : model.countState == 0
                                  ? "Trạng thái"
                                  : "Có ${model.countState} Trạng thái được áp dụng",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: model.isFilterByState()
                            ? Colors.green
                            : Colors.black,
                      ),
                    ),
                  ),
                  Icon(
                    isOpenPickState
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color:
                        model.isFilterByState() ? Colors.green : Colors.black,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showDateListDropDown(FastPurchaseOrderViewModel model) {
    BorderSide borderSide = BorderSide(
        color: model.isFilterByTime() ? Colors.green : Colors.grey.shade200,
        width: 1.5);
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 8, 8, isOpenPickTime ? 0 : 8),
      child: Container(
        padding: EdgeInsets.only(bottom: isOpenPickTime ? 8 : 0),
        decoration: BoxDecoration(
            border: isOpenPickTime
                ? Border(right: borderSide, top: borderSide, left: borderSide)
                : Border()),
        child: Stack(
          children: <Widget>[
            MaterialButton(
              elevation: 0,
              onPressed: () {},
              color:
                  model.isFilterByTime() ? Colors.green : Colors.grey.shade100,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Icon(
                Icons.check,
                size: 12,
                color: model.isFilterByState()
                    ? Colors.white
                    : Colors.grey.shade200,
              ),
            ),
            MaterialButton(
              elevation: 0,
              color: isOpenPickTime || model.isFilterByTime()
                  ? Colors.white
                  : Colors.grey.shade100,
              shape: BeveledRectangleBorder(
                side: BorderSide(
                    width: 0.5,
                    color: model.isFilterByTime() && !isOpenPickTime
                        ? Colors.green
                        : Colors.transparent),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isOpenPickTime ? 0 : 18),
                ),
              ),
              onPressed: () {
                setState(() {
                  isShowSearchField = false;
                  isOpenPickState = false;
                  isOpenPickTime = !isOpenPickTime;
                  if (!isOpenPickTime) {
                    model.onCloseTimeDropDown();
                  }
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      model.isFilterByTime() && !isOpenPickTime
                          ? model.tempTimeFilterName == "Chọn ngày"
                              ? "${model.tempFromDate.toString().substring(0, 5)} - ${model.tempToDate.toString().substring(0, 5)}"
                              : model.tempTimeFilterName
                          : "Thời gian",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: model.isFilterByTime()
                              ? Colors.green
                              : Colors.black),
                    ),
                  ),
                  Icon(
                    isOpenPickTime
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: model.isFilterByTime() ? Colors.green : Colors.black,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showListFastPurchaseOrders() {
    return Padding(
      padding: EdgeInsets.only(top: 50),
      child: Scrollbar(
        child: ScopedModelDescendant<FastPurchaseOrderViewModel>(
          builder: (context, child, model) {
            if (model.result == "Có dữ liệu") {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _showToolbar(),
                    ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.only(top: 10),
                      shrinkWrap: true,
                      itemCount: model.listForDisplay.length,
                      itemBuilder: (context, index) {
                        FastPurchaseOrder item = model.listForDisplay[index];
                        return _showListItemFastPurchaseOrderItem(item);
                      },
                    ),
                  ],
                ),
              );
            } else if (model.result == "Đang tải dữ liệu") {
              return loadingScreen();
            } else {
              return Scaffold(
                backgroundColor: Colors.grey.shade100,
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.sms,
                        size: 50,
                        color: Colors.grey.shade300,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          model.result,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                      RaisedButton(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              model.isFilterByTime() && model.isFilterByState()
                                  ? "Xóa bộ lọc"
                                  : "Tải lại",
                              style: TextStyle(color: Colors.white),
                            ),
                            Icon(
                              Icons.refresh,
                              color: Colors.white,
                            )
                          ],
                        ),
                        onPressed: () {
                          model.resetFilter();
                        },
                      )
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _showListItemFastPurchaseOrderItem(FastPurchaseOrder item) {
    return ScopedModelDescendant<FastPurchaseOrderViewModel>(
      builder: (context, child, model) {
        return GestureDetector(
          onLongPress: () {
            setState(() {
              model.isPickToDeleteMode = true;
              model.onEditModeItemTap(item.id);
            });
          },
          onTap: () {
            if (model.isPickToDeleteMode) {
              model.onEditModeItemTap(item.id);
            } else {
              model.currentOrder = item;
              if (!isTablet(context)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FastPurchaseOrderDetails(
                      vm: _viewModel,
                    ),
                  ),
                );
              } else {
                setState(() {
                  _viewModel.getDetailsFastPurchaseOrder();
                });
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: getStateColor(item.state).withOpacity(0.5),
                        width: 5,
                      ),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 1,
                          offset: Offset(0, 2),
                        )
                      ],
                      border: Border.all(
                        width: model.isPickToDeleteMode &&
                                model.isExistInListEdit(item.id)
                            ? 2
                            : 1,
                        color: model.isPickToDeleteMode &&
                                model.isExistInListEdit(item.id)
                            ? Colors.green
                            : Colors.white,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        model.isPickToDeleteMode
                            ? IconButton(
                                onPressed: () {
                                  model.onEditModeItemTap(item.id);
                                },
                                icon: model.isExistInListEdit(item.id)
                                    ? Icon(Icons.check_circle)
                                    : Icon(Icons.radio_button_unchecked),
                              )
                            : SizedBox(),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(0),
                                  title: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          "${item.number ?? "Nháp"}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: getStateColor(item.state),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            "${vietnameseCurrencyFormat(item.amountTotal ?? 0) ?? ""}",
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Icon(
                                              Icons.more_horiz,
                                              size: 18,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  subtitle: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          "${item.partnerDisplayName}",
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      item.partnerPhone != null
                                          ? Text(
                                              "${item.partnerPhone}",
                                              style: TextStyle(
                                                color: Colors.black54,
                                              ),
                                            )
                                          : SizedBox(),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 6, 16, 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: Container(
                                            height: 8,
                                            width: 8,
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color:
                                                      getStateColor(item.state)
                                                          .withOpacity(0.8),
                                                  blurRadius: 8,
                                                  offset: Offset(0, 0),
                                                )
                                              ],
                                              color: getStateColor(item.state),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${getStateVietnamese(item.state)}",
                                          style: TextStyle(
                                            color: getStateColor(item.state),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "${DateFormat("dd/MM/yyyy  HH:mm").format(item.dateInvoice)}",
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _showToolbar() {
    return ScopedModelDescendant<FastPurchaseOrderViewModel>(
      builder: (context, child, model) {
        return Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              DropdownButtonHideUnderline(
                child: DropdownButton(
                  value: model.fastPurchaseOrderSort.field,
                  onChanged: (value) {
                    model.onSortChange(value);
                  },
                  items: [
                    _showDropDownMenuItem("DateInvoice"),
                    _showDropDownMenuItem("AmountTotal"),
                    _showDropDownMenuItem("Number"),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  "Σ: ${vietnameseCurrencyFormat(model.totalAmount)}",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              /* InkWell(
                onTap: () {},
                child: Row(
                  children: <Widget>[
                    Text(
                      "Lọc",
                    ),
                    Badge(
                      badgeContent: Text(
                        "1",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      child: Icon(
                        Icons.filter_list,
                      ),
                    )
                  ],
                ),
              ),*/
            ],
          ),
        );
      },
    );
  }

  DropdownMenuItem _showDropDownMenuItem(String value) {
    return DropdownMenuItem<String>(
        value: value,
        child: Row(children: <Widget>[
          Text(getSortVietnamese(value)),
          _viewModel.fastPurchaseOrderSort.dir == "asc" &&
                  _viewModel.fastPurchaseOrderSort.field == value
              ? Icon(Icons.arrow_upward)
              : Icon(Icons.arrow_downward)
        ]));
  }

  Widget _showStateList() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: _buildCustomBtn(
                      text: "Đã thanh toán",
                      callBack: () {
                        _viewModel.onTapStateBtn("Đã thanh toán");
                      }),
                ),
                Expanded(
                  child: _buildCustomBtn(
                      text: "Xác nhận",
                      callBack: () {
                        _viewModel.onTapStateBtn("Xác nhận");
                      }),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: _buildCustomBtn(
                      text: "Hủy bỏ",
                      callBack: () {
                        _viewModel.onTapStateBtn("Hủy bỏ");
                      }),
                ),
                Expanded(
                  child: _buildCustomBtn(
                      text: "Nháp",
                      callBack: () {
                        _viewModel.onTapStateBtn("Nháp");
                      }),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: MaterialButton(
                      onPressed: () {
                        _viewModel.resetFilterState();
                      },
                      child: Text(
                        "Thiết lập lại",
                        style: TextStyle(color: Colors.green),
                      ),
                      color: Colors.white,
                      shape: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green)),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: MaterialButton(
                      onPressed: () {
                        _viewModel.loadData();
                        setState(() {
                          isOpenPickState = false;
                        });
                      },
                      child: Text(
                        "Áp dụng",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.green,
                      shape: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _showFilterDate() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: _buildCustomBtn(
                      text: "Hôm nay",
                      callBack: () {
                        _viewModel.onFilterDateTap("Hôm nay");
                      }),
                ),
                Expanded(
                  child: _buildCustomBtn(
                      text: "Hôm qua",
                      callBack: () {
                        _viewModel.onFilterDateTap("Hôm qua");
                      }),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: _buildCustomBtn(
                      text: "30 ngày gần nhất",
                      callBack: () {
                        _viewModel.onFilterDateTap("30 ngày gần nhất");
                      }),
                ),
                Expanded(
                  child: _buildCustomBtn(
                      text: "7 ngày gần nhất",
                      callBack: () {
                        _viewModel.onFilterDateTap("7 ngày gần nhất");
                      }),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: ScopedModelDescendant<FastPurchaseOrderViewModel>(
                    builder: (context, child, model) {
                      bool active = model.filterDateTemp.name == "Chọn ngày";
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          children: <Widget>[
                            MaterialButton(
                              onPressed: () {},
                              elevation: 0,
                              color: Colors.green,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                            MaterialButton(
                              elevation: 0,
                              color:
                                  active ? Colors.white : Colors.grey.shade100,
                              shape: BeveledRectangleBorder(
                                side: BorderSide(
                                    width: 0.5,
                                    color: active
                                        ? Colors.green
                                        : Colors.transparent),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(active ? 18 : 0)),
                              ),
                              child: active
                                  ? Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          "${getDate(model.filterDateTemp.fromDate)}",
                                          style: TextStyle(color: Colors.green),
                                        ),
                                        Icon(
                                          Icons.arrow_forward,
                                          color: Colors.green,
                                        ),
                                        Text(
                                          "${getDate(model.filterDateTemp.toDate)}",
                                          style: TextStyle(color: Colors.green),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[Text("Chọn ngày")],
                                    ),
                              onPressed: () async {
                                final List<DateTime> picked =
                                    await DateRagePicker.showDatePicker(
                                        context: context,
                                        initialFirstDate: _viewModel
                                                    .filterDateTemp.fromDate !=
                                                null
                                            ? _viewModel.filterDateTemp.fromDate
                                            : new DateTime.now(),
                                        initialLastDate: _viewModel
                                                    .filterDateTemp.toDate !=
                                                null
                                            ? _viewModel.filterDateTemp.toDate
                                            : (new DateTime.now())
                                                .add(new Duration(days: 7)),
                                        firstDate: new DateTime(2015),
                                        lastDate: new DateTime.now());

                                if (picked != null /*&& picked.length == 2*/) {
                                  _viewModel.onPickDateFilter(
                                    fromDate: picked[0],
                                    toDate: picked.length == 2
                                        ? picked[1]
                                        : picked[0],
                                  );
                                  print(picked);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
            Text(
              "${getDate(_viewModel.filterDateTemp.fromDate) ?? ""} - ${getDate(_viewModel.filterDateTemp.toDate) ?? ""}",
              style: TextStyle(color: Colors.green),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: MaterialButton(
                      onPressed: () {
                        _viewModel.resetFilterTime();
                      },
                      child: Text(
                        "Thiết lập lại",
                        style: TextStyle(color: Colors.green),
                      ),
                      color: Colors.white,
                      shape: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green)),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                    child: MaterialButton(
                      onPressed: () {
                        _viewModel.loadData();
                        setState(() {
                          isOpenPickTime = false;
                        });
                      },
                      child: Text(
                        "Áp dụng",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.green,
                      shape: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomBtn({String text, VoidCallback callBack}) {
    return ScopedModelDescendant<FastPurchaseOrderViewModel>(
      builder: (context, child, model) {
        bool active = model.isInExistInFilterStateList(text) ||
            model.isInExistInFilterDate(text);
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Stack(
            children: <Widget>[
              MaterialButton(
                elevation: 0,
                onPressed: () {},
                color: active ? Colors.green : Colors.grey.shade200,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Icon(
                  Icons.check,
                  size: 12,
                  color: active ? Colors.white : Colors.grey.shade200,
                ),
              ),
              MaterialButton(
                onPressed: () {
                  callBack();
                },
                elevation: 0,
                color: active ? Colors.white : Colors.grey.shade200,
                shape: BeveledRectangleBorder(
                  side: BorderSide(
                      width: 0.5,
                      color: active ? Colors.green : Colors.transparent),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(active ? 18 : 0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      text,
                      style: TextStyle(
                        color: active ? Colors.green : Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
