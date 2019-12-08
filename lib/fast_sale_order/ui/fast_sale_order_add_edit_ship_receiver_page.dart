/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/16/19 5:56 PM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/16/19 5:54 PM
 *
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/main_app.dart';
import 'package:tpos_mobile/sale_online/ui/delivery_carrier_search_page.dart';
import 'package:tpos_mobile/src/tpos_apis/models/CheckAddress.dart';
import 'package:tpos_mobile/src/tpos_apis/models/CityAddress.dart';
import 'package:tpos_mobile/src/tpos_apis/models/DistrictAddress.dart';

import 'package:tpos_mobile/src/tpos_apis/models/Address.dart';
import 'package:tpos_mobile/sale_online/models/tpos_service/calculate_fee_result.dart';
import 'package:tpos_mobile/src/tpos_apis/models/ward_address.dart';
import 'package:tpos_mobile/sale_online/ui/partner_add_edit_page.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_select_address.dart';

import 'package:tpos_mobile/sale_online/viewmodels/viewmodel.dart';

import 'package:tpos_mobile/widgets/ModalWaitingWidget.dart';

class FastSaleOrderAddEditShipReceiverPage extends StatefulWidget {
  final FastSaleOrderAddEditViewModel viewModel;

  FastSaleOrderAddEditShipReceiverPage({@required this.viewModel});
  @override
  _FastSaleOrderAddEditShipReceiverPageState createState() =>
      _FastSaleOrderAddEditShipReceiverPageState(viewModel: viewModel);
}

class _FastSaleOrderAddEditShipReceiverPageState
    extends State<FastSaleOrderAddEditShipReceiverPage> {
  FastSaleOrderAddEditViewModel _viewModel;
  _FastSaleOrderAddEditShipReceiverPageState(
      {@required FastSaleOrderAddEditViewModel viewModel}) {
    this._viewModel = viewModel;
    assert(_viewModel != null);
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _weightTextController;
  TextEditingController _cashOnDeliveryTextController;
  TextEditingController _deliveryPriceTextController;
  TextEditingController _deliveryDepositTextController;

  TextEditingController _checkAddressKeywordController;

  TextEditingController _shipInsuranceFeeController =
      new TextEditingController();

  NumberInputFormat _weightInputForamt;
  NumberInputFormat _cashOnDeliveryInputFormat;

  NumberInputFormat _deliveryPriceInputForamt;

  NumberInputFormat _deliveryDepositInputFormat;

  final FocusNode _customerNameFocus = FocusNode();
  final FocusNode _phoneNumberFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _khoiLuongFocus = FocusNode();
  final FocusNode _tienThuHoFocus = FocusNode();
  final FocusNode _phiGiaoHangFocus = FocusNode();
  final FocusNode _tienCocFocus = FocusNode();
  //final FocusNode _ghiChuFocus = FocusNode();

  StreamSubscription notifyChangedSubscription;

  @override
  void initState() {
    _viewModel.dialogMessageController
        .where((f) =>
            f.receiver == AppRoute.fast_sale_order_add_edit_ship_receiver)
        .listen((dialog) {
      registerDialogToView(context, dialog,
          scaffState: _scaffoldKey.currentState);
    });
    _weightInputForamt =
        new NumberInputFormat(value: _viewModel.order.shipWeight);
    _cashOnDeliveryInputFormat = new NumberInputFormat.vietnameDong(
        value: _viewModel.order.cashOnDelivery);
    _deliveryPriceInputForamt = new NumberInputFormat.vietnameDong(
        value: _viewModel.order.deliveryPrice);
    _deliveryDepositInputFormat = new NumberInputFormat.vietnameDong(
        value: _viewModel.order.amountDeposit);
    _weightTextController = TextEditingController(
        text: "${vietnameseCurrencyFormat(_viewModel.order.shipWeight)}");
    _cashOnDeliveryTextController = TextEditingController(
        text: "${vietnameseCurrencyFormat(_viewModel.order.cashOnDelivery)}");

    _deliveryPriceTextController = TextEditingController(
        text: "${vietnameseCurrencyFormat(_viewModel.order.deliveryPrice)}");

    _deliveryDepositTextController = TextEditingController(
        text: "${vietnameseCurrencyFormat(_viewModel.order.amountDeposit)}");

    _checkAddressKeywordController = new TextEditingController();
//    _viewModel.dialogMessageController.listen((dialog) {
//      registerDialogToView(context, dialog,
//          scaffState: _scaffoldKey.currentState);
//    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    // Listen property changed notify from viewModel
    notifyChangedSubscription =
        _viewModel.notifyPropertyChangedController.listen((propertyName) {
      if (this.mounted == false) return;
      setState(() {
        _weightInputForamt =
            new NumberInputFormat(value: _viewModel.order.shipWeight);
        _cashOnDeliveryInputFormat = new NumberInputFormat.vietnameDong(
            value: _viewModel.order.cashOnDelivery);
        _deliveryPriceInputForamt = new NumberInputFormat.vietnameDong(
            value: _viewModel.order.deliveryPrice);
        _deliveryDepositInputFormat = new NumberInputFormat.vietnameDong(
            value: _viewModel.order.amountDeposit);
        _weightTextController = TextEditingController(
            text: "${vietnameseCurrencyFormat(_viewModel.order.shipWeight)}");
        _cashOnDeliveryTextController = TextEditingController(
            text:
                "${vietnameseCurrencyFormat(_viewModel.order.cashOnDelivery)}");

        _deliveryPriceTextController = TextEditingController(
            text:
                "${vietnameseCurrencyFormat(_viewModel.order.deliveryPrice)}");

        _deliveryDepositTextController = TextEditingController(
            text:
                "${vietnameseCurrencyFormat(_viewModel.order.amountDeposit)}");
      });
    });

    _viewModel.shipWeightStream.listen((value) {
      _weightTextController.text = vietnameseCurrencyFormat(value);
    });

    _viewModel.cashOnDeliveryStream.listen((value) {
      _cashOnDeliveryTextController.text = vietnameseCurrencyFormat(value);
    });

    _viewModel.amountDepositStream.listen((value) {
      _deliveryDepositTextController.text = vietnameseCurrencyFormat(value);
    });

    _viewModel.deliveryPriceStream.listen((value) {
      _deliveryPriceTextController.text = vietnameseCurrencyFormat(value);
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Text("Thông tin giao hàng"),
      ),
      body: ModalWaitingWidget(
        isBusyStream: _viewModel.isBusyController,
        initBusy: _viewModel.isBusy,
        statusStream: _viewModel.viewModelStatusController,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    color: Colors.grey.shade100,
                    child: Column(
                      children: <Widget>[
                        // Địa chỉ theo khách hàng

                        Container(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new ListTile(
                              contentPadding:
                                  EdgeInsets.only(right: 0, left: 10),
                              title: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      "Thông tin giao hàng theo khách hàng",
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                    child: FlatButton(
                                      padding: EdgeInsets.all(0),
                                      child: Text("Sửa"),
                                      textColor: Colors.blue,
                                      onPressed: () async {
                                        if (_viewModel.partner != null) {
                                          var partner = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (ctx) =>
                                                      PartnerAddEditPage(
                                                        closeWhenDone: true,
                                                        partnerId: this
                                                            ._viewModel
                                                            .partner
                                                            ?.id,
                                                      )));

                                          if (partner != null) {
                                            _viewModel
                                                .setPartnerCommand(partner);
                                          }
                                        }
                                      },
                                    ),
                                  )
                                ],
                              ),
                              subtitle: Text("""
  - Tên: ${_viewModel.partner.displayName}
  - SĐT: ${_viewModel.partner.phone ?? "<Chưa có SĐT>"}
  - Địa chỉ: ${_viewModel.partner?.street ?? "Khách hàng chưa có địa chỉ. Vui lòng cập nhật để chọn đối tác giao hàng"}"""),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 10,
                        ),

                        _showThongTinNguoiNhan(context),

                        SizedBox(
                          height: 10,
                        ),

                        _showThongTinGiaoHang(context),

                        SizedBox(
                          height: 10,
                        ),

                        _showDeliveryCarrier(),

                        // Ghi chú

                        Container(
                            color: Colors.white,
                            child: SizedBox(
                              height: 10,
                            )),

                        SizedBox(
                          height: 10,
                        ),

                        Material(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: TextField(
                              controller: TextEditingController(
                                  text:
                                      "${_viewModel.order.deliveryNote ?? ""}"),
                              decoration: InputDecoration(
                                  labelText: "Ghi chú giao hàng",
                                  hintText: "Thêm ghi chú",
                                  icon: Icon(Icons.message),
                                  border: InputBorder.none),
                              maxLines: 2,
                              onChanged: (text) {
                                _viewModel.order.deliveryNote = text;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: Colors.white,
                child: new Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: new RaisedButton(
                    padding: EdgeInsets.only(
                      left: 15,
                      right: 15,
                    ),
                    color: Colors.green,
                    child: Text(
                      "Xong",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showThongTinNguoiNhan(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          ExpansionTile(
            title: Text("Tùy chọn địa chỉ người nhận",
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold)),
            children: <Widget>[
              // Tên người nhận
              new Padding(
                padding: const EdgeInsets.only(left: 12),
                child: new Row(
                  children: <Widget>[
                    Icon(
                      Icons.account_circle,
                      color: Colors.green,
                    ),
                    new Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 7),
                        child: TextField(
                          controller: TextEditingController(
                              text: "${_viewModel.shipReceiver?.name ?? ""}"),
                          focusNode: _customerNameFocus,
                          onSubmitted: (term) {
                            _customerNameFocus.unfocus();
                            FocusScope.of(context)
                                .requestFocus(_phoneNumberFocus);
                          },
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: "",
                            labelText: 'Tên người nhận',
                          ),
                          onChanged: (text) {
                            _viewModel.shipReceiver.name = text;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Điện thoại
              new Padding(
                padding: const EdgeInsets.only(left: 12),
                child: new Row(
                  children: <Widget>[
                    Icon(
                      Icons.phone_android,
                      color: Colors.green,
                    ),
                    new Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 7),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(
                              text: "${_viewModel.shipReceiver?.phone ?? ""}"),
                          focusNode: _phoneNumberFocus,
                          onSubmitted: (term) {
                            _phoneNumberFocus.unfocus();
                            FocusScope.of(context).requestFocus(_addressFocus);
                          },
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            hintText: '',
                            labelText: 'Điện thoại',
                          ),
                          onChanged: (text) {
                            _viewModel.shipReceiver.phone = text.trim();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Địa chỉ tùy chọn
              new Padding(
                padding: const EdgeInsets.only(left: 0),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  title: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          maxLines: 1,
                          controller: TextEditingController(
                              text: "${_viewModel.shipReceiver?.street ?? ""}"),
                          focusNode: _addressFocus,
                          onSubmitted: (term) {
                            _addressFocus.unfocus();
                            FocusScope.of(context)
                                .requestFocus(_khoiLuongFocus);
                          },
                          decoration: const InputDecoration(
                            icon: Icon(Icons.add_comment),
                            hintText: 'Số nhà, tên đường',
                            labelText: 'Địa chỉ tùy chọn',
                          ),
                          onChanged: (text) {
                            _viewModel.shipReceiver.street = text;
                          },
                        ),
                      ),
                    ],
                  ),
                  trailing: null,
                  children: <Widget>[
                    new ListTile(
                      leading: Text(
                        "Tỉnh thành",
                        style: TextStyle(color: Colors.green),
                      ),
                      title: Text(
                        "${_viewModel.shipReceiver.city?.name ?? "Chọn tỉnh/thành phố"}",
                        textAlign: TextAlign.right,
                      ),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () async {
                        Address selectAddress = await Navigator.push(
                          context,
                          new MaterialPageRoute(
                            builder: (ctx) {
                              return new SelectAddressPage(
                                cityCode: null,
                                districtCode: null,
                              );
                            },
                          ),
                        );

                        if (selectAddress != null) {
                          var city = new CityAddress(
                              code: selectAddress.code,
                              name: selectAddress.name);

                          _viewModel.selectShipReceiverCityCommand(city);
                        }
                      },
                    ),
                    new ListTile(
                      leading: Text(
                        "Quận/Huyện",
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.green),
                      ),
                      title: Text(
                        "${_viewModel.shipReceiver.district?.name ?? "Chọn Quận/Huyện"}",
                        textAlign: TextAlign.right,
                      ),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () async {
                        if (_viewModel.shipReceiver.city == null) return;
                        Address selectAddress = await Navigator.push(
                          context,
                          new MaterialPageRoute(
                            builder: (ctx) {
                              return new SelectAddressPage(
                                cityCode: _viewModel.shipReceiver.city?.code,
                                districtCode: null,
                              );
                            },
                          ),
                        );

                        if (selectAddress != null) {
                          var district = new DistrictAddress(
                              code: selectAddress.code,
                              name: selectAddress.name);

                          _viewModel
                              .selectShipReceiverDistrictCommand(district);
                        }
                      },
                    ),
                    new ListTile(
                      leading: Text(
                        "Phường/Xã",
                        style: TextStyle(color: Colors.green),
                      ),
                      title: Text(
                        "${_viewModel.shipReceiver?.ward?.name ?? "Chọn phường/xã"}",
                        style: TextStyle(),
                        textAlign: TextAlign.right,
                      ),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () async {
                        if (_viewModel.shipReceiver.district == null) return;
                        Address selectAddress = await Navigator.push(
                          context,
                          new MaterialPageRoute(
                            builder: (ctx) {
                              return new SelectAddressPage(
                                cityCode: _viewModel.shipReceiver.city?.code,
                                districtCode: _viewModel.partner.district?.code,
                              );
                            },
                          ),
                        );

                        if (selectAddress != null) {
                          var ward = new WardAddress(
                              code: selectAddress.code,
                              name: selectAddress.name);

                          _viewModel.selectShipReceiverWardCommand(ward);
                        }
                      },
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: new TextField(
                        maxLines: 2,
                        decoration: InputDecoration(
                            icon: Icon(Icons.streetview),
                            labelText: "Địa chỉ đầy đủ",
                            hintText:
                                "Số nhà, tên đường, phường xã, quận huyện, tỉnh thành"),
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: new TextField(
                        controller: _checkAddressKeywordController,
                        decoration: InputDecoration(
                            icon: Icon(Icons.check_box),
                            hintText: "54/36 dmc, tsn, tp, hcm",
                            labelText: "Kiểm tra địa chỉ nhanh",
                            suffix: SizedBox(
                              height: 35,
                              child: FlatButton(
                                child: Text(
                                  "Kiểm tra",
                                  style: TextStyle(color: Colors.blue),
                                ),
                                onPressed: () {
                                  _viewModel.quickCheckAddress(
                                      _checkAddressKeywordController.text
                                          .trim());
                                },
                              ),
                            )),
                      ),
                    ),
                    new Padding(
                      padding: EdgeInsets.all(8),
                      child: StreamBuilder(
                          stream: _viewModel.checkAddressResultStream,
                          initialData:
                              _viewModel.checkAddressResultStream.value,
                          builder: (ctx, snapshot) {
                            if (snapshot.hasError) {
                              return Container(
                                color: Colors.amber,
                                height: 40,
                                child: Text("${snapshot.error}"),
                              );
                            }

                            if (snapshot.hasData == false) {
                              return SizedBox();
                            }

                            List<CheckAddress> checkAddress = snapshot.data;
                            return DropdownButton<CheckAddress>(
                                underline: SizedBox(),
                                isExpanded: true,
                                value: _viewModel.selectedCheckAddress,
                                items: checkAddress
                                    .map((address) =>
                                        new DropdownMenuItem<CheckAddress>(
                                            value: address,
                                            child: Text("${address.address}")))
                                    .toList(),
                                onChanged: (selected) {
                                  _viewModel
                                      .selectCheckAddressCommand(selected);
                                });
                          }),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _showThongTinGiaoHang(BuildContext context) {
    List<Widget> childrens = new List<Widget>();

    // Khối lượng
    childrens.add(
      new Padding(
        padding: const EdgeInsets.only(left: 12, right: 10, top: 5),
        child: TextField(
          textAlign: TextAlign.right,
          controller: _weightTextController,
          onChanged: (value) {
            _viewModel.order.shipWeight =
                double.tryParse(value.replaceAll(".", "")) ?? 0;
          },
          onTap: () {
            _weightTextController.selection = new TextSelection(
                baseOffset: 0, extentOffset: _weightTextController.text.length);
          },
          inputFormatters: [
            WhitelistingTextInputFormatter(RegExp(r'[\d]+')),
            _weightInputForamt,
          ],
          keyboardType: TextInputType.numberWithOptions(),
          focusNode: _khoiLuongFocus,
          onSubmitted: (term) {
            _khoiLuongFocus.unfocus();
            FocusScope.of(context).requestFocus(_tienThuHoFocus);
            _cashOnDeliveryTextController.selection = new TextSelection(
                baseOffset: 0,
                extentOffset: _cashOnDeliveryTextController.text.length);
          },
          decoration: const InputDecoration(
            icon: Icon(
              FontAwesomeIcons.weightHanging,
            ),
            prefixText: "Khối lượng (g): ",
//              suffixIcon: IconButton(
//                icon: Icon(FontAwesomeIcons.balanceScale),
//              ),
            hintText: 'ví dụ: 500',
            border: InputBorder.none,
          ),
        ),
      ),
    );

    // Tiền cọc
    childrens.add(
      new Padding(
        padding: const EdgeInsets.only(left: 12, right: 10, top: 5),
        child: TextField(
          textAlign: TextAlign.right,
          controller: _deliveryDepositTextController,
          onChanged: (value) {
            _viewModel.setAmountDepositeCommand(
                double.tryParse(value.replaceAll(".", "")) ?? 0);
          },
          onTap: () {
            _deliveryDepositTextController.selection = new TextSelection(
                baseOffset: 0,
                extentOffset: _deliveryDepositTextController.text.length);
          },
          inputFormatters: [
            WhitelistingTextInputFormatter(RegExp(r'[\d]+')),
            _deliveryDepositInputFormat,
          ],
          keyboardType: TextInputType.number,
          focusNode: _tienCocFocus,
          onSubmitted: (term) {
            _khoiLuongFocus.unfocus();
            FocusScope.of(context).requestFocus(_tienThuHoFocus);
            _cashOnDeliveryTextController.selection = new TextSelection(
                baseOffset: 0,
                extentOffset: _cashOnDeliveryTextController.text.length);
          },
          decoration: const InputDecoration(
            icon: Icon(
              FontAwesomeIcons.dollarSign,
            ),
            prefixText: "Tiền cọc:",
            hintText: '',
            border: InputBorder.none,
          ),
        ),
      ),
    );
    // Phí giao hàng
    childrens.add(
      new Padding(
        padding: const EdgeInsets.only(left: 12, right: 10, top: 5),
        child: TextField(
          textAlign: TextAlign.right,
          controller: _deliveryPriceTextController,
          onChanged: (value) {
            double valueDouble =
                double.tryParse(value.replaceAll(".", "")) ?? 0;

            _viewModel.setDeliveryPriceCommand(valueDouble);
          },
          onTap: () {
            _deliveryPriceTextController.selection = new TextSelection(
                baseOffset: 0,
                extentOffset: _deliveryPriceTextController.text.length);
          },
          inputFormatters: [
            WhitelistingTextInputFormatter(RegExp(r'[\d]+')),
            _deliveryPriceInputForamt,
          ],
          keyboardType: TextInputType.number,
          focusNode: _phiGiaoHangFocus,
          onSubmitted: (term) {
            _khoiLuongFocus.unfocus();
            FocusScope.of(context).requestFocus(_tienThuHoFocus);
            _cashOnDeliveryTextController.selection = new TextSelection(
                baseOffset: 0,
                extentOffset: _cashOnDeliveryTextController.text.length);
          },
          decoration: const InputDecoration(
            icon: Icon(
              FontAwesomeIcons.dollarSign,
            ),
            prefixText: "Phí giao hàng:",
            hintText: '',
            border: InputBorder.none,
          ),
        ),
      ),
    );

    // Tiền thu hộ
    childrens.add(
      new Padding(
        padding: const EdgeInsets.only(left: 12, right: 10, top: 5),
        child: TextField(
          style: TextStyle(color: Colors.red),
          textAlign: TextAlign.right,
          controller: _cashOnDeliveryTextController,
          onChanged: (value) {
            double number = double.tryParse(value.replaceAll(".", "")) ?? 0;
            _viewModel.setCashOnDeliveryCommand(number);
          },
          onTap: () {
            _cashOnDeliveryTextController.selection = new TextSelection(
                baseOffset: 0,
                extentOffset: _cashOnDeliveryTextController.text.length);
          },
          inputFormatters: [
            WhitelistingTextInputFormatter(RegExp(r'[\d]+')),
            _cashOnDeliveryInputFormat,
          ],
          keyboardType: TextInputType.number,
          focusNode: _tienThuHoFocus,
          onSubmitted: (term) {
            _khoiLuongFocus.unfocus();
            FocusScope.of(context).requestFocus(_tienThuHoFocus);
            _cashOnDeliveryTextController.selection = new TextSelection(
                baseOffset: 0,
                extentOffset: _cashOnDeliveryTextController.text.length);
          },
          decoration: const InputDecoration(
            icon: Icon(
              FontAwesomeIcons.dollarSign,
            ),
            prefixText: "Tiền thu hộ: ",
            hintText: '',
            border: InputBorder.none,
            fillColor: Colors.red,
          ),
        ),
      ),
    );
    return Container(
      color: Colors.white,
      child: Column(
        children: childrens,
      ),
    );
  }

  // Panel Đơn vị vận chuyển
  Widget _showDeliveryCarrier() {
    List<Widget> columns = new List<Widget>();
    // Tiêu đề
    columns.add(
      new Row(
        children: <Widget>[
          Icon(FontAwesomeIcons.car),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              "Đơn vị vận chuyển",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
          )
        ],
      ),
    );
    columns.add(Divider());
    // Chọn đơn vị vận chuyển
    columns.add(
      new ListTile(
        contentPadding: EdgeInsets.all(0),
        title: Text(
          "${_viewModel.selectedDeliveryCarrier?.name ?? "Chọn đơn vị vận chuyển"}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Giá đề xuất: ${vietnameseCurrencyFormat(_viewModel.suggestedDeliveryPrice)}",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (ctx) => DeliveryCarrierSearchPage(
                        isSearch: true,
                        closeWhenDone: true,
                        selectedDeliveryCarrier:
                            _viewModel.selectedDeliveryCarrier,
                        selectedCallback: (selected) {
                          _viewModel.selectDeliveryCarrierCommand(selected);
                        },
                      )));
        },
      ),
    );
    columns.add(Divider());
    // Dịch vụ của đơn vị vận chuyển
    if (_viewModel.selectedDeliveryCarrier != null &&
        _viewModel.calculateShipingFeeResult != null &&
        _viewModel.calculateShipingFeeResult.services != null &&
        _viewModel.calculateShipingFeeResult.services.length > 0) {
      var services = _viewModel.calculateShipingFeeResult.services;
      columns.add(Divider());
      columns.add(Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                "Dịch vụ: ",
              ),
            ),
            DropdownButton<CalucateFeeResultDataService>(
              underline: SizedBox(),
              onChanged: (value) {
                _viewModel.selectDeliveryCarrierServiceCommand(service: value);
              },
              value: _viewModel.selectedDeliveryCarrierService,
              hint: Text("Chọn dịch vụ"),
              items: services.map((f) {
                return DropdownMenuItem<CalucateFeeResultDataService>(
                  value: f,
                  child: Text(
                    "${f.serviceName})",
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ));

      columns.add(Divider());
      if (_viewModel.selectedDeliveryCarrierService != null &&
          _viewModel.selectedDeliveryCarrierService.extras != null) {
        columns.add(_showDeliveryCarrierServiceExtras(
            _viewModel.selectedDeliveryCarrierService.extras));
      }
    }
    // Ca giao hàng của giao hàng nhanh
    if (_viewModel.selectedDeliveryCarrier != null &&
        _viewModel.selectedDeliveryCarrier.deliveryType == "GHTK") {
      columns.add(Divider());
      columns.add(
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Row(
            children: <Widget>[
              Expanded(child: Text("Ca lấy hàng: ")),
              Expanded(
                child: DropdownButton<String>(
                    isDense: false,
                    underline: null,
                    onChanged: (value) {
                      _viewModel.selectShiftCommand(value);
                    },
                    value: _viewModel.shipExtra?.pickWorkShift ?? null,
                    hint: Text("Chọn ca lấy hàng"),
                    items: _viewModel.shifts.keys.map((key) {
                      return DropdownMenuItem<String>(
                        value: key,
                        child: Text(_viewModel.shifts[key]),
                      );
                    }).toList()),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Column(
        children: columns,
      ),
    );
  }

  /// Danh sách tùy chọn thêm của dịch vụ giao hàng
  Widget _showDeliveryCarrierServiceExtras(
      List<CalculateFeeResultDataExtra> items) {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (ctx, index) {
          return _showDeliveryCarrierServiceExtraItem(items[index]);
        });
  }

  /// Tùy chọn dịch vụ giao hàng
  Widget _showDeliveryCarrierServiceExtraItem(
      CalculateFeeResultDataExtra item) {
    return ListTile(
      leading: Checkbox(
          tristate: false,
          value: item.isSelected,
          onChanged: (value) {
            setState(() {
              _viewModel.selectShipServiceExtra(item, value);
            });
          }),
      title: Text("${item.serviceName}"),
      subtitle: Builder(
        builder: (ctx) {
          if (item.serviceName.contains("Khai Giá Hàng Hoá") &&
              item.isSelected == true) {
            _shipInsuranceFeeController.text =
                vietnameseCurrencyFormat(_viewModel.shipInsuranceFee);
            return SizedBox(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _shipInsuranceFeeController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.red),
                      inputFormatters: [
                        WhitelistingTextInputFormatter(RegExp(r"\d+")),
                        NumberInputFormat.vietnameDong(
                            value: _viewModel.shipInsuranceFee,
                            format: "###,###,###,###"),
                      ],
                      onTap: () {
                        _shipInsuranceFeeController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset:
                                _shipInsuranceFeeController.text.length);
                      },
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                          labelText: "Giá hàng hóa",
                          hintText: "Giá mặc định = giá trị đơn hàng",
                          suffix: OutlineButton(
                            onPressed: () {
                              _viewModel.setShipInsuranceCommand(double.parse(
                                  _shipInsuranceFeeController.text
                                      .replaceAll(".", "")));
                            },
                            child: Text("OK"),
                          )),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return SizedBox();
          }
        },
      ),
      trailing: Text(
        "${vietnameseCurrencyFormat(item.fee)}",
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    notifyChangedSubscription?.cancel();
  }
}
