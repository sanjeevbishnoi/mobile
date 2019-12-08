import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base_provider.dart';
import 'package:tpos_mobile/pos_order/models/partners.dart';
import 'package:tpos_mobile/pos_order/services/pos_tpos_api.dart';
import 'package:tpos_mobile/pos_order/sqlite_database/database_function.dart';
import 'package:tpos_mobile/pos_order/sqlite_database/database_helper.dart';
import 'package:tpos_mobile/services/dialog_service.dart';

import '../../app_service_locator.dart';

class PosPartnerAddEditViewModel extends ViewModelBase {
  DialogService _dialog;
  IPosTposApi _tposApi;
  IDatabaseFunction _dbFuction;
  PosPartnerAddEditViewModel(
      {IPosTposApi tposApiService, DialogService dialogService}) {
    _tposApi = tposApiService ?? locator<IPosTposApi>();
    _dialog = dialogService ?? locator<DialogService>();
    _dbFuction = dialogService ?? locator<IDatabaseFunction>();
  }

  File image;
  Partners partner = Partners();
  final dbHelper = DatabaseHelper.instance;

  void getImageFromGallery() async {
    image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    notifyListeners();
  }

  void getImageFromCamera() async {
    image = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );
    notifyListeners();
  }

  Future<void> updatePartner(bool isUpdate) async {
    setState(true);
    try {
      if (isUpdate) {
        var result = await _tposApi.updatePartner(partner);
        if (result != null) {
          await _dbFuction.updatePartner(partner);
          showNotifyUpdate("Cập nhật thông tin thành công");
        } else {
          showNotifyUpdate("Cập nhật thất bại");
        }
      } else {
        var result = await _tposApi.updatePartner(partner);
        if (result != null) {
          await _dbFuction.insertPartner(result);
          showNotifyUpdate("Thêm khách hàng thành công");
        } else {
          showNotifyUpdate("Thêm khách hàng thất bại");
        }
      }
    } catch (e, s) {
      logger.error("loadProductFail", e, s);
      _dialog.showError(error: e);
    }
    setState(false);
  }

  void showNotifyUpdate(String title) {
    _dialog.showNotify(title: "Thông báo", message: title);
  }
}
