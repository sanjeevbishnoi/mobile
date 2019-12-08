import 'package:flutter/material.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';

class SaleOnlineSupportPrintContentListPage extends StatefulWidget {
  final List<SupportPrintSaleOnlineRow> selectedList;
  SaleOnlineSupportPrintContentListPage({this.selectedList});
  @override
  _SaleOnlineSupportPrintContentListPageState createState() =>
      _SaleOnlineSupportPrintContentListPageState();
}

class _SaleOnlineSupportPrintContentListPageState
    extends State<SaleOnlineSupportPrintContentListPage> {
  var _setting = locator<ISettingService>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nội dung có thể in"),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    var contents = _setting.supportSaleOnlinePrintRow
        .where((f) =>
            (widget.selectedList != null &&
                !widget.selectedList.any((g) => g.name == f.name)) ||
            (widget.selectedList == null))
        .toList();
    return RefreshIndicator(
      onRefresh: () async {
        return true;
      },
      child: _buildList(contents),
    );
  }

  Widget _buildList(List<SupportPrintSaleOnlineRow> items) {
    return ListView.separated(
        itemBuilder: (context, index) => _buildListItem(items[index]),
        separatorBuilder: (context, index) => Divider(
              height: 2,
            ),
        itemCount: items?.length ?? 0);
  }

  Widget _buildListItem(SupportPrintSaleOnlineRow item) {
    return ListTile(
      leading: CircleAvatar(
        child: Text("${item.description.substring(0, 1)}"),
      ),
      title: Text(item.description),
      onTap: () => Navigator.pop(context, item),
    );
  }
}
