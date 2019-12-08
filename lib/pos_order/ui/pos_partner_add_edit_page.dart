import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tpos_mobile/app_core/ui_base/view_base.dart';
import 'package:tpos_mobile/helpers/app_helper.dart';
import 'package:tpos_mobile/pos_order/models/partners.dart';
import 'package:tpos_mobile/pos_order/viewmodels/pos_partner_add_edit_viewmodel.dart';

import '../../app_service_locator.dart';

class PosPartnerAddEditPage extends StatefulWidget {
  PosPartnerAddEditPage(this.partner);
  final Partners partner;

  @override
  _PosPartnerAddEditPageState createState() => _PosPartnerAddEditPageState();
}

class _PosPartnerAddEditPageState extends State<PosPartnerAddEditPage> {
  var _vm = locator<PosPartnerAddEditViewModel>();

  TextEditingController _ctrlName = TextEditingController();
  TextEditingController _ctrlAddress = TextEditingController();
  TextEditingController _ctrlPhone = TextEditingController();
  TextEditingController _ctrlBarcode = TextEditingController();
  TextEditingController _ctrlEmail = TextEditingController();
  TextEditingController _ctrlTaxCode = TextEditingController();

  Widget header(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Text(
        "$title",
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _formThongTin(
      {TextEditingController controller, bool isPhone, int maxLine}) {
    //controller.text = value;
    return Padding(
      padding: EdgeInsets.only(left: 12.0, right: isPhone ? 0 : 12.0),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]),
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(3.0),
          ),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 12.0,
            ),
            Expanded(
                child: isPhone
                    ? TextField(
                        controller: controller,
                        decoration: InputDecoration.collapsed(
                          hintText: "",
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly,
                        ],
                      )
                    : TextField(
                        maxLines: maxLine,
                        controller: controller,
                        decoration: InputDecoration.collapsed(
                          hintText: "",
                        ),
                      ))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewBase<PosPartnerAddEditViewModel>(
        model: _vm,
        builder: (context, modle, _) {
          return WillPopScope(
            onWillPop: () async {
              return await confirmClosePage(context,
                  title: "Xác nhận đóng",
                  message:
                      "Các thông tin chưa lưu sẽ bị xóa. Bạn có muốn đóng trang này?");
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text("Thêm khách hàng"),
              ),
              body: Padding(
                padding:
                    const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4.0),
                      topRight: Radius.circular(4.0)),
                  shadowColor: Colors.grey[500],
                  elevation: 4.0,
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 60),
                        child: ListView(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Thông tin khách hàng",
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.blue),
                              ),
                            ),
                            showImage(),
                            header("Tên khách hàng"),
                            _formThongTin(
                                controller: _ctrlName,
                                isPhone: false,
                                maxLine: 1),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      header("Điện thoại"),
                                      _formThongTin(
                                          controller: _ctrlPhone,
                                          isPhone: true),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      header("Mã vạch"),
                                      _formThongTin(
                                          controller: _ctrlBarcode,
                                          isPhone: false,
                                          maxLine: 1),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            header("Email"),
                            _formThongTin(
                                controller: _ctrlEmail,
                                isPhone: false,
                                maxLine: 1),
                            header("Mã số thuế"),
                            _formThongTin(
                                controller: _ctrlTaxCode,
                                isPhone: false,
                                maxLine: 1),
                            header("Địa chỉ"),
                            _formThongTin(
                                controller: _ctrlAddress,
                                isPhone: false,
                                maxLine: 2),
                          ],
                        ),
                      ),
                      _buildBtnXacNhan()
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildBtnXacNhan() {
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
              color: Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(3.0)),
            ),
            child: FlatButton(
              onPressed: () {
                updateInfo(context);
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

  Widget showImage() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      title: Text("Menu"),
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.camera),
                          title: Text("Chọn từ máy ảnh"),
                          onTap: () {
                            _vm.getImageFromCamera();
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.image),
                          title: Text("Chọn từ thư viện"),
                          onTap: () {
                            _vm.getImageFromGallery();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  });
            },
            child: new Container(
              child: Builder(builder: (context) {
                return new Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey[400],
                        )),
                    height: 130,
                    width: 130,
                    child: CircleAvatar(
                      backgroundImage: _vm.image == null
                          ? AssetImage("images/no_image.png")
                          : FileImage(_vm.image),
                    ));
              }),
            ),
          ),
        ],
      ),
    );
  }

  void updateInfo(BuildContext context) async {
    if (_vm.image != null) {
      List<int> imageBytes = _vm.image.readAsBytesSync();
      String base64Image = base64Encode(imageBytes);
      _vm.partner.image = "data:image/png;base64," + base64Image;
    }
    _vm.partner.name = _ctrlName.text;
    _vm.partner.phone = _ctrlPhone.text;
    _vm.partner.barcode = _ctrlBarcode.text;
    _vm.partner.email = _ctrlEmail.text;
    _vm.partner.street = _ctrlAddress.text;
    _vm.partner.taxCode = _ctrlTaxCode.text;
    if (widget.partner == null) {
      await _vm.updatePartner(false);
    } else {
      await _vm.updatePartner(true);
    }
    Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.partner != null) {
      _vm.partner = widget.partner;
      _ctrlName.text = widget.partner.name;
      _ctrlAddress.text = widget.partner.street;
      _ctrlPhone.text = widget.partner.phone;
      _ctrlBarcode.text = widget.partner.barcode;
      _ctrlEmail.text = widget.partner.email;
      _ctrlTaxCode.text = "";
    }
  }
}
