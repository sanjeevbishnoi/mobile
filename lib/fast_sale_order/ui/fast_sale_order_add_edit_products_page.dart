/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/16/19 5:56 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/16/19 2:33 PM
 *
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/src/tpos_apis/models/fast_sale_order_line.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product.dart';
import 'package:tpos_mobile/fast_sale_order/ui/fast_sale_order_line_edit_page.dart';
import 'package:tpos_mobile/sale_online/ui/product_list_page.dart';
import 'package:tpos_mobile/fast_sale_order/viewmodels/fast_sale_order_add_edit_viewmodel.dart';
import 'package:tpos_mobile/string_resources.dart';
import 'package:tpos_mobile/widgets/custom_widget.dart';

class FastSaleOrderAddEditProductsPage extends StatefulWidget {
  static const String rootName = "/order_list/create_invoice";
  final FastSaleOrderAddEditViewModel viewModel;
  FastSaleOrderAddEditProductsPage(this.viewModel);

  @override
  _FastSaleOrderAddEditProductsPageState createState() =>
      _FastSaleOrderAddEditProductsPageState(this.viewModel);
}

class _FastSaleOrderAddEditProductsPageState
    extends State<FastSaleOrderAddEditProductsPage> {
  _FastSaleOrderAddEditProductsPageState(
      FastSaleOrderAddEditViewModel viewModel) {
    this._viewModel = viewModel;
  }
  FastSaleOrderAddEditViewModel _viewModel;
  StreamSubscription _notifyPropertyChangedSubscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (this.mounted) {
      _notifyPropertyChangedSubscription =
          _viewModel.notifyPropertyChangedController.listen((propertyname) {
        setState(() {});
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ViewBaseStateWidget(
      stateStream: _viewModel.stateController,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Danh sách hàng hóa"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
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
            )
          ],
        ),
        body: _showBody(),
      ),
    );
  }

  Widget _showBody() {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.separated(
              itemBuilder: (ctx, index) {
                return _showListItem(_viewModel.orderLines[index]);
              },
              separatorBuilder: (ctx, index) {
                return Divider();
              },
              itemCount: _viewModel.orderLines.length),
        ),
        Container(
          height: 40,
          color: Colors.green,
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Tổng tiền: ${vietnameseCurrencyFormat(_viewModel.calculateFastSaleOrderAmountFromDetail())}",
                  style: TextStyle(
                      fontSize: 20,
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

  Widget _showListItem(FastSaleOrderLine line) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new SizedBox(
                height: 50,
                width: 60,
                child: Image.asset("images/no_image.png"),
              ),
              new SizedBox(
                width: 60,
                child: FlatButton(
                  textColor: ColorResource.hyperlinkColor,
                  child: Text(
                    "Sửa",
                    textAlign: TextAlign.left,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) => FastSaleOrderLineEditPage(line)));
                  },
                ),
              )
            ],
          ),
          new Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        "${line.productName}",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      height: 30,
                      child: FlatButton(
                        textColor: Colors.red,
                        child: Text("Xóa"),
                        onPressed: () async {
                          if (await showQuestion(
                                  context: context,
                                  title: "Xác nhận",
                                  message: "Xác nhận xóa sản phẩm ") ==
                              OldDialogResult.Yes) {
                            _viewModel.deleteOrderLineCommand(line);
                          }
                        },
                      ),
                    )
                  ],
                ),
                new SizedBox(
                  height: 5,
                ),
                // Số lượng
                new Row(
                  children: <Widget>[
                    new Container(
                      padding: EdgeInsets.all(5),
                      height: 40,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                            width: 30,
                            child: OutlineButton(
                              child: Icon(
                                Icons.remove,
                                size: 12,
                              ),
                              onPressed: () {
                                _viewModel.changeQuantityOfProductCommand(
                                    line, false);
                              },
                              padding: EdgeInsets.all(0),
                            ),
                          ),
                          new SizedBox(
                            width: 5,
                          ),
                          SizedBox(
                            width: 120,
                            child: OutlineButton(
                              child: Text("${line.productUOMQty}"),
                              onPressed: () async {
                                var value = await showDialog(
                                    context: context,
                                    builder: (ctx) {
                                      return new NumberInputDialogWidget(
                                        currentValue: line.productUOMQty,
                                        formats: [
                                          PercentInputFormat(),
                                        ],
                                      );
                                    });

                                if (value != null) {
                                  _viewModel.updateOrderLineQuantityCommand(
                                      line, value);
                                }
                              },
                            ),
                          ),
                          new SizedBox(
                            width: 5,
                          ),
                          new SizedBox(
                            width: 30,
                            child: OutlineButton(
                              child: Icon(
                                Icons.add,
                                size: 12,
                              ),
                              padding: EdgeInsets.all(0),
                              onPressed: () {
                                _viewModel.changeQuantityOfProductCommand(
                                    line, true);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                new SizedBox(
                  height: 5,
                ),

                // Đơn giá
                new Row(
                  children: <Widget>[
                    new Container(
                      padding: EdgeInsets.all(5),
                      height: 35,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new SizedBox(
                            width: 30,
                            child: OutlineButton(
                              child: Icon(
                                Icons.remove,
                                size: 12,
                              ),
                              onPressed: () {
                                _viewModel.changePriceOfProductCommand(
                                    line, false);
                              },
                              padding: EdgeInsets.all(0),
                            ),
                          ),
                          new SizedBox(
                            width: 5,
                          ),
                          SizedBox(
                            width: 120,
                            child: OutlineButton(
                              child: Text(
                                  "${vietnameseCurrencyFormat(line.priceUnit)}"),
                              onPressed: () async {
                                var value = await showDialog(
                                    context: context,
                                    builder: (ctx) {
                                      return new NumberInputDialogWidget(
                                        currentValue: line.priceUnit,
                                        formats: [
                                          PercentInputFormat(
                                              locate: "vi_VN",
                                              format: "###,###,###.###"),
                                        ],
                                      );
                                    });

                                print(value);
                                if (value != null) {
                                  _viewModel.updateOrderLinePriceCommand(
                                      line, value);
                                }
                              },
                            ),
                          ),
                          new SizedBox(
                            width: 5,
                          ),
                          new SizedBox(
                            width: 30,
                            child: OutlineButton(
                              child: Icon(
                                Icons.add,
                                size: 12,
                              ),
                              onPressed: () {
                                _viewModel.changePriceOfProductCommand(
                                    line, true);
                              },
                              padding: EdgeInsets.all(0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Tổng cộng
                new Text(
                  "${vietnameseCurrencyFormat(line.productUOMQty * line.priceUnit)}",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notifyPropertyChangedSubscription.cancel();
    super.dispose();
  }
}
