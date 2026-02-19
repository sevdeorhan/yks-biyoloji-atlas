import '../../domain/entities/topic.dart';
import '../../domain/entities/region.dart';

class TopicModel extends Topic {
  const TopicModel({
    required super.id,
    required super.title,
    required super.description,
    required super.grade,
    required super.svgPath,
    required super.regions,
    required super.totalQuestions,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      grade: json['grade'] as String,
      svgPath: json['svg_path'] as String,
      regions: (json['regions'] as List<dynamic>?)
              ?.map((r) => Region(
                    id: r['id'] as String,
                    label: r['label'] as String,
                    description: r['description'] as String,
                    svgElementId: r['svg_element_id'] as String,
                    x: (r['x'] as num).toDouble(),
                    y: (r['y'] as num).toDouble(),
                  ))
              .toList() ??
          [],
      totalQuestions: json['total_questions'] as int? ?? 0,
    );
  }
}
