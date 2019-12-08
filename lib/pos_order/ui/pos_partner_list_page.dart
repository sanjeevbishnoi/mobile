import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';
import 'package:tpos_mobile/app_core/ui_base/view_base.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/pos_order/models/partners.dart';
import 'package:tpos_mobile/pos_order/ui/pos_partner_add_edit_page.dart';
import 'package:tpos_mobile/pos_order/ui/pos_partner_info_page.dart';
import 'package:tpos_mobile/pos_order/viewmodels/pos_partner_list_viewmodel.dart';
import 'package:tpos_mobile/widgets/appbar_search_widget.dart';

class PosPartnerListPage extends StatefulWidget {
  @override
  _PosPartnerListPageState createState() => _PosPartnerListPageState();
}

class _PosPartnerListPageState extends State<PosPartnerListPage> {
  var _vm = locator<PosPartnerListViewModel>();
  bool _isSearchEnable = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _vm.getPartners();
  }

  @override
  Widget build(BuildContext context) {
    return ViewBase<PosPartnerListViewModel>(
        model: _vm,
        builder: (context, modle, _) {
          return Scaffold(
            backgroundColor: Colors.grey[300],
            appBar: buildAppBar(context),
            body: ListView.builder(
                padding: EdgeInsets.only(top: 2),
                itemCount: _vm.partners?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  return _buildItemPartner(_vm.partners[index]);
                }),
          );
        });
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0, top: 7, bottom: 7),
        child: _isSearchEnable
            ? AppbarSearchWidget(
                autoFocus: true,
                keyword: _vm.keyword,
                onTextChange: (text) async {
                  _vm.setKeyword(text);
                },
              )
            : Text("Danh sách khách hàng"),
      ),
      actions: <Widget>[
        new IconButton(
          icon: new Icon(Icons.search),
          onPressed: () async {
            setState(() {
              _isSearchEnable = !_isSearchEnable;
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => new PosPartnerAddEditPage(null)),
            ).then((value) {
              _vm.getPartners();
            });
          },
        )
      ],
    );
  }

  Widget _buildItemPartner(Partners item) {
    Widget sizedBox = SizedBox(
      height: 8,
    );
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => new PosPartnerInfoPage(item)));
      },
      child: Container(
        margin: EdgeInsets.only(top: 2, bottom: 2, left: 5, right: 5),
        padding: EdgeInsets.only(top: 5, bottom: 5),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white70,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                child: CircleAvatar(
                  backgroundColor: RandomColor().randomColor(),
                  child: Text(
                    item.name?.substring(0, 1) ?? "",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                margin: EdgeInsets.all(0),
                width: 60,
                height: 60,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context, item);
                          },
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.check,
                                color: Colors.green,
                                size: 20,
                              ),
                              Text("Chọn")
                            ],
                          ),
                        )
                      ],
                    ),
                    sizedBox,
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.phone_android,
                          size: 15,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Expanded(
                          child: Text(
                            item.phone == null || item.phone == ""
                                ? "<Chưa có sđt>"
                                : item.phone,
                          ),
                        ),
                      ],
                    ),
                    sizedBox,
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.email,
                          size: 15,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Expanded(
                          child: Text(
                            item.email == null || item.email == ""
                                ? "<Chưa có email>"
                                : item.email,
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.grey.shade300,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            item.street == null || item.street == ""
                                ? "<Chưa có đ/c>"
                                : item.street,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
