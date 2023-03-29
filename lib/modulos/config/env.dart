import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied()
abstract class Env {
  @EnviedField(varName: 'MIXPANEL_PROJECT_ID', obfuscate: true)
  static final mixpanelProjectID = _Env.mixpanelProjectID;

  @EnviedField(varName: 'SENTRY_DSN', obfuscate: true)
  static final sentryDSN = _Env.sentryDSN;

  @EnviedField(varName: 'FLAGSMITH_APIKEY', obfuscate: true)
  static final flagsmithKey = _Env.flagsmithKey;
}
