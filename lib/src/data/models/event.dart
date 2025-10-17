class Event {
  final int? id;
  final String title;
  final String? location;
  final String? description;
  final DateTime date;
  final int? projectId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    this.id, 
    required this.title, 
    this.location, 
    this.description, 
    required this.date, 
    this.projectId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromMap(Map<String, Object?> map) => Event(
        id: map['id'] as int?,
        title: map['title'] as String,
        location: map['location'] as String?,
        description: map['description'] as String?,
        date: DateTime.parse(map['date'] as String),
        projectId: map['projectId'] as int?,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['id'] as int?,
        title: json['title'] as String,
        location: json['location'] as String?,
        description: json['description'] as String?,
        date: DateTime.parse(json['date'] as String),
        projectId: json['projectId'] as int?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'location': location,
        'description': description,
        'date': date.toIso8601String(),
        'projectId': projectId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'location': location,
        'description': description,
        'date': date.toIso8601String(),
        'projectId': projectId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
