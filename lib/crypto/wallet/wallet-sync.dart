import 'package:defichaindart/defichaindart.dart';
import 'package:defichainwallet/crypto/model/wallet_account.dart';
import 'package:defichainwallet/crypto/wallet/impl/hdWallet.dart';
import 'package:defichainwallet/network/api_service.dart';
import 'package:defichainwallet/network/model/account.dart';
import 'package:flutter/foundation.dart';

import '../chain.dart';

class WalletSync {
  static Future<List<Account>> syncBalance(
      ChainType chain,
      ChainNet network,
      String seed,
      String password,
      ApiService apiService,
      List<WalletAccount> wallets) async {
    var startDate = DateTime.now();
    var ret = List<Account>();
    try {
      for (final wallet in wallets) {
        var hdWallet = HdWallet(password, wallet, chain, network,
            mnemonicToSeedHex(seed), apiService);
        var balance = await hdWallet.syncBalance();
        ret.addAll(balance);
      }

      var endTxDate = DateTime.now();

      var diffTx =
          endTxDate.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch;

      print("wallet sync took ${diffTx / 1000} seconds");
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
    return ret;
  }
}
