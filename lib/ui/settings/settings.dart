import 'package:defichainwallet/crypto/database/wallet_database.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/network/model/ivault.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger_flutter/logger_flutter.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen();

  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(S.of(context).settings)),
        body: Column(
          children: [
            Container(
                child: SizedBox(
                    width: 300,
                    child: RaisedButton(
                      child: Text("Remove seed"),
                      color: Theme.of(context).backgroundColor,
                      onPressed: () async {
                        await sl.get<IWalletDatabase>().destroy();
                        await sl.get<IVault>().setSeed(null);

                        Navigator.of(context)
                            .pushNamedAndRemoveUntil("/", (route) => false);

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Removed saved seed"),
                        ));
                      },
                    ))),
            Container(
                child: SizedBox(
                    width: 300,
                    child: RaisedButton(
                      child: Text("Show logs"),
                      color: Theme.of(context).backgroundColor,
                      onPressed: () async {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => LogConsole()));
                      },
                    ))),
          ],
        ));
  }
}
