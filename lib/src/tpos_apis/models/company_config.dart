import 'package:tpos_mobile/sale_online/models/tpos_desktop/print_fast_sale_order_config.dart';

class CompanyConfig {
  String odataContext;
  String id;
  int defaultPrinterId;
  String defaultPrinterName;
  String defaultPrinterTemplate;
  int companyId;
  String companyName;
  List<PrinterConfig> printerConfigs;

  CompanyConfig(
      {this.odataContext,
      this.id,
      this.defaultPrinterId,
      this.defaultPrinterName,
      this.defaultPrinterTemplate,
      this.companyId,
      this.companyName,
      this.printerConfigs});

  CompanyConfig.fromJson(Map<String, dynamic> json) {
    odataContext = json['@odata.context'];
    id = json['Id'];
    defaultPrinterId = json['DefaultPrinterId'];
    defaultPrinterName = json['DefaultPrinterName'];
    defaultPrinterTemplate = json['DefaultPrinterTemplate'];
    companyId = json['CompanyId'];
    companyName = json['CompanyName'];
    if (json['PrinterConfigs'] != null) {
      printerConfigs = new List<PrinterConfig>();
      json['PrinterConfigs'].forEach((v) {
        printerConfigs.add(new PrinterConfig.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['@odata.context'] = this.odataContext;
    data['Id'] = this.id;
    data['DefaultPrinterId'] = this.defaultPrinterId;
    data['DefaultPrinterName'] = this.defaultPrinterName;
    data['DefaultPrinterTemplate'] = this.defaultPrinterTemplate;
    data['CompanyId'] = this.companyId;
    data['CompanyName'] = this.companyName;
    if (this.printerConfigs != null) {
      data['PrinterConfigs'] =
          this.printerConfigs.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PrinterConfig {
  String code;
  String name;
  dynamic template;
  int printerId;
  String printerName;
  String ip;
  String port;
  String note;
  String fontSize;
  String noteHeader;
  bool isUseCustom;
  bool isPrintProxy;
  List<PrintConfigOther> others;

  PrinterConfig(
      {this.code,
      this.name,
      this.template,
      this.printerId,
      this.printerName,
      this.ip,
      this.port,
      this.note,
      this.fontSize,
      this.noteHeader,
      this.isUseCustom,
      this.isPrintProxy,
      this.others});

  PrinterConfig.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    name = json['Name'];
    template = json['Template'];
    printerId = json['PrinterId'];
    printerName = json['PrinterName'];
    ip = json['Ip'];
    port = json['Port'];
    note = json['Note'];
    fontSize = json['FontSize'];
    noteHeader = json['NoteHeader'];
    isUseCustom = json['IsUseCustom'];
    isPrintProxy = json['IsPrintProxy'];
    if (json['Others'] != null) {
      others = new List<PrintConfigOther>();
      json['Others'].forEach((v) {
        others.add(new PrintConfigOther.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Code'] = this.code;
    data['Name'] = this.name;
    data['Template'] = this.template;
    data['PrinterId'] = this.printerId;
    data['PrinterName'] = this.printerName;
    data['Ip'] = this.ip;
    data['Port'] = this.port;
    data['Note'] = this.note;
    data['FontSize'] = this.fontSize;
    data['NoteHeader'] = this.noteHeader;
    data['IsUseCustom'] = this.isUseCustom;
    data['IsPrintProxy'] = this.isPrintProxy;
    if (this.others != null) {
      data['Others'] = this.others.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PrintConfigOther {
  String text;
  String key;
  bool value;
  Config get keyConfig {
    return Config.values.firstWhere(
        (f) => f.toString().toLowerCase().trim() == key.toLowerCase(),
        orElse: () => null);
  }

  PrintConfigOther({this.text, this.key, this.value});

  PrintConfigOther.fromJson(Map<String, dynamic> json) {
    text = json['Text'];
    key = json['Key'];
    value = json['Value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Text'] = this.text;
    data['Key'] = this.key;
    data['Value'] = this.value;
    return data;
  }
}
