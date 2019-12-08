import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tpos_mobile/helpers/messenger_helper.dart';
import 'package:tpos_mobile/sale_online/ui/product_category_page.dart';
import 'package:tpos_mobile/app_core/ui_base/ui_vm_base.dart';
import 'package:tpos_mobile/sale_online/viewmodels/product_category_add_edit_viewmodel.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product_category.dart';

class ProductCategoryAddEditPage extends StatefulWidget {
  final int productCategoryId;
  final bool closeWhenDone;
  final Function(ProductCategory) onEdited;
  ProductCategoryAddEditPage(
      {this.closeWhenDone, this.productCategoryId, this.onEdited});

  @override
  _ProductCategoryAddEditPageState createState() =>
      _ProductCategoryAddEditPageState();
}

class _ProductCategoryAddEditPageState
    extends State<ProductCategoryAddEditPage> {
  _ProductCategoryAddEditPageState();

  ProductCategoryAddEditViewModel viewModel =
      new ProductCategoryAddEditViewModel();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;

  TextEditingController _nameTextEditingController =
      new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return UIViewModelBase(
      viewModel: viewModel,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: widget.productCategoryId == null
              ? Text("Thêm danh mục sản phẩm")
              : Text("Sửa danh mục sản phẩm"),
          actions: <Widget>[
            FlatButton.icon(
              label: Text("Lưu"),
              textColor: Colors.white,
              icon: Icon(Icons.check),
              onPressed: () async {
                viewModel.productCategory.name =
                    _nameTextEditingController.text.trim();
                _sendToServer();
                if (_nameTextEditingController.text != "") {
                  await viewModel.save();
                  if (widget.closeWhenDone == true) {
                    Navigator.pop(context, viewModel.productCategory);
                  }
                }
                if (widget.onEdited != null)
                  widget.onEdited(viewModel.productCategory);
              },
            ),
          ],
        ),
        body: Container(color: Colors.grey.shade200, child: _showBody()),
      ),
    );
  }

  Widget _showBody() {
    return StreamBuilder<ProductCategory>(
      stream: viewModel.productCategoryStream,
      initialData: viewModel.productCategory,
      builder: (context, snapshot) {
        return Form(
          key: _key,
          autovalidate: _validate,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Text(
                  "Chú ý! Nhóm đã có sản phẩm dịch chuyển kho không thể thay đổi phương pháp giá",
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
                Divider(),
                new TextFormField(
                  controller: _nameTextEditingController,
                  autofocus: false,
                  onEditingComplete: () {},
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(5),
                    icon: Icon(Icons.sort),
                    labelText: 'Tên danh mục',
                  ),
                  validator: validateName,
                ),
                Divider(),
                // Nhóm sản phẩm
                new ListTile(
                  title: Text("Nhóm cha"),
                  subtitle: Text(
                      "${viewModel.productCategory?.parent?.name ?? "Chọn nhóm sản phẩm cha"}"),
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
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: new DropdownButton<String>(
                          isDense: true,
                          hint: new Text("Phương pháp giá"),
                          value: viewModel.selectedPrice,
                          onChanged: (String newValue) {
                            setState(() {
                              viewModel.selectedPrice = newValue;
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
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: new StreamBuilder(
                        stream: viewModel.productCategoryQuantityStream,
                        initialData: viewModel.ordinalNumber,
                        builder: (_, data) {
                          return new Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                "Thứ tự: ${viewModel.ordinalNumber} ",
                                style: TextStyle(fontSize: 16.0),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    width: 30,
                                    height: 20,
                                    child: new RaisedButton(
                                      padding: EdgeInsets.all(0),
                                      child: Icon(Icons.keyboard_arrow_up),
                                      onPressed: () {
                                        viewModel.ordinalNumber += 1;
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    child: new RaisedButton(
                                      child: Icon(
                                        Icons.keyboard_arrow_down,
                                      ),
                                      padding: EdgeInsets.all(0),
                                      onPressed: () {
                                        if (viewModel.ordinalNumber > 0)
                                          viewModel.ordinalNumber -= 1;
                                      },
                                    ),
                                    width: 30,
                                    height: 20,
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: viewModel.isActive,
                    title: new Text('Hiện trên điểm bán hàng'),
                    onChanged: (bool value) {
                      viewModel.isCheckActive(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  StreamSubscription notifySubcrible;
  @override
  void didChangeDependencies() {
    notifySubcrible = viewModel.notifyPropertyChangedController.listen((name) {
      setState(() {});
    });

    viewModel.dialogMessageController.listen((message) {
      registerDialogToView(context, message,
          scaffState: _scaffoldKey.currentState);
    });

    super.didChangeDependencies();
  }

  String validateName(String value) {
    if (value.length == 0) {
      return "Tên danh mục không được bỏ trống";
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

  @override
  void initState() {
    viewModel.productCategory.id = widget.productCategoryId;
    viewModel.init();
    viewModel.productCategoryStream.listen((productCategory) {
      _nameTextEditingController.text = viewModel.productCategory.name;
    });

    super.initState();
  }

  @override
  void dispose() {
    viewModel.dispose();
    notifySubcrible.cancel();
    super.dispose();
  }
}
