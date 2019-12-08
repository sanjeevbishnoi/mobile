import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/helpers/tmt.dart';
import 'package:tpos_mobile/helpers/ui_help.dart';
import 'package:tpos_mobile/sale_online/models/tpos_service/calculate_fee_result.dart';
import 'package:tpos_mobile/sale_online/ui/delivery_carrier_search_page.dart';
import 'package:tpos_mobile/fast_sale_order/viewmodels/fast_sale_order_add_edit_full_ship_info_viewmodel.dart';
import 'package:tpos_mobile/fast_sale_order/viewmodels/fast_sale_order_add_edit_full_viewmodel.dart';
import 'package:tpos_mobile/widgets/ModalWaitingWidget.dart';

import '../../app_service_locator.dart';

class FastSaleOrderAddEditFullShipInfoPage extends StatefulWidget {
  final FastSaleOrderAddEditFullViewModel editVm;
  FastSaleOrderAddEditFullShipInfoPage({@required this.editVm});
  @override
  _FastSaleOrderAddEditFullShipInfoPageState createState() =>
      _FastSaleOrderAddEditFullShipInfoPageState();
}

class _FastSaleOrderAddEditFullShipInfoPageState
    extends State<FastSaleOrderAddEditFullShipInfoPage> {
  var _vm = locator<FastSaleOrderAddEditFullShipInfoViewModel>();

  var _weightController = new TextEditingController();
  var _feeController = new TextEditingController();
  var _depositController = new TextEditingController();
  var _cashOnDeliveryController = new TextEditingController();
  var _deliverNoteController = new TextEditingController();
  var _insuranceFeeController = new TextEditingController();
  TextEditingController _edittingController;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isEditInsuranceFee = false;

  Future _selectDeliveryCarrier(BuildContext context) async {
    var selectedCarrier = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => DeliveryCarrierSearchPage(
          closeWhenDone: true,
          isSearch: true,
          selectedDeliveryCarrier: _vm.deliveryCarrier,
        ),
      ),
    );

    if (selectedCarrier != null) {
      _vm.selectDeliveryCarrierCommand(selectedCarrier);
    }
  }

  @override
  void initState() {
    _vm.init(editVm: widget.editVm);

    _weightController.text = NumberFormat("###,###,###").format(_vm.weight);
    _feeController.text = vietnameseCurrencyFormat(_vm.shippingFee);
    _depositController.text = vietnameseCurrencyFormat(_vm.depositeAmount);
    _insuranceFeeController.text =
        vietnameseCurrencyFormat(_vm.shipInsuranceFee);
    _cashOnDeliveryController.text =
        vietnameseCurrencyFormat(_vm.cashOnDelivery);
    _deliverNoteController.text = _vm.editVM.deliveryNote;

    if (_vm.editVM?.carrier != null) {
      _vm.selectDeliveryCarrierCommand(_vm.editVM?.carrier);
    }

    _vm.addListener(() {
      if (_edittingController != _weightController)
        _weightController.text = NumberFormat("###,###,###").format(_vm.weight);
      if (_edittingController != _feeController)
        _feeController.text = vietnameseCurrencyFormat(_vm.shippingFee);
      if (_edittingController != _depositController)
        _depositController.text = vietnameseCurrencyFormat(_vm.depositeAmount);
      _cashOnDeliveryController.text =
          vietnameseCurrencyFormat(_vm.cashOnDelivery);
      if (_edittingController != _deliverNoteController)
        _deliverNoteController.text = _vm.editVM.deliveryNote;
      _insuranceFeeController.text =
          vietnameseCurrencyFormat(_vm.shipInsuranceFee);
    });

    _vm.dialogMessageController.listen((f) {
      registerDialogToView(context, f, scaffState: _scaffoldKey.currentState);
    });

    super.initState();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FastSaleOrderAddEditFullShipInfoViewModel>(
      model: _vm,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Đối tác giao hàng & phí"),
        ),
        body: _buildBody(),
        bottomNavigationBar: BottomBackButton(
          content: "QUAY LẠI HÓA ĐƠN",
        ),
      ),
    );
  }

  Widget _buildBody() {
    Divider defaultDivider = new Divider(
      height: 1,
    );

    TextStyle defaultNumberStyle = new TextStyle(fontWeight: FontWeight.bold);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context)?.requestFocus(new FocusNode());
      },
      child: ModalWaitingWidget(
        isBusyStream: _vm.isBusyController,
        initBusy: false,
        child: ScopedModelDescendant<FastSaleOrderAddEditFullShipInfoViewModel>(
          builder: (ctx, _, model) {
            return Container(
              color: Colors.grey.shade300,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      color: Colors.white,
                      child: ListTile(
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
                          "${_vm.deliveryCarrier?.name ?? "Nhấp để chọn"}",
                          textAlign: TextAlign.end,
                          style: Theme.of(context)
                              .textTheme
                              .body1
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        trailing: Icon(Icons.chevron_right),
                        onTap: () async {
                          if (_vm.deliveryCarrier != null) {
                            // Thong bao chon lai
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: Text("${_vm.deliveryCarrier?.name}"),
                                actions: <Widget>[
                                  OutlineButton.icon(
                                    label: Text("Bỏ chọn"),
                                    icon: Icon(Icons.remove_circle),
                                    textColor: Colors.red,
                                    color: Colors.white,
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _vm.selectDeliveryCarrierCommand(null);
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
                    ),
                    defaultDivider,
                    //Ca lấy hàng\
                    Builder(
                      builder: (ctx) {
                        if (_vm.shipExtra != null ||
                            (_vm.deliveryCarrier?.deliveryType ?? "") ==
                                "GHTK") {
                          return Container(
                            color: Colors.white,
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text("Ca lấy hàng:"),
                                  trailing: SizedBox(
                                    width: 200,
                                    child: DropdownButton<String>(
                                        hint: Text("Chọn ca lấy hàng"),
                                        isExpanded: true,
                                        value: _vm.shipExtra?.pickWorkShift ??
                                            null,
                                        items: _vm.shifts.keys.map((key) {
                                          return DropdownMenuItem<String>(
                                            value: key,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                SizedBox(),
                                                Text(
                                                  _vm.shifts[key],
                                                  style: defaultNumberStyle,
                                                  textAlign: TextAlign.right,
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          _vm.selectShipExtraCommand(value);
                                        }),
                                  ),
                                )
                              ],
                            ),
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    ),

                    //Dịch vụ của đối tác
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            title: Text("Dịch vụ:"),
                            trailing: SizedBox(
                              width: 200,
                              child:
                                  DropdownButton<CalucateFeeResultDataService>(
                                      isExpanded: true,
                                      value: _vm.deliverCarrierService,
                                      items: _vm.deliverCarrierServices
                                          ?.map((f) => DropdownMenuItem<
                                                  CalucateFeeResultDataService>(
                                                value: f,
                                                child: Text(
                                                  "${f.serviceName} | ${vietnameseCurrencyFormat(f.totalFee)}",
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                              ))
                                          ?.toList(),
                                      onChanged: (value) {
                                        _vm.selectDeliveryCarrierServiceCommand(
                                            value);
                                      }),
                            ),
                          )
                        ],
                      ),
                    ),
                    defaultDivider,

                    // Tùy chọn thêm dịch vụ
                    Container(
                      color: Colors.white,
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount:
                            _vm.deliverCarrierServiceExtraList?.length ?? 0,
                        itemBuilder: (ctx, index) {
                          // Checkbox
                          var itemWidget = CheckboxListTile(
                              title: Text(
                                  "${_vm.deliverCarrierServiceExtraList[index].serviceName} | (${vietnameseCurrencyFormat(_vm.deliverCarrierServiceExtraList[index].fee)})"),
                              dense: true,
                              value: _vm.deliverCarrierServiceExtraList[index]
                                  .isSelected,
                              onChanged: (value) {
                                setState(() {
                                  _vm.deliverCarrierServiceExtraList[index]
                                      .isSelected = value;

                                  if (value == true &&
                                      _vm.deliverCarrierServiceExtraList[index]
                                          .serviceName
                                          .toLowerCase()
                                          .contains("khai giá")) {
                                    _vm.getDefaultInsuranceFeeCommand();
                                  }
                                });
                              });

                          if (_vm.deliverCarrierServiceExtraList[index]
                                  .serviceName
                                  .toLowerCase()
                                  .contains("khai giá") &&
                              _vm.deliverCarrierServiceExtraList[index]
                                  .isSelected) {
                            return Column(
                              children: <Widget>[
                                itemWidget,
                                SizedBox(
                                  height: 5,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  child: SizedBox(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Expanded(
                                          child: TextField(
                                            enabled: this.isEditInsuranceFee,
                                            textAlign: TextAlign.right,
                                            controller:
                                                (_vm.isInsuranceFeeEquarTotal &&
                                                        this.isEditInsuranceFee)
                                                    ? null
                                                    : _insuranceFeeController,
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                                    decimal: true,
                                                    signed: true),
                                            inputFormatters: [
                                              WhitelistingTextInputFormatter
                                                  .digitsOnly,
                                              NumberInputFormat.vietnameDong(),
                                            ],
                                            style: defaultNumberStyle,
                                            decoration: InputDecoration(
                                              hintText:
                                                  "mặc định = giá trị hóa đơn)",
                                              alignLabelWithHint: true,
                                              border: UnderlineInputBorder(),
                                              suffix: SizedBox(
                                                height: 40,
                                                child: !this.isEditInsuranceFee
                                                    ? SizedBox()
                                                    : OutlineButton(
                                                        onPressed: () {
                                                          if (this
                                                              .isEditInsuranceFee) {
                                                            this.isEditInsuranceFee =
                                                                false;
                                                            _vm.reCalculateDeliveryFeeCommand();
                                                          } else {
                                                            setState(() {
                                                              this.isEditInsuranceFee =
                                                                  true;
                                                            });
                                                          }
                                                        },
                                                        child: Text(
                                                            "Xác nhận thay đổi"),
                                                      ),
                                              ),
                                            ),
                                            onChanged: (text) {
                                              double value =
                                                  Tmt.convertToDouble(
                                                      text, "vi_VN");

                                              _vm.shipInsuranceFee = value;
                                            },
                                            onTap: () {
                                              _insuranceFeeController
                                                      .selection =
                                                  TextSelection(
                                                      baseOffset: 0,
                                                      extentOffset:
                                                          _insuranceFeeController
                                                              .text.length);
                                            },
                                          ),
                                        ),
                                        Builder(
                                          builder: (ctx) {
                                            if (!this.isEditInsuranceFee) {
                                              return OutlineButton(
                                                child: Text(
                                                  "Sửa",
                                                  style: TextStyle(
                                                      color: Colors.blue),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    this.isEditInsuranceFee =
                                                        true;
                                                  });
                                                },
                                              );
                                            } else {
                                              return SizedBox();
                                            }
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return itemWidget;
                          }
                        },
                      ),
                    ),

                    SizedBox(
                      height: 1,
                    ),

                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.green.shade200,
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(left: 10, top: 7, bottom: 7),
                          child: Row(
                            children: <Widget>[
                              Text("Phí giao hàng của đối tác: "),
                              Expanded(
                                child: Text(
                                  "${vietnameseCurrencyFormat(_vm.shippingFeeOfCarrier) ?? "N/A"}",
                                  style: defaultNumberStyle.copyWith(
                                      color: Colors.red),
                                ),
                              ),
                              if (_vm.deliveryCarrier != null)
                                SizedBox(
                                  height: 25,
                                  child: FlatButton(
                                    padding: EdgeInsets.all(0),
                                    textColor: Colors.blue,
                                    onPressed: () {
                                      _vm.reCalculateDeliveryFeeCommand();
                                    },
                                    child: Text("Tính lại"),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            title: Text("Khối lượng: (gram)"),
                            trailing: SizedBox(
                                width: 150,
                                child: TextField(
                                  controller: _weightController,
                                  textAlign: TextAlign.right,
                                  style: defaultNumberStyle,
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  inputFormatters: [
                                    WhitelistingTextInputFormatter.digitsOnly,
                                    NumberInputFormat.vietnameDong(),
                                  ],
                                  onTap: () {
                                    _weightController.selection = TextSelection(
                                        baseOffset: 0,
                                        extentOffset:
                                            _weightController.text.length);
                                    _edittingController = _weightController;
                                  },
                                  onChanged: (text) {
                                    double value =
                                        Tmt.convertToDouble(text, "vi_VN");

                                    _vm.weight = value;
                                  },
                                )),
                          ),
                          defaultDivider,
                          ListTile(
                            title: Text("Phí giao hàng:"),
                            trailing: SizedBox(
                                width: 150,
                                child: TextField(
                                  controller: _feeController,
                                  textAlign: TextAlign.right,
                                  style: defaultNumberStyle,
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  inputFormatters: [
                                    WhitelistingTextInputFormatter.digitsOnly,
                                    NumberInputFormat.vietnameDong(),
                                  ],
                                  onTap: () {
                                    _edittingController = _feeController;
                                    _feeController.selection = TextSelection(
                                        baseOffset: 0,
                                        extentOffset:
                                            _feeController.text.length);
                                  },
                                  onChanged: (text) {
                                    double value =
                                        Tmt.convertToDouble(text, "vi_VN");

                                    _vm.shippingFee = value;
                                  },
                                )),
                          ),
                          defaultDivider,
                          ListTile(
                            title: Text("Tiền cọc:"),
                            trailing: SizedBox(
                                width: 150,
                                child: TextField(
                                  controller: _depositController,
                                  textAlign: TextAlign.right,
                                  style: defaultNumberStyle,
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  inputFormatters: [
                                    WhitelistingTextInputFormatter.digitsOnly,
                                    NumberInputFormat.vietnameDong(),
                                  ],
                                  onChanged: (text) {
                                    double value =
                                        Tmt.convertToDouble(text, "vi_VN");
                                    _vm.depositeAmount = value;
                                  },
                                  onTap: () {
                                    _edittingController = _depositController;
                                    _depositController.selection =
                                        TextSelection(
                                            baseOffset: 0,
                                            extentOffset:
                                                _depositController.text.length);
                                  },
                                )),
                          ),
                          defaultDivider,
                          ListTile(
                            title: Text("Tiền thu hộ:"),
                            trailing: SizedBox(
                                width: 150,
                                child: TextField(
                                  style: defaultNumberStyle.copyWith(
                                      color: Colors.red),
                                  controller: _cashOnDeliveryController,
                                  textAlign: TextAlign.right,
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  inputFormatters: [
                                    WhitelistingTextInputFormatter.digitsOnly,
                                    NumberInputFormat.vietnameDong(),
                                  ],
                                  onChanged: (text) {
                                    double value =
                                        Tmt.convertToDouble(text, "vi_VN");
                                    _vm.cashOnDelivery = value;
                                  },
                                  onTap: () {
                                    _edittingController =
                                        _cashOnDeliveryController;
                                    _cashOnDeliveryController.selection =
                                        TextSelection(
                                            baseOffset: 0,
                                            extentOffset:
                                                _cashOnDeliveryController
                                                    .text.length);
                                  },
                                )),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: 17, right: 8, top: 5, bottom: 10),
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(Icons.note),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Ghi chú đơn hàng"),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextField(
                            controller: _deliverNoteController,
                            onChanged: (text) {
                              widget.editVm.order.deliveryNote = text;
                            },
                            maxLines: null,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  gapPadding: 10,
                                  borderSide: BorderSide(
                                      width: 1,
                                      color: Colors.grey,
                                      style: BorderStyle.solid),
                                ),
                                hintText: "Để lại ghi chú cho bên giao hàng"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
