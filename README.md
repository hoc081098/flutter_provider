# flutter_provider

## Author: [Petrus Nguyễn Thái Học](https://github.com/hoc081098)


[![Pub](https://img.shields.io/pub/v/flutter_provider.svg)](https://pub.dartlang.org/packages/flutter_provider)
[![Build Status](https://travis-ci.org/hoc081098/flutter_provider.svg?branch=master)](https://travis-ci.org/hoc081098/flutter_provider)
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
    
    Copyright (c) 2019 Petrus Nguyễn Thái Học
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.