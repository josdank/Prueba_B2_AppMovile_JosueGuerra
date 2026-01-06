import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/utils/env.dart';

/// Cliente simple para Gemini (Google Generative Language API)
/// - Evita `systemInstruction` (causa 400 en algunos endpoints)
/// - Usa un "system prompt" como primer mensaje
/// - Reintenta con modelos de fallback si el modelo da 404
class GeminiClient {
  static const String _systemPrompt =
      'Eres un asistente experto en cuidado de mascotas. Responde de forma clara y amable. '
      'Da consejos prácticos. Si hay síntomas graves, recomienda acudir a un veterinario.';

  // En muchos proyectos educativos funciona bien con v1beta + gemini-2.5-flash.
  static const String _apiVersion = 'v1beta';

  final http.Client _http;
  GeminiClient([http.Client? httpClient]) : _http = httpClient ?? http.Client();

  Future<String> generate({
    required List<Map<String, String>> history, // {role:user|model, text:""}
    required String message,
  }) async {
    final apiKey = Env.geminiApiKey;
    if (apiKey.isEmpty) {
      return 'Falta configurar GEMINI_API_KEY en el .env';
    }

    final fallbackModels = <String>[
      'gemini-2.5-flash',
      'gemini-2.0-flash',
      // últimos intentos (pueden no estar disponibles en v1beta para tu key)
      'gemini-1.5-flash',
    ];

    final contents = <Map<String, dynamic>>[
      {
        'role': 'user',
        'parts': [
          {'text': _systemPrompt}
        ],
      },
      ...history.map((m) => {
            'role': m['role'] == 'model' ? 'model' : 'user',
            'parts': [
              {'text': (m['text'] ?? '')}
            ],
          }),
      {
        'role': 'user',
        'parts': [
          {'text': message}
        ],
      },
    ];

    final body = jsonEncode({
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
        'topP': 0.9,
        'maxOutputTokens': 512,
      },
    });

    Exception? lastError;

    for (final model in fallbackModels) {
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/$_apiVersion/models/$model:generateContent?key=$apiKey',
      );

      final res = await _http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (res.statusCode == 404) {
        lastError = Exception('Gemini 404: modelo $model no disponible');
        continue;
      }

      if (res.statusCode >= 400) {
        lastError = Exception('Gemini error ${res.statusCode}: ${res.body}');
        continue;
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final candidates = (data['candidates'] as List?) ?? [];
      if (candidates.isEmpty) return 'No pude generar respuesta en este momento.';

      final content = candidates.first['content'] as Map<String, dynamic>?;
      final parts = (content?['parts'] as List?) ?? [];
      final text =
          parts.isNotEmpty ? (parts.first as Map<String, dynamic>)['text']?.toString() : null;

      final out = (text ?? '').trim();
      return out.isEmpty ? 'No pude generar respuesta.' : out;
    }

    return 'No pude conectar con Gemini. ${lastError ?? ''}';
  }
}
