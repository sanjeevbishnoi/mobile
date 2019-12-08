import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/main_app.dart';
import 'package:tpos_mobile/src/tpos_apis/models/Address.dart';
import 'package:tpos_mobile/src/tpos_apis/models/account_payment_term.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner_category.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner_status.dart';

import 'package:tpos_mobile/src/tpos_apis/tpos_models.dart';
import 'package:tpos_mobile/sale_online/ui/partner_category_page.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_select_address.dart';
import 'package:tpos_mobile/sale_online/ui/sale_online_select_partner_status_dialog_page.dart';
import 'package:tpos_mobile/sale_online/viewmodels/partner_add_edit_viewmodel.dart';
import 'package:tpos_mobile/widgets/custom_widget.dart';

class PartnerAddEditPage extends StatefulWidget {
  final bool closeWhenDone;
  final int partnerId;
  final Function(Partner) onEditPartner;
  final bool isCustomer;
  final bool isSupplier;
  PartnerAddEditPage(
      {this.closeWhenDone,
      this.partnerId,
      this.onEditPartner,
      this.isCustomer = true,
      this.isSupplier = false});
  @override
  _PartnerAddEditPageState createState() =>
      _PartnerAddEditPageState(closeWhenDone: closeWhenDone);
}

class _PartnerAddEditPageState extends State<PartnerAddEditPage> {
  bool closeWhenDone;
  _PartnerAddEditPageState({this.closeWhenDone = false});
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  PartnerAddEditViewModel viewModel = new PartnerAddEditViewModel();

  TextEditingController checkAddressController = new TextEditingController();
  TextEditingController addressController = new TextEditingController();
  TextEditingController maKhachHangController = new TextEditingController();
  TextEditingController tenKhachHangController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController zaloController = new TextEditingController();
  TextEditingController facebookController = new TextEditingController();
  TextEditingController websiteController = new TextEditingController();
  TextEditingController maVachController = new TextEditingController();
  TextEditingController maSoThueController = new TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FocusNode _maKhachHangFocus = FocusNode();
  final FocusNode _tenKhachHangFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _checkAddressFocus = FocusNode();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _zaloFocus = FocusNode();
  final FocusNode _facebookFocus = FocusNode();
  final FocusNode _websiteFocus = FocusNode();
  final FocusNode _maSoThueFocus = FocusNode();

  @override
  void initState() {
    viewModel.partner.id = widget.partnerId;
    viewModel.init(
        isSupplier: widget.isSupplier, isCustomer: widget.isCustomer);
    // Parner changed
    viewModel.partnerStream.listen(
      (partner) {
        if (viewModel.partner != null) {
          if (viewModel.partner.street != null)
            addressController.text = viewModel.partner.street;
          if (viewModel.partner.ref != null)
            maKhachHangController.text = viewModel.partner.ref;
          tenKhachHangController.text = viewModel.partner.name;
          phoneController.text = viewModel.partner.phone;
          maSoThueController.text = viewModel.partner.taxCode;
          maVachController.text = viewModel.partner.barcode;
          emailController.text = viewModel.partner.email;
          zaloController.text = viewModel.partner.zalo;
          facebookController.text = viewModel.partner.facebook;
          websiteController.text = viewModel.partner.website;
        }
      },
    );

    viewModel.eventController.listen((event) {
      if (event.eventName == "GO_BACK") Navigator.pop(context);
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    viewModel.notifyPropertyChangedController.listen((name) {
      setState(() {});
    });

    viewModel.dialogMessageController.listen((message) {
      registerDialogToView(context, message,
          scaffState: _scaffoldKey.currentState);
    });

    super.didChangeDependencies();
  }

  File _image;
  Future getImage(ImageSource source) async {
    try {
      var image = await ImagePicker.pickImage(source: source, maxWidth: 400.0);
      setState(() {
        _image = image;
      });
    } catch (ex) {}
  }

  @override
  Widget build(BuildContext context) {
    return ViewBaseWidget(
      isBusyStream: viewModel.isBusyController,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: widget.partnerId == null
              ? widget.isCustomer
                  ? Text("Thêm khách hàng")
                  : widget.isSupplier ? Text("Thêm nhà cung cấp") : Text("N/A")
              : Text("Sửa đối tác"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                save();
                if (tenKhachHangController.text != "") {
                  viewModel.partner.barcode = maVachController.text.trim();
                  var result = await viewModel.save(_image);
                  if (widget.onEditPartner != null && result == true) {
                    widget.onEditPartner(viewModel.partner);
                    Navigator.pop(context);
                  }
                  if (closeWhenDone == true && result == true) {
                    Navigator.pop(context, viewModel.partner);
                  }
                }
              },
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context)?.requestFocus(new FocusNode());
          },
          child: Container(
            color: Colors.grey.shade200,
            child: Column(children: <Widget>[
              Expanded(child: _showBody()),
              // Button
            ]),
          ),
        ),
        bottomNavigationBar: new Padding(
          padding:
              const EdgeInsets.only(left: 20, top: 6, bottom: 12, right: 20),
          child: Row(
            children: <Widget>[
              new Expanded(
                flex: 1,
                child: RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5.0)),
                  padding: EdgeInsets.all(12),
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  child: Text(
                    "LƯU",
                  ),
                  onPressed: () async {
                    save();
                    if (tenKhachHangController.text != "") {
                      viewModel.partner.barcode = maVachController.text.trim();
                      await viewModel.save(_image);
                      if (widget.onEditPartner != null)
                        widget.onEditPartner(viewModel.partner);
                      if (closeWhenDone == true) {
                        Navigator.pop(context, viewModel.partner);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showBody() {
    List<Widget> chils = new List<Widget>();

    if (true) {
      chils.add(Text("dieksjdf"));
      chils.add(Text("dieksjdf"));
      chils.add(Text("dieksjdf"));
    }
    return new StreamBuilder<Partner>(
        stream: viewModel.partnerStream,
        initialData: viewModel.partner,
        builder: (context, snapshot) {
          return SingleChildScrollView(
            child: Form(
              key: _key,
              autovalidate: _validate,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Row(
                      children: <Widget>[
                        new Radio(
                          groupValue: viewModel.radioValue,
                          value: 0,
                          onChanged: (newValue) {
                            setState(() {
                              viewModel.handleRadioValueChanged(newValue);
                            });
                          },
                        ),
                        new Text("Cá nhân"),
                        new Radio(
                          groupValue: viewModel.radioValue,
                          value: 1,
                          onChanged: (newValue) {
                            setState(() {
                              viewModel.handleRadioValueChanged(newValue);
                            });
                          },
                        ),
                        new Text("Công ty"),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: GestureDetector(
                            child: Material(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3),
                                  side: BorderSide(
                                      color: Colors.green,
                                      width: 1,
                                      style: BorderStyle.solid)),
                              color: getTextColorFromParterStatus(
                                  snapshot.data?.status)[0],
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  "${viewModel.partner?.statusText ?? "Chưa có trạng thái"}",
                                  style: TextStyle(
                                      color: getTextColorFromParterStatus(
                                          snapshot.data?.status)[1]),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            onTap: () async {
                              if (widget.partnerId != null) {
                                PartnerStatus selectStatus = await showDialog(
                                    context: context,
                                    builder: (ctx) {
                                      return AlertDialog(
                                        content:
                                            SaleOnlineSelectPartnerStatusDialogPage(),
                                      );
                                    });

                                if (selectStatus != null) {
                                  viewModel.updateParterStatus(
                                      selectStatus.value, selectStatus.text);
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Thông tin khách h
                  Container(
                    color: Colors.white,
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      title: Text("Thông tin khách hàng"),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 5),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: new Container(
                                      height: 120,
                                      child: Builder(builder: (context) {
                                        if (_image != null) {
                                          return Stack(
                                            alignment: Alignment.topRight,
                                            children: <Widget>[
                                              Image.file(_image),
                                              _buildImageSelect(),
                                            ],
                                          );
                                        }
                                        if (snapshot.data?.imageUrl != null &&
                                            snapshot.data?.imageUrl != "") {
                                          return Stack(
                                            alignment: Alignment.topRight,
                                            children: <Widget>[
                                              Image.network(
                                                snapshot.data?.imageUrl,
                                                height: 120,
                                                width: 120,
                                              ),
                                              _buildImageSelect(),
                                            ],
                                          );
                                        }
                                        return new Padding(
                                          padding: const EdgeInsets.all(3),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                              color: Colors.green,
                                            )),
                                            height: 120,
                                            width: 120,
                                            child: IconButton(
                                              color: Colors.green,
                                              icon: Icon(Icons.add),
                                              onPressed: () async {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return SimpleDialog(
                                                        title: Text("Menu"),
                                                        children: <Widget>[
                                                          ListTile(
                                                            leading: Icon(
                                                                Icons.camera),
                                                            title: Text(
                                                                "Chọn từ máy ảnh"),
                                                            onTap: () {
                                                              getImage(
                                                                  ImageSource
                                                                      .camera);
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          ),
                                                          ListTile(
                                                            leading: Icon(
                                                                Icons.image),
                                                            title: Text(
                                                                "Chọn từ thư viện"),
                                                            onTap: () {
                                                              getImage(
                                                                  ImageSource
                                                                      .gallery);
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    });
                                              },
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: <Widget>[
                                        // Mã khách hàng
                                        new TextFormField(
                                          onEditingComplete: () {
                                            _maKhachHangFocus.unfocus();
                                            FocusScope.of(context).requestFocus(
                                                _tenKhachHangFocus);
                                          },
                                          controller: maKhachHangController,
                                          focusNode: _maKhachHangFocus,
                                          textInputAction: TextInputAction.next,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.all(0),
                                            icon: Icon(Icons.code),
                                            labelText: 'Mã khách hàng',
                                          ),
                                        ),
                                        new Divider(),
                                        // Tên khách hàng
                                        new TextFormField(
                                          controller: tenKhachHangController,
                                          onEditingComplete: () {
                                            _tenKhachHangFocus.unfocus();
                                            FocusScope.of(context)
                                                .requestFocus(_phoneFocus);
                                          },
                                          focusNode: _tenKhachHangFocus,
                                          textInputAction: TextInputAction.next,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.all(0),
                                            icon: Icon(Icons.account_circle),
                                            labelText: 'Tên khách hàng',
                                          ),
                                          validator: validateName,
                                        ),
                                        new Divider(),
                                        // Điện thoại
                                        new TextFormField(
                                          controller: phoneController,
                                          onEditingComplete: () {
                                            _phoneFocus.unfocus();
                                            FocusScope.of(context)
                                                .requestFocus(_addressFocus);
                                          },
                                          focusNode: _phoneFocus,
                                          keyboardType: TextInputType.number,
                                          onFieldSubmitted: (term) {},
                                          textInputAction: TextInputAction.next,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.all(0),
                                            icon: Icon(Icons.phone),
                                            labelText: 'Điện thoại',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              new Divider(),
                              new Row(
                                children: <Widget>[
                                  new Chip(
                                    backgroundColor:
                                        Colors.greenAccent.shade100,
                                    label: Text(
                                      "Nợ hiện tại: ${vietnameseCurrencyFormat(snapshot.data?.credit) ?? 0}",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  Expanded(
                                    child: new CheckboxListTile(
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      value: viewModel.isActive,
                                      title: new Text('Active'),
                                      onChanged: (bool value) {
                                        viewModel.isCheckActive(value);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              new Divider(),
                              // Địa chỉ
                              new TextField(
                                maxLines: null,
                                onEditingComplete: () {
                                  _addressFocus.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(_checkAddressFocus);
                                },
                                focusNode: _addressFocus,
                                controller: addressController,
                                onChanged: (value) {
                                  viewModel.partner.street = value;
                                },
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(0),
                                  icon: Icon(Icons.location_on),
                                  labelText: 'Địa chỉ',
                                  counter: SizedBox(
                                    height: 30,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        FlatButton(
                                          padding: EdgeInsets.all(0),
                                          child: Text("Copy"),
                                          textColor: Colors.blue,
                                          onPressed: () {
                                            Clipboard.setData(new ClipboardData(
                                                text: addressController.text
                                                    .trim()));
                                            Scaffold.of(context).showSnackBar(
                                                new SnackBar(
                                                    content: Text(
                                                        "Đã copy ${addressController.text.trim()} vào clipboard")));
                                          },
                                        ),
                                        FlatButton(
                                          textColor: Colors.blue,
                                          padding: EdgeInsets.all(0),
                                          child: Text("Kiểm tra"),
                                          onPressed: () async {
                                            var result =
                                                await Navigator.pushNamed(
                                              context,
                                              AppRoute.check_address,
                                              arguments: {
                                                "keyword": addressController
                                                    .text
                                                    .trim(),
                                              },
                                            );
//
                                            if (result != null) {
                                              viewModel
                                                  .selectCheckAddressCommand(
                                                      result);
                                            }

                                            FocusScope.of(context)
                                                .requestFocus(new FocusNode());
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0, right: 15),
                          child: Column(
                            children: <Widget>[
                              // Check địa chỉ
//
                              new Divider(
                                height: 1,
                              ),
                              //Chọn tỉnh/thành phố
                              new ListTile(
                                contentPadding: EdgeInsets.all(0),
                                leading: Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    "Tỉnh thành",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                                title: Text(
                                  "${snapshot.data?.city?.name ?? "Chọn tỉnh/thành phố"}",
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
                                  viewModel.partnerCity = selectAddress;
                                },
                              ),
                              //Chọn quận/huyện
                              new ListTile(
                                contentPadding: EdgeInsets.all(0),
                                leading: Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    "Quận/Huyện",
                                    style: TextStyle(fontSize: 15),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                title: Text(
                                  "${snapshot.data?.district?.name ?? "Chọn quận/huyện"}",
                                  textAlign: TextAlign.right,
                                ),
                                trailing: Icon(Icons.chevron_right),
                                onTap: () async {
                                  if (snapshot.data?.city == null) return;
                                  Address selectAddress = await Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                      builder: (ctx) {
                                        return new SelectAddressPage(
                                          cityCode:
                                              viewModel.partner.city?.code,
                                          districtCode: null,
                                        );
                                      },
                                    ),
                                  );

                                  viewModel.partnerDistrict = selectAddress;
                                },
                              ),
                              //Chọn phường/xã
                              new ListTile(
                                contentPadding: EdgeInsets.all(0),
                                leading: Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    "Phường/Xã",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                                title: Text(
                                  "${snapshot.data?.ward?.name ?? "Chọn phường/xã"}",
                                  style: TextStyle(),
                                  textAlign: TextAlign.right,
                                ),
                                trailing: Icon(Icons.chevron_right),
                                onTap: () async {
                                  if (snapshot.data?.district == null) return;
                                  Address selectAddress = await Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                      builder: (ctx) {
                                        return new SelectAddressPage(
                                          cityCode:
                                              viewModel.partner.city?.code,
                                          districtCode:
                                              viewModel.partner.district?.code,
                                        );
                                      },
                                    ),
                                  );

                                  viewModel.partnerWard = selectAddress;
                                },
                              ),
                              Divider(
                                height: 1,
                              ),
                              // Danh sách địa chỉ lựa chọn
                            ],
                          ),
                        ),
                        new ListTile(
                          title: Text("Nhóm khách hàng"),
                          subtitle: Column(
                            children: <Widget>[
                              _showChip(context),
                            ],
                          ),
                          trailing: Icon(Icons.keyboard_arrow_right),
                          onTap: () async {
                            PartnerCategory result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return PartnerCategoryPage(
                                    partnerCategories:
                                        viewModel.partnerCategories,
                                  );
                                },
                              ),
                            );
                            if (result != null) {
                              if (!viewModel.partnerCategories
                                  .any((f) => f.id == result.id))
                                viewModel.selectPartnerCategoryCommand(result);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // Thông tin chi tiết
                  Container(
                    color: Colors.white,
                    child: ExpansionTile(
                      title: ListTile(
                        contentPadding: EdgeInsets.all(0),
                        title: Text(
                          "Thông tin bổ sung (ĐT, mail, zalo, fb..)",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      initiallyExpanded: false,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0, right: 15),
                          child: new Column(
                            children: <Widget>[
                              new TextFormField(
                                onEditingComplete: () {
                                  _emailFocus.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(_zaloFocus);
                                },
                                focusNode: _emailFocus,
                                controller: emailController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(0),
                                  icon: Icon(Icons.email),
                                  labelText: 'Email',
                                ),
                              ),
                              Divider(),
                              new TextFormField(
                                onEditingComplete: () {
                                  _zaloFocus.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(_facebookFocus);
                                },
                                controller: zaloController,
                                focusNode: _zaloFocus,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(0),
                                  icon: Icon(Icons.account_box),
                                  labelText: 'Zalo',
                                ),
                              ),
                              Divider(),
                              new TextFormField(
                                onEditingComplete: () {
                                  _facebookFocus.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(_websiteFocus);
                                },
                                focusNode: _facebookFocus,
                                controller: facebookController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(0),
                                  icon: Icon(Icons.face),
                                  labelText: 'Facebook',
                                ),
                              ),
                              Divider(),
                              new TextFormField(
                                onEditingComplete: () {
                                  _websiteFocus.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(_maSoThueFocus);
                                },
                                focusNode: _websiteFocus,
                                controller: websiteController,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(0),
                                  icon: Icon(Icons.cloud),
                                  labelText: 'Website',
                                ),
                              ),
                              Divider(),
                              viewModel.radioValue == 0
                                  ? SizedBox()
                                  : new TextFormField(
                                      onEditingComplete: () {
                                        _maSoThueFocus.unfocus();
                                      },
                                      focusNode: _maSoThueFocus,
                                      controller: maSoThueController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(0),
                                        icon: Icon(Icons.insert_invitation),
                                        labelText: 'Mã số thuế',
                                      ),
                                    ),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    color: Colors.white,
                    child: ExpansionTile(
                      title: ListTile(
                        contentPadding: EdgeInsets.all(0),
                        title: Text(
                          "Bán hàng",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      initiallyExpanded: false,
                      children: <Widget>[
                        new CheckboxListTile(
                          value: viewModel.isCustomer,
                          title: new Text('Là khách hàng'),
                          onChanged: (bool value) {
                            viewModel.isCheckCustomer(value);
                          },
                        ),
                        //TODO Chọn bảng giá
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 15.0, right: 15.0),
                          child: Column(
                            children: <Widget>[
//                              DropdownButtonHideUnderline(
//                                child: DropdownButton<ProductPrice>(
//                                  isExpanded: true,
//                                  hint: Text("Chọn bảng giá"),
//                                  value: viewModel.selectedProductPrice,
//                                  onChanged: (ProductPrice newValue) async {
//                                    setState(() {
//                                      viewModel.selectedProductPrice = newValue;
//                                    });
//                                  },
//                                  items: viewModel.productPrices?.map(
//                                    (ProductPrice productPrice) {
//                                      return new DropdownMenuItem<ProductPrice>(
//                                        value: productPrice,
//                                        child: new Text(
//                                          "${productPrice.name ?? ""}",
//                                        ),
//                                      );
//                                    },
//                                  )?.toList(),
//                                ),
//                              ),
                              (viewModel.accountPayments == null ||
                                      viewModel.accountPayments.length == 0)
                                  ? SizedBox()
                                  : DropdownButtonHideUnderline(
                                      child: DropdownButton<AccountPaymentTerm>(
                                        isExpanded: true,
                                        hint: Text(
                                            "Điều khoản khách hàng thanh toán"),
                                        value: viewModel.selectedAccountPayment,
                                        onChanged: (AccountPaymentTerm
                                            newValue) async {
                                          setState(() {
                                            viewModel.selectedAccountPayment =
                                                newValue;
                                          });
                                        },
                                        items: viewModel.accountPayments.map(
                                            (AccountPaymentTerm
                                                accountPayment) {
                                          return new DropdownMenuItem<
                                              AccountPaymentTerm>(
                                            value: accountPayment,
                                            child: new Text(
                                              "${accountPayment.name ?? ""}",
                                            ),
                                          );
                                        })?.toList(),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    color: Colors.white,
                    child: ExpansionTile(
                      title: ListTile(
                        contentPadding: EdgeInsets.all(0),
                        title: Text(
                          "Mua hàng",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      initiallyExpanded: false,
                      children: <Widget>[
                        new CheckboxListTile(
                          value: viewModel.isProvider,
                          title: new Text('Là nhà cung cấp'),
                          onChanged: (bool value) {
                            viewModel.isCheckProvider(value);
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 15.0, right: 15.0),
                          child: viewModel.accountPayments == null
                              ? SizedBox()
                              : DropdownButtonHideUnderline(
                                  child: DropdownButton<AccountPaymentTerm>(
                                    isExpanded: true,
                                    hint: Text(
                                        "Điều khoản thanh toán nhà cung cấp"),
                                    value: viewModel.selectedSupplierPayment,
                                    onChanged:
                                        (AccountPaymentTerm newValue) async {
                                      setState(() {
                                        viewModel.selectedSupplierPayment =
                                            newValue;
                                      });
                                    },
                                    items: viewModel.accountPayments.map(
                                        (AccountPaymentTerm accountPayment) {
                                      return new DropdownMenuItem<
                                          AccountPaymentTerm>(
                                        value: accountPayment,
                                        child: new Text(
                                          "${accountPayment.name ?? ""}",
                                        ),
                                      );
                                    })?.toList(),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    color: Colors.white,
                    child: ExpansionTile(
                      title: ListTile(
                        contentPadding: EdgeInsets.all(0),
                        title: Text(
                          "Điểm bán hàng",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      initiallyExpanded: false,
                      children: <Widget>[
                        // Mã vạch
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0, right: 15),
                          child: new TextFormField(
                            controller: maVachController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(0),
                              icon: Icon(Icons.code),
                              labelText: 'Mã vạch',
                            ),
                          ),
                        ),
                        new SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildImageSelect() {
    return GestureDetector(
      onTap: () {
        setState(() {
          viewModel.partner.imageUrl = null;
          _image = null;
          return new Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                color: Colors.green,
              )),
              height: 120,
              width: 120,
              child: IconButton(
                color: Colors.green,
                icon: Icon(Icons.add),
                onPressed: () async {},
              ),
            ),
          );
        });
      },
      child: Icon(
        Icons.close,
        color: Colors.redAccent,
      ),
    );
  }

  Widget _showChip(BuildContext context) {
    return StreamBuilder<List<PartnerCategory>>(
        stream: viewModel.partnerCategoriesStream,
        initialData: viewModel.partnerCategories,
        builder: (ctx, snapshot) {
          return Wrap(
            spacing: 1.0,
            runSpacing: 0,
            runAlignment: WrapAlignment.start,
            children: List<Widget>.generate(viewModel.partnerCategories?.length,
                (index) {
              return Chip(
                backgroundColor: Colors.greenAccent.shade100,
                onDeleted: () {
                  viewModel.removePartnerCategoryCommand(
                      viewModel.partnerCategories[index]);
                },
                label: Text("${viewModel.partnerCategories[index]?.name}"),
              );
            }),
          );
        });
  }

  String validateName(String value) {
    if (value.length == 0) {
      return "Tên khách hàng không được bỏ trống";
    }
    return null;
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  void save() {
    if (viewModel.partner == null) viewModel.partner = new Partner();
    viewModel.partner.ref = maKhachHangController.text.trim();
    viewModel.partner.name = tenKhachHangController.text;
    viewModel.partner.phone = phoneController.text.trim();
    viewModel.partner.street = addressController.text.trim();
    viewModel.partner.zalo = zaloController.text.trim();
    viewModel.partner.facebook = facebookController.text.trim();
    viewModel.partner.email = emailController.text.trim();
    viewModel.partner.website = websiteController.text.trim();
    viewModel.partner.barcode = maVachController.text.trim();
    viewModel.partner.taxCode = maSoThueController.text.trim();
    _sendToServer();
  }

  _sendToServer() {
    if (_key.currentState.validate()) {
      // No any error in validation
      _key.currentState.save();
    } else {
      // validation error
      setState(() {
        _validate = true;
      });
    }
  }
}
