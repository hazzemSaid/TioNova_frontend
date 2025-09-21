import 'package:equatable/equatable.dart';

class SummaryResponse extends Equatable {
  final bool success;
  final String message;
  final SummaryModel summary;
  final SummaryModelData summaryModel;

  const SummaryResponse({
    required this.success,
    required this.message,
    required this.summary,
    required this.summaryModel,
  });

  factory SummaryResponse.fromJson(Map<String, dynamic> json) {
    return SummaryResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      summary: _parseSummary(json['summary']),
      summaryModel: _parseSummaryModelData(json['summaryModel']),
    );
  }

  static SummaryModel _parseSummary(dynamic summaryData) {
    if (summaryData == null) {
      return const SummaryModel(
        keyConcepts: [],
        examples: [],
        professionalImplications: [],
      );
    }
    if (summaryData is Map<String, dynamic>) {
      return SummaryModel.fromJson(summaryData);
    }
    return const SummaryModel(
      keyConcepts: [],
      examples: [],
      professionalImplications: [],
    );
  }

  static SummaryModelData _parseSummaryModelData(dynamic modelData) {
    if (modelData == null) {
      return SummaryModelData(
        chapterId: '',
        summary: const SummaryModel(
          keyConcepts: [],
          examples: [],
          professionalImplications: [],
        ),
        id: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 0,
      );
    }
    if (modelData is Map<String, dynamic>) {
      return SummaryModelData.fromJson(modelData);
    }
    return SummaryModelData(
      chapterId: '',
      summary: const SummaryModel(
        keyConcepts: [],
        examples: [],
        professionalImplications: [],
      ),
      id: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      version: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'summary': summary.toJson(),
      'summaryModel': summaryModel.toJson(),
    };
  }

  @override
  List<Object> get props => [success, message, summary, summaryModel];
}

class SummaryModelData extends Equatable {
  final String chapterId;
  final SummaryModel summary;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  const SummaryModelData({
    required this.chapterId,
    required this.summary,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory SummaryModelData.fromJson(Map<String, dynamic> json) {
    return SummaryModelData(
      chapterId: json['chapterId'] as String? ?? '',
      summary: _parseSummaryFromModelData(json['summary']),
      id: json['_id'] as String? ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      version: json['__v'] as int? ?? 0,
    );
  }

  static SummaryModel _parseSummaryFromModelData(dynamic summaryData) {
    if (summaryData == null) {
      return const SummaryModel(
        keyConcepts: [],
        examples: [],
        professionalImplications: [],
      );
    }
    if (summaryData is Map<String, dynamic>) {
      return SummaryModel.fromJson(summaryData);
    }
    return const SummaryModel(
      keyConcepts: [],
      examples: [],
      professionalImplications: [],
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'chapterId': chapterId,
      'summary': summary.toJson(),
      '_id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }

  @override
  List<Object> get props => [
    chapterId,
    summary,
    id,
    createdAt,
    updatedAt,
    version,
  ];
}

class SummaryModel extends Equatable {
  final List<KeyConcept> keyConcepts;
  final List<Example> examples;
  final List<ProfessionalImplication> professionalImplications;

  const SummaryModel({
    required this.keyConcepts,
    required this.examples,
    required this.professionalImplications,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    try {
      return SummaryModel(
        keyConcepts: _parseKeyConcepts(json['key_concepts']),
        examples: _parseExamples(json['examples']),
        professionalImplications: _parseProfessionalImplications(
          json['professional_implications'],
        ),
      );
    } catch (e) {
      // Return empty summary if parsing fails
      return const SummaryModel(
        keyConcepts: [],
        examples: [],
        professionalImplications: [],
      );
    }
  }

  static List<KeyConcept> _parseKeyConcepts(dynamic data) {
    if (data == null || data is! List) return [];
    return data
        .where((item) => item != null && item is Map<String, dynamic>)
        .map((item) => KeyConcept.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static List<Example> _parseExamples(dynamic data) {
    if (data == null || data is! List) return [];
    return data
        .where((item) => item != null && item is Map<String, dynamic>)
        .map((item) => Example.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static List<ProfessionalImplication> _parseProfessionalImplications(
    dynamic data,
  ) {
    if (data == null || data is! List) return [];
    return data
        .where((item) => item != null && item is Map<String, dynamic>)
        .map(
          (item) =>
              ProfessionalImplication.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'key_concepts': keyConcepts.map((concept) => concept.toJson()).toList(),
      'examples': examples.map((example) => example.toJson()).toList(),
      'professional_implications': professionalImplications
          .map((implication) => implication.toJson())
          .toList(),
    };
  }

  @override
  List<Object> get props => [keyConcepts, examples, professionalImplications];
}

class KeyConcept extends Equatable {
  final String title;
  final String text;
  final List<String> tags;
  final String difficultyLevel;

  const KeyConcept({
    required this.title,
    required this.text,
    required this.tags,
    required this.difficultyLevel,
  });

  factory KeyConcept.fromJson(Map<String, dynamic> json) {
    return KeyConcept(
      title: _parseString(json['title']),
      text: _parseString(json['text']),
      tags: _parseStringList(json['tags']),
      difficultyLevel: _parseString(
        json['difficulty_level'],
        defaultValue: 'medium',
      ),
    );
  }

  static String _parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    return value.toString();
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null || value is! List) return [];
    return value
        .where((item) => item != null)
        .map((item) => item.toString())
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'text': text,
      'tags': tags,
      'difficulty_level': difficultyLevel,
    };
  }

  @override
  List<Object> get props => [title, text, tags, difficultyLevel];
}

class Example extends Equatable {
  final String concept;
  final String example;
  final String notes;

  const Example({
    required this.concept,
    required this.example,
    required this.notes,
  });

  factory Example.fromJson(Map<String, dynamic> json) {
    return Example(
      concept: _parseString(json['concept']),
      example: _parseString(json['example']),
      notes: _parseString(json['notes']),
    );
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return {'concept': concept, 'example': example, 'notes': notes};
  }

  @override
  List<Object> get props => [concept, example, notes];
}

class ProfessionalImplication extends Equatable {
  final String title;
  final String text;

  const ProfessionalImplication({required this.title, required this.text});

  factory ProfessionalImplication.fromJson(Map<String, dynamic> json) {
    return ProfessionalImplication(
      title: _parseString(json['title']),
      text: _parseString(json['text']),
    );
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'text': text};
  }

  @override
  List<Object> get props => [title, text];
}
