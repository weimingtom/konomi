library kurumi;

class LuaZIO {
  static const int EOZ = (-1);

  static int char2int(int c) {
    return c;
  }

  static int zgetc(ZIO z) {
    if (z.n-- > 0) {
      int ch = char2int(z.p.get(0));
      z.p.inc();
      return ch;
    } else {
      return luaZ_fill(z);
    }
  }

  static void luaZ_initbuffer(LuaState.lua_State L, Mbuffer buff) {
    buff.buffer = null;
  }

  static CLib.CharPtr luaZ_buffer(Mbuffer buff) {
    return buff.buffer;
  }

  static int luaZ_sizebuffer(Mbuffer buff) {
    return buff.buffsize;
  }

  static int luaZ_bufflen(Mbuffer buff) {
    return buff.n;
  }

  static void luaZ_resetbuffer(Mbuffer buff) {
    buff.n = 0;
  }

  static void luaZ_resizebuffer(LuaState.lua_State L, Mbuffer buff, int size) {
    if (CLib.CharPtr.isEqual(buff.buffer, null)) {
      buff.buffer = new CLib.CharPtr();
    }
    List<List<int>> chars_ref = new List<int>(1)();
    chars_ref[0] = buff.buffer.chars;
    LuaMem.luaM_reallocvector_char(
        L, chars_ref, buff.buffsize, size, new ClassType(ClassType_.TYPE_CHAR));
    buff.buffer.chars = chars_ref[0];
    buff.buffsize = buff.buffer.chars.length;
  }

  static void luaZ_freebuffer(LuaState.lua_State L, Mbuffer buff) {
    luaZ_resizebuffer(L, buff, 0);
  }

  static int luaZ_fill(ZIO z) {
    List<int> size = new List<int>(1);
    LuaState.lua_State L = z.L;
    CLib.CharPtr buff;
    LuaLimits.lua_unlock(L);
    buff = z.reader.exec(L, z.data, size);
    LuaLimits.lua_lock(L);
    if (CLib.CharPtr.isEqual(buff, null) || (size[0] == 0)) {
      return EOZ;
    }
    z.n = (size[0] - 1);
    z.p = new CLib.CharPtr(buff);
    int result = char2int(z.p.get(0));
    z.p.inc();
    return result;
  }

  static int luaZ_lookahead(ZIO z) {
    if (z.n == 0) {
      if (luaZ_fill(z) == EOZ) {
        return EOZ;
      } else {
        z.n++;
        z.p.dec();
      }
    }
    return char2int(z.p.get(0));
  }

  static void luaZ_init(
      LuaState.lua_State L, ZIO z, Lua.lua_Reader reader, Object data) {
    z.L = L;
    z.reader = reader;
    z.data = data;
    z.n = 0;
    z.p = null;
  }

  static int luaZ_read(ZIO z, CLib.CharPtr b, int n) {
    b = new CLib.CharPtr(b);
    while (n != 0) {
      int m;
      if (luaZ_lookahead(z) == EOZ) {
        return n;
      }
      m = ((n <= z.n) ? n : z.n);
      CLib.memcpy(b, z.p, m);
      z.n -= m;
      z.p = CLib.CharPtr.plus(z.p, m);
      b = CLib.CharPtr.plus(b, m);
      n -= m;
    }
    return 0;
  }

  static CLib.CharPtr luaZ_openspace(
      LuaState.lua_State L, Mbuffer buff, int n) {
    if (n > buff.buffsize) {
      if (n < LuaLimits.LUA_MINBUFFER) {
        n = LuaLimits.LUA_MINBUFFER;
      }
      luaZ_resizebuffer(L, buff, n);
    }
    return buff.buffer;
  }
}

class Mbuffer {
  CLib.CharPtr buffer = new CLib.CharPtr();
  int n;
  int buffsize;
}

class ZIO {
  int n;
  CLib.CharPtr p;
  Lua.lua_Reader reader;
  Object data;
  LuaState.lua_State L;
}
