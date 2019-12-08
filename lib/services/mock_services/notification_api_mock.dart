import 'package:tpos_mobile/src/tpos_apis/models/notification.dart';
import 'package:tpos_mobile/src/tpos_apis/services/object_apis/notification_api.dart';

class NotificationApiMock implements INotificationApi {
  @override
  Future<GetNotificationResult> getAll() async {
    Map<String, dynamic> fake = {
      "total": 1,
      "count": 0,
      "popup": null,
      "items": [
        {
          "Id": "5dcf66e49af035a93c76f36e",
          "Title": "Thông báo v/v Facebook cập nhật chính sách",
          "Image":
              "https://tpos.vn/uploads/files/admin/2019-11/fb-hero-image-001-1.jpeg",
          "Content":
              "<p dir=\"ltr\">Phần mềm quản l&yacute; b&aacute;n h&agrave;ng TPos th&ocirc;ng b&aacute;o đến Qu&yacute; kh&aacute;ch h&agrave;ng v&agrave; đối t&aacute;c về việc thay đổi thuật to&aacute;n của Facebook l&agrave;m ảnh hưởng đến một số người d&ugrave;ng trong hệ thống phần mềm.</p><p dir=\"ltr\">Theo đ&oacute;, từ <strong>0h ng&agrave;y 17/11/2019</strong> mạng x&atilde; hội Facebook cập nhật ch&iacute;nh s&aacute;ch dữ liệu với đối t&aacute;c, điều n&agrave;y l&agrave;m thay đổi thuật to&aacute;n nhận diện người d&ugrave;ng tr&ecirc;n hệ thống phần mềm!</p><p dir=\"ltr\">Nay ch&uacute;ng t&ocirc;i gửi th&ocirc;ng b&aacute;o đến Qu&yacute; đối t&aacute;c v&agrave; kh&aacute;ch h&agrave;ng của TPos, sự chuyển đổi n&agrave;y sẽ khiến chủ shop kh&ocirc;ng c&ograve;n thấy những th&ocirc;ng tin của MỘT SỐ kh&aacute;ch h&agrave;ng cũ như số điện thoại, địa chỉ như trước nữa. B&ecirc;n cạnh đ&oacute;, một số t&iacute;nh năng tạm thời sẽ bị hạn chế như sau:</p><ul><li dir=\"ltr\"><p dir=\"ltr\">Gộp like tr&ecirc;n t&agrave;i khoản c&aacute; nh&acirc;n v&agrave; page, giữa page v&agrave; page</p></li><li dir=\"ltr\"><p dir=\"ltr\">Chỉ cho ph&eacute;p gộp live giữa c&aacute;c t&agrave;i khoản c&aacute; nh&acirc;n hoặc giữa c&aacute;c live trong c&ugrave;ng một page</p></li></ul><p dir=\"ltr\">Ch&uacute;ng t&ocirc;i đang cố gắng hết sức để qu&aacute; tr&igrave;nh chuyển đổi của Facebook &iacute;t g&acirc;y ảnh hưởng nhất đến Qu&yacute; đối t&aacute;c v&agrave; kh&aacute;ch h&agrave;ng!</p><p dir=\"ltr\">Mong qu&yacute; kh&aacute;ch sắp xếp thời gian xử l&yacute; c&ocirc;ng việc v&agrave; <strong>duy tr&igrave; c&aacute;c&nbsp;</strong><strong>k&ecirc;nh b&aacute;n h&agrave;ng hoạt động b&igrave;nh thường</strong> để ch&uacute;ng t&ocirc;i c&oacute; thể tiến h&agrave;nh bảo tr&igrave; phần mềm v&agrave;o l&uacute;c <strong>0h ng&agrave;y 17/11/2019</strong>, dự kiến thời gian ho&agrave;n th&agrave;nh bảo tr&igrave; l&agrave;<strong>&nbsp;6</strong><strong>h ng&agrave;y 17/11/2019</strong>. Ch&uacute;ng t&ocirc;i rất xin lỗi v&igrave; sự bất tiện n&agrave;y!</p><p dir=\"ltr\">Mọi th&ocirc;ng tin chi tiết, vui l&ograve;ng li&ecirc;n hệ để được th&ocirc;ng tin r&otilde; r&agrave;ng nhất!</p><p dir=\"ltr\">Hotline: <strong>090.807.5455</strong></p><p dir=\"ltr\">Hỗ trợ 24/7: <strong>1900 2852</strong></p><p dir=\"ltr\">Tr&acirc;n trọng!</p>",
          "Description":
              "Phần mềm quản lý bán hàng TPos thông báo đến Quý khách hàng và đối tác về việc thay đổi thuật toán của Facebook làm ảnh hưởng đến một số người dùng trong hệ thống phần mềm.",
          "NotificationId": null,
          "EnablePopup": false,
          "Images": null,
          "Topics": null,
          "MarkReadBy": null,
          //"DateRead": "2019-11-16T04:48:35.89Z",
          "DateCreated": "2019-11-16T03:03:00.637Z"
        }
      ]
    };

    return GetNotificationResult.fromJson(fake);
  }

  @override
  Future<GetNotificationResult> getNotRead() async {
    Map<String, dynamic> fake = {
      "total": 1,
      "count": 0,
      "popup": null,
      "items": [
        {
          "Id": "5dcf66e49af035a93c76f36e",
          "Title": "Thông báo v/v Facebook cập nhật chính sách",
          "Image":
              "https://tpos.vn/uploads/files/admin/2019-11/fb-hero-image-001-1.jpeg",
          "Content":
              "<p dir=\"ltr\">Phần mềm quản l&yacute; b&aacute;n h&agrave;ng TPos th&ocirc;ng b&aacute;o đến Qu&yacute; kh&aacute;ch h&agrave;ng v&agrave; đối t&aacute;c về việc thay đổi thuật to&aacute;n của Facebook l&agrave;m ảnh hưởng đến một số người d&ugrave;ng trong hệ thống phần mềm.</p><p dir=\"ltr\">Theo đ&oacute;, từ <strong>0h ng&agrave;y 17/11/2019</strong> mạng x&atilde; hội Facebook cập nhật ch&iacute;nh s&aacute;ch dữ liệu với đối t&aacute;c, điều n&agrave;y l&agrave;m thay đổi thuật to&aacute;n nhận diện người d&ugrave;ng tr&ecirc;n hệ thống phần mềm!</p><p dir=\"ltr\">Nay ch&uacute;ng t&ocirc;i gửi th&ocirc;ng b&aacute;o đến Qu&yacute; đối t&aacute;c v&agrave; kh&aacute;ch h&agrave;ng của TPos, sự chuyển đổi n&agrave;y sẽ khiến chủ shop kh&ocirc;ng c&ograve;n thấy những th&ocirc;ng tin của MỘT SỐ kh&aacute;ch h&agrave;ng cũ như số điện thoại, địa chỉ như trước nữa. B&ecirc;n cạnh đ&oacute;, một số t&iacute;nh năng tạm thời sẽ bị hạn chế như sau:</p><ul><li dir=\"ltr\"><p dir=\"ltr\">Gộp like tr&ecirc;n t&agrave;i khoản c&aacute; nh&acirc;n v&agrave; page, giữa page v&agrave; page</p></li><li dir=\"ltr\"><p dir=\"ltr\">Chỉ cho ph&eacute;p gộp live giữa c&aacute;c t&agrave;i khoản c&aacute; nh&acirc;n hoặc giữa c&aacute;c live trong c&ugrave;ng một page</p></li></ul><p dir=\"ltr\">Ch&uacute;ng t&ocirc;i đang cố gắng hết sức để qu&aacute; tr&igrave;nh chuyển đổi của Facebook &iacute;t g&acirc;y ảnh hưởng nhất đến Qu&yacute; đối t&aacute;c v&agrave; kh&aacute;ch h&agrave;ng!</p><p dir=\"ltr\">Mong qu&yacute; kh&aacute;ch sắp xếp thời gian xử l&yacute; c&ocirc;ng việc v&agrave; <strong>duy tr&igrave; c&aacute;c&nbsp;</strong><strong>k&ecirc;nh b&aacute;n h&agrave;ng hoạt động b&igrave;nh thường</strong> để ch&uacute;ng t&ocirc;i c&oacute; thể tiến h&agrave;nh bảo tr&igrave; phần mềm v&agrave;o l&uacute;c <strong>0h ng&agrave;y 17/11/2019</strong>, dự kiến thời gian ho&agrave;n th&agrave;nh bảo tr&igrave; l&agrave;<strong>&nbsp;6</strong><strong>h ng&agrave;y 17/11/2019</strong>. Ch&uacute;ng t&ocirc;i rất xin lỗi v&igrave; sự bất tiện n&agrave;y!</p><p dir=\"ltr\">Mọi th&ocirc;ng tin chi tiết, vui l&ograve;ng li&ecirc;n hệ để được th&ocirc;ng tin r&otilde; r&agrave;ng nhất!</p><p dir=\"ltr\">Hotline: <strong>090.807.5455</strong></p><p dir=\"ltr\">Hỗ trợ 24/7: <strong>1900 2852</strong></p><p dir=\"ltr\">Tr&acirc;n trọng!</p>",
          "Description":
              "Phần mềm quản lý bán hàng TPos thông báo đến Quý khách hàng và đối tác về việc thay đổi thuật toán của Facebook làm ảnh hưởng đến một số người dùng trong hệ thống phần mềm.",
          "NotificationId": null,
          "EnablePopup": false,
          "Images": null,
          "Topics": null,
          "MarkReadBy": null,
          //"DateRead": "2019-11-16T04:48:35.89Z",
          "DateCreated": "2019-11-16T03:03:00.637Z"
        }
      ]
    };

    return GetNotificationResult.fromJson(fake);
  }

  @override
  Future<bool> markRead(String key) {
    // TODO: implement markRead
    return null;
  }
}
