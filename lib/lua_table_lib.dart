library kurumi;

class LuaTableLib
{

    static int aux_getn(LuaState.lua_State L, int n)
    {
        LuaAuxLib.luaL_checktype(L, n, Lua.LUA_TTABLE);
        return LuaAuxLib.luaL_getn(L, n);
    }

    static int foreachi(LuaState.lua_State L)
    {
        int i;
        int n = aux_getn(L, 1);
        LuaAuxLib.luaL_checktype(L, 2, Lua.LUA_TFUNCTION);
        for ((i = 1); i <= n; i++) {
            LuaAPI.lua_pushvalue(L, 2);
            LuaAPI.lua_pushinteger(L, i);
            LuaAPI.lua_rawgeti(L, 1, i);
            LuaAPI.lua_call(L, 2, 1);
            if (!Lua.lua_isnil(L, -1)) {
                return 1;
            }
            Lua.lua_pop(L, 1);
        }
        return 0;
    }

    static int _foreach(LuaState.lua_State L)
    {
        LuaAuxLib.luaL_checktype(L, 1, Lua.LUA_TTABLE);
        LuaAuxLib.luaL_checktype(L, 2, Lua.LUA_TFUNCTION);
        LuaAPI.lua_pushnil(L);
        while (LuaAPI.lua_next(L, 1) != 0) {
            LuaAPI.lua_pushvalue(L, 2);
            LuaAPI.lua_pushvalue(L, -3);
            LuaAPI.lua_pushvalue(L, -3);
            LuaAPI.lua_call(L, 2, 1);
            if (!Lua.lua_isnil(L, -1)) {
                return 1;
            }
            Lua.lua_pop(L, 2);
        }
        return 0;
    }

    static int maxn(LuaState.lua_State L)
    {
        double max = 0;
        LuaAuxLib.luaL_checktype(L, 1, Lua.LUA_TTABLE);
        LuaAPI.lua_pushnil(L);
        while (LuaAPI.lua_next(L, 1) != 0) {
            Lua.lua_pop(L, 1);
            if (LuaAPI.lua_type(L, -1) == Lua.LUA_TNUMBER) {
                double v = LuaAPI.lua_tonumber(L, -1);
                if (v > max) {
                    max = v;
                }
            }
        }
        LuaAPI.lua_pushnumber(L, max);
        return 1;
    }

    static int getn(LuaState.lua_State L)
    {
        LuaAPI.lua_pushinteger(L, aux_getn(L, 1));
        return 1;
    }

    static int setn(LuaState.lua_State L)
    {
        LuaAuxLib.luaL_checktype(L, 1, Lua.LUA_TTABLE);
        LuaAuxLib.luaL_error(L, CLib.CharPtr.toCharPtr(LuaConf.LUA_QL("setn") + " is obsolete"));
        LuaAPI.lua_pushvalue(L, 1);
        return 1;
    }

    static int tinsert(LuaState.lua_State L)
    {
        int e = (aux_getn(L, 1) + 1);
        int pos;
        switch (LuaAPI.lua_gettop(L)) {
            case 2:
                pos = e;
                break;
            case 3:
                int i;
                pos = LuaAuxLib.luaL_checkint(L, 2);
                if (pos > e) {
                    e = pos;
                }
                for ((i = e); i > pos; i--) {
                    LuaAPI.lua_rawgeti(L, 1, i - 1);
                    LuaAPI.lua_rawseti(L, 1, i);
                }
                break;
            default:
                return LuaAuxLib.luaL_error(L, CLib.CharPtr.toCharPtr("wrong number of arguments to " + LuaConf.LUA_QL("insert")));
        }
        LuaAuxLib.luaL_setn(L, 1, e);
        LuaAPI.lua_rawseti(L, 1, pos);
        return 0;
    }

    static int tremove(LuaState.lua_State L)
    {
        int e = aux_getn(L, 1);
        int pos = LuaAuxLib.luaL_optint(L, 2, e);
        if (!((1 <= pos) && (pos <= e))) {
            return 0;
        }
        LuaAuxLib.luaL_setn(L, 1, e - 1);
        LuaAPI.lua_rawgeti(L, 1, pos);
        for (; pos < e; pos++) {
            LuaAPI.lua_rawgeti(L, 1, pos + 1);
            LuaAPI.lua_rawseti(L, 1, pos);
        }
        LuaAPI.lua_pushnil(L);
        LuaAPI.lua_rawseti(L, 1, e);
        return 1;
    }

    static void addfield(LuaState.lua_State L, LuaAuxLib.luaL_Buffer b, int i)
    {
        LuaAPI.lua_rawgeti(L, 1, i);
        if (LuaAPI.lua_isstring(L, -1) == 0) {
            LuaAuxLib.luaL_error(L, CLib.CharPtr.toCharPtr("invalid value (%s) at index %d in table for " + LuaConf.LUA_QL("concat")), LuaAuxLib.luaL_typename(L, -1), i);
        }
        LuaAuxLib.luaL_addvalue(b);
    }

    static int tconcat(LuaState.lua_State L)
    {
        LuaAuxLib.luaL_Buffer b = new LuaAuxLib.luaL_Buffer();
        List<int> lsep = new List<int>(1);
        int i;
        int last;
        CLib.CharPtr sep = LuaAuxLib.luaL_optlstring(L, 2, CLib.CharPtr.toCharPtr(""), lsep); //out
        LuaAuxLib.luaL_checktype(L, 1, Lua.LUA_TTABLE);
        i = LuaAuxLib.luaL_optint(L, 3, 1);
        last = LuaAuxLib.luaL_opt_integer(L, new LuaAuxLib.luaL_checkint_delegate(), 4, LuaAuxLib.luaL_getn(L, 1));
        LuaAuxLib.luaL_buffinit(L, b);
        for (; i < last; i++) {
            addfield(L, b, i);
            LuaAuxLib.luaL_addlstring(b, sep, lsep[0]);
        }
        if (i == last) {
            addfield(L, b, i);
        }
        LuaAuxLib.luaL_pushresult(b);
        return 1;
    }

    static void set2(LuaState.lua_State L, int i, int j)
    {
        LuaAPI.lua_rawseti(L, 1, i);
        LuaAPI.lua_rawseti(L, 1, j);
    }

    static int sort_comp(LuaState.lua_State L, int a, int b)
    {
        if (!Lua.lua_isnil(L, 2)) {
            int res;
            LuaAPI.lua_pushvalue(L, 2);
            LuaAPI.lua_pushvalue(L, a - 1);
            LuaAPI.lua_pushvalue(L, b - 2);
            LuaAPI.lua_call(L, 2, 1);
            res = LuaAPI.lua_toboolean(L, -1);
            Lua.lua_pop(L, 1);
            return res;
        } else {
            return LuaAPI.lua_lessthan(L, a, b);
        }
    }

    static int auxsort_loop1(LuaState.lua_State L, List<int> i)
    {
        LuaAPI.lua_rawgeti(L, 1, ++i[0]);
        return sort_comp(L, -1, -2);
    }

    static int auxsort_loop2(LuaState.lua_State L, List<int> j)
    {
        LuaAPI.lua_rawgeti(L, 1, --j[0]);
        return sort_comp(L, -3, -1);
    }

    static void auxsort(LuaState.lua_State L, int l, int u)
    {
        while (l < u) {
            int i;
            int j;
            LuaAPI.lua_rawgeti(L, 1, l);
            LuaAPI.lua_rawgeti(L, 1, u);
            if (sort_comp(L, -1, -2) != 0) {
                set2(L, l, u);
            } else {
                Lua.lua_pop(L, 2);
            }
            if ((u - l) == 1) {
                break;
            }
            i = ((l + u) ~/ 2);
            LuaAPI.lua_rawgeti(L, 1, i);
            LuaAPI.lua_rawgeti(L, 1, l);
            if (sort_comp(L, -2, -1) != 0) {
                set2(L, i, l);
            } else {
                Lua.lua_pop(L, 1);
                LuaAPI.lua_rawgeti(L, 1, u);
                if (sort_comp(L, -1, -2) != 0) {
                    set2(L, i, u);
                } else {
                    Lua.lua_pop(L, 2);
                }
            }
            if ((u - l) == 2) {
                break;
            }
            LuaAPI.lua_rawgeti(L, 1, i);
            LuaAPI.lua_pushvalue(L, -1);
            LuaAPI.lua_rawgeti(L, 1, u - 1);
            set2(L, i, u - 1);
            i = l;
            j = (u - 1);
            for (; ; ) {
                while (true) {
                    List<int> i_ref = new List<int>(1);
                    i_ref[0] = i;
                    int ret_1 = auxsort_loop1(L, i_ref);
                    i = i_ref[0];
                    if (!(ret_1 != 0)) {
                        break;
                    }
                    if (i > u) {
                        LuaAuxLib.luaL_error(L, CLib.CharPtr.toCharPtr("invalid order function for sorting"));
                    }
                    Lua.lua_pop(L, 1);
                }
                while (true) {
                    List<int> j_ref = new List<int>(1);
                    j_ref[0] = i;
                    int ret_2 = auxsort_loop2(L, j_ref);
                    j = j_ref[0];
                    if (!(ret_2 != 0)) {
                        break;
                    }
                    if (j < l) {
                        LuaAuxLib.luaL_error(L, CLib.CharPtr.toCharPtr("invalid order function for sorting"));
                    }
                    Lua.lua_pop(L, 1);
                }
                if (j < i) {
                    Lua.lua_pop(L, 3);
                    break;
                }
                set2(L, i, j);
            }
            LuaAPI.lua_rawgeti(L, 1, u - 1);
            LuaAPI.lua_rawgeti(L, 1, i);
            set2(L, u - 1, i);
            if ((i - l) < (u - i)) {
                j = l;
                i = (i - 1);
                l = (i + 2);
            } else {
                j = (i + 1);
                i = u;
                u = (j - 2);
            }
            auxsort(L, j, i);
        }
    }

    static int sort(LuaState.lua_State L)
    {
        int n = aux_getn(L, 1);
        LuaAuxLib.luaL_checkstack(L, 40, CLib.CharPtr.toCharPtr(""));
        if (!Lua.lua_isnoneornil(L, 2)) {
            LuaAuxLib.luaL_checktype(L, 2, Lua.LUA_TFUNCTION);
        }
        LuaAPI.lua_settop(L, 2);
        auxsort(L, 1, n);
        return 0;
    }
    static final List<LuaAuxLib.luaL_Reg> tab_funcs = [new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("concat"), new LuaTableLib_delegate("tconcat")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("foreach"), new LuaTableLib_delegate("_foreach")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("foreachi"), new LuaTableLib_delegate("foreachi")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("getn"), new LuaTableLib_delegate("getn")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("maxn"), new LuaTableLib_delegate("maxn")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("insert"), new LuaTableLib_delegate("tinsert")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("remove"), new LuaTableLib_delegate("tremove")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("setn"), new LuaTableLib_delegate("setn")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("sort"), new LuaTableLib_delegate("sort")), new LuaAuxLib.luaL_Reg(null, null)];

    static int luaopen_table(LuaState.lua_State L)
    {
        LuaAuxLib.luaL_register(L, CLib.CharPtr.toCharPtr(LuaLib.LUA_TABLIBNAME), tab_funcs);
        return 1;
    }
}

class LuaTableLib_delegate with Lua_lua_CFunction
{
    String name;

    LuaTableLib_delegate_(String name)
    {
        this.name = name;
    }

    final int exec(LuaState.lua_State L)
    {
        if (new String("tconcat") == name) {
            return tconcat(L);
        } else {
            if (new String("_foreach") == name) {
                return _foreach(L);
            } else {
                if (new String("foreachi") == name) {
                    return foreachi(L);
                } else {
                    if (new String("getn") == name) {
                        return getn(L);
                    } else {
                        if (new String("maxn") == name) {
                            return maxn(L);
                        } else {
                            if (new String("tinsert") == name) {
                                return tinsert(L);
                            } else {
                                if (new String("tremove") == name) {
                                    return tremove(L);
                                } else {
                                    if (new String("setn") == name) {
                                        return setn(L);
                                    } else {
                                        if (new String("sort") == name) {
                                            return sort(L);
                                        } else {
                                            return 0;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
