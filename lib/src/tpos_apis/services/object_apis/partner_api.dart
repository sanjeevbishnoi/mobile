import 'dart:convert';

import 'package:tpos_mobile/sale_online/services/service.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_service_base.dart';

abstract class IPartnerApi {
  /// Tạo mới hoặc cập nhật thông tin khách hàng
  Future<Partner> createOrUpdate(Partner partner, [int crmTeamId]);
}

class PartnerApi extends ApiServiceBase implements IPartnerApi {
  @override
  Future<Partner> createOrUpdate(Partner partner, [int crmTeamId]) async {
    var data = partner.toJson();
    data.removeWhere((key, value) {
      return value == null;
    });
    var bodyMap = {"model": data, "teamId": crmTeamId}
      ..removeWhere((key, value) => value == null);
    String body = jsonEncode(bodyMap);

    var response = await apiClient.httpPost(
        path: "/odata/SaleOnline_Order/ODataService.CreateUpdatePartner",
        body: body);

    if (response.statusCode == 200) {
      return Partner.fromJson(jsonDecode(response.body));
    }
    throwTposApiException(response);
    return null;
  }
}
