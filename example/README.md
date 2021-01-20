# example

Flutter provider example

### 1. Provide

```dart
final foo = Foo();
final bar1 = Bar1();

Providers(
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
```

### 2. Consume

```dart
Provider.of<T>(context);
context.get<T>();
Consumer<T>(builder: (context, T value) { });
```

```dart
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter provider example'),
      ),
      body: Consumer3<Foo, Bar1, Bar2>(
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
      ),
    );
  }
}
```

