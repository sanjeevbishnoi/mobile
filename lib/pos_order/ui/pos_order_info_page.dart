import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tpos_mobile/app_core/template_ui/empty_data_widget.dart';
import 'package:tpos_mobile/app_core/helper/string_helper.dart';
import 'package:tpos_mobile/pos_order/models/pos_make_payment.dart';
import 'package:tpos_mobile/pos_order/viewmodels/pos_order_info_viewmodel.dart';
import 'package:tpos_mobile/pos_order/pos_order_state.dart';
import 'package:tpos_mobile/app_core/template_ui/reload_list_page.dart';
import 'package:tpos_mobile/app_core/ui_base/view_base.dart';
import 'package:tpos_mobile/widgets/info_row.dart';
import '../../app_service_locator.dart';

class PosOrderInfoPage extends StatefulWidget {
  final int posOrderId;
  final Function posOrderCallback;

  PosOrderInfoPage({@required this.posOrderId, this.posOrderCallback});

  @override
  _PosOrderInfoPageState createState() => _PosOrderInfoPageState();
}

class _PosOrderInfoPageState extends State<PosOrderInfoPage> {
  var _viewModel = locator<PosOrderInfoViewModel>();
  TextStyle detailFontStyle;
  TextStyle titleFontStyle;

  var dividerMin = new Divider(
    height: 2,
  );

  @override
  void initState() {
    super.initState();
    init();
  }

  Future init() async {
    if (widget.posOrderId != null) {
      await _viewModel.initCommand(widget.posOrderId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: ViewBase<PosOrderInfoViewModel>(
        model: _viewModel,
        builder: (context, model, _) => Scaffold(
          backgroundColor: Colors.grey.shade300,
          appBar: AppBar(
            title: Text("Thông tin hóa đơn"),
            actions: <Widget>[
/*              FlatButton.icon(
                textColor: Colors.white,
                icon: Icon(Icons.edit),
                label: Text("Sửa"),
                onPressed: () async {},
              ),*/
/*              IconButton(
                icon: Icon(Icons.more_horiz),
                onPressed: () {
                  showModalBottomSheetFullPage(
                    context: context,
                    builder: (context) {
                      return _buildBottomAction();
                    },
                  );
                },
              ),*/
            ],
          ),
          body: ReloadListPage(
            vm: _viewModel,
            onPressed: () {
              _viewModel.initCommand(widget.posOrderId);
            },
            child: _viewModel.posOrder != null
                ? Column(
                    children: <Widget>[
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await _viewModel.initCommand(widget.posOrderId);
                          },
                          child: ListView(
                            padding: EdgeInsets.only(
                                left: 10, top: 10, right: 10, bottom: 10),
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              _showPrimaryInfo(),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: EdgeInsets.all(3),
                                child: ExpansionTile(
                                  title: Text(
                                    "Chi tiết đơn hàng",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  initiallyExpanded: false,
                                  children: <Widget>[
                                    _showPosOrderLine(),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: EdgeInsets.all(3),
                                child: ExpansionTile(
                                  title: Text(
                                    "Thanh toán",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  initiallyExpanded: false,
                                  children: <Widget>[
                                    _showAccountBankStatement(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : EmptyData(
                    onPressed: () {
                      _viewModel.initCommand(widget.posOrderId);
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _showPrimaryInfo() {
    var dividerMin = new Divider(
      height: 2,
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            InfoRow(
              titleString: "Mã đơn hàng: ",
              content: Text(
                "${_viewModel.posOrder?.name ?? ""}",
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            InfoRow(
              titleString: "Ngày đơn hàng: ",
              content: Text(
                "${_viewModel.posOrder?.dateOrder != null ? DateFormat("dd/MM/yyyy HH:mm").format(_viewModel.posOrder?.dateOrder) : ""}",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            dividerMin,
            InfoRow(
              titleString: "Mã phiếu nhận: ",
              content: Text(
                "${_viewModel.posOrder?.pOSReference ?? ""}",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
                maxLines: null,
              ),
            ),
            dividerMin,
            InfoRow(
              titleString: "Người bán hàng: ",
              content: Text(
                "${_viewModel.posOrder?.userName ?? ""}",
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            dividerMin,
            InfoRow(
              titleString: "Phiên:",
              content: Text(
                "${_viewModel.posOrder?.sessionName ?? ""}",
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            dividerMin,
            InfoRow(
              titleString: "Khách hàng:",
              content: Text(
                "${_viewModel.posOrder?.partnerName ?? ""}",
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            dividerMin,
            InfoRow(
              titleString: "Tổng tiền:",
              content: Text(
                "${vietnameseCurrencyFormat(_viewModel.posOrder?.amountTotal) ?? 0}",
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            InfoRow(
              titleString: "Trạng thái:",
              content: Text(
                "${PosOrderSateOption.getPosOrderSateOption(state: _viewModel.posOrder?.state).description ?? ""}",
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: PosOrderSateOption.getPosOrderSateOption(
                          state: _viewModel.posOrder?.state)
                      .textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showPosOrderLine() {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.white,
          child: ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (ctx, index) {
              return SizedBox(
                width: double.infinity,
                child: ListTile(
                  contentPadding:
                      EdgeInsets.only(left: 20, right: 20, bottom: 0, top: 0),
                  dense: true,
                  title: Text(
                    _viewModel.posOrderLines[index].productNameGet ?? "",
                    style: TextStyle(color: Colors.black),
                  ),
                  subtitle: Row(
                    children: <Widget>[
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                              text:
                                  "${vietnameseCurrencyFormat(_viewModel.posOrderLines[index].priceUnit.toDouble())}",
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(text: "  x   "),
                                TextSpan(
                                    text: vietnameseCurrencyFormat(
                                        _viewModel.posOrderLines[index].qty ??
                                            0),
                                    style: TextStyle(color: Colors.blue)),
                              ]),
                        ),
                      ),
                      Text(
                        "${vietnameseCurrencyFormat(_viewModel.posOrderLines[index].priceSubTotal.toDouble())}",
                        style: TextStyle(color: Colors.red, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (ctx, index) {
              return Divider(
                height: 0,
              );
            },
            itemCount: _viewModel.posOrderLines?.length ?? 0,
          ),
        ),
      ],
    );
  }

  Widget _showAccountBankStatement() {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (ctx, index) {
          return SizedBox(
            width: double.infinity,
            child: ListTile(
              contentPadding:
                  EdgeInsets.only(left: 20, right: 20, bottom: 0, top: 0),
              dense: true,
              title: Text(
                _viewModel.posAccount[index].journalName ?? "",
                style: TextStyle(color: Colors.black),
              ),
              subtitle: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          "${_viewModel.posAccount[index].statementName}",
                          style: TextStyle(color: Colors.blue, fontSize: 15),
                        ),
                      ),
                      Text(
                        "${vietnameseCurrencyFormat(_viewModel.posAccount[index].amount)}",
                        style: TextStyle(color: Colors.red, fontSize: 15),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        "${_viewModel.posAccount[index].date != null ? DateFormat("dd/MM/yyyy HH:mm").format(_viewModel.posAccount[index].date) : ""}",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (ctx, index) {
          return Divider(
            height: 0,
          );
        },
        itemCount: _viewModel.posAccount?.length ?? 0,
      ),
    );
  }

  Widget _buildBottomAction() {
    var dividerMin = new Divider(
      height: 2,
      indent: 50,
    );
    return Container(
      color: Color(0xFF737373),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            if (_viewModel.posOrder.state == "draft") ...[
              dividerMin,
              ListTile(
                leading: Icon(
                  Icons.payment,
                  color: Colors.green,
                ),
                title: Text("Thanh toán"),
                onTap: () async {
                  await _viewModel.loadPosMakePayment(
                      _viewModel.newPosOrderId != null
                          ? _viewModel.newPosOrderId
                          : widget.posOrderId);
                  Navigator.pop(context);
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      TextEditingController amountController =
                          TextEditingController();
                      amountController.text =
                          "${vietnameseCurrencyFormat(_viewModel.posMakePayment.amount) ?? 0}";
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(
                                color: Colors.green,
                                width: 1,
                                style: BorderStyle.solid)),
                        title: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                "Thanh toán",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.cancel,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(Icons.payment),
                                  Text(" Phương thức"),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  DropdownButton<Journal>(
                                      isExpanded: false,
                                      underline: SizedBox(),
                                      hint: Text(
                                        "Chọn phương thức",
                                      ),
                                      value: _viewModel.selectedJournal,
                                      onChanged: (value) {
                                        _viewModel.selectJournalCommand(value);
                                      },
                                      items: [
                                        DropdownMenuItem<Journal>(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              SizedBox(),
                                              Text(
                                                _viewModel.selectedJournal.name,
                                                textAlign: TextAlign.right,
                                              ),
                                            ],
                                          ),
                                          value: _viewModel.selectedJournal,
                                        ),
                                      ]),
                                ],
                              ),
                              Divider(),
                              TextField(
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  WhitelistingTextInputFormatter.digitsOnly,
                                  NumberInputFormat.vietnameDong(),
                                ],
                                onTap: () {
                                  amountController.selection = TextSelection(
                                      baseOffset: 0,
                                      extentOffset:
                                          amountController.text.length);
                                },
                                controller: amountController,
                                decoration: InputDecoration(
                                  labelText: "Số tiền",
                                ),
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: "Tham chiếu thanh toán",
                                ),
                              )
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          MaterialButton(
                            child: Text("Xác nhận"),
                            onPressed: () async {
                              Navigator.pop(context);
                              _viewModel.posMakePayment.amount =
                                  double.tryParse(amountController.text
                                      .trim()
                                      .replaceAll(".", ""));
                              _viewModel
                                  .posPayment(_viewModel.newPosOrderId != null
                                      ? _viewModel.newPosOrderId
                                      : widget.posOrderId)
                                  .then((onValue) async {
                                await _viewModel.initCommand(
                                    _viewModel.newPosOrderId != null
                                        ? _viewModel.newPosOrderId
                                        : widget.posOrderId);
                                if (widget.posOrderCallback != null) {
                                  widget.posOrderCallback(_viewModel.posOrder);
                                }
                              });
                            },
                          )
                        ],
                      );
                    },
                  );
                },
              ),
            ] else ...[
              dividerMin,
              ListTile(
                  leading: Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
                  title: Text("Trả hàng"),
                  onTap: () async {
                    _viewModel.newPosOrderId = int.parse(await _viewModel
                        .refundPosOrder(_viewModel.posOrder.id));
                    Navigator.pop(context);
                    await _viewModel.initCommand(_viewModel.newPosOrderId);
                    if (widget.posOrderCallback != null) {
                      widget.posOrderCallback(_viewModel.posOrder);
                    }
                  }),
            ]
          ],
        ),
      ),
    );
  }
}
