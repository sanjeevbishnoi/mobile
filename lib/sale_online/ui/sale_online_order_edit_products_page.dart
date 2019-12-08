/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/16/19 5:56 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/16/19 2:59 PM
 *
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tpos_mobile/category/product_search_page.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_order_line_edit_page.dart';
import 'package:tpos_mobile/sale_online/viewmodels/sale_online_order_edit_products_viewmodel.dart';

import 'package:tpos_mobile/widgets/number_input_left_right_widget.dart';
import '../../app_service_locator.dart';
import 'package:flutter/widgets.dart';

class SaleOnlineOrderEditProductsPage extends StatefulWidget {
  final List<SaleOnlineOrderDetail> orderLines;
  SaleOnlineOrderEditProductsPage(this.orderLines);
  @override
  _SaleOnlineOrderEditProductsPageState createState() =>
      _SaleOnlineOrderEditProductsPageState(this.orderLines);
}

class _SaleOnlineOrderEditProductsPageState
    extends State<SaleOnlineOrderEditProductsPage> {
  _SaleOnlineOrderEditProductsPageState(this.orderLines);
  List<SaleOnlineOrderDetail> orderLines;
  var _viewModel = locator<SaleOnlineOrderEditProductsViewModel>();
  StreamSubscription _notifyPropertyChangedSubcription;
  String barcode = "";
  @override
  void initState() {
    _viewModel.init(orderLines);
    _viewModel.initCommand();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _notifyPropertyChangedSubcription =
        _viewModel.notifyPropertyChangedController.listen((propertyName) {
      setState(() {});
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _notifyPropertyChangedSubcription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  Future _findProduct({String keyword}) async {
    var product = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductSearchPage(),
      ),
    );

    if (product != null) {
      _viewModel.addItemFromProductCommand(product);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DS Sản phẩm"),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 8, bottom: 8, right: 8),
            padding: EdgeInsets.only(left: 8, right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: Colors.grey.shade100,
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: Colors.green,
                  ),
                  InkWell(
                    child: Text(
                      "Thêm sản phẩm",
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () {
                      _findProduct();
                    },
                  ),
                  Container(
                    margin:
                        EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                    width: 1,
                    color: Colors.white,
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                      "images/barcode_scan.svg",
                      width: 25,
                      height: 25,
                      color: Colors.blue,
                    ),
                    onPressed: () async {
                      var result = await scanBarcode();
                      if (result.isError) {}
                      _findProduct(keyword: result.result);
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      body: _showBody(),
    );
  }

  Widget _showBody() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: _showListItems(_viewModel.orderLines),
        ),
        new Container(
          height: 45,
          color: Colors.green,
          child: new Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 3, top: 3, bottom: 3),
                child: RaisedButton.icon(
                  textColor: Colors.white,
                  color: Colors.deepPurple,
                  icon: Icon(Icons.keyboard_return),
                  label: Padding(
                    padding: const EdgeInsets.only(right: 10, left: 10),
                    child: Text("Quay lại"),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Tổng tiền: ${vietnameseCurrencyFormat(_viewModel.getSubtotal())}",
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.right,
                ),
              ))
            ],
          ),
        ),
      ],
    );
  }

  Widget _showListItems(List<SaleOnlineOrderDetail> items) {
    return Material(
        color: Colors.white,
        child: Scrollbar(
          child: ListView.separated(
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (ctx, index) {
              return Dismissible(
                direction: DismissDirection.endToStart,
                key: Key(
                    "${items[index].productId.toString()}${items[index].uomId}"),
                child: _showItem(items[index], index),
                background: Container(
                  padding: EdgeInsets.all(20),
                  color: Colors.red,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Text("Xóa sản phẩm: "),
                      ),
                      RaisedButton(
                        child: Text("Xóa"),
                        color: Colors.red,
                        onPressed: () {},
                      )
                    ],
                  ),
                ),
                onDismissed: (direction) {
                  setState(() {
                    if (items.contains(items[index])) {
                      items.remove(items[index]);
                    }
                  });
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
            itemCount: items.length,
          ),
        ));
  }

  Widget _showItem(SaleOnlineOrderDetail item, int index) {
    TextStyle itemTextStyle = new TextStyle(color: Colors.black);
    return ListTile(
      contentPadding: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
      title: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: CircleAvatar(
              child: Text("${index + 1}"),
              radius: 10,
            ),
          ),
          RichText(
            text: TextSpan(
              style: itemTextStyle,
              children: [
                TextSpan(
                  text: "${item.productName ?? ""}",
                  style: itemTextStyle,
                ),
                TextSpan(
                  text: " (${item.uomName})",
                  style: itemTextStyle.copyWith(color: Colors.blue),
                )
              ],
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Text(
                "${vietnameseCurrencyFormat(item.price ?? 0)}",
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
              flex: 1,
              child: SizedBox(
                child: NumberInputLeftRightWidget(
                  key: Key(item.productId.toString()),
                  value: item.quantity,
                  fontWeight: FontWeight.bold,
                  onChanged: (value) {
                    _viewModel.updateQuantityCommand(item, value);
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
                builder: (ctx) => SaleOnlineOrderLineEditPage(item)));
      },
    );
  }
}

//class SaleOnlineOrderLineItemWidget extends StatelessWidget {
//  SaleOnlineOrderDetail orderLine;
//  Function(void) onDeletePress;
//  Function(void) onEditPress;
//  Function(SaleOnlineOrderDetail) onChanged;
//  SaleOnlineOrderLineItemWidget(SaleOnlineOrderDetail orderLine,
//      {this.onDeletePress, this.onEditPress}) {
//    this.orderLine = orderLine;
//  }
//  @override
//  Widget build(BuildContext context) {
//    return Material(
//      child: new Row(
//        crossAxisAlignment: CrossAxisAlignment.start,
//        mainAxisSize: MainAxisSize.min,
//        children: <Widget>[
//          new Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: <Widget>[
//              new SizedBox(
//                height: 50,
//                width: 60,
//                child: Image.asset("images/no_image.png"),
//              ),
//              new SizedBox(
//                width: 60,
//                child: FlatButton(
//                  textColor: ColorResource.hyperlinkColor,
//                  child: Text(
//                    "Sửa",
//                    textAlign: TextAlign.left,
//                  ),
//                  onPressed: () {
////                    Navigator.push(
////                        context,
////                        MaterialPageRoute(
////                            builder: (ctx) => FastSaleOrderLineEditPage(line)));
//                  },
//                ),
//              )
//            ],
//          ),
//          new Expanded(
//            child: Column(
//              crossAxisAlignment: CrossAxisAlignment.stretch,
//              mainAxisSize: MainAxisSize.max,
//              children: <Widget>[
//                new Row(
//                  children: <Widget>[
//                    Expanded(
//                      child: Text(
//                        "${orderLine.productName}",
//                        style: TextStyle(
//                            fontSize: 15,
//                            color: Colors.black,
//                            fontWeight: FontWeight.bold),
//                      ),
//                    ),
//                    SizedBox(
//                      width: 60,
//                      height: 30,
//                      child: FlatButton(
//                        textColor: Colors.red,
//                        child: Text("Xóa"),
//                        onPressed: () async {
//                          if (await showQuestion(
//                                  context: context,
//                                  title: "Xác nhận",
//                                  message: "Xác nhận xóa sản phẩm ") ==
//                              DialogResult.Yes) {
//                            if (this.onDeletePress != null) onDeletePress(null);
//                          }
//                        },
//                      ),
//                    )
//                  ],
//                ),
//                new SizedBox(
//                  height: 5,
//                ),
//                // Số lượng
//                new Row(
//                  children: <Widget>[
//                    new Container(
//                      padding: EdgeInsets.all(5),
//                      height: 35,
//                      child: Row(
//                        mainAxisSize: MainAxisSize.min,
//                        children: <Widget>[
//                          SizedBox(
//                            width: 30,
//                            child: OutlineButton(
//                              child: Icon(
//                                Icons.remove,
//                                size: 12,
//                              ),
//                              onPressed: () {
//                                _viewModel.changeQuantityOfProductCommand(
//                                    line, false);
//                              },
//                              padding: EdgeInsets.all(0),
//                            ),
//                          ),
//                          new SizedBox(
//                            width: 5,
//                          ),
//                          SizedBox(
//                            width: 120,
//                            child: OutlineButton(
//                              child: Text("${line.productUOMQty}"),
//                              onPressed: () async {
//                                var value = await showDialog(
//                                    context: context,
//                                    builder: (ctx) {
//                                      return new NumberInputDialogWidget(
//                                        currentValue: line.productUOMQty,
//                                      );
//                                    });
//
//                                if (value != null) {
//                                  _viewModel.updateOrderLineQuantityCommand(
//                                      line, value);
//                                }
//                              },
//                            ),
//                          ),
//                          new SizedBox(
//                            width: 5,
//                          ),
//                          new SizedBox(
//                            width: 30,
//                            child: OutlineButton(
//                              child: Icon(
//                                Icons.add,
//                                size: 12,
//                              ),
//                              padding: EdgeInsets.all(0),
//                              onPressed: () {
//                                _viewModel.changeQuantityOfProductCommand(
//                                    line, true);
//                              },
//                            ),
//                          ),
//                        ],
//                      ),
//                    ),
//                  ],
//                ),
//                new SizedBox(
//                  height: 5,
//                ),
//
//                // Đơn giá
//                new Row(
//                  children: <Widget>[
//                    new Container(
//                      padding: EdgeInsets.all(5),
//                      height: 35,
//                      child: Row(
//                        mainAxisSize: MainAxisSize.min,
//                        children: <Widget>[
//                          new SizedBox(
//                            width: 30,
//                            child: OutlineButton(
//                              child: Icon(
//                                Icons.remove,
//                                size: 12,
//                              ),
//                              onPressed: () {
//                                _viewModel.changePriceOfProductCommand(
//                                    line, false);
//                              },
//                              padding: EdgeInsets.all(0),
//                            ),
//                          ),
//                          new SizedBox(
//                            width: 5,
//                          ),
//                          SizedBox(
//                            width: 120,
//                            child: OutlineButton(
//                              child: Text(
//                                  "${vietnameseCurrencyFormat(line.priceUnit)}"),
//                              onPressed: () async {
//                                var value = await showDialog(
//                                    context: context,
//                                    builder: (ctx) {
//                                      return new NumberInputDialogWidget(
//                                        currentValue: line.priceUnit,
//                                      );
//                                    });
//
//                                print(value);
//                                if (value != null) {
//                                  _viewModel.updateOrderLinePriceCommand(
//                                      line, value);
//                                }
//                              },
//                            ),
//                          ),
//                          new SizedBox(
//                            width: 5,
//                          ),
//                          new SizedBox(
//                            width: 30,
//                            child: OutlineButton(
//                              child: Icon(
//                                Icons.add,
//                                size: 12,
//                              ),
//                              onPressed: () {
//                                _viewModel.changePriceOfProductCommand(
//                                    line, true);
//                              },
//                              padding: EdgeInsets.all(0),
//                            ),
//                          ),
//                        ],
//                      ),
//                    ),
//                  ],
//                ),
//
//                // Tổng cộng
//                new Text(
//                  "${vietnameseCurrencyFormat(line.productUOMQty * line.priceUnit)}",
//                  textAlign: TextAlign.right,
//                  style: TextStyle(
//                    fontSize: 20,
//                    color: Colors.red,
//                  ),
//                )
//              ],
//            ),
//          ),
//        ],
//      ),
//    );
//  }
//}
