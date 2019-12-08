import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tpos_mobile/helpers/messenger_helper.dart';
import 'package:tpos_mobile/app_core/ui_base/ui_vm_base.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner_category.dart';
import 'package:tpos_mobile/sale_online/ui/partner_category_page.dart';
import 'package:tpos_mobile/sale_online/viewmodels/partner_category_add_edit_viewmodel.dart';

class PartnerCategoryAddEditPage extends StatefulWidget {
  final int productCategoryId;
  final bool closeWhenDone;
  final Function(PartnerCategory) onEdited;
  PartnerCategoryAddEditPage(
      {this.closeWhenDone, this.productCategoryId, this.onEdited});

  @override
  _PartnerCategoryAddEditPageState createState() =>
      _PartnerCategoryAddEditPageState();
}

class _PartnerCategoryAddEditPageState
    extends State<PartnerCategoryAddEditPage> {
  _PartnerCategoryAddEditPageState();

  PartnerCategoryAddEditViewModel viewModel =
      new PartnerCategoryAddEditViewModel();
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
              ? Text("Thêm nhóm khách hàng")
              : Text("Sửa nhóm khách hàng"),
          actions: <Widget>[
            FlatButton.icon(
              label: Text("Lưu"),
              textColor: Colors.white,
              icon: Icon(Icons.check),
              onPressed: () async {
                viewModel.partnerCategory.name =
                    _nameTextEditingController.text.trim();
                _sendToServer();
                if (_nameTextEditingController.text != "") {
                  await viewModel.save();
                  if (widget.closeWhenDone == true) {
                    Navigator.pop(context, viewModel.partnerCategory);
                  }
                }
                if (widget.onEdited != null)
                  widget.onEdited(viewModel.partnerCategory);
              },
            ),
          ],
        ),
        body: Container(color: Colors.grey.shade200, child: _showBody()),
      ),
    );
  }

  Widget _showBody() {
    return StreamBuilder<PartnerCategory>(
      stream: viewModel.partnerCategoryStream,
      initialData: viewModel.partnerCategory,
      builder: (context, snapshot) {
        return Form(
          key: _key,
          autovalidate: _validate,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                new TextFormField(
                  controller: _nameTextEditingController,
                  autofocus: false,
                  onEditingComplete: () {},
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(5),
                    icon: Icon(Icons.supervised_user_circle),
                    labelText: 'Tên nhóm',
                  ),
                  validator: validateName,
                ),
                Divider(),
                // Nhóm sản phẩm
                new ListTile(
                  title: Text("Nhóm cha"),
                  subtitle: Text(
                      "${viewModel.partnerCategory?.parent?.name ?? "Chọn nhóm khách hàng cha"}"),
                  trailing: Icon(Icons.keyboard_arrow_right),
                  onTap: () async {
                    PartnerCategory result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return PartnerCategoryPage();
                        },
                      ),
                    );
                    if (result != null) {
                      viewModel.selectPartnerCategoryCommand(result);
                    }
                  },
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
      return "Tên nhóm không được bỏ trống";
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
    viewModel.partnerCategory.id = widget.productCategoryId;
    viewModel.init();
    viewModel.partnerCategoryStream.listen((productCategory) {
      _nameTextEditingController.text = viewModel.partnerCategory.name;
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
