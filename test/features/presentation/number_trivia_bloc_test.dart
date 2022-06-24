import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/usecases/usecase.dart';
import 'package:number_trivia/core/util/input_converter.dart';
import 'package:number_trivia/features/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/domain/usecases/concrete_number_trivia.dart';
import 'package:number_trivia/features/domain/usecases/random_number_trivia.dart';
import 'package:number_trivia/features/presentation/bloc/number_trivia_bloc.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([ConcreteNumberTrivia, RandomNumberTrivia, InputConverter])
void main() {
  MockConcreteNumberTrivia mockConcreteNumberTrivia = MockConcreteNumberTrivia();
  MockRandomNumberTrivia mockRandomNumberTrivia = MockRandomNumberTrivia();
  MockInputConverter mockInputConverter = MockInputConverter();
  NumberTriviaBloc bloc = NumberTriviaBloc(
    concrete: mockConcreteNumberTrivia,
    random: mockRandomNumberTrivia,
    inputConverter: mockInputConverter,
  );

  test('initialState should be Empty', () {
    // assert
    expect(bloc.state, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    // The event takes in a String
    final tNumberString = '1';
    // This is the successful output of the InputConverter
    final tNumberParsed = int.parse(tNumberString);
    // NumberTrivia instance is needed too, of course
    final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');
    void setUpMockInputConverterSuccess() =>
        when(mockInputConverter.stringToUnsignedInteger(any)).thenReturn(Right(tNumberParsed));
    void setUpMockInputConverterFailure() =>
        when(mockInputConverter.stringToUnsignedInteger(any)).thenReturn(Left(InvalidInputFailure()));

    test(
      'should call the InputConverter to validate and convert the string to an unsigned integer',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        // act
        bloc.add(ConcreteNumberTriviaEvent(tNumberString));
        await untilCalled(mockInputConverter.stringToUnsignedInteger(any));
        // assert
        verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
      },
    );

    test(
      'should emit [Error] when the input is invalid',
      () async {
        // arrange
        setUpMockInputConverterFailure();
        // assert later
        final expected = [
          // The initial state is always emitted first
          Empty(),
          Error(message: INVALID_INPUT_FAILURE_MESSAGE),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(ConcreteNumberTriviaEvent(tNumberString));
      },
    );

    test(
      'should get data from the concrete use case',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockConcreteNumberTrivia(any)).thenAnswer((_) async => Right(tNumberTrivia));
        // act
        bloc.add(ConcreteNumberTriviaEvent(tNumberString));
        await untilCalled(mockConcreteNumberTrivia);
        // assert
        verify(mockConcreteNumberTrivia(Params(number: tNumberParsed)));
      },
    );

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockConcreteNumberTrivia(any)).thenAnswer((_) async => Right(tNumberTrivia));
        // assert later
        final expected = [Loading(), Loaded(trivia: tNumberTrivia)];
        expect(bloc.state, Empty());
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(ConcreteNumberTriviaEvent(tNumberString));
      },
    );

    test(
      'should emit [Loading, Error] when getting data fails',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockConcreteNumberTrivia(any)).thenAnswer((_) async => Left(ServerFailure()));
        // assert later
        final expected = [
          Loading(),
          Error(message: SERVER_FAILURE_MESSAGE),
        ];
        expect(bloc.state, Empty());
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(ConcreteNumberTriviaEvent(tNumberString));
      },
    );

    test(
      'should emit [Loading, Error] with a proper message for the error when getting data fails',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockConcreteNumberTrivia(any)).thenAnswer((_) async => Left(CacheFailure()));
        // assert later
        final expected = [
          Loading(),
          Error(message: CACHE_FAILURE_MESSAGE),
        ];
        expect(bloc.state, Empty());
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(ConcreteNumberTriviaEvent(tNumberString));
      },
    );
  });

  group('GetTriviaForRandomNumber', () {
    final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    test(
      'should get data from the random use case',
      () async {
        // arrange
        when(mockRandomNumberTrivia(any)).thenAnswer((_) async => Right(tNumberTrivia));
        // act
        bloc.add(RandomNumberTriviaEvent());
        await untilCalled(mockRandomNumberTrivia(any));
        // assert
        verify(mockRandomNumberTrivia(NoParams()));
      },
    );

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async {
        // arrange
        when(mockRandomNumberTrivia(any)).thenAnswer((_) async => Right(tNumberTrivia));
        // assert later
        final expected = [Loading(), Loaded(trivia: tNumberTrivia)];
        expect(bloc.state, Empty());
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(RandomNumberTriviaEvent());
      },
    );

    test(
      'should emit [Loading, Error] when getting data fails',
      () async {
        // arrange
        when(mockRandomNumberTrivia(any)).thenAnswer((_) async => Left(ServerFailure()));
        // assert later
        final expected = [
          Loading(),
          Error(message: SERVER_FAILURE_MESSAGE),
        ];
        expect(bloc.state, Empty());
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(RandomNumberTriviaEvent());
      },
    );

    test(
      'should emit [Loading, Error] with a proper message for the error when getting data fails',
      () async {
        // arrange
        when(mockRandomNumberTrivia(any)).thenAnswer((_) async => Left(CacheFailure()));
        // assert later
        final expected = [
          Loading(),
          Error(message: CACHE_FAILURE_MESSAGE),
        ];
        expect(bloc.state, Empty());
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(RandomNumberTriviaEvent());
      },
    );
  });
}
