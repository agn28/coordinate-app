List _languages = ['English', 'Bengali'];
var _selectedlanguage = 'Bengali';

class Language {

  /// Get selected language
  getLanguage() {
    return _selectedlanguage;
  }

  /// Get all language
  getAllLanguages() {
    return _languages;
  }

  /// Change language.
  /// [lang] parameter is required.
  changeLanguage(lang) {
    _selectedlanguage = lang;
  }
}
