import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/helpers/tmt.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';
import 'package:tpos_mobile/fast_sale_order/viewmodels/fast_sale_order_add_edit_full_payment_info_viewmodel.dart';
import 'package:tpos_mobile/fast_sale_order/viewmodels/fast_sale_order_add_edit_full_viewmodel.dart';
import 'package:tpos_mobile/widgets/ModalWaitingWidget.dart';

class FastSaleOrderAddEditFullPaymentInfoPage extends StatefulWidget {
  final FastSaleOrderAddEditFullViewModel editVm;
  FastSaleOrderAddEditFullPaymentInfoPage({this.editVm});
  @override
  _FastSaleOrderAddEditFullPaymentInfopageState createState() =>
      _FastSaleOrderAddEditFullPaymentInfopageState();
}

class _FastSaleOrderAddEditFullPaymentInfopageState
    extends State<FastSaleOrderAddEditFullPaymentInfoPage> {
  var _vm = new FastSaleOrderAddEditFullPaymentInfoViewModel();

  @override
  void initState() {
    _vm.init(widget.editVm);
    _discountFixController.text = vietnameseCurrencyFormat(_vm.decreaseAmount);
    _discountController.text = NumberFormat("###.##").format(_vm.discount);

    _vm.addListener(() {
      if (_edittingController == _discountController) {
        _discountFixController.text =
            vietnameseCurrencyFormat(_vm.decreaseAmount);
      } else if (_edittingController == _discountFixController) {
        _discountController.text = NumberFormat("###.##").format(_vm.discount);
      }

      _rechargeAmountController.text =
          vietnameseCurrencyFormat(_vm.rechargeAmount);
      if (_edittingController != _paymentController)
        _paymentController.text = vietnameseCurrencyFormat(_vm.paymentAmount);
    });
    super.initState();
  }

  var _discountController = new TextEditingController(text: "0");
  var _discountFixController = new TextEditingController(text: "0");
  var _paymentController = new TextEditingController(text: "0");
  var _rechargeAmountController = new TextEditingController(text: "0");

  TextEditingController _edittingController;

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FastSaleOrderAddEditFullPaymentInfoViewModel>(
      model: _vm,
      child: GestureDetector(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text("Thông tin toán"),
            actions: <Widget>[
//            FlatButton(
//              textColor: Colors.white,
//              child: Text("Lưu"),
//              onPressed: () {
//                Navigator.pop(context);
//              },
//            )
            ],
          ),
          body: ModalWaitingWidget(
            isBusyStream: _vm.isBusyController,
            initBusy: false,
            child: _buildBody(),
          ),
        ),
        onTapDown: (s) {
          FocusScope.of(context)?.requestFocus(new FocusNode());
        },
      ),
    );
  }

  Widget _buildBody() {
    var defaultNumberStyle =
        TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: Container(
            color: Colors.grey.shade300,
            child: SingleChildScrollView(
              child: ScopedModelDescendant<
                  FastSaleOrderAddEditFullPaymentInfoViewModel>(
                builder: (ctx, _, model) {
                  return Column(
                    children: <Widget>[
                      Material(
                        color: Colors.white,
                        child: ListTile(
                          leading: Text("Phương thức: "),
                          title: DropdownButton<AccountJournal>(
                            isExpanded: true,
                            hint: Text("Chọn phương thức"),
                            value: _vm.selectedAccountJournal,
                            items: _vm.accountJournals
                                ?.map((f) => DropdownMenuItem<AccountJournal>(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          SizedBox(),
                                          Text(
                                            f.name,
                                            textAlign: TextAlign.right,
                                          ),
                                        ],
                                      ),
                                      value: f,
                                    ))
                                ?.toList(),
                            onChanged: (value) {
                              _vm.selectAccountJournalCommand(value);
                            },
                          ),
                          onTap: () {},
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Material(
                        color: Colors.white,
                        child: ListTile(
                          leading: Text("Tổng tiền hàng:"),
                          trailing: SizedBox(
                            width: 200,
                            child: TextField(
                              enabled: false,
                              controller: TextEditingController(
                                  text: vietnameseCurrencyFormat(
                                      widget.editVm.subTotal ?? 0)),
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                  hintText: "", border: InputBorder.none),
                              style: defaultNumberStyle,
                            ),
                          ),
                        ),
                      ),
                      // Giảm giá %
                      Divider(
                        height: 1,
                      ),
                      Material(
                        color: Colors.white,
                        child: ListTile(
                          leading: Text("Giảm giá (%):"),
                          trailing: SizedBox(
                            width: 200,
                            child: TextField(
                              style: defaultNumberStyle,
                              controller: _discountController,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                hintText: "",
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                  signed: true, decimal: true),
                              inputFormatters: [
                                WhitelistingTextInputFormatter(
                                    RegExp("[0-9.,]")),
                                PercentInputFormat(
                                    locate: "vi_VN", format: "###.0#"),
                              ],
                              onChanged: (text) {
                                double value =
                                    Tmt.convertToDouble(text, "vi_VN");
                                _vm.discount = value;
                                _edittingController = _discountController;
                              },
                              onTap: () {
                                _discountController.selection =
                                    new TextSelection(
                                        baseOffset: 0,
                                        extentOffset:
                                            _discountController.text.length);
                              },
                            ),
                          ),
                        ),
                      ),
                      // Giảm giá tiền
                      Divider(
                        height: 1,
                      ),
                      Material(
                        color: Colors.white,
                        child: ListTile(
                          leading: Text("Giảm giá (tiền):"),
                          trailing: SizedBox(
                            width: 200,
                            child: TextField(
                              style: defaultNumberStyle,
                              controller: _discountFixController,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                hintText: "",
                              ),
                              keyboardType: TextInputType.numberWithOptions(),
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly,
                                NumberInputFormat.vietnameDong(),
                              ],
                              onChanged: (text) {
                                double value =
                                    Tmt.convertToDouble(text, "vi_VN");
                                _vm.decreaseAmount = value;
                                _edittingController = _discountFixController;
                              },
                              onTap: () {
                                _discountFixController.selection =
                                    new TextSelection(
                                        baseOffset: 0,
                                        extentOffset:
                                            _discountFixController.text.length);
                              },
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                      ),
                      Material(
                        color: Colors.white,
                        child: ListTile(
                          leading: Text("Tổng tiền:"),
                          trailing: SizedBox(
                            width: 200,
                            child: TextField(
                              style: defaultNumberStyle.copyWith(
                                  color: Colors.red),
                              controller: TextEditingController(
                                text: vietnameseCurrencyFormat(_vm.totalAmount),
                              ),
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                fillColor: Colors.red,
                                enabled: false,
                                hintText: "",
                              ),
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                      ),
                      Material(
                        color: Colors.white,
                        child: ListTile(
                          leading: Text("Thanh toán:"),
                          trailing: SizedBox(
                            width: 200,
                            child: TextField(
                              style: defaultNumberStyle.copyWith(
                                  color: Colors.green),
                              controller: _paymentController,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                hintText: "",
                              ),
                              keyboardType: TextInputType.numberWithOptions(),
                              onChanged: (text) {
                                _edittingController = _paymentController;
                                double value =
                                    Tmt.convertToDouble(text, "vi_VN");

                                _vm.paymentAmount = value;
                              },
                              onTap: () {
                                _paymentController.selection =
                                    new TextSelection(
                                        baseOffset: 0,
                                        extentOffset:
                                            _paymentController.text.length);
                              },
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly,
                                NumberInputFormat.vietnameDong(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                      ),
                      Material(
                        color: Colors.white,
                        child: ListTile(
                          leading: Text("Còn lại:"),
                          trailing: SizedBox(
                            width: 200,
                            child: TextField(
                              enabled: false,
                              controller: _rechargeAmountController,
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(
                                  hintText: "", border: InputBorder.none),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 12, right: 12),
          child: RaisedButton.icon(
            textColor: Colors.white,
            icon: Icon(Icons.keyboard_return),
            label: Text("QUAY LẠI HÓA ĐƠN"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}
