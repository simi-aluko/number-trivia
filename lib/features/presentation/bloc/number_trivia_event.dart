part of 'number_trivia_bloc.dart';

abstract class NumberTriviaEvent extends Equatable {
  const NumberTriviaEvent();

  @override
  List<Object?> get props => [];
}

class ConcreteNumberTriviaEvent extends NumberTriviaEvent {
  final String numberString;

  ConcreteNumberTriviaEvent(this.numberString);
}

class RandomNumberTriviaEvent extends NumberTriviaEvent {}
