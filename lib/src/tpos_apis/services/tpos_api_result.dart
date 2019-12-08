import 'package:tpos_mobile/sale_online/services/service.dart';

class TPosApiListResult<T> {
  int count;
  List<T> data;

  TPosApiListResult({this.count, this.data});
}
