library flutter_provider;

/// # Light weight provider for flutter
///
/// ## Usage example
///
/// ```dart
/// final Api api = Api(http.Client);
/// runApp(
///   Provider<Api>(
///     value: api,
///     child: MyApp(),
///   )
/// );
///
/// //Retrieve api later and do something
/// final Api api = Provider.of<Api>(context);
///
///
///```
export 'src/flutter_provider.dart';
