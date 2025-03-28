import 'package:flutter/material.dart';
import 'package:mini_games_alif/core/constants.dart';
import 'package:mini_games_alif/data/models.dart';
import 'package:mini_games_alif/data/repositories.dart';

class NumberLineScreen extends StatefulWidget {
  @override
  _NumberLineScreenState createState() => _NumberLineScreenState();
}

class _NumberLineScreenState extends State<NumberLineScreen> {
  final NumberRepository _repository = NumberRepository();
  List<int> _numbers = [];

  @override
  void initState() {
    super.initState();
    _numbers = _repository.getNumbersInRange(0, 20); // Example range
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Constants.appTitle),
      ),
      body: Center(
        child: Column(
          children: [
            Text("Find Numbers on a Line (0-20)"),
            Expanded(
              child: ListView.builder(
                itemCount: _numbers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_numbers[index].toString()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
