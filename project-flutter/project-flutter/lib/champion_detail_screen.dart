import 'package:flutter/material.dart';
import 'champion_list_screen.dart';

class ChampionDetailScreen extends StatelessWidget {
  final Champion champion;

  ChampionDetailScreen({required this.champion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(champion.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do campeão
            Center(
              child: Image.network(
                champion.imageUrl,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),

            // Nome do campeão
            Text(
              'Nome: ${champion.name}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Título do campeão
            Text(
              'Título: ${champion.title}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),

            // Funções (roles)
            Text(
              'Funções:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: champion.roles
                  .map((role) => Chip(
                        label: Text(role),
                        backgroundColor: Colors.blue.shade100,
                      ))
                  .toList(),
            ),
            SizedBox(height: 20),

            // Dificuldade
            Text(
              'Dificuldade:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: champion.difficulty, // Dificuldade do campeão
                  child: Container(
                    height: 10,
                    color: Colors.red,
                  ),
                ),
                Expanded(
                  flex: 10 - champion.difficulty, // Restante da barra
                  child: Container(
                    height: 10,
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              '${champion.difficulty} / 10', // Exibe o valor numérico
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
