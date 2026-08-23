import 'app_strings_base.dart';
import 'app_strings_ar.dart';
import 'app_strings_en.dart';

class AppStrings {
  static AppStringsBase i = AppStringsAr();
  static String languageCode = 'ar';

  static void setLocale(String languageCode) {
    AppStrings.languageCode = languageCode;
    if (languageCode == 'en') {
      i = AppStringsEn();
    } else {
      i = AppStringsAr();
    }
  }

  static String get appName => i.appName;
  static String get welcomeToShafeea => i.welcomeToShafeea;
  static String get platformDescription => i.platformDescription;
  static String get login => i.login;
  static String get createAccount => i.createAccount;
  static String get requestSession => i.requestSession;
  static String get accept => i.accept;
  static String get reject => i.reject;
  static String get sessionStarted => i.sessionStarted;
  static String get sessionEnded => i.sessionEnded;
  static String get incomingCall => i.incomingCall;
  static String get online => i.online;
  static String get offline => i.offline;
  static String get errorMarking => i.errorMarking;
  static String get memorization => i.memorization;
  static String get revision => i.revision;
}
