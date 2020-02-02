var _selectedAssessment = {};

class Assessment {

  /// Set assessment for edit
  selectAssessment(assessment) {
    _selectedAssessment = assessment;
  }

  /// Get selected assessment for edit
  getSelectedAssessment() {
    return _selectedAssessment;
  }


  /// Clear selected asessment
  clearItem() {
    _selectedAssessment = {};
  }
}
