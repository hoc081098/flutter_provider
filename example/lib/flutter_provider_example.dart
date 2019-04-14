import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';

class Foo {
  const Foo();

  String foo() => 'Hello';
}

class Bar1 {
  const Bar1();

  String bar1() => 'Hello everyone';
}

class Bar2 {
  const Bar2();

  String bar2() => 'Fall in love with Flutter';
}

void main() {
  const Foo foo = Foo();
  const Bar1 bar1 = Bar1();
  const Bar2 bar2 = Bar2();

  runApp(
    Providers(
      providers: <Provider>[
        const Provider<Bar1>(value: bar1),
        const Provider<Bar2>(value: bar2),
      ],
      child: const Provider<Foo>(
        value: foo,
        child: MyApp(),
      ),
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
    return Consumer3<Foo, Bar1, Bar2>(
      builder: (BuildContext context, Foo a, Bar1 b, Bar2 c) {
        return Container(
          constraints: BoxConstraints.expand(),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(a.foo()),
                Text(b.bar1()),
                Text(c.bar2()),
              ],
            ),
          ),
        );
      },
    );
  }
}
