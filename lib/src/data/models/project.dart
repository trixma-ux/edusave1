class Project {
  final int? id;
  final String title;
  final String program; // CLAC, IFADEM, ELAN, Autre
  final String status; // PLANIFIE, EN_COURS, TERMINE, CLOTURE
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Project({
    this.id, 
    required this.title, 
    required this.program, 
    required this.status, 
    this.description, 
    this.startDate, 
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromMap(Map<String, Object?> map) => Project(
        id: map['id'] as int?,
        title: map['title'] as String,
        program: map['program'] as String,
        status: map['status'] as String,
        description: map['description'] as String?,
        startDate: (map['startDate'] as String?) != null ? DateTime.parse(map['startDate'] as String) : null,
        endDate: (map['endDate'] as String?) != null ? DateTime.parse(map['endDate'] as String) : null,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as int?,
        title: json['title'] as String,
        program: json['program'] as String,
        status: json['status'] as String,
        description: json['description'] as String?,
        startDate: json['startDate'] != null ? DateTime.parse(json['startDate'] as String) : null,
        endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'program': program,
        'status': status,
        'description': description,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'program': program,
        'status': status,
        'description': description,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
