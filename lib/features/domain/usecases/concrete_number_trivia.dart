import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/usecases/usecase.dart';
import 'package:number_trivia/features/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/domain/repositories/number_trivia_repository.dart';

class ConcreteNumberTrivia implements UseCase<NumberTrivia, Params> {
  final NumberTriviaRepository numberTriviaRepository;

  ConcreteNumberTrivia(this.numberTriviaRepository);

  @override
  Future<Either<Failure, NumberTrivia>> call(Params params) async {
    return await numberTriviaRepository.getConcreteNumberTrivia(params.number);
  }
}

class Params extends Equatable {
  final int number;

  Params({required this.number}) : super();

  @override
  List<Object?> get props => [number];
}
