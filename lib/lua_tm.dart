library kurumi;

class LuaTM {
  static int convertTMStoInt(LuaTM.TMS tms) {
    switch (tms) {
      case TM_INDEX:
        return 0;
      case TM_NEWINDEX:
        return 1;
      case TM_GC:
        return 2;
      case TM_MODE:
        return 3;
      case TM_EQ:
        return 4;
      case TM_ADD:
        return 5;
      case TM_SUB:
        return 6;
      case TM_MUL:
        return 7;
      case TM_DIV:
        return 8;
      case TM_MOD:
        return 9;
      case TM_POW:
        return 10;
      case TM_UNM:
        return 11;
      case TM_LEN:
        return 12;
      case TM_LT:
        return 13;
      case TM_LE:
        return 14;
      case TM_CONCAT:
        return 15;
      case TM_CALL:
        return 16;
      case TM_N:
        return 17;
    }
    throw new RuntimeException("convertTMStoInt error");
  }

      static LuaObject.TValue gfasttm(LuaState.global_State g, LuaObject.Table et, TMS e)
    {
        return (et == null) ? null : (((et.flags & (1 << e.getValue())) != 0) ? null : luaT_gettm(et, e, g.tmname[e.getValue()]));
    }

    static LuaObject.TValue fasttm(LuaState.lua_State l, LuaObject.Table et, TMS e)
    {
        return gfasttm(LuaState.G(l), et, e);
    }
    static final List<CLib.CharPtr> luaT_typenames = [CLib.CharPtr.toCharPtr("nil"), CLib.CharPtr.toCharPtr("boolean"), CLib.CharPtr.toCharPtr("userdata"), CLib.CharPtr.toCharPtr("number"), CLib.CharPtr.toCharPtr("string"), CLib.CharPtr.toCharPtr("table"), CLib.CharPtr.toCharPtr("function"), CLib.CharPtr.toCharPtr("userdata"), CLib.CharPtr.toCharPtr("thread"), CLib.CharPtr.toCharPtr("proto"), CLib.CharPtr.toCharPtr("upval")];


    static final List<CLib.CharPtr> luaT_eventname = [CLib.CharPtr.toCharPtr("__index"), CLib.CharPtr.toCharPtr("__newindex"), CLib.CharPtr.toCharPtr("__gc"), CLib.CharPtr.toCharPtr("__mode"), CLib.CharPtr.toCharPtr("__eq"), CLib.CharPtr.toCharPtr("__add"), CLib.CharPtr.toCharPtr("__sub"), CLib.CharPtr.toCharPtr("__mul"), CLib.CharPtr.toCharPtr("__div"), CLib.CharPtr.toCharPtr("__mod"), CLib.CharPtr.toCharPtr("__pow"), CLib.CharPtr.toCharPtr("__unm"), CLib.CharPtr.toCharPtr("__len"), CLib.CharPtr.toCharPtr("__lt"), CLib.CharPtr.toCharPtr("__le"), CLib.CharPtr.toCharPtr("__concat"), CLib.CharPtr.toCharPtr("__call")];

    static void luaT_init(LuaState.lua_State L)
    {
        int i;
        for ((i = 0); i < TMS.TM_N.getValue(); i++) {
            LuaState.G(L).tmname[i] = LuaString.luaS_new(L, luaT_eventname[i]);
            LuaString.luaS_fix(LuaState.G(L).tmname[i]);
        }
    }

        static LuaObject.TValue luaT_gettm(LuaObject.Table events, TMS event_, LuaObject.TString ename)
    {
        LuaObject.TValue tm = LuaTable.luaH_getstr(events, ename);
        LuaLimits.lua_assert(convertTMStoInt(event_) <= convertTMStoInt(TMS_.TM_EQ));
        if (LuaObject.ttisnil(tm)) {
            events.flags |= (1 << event_.getValue());
            return null;
        } else {
            return tm;
        }
    }

        static LuaObject.TValue luaT_gettmbyobj(LuaState.lua_State L, LuaObject.TValue o, TMS event_)
    {
        LuaObject.Table mt;
        switch (LuaObject.ttype(o)) {
            case Lua.LUA_TTABLE:
                mt = LuaObject.hvalue(o).metatable;
                break;
            case Lua.LUA_TUSERDATA:
                mt = LuaObject.uvalue(o).metatable;
                break;
            default:
                mt = LuaState.G(L).mt[LuaObject.ttype(o)];
                break;
        }
        return (mt != null) ? LuaTable.luaH_getstr(mt, LuaState.G(L).tmname[event_.getValue()]) : LuaObject.luaO_nilobject;
    }
}

/*
  * WARNING: if you change the order of this enumeration,
  * grep "ORDER TM"
  */
public static enum TMS
{
  TM_INDEX,
  TM_NEWINDEX,
  TM_GC,
  TM_MODE,
  TM_EQ,  /* last tag method with `fast' access */
  TM_ADD,
  TM_SUB,
  TM_MUL,
  TM_DIV,
  TM_MOD,
  TM_POW,
  TM_UNM,
  TM_LEN,
  TM_LT,
  TM_LE,
  TM_CONCAT,
  TM_CALL,
  TM_N;		/* number of elements in the enum */

  public int getValue() {
    return this.ordinal();
  }

  public static TMS forValue(int value) {
    return values()[value];
  }
}	

