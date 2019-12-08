/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:52 AM
 *
 */

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/src/tpos_apis/models/ProductTemplate.dart';
import 'package:tpos_mobile/src/tpos_apis/models/base_list_order_by_type.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product.dart';

import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/sale_online/ui/product_quick_add_edit_page.dart';
import 'package:tpos_mobile/sale_online/ui/product_template_quick_add_edit_page.dart';
import 'package:tpos_mobile/sale_online/viewmodels/product_search_viewmodel.dart';
import 'package:tpos_mobile/widgets/custom_widget.dart';
import 'package:tpos_mobile/widgets/listview_data_error_info_widget.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

class ProductListPage extends StatefulWidget {
  final bool closeWhenDone;
  final bool isSearchMode;
  final Function(Product) onSelectedCallback;
  final String keyWord;
  ProductListPage(
      {this.closeWhenDone = true,
      this.isSearchMode = true,
      this.onSelectedCallback,
      this.keyWord = ""});
  @override
  _ProductListPageState createState() => _ProductListPageState(
      closeWhenDone: this.closeWhenDone,
      isSearchMode: this.isSearchMode,
      onSelectedCallback: this.onSelectedCallback,
      keyWord: keyWord);
}

class _ProductListPageState extends State<ProductListPage> {
  bool closeWhenDone;
  bool isSearchMode;
  String keyWord;
  Function(Product) onSelectedCallback;
  _ProductListPageState(
      {this.closeWhenDone,
      this.isSearchMode = true,
      this.onSelectedCallback,
      this.keyWord});

  ProductSearchViewModel productViewModel = new ProductSearchViewModel();
  ISettingService _settingService = locator<ISettingService>();
  @override
  void dispose() {
    super.dispose();
    productViewModel.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: ViewBaseWidget(
        isBusyStream: productViewModel.isBusyController,
        child: Column(
          children: <Widget>[
            _showFilterPanel(),
            Expanded(
              child: _settingService.isProductSearchViewList
                  ? _showListProduct()
                  : _showListProductSquare(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showListProduct() {
    return StreamBuilder<List<Product>>(
      stream: productViewModel.productsStream,
      builder: (ctx, snapshot) {
        if (snapshot.hasError) {
          return ListViewDataErrorInfoWidget(
            errorMessage: "Đã xảy ra lỗi!. \n" + snapshot.error.toString(),
          );
        }

        if (snapshot.data == null) {
          return Center(
            child: Text(""),
          );
        }

        return Scrollbar(
          child: ListView.separated(
            padding: EdgeInsets.only(left: 12, right: 12),
            itemCount: (snapshot.data.length ?? 0) + 1,
            separatorBuilder: (context, index) {
              return Divider(
                height: 1,
              );
            },
            itemBuilder: (context, position) {
              if (position == snapshot.data.length) {
                if (productViewModel.canLoadMore) {
                  return OutlineButton(
                    child: Text(
                      "Tải thêm...",
                      style: TextStyle(color: Colors.blue),
                    ),
                    onPressed: () {
                      productViewModel.loadMoreProductCommand();
                    },
                  );
                } else {
                  return SizedBox();
                }
              }
              return _showLineItem(snapshot.data[position]);
            },
          ),
        );
      },
    );
  }

  Widget _showListProductSquare() {
    return StreamBuilder<List<Product>>(
      stream: productViewModel.productsStream,
      builder: (ctx, snapshot) {
        if (snapshot.hasError) {
          return ListViewDataErrorInfoWidget(
            errorMessage: "Đã xảy ra lỗi!. \n" + snapshot.error.toString(),
          );
        }

        if (snapshot.data == null) {
          return Center(
            child: Text(""),
          );
        }

        return Scrollbar(
          child: GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            padding: EdgeInsets.only(left: 5, right: 5),
            itemCount: snapshot.data.length,
            itemBuilder: (context, position) {
              return Padding(
                padding: const EdgeInsets.all(5),
                child: RaisedButton(
                  color: Colors.green.shade100,
                  textColor: Colors.blueGrey,
                  padding: EdgeInsets.all(5),
                  child: Center(
                    child: Text(
                      snapshot.data[position].name,
                      style: TextStyle(fontSize: 17),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  onPressed: () async {
                    if (isSearchMode) {
                      if (onSelectedCallback != null)
                        onSelectedCallback(snapshot.data[position]);
                      if (closeWhenDone) {
                        Navigator.pop(context, snapshot.data[position]);
                      }
                    } else {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          ProductQuickAddEditPage productQuickAddEditPage =
                              new ProductQuickAddEditPage(
                            productId: snapshot.data[position].id,
                          );
                          return productQuickAddEditPage;
                        }),
                      );
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          }),
      title: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0, top: 8, bottom: 8),
        child: AppbarSearchWidget(
          keyword: productViewModel.keyword,
          autoFocus: isSearchMode,
          onTextChange: (text) {
            productViewModel.keywordChangedCommand(text);
          },
        ),
      ),
      actions: <Widget>[
        new IconButton(
          icon: new Icon(Icons.center_focus_strong),
          onPressed: () async {
            try {
              var barcode = await BarcodeScanner.scan();
              if (barcode != "" && barcode != null) {
                setState(() {
                  productViewModel.keyword = barcode;
                });
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
          },
        ),
        new IconButton(
          icon: new Icon(Icons.add),
          onPressed: () async {
            ProductTemplate addProduct = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (ctx) => ProductTemplateQuickAddEditPage(
                          closeWhenDone: true,
                        )));

            if (addProduct != null) {
              productViewModel.keywordChangedCommand(addProduct.name);
            }

//            if (addProduct != null) {
//              productViewModel.addNewProductCommand(new Product(
//                id: addProduct.id,
//                name: addProduct.name,
//                nameGet: addProduct.nameGet,
//                nameNoSign: addProduct.nameNoSign,
//                price: addProduct.price,
//                oldPrice: addProduct.oldPrice,
//                uOMId: addProduct.uOMId,
//                weight: addProduct.weight,
//              ));
//            }
          },
        ),
      ],
    );
  }

  Widget _showFilterPanel() {
    return Container(
      height: 50,
      child: new Card(
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<BaseListOrderBy>(
                  hint: Text("Sắp xếp"),
                  value: productViewModel.selectedOrderBy,
                  onChanged: (BaseListOrderBy selectedOrderBy) {
                    productViewModel.selectOrderByCommand(selectedOrderBy);
                  },
                  items: productViewModel.orderByList.keys
                      .map(
                        (f) => new DropdownMenuItem<BaseListOrderBy>(
                          value: f,
                          child: Text(productViewModel.orderByList[f]),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            Expanded(
              child: Text(""),
            ),
            IconButton(
              splashColor: Colors.green,
              tooltip: "Danh sách ngang",
              icon: new Icon(productViewModel.isViewAsList == true
                  ? FontAwesomeIcons.thLarge
                  : FontAwesomeIcons.list),
              onPressed: () {
                productViewModel
                    .changeViewTypeCommand(!productViewModel.isViewAsList);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _showLineItem(Product item) {
    final defaultFontStyle = new TextStyle(fontSize: 14);
    return ListTile(
      contentPadding: EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 0),
      //leading: Image.asset("images/no_image.png"),
      title: Wrap(
        children: <Widget>[
          Text(
            "${item.nameGet}",
            style: defaultFontStyle,
          ),
//          Text(
//            " [${item.defaultCode ?? ""}] ",
//            style: defaultFontStyle,
//          ),
          Text(' (${item.uOMName ?? ""})',
              maxLines: null,
              softWrap: true,
              style: defaultFontStyle.copyWith(
                  fontWeight: FontWeight.bold, color: Colors.blue)),
          Text(""),
        ],
      ),
      trailing: Text(
        "${vietnameseCurrencyFormat(item.price) ?? 0}",
        style: TextStyle(color: Colors.red),
      ),
      onTap: () async {
        if (isSearchMode) {
          if (onSelectedCallback != null) onSelectedCallback(item);
          if (closeWhenDone) {
            Navigator.pop(context, item);
          }
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              ProductQuickAddEditPage productQuickAddEditPage =
                  new ProductQuickAddEditPage(
                productId: item.id,
              );
              return productQuickAddEditPage;
            }),
          );
        }
      },
    );
  }

//  Widget _showSquarePictureItem(Product item) {
//    return RaisedButton(
//      child: Text(""),
//      onPressed: () {},
//    );
//  }

  @override
  void initState() {
    if (keyWord != null && keyWord != "") {
      productViewModel.isBarcode = true;
    }
    productViewModel.keyword = keyWord;
    productViewModel.initCommand();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    productViewModel.notifyPropertyChangedController.listen((f) {
      setState(() {});
    });
    super.didChangeDependencies();
  }
}
