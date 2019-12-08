/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:52 AM
 *
 */

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/app_core/template_ui_function/template_ui_function.dart';
import 'package:tpos_mobile/app_core/ui_base/app_bar_button.dart';

import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';

import 'package:tpos_mobile/sale_online/ui/product_category_page.dart';
import 'package:tpos_mobile/src/tpos_apis/models/ProductTemplate.dart';
import 'package:tpos_mobile/src/tpos_apis/models/base_list_order_by_type.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product.dart';

import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/sale_online/ui/product_template_quick_add_edit_page.dart';
import 'package:tpos_mobile/sale_online/viewmodels/product_template_search_viewmodel.dart';
import 'package:tpos_mobile/widgets/custom_widget.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

class ProductTemplateSearchPage extends StatefulWidget {
  final bool closeWhenDone;
  final bool isSearchMode;
  final Function(ProductTemplate) onSelectedCallback;
  final String keyWord;
  ProductTemplateSearchPage(
      {this.closeWhenDone = true,
      this.isSearchMode = true,
      this.onSelectedCallback,
      this.keyWord = ""});
  @override
  _ProductTemplateSearchPageState createState() =>
      _ProductTemplateSearchPageState(
          closeWhenDone: this.closeWhenDone,
          isSearchMode: this.isSearchMode,
          onSelectedCallback: this.onSelectedCallback,
          keyWord: keyWord);
}

class _ProductTemplateSearchPageState extends State<ProductTemplateSearchPage> {
  bool closeWhenDone;
  bool isSearchMode;
  String keyWord;
  Function(ProductTemplate) onSelectedCallback;
  _ProductTemplateSearchPageState(
      {this.closeWhenDone,
      this.isSearchMode = true,
      this.onSelectedCallback,
      this.keyWord});

  ProductTemplateSearchViewModel productViewModel =
      new ProductTemplateSearchViewModel();
  ISettingService _settingService = locator<ISettingService>();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _scrollController = new ScrollController();

  @override
  void dispose() {
    super.dispose();
    productViewModel.dispose();
  }

  void _showSelectProductCategory(BuildContext context) async {
    var selectedCatetory = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ProductCategoryPage()));

    if (selectedCatetory != null) {
      productViewModel.selectedProductCategory = selectedCatetory;
    }
  }

  void _showEditProductCategory(BuildContext context) {
    showEditDialog(
      context: context,
      title: Text("${productViewModel.selectedProductCategory?.name}"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ProductTemplateSearchViewModel>(
      model: productViewModel,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.grey.shade200,
        appBar: buildAppBar(context),
        body: ViewBaseWidget(
          isBusyStream: productViewModel.isBusyController,
          child: Scrollbar(
            child: ScopedModelDescendant<ProductTemplateSearchViewModel>(
              builder: (_, __, ___) => Column(
                children: <Widget>[
                  //TODO
//              AppFilterListHeader(
//                height: 45,
//                childs: [
//                  AppFilterListHeaderItem(
//                    hint: "Bảng giá",
//                    value: productViewModel.selectedPriceList?.name,
//                    onPressed: () {},
//                  ),
//                  AppFilterListHeaderItem(
//                    hint: "Nhóm sản phẩm",
//                    value: productViewModel.selectedProductCategory?.name,
//                    onPressed: () {
//                      if (productViewModel.selectedProductCategory != null)
//                        _showEditProductCategory(context);
//                      else
//                        _showSelectProductCategory(context);
//                    },
//                  ),
//                ],
//              ),
                  Expanded(
                    child: CustomScrollView(
                      slivers: <Widget>[
                        SliverList(
                          delegate: SliverChildListDelegate([
                            _showFilterPanel(),

//                Expanded(
//                  child: _settingService.isProductSearchViewList
//                      ? _showListProduct()
//                      : _showListProductSquare(),
//                ),
                          ]),
                        ),
                        if (_settingService.isProductSearchViewList)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                                (context, index) => _showLineItem(
                                    productViewModel.products[index], index),
                                childCount:
                                    productViewModel.products?.length ?? 0),
                          ),
                        if (!_settingService.isProductSearchViewList)
                          SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 230,
                                    childAspectRatio: 0.85,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8),
                            delegate: SliverChildBuilderDelegate(
                                (context, index) => ProductTemplateGridItem(
                                      item: productViewModel.products[index],
                                    ),
                                childCount:
                                    productViewModel.products?.length ?? 0),
                          ),
                        SliverList(
                          delegate: SliverChildListDelegate([
                            if (productViewModel.canLoadMore)
                              Container(
                                padding: EdgeInsets.all(12),
                                child: RaisedButton(
                                  shape: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: BorderSide(
                                          width: 0.5, color: Colors.blue)),
                                  color: Colors.blue,
                                  textColor: Colors.white,
                                  child: productViewModel.isLoadingMore
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(),
                                        )
                                      : Text("Tải thêm"),
                                  onPressed: () {
                                    productViewModel.loadMoreProductCommand();
                                  },
                                ),
                              )
                          ]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
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
                productViewModel.keyword = barcode;
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
        new AppbarIconButton(
          isEnable: productViewModel.canAdd,
          icon: new Icon(Icons.add),
          onPressed: () async {
            ProductTemplate addProduct = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (ctx) => ProductTemplateQuickAddEditPage(
                          closeWhenDone: true,
                        )));

            if (addProduct != null) {
              productViewModel.addNewProductCommand(new Product(
                id: addProduct.id,
                name: addProduct.name,
                nameGet: addProduct.nameGet,
                nameNoSign: addProduct.nameNoSign,
                price: addProduct.price,
                oldPrice: addProduct.oldPrice,
                uOMId: addProduct.uOMId,
                weight: addProduct.weight,
              ));
            }
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
                if (!isSearchMode) {
                  if (!productViewModel.isViewAsList)
                    productViewModel.onDialogMessageAdd(
                        new OldDialogMessage.flashMessage(
                            "Nhấn giữ sản phẩm để xóa"));
                  else
                    productViewModel.onDialogMessageAdd(
                        new OldDialogMessage.flashMessage(
                            "Vuốt sang trái để xóa sản phẩm"));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _showLineItem(ProductTemplate item, int index) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      key: Key("${item.id}"),
      background: Container(
        color: Colors.green,
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
              color: Colors.red,
              size: 40,
            )
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        var dialogResult = await showQuestion(
            context: context,
            title: "Xác nhận xóa",
            message: "Bạn có muốn xóa sản phẩm ${item.name}?");

        if (dialogResult == OldDialogResult.Yes) {
          var result = await productViewModel.deleteProductTemplate(item.id);
          if (result) productViewModel.products.removeAt(index);
          return result;
        } else {
          return false;
        }
      },
      onDismissed: (direction) async {},
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.white),
        child: ListTile(
          contentPadding:
              EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
          leading: item.imageUrl != null
              ? ClipRRect(
                  child: Image.network(
                    item.imageUrl,
                    width: 50,
                    height: 50,
                  ),
                  borderRadius: BorderRadius.circular(5),
                )
              : SizedBox(
                  height: 50,
                  width: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Material(
                      color: Colors.grey.shade200,
                    ),
                  ),
                ),
          title: RichText(
            text: TextSpan(
                text: "",
                style: TextStyle(color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                    text: "${item.name}",
                    style: TextStyle(color: Colors.black),
                  ),
                  TextSpan(
                    text: " [${item.defaultCode ?? ""}] ",
                    style: TextStyle(color: Colors.black),
                  ),
                  TextSpan(
                      text: ' (${item.uOMName ?? ""})',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue)),
                ]),
          ),
          subtitle: Row(
            children: <Widget>[
              Text(
                "SL Thực: ${NumberFormat("###,###,###.##").format(item.availableQuantity)}",
                style: const TextStyle(color: Colors.deepOrange),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "Dự báo: ${NumberFormat("###,###,###.##").format(item.virtualQuantity)}",
              ),
            ],
          ),
          trailing: Text(
            "${vietnameseCurrencyFormat(item.listPrice)}",
            style: TextStyle(color: Colors.red),
          ),
          onTap: () async {
            if (isSearchMode) {
              if (onSelectedCallback != null) onSelectedCallback(item);
              if (closeWhenDone) {
                Navigator.pop(context, item);
              }
            } else {
              if (productViewModel.canUpdate)
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    ProductTemplateQuickAddEditPage productQuickAddEditPage =
                        new ProductTemplateQuickAddEditPage(
                      productId: item.id,
                    );
                    return productQuickAddEditPage;
                  }),
                );
            }
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    if (keyWord != null && keyWord != "") {
      productViewModel.isBarcode = true;
    }
    productViewModel.keyword = keyWord;
    productViewModel.initCommand();

    productViewModel.dialogMessageController.listen((f) {
      registerDialogToView(context, f, scaffState: _scaffoldKey.currentState);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Load more
        if (productViewModel.isLoadingMore) return;
        productViewModel.loadMoreProductCommand();
      }
    });
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

class ProductTemplateGridItem extends StatelessWidget {
  final ProductTemplate item;
  final VoidCallback onPress;
  final VoidCallback onLongPress;
  ProductTemplateGridItem({this.item, this.onPress, this.onLongPress});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 300,
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: Colors.white,
        ),
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Container(
                height: 110,
                color: Colors.white,
                child: Image.network("${item.imageUrl}"),
              ),
            ),
            Container(
              height: 1,
              color: Colors.grey.shade200,
              margin: EdgeInsets.all(8),
            ),
            Text(
              "${item.nameGet}",
              textAlign: TextAlign.center,
            ),
            Text(
              "${vietnameseCurrencyFormat(item.price)}",
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(
              height: 3,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.deepPurple),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: AutoSizeText(
                  "Còn ${item.availableQuantity} | ${item.virtualQuantity} (DB)",
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: onPress,
      onLongPress: onLongPress,
    );
  }
}
