import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/core/network/network_info.dart';

import 'network_info_test.mocks.dart';

@GenerateMocks([DataConnectionChecker])
void main() {
  final mockDataConnChecker = MockDataConnectionChecker();
  final networkInfoImpl = NetworkInfoImpl(mockDataConnChecker);

  group('isConnected', () {
    test(
      'should forward the call to DataConnectionChecker.hasConnection',
      () async {
        // arrange
        final tHasConnectionFuture = Future.value(true);
        when(mockDataConnChecker.hasConnection).thenAnswer((_) => tHasConnectionFuture);

        // act
        final result = networkInfoImpl.isConnected;

        // assert
        verify(mockDataConnChecker.hasConnection);
        expect(result, tHasConnectionFuture);
      },
    );
  });
}
