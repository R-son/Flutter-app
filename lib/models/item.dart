class Item {
  final int? id;
  final String name;
  final String description;
  final double rating;
  final String? image;
  final String? category;

  Item(
      {this.id,
      required this.name,
      required this.description,
      required this.rating,
      this.image,
      this.category});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      rating: (json['rating'] as num).toDouble(),
      image: json['image'],
    );
  }
}
