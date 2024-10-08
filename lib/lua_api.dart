library kurumi;

class LuaAPI
{
    static final String lua_ident = (((((((("\$Lua: " + Lua.LUA_RELEASE) + " ") + Lua.LUA_COPYRIGHT) + " \$\n") + "\$Authors: ") + Lua.LUA_AUTHORS) + " \$\n") + "\$URL: www.lua.org \$\n");

    static void api_checknelems(LuaState.lua_State L, int n)
    {
        LuaLimits.api_check(L, n <= LuaObject.TValue.minus(L.top, L.base_));
    }

    static void api_checkvalidindex(LuaState.lua_State L, LuaObject.TValue i)
    {
        LuaLimits.api_check(L, i != LuaObject.luaO_nilobject);
    }

    static void api_incr_top(LuaState.lua_State L)
    {
        LuaLimits.api_check(L, LuaObject.TValue.lessThan(L.top, L.ci.top));
        LuaObject.TValue[] top = new LuaObject.TValue[1];
        top[0] = L.top;
        LuaObject.TValue.inc(top);
        L.top = top[0];
    }

    static LuaObject.TValue index2adr(LuaState.lua_State L, int idx)
    {
        if (idx > 0) {
            LuaObject.TValue o = LuaObject.TValue.plus(L.base_, (idx - 1));
            LuaLimits.api_check(L, idx <= LuaObject.TValue.minus(L.ci.top, L.base_));
            if (LuaObject.TValue.greaterEqual(o, L.top)) {
                return LuaObject.luaO_nilobject;
            } else {
                return o;
            }
        } else {
            if (idx > Lua.LUA_REGISTRYINDEX) {
                LuaLimits.api_check(L, (idx != 0) && ((-idx) <= LuaObject.TValue.minus(L.top, L.base_)));
                return LuaObject.TValue.plus(L.top, idx);
            } else {
                switch (idx) {
                    case Lua.LUA_REGISTRYINDEX:
                        return LuaState.registry(L);
                    case Lua.LUA_ENVIRONINDEX:
                        LuaObject.Closure func = LuaState.curr_func(L);
                        LuaObject.sethvalue(L, L.env, func.c.getEnv());
                        return L.env;
                    case Lua.LUA_GLOBALSINDEX:
                        return LuaState.gt(L);
                    default:
                        LuaObject.Closure func = LuaState.curr_func(L);
                        idx = (Lua.LUA_GLOBALSINDEX - idx);
                        return (idx <= func.c.getNupvalues()) ? func.c.upvalue[idx-1] : (LuaObject.TValue)LuaObject.luaO_nilobject;
                }
            }
        }
    }

    static LuaObject.Table getcurrenv(LuaState.lua_State L)
    {
        if (L.ci == L.base_ci[0]) {
            return LuaObject.hvalue(LuaState.gt(L));
        } else {
            LuaObject.Closure func = LuaState.curr_func(L);
            return func.c.getEnv();
        }
    }

    static void luaA_pushobject(LuaState.lua_State L, LuaObject.TValue o)
    {
        LuaObject.setobj2s(L, L.top, o);
        api_incr_top(L);
    }

    static int lua_checkstack(LuaState.lua_State L, int size)
    {
        int res = 1;
        LuaLimits.lua_lock(L);
        if ((size > LuaConf.LUAI_MAXCSTACK) || ((LuaObject.TValue.minus(L.top, L.base_) + size) > LuaConf.LUAI_MAXCSTACK)) {
            res = 0;
        } else {
            if (size > 0) {
                LuaDo.luaD_checkstack(L, size);
                if (LuaObject.TValue.lessThan(L.ci.top, LuaObject.TValue.plus(L.top, size))) {
                    L.ci.top = LuaObject.TValue.plus(L.top, size);
                }
            }
        }
        LuaLimits.lua_unlock(L);
        return res;
    }

    static void lua_xmove(LuaState.lua_State from, LuaState.lua_State to, int n)
    {
        int i;
        if (from == to) {
            return;
        }
        LuaLimits.lua_lock(to);
        api_checknelems(from, n);
        LuaLimits.api_check(from, LuaState.G(from) == LuaState.G(to));
        LuaLimits.api_check(from, LuaObject.TValue.minus(to.ci.top, to.top) >= n);
        from.top = LuaObject.TValue.minus(from.top, n);
        for ((i = 0); i < n; i++) {
            LuaObject.TValue[] top = new LuaObject.TValue[1];
            top[0] = to.top;
            LuaObject.TValue ret = LuaObject.TValue.inc(top); //ref - StkId
            to.top = top[0];
            LuaObject.setobj2s(to, ret, LuaObject.TValue.plus(from.top, i));
        }
        LuaLimits.lua_unlock(to);
    }

    static void lua_setlevel(LuaState.lua_State from, LuaState.lua_State to)
    {
        to.nCcalls = from.nCcalls;
    }

    static Lua.lua_CFunction lua_atpanic(LuaState.lua_State L, Lua.lua_CFunction panicf)
    {
        Lua.lua_CFunction old;
        LuaLimits.lua_lock(L);
        old = LuaState.G(L).panic;
        LuaState.G(L).panic = panicf;
        LuaLimits.lua_unlock(L);
        return old;
    }

    static LuaState.lua_State lua_newthread(LuaState.lua_State L)
    {
        LuaState.lua_State L1;
        LuaLimits.lua_lock(L);
        LuaGC.luaC_checkGC(L);
        L1 = LuaState.luaE_newthread(L);
        LuaObject.setthvalue(L, L.top, L1);
        api_incr_top(L);
        LuaLimits.lua_unlock(L);
        LuaConf.luai_userstatethread(L, L1);
        return L1;
    }

    static int lua_gettop(LuaState.lua_State L)
    {
        return LuaLimits.cast_int(LuaObject.TValue.minus(L.top, L.base_));
    }

    static void lua_settop(LuaState.lua_State L, int idx)
    {
        LuaLimits.lua_lock(L);
        if (idx >= 0) {
            LuaLimits.api_check(L, idx <= LuaObject.TValue.minus(L.stack_last, L.base_));
            while (LuaObject.TValue.lessThan(L.top, LuaObject.TValue.plus(L.base_, idx))) {
                LuaObject.TValue[] top = new LuaObject.TValue[1];
                top[0] = L.top;
                LuaObject.setnilvalue(LuaObject.TValue.inc(top));
                L.top = top[0];
            }
            L.top = LuaObject.TValue.plus(L.base_, idx);
        } else {
            LuaLimits.api_check(L, (-(idx + 1)) <= LuaObject.TValue.minus(L.top, L.base_));
            L.top = LuaObject.TValue.plus(L.top, idx + 1);
        }
        LuaLimits.lua_unlock(L);
    }

    static void lua_remove(LuaState.lua_State L, int idx)
    {
        LuaObject.TValue p; //StkId
        LuaLimits.lua_lock(L);
        p = index2adr(L, idx);
        api_checkvalidindex(L, p);
        while (LuaObject.TValue.lessThan(p = p.get(1), L.top)) {
            LuaObject.setobjs2s(L, LuaObject.TValue.minus(p, 1), p);
        }
        LuaObject.TValue[] top = new LuaObject.TValue[1];
        top[0] = L.top;
        LuaObject.TValue.dec(top);
        L.top = top[0];
        LuaLimits.lua_unlock(L);
    }

    static void lua_insert(LuaState.lua_State L, int idx)
    {
        LuaObject.TValue p; //StkId
		    LuaObject.TValue[] q = new LuaObject.TValue[1]; //StkId
        q[0] = new LuaObject.TValue();
        LuaLimits.lua_lock(L);
        p = index2adr(L, idx);
        api_checkvalidindex(L, p);
        for ((q[0] = L.top); LuaObject.TValue.greaterThan(q[0], p); LuaObject.TValue.dec(q)) {
            LuaObject.setobjs2s(L, q[0], LuaObject.TValue.minus(q[0], 1));
        }
        LuaObject.setobjs2s(L, p, L.top);
        LuaLimits.lua_unlock(L);
    }

    static void lua_replace(LuaState.lua_State L, int idx)
    {
        LuaObject.TValue o; //StkId
        LuaLimits.lua_lock(L);
        if ((idx == Lua.LUA_ENVIRONINDEX) && (L.ci == L.base_ci[0])) {
            LuaDebug.luaG_runerror(L, CLib.CharPtr.toCharPtr("no calling environment"));
        }
        api_checknelems(L, 1);
        o = index2adr(L, idx);
        api_checkvalidindex(L, o);
        if (idx == Lua.LUA_ENVIRONINDEX) {
            LuaObject.Closure func = LuaState.curr_func(L);
            LuaLimits.api_check(L, LuaObject.ttistable(LuaObject.TValue.minus(L.top, 1)));
            func.c.setEnv(LuaObject.hvalue(LuaObject.TValue.minus(L.top, 1)));
            LuaGC.luaC_barrier(L, func, LuaObject.TValue.minus(L.top, 1));
        } else {
            LuaObject.setobj(L, o, LuaObject.TValue.minus(L.top, 1));
            if (idx < Lua.LUA_GLOBALSINDEX) {
                LuaGC.luaC_barrier(L, LuaState.curr_func(L), LuaObject.TValue.minus(L.top, 1));
            }
        }
        LuaObject.TValue[] top = new LuaObject.TValue[1];
        top[0] = L.top;
        LuaObject.TValue.dec(top);
        L.top = top[0];
        LuaLimits.lua_unlock(L);
    }

    static void lua_pushvalue(LuaState.lua_State L, int idx)
    {
        LuaLimits.lua_lock(L);
        LuaObject.setobj2s(L, L.top, index2adr(L, idx));
        api_incr_top(L);
        LuaLimits.lua_unlock(L);
    }

    static int lua_type(LuaState.lua_State L, int idx)
    {
        LuaObject.TValue o = index2adr(L, idx); //StkId
        return (o == LuaObject.luaO_nilobject) ? Lua.LUA_TNONE : LuaObject.ttype(o);
    }

    static CLib.CharPtr lua_typename(LuaState.lua_State L, int t)
    {
        return (t == Lua.LUA_TNONE) ? CLib.CharPtr.toCharPtr("no value") : LuaTM.luaT_typenames[t];
    }

    static bool lua_iscfunction(LuaState.lua_State L, int idx)
    {
        LuaObject.TValue o = index2adr(L, idx); //StkId
        return LuaObject.iscfunction(o);
    }

    static int lua_isnumber(LuaState.lua_State L, int idx)
    {
        LuaObject.TValue n = new LuaObject.TValue();
		    LuaObject.TValue o = index2adr(L, idx);
		    LuaObject.TValue[] o_ref = new LuaObject.TValue[1];
        o_ref[0] = o;
        int ret = LuaVM.tonumber(o_ref, n);
        o = o_ref[0];
        return ret;
    }

    static int lua_isstring(LuaState.lua_State L, int idx)
    {
        int t = lua_type(L, idx);
        return ((t == Lua.LUA_TSTRING) || (t == Lua.LUA_TNUMBER)) ? 1 : 0;
    }

    static int lua_isuserdata(LuaState.lua_State L, int idx)
    {
        LuaObject.TValue o = index2adr(L, idx);
        return (LuaObject.ttisuserdata(o) || LuaObject.ttislightuserdata(o)) ? 1 : 0;
    }

    static int lua_rawequal(LuaState.lua_State L, int index1, int index2)
    {
        LuaObject.TValue o1 = index2adr(L, index1); //StkId
		    LuaObject.TValue o2 = index2adr(L, index2); //StkId
        return ((o1 == LuaObject.luaO_nilobject) || (o2 == LuaObject.luaO_nilobject)) ? 0 : LuaObject.luaO_rawequalObj(o1, o2);
    }

    static int lua_equal(LuaState.lua_State L, int index1, int index2)
    {
        LuaObject.TValue o1, o2; //StkId
        int i;
        LuaLimits.lua_lock(L);
        o1 = index2adr(L, index1);
        o2 = index2adr(L, index2);
        i = (((o1 == LuaObject.luaO_nilobject) || (o2 == LuaObject.luaO_nilobject)) ? 0 : LuaVM.equalobj(L, o1, o2));
        LuaLimits.lua_unlock(L);
        return i;
    }

    static int lua_lessthan(LuaState.lua_State L, int index1, int index2)
    {
        LuaObject.TValue o1, o2; //StkId
        int i;
        LuaLimits.lua_lock(L);
        o1 = index2adr(L, index1);
        o2 = index2adr(L, index2);
        i = (((o1 == LuaObject.luaO_nilobject) || (o2 == LuaObject.luaO_nilobject)) ? 0 : LuaVM.luaV_lessthan(L, o1, o2));
        LuaLimits.lua_unlock(L);
        return i;
    }

    static double lua_tonumber(LuaState.lua_State L, int idx)
    {
        LuaObject.TValue n = new LuaObject.TValue();
		    LuaObject.TValue o = index2adr(L, idx);
		    LuaObject.TValue[] o_ref = new LuaObject.TValue[1];
        o_ref[0] = o;
        int ret = LuaVM.tonumber(o_ref, n);
        o = o_ref[0];
        if (ret != 0) {
            return LuaObject.nvalue(o);
        } else {
            return 0;
        }
    }

    static int lua_tointeger(LuaState.lua_State L, int idx)
    {
        LuaObject.TValue n = new LuaObject.TValue();
		    LuaObject.TValue o = index2adr(L, idx);
		    LuaObject.TValue[] o_ref = new LuaObject.TValue[1];
        o_ref[0] = o;
        int ret = LuaVM.tonumber(o_ref, n);
        o = o_ref[0];
        if (ret != 0) {
            List<int> res = new List<int>(1);
            double num = LuaObject.nvalue(o);
            LuaConf.lua_number2integer(res, num);
            return res[0];
        } else {
            return 0;
        }
    }

    static int lua_toboolean(LuaState.lua_State L, int idx)
    {
        LuaObject.TValue o = index2adr(L, idx);
        return (LuaObject.l_isfalse(o) == 0) ? 1 : 0;
    }

    static CLib.CharPtr lua_tolstring(LuaState.lua_State L, int idx, List<int> len)
    {
        LuaObject.TValue o = index2adr(L, idx); //StkId
        if (!LuaObject.ttisstring(o)) {
            LuaLimits.lua_lock(L);
            if (LuaVM.luaV_tostring(L, o) == 0) {
                len[0] = 0;
                LuaLimits.lua_unlock(L);
                return null;
            }
            LuaGC.luaC_checkGC(L);
            o = index2adr(L, idx);
            LuaLimits.lua_unlock(L);
        }
        len[0] = LuaObject.tsvalue(o).len;
        return LuaObject.svalue(o);
    }

    static int lua_objlen(LuaState.lua_State L, int idx)
    {
        LuaObject.TValue o = index2adr(L, idx); //StkId
        switch (LuaObject.ttype(o)) {
            case Lua.LUA_TSTRING:
                return LuaObject.tsvalue(o).len;
            case Lua.LUA_TUSERDATA:
                return LuaObject.uvalue(o).len;
            case Lua.LUA_TTABLE:
                return LuaTable.luaH_getn(LuaObject.hvalue(o));
            case Lua.LUA_TNUMBER:
                int l;
                LuaLimits.lua_lock(L);
                l = ((LuaVM.luaV_tostring(L, o) != 0) ? LuaObject.tsvalue(o).len : 0);
                LuaLimits.lua_unlock(L);
                return l;
            default:
                return 0;
        }
    }

    static Lua.lua_CFunction lua_tocfunction(LuaState.lua_State L, int idx)
    {
        LuaObject.TValue o = index2adr(L, idx); //StkId
        return (!LuaObject.iscfunction(o)) ? null : LuaObject.clvalue(o).c.f;
    }

    static Object lua_touserdata(LuaState.lua_State L, int idx)
    {
        LuaObject.TValue o = index2adr(L, idx); //StkId
        switch (LuaObject.ttype(o)) {
            case Lua.LUA_TUSERDATA:
                return LuaObject.rawuvalue(o).user_data;
            case Lua.LUA_TLIGHTUSERDATA:
                return LuaObject.pvalue(o);
            default:
                return null;
        }
    }

    static LuaState.lua_State lua_tothread(LuaState.lua_State L, int idx)
    {
        LuaObject.TValue o = index2adr(L, idx); //StkId
        return (!LuaObject.ttisthread(o)) ? null : LuaObject.thvalue(o);
    }

    static Object lua_topointer(LuaState.lua_State L, int idx)
    {
        LuaObject.TValue o = index2adr(L, idx); //StkId
        switch (LuaObject.ttype(o)) {
            case Lua.LUA_TTABLE:
                return LuaObject.hvalue(o);
            case Lua.LUA_TFUNCTION:
                return LuaObject.clvalue(o);
            case Lua.LUA_TTHREAD:
                return LuaObject.thvalue(o);
            case Lua.LUA_TUSERDATA:
            case Lua.LUA_TLIGHTUSERDATA:
                return lua_touserdata(L, idx);
            default:
                return null;
        }
    }

    static void lua_pushnil(LuaState.lua_State L)
    {
        LuaLimits.lua_lock(L);
        LuaObject.setnilvalue(L.top);
        api_incr_top(L);
        LuaLimits.lua_unlock(L);
    }

    static void lua_pushnumber(LuaState.lua_State L, double n)
    {
        LuaLimits.lua_lock(L);
        LuaObject.setnvalue(L.top, n);
        api_incr_top(L);
        LuaLimits.lua_unlock(L);
    }

    static void lua_pushinteger(LuaState.lua_State L, int n)
    {
        LuaLimits.lua_lock(L);
        LuaObject.setnvalue(L.top, LuaLimits.cast_num(n));
        api_incr_top(L);
        LuaLimits.lua_unlock(L);
    }

    static void lua_pushlstring(LuaState.lua_State L, CLib.CharPtr s, int len)
    {
        LuaLimits.lua_lock(L);
        LuaGC.luaC_checkGC(L);
        LuaObject.setsvalue2s(L, L.top, LuaString.luaS_newlstr(L, s, len));
        api_incr_top(L);
        LuaLimits.lua_unlock(L);
    }

    static void lua_pushstring(LuaState.lua_State L, CLib.CharPtr s)
    {
        if (CLib.CharPtr.isEqual(s, null)) {
            lua_pushnil(L);
        } else {
            lua_pushlstring(L, s, CLib.strlen(s));
        }
    }

    static CLib.CharPtr lua_pushvfstring(LuaState.lua_State L, CLib.CharPtr fmt, List<Object> argp)
    {
        CLib.CharPtr ret;
        LuaLimits.lua_lock(L);
        LuaGC.luaC_checkGC(L);
        ret = LuaObject.luaO_pushvfstring(L, fmt, argp);
        LuaLimits.lua_unlock(L);
        return ret;
    }

    static CLib.CharPtr lua_pushfstring(LuaState.lua_State L, CLib.CharPtr fmt)
    {
        CLib.CharPtr ret;
        LuaLimits.lua_lock(L);
        LuaGC.luaC_checkGC(L);
        ret = LuaObject.luaO_pushvfstring(L, fmt, null);
        LuaLimits.lua_unlock(L);
        return ret;
    }

    static CLib.CharPtr lua_pushfstring(LuaState.lua_State L, CLib.CharPtr fmt, List<Object> p /*XXX*/)
    {
        CLib.CharPtr ret;
        LuaLimits.lua_lock(L);
        LuaGC.luaC_checkGC(L);
        ret = LuaObject.luaO_pushvfstring(L, fmt, p);
        LuaLimits.lua_unlock(L);
        return ret;
    }

    static void lua_pushcclosure(LuaState.lua_State L, Lua.lua_CFunction fn, int n)
    {
        LuaObject.Closure cl;
        LuaLimits.lua_lock(L);
        LuaGC.luaC_checkGC(L);
        api_checknelems(L, n);
        cl = LuaFunc.luaF_newCclosure(L, n, getcurrenv(L));
        cl.c.f = fn;
        L.top = LuaObject.TValue.minus(L.top, n);
        while (n-- != 0) {
            LuaObject.setobj2n(L, cl.c.upvalue[n], LuaObject.TValue.plus(L.top, n));
        }
        LuaObject.setclvalue(L, L.top, cl);
        LuaLimits.lua_assert(LuaGC.iswhite(LuaState.obj2gco(cl)));
        api_incr_top(L);
        LuaLimits.lua_unlock(L);
    }

    static void lua_pushboolean(LuaState.lua_State L, int b)
    {
        LuaLimits.lua_lock(L);
        LuaObject.setbvalue(L.top, (b != 0) ? 1 : 0);
        api_incr_top(L);
        LuaLimits.lua_unlock(L);
    }

    static void lua_pushlightuserdata(LuaState.lua_State L, Object p)
    {
        LuaLimits.lua_lock(L);
        LuaObject.setpvalue(L.top, p);
        api_incr_top(L);
        LuaLimits.lua_unlock(L);
    }

    static int lua_pushthread(LuaState.lua_State L)
    {
        LuaLimits.lua_lock(L);
        LuaObject.setthvalue(L, L.top, L);
        api_incr_top(L);
        LuaLimits.lua_unlock(L);
        return (LuaState.G(L).mainthread == L) ? 1 : 0;
    }

    static void lua_gettable(LuaState.lua_State L, int idx)
    {
        LuaObject.TValue t; //StkId
        LuaLimits.lua_lock(L);
        t = index2adr(L, idx);
        api_checkvalidindex(L, t);
        LuaVM.luaV_gettable(L, t, LuaObject.TValue.minus(L.top, 1), LuaObject.TValue.minus(L.top, 1));
        LuaLimits.lua_unlock(L);
    }

    static void lua_getfield(LuaState.lua_State L, int idx, CLib.CharPtr k)
    {
        LuaObject.TValue t; //StkId
		    LuaObject.TValue key = new LuaObject.TValue();
        LuaLimits.lua_lock(L);
        t = index2adr(L, idx);
        api_checkvalidindex(L, t);
        LuaObject.setsvalue(L, key, LuaString.luaS_new(L, k));
        LuaVM.luaV_gettable(L, t, key, L.top);
        api_incr_top(L);
        LuaLimits.lua_unlock(L);
    }

    static void lua_rawget(LuaState.lua_State L, int idx)
    {
        LuaObject.TValue t; //StkId
        LuaLimits.lua_lock(L);
        t = index2adr(L, idx);
        LuaLimits.api_check(L, LuaObject.ttistable(t));
        LuaObject.setobj2s(L, LuaObject.TValue.minus(L.top, 1), LuaTable.luaH_get(LuaObject.hvalue(t), LuaObject.TValue.minus(L.top, 1)));
        LuaLimits.lua_unlock(L);
    }

    static void lua_rawgeti(LuaState.lua_State L, int idx, int n)
    {
        LuaObject.TValue o; //StkId
        LuaLimits.lua_lock(L);
        o = index2adr(L, idx);
        LuaLimits.api_check(L, LuaObject.ttistable(o));
        LuaObject.setobj2s(L, L.top, LuaTable.luaH_getnum(LuaObject.hvalue(o), n));
        api_incr_top(L);
        LuaLimits.lua_unlock(L);
    }

    static void lua_createtable(LuaState.lua_State L, int narray, int nrec)
    {
        LuaLimits.lua_lock(L);
        LuaGC.luaC_checkGC(L);
        LuaObject.sethvalue(L, L.top, LuaTable.luaH_new(L, narray, nrec));
        api_incr_top(L);
        LuaLimits.lua_unlock(L);
    }

    static int lua_getmetatable(LuaState.lua_State L, int objindex)
    {
        LuaObject.TValue obj;
		    LuaObject.Table mt = null;
        int res;
        LuaLimits.lua_lock(L);
        obj = index2adr(L, objindex);
        switch (LuaObject.ttype(obj)) {
            case Lua.LUA_TTABLE:
                mt = LuaObject.hvalue(obj).metatable;
                break;
            case Lua.LUA_TUSERDATA:
                mt = LuaObject.uvalue(obj).metatable;
                break;
            default:
                mt = LuaState.G(L).mt[LuaObject.ttype(obj)];
                break;
        }
        if (mt == null) {
            res = 0;
        } else {
            LuaObject.sethvalue(L, L.top, mt);
            api_incr_top(L);
            res = 1;
        }
        LuaLimits.lua_unlock(L);
        return res;
    }

    static void lua_getfenv(LuaState.lua_State L, int idx)
    {
        LuaObject.TValue o; //StkId
        LuaLimits.lua_lock(L);
        o = index2adr(L, idx);
        api_checkvalidindex(L, o);
        switch (LuaObject.ttype(o)) {
            case Lua.LUA_TFUNCTION:
                LuaObject.sethvalue(L, L.top, LuaObject.clvalue(o).c.getEnv());
                break;
            case Lua.LUA_TUSERDATA:
                LuaObject.sethvalue(L, L.top, LuaObject.uvalue(o).env);
                break;
            case Lua.LUA_TTHREAD:
                LuaObject.setobj2s(L, L.top, LuaState.gt(LuaObject.thvalue(o)));
                break;
            default:
                LuaObject.setnilvalue(L.top);
                break;
        }
        api_incr_top(L);
        LuaLimits.lua_unlock(L);
    }

    static void lua_settable(LuaState.lua_State L, int idx)
    {
        LuaObject.TValue t; //StkId
        LuaLimits.lua_lock(L);
        api_checknelems(L, 2);
        t = index2adr(L, idx);
        api_checkvalidindex(L, t);
        LuaVM.luaV_settable(L, t, LuaObject.TValue.minus(L.top, 2), LuaObject.TValue.minus(L.top, 1));
        L.top = LuaObject.TValue.minus(L.top, 2);
        LuaLimits.lua_unlock(L);
    }

    static void lua_setfield(LuaState.lua_State L, int idx, CLib.CharPtr k)
    {
        LuaObject.TValue t; //StkId
		    LuaObject.TValue key = new LuaObject.TValue();
        LuaLimits.lua_lock(L);
        api_checknelems(L, 1);
        t = index2adr(L, idx);
        api_checkvalidindex(L, t);
        LuaObject.setsvalue(L, key, LuaString.luaS_new(L, k));
        LuaVM.luaV_settable(L, t, key, LuaObject.TValue.minus(L.top, 1));
        top[0] = L.top;
        LuaObject.TValue.dec(top);
        L.top = top[0];
        LuaLimits.lua_unlock(L);
    }

    static void lua_rawset(LuaState.lua_State L, int idx)
    {
        LuaObject.TValue t; //StkId
        LuaLimits.lua_lock(L);
        api_checknelems(L, 2);
        t = index2adr(L, idx);
        LuaLimits.api_check(L, LuaObject.ttistable(t));
        LuaObject.setobj2t(L, LuaTable.luaH_set(L, LuaObject.hvalue(t), LuaObject.TValue.minus(L.top, 2)), LuaObject.TValue.minus(L.top, 1));
        LuaGC.luaC_barriert(L, LuaObject.hvalue(t), LuaObject.TValue.minus(L.top, 1));
        L.top = LuaObject.TValue.minus(L.top, 2);
        LuaLimits.lua_unlock(L);
    }

    static void lua_rawseti(LuaState.lua_State L, int idx, int n)
    {
        LuaObject.TValue o; //StkId
        LuaLimits.lua_lock(L);
        api_checknelems(L, 1);
        o = index2adr(L, idx);
        LuaLimits.api_check(L, LuaObject.ttistable(o));
        LuaObject.setobj2t(L, LuaTable.luaH_setnum(L, LuaObject.hvalue(o), n), LuaObject.TValue.minus(L.top, 1));
        LuaGC.luaC_barriert(L, LuaObject.hvalue(o), LuaObject.TValue.minus(L.top, 1));
        top[0] = L.top;
        LuaObject.TValue.dec(top);
        L.top = top[0];
        LuaLimits.lua_unlock(L);
    }

    static int lua_setmetatable(LuaState.lua_State L, int objindex)
    {
        LuaObject.TValue obj;
		    LuaObject.Table mt;
        LuaLimits.lua_lock(L);
        api_checknelems(L, 1);
        obj = index2adr(L, objindex);
        api_checkvalidindex(L, obj);
        if (LuaObject.ttisnil(LuaObject.TValue.minus(L.top, 1))) {
            mt = null;
        } else {
            LuaLimits.api_check(L, LuaObject.ttistable(LuaObject.TValue.minus(L.top, 1)));
            mt = LuaObject.hvalue(LuaObject.TValue.minus(L.top, 1));
        }
        switch (LuaObject.ttype(obj)) {
            case Lua.LUA_TTABLE:
                LuaObject.hvalue(obj).metatable = mt;
                if (mt != null) {
                    LuaGC.luaC_objbarriert(L, LuaObject.hvalue(obj), mt);
                }
                break;
            case Lua.LUA_TUSERDATA:
                LuaObject.uvalue(obj).metatable = mt;
                if (mt != null) {
                    LuaGC.luaC_objbarrier(L, LuaObject.rawuvalue(obj), mt);
                }
                break;
            default:
                LuaState.G(L).mt[LuaObject.ttype(obj)] = mt;
                break;
        }
        LuaObject.TValue[] top = new LuaObject.TValue[1];
        top[0] = L.top;
        LuaObject.TValue.dec(top);
        L.top = top[0];
        LuaLimits.lua_unlock(L);
        return 1;
    }

    static int lua_setfenv(LuaState.lua_State L, int idx)
    {
        LuaObject.TValue o; //StkId
        int res = 1;
        LuaLimits.lua_lock(L);
        api_checknelems(L, 1);
        o = index2adr(L, idx);
        api_checkvalidindex(L, o);
        LuaLimits.api_check(L, LuaObject.ttistable(LuaObject.TValue.minus(L.top, 1)));
        switch (LuaObject.ttype(o)) {
            case Lua.LUA_TFUNCTION:
                LuaObject.clvalue(o).c.setEnv(LuaObject.hvalue(LuaObject.TValue.minus(L.top, 1)));
                break;
            case Lua.LUA_TUSERDATA:
                LuaObject.uvalue(o).env = LuaObject.hvalue(LuaObject.TValue.minus(L.top, 1));
                break;
            case Lua.LUA_TTHREAD:
                LuaObject.sethvalue(L, LuaState.gt(LuaObject.thvalue(o)), LuaObject.hvalue(LuaObject.TValue.minus(L.top, 1)));
                break;
            default:
                res = 0;
                break;
        }
        if (res != 0) {
            LuaGC.luaC_objbarrier(L, LuaObject.gcvalue(o), LuaObject.hvalue(LuaObject.TValue.minus(L.top, 1)));
        }
        LuaObject.TValue[] top = new LuaObject.TValue[1];
        top[0] = L.top;
        LuaObject.TValue.dec(top);
        L.top = top[0];
        LuaLimits.lua_unlock(L);
        return res;
    }

    static void adjustresults(LuaState.lua_State L, int nres)
    {
        if ((nres == Lua.LUA_MULTRET) && LuaObject.TValue.greaterEqual(L.top, L.ci.top)) {
            L.ci.top = L.top;
        }
    }

    static void checkresults(LuaState.lua_State L, int na, int nr)
    {
        LuaLimits.api_check(L, (nr == Lua.LUA_MULTRET) || (LuaObject.TValue.minus(L.ci.top, L.top) >= (-na)));
    }

    static void lua_call(LuaState.lua_State L, int nargs, int nresults)
    {
        LuaObject.TValue func; //StkId
        LuaLimits.lua_lock(L);
        api_checknelems(L, nargs + 1);
        checkresults(L, nargs, nresults);
        func = LuaObject.TValue.minus(L.top, nargs + 1);
        LuaDo.luaD_call(L, func, nresults);
        adjustresults(L, nresults);
        LuaLimits.lua_unlock(L);
    }

    static void f_call(LuaState.lua_State L, Object ud)
    {
        CallS c = (CallS)((ud instanceof CallS) ? ud : null);
        LuaDo.luaD_call(L, c.func, c.nresults);
    }

    static int lua_pcall(LuaState.lua_State L, int nargs, int nresults, int errfunc)
    {
        CallS c = new CallS();
        int status;
        int func;
        LuaLimits.lua_lock(L);
        api_checknelems(L, nargs + 1);
        checkresults(L, nargs, nresults);
        if (errfunc == 0) {
            func = 0;
        } else {
            LuaObject.TValue o = index2adr(L, errfunc); //StkId
            api_checkvalidindex(L, o);
            func = LuaDo.savestack(L, o);
        }
        c.func = LuaObject.TValue.minus(L.top, nargs + 1);
        c.nresults = nresults;
        status = LuaDo.luaD_pcall(L, new f_call_delegate(), c, LuaDo.savestack(L, c.func), func);
        adjustresults(L, nresults);
        LuaLimits.lua_unlock(L);
        return status;
    }

    static void f_Ccall(LuaState.lua_State L, Object ud)
    {
        CCallS c = (CCallS)((ud instanceof CCallS) ? ud : null);
		    LuaObject.Closure cl;
        cl = LuaFunc.luaF_newCclosure(L, 0, getcurrenv(L));
        cl.c.f = c.func;
        LuaObject.setclvalue(L, L.top, cl);
        api_incr_top(L);
        LuaObject.setpvalue(L.top, c.ud);
        api_incr_top(L);
        LuaDo.luaD_call(L, LuaObject.TValue.minus(L.top, 2), 0);
    }

    static int lua_cpcall(LuaState.lua_State L, Lua.lua_CFunction func, Object ud)
    {
        CCallS c = new CCallS();
        int status;
        LuaLimits.lua_lock(L);
        c.func = func;
        c.ud = ud;
        status = LuaDo.luaD_pcall(L, new f_Ccall_delegate(), c, LuaDo.savestack(L, L.top), 0);
        LuaLimits.lua_unlock(L);
        return status;
    }

    static int lua_load(LuaState.lua_State L, Lua.lua_Reader reader, Object data, CLib.CharPtr chunkname)
    {
        LuaZIO.ZIO z = new LuaZIO.ZIO();
        int status;
        LuaLimits.lua_lock(L);
        if (CLib.CharPtr.isEqual(chunkname, null)) {
            chunkname = CLib.CharPtr.toCharPtr("?");
        }
        LuaZIO.luaZ_init(L, z, reader, data);
        status = LuaDo.luaD_protectedparser(L, z, chunkname);
        LuaLimits.lua_unlock(L);
        return status;
    }

    static int lua_dump(LuaState.lua_State L, Lua.lua_Writer writer, Object data)
    {
        int status;
        LuaObject.TValue o;
        LuaLimits.lua_lock(L);
        api_checknelems(L, 1);
        o = LuaObject.TValue.minus(L.top, 1);
        if (LuaObject.isLfunction(o)) {
            status = LuaDump.luaU_dump(L, LuaObject.clvalue(o).l.p, writer, data, 0);
        } else {
            status = 1;
        }
        LuaLimits.lua_unlock(L);
        return status;
    }

    static int lua_status(LuaState.lua_State L)
    {
        return L.status;
    }

    static int lua_gc(LuaState.lua_State L, int what, int data)
    {
        int res = 0;
        LuaState.global_State g;
        LuaLimits.lua_lock(L);
        g = LuaState.G(L);
        switch (what) {
            case Lua.LUA_GCSTOP:
                g.GCthreshold = LuaLimits.MAX_LUMEM;
                break;
            case Lua.LUA_GCRESTART:
                g.GCthreshold = g.totalbytes;
                break;
            case Lua.LUA_GCCOLLECT:
                LuaGC.luaC_fullgc(L);
                break;
            case Lua.LUA_GCCOUNT:
                res = LuaLimits.cast_int(g.totalbytes >> 10);
                break;
            case Lua.LUA_GCCOUNTB:
                res = LuaLimits.cast_int(g.totalbytes & 63);
                break;
            case Lua.LUA_GCSTEP:
                int a = (data << 10);
                if (a <= g.totalbytes) {
                    g.GCthreshold = (g.totalbytes - a);
                } else {
                    g.GCthreshold = 0;
                }
                while (g.GCthreshold <= g.totalbytes) {
                    LuaGC.luaC_step(L);
                    if (g.gcstate == LuaGC.GCSpause) {
                        res = 1;
                        break;
                    }
                }
                break;
            case Lua.LUA_GCSETPAUSE:
                res = g.gcpause;
                g.gcpause = data;
                break;
            case Lua.LUA_GCSETSTEPMUL:
                res = g.gcstepmul;
                g.gcstepmul = data;
                break;
            default:
                res = (-1);
                break;
        }
        LuaLimits.lua_unlock(L);
        return res;
    }

    static int lua_error(LuaState.lua_State L)
    {
        LuaLimits.lua_lock(L);
        api_checknelems(L, 1);
        LuaDebug.luaG_errormsg(L);
        LuaLimits.lua_unlock(L);
        return 0;
    }

    static int lua_next(LuaState.lua_State L, int idx)
    {
        LuaObject.TValue t; //StkId
        int more;
        LuaLimits.lua_lock(L);
        t = index2adr(L, idx);
        LuaLimits.api_check(L, LuaObject.ttistable(t));
        more = LuaTable.luaH_next(L, LuaObject.hvalue(t), LuaObject.TValue.minus(L.top, 1));
        if (more != 0) {
            api_incr_top(L);
        } else {
            LuaObject.TValue[] top = new LuaObject.TValue[1];
            top[0] = L.top;
            LuaObject.TValue.dec(top);
            L.top = top[0];
        }
        LuaLimits.lua_unlock(L);
        return more;
    }

    static void lua_concat(LuaState.lua_State L, int n)
    {
        LuaLimits.lua_lock(L);
        api_checknelems(L, n);
        if (n >= 2) {
            LuaGC.luaC_checkGC(L);
            LuaVM.luaV_concat(L, n, LuaLimits.cast_int(LuaObject.TValue.minus(L.top, L.base_)) - 1);
            L.top = LuaObject.TValue.minus(L.top, n - 1);
        } else {
            if (n == 0) {
                LuaObject.setsvalue2s(L, L.top, LuaString.luaS_newlstr(L, CLib.CharPtr.toCharPtr(""), 0));
                api_incr_top(L);
            }
        }
        LuaLimits.lua_unlock(L);
    }

    static Lua.lua_Alloc lua_getallocf(LuaState.lua_State L, List<Object> ud)
    {
        Lua.lua_Alloc f;
        LuaLimits.lua_lock(L);
        if (ud[0] != null) {
            ud[0] = LuaState.G(L).ud;
        }
        f = LuaState.G(L).frealloc;
        LuaLimits.lua_unlock(L);
        return f;
    }

    static void lua_setallocf(LuaState.lua_State L, Lua.lua_Alloc f, Object ud)
    {
        LuaLimits.lua_lock(L);
        LuaState.G(L).ud = ud;
        LuaState.G(L).frealloc = f;
        LuaLimits.lua_unlock(L);
    }

    static Object lua_newuserdata(LuaState.lua_State L, int size)
    {
        LuaObject.Udata u;
        LuaLimits.lua_lock(L);
        LuaGC.luaC_checkGC(L);
        u = LuaString.luaS_newudata(L, size, getcurrenv(L));
        LuaObject.setuvalue(L, L.top, u);
        api_incr_top(L);
        LuaLimits.lua_unlock(L);
        return u.user_data;
    }

    static Object lua_newuserdata(LuaState.lua_State L, ClassType t)
    {
        LuaObject.Udata u;
        LuaLimits.lua_lock(L);
        LuaGC.luaC_checkGC(L);
        u = LuaString.luaS_newudata(L, t, getcurrenv(L));
        LuaObject.setuvalue(L, L.top, u);
        api_incr_top(L);
        LuaLimits.lua_unlock(L);
        return u.user_data;
    }

    static CLib.CharPtr aux_upvalue(LuaObject.TValue fi, int n, List<LuaObject.TValue> val)
    {
        LuaObject.Closure f;
        if (!LuaObject.ttisfunction(fi)) {
            return null;
        }
        f = LuaObject.clvalue(fi);
        if (f.c.getIsC() != 0) {
            if (!((1 <= n) && (n <= f.c.getNupvalues()))) {
                return null;
            }
            val[0] = f.c.upvalue[n - 1];
            return CLib.CharPtr.toCharPtr("");
        } else {
            LuaObject.Proto p = f.l.p;
            if (!((1 <= n) && (n <= p.sizeupvalues))) {
                return null;
            }
            val[0] = f.l.upvals[n - 1].v;
            return LuaObject.getstr(p.upvalues[n - 1]);
        }
    }

    static CLib.CharPtr lua_getupvalue(LuaState.lua_State L, int funcindex, int n)
    {
        CLib.CharPtr name;
		    LuaObject.TValue val = new LuaObject.TValue();
        LuaLimits.lua_lock(L);
        LuaObject.TValue[] val_ref = new LuaObject.TValue[1];
        val_ref[0] = val;
        name = aux_upvalue(index2adr(L, funcindex), n, val_ref);
        val = val_ref[0];
        if (CLib.CharPtr.isNotEqual(name, null)) {
            LuaObject.setobj2s(L, L.top, val);
            api_incr_top(L);
        }
        LuaLimits.lua_unlock(L);
        return name;
    }

    static CLib.CharPtr lua_setupvalue(LuaState.lua_State L, int funcindex, int n)
    {
        CLib.CharPtr name;
		    LuaObject.TValue val = new LuaObject.TValue();
		    LuaObject.TValue fi; //StkId
        LuaLimits.lua_lock(L);
        fi = index2adr(L, funcindex);
        api_checknelems(L, 1);
        LuaObject.TValue[] val_ref = new LuaObject.TValue[1];
        val_ref[0] = val;
        name = aux_upvalue(fi, n, val_ref);
        val = val_ref[0];
        if (CLib.CharPtr.isNotEqual(name, null)) {
            LuaObject.TValue[] top = new LuaObject.TValue[1];
            top[0] = L.top;
            LuaObject.TValue.dec(top);
            L.top = top[0];
            LuaObject.setobj(L, val, L.top);
            LuaGC.luaC_barrier(L, LuaObject.clvalue(fi), L.top);
        }
        LuaLimits.lua_unlock(L);
        return name;
    }
}

class CallS
{
    LuaObject.TValue func;
    int nresults;
}

class f_call_delegate with LuaDo_Pfunc
{

    final void exec(LuaState.lua_State L, Object ud)
    {
        f_call(L, ud);
    }
}

class CCallS
{
    Lua.lua_CFunction func;
    Object ud;
}

class f_Ccall_delegate with LuaDo_Pfunc
{

    final void exec(LuaState.lua_State L, Object ud)
    {
        f_Ccall(L, ud);
    }
}
