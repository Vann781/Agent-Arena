class Validators {
  Validators._();
  static String? validateTopic(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Please enter a debate topic';
    if (value.trim().length < 3) return 'Topic must be at least 3 characters';
    if (value.trim().length > 500)
      return 'Topic must be at most 500 characters';
    return null;
  }

  static String? validateQuestion(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > 1000)
      return 'Question must be at most 1000 characters';
    return null;
  }

  static String? validateAgentName(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Please enter an agent name';
    if (value.trim().length < 2)
      return 'Agent name must be at least 2 characters';
    if (value.trim().length > 30)
      return 'Agent name must be at most 30 characters';
    return null;
  }
}
