import 'package:data_connection_checker/data_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final DataConnectionChecker dataConnChecker;
  NetworkInfoImpl(this.dataConnChecker);

  @override
  Future<bool> get isConnected => dataConnChecker.hasConnection;
}
