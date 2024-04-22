class Note {
  String id, title, description;

  Note({
    required this.id,
    required this.title,
    required this.description,
  });

  static Map<String, dynamic> toMap(Note note) {
    return {
      'id': note.id,
      'title': note.title,
      'description': note.description,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
