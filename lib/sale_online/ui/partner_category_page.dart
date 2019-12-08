import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tpos_mobile/app_core/ui_base/ui_vm_base.dart';

import 'package:tpos_mobile/src/tpos_apis/models/partner_category.dart';
import 'package:tpos_mobile/sale_online/ui/partner_category_add_edit_page.dart';
import 'package:tpos_mobile/sale_online/viewmodels/partner_category_viewmodel.dart';
import 'package:tpos_mobile/widgets/appbar_search_widget.dart';

class PartnerCategoryPage extends StatefulWidget {
  final List<PartnerCategory> partnerCategories;
  final bool isSearchMode;
  final String keyWord;
  PartnerCategoryPage(
      {this.partnerCategories, this.isSearchMode = true, this.keyWord = ""});
  @override
  _PartnerCategoryPageState createState() =>
      _PartnerCategoryPageState(partnerCategories: partnerCategories);
}

class _PartnerCategoryPageState extends State<PartnerCategoryPage> {
  List<PartnerCategory> partnerCategories;
  _PartnerCategoryPageState({this.partnerCategories});
  PartnerCategoryViewModel viewModel = new PartnerCategoryViewModel();

  @override
  void initState() {
    viewModel.keyword = widget.keyWord;
    viewModel.selectedPartnerCategories = partnerCategories;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: _showBody(),
    );
  }

  Widget _showBody() {
    return UIViewModelBase(
      viewModel: viewModel,
      child: new StreamBuilder(
          stream: viewModel.partnerCategoriesStream,
          initialData: viewModel.partnerCategories,
          builder: (_, snapshot) {
            return new ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: viewModel.partnerCategories?.length ?? 0,
              separatorBuilder: (context, index) => Divider(
                height: 2,
                indent: 50,
              ),
              itemBuilder: (context, position) {
                return Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      child: Text(
                          "${viewModel.partnerCategories[position].name.substring(0, 1)}"),
                    ),
                    onTap: () async {
                      if (widget.isSearchMode) {
                        Navigator.pop(
                            context, viewModel.partnerCategories[position]);
                      } else {
                        await Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          PartnerCategoryAddEditPage
                              productCategoryAddEditPage =
                              new PartnerCategoryAddEditPage(
                            productCategoryId: snapshot.data[position].id,
                            onEdited: (cat) {
                              viewModel.partnerCategories[position] = cat;
                            },
                          );
                          return productCategoryAddEditPage;
                        }));
                      }
                    },
                    title: Text(
                      "${viewModel.partnerCategories[position].name}",
                      textAlign: TextAlign.start,
                    ),
                    trailing: viewModel.selectedPartnerCategories?.any((f) =>
                                f.id ==
                                viewModel.partnerCategories[position].id) ==
                            true
                        ? Icon(Icons.check)
                        : null,
                  ),
                  actionExtentRatio: 0.20,
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      onTap: () {
                        viewModel.delete(viewModel.partnerCategories[position]);
                      },
                      caption: "Xóa",
                      icon: Icons.delete,
                      color: Colors.red,
                    ),
                  ],
                );
              },
            );
          }),
    );
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0, top: 8, bottom: 8),
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
            PartnerCategory newPartnerCategory = await Navigator.push(context,
                MaterialPageRoute(builder: (context) {
              PartnerCategoryAddEditPage partnerCategoryAddEditPage =
                  new PartnerCategoryAddEditPage(
                closeWhenDone: true,
              );
              return partnerCategoryAddEditPage;
            }));

            if (newPartnerCategory != null) {
              viewModel.addNewPartnerCategoryCommand(new PartnerCategory(
                name: newPartnerCategory.name,
              ));
            }
          },
        )
      ],
    );
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }
}
