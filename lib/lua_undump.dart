library kurumi;

class LuaUndump
{
    static const int LUAC_VERSION = 81;
    static const int LUAC_FORMAT = 0;
    static const int LUAC_HEADERSIZE = 12;

    static void IF(int c, String s)
    {
    }

    static void IF(bool c, String s)
    {
    }

    static void error(LoadState S, CLib.CharPtr why)
    {
        LuaObject.luaO_pushfstring(S.L, CLib.CharPtr.toCharPtr("%s: %s in precompiled chunk"), S.name, why);
        LuaDo.luaD_throw(S.L, Lua.LUA_ERRSYNTAX);
    }

    static Object LoadMem(LoadState S, ClassType t)
    {
        int size = t.GetMarshalSizeOf();
        CLib.CharPtr str = CLib.CharPtr.toCharPtr(new char[size]);
        LoadBlock(S, str, size);
        List<int> bytes = new List<int>(str.chars.length);
        for (int i = 0; i < str.chars.length; i++) {
            bytes[i] = str.chars[i];
        }
        Object b = t.bytesToObj(bytes);
        return b;
    }

    static Object LoadMem(LoadState S, ClassType t, int n)
    {
        List<Object> array = new List<Object>(n);
        for (int i = 0; i < n; i++) {
            array[i] = LoadMem(S, t);
        }
        return t.ToArray(array);
    }

    static int LoadByte(LoadState S)
    {
        return LoadChar(S);
    }

    static Object LoadVar(LoadState S, ClassType t)
    {
        return LoadMem(S, t);
    }

    static Object LoadVector(LoadState S, ClassType t, int n)
    {
        return LoadMem(S, t, n);
    }

    static void LoadBlock(LoadState S, CLib.CharPtr b, int size)
    {
        int r = LuaZIO.luaZ_read(S.Z, b, size);
        IF(r != 0, "unexpected end");
    }

    static int LoadChar(LoadState S)
    {
        return LoadVar(S, new ClassType(ClassType_.TYPE_CHAR)).charValue();
    }

    static int LoadInt(LoadState S)
    {
        int x = LoadVar(S, new ClassType(ClassType_.TYPE_INT)).intValue();
        IF(x < 0, "bad integer");
        return x;
    }

    static double LoadNumber(LoadState S)
    {
        return LoadVar(S, new ClassType(ClassType_.TYPE_DOUBLE)).doubleValue();
    }

    static LuaObject.TString LoadString(LoadState S)
    {
        int size = LoadVar(S, new ClassType(ClassType_.TYPE_INT)).intValue();
        if (size == 0) {
            return null;
        } else {
            CLib.CharPtr s = LuaZIO.luaZ_openspace(S.L, S.b, size);
            LoadBlock(S, s, size);
            return LuaString.luaS_newlstr(S.L, s, size - 1);
        }
    }

    static void LoadCode(LoadState S, LuaObject.Proto f)
    {
        int n = LoadInt(S);
        f.code = LuaMem.luaM_newvector_long(S.L, n, new ClassType(ClassType_.TYPE_LONG));
        f.sizecode = n;
        f.code = (long[])LoadVector(S, new ClassType(ClassType.TYPE_LONG), n); //Instruction[] - UInt32[]
    }

    static void LoadConstants(LoadState S, LuaObject.Proto f)
    {
        int i;
        int n;
        n = LoadInt(S);
        f.k = LuaMem.luaM_newvector_TValue(S.L, n, new ClassType(ClassType_.TYPE_TVALUE));
        f.sizek = n;
        for ((i = 0); i < n; i++) {
            LuaObject.setnilvalue(f.k[i]);
        }
        for ((i = 0); i < n; i++) {
            LuaObject.TValue o = f.k[i];
            int t = LoadChar(S);
            switch (t) {
                case Lua.LUA_TNIL:
                    LuaObject.setnilvalue(o);
                    break;
                case Lua.LUA_TBOOLEAN:
                    LuaObject.setbvalue(o, LoadChar(S));
                    break;
                case Lua.LUA_TNUMBER:
                    LuaObject.setnvalue(o, LoadNumber(S));
                    break;
                case Lua.LUA_TSTRING:
                    LuaObject.setsvalue2n(S.L, o, LoadString(S));
                    break;
                default:
                    error(S, CLib.CharPtr.toCharPtr("bad constant"));
                    break;
            }
        }
        n = LoadInt(S);
        f.p = LuaMem.luaM_newvector_Proto(S.L, n, new ClassType(ClassType_.TYPE_PROTO));
        f.sizep = n;
        for ((i = 0); i < n; i++) {
            f.p[i] = null;
        }
        for ((i = 0); i < n; i++) {
            f.p[i] = LoadFunction(S, f.source);
        }
    }

    static void LoadDebug(LoadState S, LuaObject.Proto f)
    {
        int i;
        int n;
        n = LoadInt(S);
        f.lineinfo = LuaMem.luaM_newvector_int(S.L, n, new ClassType(ClassType_.TYPE_INT));
        f.sizelineinfo = n;
        f.lineinfo = (int[])LoadVector(S, new ClassType(ClassType.TYPE_INT), n); //typeof(int)
        n = LoadInt(S);
        f.locvars = LuaMem.luaM_newvector_LocVar(S.L, n, new ClassType(ClassType_.TYPE_LOCVAR));
        f.sizelocvars = n;
        for ((i = 0); i < n; i++) {
            f.locvars[i].varname = null;
        }
        for ((i = 0); i < n; i++) {
            f.locvars[i].varname = LoadString(S);
            f.locvars[i].startpc = LoadInt(S);
            f.locvars[i].endpc = LoadInt(S);
        }
        n = LoadInt(S);
        f.upvalues = LuaMem.luaM_newvector_TString(S.L, n, new ClassType(ClassType_.TYPE_TSTRING));
        f.sizeupvalues = n;
        for ((i = 0); i < n; i++) {
            f.upvalues[i] = null;
        }
        for ((i = 0); i < n; i++) {
            f.upvalues[i] = LoadString(S);
        }
    }

    static LuaObject.Proto LoadFunction(LoadState S, LuaObject.TString p)
    {
        LuaObject.Proto f;
        if ((++S.L.nCcalls) > LuaConf.LUAI_MAXCCALLS) {
            error(S, CLib.CharPtr.toCharPtr("code too deep"));
        }
        f = LuaFunc.luaF_newproto(S.L);
        LuaObject.setptvalue2s(S.L, S.L.top, f);
        LuaDo.incr_top(S.L);
        f.source = LoadString(S);
        if (f.source == null) {
            f.source = p;
        }
        f.linedefined = LoadInt(S);
        f.lastlinedefined = LoadInt(S);
        f.nups = LoadByte(S);
        f.numparams = LoadByte(S);
        f.is_vararg = LoadByte(S);
        f.maxstacksize = LoadByte(S);
        LoadCode(S, f);
        LoadConstants(S, f);
        LoadDebug(S, f);
        IF((LuaDebug.luaG_checkcode(f) == 0) ? 1 : 0, "bad code");
        LuaObject.TValue[] top = new LuaObject.TValue[1];
        top[0] = S.L.top;
        LuaObject.TValue.dec(top);
        S.L.top = top[0];
        S.L.nCcalls--;
        return f;
    }

    static void LoadHeader(LoadState S)
    {
        CLib.CharPtr h = CLib.CharPtr.toCharPtr(new char[LUAC_HEADERSIZE]);
		    CLib.CharPtr s = CLib.CharPtr.toCharPtr(new char[LUAC_HEADERSIZE]);
        luaU_header(h);
        LoadBlock(S, s, LUAC_HEADERSIZE);
        IF(CLib.memcmp(h, s, LUAC_HEADERSIZE) != 0, "bad header");
    }

    static LuaObject.Proto luaU_undump(LuaState.lua_State L, LuaZIO.ZIO Z, LuaZIO.Mbuffer buff, CLib.CharPtr name)
    {
        LoadState S = new LoadState();
        if ((name.get(0) == '@'.codeUnitAt(0)) || (name.get(0) == '='.codeUnitAt(0))) {
            S.name = CLib.CharPtr.plus(name, 1);
        } else {
            if (name.get(0) == Lua.LUA_SIGNATURE.codeUnitAt(0)) {
                S.name = CLib.CharPtr.toCharPtr("binary string");
            } else {
                S.name = name;
            }
        }
        S.L = L;
        S.Z = Z;
        S.b = buff;
        LoadHeader(S);
        return LoadFunction(S, LuaString.luaS_newliteral(L, CLib.CharPtr.toCharPtr("=?")));
    }

    static void luaU_header(CLib.CharPtr h)
    {
        h = new CLib.CharPtr(h);
        int x = 1;
        CLib.memcpy(h, CLib.CharPtr.toCharPtr(Lua.LUA_SIGNATURE), Lua.LUA_SIGNATURE.length);
        h = h.add(Lua.LUA_SIGNATURE.length);
        h.set(0, LUAC_VERSION);
        h.inc();
        h.set(0, LUAC_FORMAT);
        h.inc();
        h.set(0, x);
        h.inc();
        h.set(0, ClassType_.SizeOfInt());
        h.inc();
        h.set(0, ClassType_.SizeOfLong());
        h.inc();
        h.set(0, ClassType_.SizeOfLong());
        h.inc();
        h.set(0, ClassType_.SizeOfDouble());
        h.inc();
        h.set(0, 0);
    }
}

class LoadState
{
    LuaState.lua_State L;
    LuaZIO.ZIO Z;
    LuaZIO.Mbuffer b;
    CLib.CharPtr name;
}
