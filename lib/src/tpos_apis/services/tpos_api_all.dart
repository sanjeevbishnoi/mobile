import 'package:tpos_mobile/app_service_locator.dart';
import 'package:tpos_mobile/src/tpos_apis/services/object_apis/company_api.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_interface.dart';

import 'object_apis/fast_sale_order_api.dart';
import 'object_apis/sale_setting_api.dart';

class TposApi {
  ICompanyService _company;
  IFastSaleOrderApi _fastSaleOrder;
  ISaleSettingApi _saleSetting;

  ICompanyService get company => _company;
  ISaleSettingApi get saleSetting=>_saleSetting;
  TposApi({
    ICompanyService companyService,
    IFastSaleOrderApi fastSaleOrderApi,
    ISaleSettingApi saleSetting,
  }) {
    _company = companyService ?? locator<ICompanyService>();
    _fastSaleOrder = fastSaleOrderApi ?? locator<IFastSaleOrderApi>();
    _saleSetting = saleSetting?? locator<ISaleSettingApi>();
  }
}
