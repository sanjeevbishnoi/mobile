import 'dart:async';

import 'package:rx_command/rx_command.dart';

import 'package:flutter/material.dart';

class RxCommandTestPage extends StatefulWidget {
  @override
  _RxCommandTestPageState createState() => _RxCommandTestPageState();
}

class _RxCommandTestPageState extends State<RxCommandTestPage> {
  RxCommandTestViewModel vm = new RxCommandTestViewModel();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test rxcommand"),
      ),
      body: ListView(
        children: <Widget>[
          // Test button 1. Hiện loadding khi command chưa xong
          StreamBuilder<CommandResult<String>>(
            stream: vm.testButtonCommand.results,
            initialData: null,
            builder: (ctx, snapshot) {
              if (snapshot.hasData == false) {
                return RaisedButton(
                  child: Text("Nhấn nào"),
                  onPressed: () {
                    vm.testButtonCommand.execute("demo");
                  },
                );
              }

              if (snapshot.data.isExecuting) {
                return CircularProgressIndicator();
              } else {
                return RaisedButton(
                  child: Text("Nhấn nào"),
                  onPressed: () {
                    vm.testButtonCommand.execute("demo");
                  },
                );
              }
            },
          ),
          StreamBuilder<CommandResult<String>>(
            stream: vm.testButtonCommand.results,
            initialData: null,
            builder: (ctx, snapshot) {
              if (snapshot.hasData == false) {
                return RaisedButton(
                  child: Text("Nhấn nào"),
                  onPressed: () {
                    vm.testButtonCommand.execute("demo");
                  },
                );
              }

              if (snapshot.data.isExecuting) {
                return CircularProgressIndicator();
              } else {
                return RaisedButton(
                  child: Text("Nhấn nào"),
                  onPressed: () {
                    vm.testButtonCommand.execute("demo");
                  },
                );
              }
            },
          ),
          StreamBuilder<CommandResult<String>>(
            stream: vm.testButtonCommand.results,
            builder: (ctx, snapshot) {
              if (snapshot.hasData == false) {
                return RaisedButton(
                  child: Text("Nhấn nào"),
                  onPressed: () {
                    vm.testButtonCommand.execute("demo");
                  },
                );
              }

              if (snapshot.data.isExecuting) {
                return CircularProgressIndicator();
              } else {
                return RaisedButton(
                  child: Text("Nhấn nào"),
                  onPressed: () {
                    vm.testButtonCommand.execute("demo");
                  },
                );
              }
            },
          ),
          StreamBuilder<CommandResult<String>>(
            stream: vm.testButtonCommand.results,
            builder: (ctx, snapshot) {
              if (snapshot.hasData == false) {
                return RaisedButton(
                  child: Text("Nhấn nào"),
                  onPressed: () {
                    vm.testButtonCommand.execute("demo");
                  },
                );
              }

              if (snapshot.data.isExecuting) {
                return CircularProgressIndicator();
              } else {
                return RaisedButton(
                  child: Text("Nhấn nào"),
                  onPressed: () {
                    vm.testButtonCommand.execute("demo");
                  },
                );
              }
            },
          ),
          StreamBuilder<CommandResult<String>>(
            stream: vm.testButtonCommand.results,
            builder: (ctx, snapshot) {
              if (snapshot.hasData == false) {
                return RaisedButton(
                  child: Text("Nhấn nào"),
                  onPressed: () {
                    vm.testButtonCommand.execute("demo");
                  },
                );
              }

              if (snapshot.data.isExecuting) {
                return CircularProgressIndicator();
              } else {
                return RaisedButton(
                  child: Text("Nhấn nào"),
                  onPressed: () {
                    vm.testButtonCommand.execute("demo");
                  },
                );
              }
            },
          ),
          StreamBuilder<CommandResult<String>>(
            stream: vm.testButtonCommand.results,
            builder: (ctx, snapshot) {
              if (snapshot.hasData == false) {
                return RaisedButton(
                  child: Text("Nhấn nào"),
                  onPressed: () {
                    vm.testButtonCommand.execute("demo");
                  },
                );
              }

              if (snapshot.data.isExecuting) {
                return CircularProgressIndicator();
              } else {
                return RaisedButton(
                  child: Text("Nhấn nào"),
                  onPressed: () {
                    vm.testButtonCommand.execute("demo");
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class RxCommandTestViewModel {
  RxCommandTestViewModel() {
    testButtonCommand = RxCommand.createAsync(testFunction);
  }

  RxCommandAsync<String, String> testButtonCommand;

  Future<String> testFunction(String param) async {
    await Future.delayed(Duration(seconds: 5));
    return "Result";
  }
}
