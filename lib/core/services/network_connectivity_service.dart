import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tinycast/core/utils/logger.dart';

enum NetworkType { wifi, cellular, none }

class NetworkConnectivityService {
  NetworkConnectivityService._();

  static final NetworkConnectivityService _instance =
      NetworkConnectivityService._();
  static NetworkConnectivityService get instance => _instance;

  final Connectivity _connectivity = Connectivity();

  Future<NetworkType> getCurrentNetworkType() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.wifi)) {
        return NetworkType.wifi;
      } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
        return NetworkType.cellular;
      } else {
        return NetworkType.none;
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to check network type',
        error: e,
        stackTrace: stackTrace,
      );
      return NetworkType.none;
    }
  }

  Future<bool> isWifi() async {
    final networkType = await getCurrentNetworkType();
    return networkType == NetworkType.wifi;
  }

  Future<bool> canRefresh(bool refreshOnCellular) async {
    final networkType = await getCurrentNetworkType();

    if (networkType == NetworkType.wifi) {
      return true;
    }

    if (networkType == NetworkType.cellular && refreshOnCellular) {
      return true;
    }

    return false;
  }
}
