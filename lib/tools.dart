library kurumi;

class Tools {
  static String sprintf(String Format, List<Object> Parameters /*XXX*/) {
    bool hasFloat = false;
    if ((Format == LuaConf.LUA_NUMBER_FMT) && (Parameters.length == 1)) {
      if (Parameters[0] == Parameters[0].longValue()) {
        Format = "%s";
        Parameters[0] = Parameters[0].longValue();
      } else {
        Format = "%s";
        hasFloat = true;
      }
    } else {
      if (Format == "%ld") {
        Format = "%d";
      }
    }
    String result = String_.format(Format, Parameters);
    if (hasFloat) {
      List<String> subResults = result.split("\\.");
      if ((subResults.length == 2) && (subResults[1].length > 13)) {
        result = String_.format(LuaConf.LUA_NUMBER_FMT, Parameters);
      }
    }
    return result;
  }

  static void printf(String Format, List<Object> Parameters /*XXX*/) {
    System.out.print(Tools.sprintf(Format, Parameters));
  }
}
