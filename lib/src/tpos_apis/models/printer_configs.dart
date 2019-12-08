class PrinterConfigs {
  String code;
  String name;
  String template;
  int printerId;
  String printerName;
  String ip;
  String port;
  String note;
  String fontSize;
  String noteHeader;
  bool isUseCustom;
  bool isPrintProxy;
  List<Other> others;

  PrinterConfigs(
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

  PrinterConfigs.fromJson(Map<String, dynamic> jsonMap) {
    List<Other> othersTemp;

    code = jsonMap["Code"];
    name = jsonMap["Name"];
    template = jsonMap["Template"];
    printerId = jsonMap["PrinterId"];
    printerName = jsonMap["PrinterName"];
    ip = jsonMap["Ip"];
    port = jsonMap["Port"];
    note = jsonMap["Note"];
    fontSize = jsonMap["FontSize"];
    noteHeader = jsonMap["NoteHeader"];
    isUseCustom = jsonMap["IsUseCustom"];
    isPrintProxy = jsonMap["IsPrintProxy"];

    if (jsonMap["Others"] != null) {
      others =
          (jsonMap["Others"] as List).map((f) => Other.fromJson(f)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "Code": code,
      "Name": name,
      "Template": template,
      "PrinterId": printerId,
      "PrinterName": printerName,
      "Ip": ip,
      "Port": port,
      "Note": note,
      "NoteHeader": noteHeader,
      "IsUseCustom": isUseCustom,
      "IsPrintProxy": isPrintProxy,
      "Others": others != null ? others.map((f) => f.toJson()).toList() : null,
    };
  }
}

class Other {
  String key;
  String text;
  bool value;

  Other({this.key, this.text, this.value});

  Other.fromJson(Map<String, dynamic> jsonMap) {
    key = jsonMap["Key"];
    text = jsonMap["Text"];
    value = jsonMap["Value"];
  }

  Map<String, dynamic> toJson() {
    return {
      "key": key,
      "Text": text,
      "Value": value,
    };
  }
}
