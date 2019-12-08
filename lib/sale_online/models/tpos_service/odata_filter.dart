import 'package:intl/intl.dart';
import 'package:tpos_mobile/helpers/tpos_api_helper.dart';

abstract class FilterBase {
  Map<String, dynamic> toJson();
  String toUrlEncode();
}

class OdataSortItem {
  String dir;

  OdataSortItem({this.dir, this.field});
  String field;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data["dir"] = dir;
    data["field"] = field;
    return data;
  }

  String tourlEncode() {
    return "$field $dir";
  }
}

class OdataFilter extends FilterBase {
  String logic;
  List<FilterBase> filters;

  OdataFilter({this.logic, this.filters});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data["logic"] = logic;
    data["filters"] = filters.map((f) => f.toJson()).toList();
    return data;
  }

  String toUrlEncode() {
    String filter = "";

    filter = filters
        .map((f) {
          return f.toUrlEncode();
        })
        .toList()
        .join(logic == "and" ? " and " : " or ");

    return "($filter)";
  }
}

class OdataFilterItem extends FilterBase {
  final String field;
  final String operator;
  final Object value;
  final Function(DateTime) convertDatetime;
  final Type dataType;

  OdataFilterItem(
      {this.field,
      this.operator,
      this.value,
      this.convertDatetime,
      this.dataType});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data["field"] = field;
    data["operator"] = operator;
    data["value"] = getValueJson();

    return data;
  }

  String getValueJson() {
    var valueResult = "";
    if (value is DateTime) {
      valueResult = convertDatetime != null
          ? convertDatetime(value)
          : DateFormat("yyyy-MM-ddTHH:mm:ss").format(value as DateTime);
    } else
      valueResult = value;
    return valueResult;
  }

  String toUrlEncode() {
    String result = "";
    String valueResult = "";
    if (dataType == int) {
      valueResult = value;
    } else if (value is String) {
      valueResult = "'$value'";
    } else if (value is DateTime) {
      DateTime valueDate = value as DateTime;

      valueResult = convertDatetime != null
          ? convertDatetime(value)
          : convertDatetimeToString(valueDate);
    } else {
      valueResult = value.toString();
    }
    result = "$field $operator $valueResult";
    return result;
  }
}
