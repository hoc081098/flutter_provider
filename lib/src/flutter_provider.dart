import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Provides a [value] to all descendants of this Widget. This should
/// generally be a root widget in your App
class Provider<T> extends InheritedWidget {
  /// The value exposed to other widgets.
  ///
  /// You can obtain this value this widget's descendants
  /// using [Provider.of] method
  final T value;

  /// A callback called whenever [InheritedWidget.updateShouldNotify] is called.
  /// It should return `false` when there's no need to update its dependents.
  ///
  /// Default value of [_updateShouldNotify] is [_notEquals]
  final bool Function(T, T) _updateShouldNotify;

  const Provider({
    Key key,
    Widget child,
    @required this.value,
    bool updateShouldNotify(T previous, T current),
  })  : assert(value != null),
        _updateShouldNotify = updateShouldNotify ?? _notEquals,
        super(key: key, child: child);

  /// A method that can be called by descendant Widgets to retrieve the [value]
  /// from the [Provider].
  ///
  /// Important: When using this method, pass through complete type information
  /// or Flutter will be unable to find the correct [Provider]!
  ///
  /// If [listen] is true (default), later value changes will
  /// trigger a new [State.build] to widgets, and [State.didChangeDependencies] for [StatefulWidget]
  ///
  /// ### Example
  ///
  /// ```
  /// class MyWidget extends StatelessWidget {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     final int value = Provider.of<int>(context);
  ///
  ///     return Text(value.toString();
  ///   }
  /// }
  /// ```
  static T of<T>(BuildContext context, {bool listen = true}) {
    final Type type = _typeOf<Provider<T>>();
    final Provider<T> provider = listen
        ? context.inheritFromWidgetOfExactType(type)
        : context.ancestorInheritedElementForWidgetOfExactType(type)?.widget;
    if (provider == null) {
      throw ProviderError(type);
    }
    return provider.value;
  }

  @override
  bool updateShouldNotify(Provider<T> old) =>
      _updateShouldNotify(old.value, value);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('value', value));
  }

  static bool _notEquals(previous, current) => previous != current;

  static Type _typeOf<T>() => T;

  Provider<T> copyWithChild(Widget child) => Provider<T>(
      child: child,
      value: value,
      key: key,
      updateShouldNotify: _updateShouldNotify);
}

/// If the [Provider.of] method fails, this error will be thrown.
///
/// Often, when the `of` method fails, it is difficult to understand why since
/// there can be multiple causes. This error explains those causes so the user
/// can understand and fix the issue.
class ProviderError extends Error {
  /// The type of the class the user tried to retrieve
  final Type type;

  /// Creates a [ProviderError]
  ProviderError(this.type);

  @override
  String toString() {
    return '''Error: No $type found. To fix, please try:
  * Wrapping your MaterialApp with the Provider<T>
  * Providing full type information to Provider<T> and Provider.of<T> method
If none of these solutions work, please file a bug at:
https://github.com/hoc081098/flutter_provider/issues/new
      ''';
  }
}

/// A provider that exposes that merges multiple other [Provider]s into one.
///
/// [Providers] is used to improve the readability and reduce the boilerplate of
/// having many nested providers.
///
/// As such, we're going from:
///
/// ```dart
/// Provider<Foo>(
///   value: foo,
///   child: Provider<Bar>(
///     value: bar,
///     child: Provider<Baz>(
///       value: baz,
///       child: someWidget,
///     )
///   )
/// )
/// ```
///
/// To:
///
/// ```dart
/// Providers(
///   providers: [
///     Provider<Foo>(value: foo),
///     Provider<Bar>(value: bar),
///     Provider<Baz>(value: baz),
///   ],
///   child: someWidget,
/// )
/// ```
///
/// Technically, these two are identical. [Providers] will convert the array into a tree.
/// This changes only the appearance of the code.
class Providers extends StatelessWidget {
  /// The list of providers that will be transformed into a tree.
  /// The tree is created from top to bottom.
  /// The first item because to topmost provider, while the last item it the direct parent of [child].
  final List<Provider<dynamic>> providers;

  /// The child of the last provider in [providers].
  /// If [providers] is empty, then [Providers] just returns [child].
  final Widget child;

  const Providers({Key key, @required this.providers, @required this.child})
      : assert(providers != null),
        assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => providers.reversed
      .fold(child, (Widget acc, Provider<dynamic> e) => e.copyWithChild(acc));
}

/// Obtain [Provider] from its ancestors and pass its value to [builder].
/// [builder] must not be null and may be called multiple times (such as when provided value change).
class Consumer<T> extends StatelessWidget {
  /// Build a widget tree based on the value from a [Provider].
  final Widget Function(BuildContext context, T t) builder;

  const Consumer({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) =>
      builder(context, Provider.of<T>(context));
}

/// Obtain 2 [Provider] from its ancestors and pass its value to [builder].
/// [builder] must not be null and may be called multiple times (such as when provided values change).
class Consumer2<A, B> extends StatelessWidget {
  /// Build a widget tree based on the value from a [Provider].
  final Widget Function(BuildContext context, A a, B b) builder;

  const Consumer2({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) =>
      builder(context, Provider.of<A>(context), Provider.of<B>(context));
}

/// Obtain 3 [Provider] from its ancestors and pass its value to [builder].
/// [builder] must not be null and may be called multiple times (such as when provided values change).
class Consumer3<A, B, C> extends StatelessWidget {
  /// Build a widget tree based on the value from a [Provider].
  final Widget Function(BuildContext context, A a, B b, C c) builder;

  const Consumer3({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

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
class Consumer4<A, B, C, D> extends StatelessWidget {
  /// Build a widget tree based on the value from a [Provider].
  final Widget Function(BuildContext context, A a, B b, C c, D d) builder;

  const Consumer4({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

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
class Consumer5<A, B, C, D, E> extends StatelessWidget {
  /// Build a widget tree based on the value from a [Provider].
  final Widget Function(BuildContext context, A a, B b, C c, D d, E e) builder;

  const Consumer5({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

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
class Consumer6<A, B, C, D, E, F> extends StatelessWidget {
  /// Build a widget tree based on the value from a [Provider].
  final Widget Function(BuildContext context, A a, B b, C c, D d, E e, F f)
      builder;

  const Consumer6({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

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
class Consumer7<A, B, C, D, E, F, G> extends StatelessWidget {
  /// Build a widget tree based on the value from a [Provider].
  final Widget Function(BuildContext context, A a, B b, C c, D d, E e, F f, G g)
      builder;

  const Consumer7({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

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

// Obtain 8 [Provider] from its ancestors and pass its value to [builder].
/// [builder] must not be null and may be called multiple times (such as when provided values change).
class Consumer8<A, B, C, D, E, F, G, H> extends StatelessWidget {
  /// Build a widget tree based on the value from a [Provider].
  final Widget Function(
      BuildContext context, A a, B b, C c, D d, E e, F f, G g, H h) builder;

  const Consumer8({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

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

// Obtain 9 [Provider] from its ancestors and pass its value to [builder].
/// [builder] must not be null and may be called multiple times (such as when provided values change).
class Consumer9<A, B, C, D, E, F, G, H, I> extends StatelessWidget {
  /// Build a widget tree based on the value from a [Provider].
  final Widget Function(
          BuildContext context, A a, B b, C c, D d, E e, F f, G g, H h, I i)
      builder;

  const Consumer9({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

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
