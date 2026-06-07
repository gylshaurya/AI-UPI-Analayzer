abstract class InsightsEvent {}

class AskQuestion extends InsightsEvent {
  final String question;
  final String context; // formatted transaction data
  AskQuestion(this.question, this.context);
}

class ClearInsights extends InsightsEvent {}
