const Map<String, String> agentDisplayNames = {
  'pro': 'Rambahaur',
  'con': 'Shaam Bahadur',
  'agent_a': 'Rambahaur',
  'agent_b': 'Shaam Bahadur',
};

String displayName(String agentId) {
  return agentDisplayNames[agentId] ?? agentId.replaceAll('_', ' ');
}
