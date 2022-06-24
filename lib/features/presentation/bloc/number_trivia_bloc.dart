import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:number_trivia/core/usecases/usecase.dart';

import '../../../core/error/failures.dart';
import '../../../core/util/input_converter.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/usecases/concrete_number_trivia.dart';
import '../../domain/usecases/random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE = 'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final ConcreteNumberTrivia concrete;
  final RandomNumberTrivia random;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.concrete,
    required this.random,
    required this.inputConverter,
  }) : super(Empty()) {
    on<NumberTriviaEvent>(onNumberTriviaEvent);
  }

  onNumberTriviaEvent(NumberTriviaEvent event, Emitter<NumberTriviaState> emit) async {
    if (event is ConcreteNumberTriviaEvent) {
      final inputEither = inputConverter.stringToUnsignedInteger(event.numberString);

      inputEither.fold((failure) => emit(Error(message: INVALID_INPUT_FAILURE_MESSAGE)), (integer) async {
        emit(Loading());
        final failureOrTrivia = await concrete(Params(number: integer));
        _eitherLoadedOrErrorState(failureOrTrivia);
      });
    } else if (event is RandomNumberTriviaEvent) {
      emit(Loading());
      final failureOrTrivia = await random(NoParams());
      _eitherLoadedOrErrorState(failureOrTrivia);
    }
  }

  void _eitherLoadedOrErrorState(Either<Failure, NumberTrivia> either) async {
    either.fold(
      (failure) => emit(Error(message: _mapFailureToMessage(failure))),
      (trivia) => emit(Loaded(trivia: trivia)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    // Instead of a regular 'if (failure is ServerFailure)...'
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected Error';
    }
  }
}
