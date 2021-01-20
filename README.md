# flutter_provider

## Author: [Petrus Nguyễn Thái Học](https://github.com/hoc081098)


[![Pub](https://img.shields.io/pub/v/flutter_provider.svg)](https://pub.dartlang.org/packages/flutter_provider)
[![Build Status](https://travis-ci.org/hoc081098/flutter_provider.svg?branch=master)](https://travis-ci.org/hoc081098/flutter_provider)
[![codecov](https://codecov.io/gh/hoc081098/flutter_provider/branch/master/graph/badge.svg?token=BG7WmxRnbi)](https://codecov.io/gh/hoc081098/flutter_provider)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)


Flutter generic provider using InheritedWidget. An helper to easily exposes a value using InheritedWidget without having to write one.

## Getting Started

In your flutter project, add the dependency to your `pubspec.yaml`

```yaml
dependencies:
  ...
  flutter_provider: ^1.1.1
```

## Usage

### 1. Provide
```dart
Providers(
  providers: <Provider>[
    const Provider<Bar1>(value: bar1),
    const Provider<Bar2>(value: bar2),
  ],
  child: const Provider<Foo>(
    value: foo,
    child: MyApp(),
  ),
);
```

### 2. Consume

```dart
Consumer3<Foo, Bar1, Bar2>(
  builder: (context, Foo a, Bar1 b, Bar2 c) {
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
```

# License
    MIT License
    
    Copyright (c) 2021 Petrus Nguyễn Thái Học