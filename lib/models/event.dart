class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String imageUrl;
  final String category;
  final bool isNotificationEnabled;
  final List<String> tags;
  final String organizerName;
  final double? price;
  final int maxAttendees;
  final int currentAttendees;
  final String? signUpUrl;
  final String? details;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.imageUrl,
    required this.category,
    this.isNotificationEnabled = false,
    this.tags = const [],
    required this.organizerName,
    this.price,
    this.maxAttendees = 0,
    this.currentAttendees = 0,
    this.signUpUrl,
    this.details,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'location': location,
        'imageUrl': imageUrl,
        'category': category,
        'isNotificationEnabled': isNotificationEnabled,
        'tags': tags,
        'organizerName': organizerName,
        'price': price,
        'maxAttendees': maxAttendees,
        'currentAttendees': currentAttendees,
        'signUpUrl': signUpUrl,
        'details': details,
      };

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        location: json['location'],
        imageUrl: json['imageUrl'],
        category: json['category'],
        isNotificationEnabled: json['isNotificationEnabled'] ?? false,
        tags: List<String>.from(json['tags'] ?? []),
        organizerName: json['organizerName'],
        price: json['price']?.toDouble(),
        maxAttendees: json['maxAttendees'] ?? 0,
        currentAttendees: json['currentAttendees'] ?? 0,
        signUpUrl: json['signUpUrl'],
        details: json['details'],
      );

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? imageUrl,
    String? category,
    bool? isNotificationEnabled,
    List<String>? tags,
    String? organizerName,
    double? price,
    int? maxAttendees,
    int? currentAttendees,
    String? signUpUrl,
    String? details,
  }) =>
      Event(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        location: location ?? this.location,
        imageUrl: imageUrl ?? this.imageUrl,
        category: category ?? this.category,
        isNotificationEnabled: isNotificationEnabled ?? this.isNotificationEnabled,
        tags: tags ?? this.tags,
        organizerName: organizerName ?? this.organizerName,
        price: price ?? this.price,
        maxAttendees: maxAttendees ?? this.maxAttendees,
        currentAttendees: currentAttendees ?? this.currentAttendees,
        signUpUrl: signUpUrl ?? this.signUpUrl,
        details: details ?? this.details,
      );
}
