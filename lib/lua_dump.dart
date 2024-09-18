library kurumi;

class LuaDump {
  static void DumpMem(Object b, DumpState D, ClassType t) {
    List<int> bytes = t.ObjToBytes(b);
    List<int> ch = new List<int>(bytes.length);
    for (int i = 0; i < bytes.length; i++) {
      ch[i] = bytes[i];
    }
    CLib.CharPtr str = CLib.CharPtr.toCharPtr(ch);
    DumpBlock(str, str.chars.length, D);
  }

  static void DumpMem_int(List<int> b, int n, DumpState D, ClassType t) {
    ClassType_.Assert(b.length == n);
    for (int i = 0; i < n; i++) {
      DumpMem(b[i], D, t);
    }
  }

  static void DumpMem_long(List<int> b, int n, DumpState D, ClassType t) {
    ClassType_.Assert(b.length == n);
    for (int i = 0; i < n; i++) {
      DumpMem(b[i], D, t);
    }
  }

  static void DumpVar(Object x, DumpState D, ClassType t) {
    DumpMem(x, D, t);
  }

  static void DumpBlock(CLib.CharPtr b, int size, DumpState D) {
    if (D.status == 0) {
      LuaLimits.lua_unlock(D.L);
      D.status = D.writer.exec(D.L, b, size, D.data);
      LuaLimits.lua_lock(D.L);
    }
  }

  static void DumpChar(int y, DumpState D) {
    int x = y;
    DumpVar(x, D, new ClassType(ClassType_.TYPE_CHAR));
  }

  static void DumpInt(int x, DumpState D) {
    DumpVar(x, D, new ClassType(ClassType_.TYPE_INT));
  }

  static void DumpNumber(double x, DumpState D) {
    DumpVar(x, D, new ClassType(ClassType_.TYPE_DOUBLE));
  }

  static void DumpVector_int(List<int> b, int n, DumpState D, ClassType t) {
    DumpInt(n, D);
    DumpMem_int(b, n, D, t);
  }

  static void DumpVector_long(List<int> b, int n, DumpState D, ClassType t) {
    DumpInt(n, D);
    DumpMem_long(b, n, D, t);
  }

  static void DumpString(LuaObject.TString s, DumpState D) {
    if ((s == null) || CLib.CharPtr.isEqual(LuaObject.getstr(s), null)) {
      int size = 0;
      DumpVar(size, D, new ClassType(ClassType_.TYPE_INT));
    } else {
      int size = (s.getTsv().len + 1);
      DumpVar(size, D, new ClassType(ClassType_.TYPE_INT));
      DumpBlock(LuaObject.getstr(s), size, D);
    }
  }

  static void DumpCode(LuaObject.Proto f, DumpState D) {
    DumpVector_long(f.code, f.sizecode, D, new ClassType(ClassType_.TYPE_LONG));
  }

  static void DumpConstants(LuaObject.Proto f, DumpState D) {
    int i;
    int n = f.sizek;
    DumpInt(n, D);
    for ((i = 0); i < n; i++) {
      LuaObject.TValue o = f.k[i];
      DumpChar(LuaObject.ttype(o), D);
      switch (LuaObject.ttype(o)) {
        case Lua.LUA_TNIL:
          break;
        case Lua.LUA_TBOOLEAN:
          DumpChar(LuaObject.bvalue(o), D);
          break;
        case Lua.LUA_TNUMBER:
          DumpNumber(LuaObject.nvalue(o), D);
          break;
        case Lua.LUA_TSTRING:
          DumpString(LuaObject.rawtsvalue(o), D);
          break;
        default:
          LuaLimits.lua_assert(0);
          break;
      }
    }
    n = f.sizep;
    DumpInt(n, D);
    for ((i = 0); i < n; i++) {
      DumpFunction(f.p[i], f.source, D);
    }
  }

  static void DumpDebug(LuaObject.Proto f, DumpState D) {
    int i;
    int n;
    n = ((D.strip != 0) ? 0 : f.sizelineinfo);
    DumpVector_int(f.lineinfo, n, D, new ClassType(ClassType_.TYPE_INT));
    n = ((D.strip != 0) ? 0 : f.sizelocvars);
    DumpInt(n, D);
    for ((i = 0); i < n; i++) {
      DumpString(f.locvars[i].varname, D);
      DumpInt(f.locvars[i].startpc, D);
      DumpInt(f.locvars[i].endpc, D);
    }
    n = ((D.strip != 0) ? 0 : f.sizeupvalues);
    DumpInt(n, D);
    for ((i = 0); i < n; i++) {
      DumpString(f.upvalues[i], D);
    }
  }

  static void DumpFunction(
      LuaObject.Proto f, LuaObject.TString p, DumpState D) {
    DumpString(((f.source == p) || (D.strip != 0)) ? null : f.source, D);
    DumpInt(f.linedefined, D);
    DumpInt(f.lastlinedefined, D);
    DumpChar(f.nups, D);
    DumpChar(f.numparams, D);
    DumpChar(f.is_vararg, D);
    DumpChar(f.maxstacksize, D);
    DumpCode(f, D);
    DumpConstants(f, D);
    DumpDebug(f, D);
  }

  static void DumpHeader(DumpState D) {
    CLib.CharPtr h = CLib.CharPtr.toCharPtr(new char[LuaUndump.LUAC_HEADERSIZE]);
    LuaUndump.luaU_header(h);
    DumpBlock(h, LuaUndump.LUAC_HEADERSIZE, D);
  }

  static int luaU_dump(LuaState.lua_State L, LuaObject.Proto f,
      Lua.lua_Writer w, Object data, int strip) {
    DumpState D = new DumpState();
    D.L = L;
    D.writer = w;
    D.data = data;
    D.strip = strip;
    D.status = 0;
    DumpHeader(D);
    DumpFunction(f, null, D);
    return D.status;
  }
}

class DumpState {
  LuaState.lua_State L;
  Lua.lua_Writer writer;
  Object data;
  int strip;
  int status;
}
