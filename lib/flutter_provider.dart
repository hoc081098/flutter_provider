/// # Light weight provider for flutter.
///
/// ## Usage example
///
/// ```dart
/// final Api api = Api(http.Client);
/// runApp(
///   Provider<Api>.value(
///     api,
///     child: MyApp(),
///   )
/// );
///
/// // Retrieve api later and do something
/// final Api api1 = context.get<Api>();
/// final Api api2 = Provider.of<Api>(context);
///
///```
library flutter_provider;

export 'src/consumer.dart';
export 'src/flutter_provider.dart';
