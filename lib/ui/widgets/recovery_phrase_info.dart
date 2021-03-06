import 'package:carousel_slider/carousel_slider.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../wallet/recovery_phrase_display.dart';

class RecoveryPhraseInfoWidget extends StatefulWidget {
  final String mnemonic;

  RecoveryPhraseInfoWidget({this.mnemonic});

  @override
  State<StatefulWidget> createState() {
    return _RecoveryPhraseInfoWidget();
  }
}

class _RecoveryPhraseInfoWidget extends State<RecoveryPhraseInfoWidget> {
  int _current = 0;

  Widget buildInfoWidget(String image, String header, String text) {
    return Column(
      children: <Widget>[
        Text(
          header,
          style: TextStyle(fontSize: 20),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      ],
    );
  }

  List<Widget> getCarouselItems(BuildContext context) {
    return [
      buildInfoWidget("", S.of(context).wallet_new_info1_header,
          S.of(context).wallet_new_info1_text),
      buildInfoWidget("", S.of(context).wallet_new_info2_header,
          S.of(context).wallet_new_info2_text),
      buildInfoWidget(
        "",
        S.of(context).wallet_new_info3_header,
        S.of(context).wallet_new_info4_text,
      ),
      buildInfoWidget("", S.of(context).wallet_new_info1_header,
          S.of(context).wallet_new_info1_text),
      Column(children: <Widget>[
        buildInfoWidget("", S.of(context).wallet_new_info4_header,
            S.of(context).wallet_new_info4_text)
      ])
    ];
  }

  @override
  Widget build(BuildContext context) {
    final carouselItems = getCarouselItems(context);

    return Scaffold(
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          verticalDirection: VerticalDirection.down,
          children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                verticalDirection: VerticalDirection.down,
                children: <Widget>[
                  Container(
                      width: double.infinity,
                      child: CarouselSlider(
                        items: carouselItems,
                        options: CarouselOptions(
                            enableInfiniteScroll: false,
                            enlargeCenterPage: true,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _current = index;
                              });
                            }),
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: carouselItems.map((url) {
                      int index = carouselItems.indexOf(url);
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _current == index
                              ? Color.fromRGBO(0, 0, 0, 0.9)
                              : Color.fromRGBO(0, 0, 0, 0.4),
                        ),
                      );
                    }).toList(),
                  )
                ]),
            if (_current == 4)
              Container(
                  child: SizedBox(
                      width: 300,
                      child: RaisedButton(
                        child: Text(S.of(context).wallet_new_reveal),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  RecoveryPhraseDisplayScreen(
                                      widget.mnemonic)));
                        },
                      ))),
            if (_current != 4)
              Container(child: SizedBox(width: 300, height: 40))
          ]),
    );
  }
}
