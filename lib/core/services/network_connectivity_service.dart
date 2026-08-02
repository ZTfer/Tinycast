import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tinycast/core/utils/logger.dart';

enum NetworkType { wifi, ethernet, cellular, none }

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
      }
      if (connectivityResult.contains(ConnectivityResult.ethernet)) {
        return NetworkType.ethernet;
      }
      if (connectivityResult.contains(ConnectivityResult.mobile)) {
        return NetworkType.cellular;
      }
      // Other non-none links (vpn/other) still imply connectivity on desktop.
      if (connectivityResult.contains(ConnectivityResult.vpn) ||
          connectivityResult.contains(ConnectivityResult.other)) {
        return NetworkType.ethernet;
      }
      return NetworkType.none;
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
    return networkType == NetworkType.wifi || networkType == NetworkType.ethernet;
  }

  Future<bool> canRefresh(bool refreshOnCellular) async {
    final networkType = await getCurrentNetworkType();

    if (networkType == NetworkType.wifi || networkType == NetworkType.ethernet) {
      return true;
    }

    if (networkType == NetworkType.cellular && refreshOnCellular) {
      return true;
    }

    return false;
  }
}
