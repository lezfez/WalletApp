import 'dart:async';
import 'dart:convert';

import 'package:defichainwallet/bus/pool_pair_loaded_event.dart';
import 'package:defichainwallet/bus/pool_pairs_loaded_event.dart';
import 'package:defichainwallet/network/model/pool_pair.dart';
import 'package:defichainwallet/network/model/testpoolswap_result.dart';
import 'package:defichainwallet/network/network_service.dart';
import 'package:defichainwallet/network/request/testpoolswap_request.dart';
import 'package:defichainwallet/network/response/error_response.dart';

class DexService extends NetworkService {
  Future<TestPoolSwapResult> testPoolSwap(String coin, String from, String tokenFrom, double amountFrom, String to, String tokenTo) async {
    var request = TestPoolSwapRequest(
      from: from,
      tokenFrom: tokenFrom,
      amountFrom: amountFrom,
      to: to,
      tokenTo: tokenTo
    );

    dynamic response =
        await this.httpService.makeHttpPostRequest('/dex/testpoolswap', coin, request);

    if (response is ErrorResponse) {
      this.handleError(response);
    }

    return TestPoolSwapResult.fromJson(json.decode(response.body));
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
