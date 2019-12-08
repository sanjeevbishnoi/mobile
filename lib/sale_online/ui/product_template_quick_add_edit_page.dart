/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:52 AM
 *
 */

import 'dart:async';
import 'dart:io';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/app_core/helper/string_helper.dart';
import 'package:tpos_mobile/helpers/tmt.dart';
import 'package:tpos_mobile/src/tpos_apis/models/ProductTemplate.dart';
import 'package:tpos_mobile/sale_online/ui/product_category_page.dart';
import 'package:tpos_mobile/sale_online/ui/product_unit_page.dart';
import 'package:tpos_mobile/sale_online/viewmodels/product_template_quick_add_edit_viewmodel.dart';
import 'package:tpos_mobile/src/tpos_apis/models/productUOM.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product_category.dart';
import 'package:tpos_mobile/widgets/custom_widget.dart';
import 'package:image_picker/image_picker.dart';

class ProductTemplateQuickAddEditPage extends StatefulWidget {
  final bool closeWhenDone;
  final int productId;
  ProductTemplateQuickAddEditPage({this.closeWhenDone, this.productId});
  @override
  _ProductTemplateQuickAddEditPageState createState() =>
      _ProductTemplateQuickAddEditPageState(
          closeWhenDone: closeWhenDone, productId: productId);
}

class _ProductTemplateQuickAddEditPageState
    extends State<ProductTemplateQuickAddEditPage> {
  bool closeWhenDone;
  int productId;
  _ProductTemplateQuickAddEditPageState(
      {this.closeWhenDone = false, this.productId});
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  ProductTemplateQuickAddEditViewModel viewModel =
      new ProductTemplateQuickAddEditViewModel();

  TextEditingController _tenSpTextController = new TextEditingController();
  TextEditingController _maSpTextController = new TextEditingController();
  TextEditingController _maVachTextController = new TextEditingController();
  TextEditingController _khoiLuongTextController = new TextEditingController();
  TextEditingController _giaBanTextController = new TextEditingController();
  TextEditingController _giaVonTextController = new TextEditingController();
  TextEditingController _tonKhoController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FocusNode _tenSpFocus = FocusNode();
  final FocusNode _maSpFocus = FocusNode();
  final FocusNode _maVachFocus = FocusNode();
  final FocusNode _khoiLuongFocus = FocusNode();
  final FocusNode _giaBanFocus = FocusNode();
  final FocusNode _giaVonFocus = FocusNode();

  final decorateBox = new BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
  );

  @override
  void initState() {
    viewModel.product.id = productId;
    viewModel.init();
    viewModel.productStream.listen((product) {
      _tenSpTextController.text = viewModel.product.name;
      _maSpTextController.text = viewModel.product.defaultCode.toString();
      _maVachTextController.text = viewModel.product.barcode;
      _khoiLuongTextController.text = NumberFormat("###,###.###", Tmt.locate)
          .format(viewModel.product.weight);
      _giaBanTextController.text =
          vietnameseCurrencyFormat(viewModel.product.listPrice);
      _giaVonTextController.text =
          vietnameseCurrencyFormat(viewModel.product.standardPrice);

      _tonKhoController.text = viewModel.product.initInventory.toString();
    });

    notifySubcrible = viewModel.notifyPropertyChangedController.listen((name) {
      setState(() {});
    });

    viewModel.dialogMessageController.listen((message) {
      registerDialogToView(context, message,
          scaffState: _scaffoldKey.currentState);
    });
    super.initState();

    viewModel.dialogMessageController.listen((message) {
      registerDialogToView(context, message,
          scaffState: _scaffoldKey.currentState);
    });
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

  StreamSubscription notifySubcrible;

  @override
  void dispose() {
    // TODO: implement dispose
    notifySubcrible.cancel();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewBaseWidget(
      isBusyStream: viewModel.isBusyController,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title:
              productId == null ? Text("Thêm sản phẩm") : Text("Sửa sản phẩm"),
          actions: <Widget>[
            FlatButton.icon(
              label: Text("Lưu"),
              textColor: Colors.white,
              icon: Icon(Icons.check),
              onPressed: () async {
                save();
              },
            ),
          ],
        ),
        body: Container(color: Colors.grey.shade200, child: _showBody()),
      ),
    );
  }

  Widget _buildImageSelect() {
    return GestureDetector(
      onTap: () {
        setState(() {
          viewModel.product.imageUrl = null;
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
        color: Colors.white,
      ),
    );
  }

  Widget _showBody() {
    final theme = Theme.of(context);
    return new StreamBuilder<ProductTemplate>(
        stream: viewModel.productStream,
        initialData: viewModel.product,
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Form(
                key: _key,
                autovalidate: _validate,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        new Container(
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
                            if (snapshot.data.imageUrl != null &&
                                snapshot.data.imageUrl != "") {
                              return Stack(
                                alignment: Alignment.topRight,
                                children: <Widget>[
                                  Image.network(
                                    snapshot.data.imageUrl,
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
                                        builder: (BuildContext context) {
                                          return SimpleDialog(
                                            title: Text("Menu"),
                                            children: <Widget>[
                                              ListTile(
                                                leading: Icon(Icons.camera),
                                                title: Text("Chọn từ máy ảnh"),
                                                onTap: () {
                                                  getImage(ImageSource.camera);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              ListTile(
                                                leading: Icon(Icons.image),
                                                title: Text("Chọn từ thư viện"),
                                                onTap: () {
                                                  getImage(ImageSource.gallery);
                                                  Navigator.pop(context);
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
                      ],
                    ),
                    new Divider(),
                    // Tên sản phẩm
                    new Container(
                      padding: EdgeInsets.all(5),
                      decoration: decorateBox,
                      child: Column(
                        children: <Widget>[
                          new TextFormField(
                            autofocus: false,
                            controller: _tenSpTextController,
                            onEditingComplete: () {
                              _tenSpFocus.unfocus();
                              FocusScope.of(context).requestFocus(_maSpFocus);
                            },
                            focusNode: _tenSpFocus,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(5),
                              icon: Icon(Icons.filter),
                              labelText: 'Tên sản phẩm',
                            ),
                            validator: validateName,
                          ),
                          new Divider(
                            height: 2,
                          ),
                          // Mã sản phẩm
                          new TextFormField(
                            controller: _maSpTextController,
                            focusNode: _maSpFocus,
                            onFieldSubmitted: (term) {
                              _maSpFocus.unfocus();
                              FocusScope.of(context).requestFocus(_maVachFocus);
                            },
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(5),
                              icon: Icon(Icons.clear_all),
                              labelText: 'Mã sản phẩm',
                            ),
                          ),
                          new Divider(
                            height: 2,
                          ),
                          // Mã vạch
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: new TextFormField(
                                  controller: _maVachTextController,
                                  focusNode: _maVachFocus,
                                  onFieldSubmitted: (term) {
                                    _maVachFocus.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(_khoiLuongFocus);
                                  },
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(5),
                                    icon: Icon(Icons.filter_list),
                                    labelText: 'Mã vạch',
                                  ),
                                ),
                              ),
                              new IconButton(
                                icon: new Icon(Icons.center_focus_strong),
                                onPressed: () async {
                                  try {
                                    var barcode = await BarcodeScanner.scan();
                                    if (barcode != "" && barcode != null) {
                                      setState(() {
                                        _maVachTextController.text = barcode;
                                      });
                                    }
                                  } on PlatformException catch (e) {
                                    if (e.code ==
                                        BarcodeScanner.CameraAccessDenied) {
                                      showError(
                                          context: context,
                                          title: "Chưa cấp quyền camera",
                                          message:
                                              "Vui lòng vào cài đặt cho phép ứng dụng truy cập camera");
                                    } else {
                                      showError(
                                          context: context,
                                          title: "Chưa quét được mã vạch",
                                          message: "Vui lòng thử lại");
                                    }
                                  } on FormatException {
                                    showError(
                                        context: context,
                                        title: "Chưa quét được mã vạch",
                                        message: "Vui lòng thử lại");
                                  } catch (e) {
                                    showError(
                                        context: context,
                                        title: "Chưa quét được mã vạch",
                                        message: "Vui lòng thử lại");
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // Loại sản phẩm
                    new Container(
                      padding: EdgeInsets.all(5),
                      decoration: decorateBox,
                      child: Column(
                        children: <Widget>[
                          // Loại sản phẩm
                          new Row(
                            children: <Widget>[
                              new Expanded(
                                flex: 3,
                                child: new Text(
                                  "Chọn loại sản phẩm",
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                              DropdownButtonHideUnderline(
                                child: new DropdownButton<String>(
                                  isDense: true,
                                  hint: new Text("Chọn loại sản phẩm"),
                                  value: viewModel.selectedProductType,
                                  onChanged: (String newValue) {
                                    setState(() {
                                      viewModel.selectedProductType = newValue;
                                    });
                                  },
                                  items: viewModel.sorts.map((Map map) {
                                    return new DropdownMenuItem<String>(
                                      value: map["name"],
                                      child: new Text(
                                        map["name"],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),

                          new Divider(
                            height: 2,
                          ),
                          // Nhóm sản phẩm
                          new ListTile(
                            title: Text("Nhóm sản phẩm"),
                            subtitle: Text(
                                "${viewModel.product?.categ?.name ?? "Chọn nhóm sản phẩm"}"),
                            trailing: Icon(Icons.keyboard_arrow_right),
                            onTap: () async {
                              ProductCategory result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ProductCategoryPage();
                                  },
                                ),
                              );
                              if (result != null) {
                                viewModel.selectProductCategoryCommand(result);
                              }
                            },
                          ),
                          new Divider(
                            height: 2,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    new Container(
                      padding: EdgeInsets.all(5),
                      decoration: decorateBox,
                      child: Column(
                        children: <Widget>[
                          // Khối lượng
                          new Row(
                            children: <Widget>[
                              new Icon(
                                Icons.transit_enterexit,
                                color: Colors.green,
                              ),
                              new Expanded(
                                flex: 3,
                                child: new Text(
                                  "Khối lượng",
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                              new Expanded(
                                flex: 3,
                                child: TextField(
                                  onChanged: (value) {
                                    viewModel.product.weight =
                                        int.tryParse(value) ?? 0;
                                  },
                                  onTap: () {
                                    _khoiLuongTextController.selection =
                                        TextSelection(
                                            baseOffset: 0,
                                            extentOffset:
                                                _khoiLuongTextController
                                                    .text.length);
                                  },
                                  controller: _khoiLuongTextController,
                                  textAlign: TextAlign.end,
                                  focusNode: _khoiLuongFocus,
                                  onEditingComplete: () {
                                    _khoiLuongFocus.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(_giaBanFocus);
                                  },
                                  inputFormatters: [
                                    PercentInputFormat(
                                        locate: "vi_VN", format: "###,###.###"),
                                  ],
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    hintText: "Nhập khối lượng",
                                    contentPadding: EdgeInsets.all(12),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            height: 2,
                          ),
                          // Giá bán
                          new Row(
                            children: <Widget>[
                              Icon(
                                Icons.attach_money,
                                color: Colors.green,
                              ),
                              new Expanded(
                                flex: 3,
                                child: new Text(
                                  "Giá bán",
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                              new Expanded(
                                flex: 3,
                                child: TextField(
                                  onChanged: (value) {
                                    viewModel.product.listPrice =
                                        int.tryParse(value) ?? 0;
                                  },
                                  controller: _giaBanTextController,
                                  onTap: () {
                                    _giaBanTextController.selection =
                                        TextSelection(
                                            baseOffset: 0,
                                            extentOffset: _giaBanTextController
                                                .text.length);
                                  },
                                  textAlign: TextAlign.end,
                                  focusNode: _giaBanFocus,
                                  onEditingComplete: () {
                                    _giaBanFocus.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(_giaVonFocus);
                                  },
                                  inputFormatters: [
                                    WhitelistingTextInputFormatter.digitsOnly,
                                    CurrencyInputFormatter(),
                                  ],
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    hintText: "Nhập giá bán",
                                    contentPadding: EdgeInsets.all(12),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            height: 2,
                          ),
                          // Giá vốn
                          new Row(
                            children: <Widget>[
                              Icon(
                                Icons.attach_money,
                                color: Colors.green,
                              ),
                              new Expanded(
                                flex: 3,
                                child: new Text(
                                  "Giá vốn",
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                              new Expanded(
                                flex: 3,
                                child: TextField(
                                  onChanged: (value) {
                                    viewModel.product.purchasePrice =
                                        double.tryParse(value) ?? 0;
                                  },
                                  controller: _giaVonTextController,
                                  onTap: () {
                                    _giaVonTextController.selection =
                                        TextSelection(
                                            baseOffset: 0,
                                            extentOffset: _giaVonTextController
                                                .text.length);
                                  },
                                  textAlign: TextAlign.end,
                                  focusNode: _giaVonFocus,
                                  onEditingComplete: () {
                                    _giaVonFocus.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(_tenSpFocus);
                                  },
                                  inputFormatters: [
                                    WhitelistingTextInputFormatter.digitsOnly,
                                    CurrencyInputFormatter(),
                                  ],
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    hintText: "Nhập giá vốn",
                                    contentPadding: EdgeInsets.all(12),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            height: 2,
                          ),
                          // Tồn kho
                          new Row(
                            children: <Widget>[
                              Icon(
                                Icons.attach_money,
                                color: Colors.green,
                              ),
                              new Expanded(
                                flex: 3,
                                child: new Text(
                                  "Tồn kho",
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                              new Expanded(
                                flex: 3,
                                child: TextField(
                                  onChanged: (value) {
                                    viewModel.product.initInventory =
                                        Tmt.convertToDouble(value, "vi_VN");
                                  },
                                  controller: _tonKhoController,
                                  onTap: () {
                                    _tonKhoController.selection = TextSelection(
                                        baseOffset: 0,
                                        extentOffset:
                                            _tonKhoController.text.length);
                                  },
                                  textAlign: TextAlign.end,
                                  onEditingComplete: () {
                                    _giaVonFocus.unfocus();
                                    FocusScope.of(context)
                                        .requestFocus(_tenSpFocus);
                                  },
                                  inputFormatters: [
                                    WhitelistingTextInputFormatter.digitsOnly,
                                    CurrencyInputFormatter(),
                                  ],
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    hintText: "Nhập tồn kho đầu",
                                    contentPadding: EdgeInsets.all(12),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ),
                    new Container(
                      padding: EdgeInsets.all(5),
                      decoration: decorateBox,
                      child: Column(
                        children: <Widget>[
                          //Đơn vị mặc định
                          new ListTile(
                            title: Text("Đơn vị mặc định"),
                            subtitle: Text(
                                "${viewModel.product?.uOM?.name ?? "Chọn đơn vị sản phẩm"}"),
                            trailing: Icon(Icons.keyboard_arrow_right),
                            onTap: () async {
                              ProductUOM result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ProductUnitPage();
                                  },
                                ),
                              );
                              if (result != null) {
                                viewModel.selectUomCommand(result);
                                viewModel.selectUomPCommand(result);
                              }
                            },
                          ),
                          //Đơn vị mua
                          new ListTile(
                            title: Text("Đơn vị mua"),
                            subtitle: Text(
                                "${viewModel.product?.uOMPO?.name ?? "Chọn đơn vị sản phẩm"}"),
                            trailing: Icon(Icons.keyboard_arrow_right),
                            onTap: () async {
                              ProductUOM result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ProductUnitPage(
                                      uomCateogoryId:
                                          viewModel.product.uOM.categoryId,
                                    );
                                  },
                                ),
                              );
                              if (result != null) {
                                viewModel.selectUomPCommand(result);
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    // Button
                    new Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: <Widget>[
                          new Expanded(
                            flex: 1,
                            child: RaisedButton(
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(5.0)),
                              padding: EdgeInsets.all(15),
                              color: theme.primaryColor,
                              child: Text(
                                "LƯU",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                save();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  String validateName(String value) {
    if (value.length == 0) {
      return "Tên sản phẩm không được bỏ trống";
    }
    return null;
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

  save() async {
    viewModel.product.name = _tenSpTextController.text;
    viewModel.product.defaultCode = _maSpTextController.text.trim();
    viewModel.product.barcode = _maVachTextController.text.trim();

    String khoiLuong = _khoiLuongTextController.text.trim();
    viewModel.product.weight = Tmt.convertToDouble(khoiLuong, "vi_VN");
    viewModel.product.standardPrice =
        double.tryParse(_giaVonTextController.text.trim().replaceAll(".", ""));

    viewModel.product.listPrice =
        double.tryParse(_giaBanTextController.text.trim().replaceAll(".", ""));
    _sendToServer();
    if (_tenSpTextController.text != "") {
//      await compute(viewModel.convertImageBase64, _image);
      await viewModel.save(_image);
      if (closeWhenDone == true) {
        Navigator.pop(context, viewModel.product);
      }
    }
  }
}
