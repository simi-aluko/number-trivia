import 'package:dartz/dartz.dart';
import 'package:number_trivia/features/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/domain/repositories/number_trivia_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/features/domain/usecases/concrete_number_trivia.dart';
import 'package:mockito/annotations.dart';

import 'concrete_number_trivia_test.mocks.dart';

@GenerateMocks([NumberTriviaRepository])
void main() {
  final mockNumberTriviaRepository = MockNumberTriviaRepository();
  final usecase = ConcreteNumberTrivia(mockNumberTriviaRepository);
  final tNumber = 1;
  final tNumberTrivia = NumberTrivia(text: "test", number: 1);

  test("should get trivia for the number from the repository", () async {
    // arrange
    when(mockNumberTriviaRepository.getConcreteNumberTrivia(1))
        .thenAnswer((_) async => Right(tNumberTrivia));

    // act
    final result = await usecase(Params(number: tNumber));

    // assert
    expect(result, Right(tNumberTrivia));
    verify(mockNumberTriviaRepository.getConcreteNumberTrivia(tNumber));
    verifyNoMoreInteractions(mockNumberTriviaRepository);
  });
}
