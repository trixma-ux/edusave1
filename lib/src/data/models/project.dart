class Project {
  final int? id;
  final String title;
  final String program; // CLAC, IFADEM, ELAN, Autre
  final String status; // PLANIFIE, EN_COURS, TERMINE, CLOTURE
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;

  const Project({this.id, required this.title, required this.program, required this.status, this.description, this.startDate, this.endDate});

  factory Project.fromMap(Map<String, Object?> map) => Project(
        id: map['id'] as int?,
        title: map['title'] as String,
        program: map['program'] as String,
        status: map['status'] as String,
        description: map['description'] as String?,
        startDate: (map['startDate'] as String?) != null ? DateTime.parse(map['startDate'] as String) : null,
        endDate: (map['endDate'] as String?) != null ? DateTime.parse(map['endDate'] as String) : null,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'program': program,
        'status': status,
        'description': description,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
      };
}
