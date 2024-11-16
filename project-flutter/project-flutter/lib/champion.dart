class Champion {
  final String name;
  final String title;
  final String imageUrl;

  Champion({
    required this.name,
    required this.title,
    required this.imageUrl,
  });

  factory Champion.fromJson(Map<String, dynamic> json) {
    return Champion(
      name: json['name'],
      title: json['title'],
      imageUrl: 'https://ddragon.leagueoflegends.com/cdn/13.6.1/img/champion/${json['id']}.png',
    );
  }
}
