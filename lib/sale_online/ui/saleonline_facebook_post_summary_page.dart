import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tpos_mobile/helpers/ui_help.dart';
import 'package:tpos_mobile/app_core/ui_base/ui_vm_base.dart';
import 'package:tpos_mobile/sale_online/viewmodels/saleonline_facebook_post_summary_viewmodel.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/src/facebook_apis/src/models/get_facebook_partner_result.dart';
import 'package:tpos_mobile/src/tpos_apis/models/crm_team.dart';
import 'package:tpos_mobile/src/tpos_apis/models/sale_online_facebook_post_summary_user.dart';

class SaleOnlineFacebookPostSummaryPage extends StatefulWidget {
  final String postId;
  final CRMTeam  crmTeam;
  SaleOnlineFacebookPostSummaryPage({
    @required this.postId,
    @required this.crmTeam,
  });
  @override
  _SaleOnlineFacebookPostSummaryPageState createState() =>
      _SaleOnlineFacebookPostSummaryPageState();
}

class _SaleOnlineFacebookPostSummaryPageState
    extends State<SaleOnlineFacebookPostSummaryPage> {
  var _vm = SaleOnlineFacebookPostSummaryViewModel();
  int currentTabIndex;
  bool headerVisible = true;
  double headerSize = 400;

  @override
  void initState() {
    _vm.init(
      postId: widget.postId,
      crmTeam: widget.crmTeam,
    );
    _vm.initCommand();
    _vm.dialogMessageController.listen(
      (message) {
        registerDialogToView(context, message);
      },
    );
    super.initState();
  }

  GlobalKey _headerPhoneKey = GlobalKey();

  void _getHeaderPhoneSizes() {
    RenderBox renderBoxRed = _headerPhoneKey.currentContext?.findRenderObject();
    var sizeRed = renderBoxRed?.size;
    print(sizeRed?.height);
    if (sizeRed != null && sizeRed.height != headerSize) {
      setState(
        () {
          headerSize = sizeRed.height;
        },
      );
    }
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<SaleOnlineFacebookPostSummaryViewModel>(
      model: _vm,
      child: Scaffold(
        body: UIViewModelBase(
          backgroundColor: Colors.indigo.shade200,
          viewModel: _vm,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildPhoneDetailList() {
    return ListView.separated(
        itemBuilder: (context, index) {
          return DetailItem(_vm.summary?.users[index], index,
              _vm.getPartner(_vm.summary?.users[index].id.toString()));
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemCount: _vm.summary?.users?.length ?? 0);
  }

  Widget _buildPhoneNewCustomerList() {
    return ListView.separated(
        itemBuilder: (context, index) {
          return NewCustomerItem(
              index, _vm.summary?.availableInsertPartners[index]);
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemCount: _vm.summary?.availableInsertPartners?.length ?? 0);
  }

  ScrollController _phoneScrollController = new ScrollController();
  Widget _buildPhoneLayout() {
    final headerTextStyle = TextStyle(color: Colors.white, fontSize: 18);

    return ScopedModelDescendant<SaleOnlineFacebookPostSummaryViewModel>(
      builder: (context, child, model) {
        return DefaultTabController(
          length: 2,
          child: NestedScrollView(
            controller: _phoneScrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Colors.indigo,
                  pinned: true,
                  expandedHeight: 200,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      "${_vm.summary?.post?.source ?? "Bài đăng"}",
                      style: headerTextStyle.copyWith(
                          fontSize: 14, color: Colors.indigo.shade200),
                    ),
                    background: Container(
                      key: _headerPhoneKey,
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(top: 50),
                              padding: EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
//                                  Text(
//                                    "${_vm.summary?.post?.story}",
//                                    style: headerTextStyle.copyWith(
//                                        color: Colors.red),
//                                  ),
                                  Text(
                                    "${_vm.summary?.post?.message}",
                                    style: headerTextStyle,
                                  ),
                                  if (_vm.summary?.post?.createdTime != null)
                                    Text(
                                      "Ngày tạo: ${DateFormat("dd/MM/yyyy  HH:mm").format(_vm.summary?.post?.createdTime?.toLocal())}",
                                      style: headerTextStyle.copyWith(
                                          color: Colors.lightBlueAccent),
                                    ),
                                ],
                              ),
                            ),
                          ]),
                    ),
                  ),
                  actions: <Widget>[],
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Container(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: BlockItem(
                                  header: "Bình luận",
                                  backgroundColor: Colors.indigo.shade100,
                                  value: "${_vm.summary?.countComment ?? "0"}",
                                ),
                              ),
                              Expanded(
                                child: BlockItem(
                                  header: "Người bình luận",
                                  backgroundColor: Colors.indigo.shade100,
                                  value:
                                      "${_vm.summary?.countUserComment ?? 0}",
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: BlockItem(
                                  header: "Chia sẻ",
                                  backgroundColor: Colors.indigo.shade100,
                                  value: "${_vm.summary?.countShare}",
                                ),
                              ),
                              Expanded(
                                child: BlockItem(
                                  header: "Số người chia sẻ",
                                  backgroundColor: Colors.indigo.shade100,
                                  value: "${_vm.summary?.countUserShare ?? 0}",
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: BlockItem(
                                  header: "Đơn hàng",
                                  backgroundColor: Colors.indigo.shade100,
                                  value: "${_vm.summary?.countOrder ?? 0}",
                                ),
                              ),
                              Expanded(
                                child: BlockItem(
                                  header: "Khách hàng mới",
                                  backgroundColor: Colors.indigo.shade100,
                                  value:
                                      "${_vm.summary?.availableInsertPartners?.length ?? 0}",
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      color: Colors.indigo,
                      padding: EdgeInsets.only(bottom: 5),
                    ),
                  ]),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      indicatorColor: Colors.indigo,
                      labelColor: Colors.indigo,
                      tabs: [
                        Tab(
                          text: "Chi tiết (${_vm.summary?.users?.length ?? 0})",
                        ),
                        Tab(
                          text:
                              "Khách hàng mới (${_vm.summary?.availableInsertPartners?.length ?? 0})",
                        )
                      ],
                      onTap: (index) {
                        setState(() {
                          currentTabIndex = index;
                        });
                      },
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                _buildPhoneDetailList(),
                _buildPhoneNewCustomerList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabletHeader() {
    final headerTextStyle = TextStyle(color: Colors.white, fontSize: 16);
    return ScopedModelDescendant<SaleOnlineFacebookPostSummaryViewModel>(
      builder: (context, child, vm) {
        return Container(
          height: 100,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network("${_vm.summary?.post?.picture ?? ""}"),
              ),
              Container(
                width: 350,
                child: Column(
                  children: <Widget>[
                    Text(
                      "${_vm.summary?.post?.story ?? ""}",
                      style: headerTextStyle.copyWith(color: Colors.red),
                    ),
                    Text(
                      "${_vm.summary?.post?.message ?? ""}",
                      style: headerTextStyle,
                    ),
                    if (_vm.summary?.post?.createdTime != null)
                      Text(
                        "Ngày tạo: ${DateFormat("dd/MM/yyyy  HH:mm").format(_vm.summary?.post?.createdTime?.toLocal())}",
                        style: headerTextStyle,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: BlockItem(
                  header: "Bình luận",
                  value: "${_vm.summary?.countComment}",
                ),
              ),
              Expanded(
                child: BlockItem(
                  header: "Người bình luận",
                  value: "${_vm.summary?.countUserComment ?? 0}",
                ),
              ),
              Expanded(
                child: BlockItem(
                  header: "Chia sẻ",
                  value: "${_vm.summary?.countShare ?? 0}",
                ),
              ),
              Expanded(
                child: BlockItem(
                  header: "Số người chia sẻ",
                  value: "${_vm.summary?.countUserShare ?? 0}",
                ),
              ),
              Expanded(
                child: BlockItem(
                  header: "Đơn hàng",
                  value: "${_vm.summary?.countOrder ?? 0}",
                ),
              ),
              Expanded(
                child: BlockItem(
                  header: "Khách hàng mới",
                  value: "${_vm.summary?.availableInsertPartners?.length ?? 0}",
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static const double sttWidth = 50;
  static const double avataWidth = 50;
  static const double nameWidth = 200;
  static const double commentWidth = 50;
  static const double shareWidth = 50;
  static const double invoiceWidth = 50;
  Widget _buildTabletDetailList() {
    return SingleChildScrollView(
      child: DataTable(horizontalMargin: 30, columnSpacing: 0, columns: [
        DataColumn(
          numeric: false,
          label: Container(
            child: SizedBox(
              child: Text("STT"),
              width: sttWidth,
            ),
          ),
        ),
        DataColumn(
          label: Text("Avata"),
        ),
        DataColumn(
          label: Container(width: nameWidth, child: Text("Name")),
        ),
        DataColumn(
          label: Text("Comment"),
        ),
        DataColumn(
          label: Text("Share"),
        ),
        DataColumn(
          label: Text("Hóa đơn"),
        ),
      ], rows: [
        for (int i = 0; i < (_vm.summary?.users?.length ?? 0); i++)
          DataRow(cells: [
            DataCell(Container(width: sttWidth, child: Text("${i + 1}")),
                placeholder: false),
            DataCell(Image.network(_vm.summary.users[i].picture)),
            DataCell(
              Builder(
                builder: (context) {
                  var partner = _vm.partners[_vm.summary.users[i].id];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "${_vm.summary?.users[i].name}",
                        style: TextStyle(
                            color: Colors.indigo, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: <Widget>[
                          if (partner?.hasPhone ?? false)
                            InkWell(
                              child: Padding(
                                padding: EdgeInsets.only(left: 8, right: 8),
                                child: Icon(Icons.phone),
                              ),
                              onTap: () {
                                // laucher call
                                urlLauch("tel:${partner.phone}");
                              },
                            ),
                          if (partner?.hasAddress ?? false)
                            InkWell(
                              child: Padding(
                                padding: EdgeInsets.only(left: 8, right: 8),
                                child: Icon(Icons.perm_contact_calendar),
                              ),
                            ),
                          Text("${partner?.code ?? ""}")
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            DataCell(Text(
              "${_vm.summary?.users[i].countComment}",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
            DataCell(Text(
              "${_vm.summary?.users[i].countShare}",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
            DataCell(_vm.summary?.users[i].hasOrder
                ? Icon(Icons.check)
                : SizedBox()),
          ])
      ]),
    );
  }

  /// Tablet horizon layout
  Widget _buildTabletLayout() {
    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.indigo,
              pinned: true,
              expandedHeight: 250,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "${_vm.summary?.post?.story ?? "Bài đăng"}",
                  style: TextStyle(fontSize: 15, color: Colors.indigo.shade100),
                ),
                collapseMode: CollapseMode.pin,
                background: Padding(
                  padding: const EdgeInsets.only(top: 100, bottom: 50),
                  child: _buildTabletHeader(),
                ),
              ),
              actions: <Widget>[],
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  indicatorColor: Colors.indigo,
                  labelColor: Colors.indigo,
                  tabs: [
                    Tab(
                      text: "Chi tiết (${_vm.summary?.users?.length ?? 0})",
                    ),
                    Tab(
                      text:
                          "Khách hàng mới (${_vm.summary?.availableInsertPartners?.length ?? 0})",
                    )
                  ],
                  onTap: (index) {
                    setState(() {
                      currentTabIndex = index;
                    });
                  },
                ),
              ),
            ),
          ];
        },
        body: ScopedModelDescendant<SaleOnlineFacebookPostSummaryViewModel>(
          builder: (context, child, vm) => TabBarView(
            children: [
              _buildTabletDetailList(),
              _buildPhoneNewCustomerList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (context, contraints) {
        if (contraints.maxWidth < 1000) {
          return _buildPhoneLayout();
        } else {
          return _buildTabletLayout();
        }
      },
    );
  }
}

class HeaderItem extends StatelessWidget {
  final headerTextStyle = TextStyle(color: Colors.white, fontSize: 15);
  final SaleOnlineFacebookPostSummaryViewModel vm;
  HeaderItem({this.vm});
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: <Widget>[
//        Container(
//          color: Colors.indigo.shade400,
//          child: Image.network(
//            vm.summary?.post?.picture ?? "",
//            fit: BoxFit.fitHeight,
//          ),
//        ),
        Container(
          margin: EdgeInsets.only(top: 50),
          padding: EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
//              Text(
//                "${vm.summary?.post?.story}",
//                style: headerTextStyle.copyWith(color: Colors.red),
//              ),
              Text(
                "${vm.summary?.post?.message}",
                style: headerTextStyle,
              ),
              if (vm.summary?.post?.createdTime != null)
                Text(
                  "Ngày tạo: ${DateFormat("dd/MM/yyyy  HH:mm").format(vm.summary?.post?.createdTime?.toLocal())}",
                  style: headerTextStyle,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class BlockItem extends StatelessWidget {
  final String header;
  final String value;
  final Color backgroundColor;
  BlockItem({this.header, this.value, this.backgroundColor = Colors.white});

  final BoxDecoration decorate = new BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.grey.shade400),
  );
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(5),
      decoration: decorate.copyWith(color: backgroundColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(header),
          Text(
            value,
            style: TextStyle(color: Colors.blue, fontSize: 25),
          ),
        ],
      ),
    );
  }
}

class DetailItem extends StatelessWidget {
  final Users user;
  final GetFacebookPartnerResult partner;
  final int index;
  DetailItem(this.user, this.index, this.partner);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(
        left: 5,
        right: 5,
      ),
      leading: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("# ${index + 1}"),
        ),
        Image.network("${user.picture ?? ""}"),
      ]),
      title: Wrap(
        children: <Widget>[
          Text(
            "${user.name}",
            style: TextStyle(color: Colors.blue),
          ),
          if (partner?.hasPhone ?? false)
            InkWell(
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Icon(Icons.phone),
              ),
              onTap: () {
                urlLauch("tel:${partner.phone}");
              },
            ),
          if (partner?.hasAddress ?? false)
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Icon(Icons.perm_contact_calendar),
            ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              "${partner?.code ?? ""}",
              style: TextStyle(color: Colors.indigo.shade400),
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: <Widget>[
          Icon(
            Icons.share,
            color: Colors.grey,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("${user.countShare}"),
          ),
          Icon(
            Icons.comment,
            color: Colors.grey,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("${user.countComment}"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("${user.hasOrder ? "Đã tạo đơn hàng" : ""}"),
          ),
        ],
      ),
    );
  }
}

class NewCustomerItem extends StatelessWidget {
  final AvailableInsertPartners partner;
  final int index;
  NewCustomerItem(this.index, this.partner);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("# ${index + 1}"),
        ),
        Image.network("${partner.facebookAvatar ?? ""}"),
      ]),
      title: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              "${partner.name} (${partner.facebookUserId ?? "N/A"})",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      subtitle: Row(children: <Widget>[
        Text("${partner.phone}"),
        if (partner.phoneExisted ?? false)
          Icon(
            Icons.check,
            color: Colors.red,
          )
      ]),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      color: Colors.indigo.shade50,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class MyPopupMenuItemContent extends StatelessWidget {
  final Widget icon;
  final String title;
  final Function onTap;
  MyPopupMenuItemContent({this.icon, this.title, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        icon,
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 12),
            child: Text(
              title,
              style: TextStyle(color: Colors.black),
            ),
          ),
        )
      ],
    );
  }
}
