import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/network/network_info.dart';
import 'package:number_trivia/features/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia/features/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia/features/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/data/repositories/number_trivia_repository_impl.dart';
import 'package:number_trivia/features/domain/entities/number_trivia.dart';

import 'number_trivia_repository_impl_test.mocks.dart';

@GenerateMocks([NetworkInfo, NumberTriviaLocalDataSource, NumberTriviaRemoteDataSource])
void main() {
  final mockNetworkInfo = MockNetworkInfo();
  final mockNumberTriviaLocalDS = MockNumberTriviaLocalDataSource();
  final mockNumberTriviaRemoteDS = MockNumberTriviaRemoteDataSource();
  final repository = NumberTriviaRepositoryImpl(
      networkInfo: mockNetworkInfo,
      localDataSource: mockNumberTriviaLocalDS,
      remoteDataSource: mockNumberTriviaRemoteDS);

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  group("getConcreteNumberTrivia", () {
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel(number: tNumber, text: "test");
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test("should check if the device is online", () async {
      //arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockNumberTriviaRemoteDS.getConcreteNumberTrivia(1)).thenAnswer((_) async => tNumberTriviaModel);

      //act
      repository.getConcreteNumberTrivia(tNumber);

      //assert
      verify(mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test("should return remote data when the call to remote data source is success", () async {
        //arrange
        when(mockNumberTriviaRemoteDS.getConcreteNumberTrivia(1)).thenAnswer((_) async => tNumberTriviaModel);
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verify(mockNumberTriviaRemoteDS.getConcreteNumberTrivia(tNumber));
        expect(result, equals(Right(tNumberTrivia)));
      });

      test("should cache remote data locally when the call to remote data source is success", () async {
        //arrange
        when(mockNumberTriviaRemoteDS.getConcreteNumberTrivia(1)).thenAnswer((_) async => tNumberTriviaModel);
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verify(mockNumberTriviaRemoteDS.getConcreteNumberTrivia(tNumber));
        verify(mockNumberTriviaLocalDS.cacheNumberTrivia(tNumberTriviaModel));
        expect(result, equals(Right(tNumberTrivia)));
      });

      test("should return server failure when the call to remote data source is unsuccessful", () async {
        //arrange
        reset(mockNumberTriviaLocalDS);
        when(mockNumberTriviaRemoteDS.getConcreteNumberTrivia(tNumber)).thenThrow(ServerException());
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verify(mockNumberTriviaRemoteDS.getConcreteNumberTrivia(tNumber));
        verifyZeroInteractions(mockNumberTriviaLocalDS);
        expect(result, equals(Left(ServerFailure())));
      });
    });

    runTestsOffline(() {
      test("should return locally cached data when the cached data is present", () async {
        // arrange
        reset(mockNumberTriviaRemoteDS);
        when(mockNumberTriviaLocalDS.getLastNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verifyZeroInteractions(mockNumberTriviaRemoteDS);
        verify(mockNumberTriviaLocalDS.getLastNumberTrivia());
        expect(result, equals(Right(tNumberTrivia)));
      });

      test("should return cache failure when there is no cache data present", () async {
        // arrange
        reset(mockNumberTriviaRemoteDS);
        when(mockNumberTriviaLocalDS.getLastNumberTrivia()).thenThrow(CacheException());
        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verifyZeroInteractions(mockNumberTriviaRemoteDS);
        verify(mockNumberTriviaLocalDS.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure())));
      });
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(number: 123, text: 'test trivia');
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test('should check if the device is online', () {
      //arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockNumberTriviaRemoteDS.getRandomNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
      // act
      repository.getRandomNumberTrivia();
      // assert
      verify(mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test(
        'should return remote data when the call to remote data source is successful',
        () async {
          // arrange
          when(mockNumberTriviaRemoteDS.getRandomNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
          // act
          final result = await repository.getRandomNumberTrivia();
          // assert
          verify(mockNumberTriviaRemoteDS.getRandomNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should cache the data locally when the call to remote data source is successful',
        () async {
          // arrange
          when(mockNumberTriviaRemoteDS.getRandomNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
          // act
          await repository.getRandomNumberTrivia();
          // assert
          verify(mockNumberTriviaRemoteDS.getRandomNumberTrivia());
          verify(mockNumberTriviaLocalDS.cacheNumberTrivia(tNumberTriviaModel));
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
        () async {
          // arrange
          reset(mockNumberTriviaLocalDS);
          when(mockNumberTriviaRemoteDS.getRandomNumberTrivia()).thenThrow(ServerException());
          // act
          final result = await repository.getRandomNumberTrivia();
          // assert
          verify(mockNumberTriviaRemoteDS.getRandomNumberTrivia());
          verifyZeroInteractions(mockNumberTriviaLocalDS);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      test(
        'should return last locally cached data when the cached data is present',
        () async {
          // arrange
          reset(mockNumberTriviaRemoteDS);
          when(mockNumberTriviaLocalDS.getLastNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
          // act
          final result = await repository.getRandomNumberTrivia();
          // assert
          verifyZeroInteractions(mockNumberTriviaRemoteDS);
          verify(mockNumberTriviaLocalDS.getLastNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should return CacheFailure when there is no cached data present',
        () async {
          // arrange
          reset(mockNumberTriviaRemoteDS);
          when(mockNumberTriviaLocalDS.getLastNumberTrivia()).thenThrow(CacheException());
          // act
          final result = await repository.getRandomNumberTrivia();
          // assert
          verifyZeroInteractions(mockNumberTriviaRemoteDS);
          verify(mockNumberTriviaLocalDS.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });
}
