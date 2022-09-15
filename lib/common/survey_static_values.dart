class StaticSurvey {
  static List<SurveyData> surveyStaticList = [
    SurveyData(
        "1. ¿Conoce la razón por la que tiene que seguir su tratamiento?",
        ["Nunca", "Pocas veces", "Algunas veces", "Mayormente", "Totalmente"]),
    SurveyData(
        "2. ¿Conoce a detalle los hábitos y rutinas que debes seguir en tu tratamiento?",
        ["Nunca", "Pocas veces", "Algunas veces", "Mayormente", "Totalmente"]),
    SurveyData(
        "3. ¿Está familiarizado con el horario en el que debe seguir su tratamiento?",
        ["Nunca", "Pocas veces", "Algunas veces", "Mayormente", "Totalmente"]),
    SurveyData(
        "4. ¿Conoce los medicamentos que toma para controlar su enfermedad?",
        ["Nunca", "Pocas veces", "Algunas veces", "Mayormente", "Totalmente"]),
    SurveyData("5. ¿Te preocupa seguir completamente tu tratamiento?",
        ["Nunca", "Pocas veces", "Algunas veces", "Mayormente", "Totalmente"]),
    SurveyData(
        "6. ¿Deja de controlar su tratamiento si a veces se siente mejor/peor después de seguir las indicaciones de su médico?",
        ["Totalmente", "Mayormente", "Algunas veces", "Rara vez", "Nunca"]),
    SurveyData(
        "7. ¿Toma algún tratamiento que el médico no le indicó (recomendado por su amigo, familiar o pareja)?",
        ["Totalmente", "Mayormente", "Algunas veces", "Rara vez", "Nunca"]),
    SurveyData(
        "8. Si tiene efectos secundarios con su tratamiento ¿Reduce los hábitos y rutinas sin consultar a un médico?",
        ["Totalmente", "Mayormente", "Algunas veces", "Rara vez", "Nunca"]),
    SurveyData(
        "9. Si tiene efectos secundarios con su tratamiento ¿No realiza el tratamiento por un largo periodo, es decir, toma un descanso?",
        ["Totalmente", "Mayormente", "Algunas veces", "Rara vez", "Nunca"]),
    SurveyData(
        "10. Si siente que tiene que realizar muchas actividades relacionadas a su tratamiento, ¿Deja de seguirlas sin consultar al médico?",
        ["Totalmente", "Mayormente", "Algunas veces", "Rara vez", "Nunca"]),
    SurveyData(
        "11. ¿Alguna vez ha seguido parcialmente su tratamiento y dejó de realizar actividades que no considera importantes?",
        ["Totalmente", "Mayormente", "Algunas veces", "Rara vez", "Nunca"]),
    SurveyData("12. ¿Ha fumado usted cigarrillo en los últimos días?",
        ["Totalmente", "Mayormente", "Algunas veces", "Rara vez", "Nunca"])
  ];
}

class SurveyData {
  String question;
  List<String> options;

  SurveyData(this.question, this.options);
}
