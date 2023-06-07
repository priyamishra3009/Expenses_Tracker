// ignore_for_file: prefer_const_constructors
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import './widgets/chart.dart';

import './widgets/new_transaction.dart';
import './widgets/transaction_list.dart';
import 'package:flutter/material.dart';
import './models/transaction.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([
  //     DeviceOrientation.portraitUp,
  //     DeviceOrientation.portraitDown,
  //     ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme(
          primary: Color.fromARGB(255, 59, 171, 181),
          secondary: Color.fromARGB(255, 59, 171, 181),
          surface: Colors.white,
          background: Colors.grey,
          error: Colors.red, // Set the error color here
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black,
          onBackground: Colors.black,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        // accentColor: Colors.amber
        fontFamily: 'Quicksand',
        textTheme: ThemeData.light().textTheme.copyWith(
              titleLarge: TextStyle(
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'DancingScript',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // String? titleInput;

  final List<Transaction> _userTransactions = [
    // Transaction(
    //   id: 't1',
    //   title: 'New Shoes',
    //   amount: 69.69,
    //   date: DateTime.now(),
    // ),
    // Transaction(
    //   id: 't2',
    //   title: 'Weekly Groceries',
    //   amount: 16.53,
    //   date: DateTime.now(),
    // ),
  ];

  bool _showChart = false;

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(
      String txTitle, double txAmount, DateTime chosenDate) {
    final newTx = Transaction(
        id: DateTime.now().toString(),
        title: txTitle,
        amount: txAmount,
        date: chosenDate);
    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewTransaction(_addNewTransaction),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape =
        mediaQuery.orientation == Orientation.landscape;
    final appBar =  AppBar(
      // backgroundColor: Colors.lightBlueAccent,
      title: Text('Personal Expenses'),
      actions: <Widget>[
        IconButton(
          onPressed: () => _startAddNewTransaction(context),
          icon: Icon(
            Icons.add,
          ),
        )
      ],
    );

    final txListWidget = Container(
        height: (mediaQuery.size.height -
                appBar.preferredSize.height -
                mediaQuery.padding.top) *
            0.7,
        child: TransactionList(_userTransactions, _deleteTransaction));

        final pageBody =  SafeArea (
          child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start, //top to bottom
            crossAxisAlignment: CrossAxisAlignment.stretch, //left to right
            children: <Widget>[
              if (isLandscape)
                Row(
                  //ternary can be replaced by if in this way
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Show Chart'),
                    Switch.adaptive(
                      activeColor: Colors.blueGrey,
                      value: _showChart,
                      onChanged: (val) {
                        setState(() {
                          _showChart = val;
                        });
                      },
                    ),
                  ],
                ),
              if (!isLandscape)
                Container(
                  height: (mediaQuery.size.height -
                          appBar.preferredSize.height -
                         mediaQuery.padding.top) *
                      0.3,
                  child: Chart(_recentTransactions),
                ),
              if (!isLandscape) txListWidget,
              if (isLandscape)
                _showChart
                    ? Container(
                        height: (MediaQuery.of(context).size.height -
                                appBar.preferredSize.height -
                                MediaQuery.of(context).padding.top) *
                            0.7,
                        child: Chart(_recentTransactions),
                      )
                    : txListWidget
            ],
          ),
              ),
        );

        return Platform.isIOS ? CupertinoPageScaffold(child: pageBody,) : Scaffold(
      appBar: appBar,
      body: pageBody,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: Platform.isIOS ? 
      Container()
      : FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _startAddNewTransaction(context),
      ),
    );
  }
}
