class NotificationPreference {
  final String eventId;
  final bool isEnabled;
  final Duration notifyBefore;
  final String type;

  NotificationPreference({
    required this.eventId,
    required this.isEnabled,
    required this.notifyBefore,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'isEnabled': isEnabled,
    'notifyBefore': notifyBefore.inMinutes,
    'type': type,
  };

  factory NotificationPreference.fromJson(Map<String, dynamic> json) =>
      NotificationPreference(
        eventId: json['eventId'],
        isEnabled: json['isEnabled'],
        notifyBefore: Duration(minutes: json['notifyBefore']),
        type: json['type'],
      );
}