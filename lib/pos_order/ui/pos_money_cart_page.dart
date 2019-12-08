import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter/services.dart';
import 'package:tpos_mobile/app_core/helper/string_helper.dart';
import 'package:tpos_mobile/app_core/ui_base/view_base.dart';
import 'package:tpos_mobile/pos_order/models/partners.dart';
import 'package:tpos_mobile/pos_order/ui/pos_partner_list_page.dart';
import 'package:tpos_mobile/pos_order/ui/pos_payment_page.dart';
import 'package:tpos_mobile/pos_order/viewmodels/pos_money_cart_viewmodel.dart';

import '../../app_service_locator.dart';

class PosMoneyCartPage extends StatefulWidget {
  PosMoneyCartPage({this.priceCart, this.positionCart});
  final double priceCart;
  final String positionCart;

  @override
  _PosMoneyCartPageState createState() => _PosMoneyCartPageState();
}

class _PosMoneyCartPageState extends State<PosMoneyCartPage> {
  var _vm = locator<PosMoneyCartViewModel>();
  bool showDeletePartner = false;

  TextEditingController _controllerGiamTien = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _vm.updateTongTien(widget.priceCart);
    _controllerGiamTien.text = "0";
  }

  @override
  Widget build(BuildContext context) {
    return ViewBase<PosMoneyCartViewModel>(
        model: _vm,
        builder: (context, model, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Tính tiền"),
            ),
            body: Padding(
              padding:
                  const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4.0),
                    topRight: Radius.circular(4.0)),
                shadowColor: Colors.grey[500],
                elevation: 4.0,
                child: Stack(
                  children: <Widget>[_buildBody(), btnThanhToan()],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 53),
      child: ListView(
        children: <Widget>[
          infoRow("Tổng tiền", "${vietnameseCurrencyFormat(widget.priceCart)}"),
          _buildPhuongThucGiam(),
          infoRow("Tổng thanh toán",
              "${vietnameseCurrencyFormat(_vm.cachThucGiam == 0 ? _vm.tongTienChietKhau : _vm.tongTienGiamTien)}"),
          _buildGiamTien(),
          _formGiamTien(controller: _controllerGiamTien, focusNode: focusNode),
          Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
              child: _buildHeader("Khách hàng")),
          _buildFormSelectPartner(),
          SizedBox(
            height: 16.0,
          ),
        ],
      ),
    );
  }

  Widget infoRow(String header, String content) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _buildHeader("Tổng thanh toán"),
          ),
          Expanded(
            child: Text(
              content,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 18),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Text(
      "$title:",
      style: const TextStyle(fontSize: 17),
    );
  }

  Widget _buildFormSelectPartner() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            new MaterialPageRoute(builder: (context) => PosPartnerListPage()),
          ).then((value) {
            if (value != null) {
              _vm.partner = value;
            }
          });
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              border: Border.all(color: Colors.grey[400])),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    _vm.partner.name ?? "Chọn khách hàng",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Visibility(
                  visible: _vm.partner.name == null ? false : true,
                  child: InkWell(
                    onTap: () {
                      _vm.partner = Partners();
                    },
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.red,
                    ),
                  ),
                ),
                SizedBox(
                  width: 12,
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
      ),
    );
  }

  Widget btnThanhToan() {
    return Positioned(
      bottom: 6,
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        padding: EdgeInsets.only(top: 8, right: 24),
        child: Center(
          child: Container(
            margin: EdgeInsets.only(
                right: MediaQuery.of(context).size.width / 5,
                left: MediaQuery.of(context).size.width / 5),
            height: 45,
            decoration: BoxDecoration(
              color: Colors.green[600],
              borderRadius: BorderRadius.all(Radius.circular(3.0)),
            ),
            child: FlatButton(
              onPressed: () {
                if (_vm.partner.name != null) {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => PosPaymentPage(
                            _vm.cachThucGiam == 0
                                ? _vm.tongTienChietKhau
                                : _vm.tongTienGiamTien,
                            _vm.cachThucGiam,
                            _vm.cachThucGiam == 0
                                ? double.parse(_vm.chietKhau.toString())
                                : _vm.tienGiam,
                            widget.positionCart,
                            _vm.partner.id)),
                  ).then((value) {
                    if (value != null) {
                      Navigator.pop(context, value);
                    }
                  });
                } else {
                  _vm.notifyErrorPayment();
                }
              },
              child: Center(
                child: Text(
                  "Thanh toán",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGiamTien() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Radio(
          value: 0,
          groupValue: _vm.cachThucGiam,
          onChanged: (value) {
            _controllerGiamTien.text = "0";
            _vm.changeDiscountPrice(value);
          },
        ),
        _buildHeader('Chiết khấu'),
        SizedBox(
          width: 16.0,
        ),
        new Radio(
          value: 1,
          groupValue: _vm.cachThucGiam,
          onChanged: (value) {
            _controllerGiamTien.text = "0";
            _vm.changeDiscountPrice(value);
          },
        ),
        _buildHeader('Giảm tiền'),
        SizedBox(
          width: 16.0,
        ),
      ],
    );
  }

  Widget _formGiamTien(
      {TextEditingController controller, FocusNode focusNode}) {
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        controller.selection =
            TextSelection(baseOffset: 0, extentOffset: controller.text.length);
      }
    });

    //controller.text = value;
    return Padding(
      padding: EdgeInsets.only(left: 12.0, right: 12.0),
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
                child: TextField(
              onChanged: (value) {
                if (_vm.cachThucGiam == 0) {
                  _vm.handleGiamChietKhau(value);
                } else {
                  _vm.handleGiamTien(value);
                }
              },
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

  Widget _buildPhuongThucGiam() {
    print("${_vm.tongTienGiamTien} - ${_vm.cachThucGiam}");
    return _vm.cachThucGiam == 0
        ? Padding(
            padding:
                const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 6),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _buildHeader("Chiết khấu ${_vm.chietKhau}%"),
                ),
                Expanded(
                  child: Text(
                    "${vietnameseCurrencyFormat(_vm.tongTien - _vm.tongTienChietKhau)}",
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 18),
                  ),
                )
              ],
            ),
          )
        : Padding(
            padding:
                const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 6),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _buildHeader("Giảm tiền"),
                ),
                Expanded(
                  child: Text(
                    "${vietnameseCurrencyFormat(_vm.tienGiam)}",
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 17),
                  ),
                )
              ],
            ),
          );
  }
}
