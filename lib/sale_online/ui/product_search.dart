import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logging/logging.dart';
import 'package:random_color/random_color.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/sale_online/ui/product_template_quick_add_edit_page.dart';
import 'package:tpos_mobile/sale_online/viewmodels/viewmodel.dart';
import 'package:tpos_mobile/src/tpos_apis/models/ProductTemplate.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product_category.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product_price.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';
import 'package:tpos_mobile/widgets/ModalWaitingWidget.dart';
import 'package:tpos_mobile/widgets/listview_data_error_info_widget.dart';

class ProductSearchDelegate extends SearchDelegate {
  Function(Product) onSelected;
  ProductSearchViewModel _vm;
  Logger _log = new Logger("ProductSearchDelegate");
  String lastQuery = "";
  String initQuery;

  ProductSearchDelegate(
      {ProductSearchViewModel vm, ProductPrice priceList, String keyword}) {
    _vm = vm ?? locator<ProductSearchViewModel>();
    _vm.setPriceList(priceList);
    initQuery = keyword;

    Timer(Duration(seconds: 1), () {
      query = keyword;
    });
    print(this.query);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    var _theme = Theme.of(context);
    return [
      IconButton(
        icon: Icon(
          Icons.cancel,
          color: Colors.black54,
        ),
        onPressed: () {
          query = "";
        },
      ),
      IconButton(
        icon: Icon(
          Icons.add,
          color: _theme.primaryColor,
        ),
        onPressed: () async {
          ProductTemplate addedProduct = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProductTemplateQuickAddEditPage(
                        closeWhenDone: true,
                      )));

          if (addedProduct != null) {
            query = addedProduct.name;
          }
        },
      ),
      IconButton(
        color: _theme.primaryColor,
        icon: SvgPicture.asset(
          "images/barcode_scan.svg",
          width: 25,
          height: 25,
        ),
        onPressed: () async {
          var result = await scanBarcode();
          if (result.isError) {}

          query = result.result;
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query != lastQuery) {
      _vm._keywordSubject.add(query);
      lastQuery = query;
    }

    return _buildLayout(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _vm._keywordSubject.add(query);
    return ModalWaitingWidget(
      isBusyStream: _vm.isBusyController,
      initBusy: false,
      child: _buildLayout(context),
    );
  }

  Widget _buildLayout(BuildContext context) {
    var _style = TextStyle(fontSize: 14);
    return Column(
      children: <Widget>[
        //TODO lọc theo nhóm
        Container(
          height: 40,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade500, width: 0.5)),
          child: Row(
            children: <Widget>[
//              Expanded(
//                child: FlatButton(
//                  child: Row(
//                    mainAxisSize: MainAxisSize.max,
//                    children: <Widget>[
//                      Expanded(
//                          child: Text(
//                        "${_vm.selectProductCategory?.name ?? "Chọn nhóm"}",
//                        style: _style,
//                      )),
//                      Icon(Icons.arrow_drop_down)
//                    ],
//                  ),
//                  onPressed: () async {
//                    ProductCategory cat = await Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                        builder: (context) => ProductCategoryPage(
//                          closeWhenDone: true,
//                          isSearchMode: true,
//                        ),
//                      ),
//                    );
//
//                    _vm.selectProductCategory = cat;
//                  },
//                ),
//              ),
//              Container(
//                margin: EdgeInsets.only(left: 3, right: 3, top: 3, bottom: 3),
//                width: 1,
//                color: Colors.grey,
//              ),
              Expanded(
                child: FlatButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                          child: Text(
                        "Bảng giá: ${_vm.priceList?.name ?? "Giá cố định"}",
                        style: _style,
                      )),
                      Icon(Icons.arrow_drop_down)
                    ],
                  ),
                  onPressed: () {},
                ),
              ),

              OutlineButton(
                child: Icon(Icons.format_list_bulleted),
                onPressed: () {},
              ),
//              Container(
//                margin: EdgeInsets.only(left: 3, right: 3, top: 3, bottom: 3),
//                width: 1,
//                color: Colors.grey,
//              ),
//              Expanded(
//                child: FlatButton(
//                  child: Row(
//                    mainAxisSize: MainAxisSize.max,
//                    children: <Widget>[
//                      Expanded(
//                          child: Text(
//                        "Nhóm",df
//                        style: _style,
//                      )),
//                      Icon(Icons.arrow_drop_down)
//                    ],
//                  ),
//                ),
//              ),
            ],
          ),
        ),
        Expanded(
          child: _showListProduct(),
        ),
      ],
    );
  }

  Widget _showLineItem(Product item, BuildContext context) {
    final defaultFontStyle = new TextStyle(fontSize: 14);
    return ListTile(
      contentPadding: EdgeInsets.only(left: 5, right: 5, top: 0, bottom: 0),
      leading: SizedBox.fromSize(
        size: Size(40, 40),
        child: Builder(builder: (ctx) {
          if (item.imageUrl != null && item.imageUrl != "") {
            return Image.network(item.imageUrl);
          } else {
            return CircleAvatar(
              backgroundColor: RandomColor().randomColor(),
              child: Text(
                item.name.substring(0, 1),
              ),
            );
          }
        }),
      ),
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
        "${vietnameseCurrencyFormat(item.price)}",
        style: TextStyle(color: Colors.red),
      ),
      subtitle:
          Text("Tồn: ${item.inventory} | Dự báo: ${item.focastInventory}"),
      onTap: () {
        if (onSelected != null) {
          onSelected(item);
        }
        this.close(context, item);
        _vm.dispose();
      },
    );
  }

  //TODO Gridview
//  Widget _showGridItem(Product item, BuildContext context) {}

  Widget _showListProduct() {
    return StreamBuilder<List<Product>>(
      stream: _vm.productsStream,
      initialData: null,
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
            padding: EdgeInsets.only(left: 10, right: 10),
            itemCount: (snapshot.data.length ?? 0),
            separatorBuilder: (context, index) {
              return Divider(
                height: 1,
                indent: 50,
              );
            },
            itemBuilder: (context, position) {
              return _showLineItem(snapshot.data[position], context);
            },
          ),
        );
      },
    );
  }

  Widget _showGridProduct() {
    return StreamBuilder<List<Product>>(
      stream: _vm.productsStream,
      initialData: null,
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
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 150),
            padding: EdgeInsets.only(left: 10, right: 10),
            itemCount: (snapshot.data.length ?? 0),
            itemBuilder: (context, position) {
              return _showLineItem(snapshot.data[position], context);
            },
          ),
        );
      },
    );
  }

//  @override
//  ThemeData appBarTheme(BuildContext context) {
//    var _theme = Theme.of(context);
//
//    return ThemeData(
//        backgroundColor: _theme.primaryColor,
//        primaryColor: _theme.primaryColor,
//        accentColor: Colors.white,
//        primaryTextTheme: TextTheme(caption: TextStyle(color: Colors.white)),
//        iconTheme: IconThemeData(color: Colors.white));
//  }
}

class ProductSearchViewModel extends ViewModel {
  ITposApiService _tposApi;
  Logger _log = new Logger("ProductSearchViewModel");

  ProductSearchViewModel({ITposApiService tposApi}) {
    _tposApi = tposApi ?? locator<ITposApiService>();

    _keywordSubject.debounceTime(new Duration(milliseconds: 500)).listen((key) {
      _search(key);
    });

    onStateAdd(false);
  }

  String _keyword = "";
  String get keyword => _keyword;
  int _lastSkip = 0;
  int _maxResult = 0;
  double scrollOffset = 0;
  ProductPrice priceList;
  Map<String, dynamic> _priceListMap;
  List<Product> _products;

  ProductCategory _selectProductCategory;
  ProductCategory get selectProductCategory => _selectProductCategory;
  set selectProductCategory(ProductCategory value) {
    _selectProductCategory = value;
    onPropertyChanged("");
  }

  Future setPriceList(ProductPrice priceList) async {
    try {
      this.priceList = priceList;
      if (priceList == null) return;
      _priceListMap = await _tposApi.getPriceListItems(priceList?.id);
    } catch (e, s) {
      _log.severe("get price list", e, s);
    }
  }

  Future loadInventory() async {
    try {
      inventories = await _tposApi.getProductInventory();
    } catch (e, s) {
      print(e);
    }
  }

  bool get canLoadMore {
    return (_lastSkip ?? 0) < (_maxResult ?? 0);
  }

  Map<String, dynamic> inventories;

  BehaviorSubject<List<Product>> _productsSubject =
      new BehaviorSubject<List<Product>>();

  var _categorySubject = new BehaviorSubject<List<ProductCategory>>();

  Stream<List<Product>> get productsStream => _productsSubject.stream;
  Stream<List<ProductCategory>> get categorySubject => _categorySubject.stream;
  BehaviorSubject<String> _keywordSubject = new BehaviorSubject<String>();

  StreamSubscription _searchSub;
  Future _search(String key) async {
    String tempKey = removeVietnameseMark(key ?? "").toLowerCase();
    onStateAdd(true);
    try {
      _searchSub?.cancel();
      _searchSub = _tposApi.productSearch(tempKey, top: 100).asStream().listen(
        (result) {
          if (_productsSubject.isClosed == false) {
            if (result.error) {
              _productsSubject.addError(result.message);
            }

            //if (result.keyword == key) {
            _products = result.result;
            // Map price list

            _products.forEach((f) {
              if (_priceListMap != null) {
                f.price = _priceListMap["${f.id}_${f.uOMId}"] ?? f.price;
              }

              if (inventories != null) {
                f.inventory = (inventories[f.id.toString()] != null
                    ? inventories[f.id.toString()]["QtyAvailable"]?.toDouble()
                    : 0);
                f.focastInventory = (inventories[f.id.toString()] != null
                    ? inventories[f.id.toString()]["VirtualAvailable"]
                        ?.toDouble()
                    : 0);
              }
            });
            _productsSubject.add(_products);
            onStateAdd(false);
            //}
          }
        },
      )..onError((e, s) {
          onStateAdd(false);
          _log.severe("find product error", e, s);
          onDialogMessageAdd(OldDialogMessage.error("", "", error: e));
          _productsSubject.addError(e, s);
        });
    } catch (e, s) {
      _productsSubject.addError(e, s);
      _log.severe("_search", e, s);
      onStateAdd(false);
    }
  }

  @override
  void dispose() {
    // sưddsd_productsSubject.close();
    // super.dispose();
  }
}
