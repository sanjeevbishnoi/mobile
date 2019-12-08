


import 'dart:convert';

import 'package:tpos_mobile/sale_online/models/tpos_service/tpos_service_models.dart';
import 'package:tpos_mobile/src/tpos_apis/models/company.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_client.dart';
import 'package:tpos_mobile/src/tpos_apis/services/tpos_api_service_base.dart';

abstract class ICompanyService {
  Future<Company> getById(int companyId);
  Future<void> update(Company company);
  Future<void> insert(Company company);
  Future<GetCompanyCurrentResult> getCompanyCurrent();
}

class CompanyService extends ApiServiceBase implements ICompanyService {

  CompanyService ({TposApiClient apiClient}): super(apiClient:apiClient);
  @override
  Future<Company> getById(int companyId) async {
    var response = await apiClient.httpGet(path: "/odata/Company($companyId)");
    if (response.statusCode == 200)
      return Company.fromJson(jsonDecode(response.body));
    throwTposApiException(response);
    return null;
  }


  @override
  Future<GetCompanyCurrentResult> getCompanyCurrent() async {
    var response = await apiClient.httpGet(path: "/Company/GetCompanyCurrent");
    if (response.statusCode == 200)
      return GetCompanyCurrentResult.fromJson(jsonDecode(response.body));
    throwTposApiException(response);
    return null;
  }

  @override
  Future<void> update(Company company) async {
    assert(company!=null && company.id!=null && company.id!=0);
    var response = await apiClient.httpPut(path: "/odata/Company(${company.id})", body: jsonEncode(company.toJson()));
    if (response.statusCode != 204)
    throwTposApiException(response);
    return null;
  }

  @override
  Future<void> insert(Company company) async {
    assert(company!=null );
    var response = await apiClient.httpPost(path: "/odata/Company", 
    body: jsonEncode(company.toJson(),),);
    if (response.statusCode != 201)
      throwTposApiException(response);
    return null;
  }

}