String extractCommune(String adresseComplete) {
  if (adresseComplete.contains(",")) {
    return adresseComplete.split(",").last.trim();
  }
  return "";
}
