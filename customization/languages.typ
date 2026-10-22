#let language-translations = state(
  "language-translations",
  (
    en: (
      "theorem": "Theorem",
      "proposition": "Proposition",
      "corollary": "Corollary",
      "lemma": "Lemma",
      "definition": "Definition",
      "remark": "Remark",
      "example": "Example",
      "question": "Question",
      "proof": "Proof",
      "keywords": "Keywords",
      "ams": "AMS subject classification",
      "appendix": "Appendix",
      "abstract": "Abstract",
      "reminder": "Reminder",
      "chapter": "Chapter",
    ),
    de: (
      "theorem": "Satz",
      "proposition": "Proposition",
      "corollary": "Korollar",
      "lemma": "Lemma",
      "definition": "Definition",
      "remark": "Anmerkung",
      "example": "Beispiel",
      "question": "Frage",
      "proof": "Beweis",
      "keywords": "Schlüsselwörter",
      "ams": "AMS-Klassifikation",
      "appendix": "Anhang",
      "abstract": "Zusammenfassung",
    ),
    fr: (
      "theorem": "Théorème",
      "proposition": "Proposition",
      "corollary": "Corollaire",
      "lemma": "Lemme",
      "definition": "Définition",
      "remark": "Remarque",
      "example": "Exemple",
      "question": "Question",
      "proof": "Preuve",
      "keywords": "Mots clés",
      "ams": "Classification AMS",
      "appendix": "Annexe",
      "abstract": "Résumé",
      "reminder": "Rappel",
      "chapter": "Partie",
    ),
    es: (
      "theorem": "Teorema",
      "proposition": "Proposición",
      "corollary": "Corolario",
      "lemma": "Lema",
      "definition": "Definición",
      "remark": "Comentario",
      "example": "Ejemplo",
      "question": "Pregunta",
      "proof": "Demostración",
      "keywords": "Palabras clave",
      "ams": "Clasificación AMS",
      "appendix": "Apéndice",
      "abstract": "Resumen",
    ),
  ),
)

#let get-label(label) = {
  context {
    let language = str(text.lang)
    let translations = language-translations.get()
    if language in translations {
      translations.at(language).at(label, default: "Unknown")
    } else {
      translations.en.at(label, default: "Unknown")
    }
  }
}
