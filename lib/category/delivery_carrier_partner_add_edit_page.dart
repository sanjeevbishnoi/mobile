import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:test/test.dart';
import 'package:tpos_mobile/app_core/my_widgets/number_input_field.dart';
import 'package:tpos_mobile/app_core/ui_base/ui_base.dart';
import 'package:tpos_mobile/category/viewmodel/delivery_carrier_partner_add_edit_viewmodel.dart';
import 'package:tpos_mobile/helpers/helpers.dart';
import 'package:tpos_mobile/helpers/tmt.dart';
import 'package:tpos_mobile/sale_online/models/tpos_desktop.dart';
import 'package:tpos_mobile/src/tpos_apis/tpos_api.dart';

class DeliveryCarrierPartnerAddEditPage extends StatefulWidget {
  final String deliveryType;
  final String deliveryName;
  final DeliveryCarrier editCarrier;
  DeliveryCarrierPartnerAddEditPage(
      {this.deliveryType, this.deliveryName, this.editCarrier});
  @override
  _DeliveryCarrierPartnerAddEditPageState createState() =>
      _DeliveryCarrierPartnerAddEditPageState();
}

class _DeliveryCarrierPartnerAddEditPageState
    extends State<DeliveryCarrierPartnerAddEditPage> {
  var _vm = DeliveryCarrierPartnerAddEditViewModel();
  var _nameController = TextEditingController();
  var _senderNameController = TextEditingController();
  var _vnPostClientIdController = TextEditingController();
  var _vnPostPostIdController = TextEditingController();

  var _inputStyle =
      TextStyle(fontWeight: FontWeight.bold, color: Colors.black54);

  var _headerStyle = TextStyle(color: Colors.blue);
  @override
  void initState() {
    _vm.init(
        carrier: widget.editCarrier,
        addCarrierType: widget.deliveryType,
        addCarrierName: widget.deliveryName);
    _vm.initData();

    // fill editing controller
    _vm.addListener(() {
      _nameController.text = _vm.carrier.name;
      _senderNameController.text = _vm.carrier?.senderName;
      _vnPostClientIdController.text = _vm.carrier?.vNPostClientId?.toString();
      _vnPostPostIdController.text = _vm.carrier?.extras?.posId?.toString();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return UIViewModelBase<DeliveryCarrierPartnerAddEditViewModel>(
      viewModel: _vm,
      child: Scaffold(
        appBar: AppBar(
          title: widget.deliveryType != null
              ? Text("Kết nối tới ${widget.deliveryType}")
              : Text("Sửa đối tác ${widget.editCarrier?.name}"),
          actions: <Widget>[
            FlatButton.icon(
                textColor: Colors.white,
                onPressed: () {
                  _vm.save().then((value) {
                    if (value) Navigator.pop(context);
                  });
                },
                icon: Icon(Icons.save),
                label: Text("LƯU"))
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: ScopedModelDescendant<DeliveryCarrierPartnerAddEditViewModel>(
        builder: (_, __, ___) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              color: Colors.grey.shade300,
              padding: EdgeInsets.all(8),
              child: Text(
                "Thông tin",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            //Chung
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: InputDecoration(
                    labelText: "Đặt tên đối tác:", labelStyle: _headerStyle),
                controller: TextEditingController(text: _vm.carrier?.name),
                onChanged: (text) => _vm.carrier?.name = text,
                style: _inputStyle,
              ),
            ),
            CheckboxListTile(
              title: Text("Cho phép sử dụng?"),
              value: _vm.carrier?.active ?? false,
              onChanged: (value) => _vm.isActive = value,
            ),
            CheckboxListTile(
              title: Text("In theo mẫu?"),
              subtitle: Text(
                  'In theo mẫu riêng của đối tác (Chỉ áp dụng cho phiên bản Web)'),
              value: _vm.carrier?.isPrintCustom ?? false,
              onChanged: (value) => _vm.isPrintCustom = value,
            ),

            Container(
              color: Colors.grey.shade300,
              padding: EdgeInsets.all(8),
              child: Text(
                "Thông tin kết nối",
                style: const TextStyle(color: Colors.grey),
              ),
            ),

            // Cấu hình kết nối
            _buildConnect(),
            // Cấu hình nâng cao
            Container(
              color: Colors.grey.shade300,
              padding: EdgeInsets.all(8),
              child: Text(
                "Giá trị mặc định",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            _builDefaultValuePanel(),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                child: Text("LƯU"),
                onPressed: () {
                  _vm.save().then((value) {
                    if (value) Navigator.pop(context);
                  });
                },
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnect() {
    switch (_vm.carrierType) {
      case "VNPost":
        return _buildVNPOSTConnectInputPanel();
        break;
      case "ViettelPost":
        return _buildVIETTELPOSTConnectInputPanel();
        break;
      case "GHN":
        return _buildGHNConnectInputPanel();
        break;
      case "GHTK":
        return _buildGHTKConnectInputPanel();
        break;
      case "TinToc":
        return _buildTINTOCConnectInputPanel();
        break;
      case "JNT":
        return _buildJNTConnectInputPanel();
        break;
      case "SuperShip":
        return _buildSUPERSHIPConnectInputPanel();
        break;
      case "fixed":
        return _buildFIXEDConnectInputPanel();
        break;
      default:
        return SizedBox();
        break;
    }
  }

  /// Nhập tên người gửi
  Widget _buildSenderNameInput() {
    return TextField(
      controller: _senderNameController,
      decoration: InputDecoration(
          labelText: "Tên người gửi:", labelStyle: _headerStyle),
      onChanged: (text) => _vm.carrier?.senderName = text,
      style: _inputStyle,
    );
  }

  Widget _buildVNPOSTConnectInputPanel() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSenderNameInput(),
            TextField(
              controller: _vnPostPostIdController,
              decoration: InputDecoration(
                  labelText: "Mã bưu cục:", labelStyle: _headerStyle),
              onChanged: (text) => _vm.postId = text,
            ),
            TextField(
              controller: _vnPostClientIdController,
              decoration: InputDecoration(
                  labelText: "Mã khách hàng:", labelStyle: _headerStyle),
              onChanged: (text) =>
                  _vm.carrier?.vNPostClientId = int.parse(text),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "Dịch vụ",
                style: _headerStyle,
              ),
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: _vm.carrier?.vNPostServiceId,
              hint: Text("Chọn dịch vụ"),
              onChanged: (value) {
                setState(() {
                  _vm.carrier.vNPostServiceId = value;
                });
              },
              items: [
                DropdownMenuItem<String>(
                  child: Text("- Không chọn -"),
                  value: null,
                ),
                DropdownMenuItem<String>(
                  child: Text("Nhanh (EMS)"),
                  value: "1",
                ),
                DropdownMenuItem<String>(
                  child: Text("Thường (Bưu kiện)"),
                  value: "2",
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "Hình thức lấy hàng",
                style: _headerStyle,
              ),
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: _vm.carrier?.vNPostPickupType,
              hint: Text("Chọn hình thức lấy hàng"),
              onChanged: (value) {
                setState(() {
                  _vm.carrier.vNPostPickupType = value;
                });
              },
              items: [
                DropdownMenuItem<String>(
                  child: Text("- Không chọn -"),
                  value: null,
                ),
                DropdownMenuItem<String>(
                  child: Text("Dropoff (Mang hàng đến bưu cục)"),
                  value: "1",
                ),
                DropdownMenuItem<String>(
                  child: Text("Pickup (Thu gom hàng)"),
                  value: "2",
                ),
              ],
            ),
            CheckboxListTile(
              title: Text("Đã ký hợp đồng?"),
              value: _vm.carrier?.vNPostIsContracted ?? false,
              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVIETTELPOSTConnectInputPanel() {
    var inputStyle =
        TextStyle(color: Colors.black87, fontWeight: FontWeight.bold);
    return Container(
      padding: EdgeInsets.all(16),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSenderNameInput(),

            TextField(
              decoration: InputDecoration(
                  labelText: "Tải khoản:", labelStyle: _headerStyle),
              style: inputStyle,
              controller:
                  TextEditingController(text: _vm.carrier?.viettelPostUserName),
              onChanged: (text) => _vm.carrier.viettelPostUserName = text,
            ),
            TextField(
              decoration: InputDecoration(
                  labelText: "Mật khẩu:", labelStyle: _headerStyle),
              style: inputStyle,
              controller:
                  TextEditingController(text: _vm.carrier?.viettelPostPassword),
              onChanged: (text) => _vm.carrier.viettelPostPassword = text,
            ),
            // Dịch vụ
            Padding(
              padding: const EdgeInsets.only(left: 0, top: 8),
              child: Text("Dịch vụ:", style: _headerStyle),
            ),
            DropdownButton<String>(
              style: inputStyle,
              isExpanded: true,
              value: _vm.carrier?.viettelPostServiceId,
              hint: Text("Chọn dịch vụ"),
              onChanged: (value) {
                setState(() {
                  _vm.carrier.viettelPostServiceId = value;
                });
              },
              items: [
                DropdownMenuItem<String>(
                  child: Text("- Không chọn -"),
                  value: "",
                ),
                DropdownMenuItem<String>(
                  child: Text("Giao hàng thu tiền (SCOD)"),
                  value: "SCOD",
                ),
                DropdownMenuItem<String>(
                  child: Text("Chuyển phát nhanh (VCN)"),
                  value: "VCN",
                ),
                DropdownMenuItem<String>(
                  child: Text("Phát trong ngày nội tỉnh (PTN)"),
                  value: "PTN",
                ),
                DropdownMenuItem<String>(
                  child: Text("Phát hỏa tốc nội tỉnh (PHT)"),
                  value: "PHT",
                ),
                DropdownMenuItem<String>(
                  child: Text("Phát hôm sau nội tỉnh (PHS)"),
                  value: "PHS",
                ),
                DropdownMenuItem<String>(
                  child: Text("Tiết kiệm (VTK)"),
                  value: "VTK",
                ),
                DropdownMenuItem<String>(
                  child: Text("Dịch vụ nhanh 60h (V60)"),
                  value: "V60",
                ),
                DropdownMenuItem<String>(
                  child: Text("Dịch vụ vận tải (VVT)"),
                  value: "VVT",
                ),
                DropdownMenuItem<String>(
                  child: Text("Nhanh theo hộp (VBS)"),
                  value: "VBS",
                ),
                DropdownMenuItem<String>(
                  child: Text("Tiết kiệm theo hộp (VBE)"),
                  value: "VBE",
                ),
              ],
            ),
            TextField(
              decoration: InputDecoration(
                  labelText: "Mã khách hàng:",
                  labelStyle: _headerStyle,
                  hintText: "Mã khách hàng"),
              style: inputStyle,
              controller: TextEditingController(
                  text: _vm.carrier?.vNPostClientId?.toString()),
              onChanged: (text) => _vm.carrier.vNPostClientId = int.parse(text),
              readOnly: true,
            ),

            // Loại hàng hóa
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text("Loại hàng hóa", style: _headerStyle),
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: _vm.carrier?.viettelPostProductType,
              style: inputStyle,
              hint: Text("Chọn loại hàng hóa"),
              onChanged: (value) {
                setState(() {
                  _vm.carrier.viettelPostProductType = value;
                });
              },
              items: [
                DropdownMenuItem<String>(
                  child: Text("- Không chọn -"),
                  value: null,
                ),
                DropdownMenuItem<String>(
                  child: Text("Thư"),
                  value: "TH",
                ),
                DropdownMenuItem<String>(
                  child: Text("Hàng hóa"),
                  value: "HH",
                ),
              ],
            ),

            // Loại vận đơn
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text("Loại vận đơn", style: _headerStyle),
            ),
            DropdownButton<int>(
              isExpanded: true,
              value: _vm.carrier?.viettelPostOrderPayment,
              hint: Text("Chọn loại vận đơn"),
              style: inputStyle,
              onChanged: (value) {
                setState(() {
                  _vm.carrier.viettelPostOrderPayment = value;
                });
              },
              items: [
                DropdownMenuItem<int>(
                  child: Text("Không thu tiền"),
                  value: 1,
                ),
                DropdownMenuItem<int>(
                  child: Text("Thu hộ tiền cước và tiền hàng"),
                  value: 2,
                ),
                DropdownMenuItem<int>(
                  child: Text("Thu hộ tiền hàng"),
                  value: 3,
                ),
                DropdownMenuItem<int>(
                  child: Text("Thu hộ tiền cước"),
                  value: 4,
                ),
              ],
            ),
            TextField(
              decoration: InputDecoration(
                  labelText: "Mã Token:", labelStyle: _headerStyle),
              style: inputStyle,
              controller:
                  TextEditingController(text: _vm.carrier?.viettelPostToken),
              onChanged: (text) => _vm.carrier.viettelPostToken = text,
              maxLines: null,
            ),

            RaisedButton(
              child: Text("Lấy token"),
              color: Colors.deepPurpleAccent,
              textColor: Colors.white,
              onPressed: () {
                _vm.getViettelPostShipToken();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGHNConnectInputPanel() {
    var inputStyle =
        TextStyle(color: Colors.black87, fontWeight: FontWeight.bold);
    return Container(
      padding: EdgeInsets.all(16),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSenderNameInput(),

            TextField(
              decoration: InputDecoration(
                  labelText: "Mã khách hàng:", labelStyle: _headerStyle),
              style: inputStyle,
              controller: TextEditingController(text: _vm.carrier?.gHNClientId),
              onChanged: (text) => _vm.carrier.gHNClientId = text,
            ),

            TextField(
              decoration: InputDecoration(
                  labelText: "API Key:", labelStyle: _headerStyle),
              style: inputStyle,
              controller: TextEditingController(text: _vm.carrier?.gHNApiKey),
              onChanged: (text) => _vm.carrier.gHNApiKey = text,
            ),

            // Dịch vụ
            Padding(
              padding: const EdgeInsets.only(left: 0, top: 8),
              child: Text("Dịch vụ:", style: _headerStyle),
            ),
            DropdownButton<String>(
              style: inputStyle,
              isExpanded: true,
              value: _vm.carrier?.gHNServiceId,
              hint: Text("Chọn dịch vụ"),
              onChanged: (value) {
                setState(() {
                  _vm.carrier.gHNServiceId = value;
                });
              },
              items: [
                DropdownMenuItem<String>(
                  child: Text("Không chọn"),
                  value: "",
                ),
                DropdownMenuItem<String>(
                  child: Text("Gói siêu tốc (Kiện)"),
                  value: "17",
                ),
                DropdownMenuItem<String>(
                  child: Text("Gói tiết kiệm (Kiện)"),
                  value: "18",
                ),
                DropdownMenuItem<String>(
                  child: Text("6 Giờ"),
                  value: "53319",
                ),
                DropdownMenuItem<String>(
                  child: Text("1 Ngày"),
                  value: "53320",
                ),
                DropdownMenuItem<String>(
                  child: Text("2 Ngày"),
                  value: "53321",
                ),
                DropdownMenuItem<String>(
                  child: Text("3 Ngày"),
                  value: "53322",
                ),
                DropdownMenuItem<String>(
                  child: Text("4 Ngày"),
                  value: "53323",
                ),
                DropdownMenuItem<String>(
                  child: Text("5 Ngày"),
                  value: "53324",
                ),
                DropdownMenuItem<String>(
                  child: Text("Prime"),
                  value: "53325",
                ),
                DropdownMenuItem<String>(
                  child: Text("4 Giờ"),
                  value: "53326",
                ),
                DropdownMenuItem<String>(
                  child: Text("6 Ngày"),
                  value: "53327",
                ),
                DropdownMenuItem<String>(
                  child: Text("60 Phút"),
                  value: "53329",
                ),
                DropdownMenuItem<String>(
                  child: Text("Siêu tiết kiệm"),
                  value: "100036",
                ),
              ],
            ),
            // Loại hàng hóa
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text("Ghi chú hàng ship", style: _headerStyle),
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: _vm.carrier?.gHNNoteCode,
              style: inputStyle,
              hint: Text("Chọn ghi chú"),
              onChanged: (value) {
                setState(() {
                  _vm.carrier.gHNNoteCode = value;
                });
              },
              items: [
                DropdownMenuItem<String>(
                  child: Text("Cho xem hàng không thử"),
                  value: "CHOXEMHANGKHONGTHU",
                ),
                DropdownMenuItem<String>(
                  child: Text("Cho thử hàng"),
                  value: "CHOTHUHANG",
                ),
                DropdownMenuItem<String>(
                  child: Text("Không cho xem hàng"),
                  value: "KHONGCHOXEMHANG",
                ),
              ],
            ),

            // Người  trả tiền ship
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text("Người trả  tiền ship", style: _headerStyle),
            ),
            DropdownButton<int>(
              isExpanded: true,
              value: _vm.carrier?.gHNPaymentTypeId,
              style: inputStyle,
              hint: Text("Chọn người trả"),
              onChanged: (value) {
                setState(() {
                  _vm.carrier.gHNPaymentTypeId = value;
                });
              },
              items: [
                DropdownMenuItem<int>(
                  child: Text("Shop trả"),
                  value: 1,
                ),
                DropdownMenuItem<int>(
                  child: Text("Khách trả"),
                  value: 2,
                ),
              ],
            ),
// Kích thước
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text("Kích thước kiện hàng (cm)", style: _headerStyle),
            ),

            Row(
              children: <Widget>[
                Expanded(
                  child: AppInputNumberField(
                    value: _vm.carrier?.gHNPackageLength?.toDouble(),
                    format: "###,###,###",
                    decoration: InputDecoration(
                        labelText: "Dài:", labelStyle: _headerStyle),
                    onValueChanged: (value) {
                      _vm.carrier?.gHNPackageLength = value.toInt();
                    },
                  ),
                ),
                Expanded(
                  child: AppInputNumberField(
                    value: _vm.carrier?.gHNPackageWidth?.toDouble(),
                    format: "###,###,###",
                    decoration: InputDecoration(
                        labelText: "Rộng:", labelStyle: _headerStyle),
                    onValueChanged: (value) {
                      _vm.carrier?.gHNPackageWidth = value.toInt();
                    },
                  ),
                ),
                Expanded(
                  child: AppInputNumberField(
                    value: _vm.carrier?.gHNPackageHeight?.toDouble(),
                    format: "###,###,###",
                    decoration: InputDecoration(
                        labelText: "Cao:", labelStyle: _headerStyle),
                    onValueChanged: (value) {
                      print(value);
                      _vm.carrier?.gHNPackageHeight = value.toInt();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGHTKConnectInputPanel() {
    var inputStyle =
        TextStyle(color: Colors.black87, fontWeight: FontWeight.bold);
    return Container(
      padding: EdgeInsets.all(16),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSenderNameInput(),

            TextField(
              decoration: InputDecoration(
                  labelText: "Mã khách hàng:", labelStyle: _headerStyle),
              style: inputStyle,
              controller:
                  TextEditingController(text: _vm.carrier?.gHTKClientId),
              onChanged: (text) => _vm.carrier.gHTKClientId = text,
            ),

            TextField(
              decoration: InputDecoration(
                  labelText: "Token:",
                  labelStyle: _headerStyle,
                  suffix: RaisedButton(
                    child: Text("Lấy token"),
                    onPressed: () {
                      _showGetTokenGHTKDialog();
                    },
                    textColor: Colors.white,
                  )),
              style: inputStyle,
              controller: TextEditingController(text: _vm.carrier?.gHTKToken),
              onChanged: (text) => _vm.carrier.gHTKToken = text,
            ),

            // Dịch vụ
            Padding(
              padding: const EdgeInsets.only(left: 0, top: 8),
              child: Text("Phương thức vận chuyển:", style: _headerStyle),
            ),
            DropdownButton<int>(
              style: inputStyle,
              isExpanded: true,
              value: _vm.carrier?.configTransportId,
              hint: Text("Chọn dịch vụ"),
              onChanged: (value) {
                setState(() {
                  _vm.carrier.configTransportId = value;
                });
              },
              items: [
                DropdownMenuItem<int>(
                  child: Text("Không chọn"),
                  value: null,
                ),
                DropdownMenuItem<int>(
                  child: Text("Đường bay"),
                  value: 1,
                ),
                DropdownMenuItem<int>(
                  child: Text("Đường bộ"),
                  value: 0,
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(left: 0, top: 8),
              child: Text("Người trả phí ship:", style: _headerStyle),
            ),
            DropdownButton<int>(
              style: inputStyle,
              isExpanded: true,
              value: _vm.carrier.gHNPaymentTypeId,
              hint: Text("Chọn"),
              onChanged: (value) {
                setState(() {
                  _vm.carrier.gHNPaymentTypeId = value;
                });
              },
              items: [
                DropdownMenuItem<int>(
                  child: Text("Khách trả"),
                  value: 1,
                ),
                DropdownMenuItem<int>(
                  child: Text("Shop trả"),
                  value: 2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTINTOCConnectInputPanel() {
    var inputStyle =
        TextStyle(color: Colors.black87, fontWeight: FontWeight.bold);
    return Container(
      padding: EdgeInsets.all(16),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSenderNameInput(),

            TextField(
              decoration: InputDecoration(
                  labelText: "Tài khoản (email):", labelStyle: _headerStyle),
              style: inputStyle,
              controller:
                  TextEditingController(text: _vm.carrier?.viettelPostUserName),
              onChanged: (text) => _vm.carrier.viettelPostUserName = text,
            ),
            TextField(
              decoration: InputDecoration(
                  labelText: "API TOKEN:", labelStyle: _headerStyle),
              style: inputStyle,
              controller:
                  TextEditingController(text: _vm.carrier?.viettelPostPassword),
              onChanged: (text) => _vm.carrier.viettelPostPassword = text,
            ),
            TextField(
              decoration: InputDecoration(
                  labelText: "Token:", labelStyle: _headerStyle),
              style: inputStyle,
              controller:
                  TextEditingController(text: _vm.carrier?.viettelPostToken),
              onChanged: (text) => _vm.carrier.viettelPostToken = text,
            ),

            // Dịch vụ
            Padding(
              padding: const EdgeInsets.only(left: 0, top: 8),
              child: Text("Người trả phí ship:", style: _headerStyle),
            ),
            DropdownButton<int>(
              style: inputStyle,
              isExpanded: true,
              value: _vm.carrier.gHNPaymentTypeId,
              hint: Text("Chọn dịch vụ"),
              onChanged: (value) {
                setState(() {
                  _vm.carrier.gHNPaymentTypeId = value;
                });
              },
              items: [
                DropdownMenuItem<int>(
                  child: Text("Khách trả"),
                  value: 0,
                ),
                DropdownMenuItem<int>(
                  child: Text("Shop trả"),
                  value: 1,
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(left: 0, top: 8),
              child: Text("Dịch vụ:", style: _headerStyle),
            ),
            DropdownButton<String>(
              style: inputStyle,
              isExpanded: true,
              value: _vm.carrier.viettelPostServiceId,
              hint: Text("Chọn"),
              onChanged: (value) {
                setState(
                  () {
                    _vm.carrier.viettelPostServiceId = value;
                  },
                );
              },
              items: [
                DropdownMenuItem<String>(
                  child: Text("Không chọn"),
                  value: null,
                ),
                DropdownMenuItem<String>(
                  child: Text("Giao tức thời"),
                  value: "1351",
                ),
                DropdownMenuItem<String>(
                  child: Text("Hẹn giờ"),
                  value: "2082600",
                ),
                DropdownMenuItem<String>(
                  child: Text("Tiêu chuẩn"),
                  value: "103800",
                ),
                DropdownMenuItem<String>(
                  child: Text("Siêu tốc"),
                  value: "100001",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJNTConnectInputPanel() {
    var inputStyle =
        TextStyle(color: Colors.black87, fontWeight: FontWeight.bold);
    return Container(
      padding: EdgeInsets.all(16),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSenderNameInput(),

            TextField(
              decoration: InputDecoration(
                  labelText: "Mã khách hàng:", labelStyle: _headerStyle),
              style: inputStyle,
              controller: TextEditingController(text: _vm.carrier?.gHNClientId),
              onChanged: (text) => _vm.carrier.gHNClientId = text,
            ),

            // Dịch vụ
            Padding(
              padding: const EdgeInsets.only(left: 0, top: 8),
              child: Text("Hình thức thanh toán:", style: _headerStyle),
            ),
            DropdownButton<int>(
              style: inputStyle,
              isExpanded: true,
              value: _vm.carrier.gHNPaymentTypeId,
              hint: Text("Vui lòng chọn"),
              onChanged: (value) {
                setState(() {
                  _vm.carrier.gHNPaymentTypeId = value;
                });
              },
              items: [
                DropdownMenuItem<int>(
                  child: Text("PP_PM"),
                  value: 0,
                ),
                DropdownMenuItem<int>(
                  child: Text("PP_CASH"),
                  value: 1,
                ),
                DropdownMenuItem<int>(
                  child: Text("CC_CASH"),
                  value: 2,
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(left: 0, top: 8),
              child: Text("Hình thức lấy hàng:", style: _headerStyle),
            ),
            DropdownButton<String>(
              style: inputStyle,
              isExpanded: true,
              value: _vm.carrier.vNPostPickupType,
              hint: Text("Chọn"),
              onChanged: (value) {
                setState(
                  () {
                    _vm.carrier.vNPostPickupType = value;
                  },
                );
              },
              items: [
                DropdownMenuItem<String>(
                  child: Text("Không chọn"),
                  value: null,
                ),
                DropdownMenuItem<String>(
                  child: Text("Dropoff (Mang hàng đến bưu cục)"),
                  value: "6",
                ),
                DropdownMenuItem<String>(
                  child: Text("Picup (Thu gom hàng)"),
                  value: "1",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSUPERSHIPConnectInputPanel() {
    var inputStyle =
        TextStyle(color: Colors.black87, fontWeight: FontWeight.bold);
    return Container(
      padding: EdgeInsets.all(16),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSenderNameInput(),
            TextField(
              decoration: InputDecoration(
                  labelText: "Mã khách hàng:", labelStyle: _headerStyle),
              style: inputStyle,
              controller:
                  TextEditingController(text: _vm.carrier?.superShipClientId),
              onChanged: (text) => _vm.carrier.superShipClientId = text,
            ),
            TextField(
              decoration: InputDecoration(
                  labelText: "Token:", labelStyle: _headerStyle),
              style: inputStyle,
              controller:
                  TextEditingController(text: _vm.carrier?.superShipToken),
              onChanged: (text) => _vm.carrier.superShipToken = text,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFIXEDConnectInputPanel() {
    var inputStyle =
        TextStyle(color: Colors.black87, fontWeight: FontWeight.bold);
    return Container(
      padding: EdgeInsets.all(16),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSenderNameInput(),
            AppInputNumberField(
              value: _vm.carrier?.fixedPrice ?? 0,
              onValueChanged: (value) => _vm.carrier?.fixedPrice = value,
              format: "###,###,###.###",
              decoration: InputDecoration(
                  labelText: "Giá cố định", labelStyle: _headerStyle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _builDefaultValuePanel() {
    return Container(
      child: Column(
        children: <Widget>[],
      ),
    );
  }

  String groupValue = "has";
  Widget _showGetTokenGHTKDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Lấy token GHTK"),
        content: GetTokenDialog(_vm),
      ),
    );
  }
}

class GetTokenDialog extends StatefulWidget {
  final DeliveryCarrierPartnerAddEditViewModel vm;
  GetTokenDialog(this.vm);
  @override
  _GetTokenDialogState createState() => _GetTokenDialogState();
}

class _GetTokenDialogState extends State<GetTokenDialog> {
  String groupValue = "has";
  var _usernameController = new TextEditingController();
  var _passwordController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return UIViewModelBase(
      viewModel: widget.vm,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: RadioListTile<String>(
                  title: Text("Đã có TK"),
                  groupValue: groupValue,
                  value: "has",
                  onChanged: (value) {
                    setState(() {
                      groupValue = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: Text("Chưa có TK"),
                  groupValue: groupValue,
                  value: "no",
                  onChanged: (value) {
                    setState(() {
                      groupValue = value;
                    });
                  },
                ),
              ),
            ],
          ),
          if (groupValue == "has") getHasAccount(),
          if (groupValue == "no") getNoAccount(),
        ],
      ),
    );
  }

  Widget getHasAccount() {
    return Column(
      children: <Widget>[
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            hintText: "Tên đăng nhập",
            labelText: "Tên đăng nhập",
          ),
        ),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            hintText: "Mật khẩu",
            labelText: "Tên đăng nhập",
          ),
        ),
        RaisedButton(
          child: Text("ĐỒNG Ý"),
          color: Colors.blue,
          onPressed: () {
            widget.vm
                .getGhtkToken(
                    username: _usernameController.text,
                    password: _passwordController.text)
                .then((value) {
              if (value) Navigator.pop(context);
            });
          },
          textColor: Colors.white,
        )
      ],
    );
  }

  Widget getNoAccount() {
    return SizedBox();
  }
}
