import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/fast_purchase_order/helper/animation_helper.dart';
import 'package:tpos_mobile/fast_purchase_order/helper/screen_helper.dart';
import 'package:tpos_mobile/fast_purchase_order/helper/widget_helper.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/app_core/helper/string_helper.dart';
import 'package:tpos_mobile/main_app.dart';
import 'package:tpos_mobile/sale_online/ui/report_dashboard_page_change_password.dart';
import 'package:tpos_mobile/sale_online/ui/report_dashboard_page_columnchart.dart';
import 'package:tpos_mobile/sale_online/ui/report_dashboard_page_dataline.dart';
import 'package:tpos_mobile/sale_online/ui/report_dashboard_page_piechart.dart';
import 'package:tpos_mobile/sale_online/ui/report_sale_order_page.dart';
import 'package:tpos_mobile/app_core/ui_base/ui_vm_base.dart';
import 'package:tpos_mobile/sale_online/viewmodels/report_dashboard_viewmodel.dart';
import 'package:tpos_mobile/src/tpos_apis/models/DashboardReport.dart';
import 'package:tpos_mobile/thong_ke_giao_hang/report_delivery_page.dart';
import '../../app_service_locator.dart';

class ReportDashboardPage extends StatefulWidget {
  @override
  ReportDashboardPageState createState() => ReportDashboardPageState();
}

class ReportDashboardPageState extends State<ReportDashboardPage>
    with SingleTickerProviderStateMixin {
  final _vm = locator<ReportDashboardViewModel>();
  final dividerMin = Divider(
    height: 1,
  );
  double myPadding = 5;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  AnimationController _animationController;
  final iconRight = Icon(Icons.chevron_right);
  double topBarOpacity = 0;
  ScrollController _scrollController;
  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _scrollController = ScrollController();
    _scrollController.addListener(
      () {
        if (_scrollController.offset <= 110) {
          setState(() {
            topBarOpacity = _scrollController.offset;
          });
        }
      },
    );

    _vm.dialogMessageController.listen(
      (message) {
        registerDialogToView(context, message,
            scaffState: _scaffoldKey.currentState);
      },
    );
    _vm.initCommand();
    super.initState();
    /* _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("bao cao"),
    ));*/
  }

  bool openMenu = false;

  @override
  Widget build(BuildContext context) {
    updateScreenResolution(context);

    return ScopedModel<ReportDashboardViewModel>(
      model: _vm,
      child: Scaffold(
        key: _scaffoldKey,
        /*appBar: AppBar(
          title: Text("Tổng quan"),
          elevation: 0,
          actions: <Widget>[
            IconButton(
              onPressed: () {
                setState(() {
                  openMenu = !openMenu;
                });
              },
              icon: Icon(Icons.more_vert),
            )
          ],
        ),*/
        body: Stack(
          children: <Widget>[
            _buildBody(),
            _buildMenu(),
          ],
        ),
        backgroundColor: Colors.grey.shade200,
      ),
    );
  }

  Widget _buildBody() {
    return UIViewModelBase(
      viewModel: _vm,
      child: RefreshIndicator(
          child: Stack(
            children: <Widget>[
              clipShape(context),
              SafeArea(
                child: Stack(
                  children: <Widget>[
                    SingleChildScrollView(
                      controller: _scrollController,
                      child: Padding(
                        padding:
                            EdgeInsets.fromLTRB(0, 150, myPadding, myPadding),
                        child: Column(
                          //padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
                          children: <Widget>[
                            _buildSaleResultReportPanel(),
                            isTablet(context)
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Expanded(
                                        child: _buildPieChart(),
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: <Widget>[
                                            _buildColumnChart(),
                                            _buildLineChart(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: <Widget>[
                                      _buildLineChart(),
                                      _buildPieChart(),
                                      _buildColumnChart(),
                                    ],
                                  )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: Theme.of(context).primaryColor.withOpacity(
                          topBarOpacity / 100 >= 1 ? 1 : topBarOpacity / 100),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(0),
                        leading: IconButton(
                          icon: Icon(
                            Icons.menu,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ),
                        title: Text(
                          "Tổng quan",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 20),
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            onMenuTap();
                          },
                          icon: Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          onRefresh: () async {
            await _vm.refreshReportCommand();
            return true;
          }),
    );
  }

  Widget _buildSaleResultReportPanel() {
    return _myCusContainer(
      child: ScopedModelDescendant<ReportDashboardViewModel>(
        builder: (context, child, model) {
          return Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 8, right: 8),
                width: double.infinity,
                color: Colors.grey.shade100,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        "Kết quả bán hàng",
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      child: DropdownButton<DashboardReportDataOverviewOption>(
                        //iconEnabledColor: Colors.white,
                        style: TextStyle(
                          color: Colors.lightBlue,
                        ),
                        hint: Text("Chọn thời gian"),
                        value: _vm.selectedOverviewOption,
                        onChanged: (value) {
                          _vm.selectedOverviewOption = value;
                          _vm.reloadOverviewCommand();
                        },
                        underline: DropdownButtonHideUnderline(
                            child: Text(
                          _vm.selectedOverviewOption != null
                              ? "".padLeft(
                                  _vm.selectedOverviewOption.text.length + 1,
                                  "_")
                              : "",
                          style: TextStyle(color: Colors.lightBlue),
                        )),
                        iconEnabledColor: Colors.lightBlue,
                        items: _vm.overviewFilter
                            ?.map(
                              (f) => DropdownMenuItem<
                                  DashboardReportDataOverviewOption>(
                                child: Text(
                                  "${f.text.toUpperCase()[0]}${f.text.substring(1).toLowerCase()}",
                                  style: TextStyle(
                                      color: _vm.selectedOverviewOption == f
                                          ? Colors.lightBlue
                                          : Colors.black),
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
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: ListTile(
                        contentPadding: EdgeInsets.only(left: 12),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 20,
                          child: Icon(FontAwesomeIcons.dollarSign),
                        ),
                        title: Text(
                          "${_vm.report?.overview?.totalOrderCurrent ?? 0} hóa đơn",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            AutoSizeText(
                              "${vietnameseCurrencyFormat(_vm.report?.overview?.totalSaleCurrent ?? 0)}",
                              maxLines: 1,
                              style: TextStyle(
                                  //fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.blue),
                            ),
                            Text("Doanh số"),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: ListTile(
                        contentPadding: EdgeInsets.only(left: 12),
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: 20,
                          child: Icon(FontAwesomeIcons.replyAll),
                        ),
                        title: AutoSizeText(
                          "${_vm.report?.overview?.totalOrderReturns ?? 0} phiếu",
                          maxLines: 1,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "${vietnameseCurrencyFormat(_vm.report?.overview?.totalReturn ?? 0)}",
                              style: TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.green),
                            ),
                            Text("Trả hàng")
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  bool isAppearMenu = false;
  void onMenuTap() {
    if (openMenu) {
      setState(() {
        openMenu = false;
      });
      _animationController.forward(from: 0).then((_) {
        setState(() {
          isAppearMenu = false;
        });
      });
    } else {
      setState(() {
        openMenu = true;
        isAppearMenu = true;
      });
      _animationController.forward(from: 0);
    }
  }

  Widget _buildMenu() {
    Widget myDivider = Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
      child: Container(
        width: double.infinity,
        height: 1,
        color: Colors.grey.shade100,
      ),
    );
    return !isAppearMenu
        ? SizedBox()
        : Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    onMenuTap();
                  },
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      getScreenWidth(context) / (isTablet(context) ? 1.7 : 3),
                      80,
                      5,
                      8),
                  child: myFadeAnim(
                      controller: _animationController,
                      isFadeIn: openMenu,
                      fromTop: true,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black54,
                                  offset: Offset(0, 5),
                                  blurRadius: 20,
                                )
                              ]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                title: Text(
                                  "Hóa đơn đã bán",
                                  style: TextStyle(color: Colors.black),
                                ),
                                trailing: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Colors.black,
                                ),
                                onTap: () {
                                  onMenuTap();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ReportSaleOrderPage()));
                                },
                              ),
                              myDivider,
                              ListTile(
                                title: Text(
                                  "Thống kê giao hàng",
                                  style: TextStyle(color: Colors.black),
                                ),
                                trailing: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Colors.black,
                                ),
                                onTap: () {
                                  onMenuTap();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ReportDeliveryPage()));
                                },
                              ),

                              ListTile(
                                title: Text(
                                  "Thống kê xuất nhập tồn",
                                  style: TextStyle(color: Colors.black),
                                ),
                                trailing: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Colors.black,
                                ),
                                onTap: () {
                                  onMenuTap();
                                  Navigator.pushNamed(
                                      context, AppRoute.report_inventory);
                                },
                              ),

                              ///       Thử máy in

                              /*
                              myDivider,
                              ListTile(
                                title: Text(
                                  "Thử mẫu in",
                                  style: TextStyle(color: Colors.black),
                                ),
                                trailing: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Colors.black,
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PageTestPrinterCuaQuan()));
                                },
                              ),*/
                              myDivider,
//                              ListTile(
//                                title: Text(
//                                  "Lịch sử hoạt động",
//                                  style: TextStyle(color: Colors.black),
//                                ),
//                                trailing: Icon(
//                                  Icons.keyboard_arrow_right,
//                                  color: Colors.black,
//                                ),
//                                onTap: () {
//                                  onMenuTap();
//                                  Navigator.push(
//                                    context,
//                                    MaterialPageRoute(
//                                      builder: (context) =>
//                                          UserActivitiesPage(),
//                                    ),
//                                  );
//                                },
//                              ),
//                              myDivider,
//                              ListTile(
//                                title: Text(
//                                  "Đổi mật khẩu",
//                                  style: TextStyle(color: Colors.black),
//                                ),
//                                trailing: Icon(
//                                  Icons.keyboard_arrow_right,
//                                  color: Colors.black,
//                                ),
//                                onTap: () {
//                                  onMenuTap();
//                                  openChangePassWordDialog();
//                                },
//                              ),
                            ],
                          ),
                        ),
                      )),
                ),
              ],
            ),
          );
  }

  Widget _myCusContainer({Widget child}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(myPadding, myPadding, 0, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
          border: Border.all(
            color: Colors.grey.shade400,
          ),
        ),
        //clipBehavior: Clip.antiAlias,
        /*shape: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 0.5),
            gapPadding: 12),*/
        child: child,
      ),
    );
  }

  Widget _buildLineChart() {
    return _myCusContainer(child: LineChartPage(scaffoldKey: _scaffoldKey));
  }

  Widget _buildPieChart() {
    return _myCusContainer(child: PieChartPage(scaffoldKey: _scaffoldKey));
  }

  Widget _buildColumnChart() {
    return _myCusContainer(child: ColumnChartPage(scaffoldKey: _scaffoldKey));
  }

  void openChangePassWordDialog() {
    showDialog(
      context: context,
      builder: (context) => ChangePassWordDialog(_scaffoldKey),
    );
  }
}
