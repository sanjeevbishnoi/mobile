import 'dart:math';

import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';
import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/services/dialog_service.dart';
import 'package:tpos_mobile/src/tpos_apis/models/company.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_all.dart';

class CompanyAddEditViewModel extends ViewModel {
  DialogService _dialogService;
  TposApi _tposApi;
  CompanyAddEditViewModel({DialogService dialogService, TposApi tposApi}) {
    _dialogService = dialogService?? locator<DialogService>();
    _tposApi = tposApi?? locator<TposApi>();
  }

  Company _company = new Company();
  Company get company=>_company;

  void init({Company company}) {
    _company = company;
  }

  Future initData() async {
    onStateAdd(true);
    if(_company==null || _company.id==null || _company.id==0) {
      // tạo mới
      _company = new Company();
    }
    else {
      // Tải về
      _company = await _tposApi.company.getById(_company.id);
    }
    notifyListeners();
    onStateAdd(false);
  }


  Future<bool> save({bool refreshOnSaved}) async {
    bool isSuccess =false;
    onStateAdd(true, message: "Đang lưu...");
    try{
      if (_company!=null && _company.id!=null && _company.id!=0) {
        //update
        await _tposApi.company.update(_company);
        _dialogService.showNotify(message:"Đã cập nhật công ty ${_company.name}", showOnTop: true, type: DialogType.NOTIFY_INFO);
        isSuccess =true;
    }
      else {
        // insert
        await _tposApi.company.insert(_company);
        _dialogService.showNotify(message:"Đã thêm công ty mới");
        isSuccess =true;
      }

      if (refreshOnSaved) {
       await  initData();
      }
    }
    catch (e,s) {
      logger.error("", e, s);
      _dialogService.showError(error: e);
    }

    onStateAdd(false);
    return isSuccess;
  }
}