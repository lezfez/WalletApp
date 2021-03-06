import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/model/wallet_account.dart';
import 'package:defichainwallet/network/model/account.dart';
import 'package:defichainwallet/network/model/account_balance.dart';
import 'package:defichainwallet/network/model/transaction.dart';
import 'package:flutter/cupertino.dart';

abstract class IWalletDatabase {
  Future<int> getNextFreeIndex(int account);

  Future<List<WalletAccount>> getAccounts();
  Future<WalletAccount> updateAccount(WalletAccount account);
  Future<WalletAccount> addAccount(
      {@required String name,
      @required int account,
      @required ChainType chain,
      bool isSelected = false});

  Future clearTransactions();
  Future<List<Transaction>> getTransactions();
  Future addTransaction(Transaction transaction);

  
  Future clearUnspentTransactions();
  Future<List<Transaction>> getUnspentTransactions();
  Future addUnspentTransaction(Transaction transaction);

  Future clearAccountBalances();
  Future setAccountBalance(Account balance);
  Future<List<Account>> getAccountBalances();
  Future<double> getAccountBalance(String token);
  Future<List<AccountBalance>> getTotalBalances();

  Future open();
  Future close();
  Future destroy();
}
