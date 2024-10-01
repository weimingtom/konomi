library kurumi;

class LuaString {
  static int sizestring(LuaObject.TString s) {
    return (s.len + 1) *
        CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_CHAR));
  }

  static int sizeudata(LuaObject.Udata u) {
    return u.len;
  }

  static LuaObject.TString luaS_new(LuaState.lua_State L, CLib.CharPtr s) {
    return luaS_newlstr(L, s, CLib.strlen(s));
  }

  static LuaObject.TString luaS_newliteral(
      LuaState.lua_State L, CLib.CharPtr s) {
    return luaS_newlstr(L, s, CLib.strlen(s));
  }

  static void luaS_fix(LuaObject.TString s) {
    int marked = s.getTsv().marked;
    List<int> marked_ref = new List<int>(1);
    marked_ref[0] = marked;
    LuaGC.l_setbit(marked_ref, LuaGC.FIXEDBIT);
    marked = marked_ref[0];
    s.getTsv().marked = marked;
  }

  static void luaS_resize(LuaState.lua_State L, int newsize) {
    LuaState.GCObject[] newhash;
		LuaState.stringtable tb;
    int i;
    if (LuaState.G(L).gcstate == LuaGC.GCSsweepstring) {
      return;
    }
    newhash = new List<LuaState.GCObject>(newsize);
    LuaMem.AddTotalBytes(
        L,
        newsize *
            CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_GCOBJECTREF)));
    tb = LuaState.G(L).strt;
    for ((i = 0); i < newsize; i++) {
      newhash[i] = null;
    }
    for ((i = 0); i < tb.size; i++) {
      LuaState.GCObject p = tb.hash[i];
      while (p != null) {
        LuaState.GCObject next = p.getGch().next; // save next 
        int h = LuaState.gco2ts(p).hash;
        int h1 = CLib.lmod(h, newsize);
        LuaLimits.lua_assert((h % newsize) == CLib.lmod(h, newsize));
        p.getGch().next = newhash[h1];
        newhash[h1] = p;
        p = next;
      }
    }
    if (tb.hash != null) {
      LuaMem.SubtractTotalBytes(
          L,
          tb.hash.length *
              CLib.GetUnmanagedSize(
                  new ClassType(ClassType_.TYPE_GCOBJECTREF)));
    }
    tb.size = newsize;
    tb.hash = newhash;
  }

      static LuaObject.TString newlstr(LuaState.lua_State L, CLib.CharPtr str, int l, int h)
    {
      LuaObject.TString ts;
		  LuaState.stringtable tb;
        if ((l + 1) > (LuaLimits.MAX_SIZET ~/ CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_CHAR)))) {
            LuaMem.luaM_toobig(L);
        }
        ts = new LuaObject.TString(CLib.CharPtr.toCharPtr(new List<int>((l + 1))));
        LuaMem.AddTotalBytes(L, ((l + 1) * CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_CHAR))) + CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_TSTRING)));
        ts.getTsv().len = l;
        ts.getTsv().hash = h;
        ts.getTsv().marked = LuaGC.luaC_white(LuaState.G(L));
        ts.getTsv().tt = Lua.LUA_TSTRING;
        ts.getTsv().reserved = 0;
        CLib.memcpy_char(ts.str.chars, str.chars, str.index, l);
        ts.str.set(l, '\0'.codeUnitAt(0));
        tb = LuaState.G(L).strt;
        h = CLib.lmod(h, tb.size);
        ts.getTsv().next = tb.hash[h];
        tb.hash[h] = LuaState.obj2gco(ts);
        tb.nuse++;
        if ((tb.nuse > tb.size) && (tb.size <= (LuaLimits.MAX_INT ~/ 2))) {
            luaS_resize(L, tb.size * 2);
        }
        return ts;
    }

    static LuaObject.TString luaS_newlstr(LuaState.lua_State L, CLib.CharPtr str, int l)
    {
      	LuaState.GCObject o;
		    //FIXME:
	      long h = ((long)l) & 0xffffffffL; // seed  - (uint) - uint - int
        int step = ((l >> 5) + 1);
        int l1;
        for ((l1 = l); l1 >= step; (l1 -= step)) {
          h = (0xffffffffL) & ((long)(h ^ ((h << 5)+(h >> 2) + (byte)str.get(l1 - 1))));
        }
        for ((o = LuaState.G(L).strt.hash[CLib.lmod(h, LuaState.G(L).strt.size)]); o != null; (o = o.getGch().next)) {
            LuaObject.TString ts = LuaState.rawgco2ts(o);
            if ((ts.getTsv().len == l) && (CLib.memcmp(str, LuaObject.getstr(ts), l) == 0)) {
                if (LuaGC.isdead(LuaState.G(L), o)) {
                    LuaGC.changewhite(o);
                }
                return ts;
            }
        }
        LuaObject.TString res = newlstr(L, str, l, h);
        return res;
    }

        static LuaObject.Udata luaS_newudata(LuaState.lua_State L, int s, LuaObject.Table e)
    {
        LuaObject.Udata u = new LuaObject.Udata();
        u.uv.marked = LuaGC.luaC_white(LuaState.G(L));
        u.uv.tt = Lua.LUA_TUSERDATA;
        u.uv.len = s;
        u.uv.metatable = null;
        u.uv.env = e;
        u.user_data = new List<int>(s);
        u.uv.next = LuaState.G(L).mainthread.next;
        LuaState.G(L).mainthread.next = LuaState.obj2gco(u);
        return u;
    }

    static LuaObject.Udata luaS_newudata(LuaState.lua_State L, ClassType t, LuaObject.Table e)
    {
        LuaObject.Udata u = new LuaObject.Udata();
        u.uv.marked = LuaGC.luaC_white(LuaState.G(L));
        u.uv.tt = Lua.LUA_TUSERDATA;
        u.uv.len = 0;
        u.uv.metatable = null;
        u.uv.env = e;
        u.user_data = LuaMem.luaM_realloc_(L, t);
        LuaMem.AddTotalBytes(L, CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_UDATA)));
        u.uv.next = LuaState.G(L).mainthread.next;
        LuaState.G(L).mainthread.next = LuaState.obj2gco(u);
        return u;
    }
}
