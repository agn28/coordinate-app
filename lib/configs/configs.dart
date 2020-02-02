var _configs = {
  'isThumbprint': false,
  'isBarcode': false,
};

class Configs {

  /// Check config is available or not
  /// [key] is required as parameter
  configAvailable(key) {
    return _configs[key];
  }
}
