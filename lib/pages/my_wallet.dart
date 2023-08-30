import 'package:flutter/material.dart';



class MyWalletPage extends StatefulWidget {
  @override
  _MyWalletPageState createState() => _MyWalletPageState();
}

class _MyWalletPageState extends State<MyWalletPage> {
  double balance = 100.0;
  List<String> transactionHistory = [
    'Received \$50.00 from John',
    'Sent \$20.00 to Lisa',
    'Received \$30.00 from Sarah',
  ];

  void deposit(double amount) {
    setState(() {
      balance += amount;
      transactionHistory.add('Received \$${amount.toStringAsFixed(2)}');
    });
  }

  void withdraw(double amount) {
    setState(() {
      if (balance >= amount) {
        balance -= amount;
        transactionHistory.add('Sent \$${amount.toStringAsFixed(2)}');
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Insufficient Balance'),
              content: Text('You do not have enough balance to withdraw.'),
              actions: <Widget>[
                ElevatedButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  void viewTransactionDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Transaction History'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Balance: \$${balance.toStringAsFixed(2)}'),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: transactionHistory.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(transactionHistory[index]),
                    );
                  },
                ),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Wallet'),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 5.0,
              child: Container(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balance',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '\$${balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                deposit(50.0);
              },
              child: Text('Deposit'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                withdraw(20.0);
              },
              child: Text('Withdraw'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                viewTransactionDetails();
              },
              child: Text('Transaction Details'),
            ),
          ],
        ),
      ),
    );
  }
}
