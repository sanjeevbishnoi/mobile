import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/sale_online/viewmodels/viewmodel.dart';
import 'package:tpos_mobile/src/tpos_apis/models/CheckAddress.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';
import 'package:tpos_mobile/widgets/ModalWaitingWidget.dart';
import 'package:tpos_mobile/widgets/info_row.dart';

class CheckAddressPage extends StatefulWidget {
  final CheckAddress selectedAddress;
  final String keyword;
  CheckAddressPage({this.selectedAddress, this.keyword});

  @override
  _CheckAddressPageState createState() => _CheckAddressPageState();
}

class _CheckAddressPageState extends State<CheckAddressPage> {
  var _vm = CheckAddressViewModel();
  var _keywordController = new TextEditingController();
  @override
  void initState() {
    _keywordController.text = widget.keyword;
    _vm.init(selectedCheckaddress: widget.selectedAddress);
    if (widget.keyword != null) {
      _vm.checkAddressCommand(widget.keyword);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<CheckAddressViewModel>(
      model: _vm,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Tìm địa chỉ"),
          actions: <Widget>[
            FlatButton(
              child: Text("LƯU"),
              onPressed: () {
                Navigator.pop(context, _vm._selectedCheckAddress);
              },
              textColor: Colors.white,
            )
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return ModalWaitingWidget(
      isBusyStream: _vm.isBusyController,
      initBusy: false,
      child: Container(
        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
        color: Colors.grey.shade300,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Khung tìm kiếm
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.all(0),
                child: TextField(
                  maxLines: null,
                  controller: _keywordController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.all(6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(width: 0),
                    ),
                    hintText: "Từ khóa: vd: 54/35 dmc,tsn,tp,hcm",
                    suffix: SizedBox(
                      height: 30,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          FlatButton.icon(
                            icon: Icon(Icons.search),
                            textColor: Colors.blue,
                            padding: EdgeInsets.all(0),
                            label: Text("Tìm"),
                            onPressed: () {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              _vm.checkAddressCommand(
                                  _keywordController.text.trim());
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Kết quả  tìm kiếm
              SizedBox(
                height: 10,
              ),

              Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                  ),
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  child: RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: "Các kết quả sau phù hợp với từ khóa: ",
                        style: TextStyle(color: Colors.black87)),
                    TextSpan(
                      text: "${_keywordController.text.trim()}",
                      style: TextStyle(color: Colors.green),
                    )
                  ]))),
              Divider(
                height: 1,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: ScopedModelDescendant<CheckAddressViewModel>(
                  builder: (ctx, child, model) {
                    return ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        separatorBuilder: (ctx, index) => Divider(
                              height: 1,
                            ),
                        itemCount: _vm.checkAddressResults?.length ?? 0,
                        shrinkWrap: true,
                        itemBuilder: (ctx, index) {
                          return _buildResultItem(
                              _vm.checkAddressResults[index]);
                        });
                  },
                ),
              ),

              if (_vm.selectedCheckAddress != null) ...[
                SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      InfoRow(
                        titleString: "Tỉnh thành:",
                        contentString:
                            _vm.selectedCheckAddress.cityName ?? "N/A",
                      ),
                      InfoRow(
                        titleString: "Quận huyện:",
                        contentString:
                            _vm.selectedCheckAddress.districtName ?? "N/A",
                      ),
                      InfoRow(
                        titleString: "Phường/xã:",
                        contentString:
                            _vm.selectedCheckAddress.wardName ?? "N/A",
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      RaisedButton.icon(
                        icon: Icon(Icons.close),
                        color: Colors.white,
                        shape: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                        textColor: Colors.green,
                        label: Text("ĐÓNG"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      RaisedButton.icon(
                        shape: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        icon: Icon(Icons.save),
                        textColor: Colors.white,
                        label: Text("LƯU LỰA CHỌN"),
                        onPressed: () {
                          Navigator.pop(context, _vm.selectedCheckAddress);
                        },
                      )
                    ],
                  ),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultItem(CheckAddress item) {
    return CheckboxListTile(
      value: _vm.selectedCheckAddress == item,
      title: Text(
        item.address ?? "",
        style: TextStyle(color: Colors.black54),
      ),
      selected: _vm.selectedCheckAddress == item,
      onChanged: (value) {
        setState(() {
          _vm.selectedCheckAddress = item;
        });

        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
  }
}

class CheckAddressViewModel extends ViewModel {
  ITposApiService _tposApi;

  CheckAddressViewModel({ITposApiService tposApi}) {
    _tposApi = tposApi ?? locator<ITposApiService>();
  }

  void init({CheckAddress selectedCheckaddress}) {
    this._selectedCheckAddress = selectedCheckaddress;
  }

  List<CheckAddress> _checkAddressResults;
  CheckAddress _selectedCheckAddress;

  List<CheckAddress> get checkAddressResults => _checkAddressResults;
  CheckAddress get selectedCheckAddress => _selectedCheckAddress;

  set selectedCheckAddress(CheckAddress value) {
    _selectedCheckAddress = value;
    notifyListeners();
  }

  Future<void> initcommand() async {}
  Future<void> checkAddressCommand(String keyword) async {
    onStateAdd(true);

    try {
      _checkAddressResults = await _tposApi.checkAddress(keyword);
    } catch (e, s) {
      logger.error("", e, s);
    }
    onStateAdd(false);
    notifyListeners();
  }
}
