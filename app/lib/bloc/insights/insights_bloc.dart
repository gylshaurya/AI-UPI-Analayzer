import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'insights_event.dart';
import 'insights_state.dart';

class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  // Replace with your actual Gemini API key
  static const _apiKey = 'YOUR_GEMINI_API_KEY';
  static const _url =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey';

  InsightsBloc() : super(InsightsIdle()) {
    on<AskQuestion>(_onAsk);
    on<ClearInsights>((_, emit) => emit(InsightsIdle()));
  }

  Future<void> _onAsk(AskQuestion event, Emitter emit) async {
    emit(InsightsLoading());
    try {
      final prompt =
          '''
You are a personal finance assistant. A user has the following UPI transaction history:

${event.context}

Answer this question concisely and helpfully: ${event.question}

Keep your answer short (2-4 sentences). Use INR (₹) for amounts.
''';

      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data['candidates'][0]['content']['parts'][0]['text'];
        emit(InsightsAnswered(event.question, answer));
      } else {
        emit(InsightsError('API error: ${response.statusCode}'));
      }
    } catch (e) {
      emit(InsightsError('No internet connection'));
    }
  }
}
