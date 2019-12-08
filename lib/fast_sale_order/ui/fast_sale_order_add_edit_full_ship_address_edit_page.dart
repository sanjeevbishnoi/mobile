import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/main_app.dart';
import 'package:tpos_mobile/src/tpos_apis/models/CityAddress.dart';
import 'package:tpos_mobile/src/tpos_apis/models/DistrictAddress.dart';
import 'package:tpos_mobile/src/tpos_apis/models/Address.dart';
import 'package:tpos_mobile/src/tpos_apis/models/ward_address.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_select_address.dart';
import 'package:tpos_mobile/fast_sale_order/viewmodels/fast_sale_order_add_edit_full_viewmodel.dart';
import 'package:tpos_mobile/sale_online/viewmodels/ship_receiver_model.dart';
import 'package:tpos_mobile/widgets/ModalWaitingWidget.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class FastSaleOrderAddEditFullShipAddressEditPage extends StatefulWidget {
  FastSaleOrderAddEditFullShipAddressEditPage({this.editOrderVm});
  final FastSaleOrderAddEditFullViewModel editOrderVm;

  @override
  _FastSaleOrderAddEditFullShipAddressEditPageState createState() =>
      _FastSaleOrderAddEditFullShipAddressEditPageState();
}

class _FastSaleOrderAddEditFullShipAddressEditPageState
    extends State<FastSaleOrderAddEditFullShipAddressEditPage> {
  var _vm = new ShipReceiverModel();

  var _nameTextController = new TextEditingController();
  var _phoneTextController = new TextEditingController();
  var _streetTextController = new TextEditingController();
  var _checkKeywordTextController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scafffoldKey = new GlobalKey<ScaffoldState>();

  bool _isKeyboardVisible = false;

  @override
  void initState() {
    _vm.init(
        partnerId: widget.editOrderVm.partner?.id, editVm: widget.editOrderVm);
    _vm.dialogMessageController.listen((message) {
      registerDialogToView(context, message,
          scaffState: _scafffoldKey.currentState);
    });

    // Tính phí nêu có đối tác

    KeyboardVisibilityNotification().addNewListener(onChange: (value) {
      if (mounted)
        setState(() {
          _isKeyboardVisible = value;
        });
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
    _vm.shipReceiver = widget.editOrderVm.shipReceiver;
    return ScopedModel<ShipReceiverModel>(
      model: _vm,
      child: GestureDetector(
        child: Scaffold(
          key: _scafffoldKey,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text("Địa chỉ giao hàng"),
            actions: <Widget>[],
          ),
          body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(child: _buildBody()),
                if (!_isKeyboardVisible)
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
                if (_isKeyboardVisible)
                  Container(
                    child: RaisedButton(
                      textColor: Colors.white,
                      child: Text("XONG"),
                      color: Colors.grey.shade500,
                      onPressed: () {
                        FocusScope.of(context)?.requestFocus(new FocusNode());
                      },
                    ),
                  ),
              ]),
        ),
        onTapDown: (tap) {
          FocusScope.of(context)?.requestFocus(new FocusNode());
        },
      ),
    );
  }

  Widget _buildBody() {
    return ScopedModelDescendant<ShipReceiverModel>(
      rebuildOnChange: true,
      builder: (ctx, _, model) {
        _nameTextController.text = model.shipReceiver.name;
        _phoneTextController.text = model.shipReceiver.phone;
        _streetTextController.text = model.shipReceiver.street;
        _checkKeywordTextController.text = model.checkKeyword;

        return ModalWaitingWidget(
          isBusyStream: model.isBusyController,
          initBusy: false,
          child: Container(
            color: Colors.grey.shade300,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  //TODO CHọn địa chỉ khách hàng hoặc tùy chọn
//                  Container(
//                    child: Row(
//                      children: <Widget>[
//                        Radio(
//                            value: true,
//                            groupValue: "1",
//                            onChanged: (value) {}),
//                        Text("Lấy địa chỉ khách hàng"),
//                        Radio(
//                            value: true,
//                            groupValue: "1",
//                            onChanged: (value) {}),
//                        Text("Tùy chọn"),
//                      ],
//                    ),
//                  ),
                  Container(
                    padding: EdgeInsets.only(left: 12, right: 12),
                    color: Colors.white,
                    child: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        TextField(
                          decoration: InputDecoration(
                            labelText: "Tên người nhận:",
                          ),
                          controller: _nameTextController,
                          onChanged: (text) {
                            model.name = text.trim();
                          },
                        ),
                        TextField(
                          controller: _phoneTextController,
                          autofocus: false,
                          onChanged: (text) {
                            model.phone = text.trim();
                          },
                          decoration: InputDecoration(
                            labelText: "Số điện thoại:",
                          ),
                        ),
                        TextField(
                            maxLines: null,
                            controller: _streetTextController,
                            onChanged: (text) {
                              model.street = text;
                            },
                            decoration: InputDecoration(
                              labelText: "Địa chỉ:",
                              counter: SizedBox(
                                height: 30,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    FlatButton(
                                      padding: EdgeInsets.all(0),
                                      child: Text("Copy"),
                                      textColor: Colors.blue,
                                      onPressed: () {
                                        Clipboard.setData(new ClipboardData(
                                            text: model.shipReceiver.street));
                                        Scaffold.of(ctx).showSnackBar(new SnackBar(
                                            content: Text(
                                                "Đã copy ${model.shipReceiver.street} vào clipboard")));
                                      },
                                    ),
                                    FlatButton(
                                      textColor: Colors.blue,
                                      padding: EdgeInsets.all(0),
                                      child: Text("Kiểm tra"),
                                      onPressed: () async {
                                        var result = await Navigator.pushNamed(
                                          context,
                                          AppRoute.check_address,
                                          arguments: {
                                            "keyword": _streetTextController
                                                .text
                                                .trim(),
                                            "selectedAddress":
                                                _vm.selectedCheckAddress,
                                          },
                                        );
//
                                        if (result != null) {
                                          _vm.selectCheckAddressCommand(result);
                                        }

                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                      },
                                    )
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Builder(
                    builder: (context) {
                      if (widget.editOrderVm.isHideWarningDeliverAddress) {
                        return SizedBox();
                      }
                      String partnerStreet = widget.editOrderVm.partner?.street;
                      String currentStreet = _vm.street;
                      if (partnerStreet != currentStreet) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 12, right: 12, top: 12, bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: <Widget>[
                                Text(
                                    "Địa chỉ giao hàng hiện tại khác với địa chỉ của khách hàng. Bạn có muốn lưu địa chỉ này vào khách hàng đang chọn?"),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    RaisedButton(
                                      child: Text("Chỉ cho hóa đơn này"),
                                      textColor: Colors.white,
                                      color: Colors.deepPurple,
                                      onPressed: () {
                                        setState(() {
                                          widget.editOrderVm
                                                  .isHideWarningDeliverAddress =
                                              true;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    RaisedButton(
                                      color: Colors.green,
                                      child: Text("Ok Lưu"),
                                      textColor: Colors.white,
                                      onPressed: () async {
                                        var result = await showQuestion(
                                            context: context,
                                            title: "Xác nhận lưu",
                                            message:
                                                "Thông tin địa chỉ của khách hàng sẽ được thay thế bằng thông tin này");

                                        if (result == OldDialogResult.Yes) {
                                          // Lưu TODO
                                          await _vm
                                              .updatePartnerAddressCommand();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return SizedBox();
                      }
                    },
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 12, right: 12),
                    color: Colors.white,
                    child: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        SelectAddressWidget(
                          title: "Tỉnh thành: ",
                          currentValue: model.shipReceiver?.city?.name ??
                              "Chọn tỉnh thành",
                          onTap: () async {
                            Address selectedCity = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (ctx) => SelectAddressPage()));

                            if (selectedCity != null) {
                              model.city = new CityAddress(
                                  code: selectedCity.code,
                                  name: selectedCity.name);
                            }
                          },
                        ),
                        Divider(),
                        SelectAddressWidget(
                          title: "Quận/huyện",
                          currentValue: model.shipReceiver?.district?.name ??
                              "Chọn quận huyện",
                          valueColor: model.shipReceiver?.district == null
                              ? Colors.orange
                              : Colors.black,
                          onTap: () async {
                            if (model.shipReceiver.city == null ||
                                model.shipReceiver.city.code == null) {
                              return;
                            }
                            Address selectedCity = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (ctx) => SelectAddressPage(
                                          cityCode:
                                              model.shipReceiver.city.code,
                                        )));

                            if (selectedCity != null) {
                              model.district = new DistrictAddress(
                                  code: selectedCity.code,
                                  name: selectedCity.name);
                            }
                          },
                        ),
                        Divider(),
                        SelectAddressWidget(
                          title: "Phường/xã",
                          currentValue: model.shipReceiver?.ward?.name ??
                              "Chọn phường xã",
                          valueColor: model.shipReceiver?.ward == null
                              ? Colors.orange
                              : Colors.black,
                          onTap: () async {
                            if (model.shipReceiver.district == null ||
                                model.shipReceiver.district.code == null) {
                              return;
                            }
                            Address selectedCity = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (ctx) => SelectAddressPage(
                                          cityCode:
                                              model.shipReceiver.city.code,
                                          districtCode:
                                              model.shipReceiver.district.code,
                                        )));

                            if (selectedCity != null) {
                              model.ward = new WardAddress(
                                  code: selectedCity.code,
                                  name: selectedCity.name);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 12, right: 12),
                    color: Colors.white,
                    child: TextField(
                      onChanged: (text) {
                        model.checkKeyword = text.trim();
                      },
                      controller: _checkKeywordTextController,
                      decoration: InputDecoration(
                          suffix: OutlineButton(
                            onPressed: () async {
                              var result = await Navigator.pushNamed(
                                context,
                                AppRoute.check_address,
                                arguments: {
                                  "keyword":
                                      _checkKeywordTextController.text.trim(),
                                  "selectedAddress": _vm.selectedCheckAddress,
                                },
                              );
//
                              if (result != null) {
                                _vm.selectCheckAddressCommand(result);
                              }

                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                            },
                            child: Text(
                              "Kiểm tra",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          labelText: "Nhập đc viết tắt để tìm địa chỉ nhanh",
                          hintText: "VD: 54 dmc, tsn, tp, hcm "),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    color: Colors.white,
                    child: ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        separatorBuilder: (ctx, index) => Divider(
                              height: 1,
                            ),
                        itemCount: model.checkAddressResults?.length ?? 0,
                        shrinkWrap: true,
                        itemBuilder: (ctx, index) {
                          return Row(
                            children: <Widget>[
                              Checkbox(
                                value: model.selectedCheckAddress ==
                                    model.checkAddressResults[index],
                                onChanged: (value) {
                                  model.selectCheckAddressCommand(
                                      model.checkAddressResults[index]);
                                },
                              ),
                              Expanded(
                                  child: Text(model
                                          .checkAddressResults[index].address ??
                                      ""))
                            ],
                          );
                        }),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SelectAddressWidget extends StatelessWidget {
  final String title;
  final String currentValue;
  final EdgeInsetsGeometry contentPadding;
  final Function onTap;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) onTap();
      },
      child: Padding(
        padding: contentPadding,
        child: Row(
          children: <Widget>[
            Text(title ?? ""),
            Expanded(
              child: Text(
                currentValue ?? "",
                textAlign: TextAlign.right,
                style: TextStyle(color: valueColor),
              ),
            ),
            Icon(Icons.chevron_right)
          ],
        ),
      ),
    );
  }

  SelectAddressWidget(
      {this.title,
      this.currentValue,
      this.onTap,
      this.valueColor = Colors.black,
      this.contentPadding =
          const EdgeInsets.only(left: 8, top: 8, bottom: 8, right: 2)});
}
