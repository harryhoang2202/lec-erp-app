import 'package:objectbox/objectbox.dart';
import 'dart:convert';

@Entity()
class NotificationModel {
  int id;

  @Unique()
  String messageId;

  String title;
  String body;
  String? imageUrl;

  // Store data as JSON string for ObjectBox compatibility
  String dataJson;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  bool isRead;
  String? topic;
  String? category;

  // Username của user nhận notification
  String username;

  NotificationModel({
    this.id = 0,
    required this.messageId,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.dataJson,
    required this.createdAt,
    this.isRead = false,
    this.topic,
    this.category,
    required this.username,
  });

  // Getter for data
  Map<String, dynamic> get data => json.decode(dataJson);

  // Setter for data
  set data(Map<String, dynamic> value) {
    dataJson = json.encode(value);
  }

  factory NotificationModel.fromRemoteMessage(
    dynamic message, {
    required String username,
  }) {
    final dataMap = Map<String, dynamic>.from(message.data ?? {});
    return NotificationModel(
      messageId:
          message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      imageUrl:
          message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl,
      dataJson: json.encode(dataMap),
      createdAt: DateTime.now(),
      username: username,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'messageId': messageId,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'topic': topic,
      'category': category,
      'username': username,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      messageId: json['messageId'],
      title: json['title'],
      body: json['body'],
      imageUrl: json['imageUrl'],
      dataJson: jsonEncode(json['data'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      topic: json['topic'],
      category: json['category'],
      username: json['username'] ?? '',
    );
  }
}
