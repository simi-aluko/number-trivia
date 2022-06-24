import 'dart:convert';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/features/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia/features/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../fixtures/fixture_reader.dart';
import 'number_trivia_local_data_source_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  final mockSharedPrefs = MockSharedPreferences();
  final dataSource = NumberTriviaLocalDataSourceImpl(mockSharedPrefs);

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));

    test(
      'should return NumberTrivia from SharedPreferences when there is one in the cache',
      () async {
        // arrange
        when(mockSharedPrefs.getString(any)).thenReturn(fixture('trivia_cached.json'));
        // act
        final result = await dataSource.getLastNumberTrivia;
        // assert
        verify(mockSharedPrefs.getString('CACHED_NUMBER_TRIVIA'));
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test('should throw a CacheException when there is not a cached value', () {
      // arrange
      when(mockSharedPrefs.getString(any)).thenReturn(null);
      // act
      // Not calling the method here, just storing it inside a call variable
      final call = dataSource.getLastNumberTrivia;
      // assert
      // Calling the method happens from a higher-order function passed.
      // This is needed to test if calling a method throws an exception.
      expect(() => call(), throwsA(TypeMatcher<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'test');

    test('should call SharedPreferences to cache the data', () {
      // act
      dataSource.cacheNumberTrivia(tNumberTriviaModel);
      // assert
      final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
      verify(mockSharedPrefs.setString(
        CACHED_NUMBER_TRIVIA,
        expectedJsonString,
      ));
    });
  });
}
