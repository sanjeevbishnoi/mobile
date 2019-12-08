import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tpos_mobile/app_core/template_ui/app_filter_datetime.dart';
import 'package:tpos_mobile/app_core/template_ui/app_filter_drawer.dart';
import 'package:tpos_mobile/app_core/template_ui/app_filter_panel.dart';
import 'package:tpos_mobile/app_core/template_ui/empty_data_widget.dart';
import 'package:tpos_mobile/app_core/helper/string_helper.dart';
import 'package:tpos_mobile/pos_order/models/pos_order.dart';
import 'package:tpos_mobile/pos_order/ui/pos_order_info_page.dart';
import 'package:tpos_mobile/pos_order/viewmodels/pos_order_list_viewmodel.dart';
import 'package:tpos_mobile/pos_order/pos_order_state.dart';
import 'package:tpos_mobile/app_core/template_ui/reload_list_page.dart';
import 'package:tpos_mobile/app_core/ui_base/view_base.dart';
import 'package:tpos_mobile/services/dialog_service.dart';
import 'package:tpos_mobile/widgets/appbar_search_widget.dart';
import '../../app_service_locator.dart';
import '../../app_core/template_ui/creation_aware_list_item.dart';

class PosOrderListPage extends StatefulWidget {
  const PosOrderListPage({Key key}) : super(key: key);

  @override
  _PosOrderListPageState createState() => _PosOrderListPageState();
}

class _PosOrderListPageState extends State<PosOrderListPage> {
  bool _checkSearch = false;
  var _viewModel = locator<PosOrderListViewModel>();
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget buildAppBar() {
    return new AppBar(
      title: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0, top: 7, bottom: 7),
        child: _checkSearch
            ? AppbarSearchWidget(
                autoFocus: true,
                keyword: _viewModel.keyword,
                onTextChange: (text) async {
                  _viewModel.setKeyword(text);
                },
              )
            : Text("Đơn hàng POS"),
      ),
      actions: <Widget>[
        new IconButton(
          icon: new Icon(Icons.search),
          onPressed: () async {
            setState(() {
              _checkSearch = !_checkSearch;
            });
          },
        ),
      ],
    );
  }

  Widget _builFilterPanel() {
    return AppFilterDrawerContainer(
      onRefresh: () {
        _viewModel.resetFilter();
      },
      closeWhenConfirm: true,
      onApply: () {
        _viewModel.applyFilter();
      },
      child: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppFilterDateTime(
                  isSelected: _viewModel.isFilterByDate,
                  initDateRange: _viewModel.filterDateRange,
                  onSelectChange: (value) {
                    _viewModel.isFilterByDate = value;
                  },
                  toDate: _viewModel.filterToDate,
                  fromDate: _viewModel.filterFromDate,
                  dateRangeChanged: (value) {
                    _viewModel.filterDateRange = value;
                  },
                  onFromDateChanged: (value) {
                    _viewModel.filterFromDate = value;
                  },
                  onToDateChanged: (value) {
                    _viewModel.filterToDate = value;
                  },
                ),
                AppFilterPanel(
                  isEnable: true,
                  isSelected: _viewModel.isFilterByStatus,
                  onSelectedChange: (bool value) =>
                      _viewModel.isFilterByStatus = value,
                  title: Text("Lọc theo trạng thái"),
                  children: <Widget>[
                    Builder(
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Wrap(
                            runSpacing: 0,
                            runAlignment: WrapAlignment.start,
                            spacing: 5,
                            children: _viewModel.filterStatusList
                                    ?.map(
                                      (f) => FilterChip(
                                        label: Text(
                                          f.description,
                                          style: TextStyle(
                                              color: f.isSelected
                                                  ? Colors.white
                                                  : Colors.grey),
                                        ),
                                        onSelected: (value) {
                                          setState(() {
                                            f.isSelected = value;
                                          });
                                        },
                                        selected: f.isSelected,
                                        selectedColor: f.textColor,
                                      ),
                                    )
                                    ?.toList() ??
                                new List<Widget>(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("${_viewModel.max ?? 0} hóa đơn"),
/*                Text(
                  "Tổng tiền: ${NumberFormat("###,###,###,###").format(
                    _viewModel.max,
                  )}",
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0),
                  textAlign: TextAlign.center,
                ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }

  Key refreshIndicatorKey = new Key("refreshIndicator");

  @override
  Widget build(BuildContext context) {
    return ViewBase<PosOrderListViewModel>(
      model: _viewModel,
      builder: (context, model, sizingInformation) => Scaffold(
        backgroundColor: Colors.grey.shade200,
        key: _scaffoldKey,
        appBar: buildAppBar(),
        endDrawer: _builFilterPanel(),
        body: Container(
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: new GestureDetector(
                    onTap: () {
                      _scaffoldKey.currentState.openEndDrawer();
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(FontAwesomeIcons.sort),
                        Text("Sắp xếp:  "),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _viewModel.posOrderSort.orderBy,
                            onChanged: (String newValue) {
                              switch (newValue) {
                                case "DateOrder":
                                  _viewModel.selectSoftCommand("DateOrder");
                                  break;
                                case "AmountTotal":
                                  _viewModel.selectSoftCommand("AmountTotal");
                                  break;
                              }
                            },
                            items: [
                              DropdownMenuItem<String>(
                                value: "DateOrder",
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      "Ngày ",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    _viewModel.posOrderSort.value == "desc" &&
                                            _viewModel.posOrderSort.orderBy ==
                                                "DateOrder"
                                        ? Icon(FontAwesomeIcons.sortNumericDown)
                                        : Icon(FontAwesomeIcons.sortNumericUp),
                                  ],
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: "AmountTotal",
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      "Tổng tiền  ",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    _viewModel.posOrderSort.value == "desc" &&
                                            _viewModel.posOrderSort.orderBy ==
                                                "AmountTotal"
                                        ? Icon(FontAwesomeIcons.sortAmountDown)
                                        : Icon(FontAwesomeIcons.sortAmountUp),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        Badge(
                          badgeColor: Colors.redAccent,
                          badgeContent: Text(
                            "${_viewModel.filterCount}",
                            style: TextStyle(color: Colors.white),
                          ),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "Lọc",
                              ),
                              Icon(
                                Icons.filter_list,
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ReloadListPage(
                  vm: _viewModel,
                  onPressed: () {
                    _viewModel.loadPosOrders();
                  },
                  child: _viewModel.posOrders != null &&
                          _viewModel.posOrders.length > 0
                      ? _showListInvoice()
                      : EmptyData(
                          onPressed: () {
                            _viewModel.loadPosOrders();
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showListInvoice() {
    return Scrollbar(
      child: Container(
        child: RefreshIndicator(
          key: refreshIndicatorKey,
          onRefresh: () async {
            _viewModel.loadPosOrders();
          },
          child: CustomScrollView(
            slivers: <Widget>[
/*              SliverPersistentHeader(
                pinned: false,
                floating: true,
                delegate: FixedHeader(
                  child: _showFilterPanel(),
                ),
              ),*/
              SliverList(
                delegate: SliverChildBuilderDelegate(
                    (context, index) => CreationAwareListItem(
                          itemCreated: () {
                            SchedulerBinding.instance.addPostFrameCallback(
                                (duration) =>
                                    _viewModel.handleItemCreated(index));
                          },
                          child: Dismissible(
                            background: Container(
                              margin: EdgeInsets.only(
                                  top: 2.5, bottom: 2.5, left: 5, right: 5),
                              padding: EdgeInsets.only(top: 2.5, bottom: 2.5),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      "Xóa dòng này?",
                                      style: TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Icon(
                                    Icons.delete_forever,
                                    color: Colors.white,
                                    size: 30,
                                  )
                                ],
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            key: Key("${_viewModel.posOrders}"),
                            confirmDismiss: (direction) async {
                              var dialogResult = await showQuestion(
                                  context: context,
                                  title: "Xác nhận xóa",
                                  message:
                                      "Bạn có muốn xóa hóa đơn ${_viewModel.posOrders[index].name ?? ""}");

                              if (dialogResult == DialogResultType.YES) {
                                var result = await _viewModel.deleteInvoice(
                                    _viewModel.posOrders[index].id);
                                if (result) _viewModel.removePosOrder(index);
                                return result;
                              } else {
                                return false;
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8, right: 8, top: 8),
                              child:
                                  _showItem(_viewModel.posOrders[index], index),
                            ),
                          ),
                        ),
                    childCount: _viewModel.posOrders?.length ?? 0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showFilterPanel() {
    return new Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            color: Colors.grey,
            spreadRadius: 2,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.start,
        runSpacing: 10,
        spacing: 10,
        children: <Widget>[
          FilterButton(
            child: Text("${_viewModel.filterDateRange.name}"),
            backgroundColor: Colors.green,
            isSelected: _viewModel.filterDateRange != null,
            onTap: () {
              _scaffoldKey.currentState.openEndDrawer();
            },
          ),
          FilterButton(
            child: Text("${_viewModel.filterByStatusString ?? "Tình trạng"}"),
            isSelected: _viewModel.filterByStatusString != null,
            onTap: () {
              _scaffoldKey.currentState.openEndDrawer();
            },
          ),
        ],
      ),
    );
  }

  Widget _showItem(PosOrder item, int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: PosOrderSateOption.getPosOrderSateOption(state: item?.state)
                .textColor
                .withOpacity(0.5),
            width: 5,
          ),
        ),
      ),
      child: item == temp
          ? Center(
              child: SpinKitCircle(
                color: Theme.of(context).primaryColor,
              ),
            )
          : Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(3.0)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[300],
                        offset: Offset(0, 2),
                        blurRadius: 3)
                  ]),
              child: new Column(
                children: <Widget>[
                  new ListTile(
                    onTap: () async {
                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => new PosOrderInfoPage(
                                  posOrderId: item.id,
                                  posOrderCallback: (value) {
                                    _viewModel.posOrders[index] = value;
                                  },
                                )),
                      );
                    },
                    title: Padding(
                      padding: const EdgeInsets.only(top: 0, bottom: 10),
                      child: Row(
                        children: <Widget>[
                          new Expanded(
                            child: new Text(
                              item?.name ?? "",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color:
                                      PosOrderSateOption.getPosOrderSateOption(
                                              state: item?.state)
                                          .textColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          new Expanded(
                            child: new Text(
                                "${vietnameseCurrencyFormat(item?.amountTotal ?? 0) ?? ""}",
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color:
                                      PosOrderSateOption.getPosOrderSateOption(
                                              state: item?.state)
                                          .textColor,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                          InkWell(
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Icon(
                                  Icons.more_horiz,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    subtitle: Column(
                      children: <Widget>[
                        new Text(
                          "${item?.pOSReference}",
                          style: TextStyle(color: Colors.black),
                        ),
                        new Divider(
                          color: Colors.grey.shade100,
                        ),
                        new Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                height: 8,
                                width: 8,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: PosOrderSateOption
                                              .getPosOrderSateOption(
                                                  state: item?.state)
                                          .textColor
                                          .withOpacity(0.8),
                                      blurRadius: 8,
                                      offset: Offset(0, 0),
                                    )
                                  ],
                                  color:
                                      PosOrderSateOption.getPosOrderSateOption(
                                              state: item?.state)
                                          .textColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Text(
                              "${PosOrderSateOption.getPosOrderSateOption(state: item?.state).description}",
                              style: TextStyle(
                                color: PosOrderSateOption.getPosOrderSateOption(
                                        state: item?.state)
                                    .textColor,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            Expanded(
                              child: Text(
                                "${DateFormat("dd/MM/yyyy  HH:mm").format(item?.dateOrder)}",
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                    onLongPress: () {},
                  )
                ],
              ),
            ),
    );
  }

  @override
  void initState() {
    _viewModel.loadPosOrders();
    super.initState();
  }
}

class FixedHeader extends SliverPersistentHeaderDelegate {
  final Widget child;

  FixedHeader({this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TODO: implement build
    return Container(
      color: Colors.indigo,
      height: 100,
      child: child,
    );
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => 50;

  @override
  // TODO: implement minExtent
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class FilterButton extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color selectedColor;
  final VoidCallback onTap;
  final bool isSelected;

  FilterButton(
      {this.selectedColor,
      this.backgroundColor = Colors.white,
      this.child,
      this.onTap,
      this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isSelected ? Colors.green : Colors.grey.shade200,
        border: isSelected
            ? Border.all(color: Colors.green, width: 2)
            : Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              child,
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
