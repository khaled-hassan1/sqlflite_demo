import 'package:flutter/foundation.dart';

/// Kind of media stored with a note.
enum AttachmentType {
  image,
  drawing,
  audio,
  file;

  bool get isVisual => this == image || this == drawing;

  static AttachmentType fromName(String? name) => values.firstWhere(
    (AttachmentType t) => t.name == name,
    orElse: () => AttachmentType.file,
  );
}

/// A media file copied into the app's private media folder.
///
/// Only the [fileName] (relative to the media folder) is persisted, so the
/// data survives app-directory changes and backup restores.
@immutable
final class Attachment {
  const Attachment({
    required this.id,
    required this.type,
    required this.fileName,
    required this.displayName,
    required this.sizeBytes,
    required this.createdAt,
    this.durationMs,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
    id: json['id'] as String,
    type: AttachmentType.fromName(json['type'] as String?),
    fileName: json['file'] as String,
    displayName: json['name'] as String? ?? '',
    sizeBytes: (json['size'] as num?)?.toInt() ?? 0,
    durationMs: (json['duration'] as num?)?.toInt(),
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      (json['created'] as num?)?.toInt() ?? 0,
    ),
  );

  final String id;
  final AttachmentType type;
  final String fileName;
  final String displayName;
  final int sizeBytes;
  final int? durationMs;
  final DateTime createdAt;

  Duration get duration => Duration(milliseconds: durationMs ?? 0);

  /// Lower-case extension without the dot, e.g. `pdf`.
  String get extension {
    final int dot = displayName.lastIndexOf('.');
    return dot < 0 ? '' : displayName.substring(dot + 1).toLowerCase();
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'type': type.name,
    'file': fileName,
    'name': displayName,
    'size': sizeBytes,
    if (durationMs != null) 'duration': durationMs,
    'created': createdAt.millisecondsSinceEpoch,
  };

  @override
  bool operator ==(Object other) =>
      other is Attachment && other.id == id && other.fileName == fileName;

  @override
  int get hashCode => Object.hash(id, fileName);
}
