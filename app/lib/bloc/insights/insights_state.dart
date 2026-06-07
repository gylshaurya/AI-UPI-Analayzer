abstract class InsightsState {}

class InsightsIdle extends InsightsState {}

class InsightsLoading extends InsightsState {}

class InsightsAnswered extends InsightsState {
  final String question;
  final String answer;
  InsightsAnswered(this.question, this.answer);
}

class InsightsError extends InsightsState {
  final String message;
  InsightsError(this.message);
}
