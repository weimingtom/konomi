library kurumi;

class LuaAuxLib
{

    static int luaL_getn(LuaState.lua_State L, int i)
    {
        return LuaAPI.lua_objlen(L, i);
    }

    static void luaL_setn(LuaState.lua_State L, int i, int j)
    {
    }
    static const int LUA_ERRFILE = (Lua.LUA_ERRERR + 1);

    static void luaL_argcheck(LuaState.lua_State L, bool cond, int numarg, String extramsg)
    {
        if (!cond) {
            luaL_argerror(L, numarg, CLib.CharPtr.toCharPtr(extramsg));
        }
    }

    static CLib.CharPtr luaL_checkstring(LuaState.lua_State L, int n)
    {
        return luaL_checklstring(L, n);
    }

    static CLib.CharPtr luaL_optstring(LuaState.lua_State L, int n, CLib.CharPtr d)
    {
        List<int> len = new List<int>(1);
        return luaL_optlstring(L, n, d, len);
    }

    static int luaL_checkint(LuaState.lua_State L, int n)
    {
        return luaL_checkinteger(L, n);
    }

    static int luaL_optint(LuaState.lua_State L, int n, int d)
    {
        return luaL_optinteger(L, n, d);
    }

    static int luaL_checklong(LuaState.lua_State L, int n)
    {
        return luaL_checkinteger(L, n);
    }

    static int luaL_optlong(LuaState.lua_State L, int n, int d)
    {
        return luaL_optinteger(L, n, d);
    }

    static CLib.CharPtr luaL_typename(LuaState.lua_State L, int i)
    {
        return LuaAPI.lua_typename(L, LuaAPI.lua_type(L, i));
    }

    static void luaL_getmetatable(LuaState.lua_State L, CLib.CharPtr n)
    {
        LuaAPI.lua_getfield(L, Lua.LUA_REGISTRYINDEX, n);
    }

    abstract class luaL_opt_delegate
    {

        double exec(LuaState.lua_State L, int narg);
    }

    static double luaL_opt(LuaState.lua_State L, luaL_opt_delegate f, int n, double d)
    {
        return Lua.lua_isnoneornil(L, (n != 0) ? d : f.exec(L, n)) ? 1 : 0;
    }

    abstract class luaL_opt_delegate_integer
    {

        int exec(LuaState.lua_State L, int narg);
    }

    static int luaL_opt_integer(LuaState.lua_State L, luaL_opt_delegate_integer f, int n, double d)
    {
        return Lua.lua_isnoneornil(L, n) ? d : f.exec(L, n);
    }

    static void luaL_addchar(luaL_Buffer B, int c)
    {
        if (B.p >= LuaConf.LUAL_BUFFERSIZE) {
            luaL_prepbuffer(B);
        }
        B.buffer.set(B.p++, c);
    }

    static void luaL_putchar(luaL_Buffer B, int c)
    {
        luaL_addchar(B, c);
    }

    static void luaL_addsize(luaL_Buffer B, int n)
    {
        B.p += n;
    }
    static const int LUA_NOREF = (-2);
    static const int LUA_REFNIL = (-1);
    static const int FREELIST_REF = 0;

    static int abs_index(LuaState.lua_State L, int i)
    {
        return ((i > 0) || (i <= Lua.LUA_REGISTRYINDEX)) ? i : (LuaAPI.lua_gettop(L) + (+1));
    }

    static int luaL_argerror(LuaState.lua_State L, int narg, CLib.CharPtr extramsg)
    {
        Lua.lua_Debug ar = new Lua.lua_Debug();
        if (LuaDebug.lua_getstack(L, 0, ar) == 0) {
            return luaL_error(L, CLib.CharPtr.toCharPtr("bad argument #%d (%s)"), narg, extramsg);
        }
        LuaDebug.lua_getinfo(L, CLib.CharPtr.toCharPtr("n"), ar);
        if (CLib.strcmp(ar.namewhat, CLib.CharPtr.toCharPtr("method")) == 0) {
            narg--;
            if (narg == 0) {
                return luaL_error(L, CLib.CharPtr.toCharPtr(("calling " + LuaConf.getLUA_QS()) + " on bad self ({1})"), ar.name, extramsg);
            }
        }
        if (CLib.CharPtr.isEqual(ar.name, null)) {
            ar.name = CLib.CharPtr.toCharPtr("?");
        }
        return luaL_error(L, CLib.CharPtr.toCharPtr(("bad argument #%d to " + LuaConf.getLUA_QS()) + " (%s)"), narg, ar.name, extramsg);
    }

    static int luaL_typerror(LuaState.lua_State L, int narg, CLib.CharPtr tname)
    {
        CLib.CharPtr msg = LuaAPI.lua_pushfstring(L, CLib.CharPtr.toCharPtr("%s expected, got %s"), tname, luaL_typename(L, narg));
        return luaL_argerror(L, narg, msg);
    }

    static void tag_error(LuaState.lua_State L, int narg, int tag)
    {
        luaL_typerror(L, narg, LuaAPI.lua_typename(L, tag));
    }

    static void luaL_where(LuaState.lua_State L, int level)
    {
        Lua.lua_Debug ar = new Lua.lua_Debug();
        if (LuaDebug.lua_getstack(L, level, ar) != 0) {
            LuaDebug.lua_getinfo(L, CLib.CharPtr.toCharPtr("Sl"), ar);
            if (ar.currentline > 0) {
                LuaAPI.lua_pushfstring(L, CLib.CharPtr.toCharPtr("%s:%d: "), ar.short_src, ar.currentline);
                return;
            }
        }
        Lua.lua_pushliteral(L, CLib.CharPtr.toCharPtr(""));
    }

    static int luaL_error(LuaState.lua_State L, CLib.CharPtr fmt, List<Object> p /*XXX*/)
    {
        luaL_where(L, 1);
        LuaAPI.lua_pushvfstring(L, fmt, p);
        LuaAPI.lua_concat(L, 2);
        return LuaAPI.lua_error(L);
    }

    static int luaL_checkoption(LuaState.lua_State L, int narg, CLib.CharPtr def, List<CLib.CharPtr> lst)
    {
        CLib.CharPtr name = (CLib.CharPtr.isNotEqual(def, null)) ? luaL_optstring(L, narg, def) : luaL_checkstring(L, narg);
        int i;
        for ((i = 0); i < lst.length; i++) {
            if (CLib.strcmp(lst[i], name) == 0) {
                return i;
            }
        }
        return luaL_argerror(L, narg, LuaAPI.lua_pushfstring(L, CLib.CharPtr.toCharPtr("invalid option " + LuaConf.getLUA_QS()), name));
    }

    static int luaL_newmetatable(LuaState.lua_State L, CLib.CharPtr tname)
    {
        LuaAPI.lua_getfield(L, Lua.LUA_REGISTRYINDEX, tname);
        if (!Lua.lua_isnil(L, -1)) {
            return 0;
        }
        Lua.lua_pop(L, 1);
        Lua.lua_newtable(L);
        LuaAPI.lua_pushvalue(L, -1);
        LuaAPI.lua_setfield(L, Lua.LUA_REGISTRYINDEX, tname);
        return 1;
    }

    static Object luaL_checkudata(LuaState.lua_State L, int ud, CLib.CharPtr tname)
    {
        Object p = LuaAPI.lua_touserdata(L, ud);
        if (p != null) {
            if (LuaAPI.lua_getmetatable(L, ud) != 0) {
                LuaAPI.lua_getfield(L, Lua.LUA_REGISTRYINDEX, tname);
                if (LuaAPI.lua_rawequal(L, -1, -2) != 0) {
                    Lua.lua_pop(L, 2);
                    return p;
                }
            }
        }
        luaL_typerror(L, ud, tname);
        return null;
    }

    static void luaL_checkstack(LuaState.lua_State L, int space, CLib.CharPtr mes)
    {
        if (LuaAPI.lua_checkstack(L, space) == 0) {
            luaL_error(L, CLib.CharPtr.toCharPtr("stack overflow (%s)"), mes);
        }
    }

    static void luaL_checktype(LuaState.lua_State L, int narg, int t)
    {
        if (LuaAPI.lua_type(L, narg) != t) {
            tag_error(L, narg, t);
        }
    }

    static void luaL_checkany(LuaState.lua_State L, int narg)
    {
        if (LuaAPI.lua_type(L, narg) == Lua.LUA_TNONE) {
            luaL_argerror(L, narg, CLib.CharPtr.toCharPtr("value expected"));
        }
    }

    static CLib.CharPtr luaL_checklstring(LuaState.lua_State L, int narg)
    {
        List<int> len = new List<int>(1);
        return luaL_checklstring(L, narg, len);
    }

    static CLib.CharPtr luaL_checklstring(LuaState.lua_State L, int narg, List<int> len)
    {
        CLib.CharPtr s = LuaAPI.lua_tolstring(L, narg, len); //out
        if (CLib.CharPtr.isEqual(s, null)) {
            tag_error(L, narg, Lua.LUA_TSTRING);
        }
        return s;
    }

    static CLib.CharPtr luaL_optlstring(LuaState.lua_State L, int narg, CLib.CharPtr def)
    {
        List<int> len = new List<int>(1);
        return luaL_optlstring(L, narg, def, len);
    }

    static CLib.CharPtr luaL_optlstring(LuaState.lua_State L, int narg, CLib.CharPtr def, List<int> len)
    {
        if (Lua.lua_isnoneornil(L, narg)) {
            len[0] = (CLib.CharPtr.isNotEqual(def, null) ? CLib.strlen(def) : 0);
            return def;
        } else {
            return luaL_checklstring(L, narg, len);
        }
    }

    static double luaL_checknumber(LuaState.lua_State L, int narg)
    {
        double d = LuaAPI.lua_tonumber(L, narg);
        if ((d == 0) && (LuaAPI.lua_isnumber(L, narg) == 0)) {
            tag_error(L, narg, Lua.LUA_TNUMBER);
        }
        return d;
    }

    static double luaL_optnumber(LuaState.lua_State L, int narg, double def)
    {
        return luaL_opt(L, new luaL_checknumber_delegate(), narg, def);
    }

    static int luaL_checkinteger(LuaState.lua_State L, int narg)
    {
        int d = LuaAPI.lua_tointeger(L, narg);
        if ((d == 0) && (LuaAPI.lua_isnumber(L, narg) == 0)) {
            tag_error(L, narg, Lua.LUA_TNUMBER);
        }
        return d;
    }

    static int luaL_optinteger(LuaState.lua_State L, int narg, int def)
    {
        return luaL_opt_integer(L, new luaL_checkinteger_delegate(), narg, def);
    }

    static int luaL_getmetafield(LuaState.lua_State L, int obj, CLib.CharPtr event_)
    {
        if (LuaAPI.lua_getmetatable(L, obj) == 0) {
            return 0;
        }
        LuaAPI.lua_pushstring(L, event_);
        LuaAPI.lua_rawget(L, -2);
        if (Lua.lua_isnil(L, -1)) {
            Lua.lua_pop(L, 2);
            return 0;
        } else {
            LuaAPI.lua_remove(L, -2);
            return 1;
        }
    }

    static int luaL_callmeta(LuaState.lua_State L, int obj, CLib.CharPtr event_)
    {
        obj = abs_index(L, obj);
        if (luaL_getmetafield(L, obj, event_) == 0) {
            return 0;
        }
        LuaAPI.lua_pushvalue(L, obj);
        LuaAPI.lua_call(L, 1, 1);
        return 1;
    }

    static void luaL_register(LuaState.lua_State L, CLib.CharPtr libname, List<luaL_Reg> l)
    {
        luaI_openlib(L, libname, l, 0);
    }

    static int libsize(List<luaL_Reg> l)
    {
        int size = 0;
        for (; CLib.CharPtr.isNotEqual(l[size].name, null); size++) {
        }
        return size;
    }

    static void luaI_openlib(LuaState.lua_State L, CLib.CharPtr libname, List<luaL_Reg> l, int nup)
    {
        if (CLib.CharPtr.isNotEqual(libname, null)) {
            int size = libsize(l);
            luaL_findtable(L, Lua.LUA_REGISTRYINDEX, CLib.CharPtr.toCharPtr("_LOADED"), 1);
            LuaAPI.lua_getfield(L, -1, libname);
            if (!Lua.lua_istable(L, -1)) {
                Lua.lua_pop(L, 1);
                if (CLib.CharPtr.isNotEqual(luaL_findtable(L, Lua.LUA_GLOBALSINDEX, libname, size), null)) {
                    luaL_error(L, CLib.CharPtr.toCharPtr("name conflict for module " + LuaConf.getLUA_QS()), libname);
                }
                LuaAPI.lua_pushvalue(L, -1);
                LuaAPI.lua_setfield(L, -3, libname);
            }
            LuaAPI.lua_remove(L, -2);
            LuaAPI.lua_insert(L, -(nup + 1));
        }
        int reg_num = 0;
        for (; CLib.CharPtr.isNotEqual(l[reg_num].name, null); reg_num++) {
            int i;
            for ((i = 0); i < nup; i++) {
                LuaAPI.lua_pushvalue(L, -nup);
            }
            LuaAPI.lua_pushcclosure(L, l[reg_num].func, nup);
            LuaAPI.lua_setfield(L, -(nup + 2), l[reg_num].name);
        }
        Lua.lua_pop(L, nup);
    }

    static CLib.CharPtr luaL_gsub(LuaState.lua_State L, CLib.CharPtr s, CLib.CharPtr p, CLib.CharPtr r)
    {
        CLib.CharPtr wild;
        int l = CLib.strlen(p);
        luaL_Buffer b = new luaL_Buffer();
        luaL_buffinit(L, b);
        while (CLib.CharPtr.isNotEqual(wild = CLib.strstr(s, p), null)) {
            luaL_addlstring(b, s, CLib.CharPtr.minus(wild, s));
            luaL_addstring(b, r);
            s = CLib.CharPtr.plus(wild, l);
        }
        luaL_addstring(b, s);
        luaL_pushresult(b);
        return Lua.lua_tostring(L, -1);
    }

    static CLib.CharPtr luaL_findtable(LuaState.lua_State L, int idx, CLib.CharPtr fname, int szhint)
    {
        CLib.CharPtr e;
        LuaAPI.lua_pushvalue(L, idx);
        do {
            e = CLib.strchr(fname, '.'.codeUnitAt(0));
            if (CLib.CharPtr.isEqual(e, null)) {
                e = CLib.CharPtr.plus(fname, CLib.strlen(fname));
            }
            LuaAPI.lua_pushlstring(L, fname, CLib.CharPtr.minus(e, fname));
            LuaAPI.lua_rawget(L, -2);
            if (Lua.lua_isnil(L, -1)) {
                Lua.lua_pop(L, 1);
                LuaAPI.lua_createtable(L, 0, CLib.CharPtr.isEqualChar(e, '.'.codeUnitAt(0)) ? 1 : szhint);
                LuaAPI.lua_pushlstring(L, fname, CLib.CharPtr.minus(e, fname));
                LuaAPI.lua_pushvalue(L, -2);
                LuaAPI.lua_settable(L, -4);
            } else {
                if (!Lua.lua_istable(L, -1)) {
                    Lua.lua_pop(L, 2);
                    return fname;
                }
            }
            LuaAPI.lua_remove(L, -2);
            fname = CLib.CharPtr.plus(e, 1);
        } while (CLib.CharPtr.isEqualChar(e, '.'.codeUnitAt(0)));
        return null;
    }

    static int bufflen(luaL_Buffer B)
    {
        return B.p;
    }

    static int bufffree(luaL_Buffer B)
    {
        return LuaConf.LUAL_BUFFERSIZE - bufflen(B);
    }
    static const int LIMIT = (Lua.LUA_MINSTACK ~/ 2);

    static int emptybuffer(luaL_Buffer B)
    {
        int l = bufflen(B);
        if (l == 0) {
            return 0;
        } else {
            LuaAPI.lua_pushlstring(B.L, B.buffer, l);
            B.p = 0;
            B.lvl++;
            return 1;
        }
    }

    static void adjuststack(luaL_Buffer B)
    {
        if (B.lvl > 1) {
            LuaState.lua_State L = B.L;
            int toget = 1;
            int toplen = Lua.lua_strlen(L, -1);
            do {
                int l = Lua.lua_strlen(L, -(toget + 1));
                if ((((B.lvl - toget) + 1) >= LIMIT) || (toplen > l)) {
                    toplen += l;
                    toget++;
                } else {
                    break;
                }
            } while (toget < B.lvl);
            LuaAPI.lua_concat(L, toget);
            B.lvl = ((B.lvl - toget) + 1);
        }
    }

    static CLib.CharPtr luaL_prepbuffer(luaL_Buffer B)
    {
        if (emptybuffer(B) != 0) {
            adjuststack(B);
        }
        return new CLib.CharPtr(B.buffer, B.p);
    }

    static void luaL_addlstring(luaL_Buffer B, CLib.CharPtr s, int l)
    {
        while (l-- != 0) {
            int c = s.get(0);
            s = s.next();
            luaL_addchar(B, c);
        }
    }

    static void luaL_addstring(luaL_Buffer B, CLib.CharPtr s)
    {
        luaL_addlstring(B, s, CLib.strlen(s));
    }

    static void luaL_pushresult(luaL_Buffer B)
    {
        emptybuffer(B);
        LuaAPI.lua_concat(B.L, B.lvl);
        B.lvl = 1;
    }

    static void luaL_addvalue(luaL_Buffer B)
    {
        LuaState.lua_State L = B.L;
        List<int> vl = new List<int>(1);
        CLib.CharPtr s = LuaAPI.lua_tolstring(L, -1, vl); //out
        if (vl[0] <= bufffree(B)) {
            CLib.CharPtr dst = new CLib.CharPtr(B.buffer.chars, B.buffer.index + B.p);
			      CLib.CharPtr src = new CLib.CharPtr(s.chars, s.index);
            for (int i = 0; i < vl[0]; i++) {
                dst.set(i, src.get(i));
            }
            B.p += vl[0];
            Lua.lua_pop(L, 1);
        } else {
            if (emptybuffer(B) != 0) {
                LuaAPI.lua_insert(L, -2);
            }
            B.lvl++;
            adjuststack(B);
        }
    }

    static void luaL_buffinit(LuaState.lua_State L, luaL_Buffer B)
    {
        B.L = L;
        B.p = 0;
        B.lvl = 0;
    }

    static int luaL_ref(LuaState.lua_State L, int t)
    {
        int ref_;
        t = abs_index(L, t);
        if (Lua.lua_isnil(L, -1)) {
            Lua.lua_pop(L, 1);
            return LUA_REFNIL;
        }
        LuaAPI.lua_rawgeti(L, t, FREELIST_REF);
        ref_ = LuaAPI.lua_tointeger(L, -1);
        Lua.lua_pop(L, 1);
        if (ref_ != 0) {
            LuaAPI.lua_rawgeti(L, t, ref_);
            LuaAPI.lua_rawseti(L, t, FREELIST_REF);
        } else {
            ref_ = LuaAPI.lua_objlen(L, t);
            ref_++;
        }
        LuaAPI.lua_rawseti(L, t, ref_);
        return ref_;
    }

    static void luaL_unref(LuaState.lua_State L, int t, int ref_)
    {
        if (ref_ >= 0) {
            t = abs_index(L, t);
            LuaAPI.lua_rawgeti(L, t, FREELIST_REF);
            LuaAPI.lua_rawseti(L, t, ref_);
            LuaAPI.lua_pushinteger(L, ref_);
            LuaAPI.lua_rawseti(L, t, FREELIST_REF);
        }
    }

    static CLib.CharPtr getF(LuaState.lua_State L, Object ud, List<int> size)
    {
        size[0] = 0;
        LoadF lf = ud;
        if (lf.extraline != 0) {
            lf.extraline = 0;
            size[0] = 1;
            return CLib.CharPtr.toCharPtr("\n");
        }
        if (CLib.feof(lf.f) != 0) {
            return null;
        }
        size[0] = CLib.fread(lf.buff, 1, lf.buff.chars.length, lf.f);
        return (size[0] > 0) ? new CLib.CharPtr(lf.buff) : null;
    }

    static int errfile(LuaState.lua_State L, CLib.CharPtr what, int fnameindex)
    {
        CLib.CharPtr serr = CLib.strerror(CLib.errno());
		    CLib.CharPtr filename = CLib.CharPtr.plus(Lua.lua_tostring(L, fnameindex), 1);
        LuaAPI.lua_pushfstring(L, CLib.CharPtr.toCharPtr("cannot %s %s: %s"), what, filename, serr);
        LuaAPI.lua_remove(L, fnameindex);
        return LUA_ERRFILE;
    }

    static int luaL_loadfile(LuaState.lua_State L, CLib.CharPtr filename)
    {
        LoadF lf = new LoadF();
        int status;
        int readstatus;
        int c;
        int fnameindex = (LuaAPI.lua_gettop(L) + 1);
        lf.extraline = 0;
        if (CLib.CharPtr.isEqual(filename, null)) {
            Lua.lua_pushliteral(L, CLib.CharPtr.toCharPtr("=stdin"));
            lf.f = CLib.stdin;
        } else {
            LuaAPI.lua_pushfstring(L, CLib.CharPtr.toCharPtr("@%s"), filename);
            lf.f = CLib.fopen(filename, CLib.CharPtr.toCharPtr("r"));
            if (lf.f == null) {
                return errfile(L, CLib.CharPtr.toCharPtr("open"), fnameindex);
            }
        }
        c = CLib.getc(lf.f);
        if (c == '#'.codeUnitAt(0)) {
            lf.extraline = 1;
            while (((c = CLib.getc(lf.f)) != CLib.EOF) && (c != '\n'.codeUnitAt(0))) {
            }
            if (c == '\n'.codeUnitAt(0)) {
                c = CLib.getc(lf.f);
            }
        }
        if ((c == Lua.LUA_SIGNATURE.codeUnitAt(0)) && CLib.CharPtr.isNotEqual(filename, null)) {
            lf.f = CLib.freopen(filename, CLib.CharPtr.toCharPtr("rb"), lf.f);
            if (lf.f == null) {
                return errfile(L, CLib.CharPtr.toCharPtr("reopen"), fnameindex);
            }
            while (((c = CLib.getc(lf.f)) != CLib.EOF) && (c != Lua.LUA_SIGNATURE.codeUnitAt(0))) {
            }
            lf.extraline = 0;
        }
        CLib.ungetc(c, lf.f);
        status = LuaAPI.lua_load(L, new getF_delegate(), lf, Lua.lua_tostring(L, -1));
        readstatus = CLib.ferror(lf.f);
        if (CLib.CharPtr.isNotEqual(filename, null)) {
            CLib.fclose(lf.f);
        }
        if (readstatus != 0) {
            LuaAPI.lua_settop(L, fnameindex);
            return errfile(L, CLib.CharPtr.toCharPtr("read"), fnameindex);
        }
        LuaAPI.lua_remove(L, fnameindex);
        return status;
    }

    static CLib.CharPtr getS(LuaState.lua_State L, Object ud, List<int> size)
    {
        LoadS ls = ud;
        size[0] = ls.size;
        ls.size = 0;
        return ls.s;
    }

    static int luaL_loadbuffer(LuaState.lua_State L, CLib.CharPtr buff, int size, CLib.CharPtr name)
    {
        LoadS ls = new LoadS();
        ls.s = new CLib.CharPtr(buff);
        ls.size = size;
        return LuaAPI.lua_load(L, new getS_delegate(), ls, name);
    }

    static int luaL_loadstring(LuaState.lua_State L, CLib.CharPtr s)
    {
        return luaL_loadbuffer(L, s, CLib.strlen(s), s);
    }

    static Object l_alloc(ClassType t)
    {
        return t.Alloc();
    }

    static int panic(LuaState.lua_State L)
    {
        CLib.fprintf(CLib.stderr, CLib.CharPtr.toCharPtr("PANIC: unprotected error in call to Lua API (%s)\n"), Lua.lua_tostring(L, -1));
        return 0;
    }

    static LuaState.lua_State luaL_newstate()
    {
        LuaState.lua_State L = LuaState.lua_newstate(new l_alloc_delegate(), null);
        if (L != null) {
            LuaAPI.lua_atpanic(L, new LuaAuxLib_delegate("panic"));
        }
        return L;
    }
}

class luaL_Reg
{
    CLib.CharPtr name;
    Lua.lua_CFunction func;

    luaL_Reg_(CLib.CharPtr name, Lua.lua_CFunction func)
    {
        this.name = name;
        this.func = func;
    }
}

class luaL_checkint_delegate with luaL_opt_delegate_integer
{

    final int exec(LuaState.lua_State L, int narg)
    {
        return luaL_checkint(L, narg);
    }
}

class luaL_Buffer
{
    int p;
    int lvl;
    LuaState.lua_State L;
    CLib.CharPtr buffer = CLib.CharPtr.toCharPtr(new List<int>(LuaConf.LUAL_BUFFERSIZE));
}

class luaL_checknumber_delegate with luaL_opt_delegate
{

    final double exec(LuaState.lua_State L, int narg)
    {
        return luaL_checknumber(L, narg);
    }
}

class luaL_checkinteger_delegate with luaL_opt_delegate_integer
{

    final int exec(LuaState.lua_State L, int narg)
    {
        return luaL_checkinteger(L, narg);
    }
}

class LoadF
{
    int extraline;
    StreamProxy f;
    CLib.CharPtr buff = CLib.CharPtr.toCharPtr(new List<int>(LuaConf.LUAL_BUFFERSIZE));
}

class LoadS
{
    CLib.CharPtr s;
    int size;
}

class l_alloc_delegate with Lua_lua_Alloc
{

    final Object exec(ClassType t)
    {
        return l_alloc(t);
    }
}

class LuaAuxLib_delegate with Lua_lua_CFunction
{
    String name;

    LuaAuxLib_delegate_(String name)
    {
        this.name = name;
    }

    final int exec(LuaState.lua_State L)
    {
        if (new String("panic") == name) {
            return panic(L);
        } else {
            return 0;
        }
    }
}

class getF_delegate with Lua_lua_Reader
{

    final CLib.CharPtr exec(LuaState.lua_State L, Object ud, List<int> sz)
    {
        return getF(L, ud, sz);
    }
}

class getS_delegate with Lua_lua_Reader
{

    final CLib.CharPtr exec(LuaState.lua_State L, Object ud, List<int> sz)
    {
        return getS(L, ud, sz);
    }
}
