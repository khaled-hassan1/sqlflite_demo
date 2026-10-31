import 'package:flutter/foundation.dart';

import '../../core/utils/id_generator.dart';
import 'attachment.dart';
import 'checklist_item.dart';
import 'note_color.dart';

/// Where a note currently lives.
enum NoteStatus {
  active,
  archived,
  trashed;

  static NoteStatus fromName(String? name) => values.firstWhere(
    (NoteStatus s) => s.name == name,
    orElse: () => NoteStatus.active,
  );
}

/// Immutable note entity. Every change produces a new instance through
/// [copyWith], which lets `Selector`s compare by identity cheaply.
@immutable
final class Note {
  const Note({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.sortOrder,
    this.title = '',
    this.content = '',
    this.color = NoteColor.none,
    this.status = NoteStatus.active,
    this.isPinned = false,
    this.isChecklist = false,
    this.checklist = const <ChecklistItem>[],
    this.attachments = const <Attachment>[],
    this.tags = const <String>[],
  });

  factory Note.create({bool isChecklist = false}) {
    final DateTime now = DateTime.now();
    return Note(
      id: IdGenerator.next(),
      createdAt: now,
      updatedAt: now,
      sortOrder: now.millisecondsSinceEpoch.toDouble(),
      isChecklist: isChecklist,
      checklist: isChecklist
          ? <ChecklistItem>[ChecklistItem.create()]
          : const <ChecklistItem>[],
    );
  }

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    content: json['content'] as String? ?? '',
    color: NoteColor.fromName(json['color'] as String?),
    status: NoteStatus.fromName(json['status'] as String?),
    isPinned: json['pinned'] as bool? ?? false,
    isChecklist: json['checklist'] as bool? ?? false,
    checklist: _list(json['items'], ChecklistItem.fromJson),
    attachments: _list(json['attachments'], Attachment.fromJson),
    tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const <String>[],
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      (json['created'] as num).toInt(),
    ),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      (json['updated'] as num).toInt(),
    ),
    // Notes saved before manual ordering existed keep their date order.
    sortOrder: ((json['order'] ?? json['updated']) as num).toDouble(),
  );

  final String id;
  final String title;
  final String content;
  final NoteColor color;
  final NoteStatus status;
  final bool isPinned;
  final bool isChecklist;
  final List<ChecklistItem> checklist;
  final List<Attachment> attachments;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Manual position (drag & drop). Higher values are shown first.
  final double sortOrder;

  bool get isActive => status == NoteStatus.active;
  bool get isArchived => status == NoteStatus.archived;
  bool get isTrashed => status == NoteStatus.trashed;

  Iterable<Attachment> get visuals =>
      attachments.where((Attachment a) => a.type.isVisual);
  Iterable<Attachment> get audios =>
      attachments.where((Attachment a) => a.type == AttachmentType.audio);
  Iterable<Attachment> get files =>
      attachments.where((Attachment a) => a.type == AttachmentType.file);

  bool get hasAudio =>
      attachments.any((Attachment a) => a.type == AttachmentType.audio);
  bool get hasDrawing =>
      attachments.any((Attachment a) => a.type == AttachmentType.drawing);
  bool get hasMedia => attachments.any(
    (Attachment a) =>
        a.type == AttachmentType.image || a.type == AttachmentType.file,
  );

  /// A note with nothing worth keeping.
  bool get isEmpty =>
      title.trim().isEmpty &&
      content.trim().isEmpty &&
      attachments.isEmpty &&
      checklist.every((ChecklistItem i) => i.isBlank);

  Note copyWith({
    String? title,
    String? content,
    NoteColor? color,
    NoteStatus? status,
    bool? isPinned,
    bool? isChecklist,
    List<ChecklistItem>? checklist,
    List<Attachment>? attachments,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? sortOrder,
    String? id,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      status: status ?? this.status,
      isPinned: isPinned ?? this.isPinned,
      isChecklist: isChecklist ?? this.isChecklist,
      checklist: checklist ?? this.checklist,
      attachments: attachments ?? this.attachments,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'content': content,
    'color': color.name,
    'status': status.name,
    'pinned': isPinned,
    'checklist': isChecklist,
    'items': checklist
        .map((ChecklistItem i) => i.toJson())
        .toList(growable: false),
    'attachments': attachments
        .map((Attachment a) => a.toJson())
        .toList(growable: false),
    'tags': tags,
    'created': createdAt.millisecondsSinceEpoch,
    'updated': updatedAt.millisecondsSinceEpoch,
    'order': sortOrder,
  };

  static List<T> _list<T>(Object? raw, T Function(Map<String, dynamic>) parse) {
    if (raw is! List<dynamic>) return List<T>.empty();
    return List<T>.unmodifiable(
      raw.whereType<Map<dynamic, dynamic>>().map(
        (Map<dynamic, dynamic> m) => parse(m.cast<String, dynamic>()),
      ),
    );
  }
}
