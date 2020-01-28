var _configs = {
  'isThumbprint': false,
  'isBarcode': false,
};

class Configs {

  configAvailable(key) {
    return _configs[key];
  }
}
