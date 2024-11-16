import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'champion_detail_screen.dart';

class Champion {
  final String name;
  final String title;
  final String imageUrl;
  final List<String> roles;
  final int difficulty;
  bool isFavorite;

  Champion({
    required this.name,
    required this.title,
    required this.imageUrl,
    required this.roles,
    required this.difficulty,
    this.isFavorite = false,
  });

  factory Champion.fromJson(Map<String, dynamic> json) {
    return Champion(
      name: json['name'],
      title: json['title'],
      imageUrl: 'https://ddragon.leagueoflegends.com/cdn/13.6.1/img/champion/${json['id']}.png',
      roles: List<String>.from(json['tags']),
      difficulty: json['info']['difficulty'],
    );
  }
}

class ChampionListScreen extends StatefulWidget {
  @override
  _ChampionListScreenState createState() => _ChampionListScreenState();
}

class _ChampionListScreenState extends State<ChampionListScreen> {
  List<Champion> _champions = [];
  List<Champion> _filteredChampions = [];
  bool _isLoading = true;
  String _searchQuery = "";
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    fetchChampions();
  }

  Future<void> fetchChampions() async {
    final response = await http.get(Uri.parse(
        'https://ddragon.leagueoflegends.com/cdn/13.6.1/data/en_US/champion.json'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as Map<String, dynamic>;
      final champions = data.values
          .map((champ) => Champion.fromJson(champ))
          .toList();

      setState(() {
        _champions = champions;
        _filteredChampions = champions;
        _isLoading = false;
      });

      _loadFavorites();
    } else {
      throw Exception('Erro ao carregar os campeões');
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteNames = prefs.getStringList('favorites') ?? [];

    setState(() {
      for (var champ in _champions) {
        champ.isFavorite = favoriteNames.contains(champ.name);
      }
    });
  }

  Future<void> _toggleFavorite(Champion champion) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      champion.isFavorite = !champion.isFavorite;
    });

    final favoriteNames = _champions
        .where((champ) => champ.isFavorite)
        .map((champ) => champ.name)
        .toList();

    await prefs.setStringList('favorites', favoriteNames);
  }

  void _filterChampions(String query) {
    setState(() {
      _searchQuery = query;
      _filteredChampions = _champions
          .where((champ) =>
              champ.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Campeões'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar campeões...',
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
              onChanged: _filterChampions,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _isGridView
              ? GridView.builder(
                  padding: EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.75, 
                  ),
                  itemCount: _filteredChampions.length,
                  itemBuilder: (context, index) {
                    final champion = _filteredChampions[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChampionDetailScreen(champion: champion),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4.0,
                        child: Column(
                          children: [
                            Expanded(
                              child: Image.network(
                                champion.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    champion.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16), 
                                  ),
                                  Text(
                                    champion.title,
                                    style: TextStyle(fontSize: 14), 
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : ListView.builder(
                  itemCount: _filteredChampions.length,
                  itemBuilder: (context, index) {
                    final champion = _filteredChampions[index];
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: Image.network(champion.imageUrl),
                        title: Text(champion.name),
                        subtitle: Text(champion.title),
                        trailing: IconButton(
                          icon: Icon(
                            champion.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: champion.isFavorite ? Colors.red : null,
                          ),
                          onPressed: () {
                            _toggleFavorite(champion);
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChampionDetailScreen(champion: champion),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
