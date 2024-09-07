
class Etudiant {
  final String id;
  final String name;
  final String email;

  Etudiant({required this.id, required this.name, required this.email});

  factory Etudiant.fromJson(Map<String, dynamic> json) {
    
    return Etudiant(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
