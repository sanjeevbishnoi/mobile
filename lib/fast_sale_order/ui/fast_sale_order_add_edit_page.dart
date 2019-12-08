/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/10/19 5:57 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/10/19 5:49 PM
 *
 */

import 'package:flutter/material.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_sale_order.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_sale_order_line.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product.dart';
import 'package:tpos_mobile/fast_sale_order/ui/fast_sale_order_line_edit_page.dart';
import 'package:tpos_mobile/sale_online/ui/partner_add_edit_page.dart';
import 'package:tpos_mobile/sale_online/ui/product_list_page.dart';
import 'package:tpos_mobile/sale_online/viewmodels/viewmodel.dart';
import 'package:tpos_mobile/string_resources.dart';
import 'package:tpos_mobile/widgets/ModalWaitingWidget.dart';
import 'package:tpos_mobile/widgets/number_input_left_right_widget.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

import 'fast_sale_order_add_edit_ship_receiver_page.dart';

class FastSaleOrderAddEditPage extends StatefulWidget {
  final FastSaleOrderAddEditData editOrder;
  FastSaleOrderAddEditPage({this.editOrder});
  @override
  _FastSaleOrderAddEditPageState createState() =>
      _FastSaleOrderAddEditPageState(editOrder: editOrder);
}

class _FastSaleOrderAddEditPageState extends State<FastSaleOrderAddEditPage> {
  FastSaleOrderAddEditData _editOrder;
  //Logger _log = new Logger("FastSaleOrderAddEditPage");

  _FastSaleOrderAddEditPageState({FastSaleOrderAddEditData editOrder}) {
    _editOrder = editOrder;
  }

  FastSaleOrderAddEditViewModel _viewModel =
      locator<FastSaleOrderAddEditViewModel>();

  @override
  void didChangeDependencies() {
    _viewModel.notifyPropertyChangedController.listen((name) {
      setState(() {});
    });

    super.didChangeDependencies();
  }

  @override
  void initState() {
    _viewModel.init(editOrder: _editOrder);
    _viewModel.initCommand();
    _viewModel.dialogMessageController
        .where((f) => f.receiver == null)
        .listen((dialog) {
      registerDialogToView(context, dialog,
          scaffState: _scaffoldKey.currentState);
    });
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String barcode = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text(
            "${_viewModel.order != null && _viewModel.order.id != null && _viewModel.order.id != 0 ? "Chỉnh sửa hóa đơn" : "Thêm hóa đơn"}"),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            child: Text("Lưu nháp"),
            onPressed: () async {
              _viewModel.saveCommand(true);
            },
          ),
        ],
      ),
      body: ModalWaitingWidget(
        isBusyStream: _viewModel.isBusyController,
        initBusy: false,
        child: _showBody(),
      ),
    );
  }

  Widget _showBody() {
    return Material(
      color: Colors.grey.shade300,
      child: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _showInfoCustomer(),
                  SizedBox(
                    height: 10,
                  ),
                  _showProductAddItem(),
                  SizedBox(
                    height: 10,
                  ),
                  _showListProduct(_viewModel.orderLines),
                  SizedBox(
                    height: 10,
                  ),
                  _showSummary(),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    height: 1,
                  ),
                  Container(
                    color: Colors.white,
                    child: new ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.account_circle,
                            color: Colors.green,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Giao hàng: ",
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
//            subtitle: Text("",
//                textAlign: TextAlign.start,
//                style: TextStyle(
//                    color: Colors.green, fontWeight: FontWeight.bold)),
                      title: Text(
                        "${_viewModel.selectedDeliveryCarrier?.name ?? "Chọn đối tác giao hàng"}",
                        style: TextStyle(fontSize: 15),
                        textAlign: TextAlign.right,
                      ),
                      trailing: Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        //Edit Thông tin giao hàng
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (ctx) =>
                                    new FastSaleOrderAddEditShipReceiverPage(
                                      viewModel: this._viewModel,
                                    )));
                      },
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  Material(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: TextField(
                        decoration: InputDecoration(
                            labelText: "Ghi chú hóa đơn",
                            hintText: "Thêm ghi chú",
                            icon: Icon(Icons.message),
                            border: InputBorder.none),
                        maxLines: 2,
                        onChanged: (text) {
                          _viewModel.order.comment = text;
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
          _showButton(),
        ],
      ),
    );
  }

  Widget _showInfoCustomer() {
    return Material(
      color: Colors.white,
      child: new Column(
        children: <Widget>[
          // Ngày hóa đơn
          Builder(
            builder: (context) {
              if (_viewModel.order.id != null && _viewModel.order.id != 0) {
                return new ListTile(
                  leading: Icon(
                    Icons.date_range,
                    color: Colors.green,
                  ),
                  title: Text("Hóa đơn ${_viewModel.order.number}",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                );
              } else {
                return SizedBox();
              }
            },
          ),
          new Divider(
            height: 1.0,
          ),
          // Khách hàng
          new ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.supervised_user_circle,
                  color: Colors.green,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "Khách hàng",
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            title: Text(
              "${_viewModel.partner?.displayName ?? "<Chưa chọn khách hàng>"}",
              textAlign: TextAlign.right,
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () async {
              if (_viewModel.partner != null) {
                var partner = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (ctx) => PartnerAddEditPage(
                              closeWhenDone: true,
                              partnerId: this._viewModel.partner?.id,
                            )));

                if (partner != null) {
                  _viewModel.setPartnerCommand(partner);
                }
              }
            },
          ),
          // Thông tin giao hàng

          // END DSSP
        ],
      ),
    );
  }

  Widget _showListProduct(List<FastSaleOrderLine> items) {
    return Material(
        color: Colors.white,
        child: ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (ctx, index) {
            return Dismissible(
              direction: DismissDirection.endToStart,
              key: Key(items[index].id.toString()),
              child: _showProductItem(items[index], index),
              background: Container(
                padding: EdgeInsets.all(20),
                color: Colors.red,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text("Xóa sản phẩm: "),
                    ),
                    Icon(
                      Icons.delete_forever,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
              onDismissed: (direction) {
                setState(() {
                  items.removeAt(index);
                });
              },
              confirmDismiss: (direction) async {
                return true;
              },
            );
          },
          separatorBuilder: (ctx, index) {
            return Divider(
              height: 5,
              indent: 10,
              color: Colors.black45,
            );
          },
          itemCount: (items.length ?? 0),
        ));
  }

  Widget _showProductItem(FastSaleOrderLine item, [int index]) {
    TextStyle itemTextStyle = new TextStyle(color: Colors.black);
    return ListTile(
      contentPadding: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
      title: RichText(
        text: TextSpan(
          text: "${index + 1}. ",
          style: itemTextStyle,
          children: [
            TextSpan(
              text: "${item.productName ?? ""}",
              style: itemTextStyle,
            ),
            TextSpan(
              text: " (${item.productUomName})",
              style: itemTextStyle.copyWith(color: Colors.blue),
            )
          ],
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Text(
                "${vietnameseCurrencyFormat(item.priceUnit ?? 0)}",
                style: itemTextStyle.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
                child: Text(
              "x",
              style: itemTextStyle.copyWith(color: Colors.green),
              textAlign: TextAlign.left,
            )),
            Expanded(
              flex: 2,
              child: SizedBox(
                child: NumberInputLeftRightWidget(
                  key: Key(item.id.toString()),
                  value: item.productUOMQty,
                  fontWeight: FontWeight.bold,
                  onChanged: (value) {
                    _viewModel.updateOrderLineQuantityCommand(item, value);
                  },
                ),
                height: 35,
              ),
            )
          ],
        ),
      ),
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (ctx) => FastSaleOrderLineEditPage(item)));
      },
    );
  }

  Widget _showProductAddItem() {
    return Container(
      color: Colors.white,
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
        leading: Icon(
          Icons.add,
          color: Colors.blue,
        ),
        title: Text(
          "Thêm hàng hóa",
          style: TextStyle(color: Colors.blue),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.center_focus_strong,
            color: Colors.blue,
          ),
          onPressed: () async {
            try {
              barcode = await BarcodeScanner.scan();
              if (barcode != "" && barcode != null) {
                Product selectedProduct = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (ctx) => ProductListPage(
                              keyWord: barcode,
                              closeWhenDone: true,
                              isSearchMode: true,
                            )));
                if (selectedProduct != null) {
                  _viewModel.addNewOrderLineFromProductCommand(selectedProduct);
                }
              }
            } on PlatformException catch (e) {
              if (e.code == BarcodeScanner.CameraAccessDenied) {
                showError(
                    context: context,
                    title: "Chưa cấp quyền camera",
                    message:
                        "Vui lòng vào cài đặt cho phép ứng dụng truy cập camera");
              } else {
                showError(
                    context: context,
                    title: "Chưa quét được mã vạch",
                    message: "Vui lòng thử lại");
              }
            } on FormatException {
              showError(
                  context: context,
                  title: "Chưa quét được mã vạch",
                  message: "Vui lòng thử lại");
            } catch (e) {
              showError(
                  context: context,
                  title: "Chưa quét được mã vạch",
                  message: "Vui lòng thử lại");
            }
            //Navigator.pop(context);
          },
        ),
        dense: true,
        onTap: () async {
          Product selectedProduct = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => ProductListPage(
                isSearchMode: true,
                closeWhenDone: true,
              ),
            ),
          );

          if (selectedProduct != null) {
            _viewModel.addNewOrderLineFromProductCommand(selectedProduct);
          }
        },
      ),
    );
  }

  Widget _showSummary() {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Text("Cộng tiền: "),
                Expanded(
                    child: Text(
                  vietnameseCurrencyFormat(_viewModel.totalAmount),
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )),
              ],
            ),
          ),

//          Row(
//            children: <Widget>[
//              Text("Tổng tiền: "),
//              Expanded(
//                  child: Text(
//                vietnameseCurrencyFormat(_viewModel.totalAmount),
//                textAlign: TextAlign.right,
//                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//              )),
//            ],
//          ),
        ],
      ),
    );
  }

  Widget _showButton() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              color: ColorResource.saveButtonColor,
              textColor: ColorResource.saveButtonTextColor,
              child: Text("Lưu nháp"),
              onPressed: () {
                _viewModel.saveCommand(true);
              },
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              color: Colors.deepPurple,
              textColor: ColorResource.saveButtonTextColor,
              child: Text("Xác nhận"),
              onPressed: () {
                _viewModel.saveCommand(false);
              },
            ),
          ),
        ),

//
      ],
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
// TODO làm tiếp tạo hoa đơn từ đơn hàng sale online
