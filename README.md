# flutter_provider

## Author: [Petrus Nguyễn Thái Học](https://github.com/hoc081098)


[![Pub](https://img.shields.io/pub/v/flutter_provider.svg)](https://pub.dartlang.org/packages/flutter_provider)
[![Build Status](https://travis-ci.org/hoc081098/flutter_provider.svg?branch=master)](https://travis-ci.org/hoc081098/flutter_provider)
[![codecov](https://codecov.io/gh/hoc081098/flutter_provider/branch/master/graph/badge.svg?token=BG7WmxRnbi)](https://codecov.io/gh/hoc081098/flutter_provider)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fhoc081098%2Fflutter_provider&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)


Flutter generic provider using InheritedWidget. An helper to easily exposes a value using InheritedWidget without having to write one.

## Getting Started

In your flutter project, add the dependency to your `pubspec.yaml`

```yaml
dependencies:
  ...
  flutter_provider: <latest_version>
```

## Usage

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

# License
    MIT License
    
    Copyright (c) 2019-2021 Petrus Nguyễn Thái Học
