import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Movie {
  final String title;
  final String overview;
  final String posterPath;

  Movie({
    required this.title,
    required this.overview,
    required this.posterPath,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'],
      overview: json['overview'],
      posterPath: 'https://image.tmdb.org/t/p/w500${json['poster_path']}',
    );
  }
}

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  List<Movie> _movies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    final apiKey = 'SUA_API_KEY'; // Substitua pela sua chave de API da TMDB.
    final url =
        'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey&language=pt-BR&page=1';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['results'] as List<dynamic>;
        setState(() {
          _movies = data.map((movie) => Movie.fromJson(movie)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Erro ao carregar filmes: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro ao carregar filmes: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Filmes'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _movies.length,
              itemBuilder: (context, index) {
                final movie = _movies[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Image.network(
                      movie.posterPath,
                      fit: BoxFit.cover,
                      width: 50,
                    ),
                    title: Text(movie.title),
                    subtitle: Text(
                      movie.overview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
