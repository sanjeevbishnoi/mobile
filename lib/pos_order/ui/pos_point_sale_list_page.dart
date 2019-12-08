import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tpos_mobile/app_core/helper/string_helper.dart';
import 'package:tpos_mobile/app_core/template_ui/reload_list_page.dart';
import 'package:tpos_mobile/app_core/ui_base/view_base.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/tpos_api_helper.dart';
import 'package:tpos_mobile/pos_order/models/point_sale.dart';
import 'package:tpos_mobile/pos_order/ui/pos_cart_page.dart';
import 'package:tpos_mobile/pos_order/viewmodels/pos_point_sale_list_viewmodel.dart';

class PosPointSaleListPage extends StatefulWidget {
  @override
  _PosPointSaleListPageState createState() => _PosPointSaleListPageState();
}

class _PosPointSaleListPageState extends State<PosPointSaleListPage> {
  var _vm = locator<PosPointSaleListViewModel>();

  @override
  Widget build(BuildContext context) {
    return ViewBase<PosPointSaleListViewModel>(
      model: _vm,
      builder: (context, model, _) => Scaffold(
        appBar: AppBar(
          title: Text("Điểm bán hàng"),
        ),
        body: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Container(
              decoration: BoxDecoration(color: Colors.white
                  //gradient: LinearGradient(colors: [Colors.green[300],Colors.green[400]])
                  ),
              child: _showDanhSachDiemBanHang(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _showDanhSachDiemBanHang() {
    return Container(
      child: RefreshIndicator(
          onRefresh: () async {
            return await _vm.loadPointSales();
          },
          child: ReloadListPage(
              vm: _vm,
              onPressed: _vm.loadPointSales,
              child: ListView.builder(
                  itemCount: _vm.pointSales.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
                      child: _showItem(_vm.pointSales[index]),
                    );
                  }))),
    );
  }

  Widget _showItem(PointSale item) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(3.0)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey[400], offset: Offset(0, 3), blurRadius: 3)
          ]),
      child: new Column(
        children: <Widget>[
          new ListTile(
            onTap: () async {},
            title: Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 6),
              child: Row(
                children: <Widget>[
                  new Expanded(
                    child: new Text(
                      "${item.name ?? ""}",
                      textAlign: TextAlign.start,
                    ),
                  ),
                  new Expanded(
                    child:
                        new Text("${item.pOSSessionUserName ?? "Chưa sử dụng"}",
                            textAlign: TextAlign.end,
                            style: TextStyle(
//                          color: getFastSaleOrderStateOption(state: item.state)
//                              .textColor,
                              fontWeight: FontWeight.bold,
                            )),
                  ),
                ],
              ),
            ),
            subtitle: Column(
              children: <Widget>[
                new Text(
                  "Phiên cuối:  ${item.lastSessionClosingDate == null ? "" : DateFormat("dd/MM/yyyy  HH:mm").format(convertStringToDateTime(item.lastSessionClosingDate))}",
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(
                  height: 4,
                ),
                new Text(
                  "Đóng lúc:",
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(
                  height: 4,
                ),
                new Text(
                  "Số dư tiền mặt: ${vietnameseCurrencyFormat(item.discountPc) ?? ""}",
                  style: TextStyle(color: Colors.black),
                ),
                new Divider(
                  color: Colors.grey.shade300,
                ),
                new Row(
                  children: <Widget>[
                    Visibility(
                      visible: item.pOSSessionUserName == null ? false : true,
                      child: Container(
                        height: 30,
                        width: 100,
                        color: Colors.lightGreen[400],
                        child: RaisedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => PosCartPage()),
                              );
                            },
                            child: Text(
                              "Tiếp tục",
                              style: TextStyle(color: Colors.white),
                            )),
                      ),
                    ),
                    Visibility(
                      visible: item.pOSSessionUserName == null ? false : true,
                      child: SizedBox(
                        width: 15,
                      ),
                    ),
                    Container(
                      height: 30,
                      width: 100,
                      child: RaisedButton(
                          color: Colors.deepOrange,
                          onPressed: () {
                            _vm.hanleCreatePointSale(
                                item.pOSSessionUserName, item.id);
                          },
                          child: Text(
                            "${item.pOSSessionUserName == null ? "Phiên mới" : "Đóng"}",
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                  ],
                ),
                SizedBox(
                  height: 4,
                )
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            onLongPress: () {},
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _vm.loadPointSales();
  }
}
