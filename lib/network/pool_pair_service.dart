import 'dart:async';
import 'dart:convert';

import 'package:defichainwallet/bus/pool_pair_loaded_event.dart';
import 'package:defichainwallet/bus/pool_pairs_loaded_event.dart';
import 'package:defichainwallet/network/model/pool_pair.dart';
import 'package:defichainwallet/network/network_service.dart';
import 'package:defichainwallet/network/response/error_response.dart';

class PoolPairService extends NetworkService {
  Future<List<PoolPair>> getPoolPairs(String coin) async {
    dynamic response =
        await this.httpService.makeHttpGetRequest('/listpoolpairs', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    List<PoolPair> poolPairs = response.entries
        .map<PoolPair>((data) => PoolPair.fromJson(data.value))
        .toList();

    this.fireEvent(new PoolPairsLoadedEvent(poolPairs: poolPairs));

    return poolPairs;
  }

  Future<PoolPair> getPoolPair(String coin, String poolID) async {
    dynamic response = await this
        .httpService
        .makeHttpGetRequest('/getpoolpairs/$poolID', coin);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    PoolPair poolPair = PoolPair.fromJson(response);

    this.fireEvent(new PoolPairLoadedEvent(poolPair: poolPair));

    return poolPair;
  }
}
