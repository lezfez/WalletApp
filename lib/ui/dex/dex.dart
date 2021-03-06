import 'package:defichainwallet/appstate_container.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/crypto/wallet/defichain_wallet.dart';
import 'package:defichainwallet/network/balance_service.dart';
import 'package:defichainwallet/network/dex_service.dart';
import 'package:defichainwallet/network/model/account_balance.dart';
import 'package:defichainwallet/network/model/pool_pair.dart';
import 'package:defichainwallet/network/model/token_balance.dart';
import 'package:defichainwallet/network/pool_pair_service.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DexScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DexScreen();
  }
}

class _DexScreen extends State<DexScreen> {
  TokenBalance _selectedValueTo;
  TokenBalance _selectedValueFrom;

  double _amountFrom;
  double _amountTo;

  bool _testSwapFrom = false;
  bool _testSwapTo = false;
  bool _testSwapLoading = false;

  List<TokenBalance> _fromTokens = [];
  List<TokenBalance> _toTokens = [];
  List<TokenBalance> _tokenMap = [];
  List<PoolPair> _poolPairs;
  bool _poolPairCondition = true;
  PoolPair _selectedPoolPair;

  var _amountFromController = TextEditingController(text: '');
  var _amountToController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();

    _amountFromController.addListener(handleChangeFrom);
    _amountToController.addListener(handleChangeTo);

    _init();
  }

  @override
  void dispose() {
    _amountFromController.dispose();
    _amountToController.dispose();
    super.dispose();
  }

  _init() async {
    var tokenMap = List<TokenBalance>();
    var pairs = await sl.get<PoolPairService>().getPoolPairs('DFI');
    var uniqueTokenList = Map<String, String>();

    for (var i = 0; i < pairs.length; i++) {
      var element = pairs[i];

      var symbol = element.symbol;
      var symbolList = symbol.split('-');

      if (!uniqueTokenList.containsKey(element.idTokenA)) {
        uniqueTokenList[element.idTokenA] = symbolList[0];
      }

      if (!uniqueTokenList.containsKey(element.idTokenB)) {
        uniqueTokenList[element.idTokenB] = symbolList[1];
      }
    }

    var accountBalance = await sl.get<IWalletDatabase>().getTotalBalances();
    var popularSymbols = ['DFI', 'ETH', 'BTC'];

    if (null ==
        accountBalance.firstWhere((element) => element.token == '\$DFI',
            orElse: () => null)) {
      accountBalance.add(AccountBalance(token: '\$DFI', balance: 0));
    }

    uniqueTokenList.forEach((symbolKey, tokenId) {
      var account = accountBalance.firstWhere(
          (element) => element.token == '\$' + tokenId,
          orElse: () => null);
      var finalBalance = account != null ? account.balance : 0;

      tokenMap.add(TokenBalance(
          hash: tokenId,
          idToken: symbolKey,
          balance: double.tryParse(finalBalance.toString()),
          isPopularToken: popularSymbols.contains(tokenId)));
    });

    _poolPairs = pairs;
    _tokenMap = tokenMap;

    setState(() {
      _fromTokens = tokenMap;
      _toTokens = tokenMap;
    });
  }

  filter(TokenBalance valFromSymbol, TokenBalance valToSymbol) {
    var filterPoolPairList = (TokenBalance symbol) {
      var validSymbols = [];

      for (var i = 0; i < _poolPairs.length; i++) {
        var element = _poolPairs[i];

        var elSymbol = element.symbol;
        var symbolList = elSymbol.split('-');

        if (symbolList[0] == symbol.hash) {
          validSymbols.add(symbolList[1]);
        } else if (symbolList[1] == symbol.hash) {
          validSymbols.add(symbolList[0]);
        }
      }

      List<TokenBalance> tokens = [];

      _tokenMap.forEach((TokenBalance value) {
        if (validSymbols.contains(value.hash)) {
          tokens.add(value);
        }
      });

      return tokens;
    };

    if (null != valFromSymbol) {
      setState(() {
        _toTokens = filterPoolPairList(valFromSymbol);
      });
    }

    if (null != valToSymbol) {
      setState(() {
        _fromTokens = filterPoolPairList(valToSymbol);
      });
    }
  }

  findPoolPair(TokenBalance tokenA, TokenBalance tokenB) {
    if (null == tokenA || null == tokenB) {
      return;
    }

    _selectedPoolPair = _poolPairs.firstWhere(
        (element) =>
            (element.idTokenA == tokenA.idToken &&
                element.idTokenB == tokenB.idToken) ||
            (element.idTokenA == tokenB.idToken &&
                element.idTokenB == tokenA.idToken),
        orElse: () => null);
    if (null != _selectedPoolPair) {
      _poolPairCondition = _selectedPoolPair.idTokenA == tokenA.idToken &&
          _selectedPoolPair.idTokenB == tokenB.idToken;
    }
  }

  findPoolPairReserve() {}

  interchangeSymbols() {
    var backupTo = _selectedValueTo;
    var backupToTokens = _toTokens;

    _amountTo = null;
    _amountFrom = null;

    handleChangeFrom();

    setState(() {
      _selectedValueTo = _selectedValueFrom;
      _toTokens = _fromTokens;

      _selectedValueFrom = backupTo;
      _fromTokens = backupToTokens;
    });
  }

  handleChangeFrom() async {
    if (null == _selectedValueTo || null == _selectedValueFrom) {
      return;
    }

    if (_testSwapTo || _testSwapLoading) {
      return;
    }

    double amount = double.tryParse(_amountFromController.text);

    if (_amountFrom == amount) {
      return;
    }

    _testSwapFrom = true;
    _testSwapTo = false;

    setState(() {
      _amountFrom = amount;
    });

    if (null == amount) {
      _amountToController.text = '-';
    } else {
      _testSwapLoading = true;

      var wallet = sl.get<DeFiChainWallet>();
      var pubKey = await wallet.getPublicKey();

      var swapResult = await sl.get<DexService>().testPoolSwap('DFI', pubKey,
          _selectedValueFrom.hash, amount, pubKey, _selectedValueTo.hash);

      _testSwapLoading = false;
      setState(() {
        _amountTo = double.tryParse(swapResult.result.split('@')[0]);
      });
      _amountToController.text = swapResult.result.split('@')[0];
    }

    _testSwapFrom = false;
  }

  handleChangeTo() async {
    if (null == _selectedValueTo || null == _selectedValueFrom) {
      return;
    }

    if (_testSwapFrom || _testSwapLoading) {
      return;
    }

    double amount = double.tryParse(_amountToController.text);

    if (_amountTo == amount) {
      return;
    }

    _testSwapFrom = false;
    _testSwapTo = true;

    setState(() {
      _amountTo = amount;
    });

    if (null == amount) {
      _amountFromController.text = '-';
    } else {
      _testSwapLoading = true;

      var wallet = sl.get<DeFiChainWallet>();
      var pubKey = await wallet.getPublicKey();

      var swapResult = await sl.get<DexService>().testPoolSwap('DFI', pubKey,
          _selectedValueFrom.hash, amount, pubKey, _selectedValueFrom.hash);

      setState(() {
        _amountFrom = double.tryParse(swapResult.result.split('@')[0]);
      });

      _testSwapLoading = false;
      _amountFromController.text = swapResult.result.split('@')[0];
    }

    _testSwapTo = false;
  }

  @override
  Widget build(Object context) {
    return Scaffold(
        appBar: AppBar(title: Text(S.of(context).dex)),
        body: Padding(
            padding: EdgeInsets.all(30),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButton<TokenBalance>(
                isExpanded: true,
                hint: Text("Status"),
                value: _selectedValueFrom,
                items: _fromTokens.map((e) {
                  return new DropdownMenuItem<TokenBalance>(
                    value: e,
                    child: new Text(e.hash + ' ' + e.balance.toString()),
                  );
                }).toList(),
                onChanged: (TokenBalance val) {
                  setState(() {
                    filter(val, _selectedValueTo);

                    _selectedValueFrom = val;

                    findPoolPair(_selectedValueFrom, _selectedValueTo);
                  });
                },
              ),
              TextField(
                controller: _amountFromController,
                decoration:
                    InputDecoration(hintText: S.of(context).dex_from_amount),
              ),
              RaisedButton(
                  color: StateContainer.of(context).curTheme.buttonColorPrimary,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 10),
                        Text(
                          '<->',
                        ),
                      ]),
                  onPressed: () {
                    interchangeSymbols();
                  }),
              DropdownButton<TokenBalance>(
                isExpanded: true,
                hint: Text("Status"),
                value: _selectedValueTo,
                items: _toTokens.map((e) {
                  return new DropdownMenuItem<TokenBalance>(
                    value: e,
                    child: new Text(e.hash + ' ' + e.balance.toString()),
                  );
                }).toList(),
                onChanged: (TokenBalance val) {
                  setState(() {
                    filter(_selectedValueFrom, val);

                    _selectedValueTo = val;

                    findPoolPair(_selectedValueFrom, _selectedValueTo);
                  });
                },
              ),
              TextField(
                controller: _amountToController,
                decoration:
                    InputDecoration(hintText: S.of(context).dex_to_amount),
              ),
              if (_selectedPoolPair != null && _amountTo != null)
                Column(children: [
                  Row(children: [
                    Expanded(flex: 4, child: Text(S.of(context).dex_price)),
                    Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                                (_poolPairCondition == true
                                        ? _selectedPoolPair.reserveADivReserveB
                                            .toString()
                                        : _selectedPoolPair.reserveBDivReserveA
                                            .toString()) +
                                    ' ' +
                                    _selectedValueFrom.hash +
                                    ' per ' +
                                    _selectedValueTo.hash,
                                textAlign: TextAlign.right),
                            Text(
                                (_poolPairCondition == true
                                        ? _selectedPoolPair.reserveBDivReserveA
                                            .toString()
                                        : _selectedPoolPair.reserveADivReserveB
                                            .toString()) +
                                    ' ' +
                                    _selectedValueTo.hash +
                                    ' per ' +
                                    _selectedValueFrom.hash,
                                textAlign: TextAlign.right),
                          ],
                        )),
                  ]),
                  Divider(color: Colors.black),
                  Row(children: [
                    Expanded(flex: 4, child: Text(S.of(context).dex_amount)),
                    Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_amountTo.toString()),
                          ],
                        )),
                  ]),
                  Divider(color: Colors.black),
                  Row(children: [
                    Expanded(flex: 4, child: Text(S.of(context).dex_commision)),
                    Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_selectedPoolPair.commision.toString()),
                          ],
                        )),
                  ])
                ])
            ])));
  }
}
