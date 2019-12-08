import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tpos_mobile/app_core/helper/string_helper.dart';
import 'package:tpos_mobile/app_core/template_ui/app_filter_drawer.dart';
import 'package:tpos_mobile/app_core/ui_base/view_base.dart';
import 'package:tpos_mobile/pos_order/models/cart_product.dart';
import 'package:tpos_mobile/pos_order/models/price_list.dart';
import 'package:tpos_mobile/pos_order/ui/pos_price_list_page.dart';
import 'package:tpos_mobile/pos_order/viewmodels/pos_product_list_viewmodel.dart';
import 'package:tpos_mobile/widgets/appbar_search_widget.dart';

import '../../app_service_locator.dart';

class PosProductListPage extends StatefulWidget {
  PosProductListPage(this.positionCart);
  final String positionCart;
  @override
  _PosProductListPageState createState() => _PosProductListPageState();
}

class _PosProductListPageState extends State<PosProductListPage> {
  var _vm = locator<PosProductListViewmodel>();
  bool _isSearchEnable = false;

  var _key = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ViewBase<PosProductListViewmodel>(
        model: _vm,
        builder: (context, model, _) {
          return Scaffold(
            key: _key,
            appBar: buildAppBar(context),
            endDrawer: builFilterPanel(),
            body: Stack(
              children: <Widget>[
                Positioned(
                  top: 0,
                  child: buildFilter(),
                ),
                Container(
                  padding:
                      EdgeInsets.only(left: 4, right: 4, bottom: 55, top: 45),
                  child: ListView.builder(
                      itemCount: _vm.products.length,
                      itemBuilder: (BuildContext context, int index) {
                        return showItem(_vm.products[index], index);
                      }),
                ),
                _buildBtnClose()
              ],
            ),
          );
        });
  }

  Widget _buildBtnClose() {
    return Positioned(
      bottom: 6,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 45,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                  offset: Offset(0, 2), blurRadius: 2, color: Colors.grey[400])
            ], color: Colors.orange, borderRadius: BorderRadius.circular(6)),
            child: FlatButton(
                color: Colors.orange,
                onPressed: () async {
                  await _vm.insertProductForCart(widget.positionCart);
                  Navigator.pop(context);
                },
                child: Text(
                  "Đóng",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                )),
          ),
        ),
      ),
    );
  }

  Widget builFilterPanel() {
    return AppFilterDrawerContainer(
      onRefresh: () {
        _vm.resetFilter();
      },
      closeWhenConfirm: true,
      onApply: () {
        _vm.handleFilter();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text("Sắp xếp"),
          ),
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]),
                    borderRadius: BorderRadius.all(Radius.circular(4))),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: filter()),
          ),
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "Bảng giá",
              style: TextStyle(fontSize: 16),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                new MaterialPageRoute(builder: (context) => PosPriceListPage()),
              ).then((value) {
                if (value != null) {
                  _vm.priceList = value;
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey[300])),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        "${_vm.priceList.name ?? ""}",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Visibility(
                      visible: _vm.priceList.name == null ? false : true,
                      child: InkWell(
                        onTap: () {
                          _vm.priceList = PriceList();
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[600],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  DropdownButton filter() => DropdownButton<String>(
          items: [
            DropdownMenuItem<String>(
              value: "1",
              child: Text(
                "Mặc định",
              ),
            ),
            DropdownMenuItem<String>(
              value: "2",
              child: Text(
                "Bán chạy",
              ),
            ),
            DropdownMenuItem<String>(
              value: "3",
              child: Text(
                "Theo tên",
              ),
            ),
          ],
          onChanged: (value) {
            _vm.changePositionStack(value);
          },
          value: _vm.filterStack,
          elevation: 2,
          style: TextStyle(color: Colors.grey[800], fontSize: 17),
          isDense: true,
          isExpanded: true,
          underline: SizedBox());

  Widget buildFilter() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(offset: Offset(0, 2), blurRadius: 2, color: Colors.grey[400])
      ]),
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, right: 15.0),
        child: new GestureDetector(
          onTap: () {
            _key.currentState.openEndDrawer();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Badge(
                badgeColor: Colors.redAccent,
                badgeContent: Text(
                  "${_vm.countFilter()}",
                  style: const TextStyle(color: Colors.white),
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
    );
  }

  Widget buildAppBar(BuildContext context) {
      return new AppBar(
      title: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0, top: 7, bottom: 7),
        child: _isSearchEnable
            ? AppbarSearchWidget(
                autoFocus: true,
                keyword: _vm.keyword,
                onTextChange: (text) async {
                  _vm.setKeyword(text);
                },
              )
            : Text("Danh sách sản phẩm"),
      ),
      actions: <Widget>[
        new IconButton(
          icon: new Icon(Icons.search),
          onPressed: () async {
            setState(() {
              _isSearchEnable = !_isSearchEnable;
            });
          },
        ),
      ],
    );
  }

  Widget showItem(CartProduct item, int index) {
    return InkWell(
      onTap: () {
        _vm.incrementQtyProduct(item, index, widget.positionCart);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 3),
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 2), blurRadius: 2, color: Colors.grey[400]),
          ],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                height: 90,
                width: 60,
                child: item.imageUrl == null
                    ? Image.asset("images/no_image.png")
                    : Image.network(
                        "${item.imageUrl}",
                      ),
              ),
            ),
            SizedBox(
              width: 6,
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 6,
                  ),
                  Text("${item.nameGet} (${item.uOMName})"),
                  SizedBox(
                    height: 6,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(child: Text("Đơn vị: ${item.uOMName}")),
                      Expanded(
                        child: Text(
                          "SL: ${item.qty}",
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              fontSize: 18,
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.w700),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text("Giá: ${vietnameseCurrencyFormat(item.price)}"),
                  SizedBox(
                    height: 6,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _vm.getProducts();
  }
}
