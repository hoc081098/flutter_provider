// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';

class Foo {
  Foo() {
    print('$this::init');
  }

  String foo() => 'Hello';

  void dispose() => print('$this::dispose');
}

class Bar1 {
  Bar1() {
    print('$this::init');
  }

  String bar1() => 'Hello everyone';

  void dispose() => print('$this::dispose');
}

class Bar2 {
  Bar2() {
    print('$this::init');
  }

  String bar2() => 'Fall in love with Flutter';

  void dispose() => print('$this::dispose');
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Provider example',
      theme: ThemeData.dark(),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        child: const Text('GO TO HOME'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) {
                final foo = Foo();
                final bar1 = Bar1();

                return Providers(
                  providers: [
                    Provider<Bar1>.value(
                      bar1,
                      disposer: (v) => v.dispose(),
                    ),
                    Provider<Bar2>.factory(
                      (context) => Bar2(),
                      disposer: (v) => v.dispose(),
                    ),
                  ],
                  child: Provider<Foo>.value(
                    foo,
                    disposer: (v) => v.dispose(),
                    child: const HomePage(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter provider example'),
      ),
      body: Consumer3<Foo, Bar1, Bar2>(
        builder: (BuildContext context, Foo a, Bar1 b, Bar2 c) {
          return Container(
            constraints: const BoxConstraints.expand(),
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
      ),
    );
  }
}
