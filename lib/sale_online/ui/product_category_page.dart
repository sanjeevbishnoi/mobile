/*
 * *
 *  * Created by Nam, Công ty TNHH TM& DV Trực Tuyến Trường Minh Thịnh on 4/9/19 9:59 AM
 *  * Copyright (c) 2019 . All rights reserved.
 *  * Last modified 4/9/19 9:52 AM
 *
 */

import 'package:flutter/material.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/sale_online/ui/product_category_add_edit_page.dart';
import 'package:tpos_mobile/app_core/ui_base/ui_vm_base.dart';
import 'package:tpos_mobile/sale_online/viewmodels/product_category_viewmodel.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product_category.dart';
import 'package:tpos_mobile/widgets/custom_widget.dart';

class ProductCategoryPage extends StatefulWidget {
  final bool isSearchMode;
  final bool closeWhenDone;
  final String keyWord;
  ProductCategoryPage(
      {this.closeWhenDone = true, this.isSearchMode = true, this.keyWord = ""});
  @override
  _ProductCategoryPageState createState() => _ProductCategoryPageState();
}

class _ProductCategoryPageState extends State<ProductCategoryPage> {
  _ProductCategoryPageState();
  ProductCategoryViewModel viewModel = new ProductCategoryViewModel();

  @override
  void initState() {
    viewModel.keyword = widget.keyWord;

    super.initState();
    viewModel.dialogMessageController.listen((message) {
      registerDialogToView(context, message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: _showListProductCategories(),
    );
  }

  Widget _showListProductCategories() {
    return UIViewModelBase(
      viewModel: viewModel,
      child: new StreamBuilder(
        stream: viewModel.productCategoriesStream,
        initialData: viewModel.productCategories,
        builder: (_, snapshot) {
          return Scrollbar(
            child: new ListView.separated(
              padding: EdgeInsets.only(left: 12),
              separatorBuilder: (context, index) {
                return Divider(
                  height: 1,
                  indent: 50,
                );
              },
              shrinkWrap: true,
              itemCount: viewModel.productCategories?.length ?? 0,
              itemBuilder: (context, position) {
                return Dismissible(
                  direction: DismissDirection.endToStart,
                  key: Key("${snapshot.data[position].id}"),
                  child: new Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        child: Text(
                            "${viewModel.productCategories[position].name.substring(0, 1)}"),
                      ),
                      onTap: () async {
                        if (widget.isSearchMode) {
                          if (widget.closeWhenDone)
                            Navigator.pop(
                                context, viewModel.productCategories[position]);
                        } else {
                          await Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            ProductCategoryAddEditPage
                                productCategoryAddEditPage =
                                new ProductCategoryAddEditPage(
                              productCategoryId: snapshot.data[position].id,
                              onEdited: (cat) {
                                viewModel.productCategories[position] = cat;
                              },
                            );
                            return productCategoryAddEditPage;
                          }));
                        }
                      },
                      contentPadding: EdgeInsets.all(0),
                      title: Text(
                        "${viewModel.productCategories[position].name}",
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    var dialogResult = await showQuestion(
                        title: "Xác nhận xóa",
                        message:
                            "Bạn có muốn xóa nhóm sản phẩm ${snapshot.data[position].name}",
                        context: context);

                    if (dialogResult == OldDialogResult.Yes) {
                      var result = await viewModel
                          .deleteProductCategory(snapshot.data[position].id);
                      if (result) snapshot.data.removeAt(position);
                      return result;
                    } else {
                      return false;
                    }
                  },
                  background: Container(
                    color: Colors.green,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            "Xóa dòng này?",
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                          size: 40,
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: AppbarSearchWidget(
          onTextChange: (text) {
            viewModel.keywordChangedCommand(text);
          },
        ),
      ),
      actions: <Widget>[
        new IconButton(
          icon: new Icon(Icons.add),
          onPressed: () async {
            ProductCategory newProductCategory = await Navigator.push(context,
                MaterialPageRoute(builder: (context) {
              ProductCategoryAddEditPage productCategoryAddEditPage =
                  new ProductCategoryAddEditPage(
                closeWhenDone: true,
              );
              return productCategoryAddEditPage;
            }));

            if (newProductCategory != null) {
              viewModel.addNewProductCategoryCommand(new ProductCategory(
                name: newProductCategory.name,
              ));
            }
          },
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    viewModel.dispose();
  }
}
