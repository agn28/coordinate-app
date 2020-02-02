var _selectedAssessment = {};

class Assessment {

  /// Set assessment for edit
  selectAssessment(assessment) {
    _selectedAssessment = assessment;
    print(_selectedAssessment);
  }

  /// Clear selected asessment
  clearItem() {
    _selectedAssessment = {};
  }
}
