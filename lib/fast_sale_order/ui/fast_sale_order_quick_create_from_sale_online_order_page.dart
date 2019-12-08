import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/fast_sale_order/models/create_quick_fast_sale_order_model.dart';
import 'package:tpos_mobile/fast_sale_order/viewmodels/fast_sale_order_quick_create_from_sale_online_order_viewmodel.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/helpers/tmt.dart';
import 'package:tpos_mobile/helpers/ui_help.dart';
import 'package:tpos_mobile/sale_online/ui/delivery_carrier_search_page.dart';
import 'package:tpos_mobile/sale_online/ui/partner_add_edit_page.dart';
import 'package:tpos_mobile/sale_online/ui/ui.dart';
import 'package:tpos_mobile/widgets/my_step_view.dart';

class fastSaleOrderQuickCreateFromSaleOnlineOrderPage extends StatefulWidget {
  final List<String> saleOnlineIds;
  fastSaleOrderQuickCreateFromSaleOnlineOrderPage(
      {@required this.saleOnlineIds});
  @override
  _fastSaleOrderQuickCreateFromSaleOnlineOrderPageState createState() =>
      _fastSaleOrderQuickCreateFromSaleOnlineOrderPageState();
}

class _fastSaleOrderQuickCreateFromSaleOnlineOrderPageState
    extends State<fastSaleOrderQuickCreateFromSaleOnlineOrderPage> {
  var _vm = FastSaleOrderQuickCreateFromSaleOnlineOrderViewModel();

  @override
  void initState() {
    _vm.init(saleOnlineOrderIds: widget.saleOnlineIds);
    _vm.initData();

    _vm.eventController.listen((event) {
      if (event.eventName == "GO_BACK") {
        if (mounted) Navigator.pop(context);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FastSaleOrderQuickCreateFromSaleOnlineOrderViewModel>(
      model: _vm,
      child: UIViewModelBase(
        viewModel: _vm,
        child: Scaffold(
          backgroundColor: Colors.grey.shade200,
          appBar: AppBar(
            title: Text("Tạo HĐ với sản phẩm mặc định"),
          ),
          body: _buildBody(),
          bottomNavigationBar: _buildBottomMenu(),
        ),
      ),
    );
  }

  Widget _buildBottomMenu() {
    var theme = Theme.of(context);
    return Container(
      height: 60,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border:
              Border(top: BorderSide(width: 1, color: Colors.grey.shade400))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: RaisedButton(
                padding: EdgeInsets.all(0),
                shape: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.primaryColor, width: 0.5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                  ),
                ),
                color: theme.primaryColor,
                disabledColor: Colors.grey.shade300,
                textColor: Colors.white,
                child: Text("LƯU VÀ GỬI VẬN ĐƠN"),
                onPressed: () {
                  _vm.save().then((value) {
                    if (value) Navigator.pop(context);
                  });
                }),
          ),
          SizedBox(
            width: 0,
          ),
          RaisedButton(
            padding: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: theme.primaryColor, width: 0.5),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
            ),
            color: Colors.grey.shade100,
            disabledColor: Colors.grey.shade300,
            child: Icon(Icons.more_horiz),
            onPressed: !true
                ? null
                : () {
                    Divider dividerMin = new Divider(
                      height: 2,
                      indent: 50,
                    );

                    showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) => BottomSheet(
                        shape: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            )),
                        onClosing: () {},
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: Icon(
                                Icons.print,
                                color: Colors.blue,
                              ),
                              title: Text("LƯU + GỬI VẬN ĐƠN + IN HÓA ĐƠN"),
                              onTap: () {
                                Navigator.pop(context);
                                _vm.save(printOrder: true).then((value) {
                                  if (value) Navigator.pop(context);
                                });
                              },
                            ),
                            Divider(),
                            ListTile(
                              leading: Icon(
                                Icons.print,
                                color: Colors.blue,
                              ),
                              title: Text("LƯU + GỬI VẬN ĐƠN + IN SHIP"),
                              onTap: () {
                                Navigator.pop(context);
                                _vm.save(printShip: true).then((value) {
                                  if (value) Navigator.pop(context);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }

  Future _selectDeliveryCarrier(BuildContext context) async {
    var selectedCarrier = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => DeliveryCarrierSearchPage(
          closeWhenDone: true,
          isSearch: true,
          selectedDeliveryCarrier: _vm.carrier,
        ),
      ),
    );

    if (selectedCarrier != null) {
      _vm.carrier = selectedCarrier;
    }
  }

  Widget _buildBody() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context)?.requestFocus(new FocusNode());
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
        child: ScopedModelDescendant<
            FastSaleOrderQuickCreateFromSaleOnlineOrderViewModel>(
          builder: (context, child, model) => Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.directions_car,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Đối tác giao hàng:")
                        ],
                      ),
                      title: Text(
                        "${_vm.carrier?.name ?? "Nhấp để chọn"}",
                        textAlign: TextAlign.end,
                        style: Theme.of(context)
                            .textTheme
                            .body1
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () async {
                        if (_vm.carrier != null) {
                          // Thong bao chon lai
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: ContinuousRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: Text("${_vm.carrier?.name}"),
                              actions: <Widget>[
                                OutlineButton.icon(
                                  label: Text("Bỏ chọn"),
                                  icon: Icon(Icons.remove_circle),
                                  textColor: Colors.red,
                                  color: Colors.white,
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _vm.carrier = null;
                                  },
                                ),
                                RaisedButton.icon(
                                  label: Text("Thay đổi"),
                                  icon: Icon(Icons.cached),
                                  textColor: Colors.white,
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _selectDeliveryCarrier(context);
                                  },
                                ),
                              ],
                            ),
                          );

                          return;
                        }

                        _selectDeliveryCarrier(context);
                      },
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 10),
                          child: Icon(
                            Icons.info,
                            color: Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Phần mềm sẽ tự động chọn dịch vụ với phí giao hàng thấp nhất",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_vm.lines?.length != null && _vm.lines.length == 0)
                _buildOneDetail(),
              if (_vm.lines?.length != null && _vm.lines.length > 0) ...[
                SizedBox(
                  height: 10,
                ),
                _buildListDetail(),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOneDetail() {
    return Container();
  }

  Widget _buildListDetail() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => _buildDetailItem(_vm.lines[index]),
          separatorBuilder: (context, index) => SizedBox(
                height: 8,
                child: Container(
                  color: Colors.grey.shade200,
                ),
              ),
          itemCount: _vm.lines?.length ?? 0),
    );
  }

  Widget _buildDetailItem(CreateQuickFastSaleOrderLineModel item) {
    var codController = TextEditingController(
        text: vietnameseCurrencyFormat(item.totalAmount ?? 0));

    var shipController = TextEditingController(
      text: vietnameseCurrencyFormat(item.shipAmount ?? 0),
    );
    return ExpansionTile(
      initiallyExpanded: true,
      title: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              "${item.facebookName}",
              style: TextStyle(color: Colors.blue),
            ),
          ),
          OutlineButton(
            child: Text(
              "Sửa khách hàng",
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PartnerAddEditPage(
                    partnerId: item.partnerId,
                    onEditPartner: (partner) {
                      setState(() {
                        item.partner.phone = partner.phone;
                        item.partner.city = partner.city;
                        item.partner.district = partner.district;
                        item.partner.ward = partner.ward;
                        item.partner.street = partner.street;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      children: <Widget>[
        Container(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RichText(
              text: TextSpan(
                  style: TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.bold),
                  text: "Giao tới: ",
                  children: [
                    TextSpan(
                      text:
                          "${item.partner?.phone != null && item.partner?.phone != "" ? item.partner?.phone : "<Vui lòng cập nhật SĐT>"} | ",
                      style: TextStyle(
                          color: item.partner?.phone != null &&
                                  item.partner?.phone != ""
                              ? Colors.black87
                              : Colors.orangeAccent),
                    ),
                    TextSpan(
                      text:
                          "${item.partner?.addressFull != null && item.partner?.addressFull != "" ? item.partner?.addressFull : "Vui lòng cập nhật địa chỉ Phường Xã, Quận Huyện, Tỉnh- Thành phố cho khách hàng"}",
                      style: TextStyle(
                          color: item.partner?.addressFull == null ||
                                  item.partner?.addressFull == ""
                              ? Colors.red
                              : Colors.grey),
                    ),
                  ]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                      hintText: "Tiền hàng:",
                      labelText: "Tiền hàng: ",
                      alignLabelWithHint: true),
                  controller: codController,
                  onChanged: (text) {
                    var value = Tmt.convertToDouble(text, "vi_VN");
                    item.totalAmount = value;
                  },
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    WhitelistingTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter(),
                  ],
                  onTap: () {
                    codController.selection = new TextSelection(
                        baseOffset: 0, extentOffset: codController.text.length);
                  },
                ),
              ),
              SizedBox(
                width: 50,
              ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                      hintText: "Phí ship:", labelText: "Phí ship :"),
                  controller: shipController,
                  onChanged: (text) {
                    var value = Tmt.convertToDouble(text, "vi_VN");
                    item.shipAmount = value;
                  },
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    WhitelistingTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter(),
                  ],
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  onTap: () {
                    shipController.selection = new TextSelection(
                        baseOffset: 0,
                        extentOffset: shipController.text.length);
                  },
                ),
              ),
              Text("Thanh toán:"),
              Checkbox(
                value: item.isPayment,
                onChanged: (value) {
                  setState(() {
                    item.isPayment = value;
                  });
                },
              ),
            ],
          ),
        ),
        //Ghi chú sản phẩm
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey, width: 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${item.productNote ?? "Ghi chú sản phẩm"}",
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              onTap: () async {
                var result =
                    await showTextInputDialog(context, item.productNote, true);
                if (result != null)
                  setState(() {
                    item.productNote = result;
                  });
              },
            ),
          ),
        ),
        //Ghi chú
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey, width: 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Ghi chú: ${item.comment}",
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              onTap: () async {
                var result =
                    await showTextInputDialog(context, item.comment, true);
                if (result != null)
                  setState(() {
                    item.comment = result;
                  });
              },
            ),
          ),
        )
      ],
    );
  }
}
