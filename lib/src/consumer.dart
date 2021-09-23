import 'package:flutter/widgets.dart';

import '../flutter_provider.dart';

/// Obtain [Provider] from its ancestors and pass its value to [builder].
/// [builder] must not be null and may be called multiple times (such as when provided value change).
class Consumer<T extends Object> extends StatelessWidget {
  /// Build a widget tree based on the value from a [Provider].
  final Widget Function(BuildContext context, T t) builder;

  /// Creates a widget that delegates its build to a callback.
  /// The callback will be called with value retrieved from [Provider].
  ///
  /// The [builder] argument must not be null.
  const Consumer({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      builder(context, Provider.of<T>(context));
}

/// Obtain 2 [Provider] from its ancestors and pass its value to [builder].
/// [builder] must not be null and may be called multiple times (such as when provided values change).
class Consumer2<A extends Object, B extends Object> extends StatelessWidget {
  /// Build a widget tree based on the values from a [Provider].
  final Widget Function(BuildContext context, A a, B b) builder;

  /// Creates a widget that delegates its build to a callback.
  /// The callback will be called with values retrieved from [Provider].
  ///
  /// The [builder] argument must not be null.
  const Consumer2({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      builder(context, Provider.of<A>(context), Provider.of<B>(context));
}

/// Obtain 3 [Provider] from its ancestors and pass its value to [builder].
/// [builder] must not be null and may be called multiple times (such as when provided values change).
class Consumer3<A extends Object, B extends Object, C extends Object>
    extends StatelessWidget {
  /// Build a widget tree based on the values from a [Provider].
  final Widget Function(BuildContext context, A a, B b, C c) builder;

  /// Creates a widget that delegates its build to a callback.
  /// The callback will be called with values retrieved from [Provider].
  ///
  /// The [builder] argument must not be null.
  const Consumer3({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => builder(
        context,
        Provider.of<A>(context),
        Provider.of<B>(context),
        Provider.of<C>(context),
      );
}

/// Obtain 4 [Provider] from its ancestors and pass its value to [builder].
/// [builder] must not be null and may be called multiple times (such as when provided values change).
class Consumer4<A extends Object, B extends Object, C extends Object,
    D extends Object> extends StatelessWidget {
  /// Build a widget tree based on the values from a [Provider].
  final Widget Function(BuildContext context, A a, B b, C c, D d) builder;

  /// Creates a widget that delegates its build to a callback.
  /// The callback will be called with values retrieved from [Provider].
  ///
  /// The [builder] argument must not be null.
  const Consumer4({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => builder(
        context,
        Provider.of<A>(context),
        Provider.of<B>(context),
        Provider.of<C>(context),
        Provider.of<D>(context),
      );
}

/// Obtain 5 [Provider] from its ancestors and pass its value to [builder].
/// [builder] must not be null and may be called multiple times (such as when provided values change).
class Consumer5<A extends Object, B extends Object, C extends Object,
    D extends Object, E extends Object> extends StatelessWidget {
  /// Build a widget tree based on the values from a [Provider].
  final Widget Function(BuildContext context, A a, B b, C c, D d, E e) builder;

  /// Creates a widget that delegates its build to a callback.
  /// The callback will be called with values retrieved from [Provider].
  ///
  /// The [builder] argument must not be null.
  const Consumer5({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => builder(
        context,
        Provider.of<A>(context),
        Provider.of<B>(context),
        Provider.of<C>(context),
        Provider.of<D>(context),
        Provider.of<E>(context),
      );
}

/// Obtain 6 [Provider] from its ancestors and pass its value to [builder].
/// [builder] must not be null and may be called multiple times (such as when provided values change).
class Consumer6<
    A extends Object,
    B extends Object,
    C extends Object,
    D extends Object,
    E extends Object,
    F extends Object> extends StatelessWidget {
  /// Build a widget tree based on the values from a [Provider].
  final Widget Function(BuildContext context, A a, B b, C c, D d, E e, F f)
      builder;

  /// Creates a widget that delegates its build to a callback.
  /// The callback will be called with values retrieved from [Provider].
  ///
  /// The [builder] argument must not be null.
  const Consumer6({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => builder(
        context,
        Provider.of<A>(context),
        Provider.of<B>(context),
        Provider.of<C>(context),
        Provider.of<D>(context),
        Provider.of<E>(context),
        Provider.of<F>(context),
      );
}

/// Obtain 7 [Provider] from its ancestors and pass its value to [builder].
/// [builder] must not be null and may be called multiple times (such as when provided values change).
class Consumer7<
    A extends Object,
    B extends Object,
    C extends Object,
    D extends Object,
    E extends Object,
    F extends Object,
    G extends Object> extends StatelessWidget {
  /// Build a widget tree based on the values from a [Provider].
  final Widget Function(BuildContext context, A a, B b, C c, D d, E e, F f, G g)
      builder;

  /// Creates a widget that delegates its build to a callback.
  /// The callback will be called with values retrieved from [Provider].
  ///
  /// The [builder] argument must not be null.
  const Consumer7({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => builder(
        context,
        Provider.of<A>(context),
        Provider.of<B>(context),
        Provider.of<C>(context),
        Provider.of<D>(context),
        Provider.of<E>(context),
        Provider.of<F>(context),
        Provider.of<G>(context),
      );
}

/// Obtain 8 [Provider] from its ancestors and pass its value to [builder].
/// [builder] must not be null and may be called multiple times (such as when provided values change).
class Consumer8<
    A extends Object,
    B extends Object,
    C extends Object,
    D extends Object,
    E extends Object,
    F extends Object,
    G extends Object,
    H extends Object> extends StatelessWidget {
  /// Build a widget tree based on the values from a [Provider].
  final Widget Function(
      BuildContext context, A a, B b, C c, D d, E e, F f, G g, H h) builder;

  /// Creates a widget that delegates its build to a callback.
  /// The callback will be called with values retrieved from [Provider].
  ///
  /// The [builder] argument must not be null.
  const Consumer8({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => builder(
        context,
        Provider.of<A>(context),
        Provider.of<B>(context),
        Provider.of<C>(context),
        Provider.of<D>(context),
        Provider.of<E>(context),
        Provider.of<F>(context),
        Provider.of<G>(context),
        Provider.of<H>(context),
      );
}

/// Obtain 9 [Provider] from its ancestors and pass its value to [builder].
/// [builder] must not be null and may be called multiple times (such as when provided values change).
class Consumer9<
    A extends Object,
    B extends Object,
    C extends Object,
    D extends Object,
    E extends Object,
    F extends Object,
    G extends Object,
    H extends Object,
    I extends Object> extends StatelessWidget {
  /// Build a widget tree based on the values from a [Provider].
  final Widget Function(
          BuildContext context, A a, B b, C c, D d, E e, F f, G g, H h, I i)
      builder;

  /// Creates a widget that delegates its build to a callback.
  /// The callback will be called with values retrieved from [Provider].
  ///
  /// The [builder] argument must not be null.
  const Consumer9({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => builder(
        context,
        Provider.of<A>(context),
        Provider.of<B>(context),
        Provider.of<C>(context),
        Provider.of<D>(context),
        Provider.of<E>(context),
        Provider.of<F>(context),
        Provider.of<G>(context),
        Provider.of<H>(context),
        Provider.of<I>(context),
      );
}
