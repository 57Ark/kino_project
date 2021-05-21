import 'package:flutter/material.dart';
import 'package:kino_project/main.dart';
import 'add_location.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class Payment extends StatefulWidget {
  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _cardNumber = '';
  String _expiryDate = '';
  String _cardHolderName = '';
  String _cvvCode = '';
  bool _isCvvFocused = false;

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      _cardNumber = creditCardModel!.cardNumber;
      _expiryDate = creditCardModel.expiryDate;
      _cardHolderName = creditCardModel.cardHolderName;
      _cvvCode = creditCardModel.cvvCode;
      _isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kino Locations"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Личный кабинет',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddLocation()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            CreditCardWidget(
              cardNumber: _cardNumber,
              expiryDate: _expiryDate,
              cardHolderName: _cardHolderName,
              cvvCode: _cvvCode,
              showBackView: _isCvvFocused,
              obscureCardNumber: true,
              obscureCardCvv: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    CreditCardForm(
                      formKey: _formKey,
                      obscureCvv: true,
                      obscureNumber: true,
                      cardNumber: _cardNumber,
                      cvvCode: _cvvCode,
                      cardHolderName: _cardHolderName,
                      expiryDate: _expiryDate,
                      themeColor: Colors.blue,
                      cardNumberDecoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Номер карты',
                        hintText: 'XXXX XXXX XXXX XXXX',
                      ),
                      expiryDateDecoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'ММ / ГГ',
                        hintText: 'XX/XX',
                      ),
                      cvvCodeDecoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'CVV код',
                        hintText: 'XXX',
                      ),
                      cardHolderDecoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Владелец карты',
                      ),
                      onCreditCardModelChange: onCreditCardModelChange,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        primary: const Color(0xff1b447b),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        child: const Text(
                          'Оплатить',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'halter',
                            fontSize: 14,
                            package: 'flutter_credit_card',
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
