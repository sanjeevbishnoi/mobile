import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tpos_mobile/app_core/helper/string_helper.dart';
import 'package:tpos_mobile/app_core/ui_base/view_base.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/app_helper.dart';
import 'package:tpos_mobile/pos_order/models/payment.dart';
import 'package:tpos_mobile/pos_order/models/state_cart.dart';
import 'package:tpos_mobile/pos_order/ui/pos_money_cart_page.dart';
import 'package:tpos_mobile/pos_order/ui/pos_product_list_page.dart';
import 'package:tpos_mobile/pos_order/viewmodels/pos_cart_viewmodel.dart';
import 'package:tpos_mobile/services/dialog_service.dart';

class PosCartPage extends StatefulWidget {
  @override
  _PosCartPageState createState() => _PosCartPageState();
}

class _PosCartPageState extends State<PosCartPage> {
  var _vm = locator<PosCartViewModel>();

  TextEditingController _controllerSoLuong = TextEditingController();
  TextEditingController _controllerDonGia = TextEditingController();
  TextEditingController _controllerChietKhau = TextEditingController();
  TextEditingController _controllerGhiChu = TextEditingController();

  FocusNode _focusSoLuong = FocusNode();
  FocusNode _focusDonGia = FocusNode();
  FocusNode _focusChietKhau = FocusNode();

  @override
  Widget build(BuildContext context) {
    return ViewBase<PosCartViewModel>(
        model: _vm,
        builder: (context, model, sizingInformation) {
          return WillPopScope(
            onWillPop: () async {
              return await confirmClosePage(context,
                  title: "Xác nhận đóng",
                  message: "Bạn có muốn đóng trang này?");
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text("Giỏ hàng"),
                actions: <Widget>[
                  Center(
                    child: InkWell(
                      onTap: () {
                        _vm.excPayment();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Badge(
                          badgeColor: Colors.redAccent,
                          badgeContent: Text(
                            "${_vm.countPayment}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          child: Icon(Icons.shopping_cart),
                        ),
                      ),
                    ),
                  ),
                  IconButton(icon: Icon(Icons.star),onPressed: (){
                    _vm.handlePromotion();
                  },)
                ],
              ),
              body: Column(
                children: <Widget>[
                  Container(
                    color: Colors.grey[100],
                    padding: EdgeInsets.only(left: 4, right: 4, top: 2),
                    height: 55,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: _buildListItemCart(),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        _buildDeleteCart(),
                        SizedBox(
                          width: 2,
                        ),
                        _buildBtnAddCart(),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Expanded(child: _builContent()),
                ],
              ),
            ),
          );
        });
  }

  Widget _builContent() {
    return Stack(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 85),
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              decoration: BoxDecoration(color: Colors.white
                  //gradient: LinearGradient(colors: [Colors.green[300],Colors.green[400]])
                  ),
              child: _showDanhSachSanPham(),
            ),
          ),
        ),
        _buildButtonAddProduct(),
        _buildButtonTinhTien()
      ],
    );
  }

  Widget _buildBtnAddCart() {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                offset: Offset(-2, 2), color: Colors.grey[300], blurRadius: 2)
          ],
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.grey[600], Colors.green]),
          //shape: BoxShape.circle,
          color: Colors.grey[300]),
      child: Center(
        child: FlatButton(
          onPressed: () {
            _vm.addCart(true);
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteCart() {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                offset: Offset(-2, 2), color: Colors.grey[300], blurRadius: 2)
          ],
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.green, Colors.grey[600]]),
          //shape: BoxShape.circle,
          color: Colors.grey[300]),
      child: Center(
        child: FlatButton(
          onPressed: () {
            if (_vm.positionCart != -1) {
              _vm.deleteCart(isDelete: true);
            }
          },
          child: Icon(
            Icons.remove,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildButtonTinhTien() {
    return Positioned(
      bottom: 6,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 12,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 45,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0, 2),
                          blurRadius: 2,
                          color: Colors.grey[400])
                    ],
                    color: Colors.green[400],
                    borderRadius: BorderRadius.circular(6)),
                child: RaisedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => PosMoneyCartPage(
                                  priceCart: _vm.cartAmountTotal(),
                                  positionCart: _vm.positionCart,
                                )),
                      ).then((val) {
                        if (val != null) {
                          _vm.deleteCart(cart: val, isDelete: false);
                          _vm.countInvoicePayment();
                        }
                      });
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Tính tiền (",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                        Icon(
                          Icons.attach_money,
                          color: Colors.white,
                        ),
                        Text(
                          "${vietnameseCurrencyFormat(_vm.cartAmountTotal())} )",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonAddProduct() {
    return Positioned(
      bottom: 65,
      right: 10,
      child: Container(
        height: 50,
        width: 60,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.orange, Colors.orange]),
            //shape: BoxShape.circle,
            color: Colors.grey[300],
            shape: BoxShape.circle),
        child: Center(
          child: IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              if (_vm.positionCart != "-1") {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) =>
                          PosProductListPage(_vm.positionCart)),
                ).then((value) {
                  _vm.getProductsForCart();
                });
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildListItemCart() {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _vm.childCarts.length,
        itemBuilder: (context, index) {
          return _showItemCart(_vm.childCarts[index], index);
        });
  }

  Widget _showItemCart(StateCart item, int index) {
    return Container(
      margin: EdgeInsets.only(right: 3, left: 3, bottom: 1),
      decoration: BoxDecoration(
          color: _vm.childCarts[index].check == 0
              ? Colors.white
              : Colors.green[500],
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(3), topRight: Radius.circular(3)),
          boxShadow: [
            BoxShadow(offset: Offset(0, 2), blurRadius: 2, color: Colors.grey)
          ]),
      height: 48,
      width: 60,
      child: Center(
        child: FlatButton(
            onPressed: () {
              _vm.handleCheckCart(index);
            },
            child: Text("${_vm.childCarts[index].position}")),
      ),
    );
  }

  Widget _showDanhSachSanPham() {
    return Container(
      height: (MediaQuery.of(context).size.height),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: ListView.builder(
                  itemCount: _vm.lstLine.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
                      child: _showItem(_vm.lstLine[index]),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showItem(Lines item) {
    return Dismissible(
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
              size: 30,
            )
          ],
        ),
      ),
      direction: DismissDirection.endToStart,
      key: UniqueKey(),
      confirmDismiss: (direction) async {
        var dialogResult = await showQuestion(
            context: context,
            title: "Xác nhận xóa",
            message: "Bạn có muốn xóa sản phẩm ${item.productName ?? ""}");

        if (dialogResult == DialogResultType.YES) {
          var result = await _vm.deleteProductCart(item);
          if (result) {
            _vm.removeProduct(item);
            _vm.showNotifyDeleteProduct();
            return result;
          } else {
            return result;
          }
        } else {
          return false;
        }
      },
      child: Container(
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
              onTap: () async {
                dialogEditProduct(context, "Cập nhật thông tin", item);
              },
              title: Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 6),
                child: Row(
                  children: <Widget>[
                    new Expanded(
                      child: new Text(
                        "${item.productName}",
                        textAlign: TextAlign.start,
                      ),
                    ),
                    new Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            _vm.copyProductCart(item);
                          },
                          child: Icon(
                            Icons.content_copy,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              subtitle: Column(
                children: <Widget>[
                  new Text(
                    "Giá: ${vietnameseCurrencyFormat(item.priceUnit)} x ${item.qty}",
                    style: const TextStyle(color: Colors.black),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  new Text(
                    "Tổng : ${vietnameseCurrencyFormat(item.priceUnit * item.qty * (1 - item.discount / 100))} (Chiết khấu: ${vietnameseCurrencyFormat(item.discount)}%)",
                    style: const TextStyle(color: Colors.black),
                  ),
                  new Divider(
                    color: Colors.grey.shade300,
                  ),
                  new Text(
                    "Ghi chú: ${item.note}",
                    style: const TextStyle(color: Colors.black),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            )
          ],
        ),
      ),
    );
  }

  void dialogEditProduct(BuildContext context, String title, Lines line) {
    _controllerGhiChu.text = line.note;
    _controllerSoLuong.text = line.qty.toString();
    _controllerDonGia.text =
        vietnameseCurrencyFormat(line.priceUnit).toString();
    _controllerChietKhau.text = line.discount.floor().toString();
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              width: 0,
            ),
          ),
          title: Center(
            child: new Text(
              title.isNotEmpty ? title : "Xác nhận",
              style: TextStyle(color: Colors.red),
            ),
          ),
          content: Container(
            height: 220,
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: 6,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Số lượng"),
                          _formThongTin(
                              controller: _controllerSoLuong,
                              isGhiChu: false,
                              focusNode: _focusSoLuong),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Chiết khấu(%)"),
                          _formThongTin(
                              controller: _controllerChietKhau,
                              isGhiChu: false,
                              focusNode: _focusChietKhau),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Text("Đơn giá"),
                SizedBox(
                  height: 6,
                ),
                _formThongTin(
                    controller: _controllerDonGia,
                    isGhiChu: false,
                    focusNode: _focusDonGia),
                SizedBox(
                  height: 4,
                ),
                Text("Ghi chú"),
                SizedBox(
                  height: 6,
                ),
                _formThongTin(controller: _controllerGhiChu, isGhiChu: true)
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("HỦY BỎ"),
              onPressed: () {
                Navigator.of(context).pop(DialogResultType.CANCEL);
              },
            ),
            FlatButton(
              child: Text("XÁC NHẬN"),
              onPressed: () {
                updateInfoProduct(line);
                Navigator.of(context).pop(DialogResultType.YES);
              },
            ),
          ],
        );
      },
    );
  }

  void updateInfoProduct(Lines line) {
    line.qty = int.parse(_controllerSoLuong.text.replaceAll(".", ""));
    line.discount = double.parse(_controllerChietKhau.text.replaceAll(".", ""));
    line.priceUnit = double.parse(_controllerDonGia.text.replaceAll(".", ""));
    line.note = _controllerGhiChu.text;
    _vm.updateProductCart(line);
  }

  Widget _formThongTin(
      {TextEditingController controller, bool isGhiChu, FocusNode focusNode}) {
    //controller.text = value;
    if (!isGhiChu) {
      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          controller.selection = TextSelection(
              baseOffset: 0, extentOffset: controller.text.length);
        }
      });
    }
    return Padding(
      padding: EdgeInsets.only(left: 0.0, right: 0.0),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]),
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 12.0,
            ),
            Expanded(
                child: isGhiChu
                    ? TextField(
                        controller: controller,
                        decoration: InputDecoration.collapsed(
                          hintText: "",
                        ),
                      )
                    : TextField(
                        controller: controller,
                        decoration: InputDecoration.collapsed(
                          hintText: "",
                        ),
                        focusNode: focusNode,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly,
                          NumberInputFormat.vietnameDong(),
                        ],
                      ))
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  void getData() async {
    await _vm.countInvoicePayment();
    await _vm.getSession();
    await _vm.getProducts();
    await _vm.getPartners();
    await _vm.getPriceLists();
    await _vm.getAccountJournal();
    await _vm.getCompanies();
  }
}
