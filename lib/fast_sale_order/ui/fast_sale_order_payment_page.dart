/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 7/5/19 4:54 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 7/5/19 8:36 AM
 *
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/fast_sale_order/viewmodels/fast_sale_order_payment_viewmodel.dart';
import 'package:tpos_mobile/src/tpos_apis/models/account_journal.dart';
import 'package:tpos_mobile/src/tpos_apis/models/account_payment.dart';
import 'package:tpos_mobile/widgets/ModalWaitingWidget.dart';
import 'package:tpos_mobile/widgets/simple_input_field.dart';

class FastSaleOrderPaymentPage extends StatefulWidget {
  final AccountPayment payment;
  final double amount;
  final String content;
  FastSaleOrderPaymentPage({this.payment, this.amount, this.content});
  @override
  _FastSaleOrderPaymentPageState createState() =>
      _FastSaleOrderPaymentPageState(
          defaultPaymentInfo: payment, amount: amount, content: content);
}

class _FastSaleOrderPaymentPageState extends State<FastSaleOrderPaymentPage> {
  var _viewModel = locator<FastSaleOrderPaymentViewModel>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  _FastSaleOrderPaymentPageState(
      {AccountPayment defaultPaymentInfo, double amount, String content}) {
    _viewModel.init(
        defaultPayment: defaultPaymentInfo, amount: amount, content: content);
  }
  @override
  void initState() {
    _viewModel.initCommand();
    _viewModel.notifyPropertyChangedController.listen((f) {
      if (mounted) {
        setState(() {});
      }
    });

    _viewModel.dialogMessageController.listen((f) {
      registerDialogToView(context, f, scaffState: _scaffoldKey.currentState);
    });
    super.initState();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalWaitingWidget(
      isBusyStream: _viewModel.isBusyController,
      initBusy: _viewModel.isBusy,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Đăng ký thanh toán"),
        ),
        body: _showBody(),
      ),
    );
  }

  Widget _showBody() {
    final TextEditingController _amountController = TextEditingController(
        text: vietnameseCurrencyFormat(_viewModel.amount));
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
            children: <Widget>[
              // Phương thức thanh toán
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: SimpleInputField(
                  leading: Icon(Icons.payment),
                  title: Text("Phương thức:"),
                  content: DropdownButton<AccountJournal>(
                    isExpanded: false,
                    underline: SizedBox(),
                    hint: Text(
                      "Chọn phương thức",
                    ),
                    value: _viewModel.selectedAccountJournal,
                    onChanged: (value) {
                      _viewModel.selectAccountJournalCommand(value);
                    },
                    items: _viewModel.accountJournals == null
                        ? null
                        : _viewModel.accountJournals
                            .map(
                              (f) => DropdownMenuItem<AccountJournal>(
                                value: f,
                                child: Text(
                                  f.name,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
              Divider(
                height: 2,
              ),
              ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.attach_money),
                    Text(
                      "Số tiền:",
                    ),
                  ],
                ),
                trailing: SizedBox(
                  width: 150,
                  child: TextField(
                    textAlign: TextAlign.right,
                    controller: _amountController,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                    onChanged: (value) {
                      _viewModel.amount =
                          double.tryParse(value.replaceAll(".", "")) ?? 0;
                    },
                    onTap: () {
                      _amountController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: _amountController.text.length);
                    },
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp(r'[\d]+')),
                      NumberInputFormat.vietnameDong(
                          value: _viewModel.amount ?? 0,
                          format: "###,###,###,###"),
                    ],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(),
                  ),
                ),
              ),
              Divider(
                height: 2,
              ),
              ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.date_range),
                    Text("Ngày thanh toán:"),
                  ],
                ),
                trailing: SizedBox(
                  width: 150,
                  child: TextField(
                    textAlign: TextAlign.right,
                    controller: TextEditingController(
                        text: DateFormat("dd/MM/yyyy")
                                .format(_viewModel.datePayment) ??
                            "Chọn ngày"),
                    onChanged: (value) {},
                    onTap: () async {
                      var selectedDate = await showDatePicker(
                          context: context,
                          initialDate: _viewModel.datePayment ?? DateTime.now(),
                          firstDate:
                              DateTime.now().add(new Duration(days: -3650)),
                          lastDate: DateTime.now());
                      if (selectedDate != null) {
                        setState(() {
                          _viewModel.datePayment = selectedDate;
                        });
                      }
                    },
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp(r'[\d]+')),
                      // _weightInputForamt,
                    ],
                    keyboardType: TextInputType.number,
                    // focusNode: _khoiLuongFocus,
                    decoration: const InputDecoration(),
                  ),
                ),
              ),

              Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller:
                      TextEditingController(text: _viewModel.description),
                  decoration: InputDecoration(
                    labelText: "Nội dung thanh toán: ",
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 45,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: RaisedButton(
                  color: Colors.deepPurple,
                  textColor: Colors.white,
                  padding: EdgeInsets.only(),
                  onPressed: () async {
                    if (_viewModel.selectedAccountJournal == null) {
                      _scaffoldKey.currentState.showSnackBar((new SnackBar(
                          content:
                              Text("Vui lòng chọn phương thức thanh toán"))));
                      return;
                    }

                    if (_viewModel.amount == 0) {
                      _scaffoldKey.currentState.showSnackBar((new SnackBar(
                          content: Text("Vui lòng nhập số tiền"))));
                      return;
                    }
                    var success = await _viewModel.submitPaymentCommand();
                    if (success == true) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: Text("XÁC NHẬN THANH TOÁN"),
                ),
              ),
// TODO Nút thanh toán và in
//              Expanded(
//                child: Padding(
//                  padding: const EdgeInsets.all(8.0),
//                  child: RaisedButton(
//                    onPressed: () {},
//                    child: Text("Thanh toán & in"),
//                  ),
//                ),
//              )
            ],
          ),
        ),
      ],
    );
  }
}

class NumberField extends StatelessWidget {
  final double value;
  final Function(double) onChanged;
  final String format;

  NumberField({this.value = 0, this.onChanged, this.format});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: TextEditingController(
            text: NumberFormat(format).format(value ?? 0)),
      ),
    );
  }
}
