enum Option { call, put, none }

extension OptionExtension on Option {
  int get value {
    switch (this) {
      case Option.call:
        return 1;
      case Option.put:
        return 2;
      case Option.none:
        return 0;
    }
  }
  String get text {
    switch (this) {
      case Option.call:
        return "看涨";
      case Option.put:
        return "看跌";
      case Option.none:
        return "无";
    }
  }
}
