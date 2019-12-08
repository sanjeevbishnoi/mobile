///*
// * *
// *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
// *  * Copyright (c) 2019 . All rights reserved.
// *  * Last modified 4/9/19 9:52 AM
// *
// */
//
//import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
//import 'package:scoped_model/scoped_model.dart';
//import 'package:tpos_mobile/helpers/helpers.dart';
//import 'package:tpos_mobile/my_controls/ViewCellWidget.dart';
//import 'package:tpos_mobile/sale_online/models/tpos/fast_sale_order.dart';
//import 'package:tpos_mobile/sale_online/models/tpos/sale_online_order.dart';
//import 'package:tpos_mobile/sale_online/ui/sale_online_create_invoice_from_app_edit_detail_page.dart';
//import 'package:tpos_mobile/sale_online/ui/sale_online_create_invoice_from_app_edit_ship_receiver_page.dart';
//import 'package:tpos_mobile/sale_online/viewmodels/fast_sale_order_create_viewmodel.dart';
//import 'package:tpos_mobile/sale_online/viewmodels/sale_online_create_invoice_from_app_viewmodel.dart';
//import 'package:tpos_mobile/tpos/models/Order.dart';
//import 'package:tpos_mobile/tpos/ui/sale_online_product_list_invoice_page.dart';
//import 'package:tpos_mobile/helpers/messenger_helper.dart';
//
//class FastSaleOrderCreatePage extends StatefulWidget {
//  List<String> orderIds;
//
//  FastSaleOrderCreatePage({@required this.orderIds});
//  @override
//  _FastSaleOrderCreatePageState createState() =>
//      _FastSaleOrderCreatePageState(orderIds: this.orderIds);
//}
//
//class _FastSaleOrderCreatePageState extends State<FastSaleOrderCreatePage> {
//  List<String> orderIds;
//  _FastSaleOrderCreatePageState({this.orderIds});
//
//  FastSaleOrderCreateViewModel viewModel = new FastSaleOrderCreateViewModel();
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//        appBar: AppBar(
//          leading: IconButton(
//              icon: Icon(Icons.close),
//              onPressed: () {
//                Navigator.pop(context);
//              }),
//          actions: <Widget>[],
//          title: Text("Tạo hóa đơn"),
//        ),
//        body: SingleChildScrollView(
//          child: Column(
//            children: <Widget>[
//              _showInfoCustomer(),
//              _showButton(),
//            ],
//          ),
//        ));
//  }
//
//  Widget _showInfoCustomer() {
//    return StreamBuilder<FastSaleOrder>(
//        stream: viewModel.fastSaleOrderStream,
//        initialData: viewModel.fastSaleOrder,
//        builder: (context, snapshot) {
//          return new Column(
//            children: <Widget>[
//              // Ngày hóa đơn
//              new ListTile(
//                leading: Icon(
//                  Icons.date_range,
//                  color: Colors.green,
//                ),
//                title: Text("Ngày tạo hóa đơn",
//                    textAlign: TextAlign.start,
//                    style: TextStyle(
//                        color: Colors.green, fontWeight: FontWeight.bold)),
//                subtitle: Text(
//                    "${DateFormat("dd/MM/yyyy HH:mm", "en_US").format(snapshot.data?.dateInvoice ?? DateTime.now())}",
//                    textAlign: TextAlign.start,
//                    style: TextStyle(fontSize: 15)),
//              ),
//              new Divider(
//                height: 5.0,
//              ),
//              // Khách hàng
//              new ListTile(
//                leading: Icon(Icons.supervised_user_circle),
//                title: Text("Khách hàng:"),
//                subtitle: Text("${snapshot.data?.userName}"),
//              ),
//              new Expanded(
//                child: StreamBuilder<List<DeliveryCarriers>>(
//                    stream: viewModel.deliveryCarriersStraem,
//                    initialData: viewModel.deliveryCarriers,
//                    builder: (context, snapshotDeliveryCarriers) {
//                      return StreamBuilder<DeliveryCarriers>(
//                          stream: viewModel.selectedDeliveryCarrierStream,
//                          initialData: viewModel.selectedDeliveryCarrier,
//                          builder: (context, snapshotSelectedDeliveryCarrier) {
//                            return DropdownButton<DeliveryCarriers>(
//                              hint: Text("Đối tác giao hàng"),
//                              value: snapshotSelectedDeliveryCarrier.data,
//                              onChanged: (DeliveryCarriers newValue) {
//                                viewModel.selectedDeliveryCarrier = newValue;
//                                setState(() {});
//                              },
//                              items: snapshotDeliveryCarriers.data
//                                  .map((DeliveryCarriers deliveryCarrier) {
//                                return new DropdownMenuItem<DeliveryCarriers>(
//                                  value: deliveryCarrier,
//                                  child: new Text(
//                                    deliveryCarrier.carrierId,
//                                  ),
//                                );
//                              }).toList(),
//                            );
//                          });
//                    }),
//              ),
//              new Divider(),
//              // Thông tin giao hàng, shipReceiver
//              new ListTile(
//                contentPadding: EdgeInsets.only(left: 12),
//                leading: Icon(
//                  Icons.account_circle,
//                  color: Colors.green,
//                ),
//                title: Text("Thông tin giao hàng",
//                    textAlign: TextAlign.start,
//                    style: TextStyle(
//                        color: Colors.green, fontWeight: FontWeight.bold)),
//                subtitle: Column(
//                  children: <Widget>[
//                    Text(
//                      "Người nhận: ${snapshot.data?.shipReceiver?.name ?? "<chưa có tên>"}, ${snapshot.data?.shipReceiver?.street ?? "<Chưa có địa chỉ>"}, SĐT: ${snapshot.data?.shipReceiver?.phone ?? "<Chưa có sđt>"}",
//                      style: TextStyle(fontSize: 15),
//                    ),
//                    Text(
//                      "Giao hàng: ${viewModel.selectedDeliveryCarrier?.carrierId ?? "<Chưa chọn đối tác>"}",
//                      style: TextStyle(fontSize: 15),
//                    ),
//                  ],
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                ),
//                trailing: SizedBox(
//                  width: 40,
//                  child: IconButton(
//                    icon: Icon(Icons.keyboard_arrow_right),
//                    onPressed: () {},
//                  ),
//                ),
//                onTap: () {
//                  //Edit Thông tin giao hàng
////                  Navigator.push(
////                      context,
////                      MaterialPageRoute(
////                          builder: (ctx) =>
////                              SaleOnlineCreateInvoiceFromAppEditShipReceiverPage()));
//                },
//              ),
//              // Danh sách sản phẩm
//              new ListTile(
//                contentPadding: EdgeInsets.only(left: 12),
//                leading: Icon(Icons.shopping_basket),
//                title: Text(
//                  "Danh sách sản phẩm (${snapshot.data?.fastSaleOrderLine?.length ?? 0})",
//                  style: TextStyle(
//                      color: Colors.green,
//                      fontWeight: FontWeight.bold,
//                      fontSize: 16),
//                ),
//                subtitle: new Column(
//                  children: <Widget>[
//                    new Divider(),
//                    new Row(
//                      children: <Widget>[
//                        new Expanded(
//                            child: Text(
//                                "${snapshot.data?.fastSaleOrderLine?.length ?? 0} mặt hàng")),
//                        //new Text(
//                        // "Tổng tiền: ${vietnameseCurrencyFormat(viewModel.totalAmount, sysmbol: "đ")}"),
//                      ],
//                    ),
//                  ],
//                ),
//                trailing: SizedBox(
//                  width: 40,
//                  child: IconButton(
//                    icon: Icon(Icons.keyboard_arrow_right),
//                    onPressed: () {},
//                  ),
//                ),
//                onTap: () {
//                  // Edit danh sách sản phẩm
//
//                  //  Navigator.push(
//                  //context,
//                  // MaterialPageRoute(
////                      builder: (ctx) =>
////                          SaleOnlineCreateInvoiceFromAppEditDetailPage(
////                              viewModel.orderLine),
//                  //),
//                  //);
//
//                  setState(() {
////                    viewModel.calulateSummary();
//                  });
//                },
//              ),
//            ],
//          );
//        });
//  }
//
//  Widget _showButton() {
//    return Padding(
//      padding: const EdgeInsets.only(left: 10, right: 10, top: 25, bottom: 0),
//      child: Padding(
//        padding: const EdgeInsets.only(bottom: 10.0),
//        child: Row(
//          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//          children: <Widget>[
//            Expanded(
//              flex: 1,
//              child: RaisedButton(
//                padding: EdgeInsets.all(15),
//                color: Colors.green,
//                child: Text(
//                  "Lưu",
//                  style: TextStyle(color: Colors.white),
//                ),
//                onPressed: () {
////                  viewModel.saveInvoice();
//                },
//              ),
//            ),
//            SizedBox(
//              width: 10,
//            ),
//            Expanded(
//              flex: 1,
//              child: RaisedButton(
//                padding: EdgeInsets.all(15),
//                color: Colors.green,
//                child: Text(
//                  "Hủy",
//                  style: TextStyle(color: Colors.white),
//                ),
//                onPressed: () {
//                  Navigator.pop(context);
//                },
//              ),
//            ),
//          ],
//        ),
//      ),
//    );
//  }
//
//  @override
//  void initState() {
////    viewModel.orderIds = this.orderIds;
////    viewModel.init();
////    viewModel.notifyChangedStream.listen((objectName) {
////      setState(() {});
////    });
////
////    viewModel.dialogStream.listen((dialogMessage) {
////      registerDialogToView(context, dialogMessage, null);
////    });
//  }
//
//  @override
//  void dispose() {
//    super.dispose();
//    viewModel.dispose();
//  }
//}
