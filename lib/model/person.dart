class Person {
  final int id;
  final String title, description;

  Person({
    required this.id,
    required this.title,
    required this.description,
  });

  factory Person.getNewEmpty() {
    return Person(
      id: 0,
      title: "Title...",
      description: 'Description...',
    );
  }

  factory Person.fromMap(Map<dynamic, dynamic> map) {
    return Person(
      id: map['id'] ?? 0,
      title: map['title'] ?? "Title...",
      description: map['description'] ?? 'Description...',
    );
  }
}
