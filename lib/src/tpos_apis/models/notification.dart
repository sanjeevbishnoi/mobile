class GetNotificationResult {
  int count;
  List<Notification> items;

  GetNotificationResult({this.count, this.items});

  GetNotificationResult.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['items'] != null) {
      items = new List<Notification>();
      json['items'].forEach((v) {
        items.add(new Notification.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    if (this.items != null) {
      data['items'] = this.items.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Notification {
  String id;
  String title;
  String image;
  String content;
  String description;
  int notificationId;
  bool enablePopup;
  dynamic images;
  dynamic topics;
  dynamic markReadBy;
  DateTime dateRead;
  DateTime dateCreated;

  Notification(
      {this.id,
      this.title,
      this.image,
      this.content,
      this.description,
      this.notificationId,
      this.enablePopup,
      this.images,
      this.topics,
      this.markReadBy,
      this.dateRead,
      this.dateCreated});

  Notification.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    title = json['Title'];
    image = json['Image'];
    content = json['Content'];
    description = json['Description'];
    notificationId = json['NotificationId'];
    enablePopup = json['EnablePopup'];
    images = json['Images'];
    topics = json['Topics'];
    markReadBy = json['MarkReadBy'];
    if (json['DateRead'] != null) {
      dateRead = DateTime.parse(json['DateRead']);
    }
    if (json['DateCreated'] != null) {
      dateCreated = DateTime.parse(json['DateCreated']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Title'] = this.title;
    data['Image'] = this.image;
    data['Content'] = this.content;
    data['Description'] = this.description;
    data['NotificationId'] = this.notificationId;
    data['EnablePopup'] = this.enablePopup;
    data['Images'] = this.images;
    data['Topics'] = this.topics;
    data['MarkReadBy'] = this.markReadBy;
    data['DateRead'] = this.dateRead;
    data['DateCreated'] = this.dateCreated;
    return data;
  }
}
