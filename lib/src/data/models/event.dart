class EventModel {
  final int? id;
  final String title;
  final String? location;
  final String? description;
  final DateTime date;
  final int? projectId;

  const EventModel({this.id, required this.title, this.location, this.description, required this.date, this.projectId});

  factory EventModel.fromMap(Map<String, Object?> map) => EventModel(
        id: map['id'] as int?,
        title: map['title'] as String,
        location: map['location'] as String?,
        description: map['description'] as String?,
        date: DateTime.parse(map['date'] as String),
        projectId: map['projectId'] as int?,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'location': location,
        'description': description,
        'date': date.toIso8601String(),
        'projectId': projectId,
      };
}
