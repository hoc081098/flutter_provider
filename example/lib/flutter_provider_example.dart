import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';

class Foo {
  const Foo();

  String foo() => 'Hello';
}

void main() {
  const Foo foo = Foo();

  runApp(
    const Provider<Foo>(
      value: foo,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Provider example',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Foo>(
      builder: (context, value) {
        return Container(
          constraints: BoxConstraints.expand(),
          child: Center(
            child: Text(value.foo()),
          ),
        );
      },
    );
  }
}
