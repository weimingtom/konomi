library kurumi;

class LuaLimits {
  static const int MAX_SIZET = (Integer.MAX_VALUE - 2);
  static const int MAX_LUMEM = (Integer.MAX_VALUE - 2);
  static const int MAX_INT = (Integer.MAX_VALUE - 2);

  static void lua_assert(bool c) {}

  static void lua_assert(int c) {}

  static Object check_exp(bool c, Object e) {
    return e;
  }

  static Object check_exp(int c, Object e) {
    return e;
  }

  static void api_check(Object o, bool e) {
    lua_assert(e);
  }

  static void api_check(Object o, int e) {
    lua_assert(e != 0);
  }

  static int cast_byte(int i) {
    return i;
  }

  static int cast_byte(int i) {
    return i;
  }

  static int cast_byte(bool i) {
    return i ? 1 : 0;
  }

  static int cast_byte(double i) {
    return i;
  }

  static int cast_int(int i) {
    return i;
  }

  static int cast_int(int i) {
    return i;
  }

  static int cast_int(bool i) {
    return i ? 1 : 0;
  }

  static int cast_int(double i) {
    return i;
  }

  static int cast_int_instruction(int i) {
    return ClassType.ConvertToInt32(i);
  }

  static int cast_int(Object i) {
    ClassType.Assert(false, "Can't convert int.");
    return ClassType.ConvertToInt32_object(i);
  }

  static double cast_num(int i) {
    return i;
  }

  static double cast_num(int i) {
    return i;
  }

  static double cast_num(bool i) {
    return i ? 1 : 0;
  }

  static double cast_num(Object i) {
    ClassType.Assert(false, "Can't convert number.");
    return ClassType.ConvertToSingle(i);
  }

  static const int MAXSTACK = 250;
  static const int MINSTRTABSIZE = 32;
  static const int LUA_MINBUFFER = 32;

  static void lua_lock(LuaState.lua_State L) {}

  static void lua_unlock(LuaState.lua_State L) {}

  static void luai_threadyield(LuaState.lua_State L) {
    lua_unlock(L);
    lua_lock(L);
  }
}
