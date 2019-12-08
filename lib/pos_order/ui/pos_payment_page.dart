import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tpos_mobile/app_core/helper/string_helper.dart';
import 'package:tpos_mobile/app_core/ui_base/view_base.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/pos_order/models/multi_payment.dart';
import 'package:tpos_mobile/pos_order/models/payment.dart';
import 'package:tpos_mobile/pos_order/viewmodels/pos_payment_viewmodel.dart';
import 'package:tpos_mobile/services/dialog_service.dart';

class PosPaymentPage extends StatefulWidget {
  PosPaymentPage(this.amoutTotal, this.discountType, this.discount,
      this.position, this.partnerId);
  final double amoutTotal;
  final int discountType;
  final double discount;
  final String position;
  final int partnerId;

  @override
  _PosPaymentPageState createState() => _PosPaymentPageState();
}

class _PosPaymentPageState extends State<PosPaymentPage> {
  var _vm = locator<PosPaymentViewModel>();
  bool showDeletePartner = false;

  TextEditingController _ctrlGiamTien = TextEditingController();
  TextEditingController _ctrlName = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _vm.tongTien = widget.amoutTotal;
    _vm.updateData(widget.amoutTotal);
  }

  @override
  Widget build(BuildContext context) {
    return ViewBase<PosPaymentViewModel>(
        model: _vm,
        builder: (context, model, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Thanh toán "),
              actions: <Widget>[
                InkWell(
                  onTap: () {
                    _vm.isCheckInvoice();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        _vm.checkInvoice ? Icons.check : Icons.close,
                        color: Colors.white,
                      ),
                      Text(
                        "Hóa đơn",
                      ),
                      SizedBox(
                        width: 6,
                      )
                    ],
                  ),
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 4.0, top: 6.0),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4.0),
                    topRight: Radius.circular(4.0)),
                shadowColor: Colors.grey[500],
                elevation: 4.0,
                child: Stack(
                  children: <Widget>[
                    _buildListPayment(),
                    _buildMoneyPayment(),
                    btnThanhToan()
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildListPayment() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 60, top: 60),
        child: ListView.builder(
            itemCount: _vm.multiPayments.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(top: 3),
                child: _showItem(_vm.multiPayments[index], index),
              );
            }));
  }

  Widget _buildMoneyPayment() {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 12,
        ),
        Expanded(
          child: Container(
              margin: EdgeInsets.only(top: 8),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]),
                  borderRadius: BorderRadius.all(Radius.circular(3))),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: dropPhuongThuc()),
        ),
        SizedBox(
          width: 8,
        ),
        Container(
          margin: EdgeInsets.only(top: 8),
          child: IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.green,
            ),
            onPressed: () {
              dialogAdd(context, false);
            },
          ),
        ),
        SizedBox(
          width: 12,
        ),
      ],
    );
  }

  DropdownButton dropPhuongThuc() => DropdownButton<String>(
      items: _vm.lstPhuongThuc.map((val) => val).toList(),
      onChanged: (value) {
        _vm.changePhuongThuc(value);
      },
      value: "${_vm.position}",
      elevation: 2,
      style: TextStyle(color: Colors.grey[800], fontSize: 17),
      isDense: true,
      isExpanded: true,
      underline: SizedBox());

  void dialogAdd(BuildContext context, bool isUpdate,
      {int index, double amountPaid}) {
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
              "Tiền khách trả",
              style: TextStyle(color: Colors.red),
            ),
          ),
          content: Container(
            height: 70,
            child: ListView(
              children: <Widget>[
                Text("Nhập số tiền"),
                SizedBox(
                  height: 6,
                ),
                _formThongTin(
                    controller: _ctrlName,
                    focusNode: focusNode,
                    isUpdate: isUpdate,
                    amountPaid: amountPaid)
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
                if (isUpdate) {
                  _vm.updatePayment(index, _ctrlName.text);
                } else {
                  _vm.addPayment(_ctrlName.text, widget.amoutTotal);
                }
                Navigator.of(context).pop(DialogResultType.YES);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _formThongTin(
      {TextEditingController controller,
      FocusNode focusNode,
      bool isUpdate,
      double amountPaid}) {
    controller.text = isUpdate ? vietnameseCurrencyFormat(amountPaid) : "0";
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        controller.selection =
            TextSelection(baseOffset: 0, extentOffset: controller.text.length);
      }
    });

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
                child: TextField(
              controller: controller,
              decoration: InputDecoration.collapsed(
                hintText: "Nhập số tiền...",
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

  Widget _showItem(MultiPayment item, int index) {
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
      key: Key("213  312"),
      confirmDismiss: (direction) async {
        var dialogResult = await showQuestion(
            context: context,
            title: "Xác nhận xóa",
            message: "Bạn có muốn xóa");

        if (dialogResult == DialogResultType.YES) {
          return false;
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
                dialogAdd(context, true,
                    index: index, amountPaid: item.amountPaid);
              },
              title: Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 6),
                child: Row(
                  children: <Widget>[
                    new Expanded(
                      child: new Text(
                        "Phương thức: ${_vm.getAccountJournal(item.accountJournalId)}",
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
              subtitle: Column(
                children: <Widget>[
                  new Text(
                    "Tổng tiền: ${vietnameseCurrencyFormat(item.amountTotal)}",
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  new Text(
                    "Trả: ${vietnameseCurrencyFormat(item.amountPaid)}",
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  new Text(
                    "Nợ: ${vietnameseCurrencyFormat(item.amountDebt)}",
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  new Divider(
                    color: Colors.grey.shade300,
                  ),
                  new Text(
                    "Tiền thừa: ${vietnameseCurrencyFormat(item.amountReturn)}",
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(
                    height: 6,
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
                _vm.addInfoPayment(widget.discountType, widget.discount,
                    widget.position, widget.partnerId, context);
              },
              child: Center(
                child: Text(
                  "Xác nhận",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formMoney({TextEditingController controller, FocusNode focusNode}) {
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        controller.selection =
            TextSelection(baseOffset: 0, extentOffset: controller.text.length);
      }
    });

    //controller.text = value;
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
                child: TextField(
              onChanged: (value) {
                _vm.handleTinhTien(value);
              },
              controller: controller,
              decoration: InputDecoration.collapsed(
                hintText: "Nhập số tiền...",
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
}
