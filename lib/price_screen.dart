import 'package:flutter/material.dart';
import 'coin_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:loading/loading.dart';
import 'dart:io' show Platform;

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  String selectedCurrency = currenciesList.first;
  Map<String, String> bitcoinRate = {};

  DropdownButton<String> androidDropDown() {
    List<DropdownMenuItem<String>> dropdownItems = [];
    for (String currency in currenciesList) {
      var newItem = DropdownMenuItem(
        child: Text(currency),
        value: currency,
      );
      dropdownItems.add(newItem);
    }
    return DropdownButton<String>(
      value: selectedCurrency,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.white),
      onChanged: (String newValue) {
        setState(() {
          selectedCurrency = newValue;
          exchangeRate();
        });
      },
      items: dropdownItems,
    );
  }

  CupertinoPicker iOSPicker() {
    List<Text> pickerItems = [];
    for (String currency in currenciesList) {
      pickerItems.add(Text(currency));
    }

    return CupertinoPicker(
      backgroundColor: Colors.lightBlue,
      itemExtent: 32.0,
      onSelectedItemChanged: (selectedValue) {
        setState(() {
          selectedCurrency = currenciesList[selectedValue];
          exchangeRate();
        });
      },
      children: pickerItems,
    );
  }

  bool isWaiting = false;

  void exchangeRate() async {
    isWaiting = true;
    try {
      var coinData = CoinData();
      var rate = await coinData.getCoinData(selectedCurrency);
      isWaiting = false;
      setState(() {
        bitcoinRate = rate;
      });
    } catch (e) {
      print('Exception: $e');
    }
  }

  Column makeCards() {
    List<ReuseableCard> cryptoCards = [];
    for (String crypto in cryptoList) {
      cryptoCards.add(
        ReuseableCard(
          cryptoCurrency: crypto,
          selectedCurrency: selectedCurrency,
          bitcoinRate: isWaiting ? '?' : bitcoinRate[crypto],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: cryptoCards,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🤑 Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            child: makeCards(),
          ),
          Container(
            height: 150.0,
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.lightBlue,
            child: Platform.isIOS ? iOSPicker() : androidDropDown(),
          ),
        ],
      ),
    );
  }
}

class ReuseableCard extends StatelessWidget {
  const ReuseableCard({
    @required this.cryptoCurrency,
    @required this.bitcoinRate,
    @required this.selectedCurrency,
  });

  final String cryptoCurrency;
  final String bitcoinRate;
  final String selectedCurrency;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
      child: Card(
        color: Colors.lightBlueAccent,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          child: Text(
            '1 $cryptoCurrency = $bitcoinRate $selectedCurrency',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
