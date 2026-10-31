import 'package:flutter/foundation.dart';

import '../../core/utils/id_generator.dart';

/// One row of a checklist note.
@immutable
final class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.text,
    this.isDone = false,
  });

  factory ChecklistItem.create([String text = '']) =>
      ChecklistItem(id: IdGenerator.next(), text: text);

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
    id: json['id'] as String,
    text: json['text'] as String? ?? '',
    isDone: json['done'] as bool? ?? false,
  );

  final String id;
  final String text;
  final bool isDone;

  bool get isBlank => text.trim().isEmpty;

  ChecklistItem copyWith({String? text, bool? isDone}) => ChecklistItem(
    id: id,
    text: text ?? this.text,
    isDone: isDone ?? this.isDone,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'text': text,
    'done': isDone,
  };

  @override
  bool operator ==(Object other) =>
      other is ChecklistItem &&
      other.id == id &&
      other.text == text &&
      other.isDone == isDone;

  @override
  int get hashCode => Object.hash(id, text, isDone);
}
