import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get geminiApiVersion => dotenv.env['GEMINI_API_VERSION'] ?? 'v1';
  static String get geminiModel => dotenv.env['GEMINI_MODEL'] ?? 'gemini-1.5-flash';

  static bool get enableFirebase =>
      (dotenv.env['ENABLE_FIREBASE'] ?? 'false').toLowerCase() == 'true';

  static bool get enableGoogleOAuth =>
      (dotenv.env['ENABLE_GOOGLE_OAUTH'] ?? 'true').toLowerCase() == 'true';

  static String get webAuxUrl =>
      dotenv.env['WEB_AUX_URL'] ?? 'https://petadopt-web.vercel.app';

  static String get googleWebClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';

  static String get shelterAName => dotenv.env['SHELTER_A_NAME'] ?? 'Refugio A';
  static double get shelterALat =>
      double.tryParse(dotenv.env['SHELTER_A_LAT'] ?? '') ?? -0.2100;
  static double get shelterALng =>
      double.tryParse(dotenv.env['SHELTER_A_LNG'] ?? '') ?? -78.4900;

  static String get shelterBName => dotenv.env['SHELTER_B_NAME'] ?? 'Refugio B';
  static double get shelterBLat =>
      double.tryParse(dotenv.env['SHELTER_B_LAT'] ?? '') ?? -0.2050;
  static double get shelterBLng =>
      double.tryParse(dotenv.env['SHELTER_B_LNG'] ?? '') ?? -78.4800;

  static String get shelterCName => dotenv.env['SHELTER_C_NAME'] ?? 'Refugio C';
  static double get shelterCLat =>
      double.tryParse(dotenv.env['SHELTER_C_LAT'] ?? '') ?? -0.2200;
  static double get shelterCLng =>
      double.tryParse(dotenv.env['SHELTER_C_LNG'] ?? '') ?? -78.4950;

  static String get shelterDName => dotenv.env['SHELTER_D_NAME'] ?? 'Refugio D';
  static double get shelterDLat =>
      double.tryParse(dotenv.env['SHELTER_D_LAT'] ?? '') ?? -0.2080;
  static double get shelterDLng =>
      double.tryParse(dotenv.env['SHELTER_D_LNG'] ?? '') ?? -78.4750;
}
