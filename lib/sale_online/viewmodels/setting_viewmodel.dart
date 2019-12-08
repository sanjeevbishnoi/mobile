import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/app_core/viewmodel/viewmodel_base.dart';

class SettingViewModel extends ViewModel {
  SettingViewModel({ISettingService settingService}) {
    settingService = settingService ?? locator<ISettingService>();
  }
}
