import 'package:number_trivia/features/domain/entities/number_trivia.dart';

class NumberTriviaModel extends NumberTrivia {
  final int number;
  final String text;

  NumberTriviaModel({required this.number, required this.text}) : super(number: number, text: text);

  factory NumberTriviaModel.fromJson(Map<String, dynamic> json) {
    return NumberTriviaModel(number: (json['number'] as num).toInt(), text: json['text']);
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'number': number};
  }
}
