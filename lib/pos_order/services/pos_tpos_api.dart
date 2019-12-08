import 'dart:convert';

import 'package:tpos_mobile/pos_order/models/cart_product.dart';
import 'package:tpos_mobile/pos_order/models/company.dart';
import 'package:tpos_mobile/pos_order/models/key.dart';
import 'package:tpos_mobile/pos_order/models/partners.dart';
import 'package:tpos_mobile/pos_order/models/payment.dart';
import 'package:tpos_mobile/pos_order/models/point_sale.dart';
import 'package:tpos_mobile/pos_order/models/price_list.dart';
import 'package:tpos_mobile/pos_order/models/promotion.dart';
import 'package:tpos_mobile/pos_order/models/res_currency.dart';
import 'package:tpos_mobile/src/tpos_apis/models/account_journal.dart';
import 'package:tpos_mobile/src/tpos_apis/models/partner.dart';
import 'package:tpos_mobile/src/tpos_apis/models/product.dart';

import '../../sale_online/services/tpos_api_service.dart';
import '../../src/tpos_apis/services/tpos_api_service_base.dart';
import '../models/pos_order.dart';

abstract class IPosTposApi {
  // get Session
  Future<List<Session>> getPosSession();
  // get Point Sales
  Future<List<PointSale>> getPointSales();
  // get Price List
  Future<List<PriceList>> getPriceLists();
  // check Create Session
  Future<bool> checkCreateSessionSale(int configId);
  // get Company
  Future<List<Companies>> getCompanys();
  // get ResCurreies
  Future<List<ResCurrency>> getResCurreies();
  // get Partner
  Future<List<Partners>> getPartners();
  // get Account journal
  Future<List<AccountJournal>> getAccountJournals();
  // get Product
  Future<List<CartProduct>> getProducts();
  // update Partner
  Future<Partners> updatePartner(Partners partner);
  // excute Payment
  Future<bool> exePayment(List<Payment> payments, bool isCheckInvoice);
  // fiiter price list product
  Future<List<dynamic>> exeListPrice(String id);
  // get promotion
  Future<List<Promotion>> getPromotions(List<Promotion> promotions);
}

class PosTposApi extends ApiServiceBase implements IPosTposApi {
  @override
  Future<List<Session>> getPosSession() async {
    List<Session> _sessions = [];

    String body = json.encode({
      "model": {
        "State": "opened",
        "UserId": "6ae9a8e1-3acd-40c0-b3f7-96d49ce403e9"
      }
    });
    var response = await apiClient.httpPost(
        path: '/odata/POS_Session/ODataService.Search', body: body);

    if (response.statusCode == 200) {
      for (var session in json.decode(response.body)["value"]) {
        _sessions.add(Session.fromJson(session));
      }

      // var list = (map["items"] as List).map((f) => Labo.fromJson(f)).toList();
      return _sessions;
    }
    throwHttpException(response);
    return null;
  }

  @override
  Future<List<PointSale>> getPointSales() async {
    List<PointSale> _pointSales = [];

    var response = await apiClient.httpGet(
        path: "/odata/POS_Config/ODataService.SearchReadKanban");
    if (response.statusCode == 200) {
      for (var pointSale in json.decode(response.body)["value"]) {
        _pointSales.add(PointSale.fromJson(pointSale));
      }
      return _pointSales;
    }
    throwHttpException(response);
    return null;
  }

  @override
  Future<List<PriceList>> getPriceLists() async {
    List<PriceList> _priceLists = [];

    var response = await apiClient.httpGet(path: "/odata/Product_PriceList");
    if (response.statusCode == 200) {
      for (var pointSale in json.decode(response.body)["value"]) {
        _priceLists.add(PriceList.fromJson(pointSale));
      }
      return _priceLists;
    }
    throwHttpException(response);
    return null;
  }

  @override
  Future<bool> checkCreateSessionSale(int configId) async {
    bool result = false;
    String body = json.encode({"configId": configId});

    var response = await apiClient.httpPost(
        path: "/odata/POS_Config/ODataService.OpenSessionCb", body: body);
    if (response.statusCode.toString().startsWith("2")) {
      result = true;
    } else {
      result = false;
    }
    return result;
  }

  @override
  Future<List<Companies>> getCompanys() async {
    List<Companies> _companys = [];

    String body = json.encode({
      "ids": [1]
    });

    var response = await apiClient.httpPost(
        path: "/odata/Company/ODataService.SearchForPos", body: body);

    if (response.statusCode == 200) {
      for (var company in json.decode(response.body)["value"]) {
        _companys.add(Companies.fromJson(company));
      }
      return _companys;
    }
    throwHttpException(response);
    return null;
  }

  @override
  Future<List<ResCurrency>> getResCurreies() async {
    List<ResCurrency> _resCurrencies = [];
    String body = json.encode({
      "model": {
        "Ids": [1]
      }
    });

    var response = await apiClient.httpPost(
        path: "/odata/ResCurrency/ODataService.Search", body: body);
    if (response.statusCode == 200) {
      for (var company in json.decode(response.body)["value"]) {
        _resCurrencies.add(ResCurrency.fromJson(company));
      }
      return _resCurrencies;
    }
    throwHttpException(response);
    return null;
  }

  @override
  Future<List<Partners>> getPartners() async {
    List<Partners> _partners = [];
    var response = await apiClient.httpGet(
        path: "/odata/Partner/ODataService.SearchForPos");

    if (response.statusCode == 200) {
      for (var company in json.decode(response.body)["value"]) {
        _partners.add(Partners.fromJson(company));
      }
      return _partners;
    }
    throwHttpException(response);
    return null;
  }

  @override
  Future<List<AccountJournal>> getAccountJournals() async {
    List<AccountJournal> accountJournals = [];

    var response = await apiClient.httpGet(
        path: "/odata/AccountJournal?\$filter=(Id+eq+1)&\$select=Id,Type,Name");
    if (response.statusCode == 200) {
      for (var company in json.decode(response.body)["value"]) {
        accountJournals.add(AccountJournal.fromJson(company));
      }
      return accountJournals;
    }
    throwHttpException(response);
    return null;
  }

  @override
  Future<List<CartProduct>> getProducts() async {
    List<CartProduct> _products = [];

    var response = await apiClient.httpGet(
        path:
            "/odata/ProductTemplateUOMLine/ODataService.GetLastVersionV2?\$expand=Datas&countIndexDB=0&Version=-1");

    if (response.statusCode == 200) {
      for (var product in json.decode(response.body)["Datas"]) {
        _products.add(CartProduct.fromJson(product));
      }
      return _products;
    }
    throwHttpException(response);
    return null;
  }

  @override
  Future<Partners> updatePartner(Partners partner) async {
    // TODO: implement updatePartner

    String body = json.encode({"model": partner.toJson()});
    var response = await apiClient.httpPost(
        path: "/odata/Partner/ODataService.CreateUpdateFromUI", body: body);
    if (response.statusCode == 200) {
      return Partners.fromJson(json.decode(response.body));
    }
    throwHttpException(response);
    return null;
  }

  @override
  Future<bool> exePayment(List<Payment> payments, bool isCheckInvoice) async {
    int count = 0;

    String body = json.encode({
      "models": payments
          .map((val) => {
                "id": val.uid,
                "data": val.toJson(),
                "to_invoice": isCheckInvoice
              })
          .toList()
    });

    var response = await apiClient.httpPost(
        path: "/odata/POS_Order/ODataService.CreateFromUI", body: body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<List<dynamic>> exeListPrice(String id) async {
    var keys = [];
    var response =
        await apiClient.httpGet(path: "/api/common/getpricelistitems?id=$id");

    if (response.statusCode == 200) {
      var res = json.decode(response.body);
      keys = res.keys.map((val) => Key(key: val, value: res[val])).toList();
    }

    return keys;
  }

  @override
  Future<List<Promotion>> getPromotions(List<Promotion> promotions) async {
    List<Promotion> _promotions = [];
    String body =
        json.encode({"model": promotions.map((val) => val.toJson()).toList()});

    var response = await apiClient.httpPost(
        path: "/odata/POS_Order/ODataService.ApplyPromotion", body: body);

    if (response.statusCode == 200) {
      var map = json.decode(response.body);
      _promotions =
          (map["value"] as List).map((val) => Promotion.fromJson(val)).toList();
      return _promotions;
    }
    // var list = (map["items"] as List).map((f) => Labo.fromJson(f)).toList();
    throwHttpException(response);
    return null;
  }
}
