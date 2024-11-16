import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Movie {
  final String title;
  final String overview;
  final String posterPath;
  final String releaseDate; // Ano de lançamento.
  final double voteAverage; // Classificação (de 0 a 10).

  Movie({
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.voteAverage,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'],
      overview: json['overview'],
      posterPath: 'https://image.tmdb.org/t/p/w500${json['poster_path']}',
      releaseDate: json['release_date'], // Adiciona a data de lançamento.
      voteAverage: (json['vote_average'] as num).toDouble(), // Adiciona a classificação.
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
    final apiKey = '0c2ca966bd525c7a5c934b21f02d65a5'; // Chave de API fornecida.
    final url =
        'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey&language=pt-BR&page=1';

    try {
      print('URL: $url'); // Log para verificar a URL gerada.
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Response body: ${response.body}'); // Log do corpo da resposta.
        final data = json.decode(response.body)['results'] as List<dynamic>;
        setState(() {
          _movies = data.map((movie) => Movie.fromJson(movie)).toList();
          _isLoading = false;
        });
      } else {
        print('Erro na API: ${response.statusCode}'); // Log de erro na API.
        throw Exception('Erro ao carregar filmes: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro ao carregar filmes: $error'); // Log de erros genéricos.
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
          ? Center(child: CircularProgressIndicator()) // Indicador de carregamento.
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Exibe o ano de lançamento
                        Text(
                          'Ano: ${movie.releaseDate.split('-')[0]}', // Extrai apenas o ano.
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 5),
                        // Exibe estrelas de classificação
                        Row(
                          children: List.generate(
                            5,
                            (starIndex) => Icon(
                              Icons.star,
                              size: 16,
                              color: starIndex < (movie.voteAverage / 2).round()
                                  ? Colors.amber
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        // Exibe uma breve descrição
                        Text(
                          movie.overview,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
