library kurumi;

class LuaLoadLib
{
    static final String LUA_POF = "luaopen_";
    static final String LUA_OFSEP = "_";
    static final String LIBPREFIX = "LOADLIB: ";
    static final String POF = LUA_POF;
    static final String LIB_FAIL = "open";
    static const int ERRLIB = 1;
    static const int ERRFUNC = 2;

    static void setprogdir(LuaState.lua_State L)
    {
        CLib.CharPtr buff = CLib.CharPtr.toCharPtr(StreamProxy.GetCurrentDirectory());
        LuaAuxLib.luaL_gsub(L, Lua.lua_tostring(L, -1), CLib.CharPtr.toCharPtr(LuaConf.LUA_EXECDIR), buff);
        LuaAPI.lua_remove(L, -2);
    }
    static final String DLMSG = "dynamic libraries not enabled; check your Lua installation";

    static void ll_unloadlib(Object lib)
    {
    }

    static Object ll_load(LuaState.lua_State L, CLib.CharPtr path)
    {
        Lua.lua_pushliteral(L, CLib.CharPtr.toCharPtr(DLMSG));
        return null;
    }

    static Lua.lua_CFunction ll_sym(LuaState.lua_State L, Object lib, CLib.CharPtr sym)
    {
        Lua.lua_pushliteral(L, CLib.CharPtr.toCharPtr(DLMSG));
        return null;
    }

    static Object ll_register(LuaState.lua_State L, CLib.CharPtr path)
    {
        Object plib = null;
        LuaAPI.lua_pushfstring(L, CLib.CharPtr.toCharPtr("%s%s"), LIBPREFIX, path);
        LuaAPI.lua_gettable(L, Lua.LUA_REGISTRYINDEX);
        if (!Lua.lua_isnil(L, -1)) {
            plib = LuaAPI.lua_touserdata(L, -1);
        } else {
            Lua.lua_pop(L, 1);
            LuaAuxLib.luaL_getmetatable(L, CLib.CharPtr.toCharPtr("_LOADLIB"));
            LuaAPI.lua_setmetatable(L, -2);
            LuaAPI.lua_pushfstring(L, CLib.CharPtr.toCharPtr("%s%s"), LIBPREFIX, path);
            LuaAPI.lua_pushvalue(L, -2);
            LuaAPI.lua_settable(L, Lua.LUA_REGISTRYINDEX);
        }
        return plib;
    }

    static int gctm(LuaState.lua_State L)
    {
        Object lib = LuaAuxLib.luaL_checkudata(L, 1, CLib.CharPtr.toCharPtr("_LOADLIB"));
        if (lib != null) {
            ll_unloadlib(lib);
        }
        lib = null;
        return 0;
    }

    static int ll_loadfunc(LuaState.lua_State L, CLib.CharPtr path, CLib.CharPtr sym)
    {
        Object reg = ll_register(L, path);
        if (reg == null) {
            reg = ll_load(L, path);
        }
        if (reg == null) {
            return ERRLIB;
        } else {
            Lua.lua_CFunction f = ll_sym(L, reg, sym);
            if (f == null) {
                return ERRFUNC;
            }
            Lua.lua_pushcfunction(L, f);
            return 0;
        }
    }

    static int ll_loadlib(LuaState.lua_State L)
    {
        CLib.CharPtr path = LuaAuxLib.luaL_checkstring(L, 1);
		    CLib.CharPtr init = LuaAuxLib.luaL_checkstring(L, 2);
        int stat = ll_loadfunc(L, path, init);
        if (stat == 0) {
            return 1;
        } else {
            LuaAPI.lua_pushnil(L);
            LuaAPI.lua_insert(L, -2);
            LuaAPI.lua_pushstring(L, (stat == ERRLIB) ? CLib.CharPtr.toCharPtr(LIB_FAIL) : CLib.CharPtr.toCharPtr("init"));
            return 3;
        }
    }

    static int readable(CLib.CharPtr filename)
    {
        StreamProxy f = CLib.fopen(filename, CLib.CharPtr.toCharPtr("r"));
        if (f == null) {
            return 0;
        }
        CLib.fclose(f);
        return 1;
    }

    static CLib.CharPtr pushnexttemplate(LuaState.lua_State L, CLib.CharPtr path)
    {
        CLib.CharPtr l;
        while (path.get(0) == LuaConf.LUA_PATHSEP.codeUnitAt(0)) {
            path = path.next();
        }
        if (path.get(0) == '\0'.codeUnitAt(0)) {
            return null;
        }
        l = CLib.strchr(path, LuaConf.LUA_PATHSEP.codeUnitAt(0));
        if (CLib.CharPtr.isEqual(l, null)) {
            l = CLib.CharPtr.plus(path, CLib.strlen(path));
        }
        LuaAPI.lua_pushlstring(L, path, CLib.CharPtr.minus(l, path));
        return l;
    }

    static CLib.CharPtr findfile(LuaState.lua_State L, CLib.CharPtr name, CLib.CharPtr pname)
    {
        CLib.CharPtr path;
        name = LuaAuxLib.luaL_gsub(L, name, CLib.CharPtr.toCharPtr("."), CLib.CharPtr.toCharPtr(LuaConf.LUA_DIRSEP));
        LuaAPI.lua_getfield(L, Lua.LUA_ENVIRONINDEX, pname);
        path = Lua.lua_tostring(L, -1);
        if (CLib.CharPtr.isEqual(path, null)) {
            LuaAuxLib.luaL_error(L, CLib.CharPtr.toCharPtr(LuaConf.LUA_QL("package.%s") + " must be a string"), pname);
        }
        Lua.lua_pushliteral(L, CLib.CharPtr.toCharPtr(""));
        while (CLib.CharPtr.isNotEqual(path = pushnexttemplate(L, path), null)) {
            CLib.CharPtr filename;
            filename = LuaAuxLib.luaL_gsub(L, Lua.lua_tostring(L, -1), CLib.CharPtr.toCharPtr(LuaConf.LUA_PATH_MARK), name);
            LuaAPI.lua_remove(L, -2);
            if (readable(filename) != 0) {
                return filename;
            }
            LuaAPI.lua_pushfstring(L, CLib.CharPtr.toCharPtr("\n\tno file " + LuaConf.getLUA_QS()), filename);
            LuaAPI.lua_remove(L, -2);
            LuaAPI.lua_concat(L, 2);
        }
        return null;
    }

    static void loaderror(LuaState.lua_State L, CLib.CharPtr filename)
    {
        LuaAuxLib.luaL_error(L, CLib.CharPtr.toCharPtr(((("error loading module " + LuaConf.getLUA_QS()) + " from file ") + LuaConf.getLUA_QS()) + ":\n\t%s"), Lua.lua_tostring(L, 1), filename, Lua.lua_tostring(L, -1));
    }

    static int loader_Lua(LuaState.lua_State L)
    {
        CLib.CharPtr filename;
		    CLib.CharPtr name = LuaAuxLib.luaL_checkstring(L, 1);
        filename = findfile(L, name, CLib.CharPtr.toCharPtr("path"));
        if (CLib.CharPtr.isEqual(filename, null)) {
            return 1;
        }
        if (LuaAuxLib.luaL_loadfile(L, filename) != 0) {
            loaderror(L, filename);
        }
        return 1;
    }

    static CLib.CharPtr mkfuncname(LuaState.lua_State L, CLib.CharPtr modname)
    {
        CLib.CharPtr funcname;
		    CLib.CharPtr mark = CLib.strchr(modname, LuaConf.LUA_IGMARK.charAt(0));
        if (CLib.CharPtr.isNotEqual(mark, null)) {
            modname = CLib.CharPtr.plus(mark, 1);
        }
        funcname = LuaAuxLib.luaL_gsub(L, modname, CLib.CharPtr.toCharPtr("."), CLib.CharPtr.toCharPtr(LUA_OFSEP));
        funcname = LuaAPI.lua_pushfstring(L, CLib.CharPtr.toCharPtr(POF + "%s"), funcname);
        LuaAPI.lua_remove(L, -2);
        return funcname;
    }

    static int loader_C(LuaState.lua_State L)
    {
        CLib.CharPtr funcname;
		    CLib.CharPtr name = LuaAuxLib.luaL_checkstring(L, 1);
		    CLib.CharPtr filename = findfile(L, name, CLib.CharPtr.toCharPtr("cpath"));
        if (CLib.CharPtr.isEqual(filename, null)) {
            return 1;
        }
        funcname = mkfuncname(L, name);
        if (ll_loadfunc(L, filename, funcname) != 0) {
            loaderror(L, filename);
        }
        return 1;
    }

    static int loader_Croot(LuaState.lua_State L)
    {
        CLib.CharPtr funcname;
		    CLib.CharPtr filename;
		    CLib.CharPtr name = LuaAuxLib.luaL_checkstring(L, 1);
		    CLib.CharPtr p = CLib.strchr(name, '.');
        int stat;
        if (CLib.CharPtr.isEqual(p, null)) {
            return 0;
        }
        LuaAPI.lua_pushlstring(L, name, CLib.CharPtr.minus(p, name));
        filename = findfile(L, Lua.lua_tostring(L, -1), CLib.CharPtr.toCharPtr("cpath"));
        if (CLib.CharPtr.isEqual(filename, null)) {
            return 1;
        }
        funcname = mkfuncname(L, name);
        if ((stat = ll_loadfunc(L, filename, funcname)) != 0) {
            if (stat != ERRFUNC) {
                loaderror(L, filename);
            }
            LuaAPI.lua_pushfstring(L, CLib.CharPtr.toCharPtr((("\n\tno module " + LuaConf.getLUA_QS()) + " in file ") + LuaConf.getLUA_QS()), name, filename);
            return 1;
        }
        return 1;
    }

    static int loader_preload(LuaState.lua_State L)
    {
        CLib.CharPtr name = LuaAuxLib.luaL_checkstring(L, 1);
        LuaAPI.lua_getfield(L, Lua.LUA_ENVIRONINDEX, CLib.CharPtr.toCharPtr("preload"));
        if (!Lua.lua_istable(L, -1)) {
            LuaAuxLib.luaL_error(L, CLib.CharPtr.toCharPtr(LuaConf.LUA_QL("package.preload") + " must be a table"));
        }
        LuaAPI.lua_getfield(L, -1, name);
        if (Lua.lua_isnil(L, -1)) {
            LuaAPI.lua_pushfstring(L, CLib.CharPtr.toCharPtr("\n\tno field package.preload['%s']"), name);
        }
        return 1;
    }
    static Object sentinel = new Object();

    static int ll_require(LuaState.lua_State L)
    {
        CLib.CharPtr name = LuaAuxLib.luaL_checkstring(L, 1);
        int i;
        LuaAPI.lua_settop(L, 1);
        LuaAPI.lua_getfield(L, Lua.LUA_REGISTRYINDEX, CLib.CharPtr.toCharPtr("_LOADED"));
        LuaAPI.lua_getfield(L, 2, name);
        if (LuaAPI.lua_toboolean(L, -1) != 0) {
            if (LuaAPI.lua_touserdata(L, -1) == sentinel) {
                LuaAuxLib.luaL_error(L, CLib.CharPtr.toCharPtr("loop or previous error loading module " + LuaConf.getLUA_QS()), name);
            }
            return 1;
        }
        LuaAPI.lua_getfield(L, Lua.LUA_ENVIRONINDEX, CLib.CharPtr.toCharPtr("loaders"));
        if (!Lua.lua_istable(L, -1)) {
            LuaAuxLib.luaL_error(L, CLib.CharPtr.toCharPtr(LuaConf.LUA_QL("package.loaders") + " must be a table"));
        }
        Lua.lua_pushliteral(L, CLib.CharPtr.toCharPtr(""));
        for ((i = 1); ; i++) {
            LuaAPI.lua_rawgeti(L, -2, i);
            if (Lua.lua_isnil(L, -1)) {
                LuaAuxLib.luaL_error(L, CLib.CharPtr.toCharPtr(("module " + LuaConf.getLUA_QS()) + " not found:%s"), name, Lua.lua_tostring(L, -2));
            }
            LuaAPI.lua_pushstring(L, name);
            LuaAPI.lua_call(L, 1, 1);
            if (Lua.lua_isfunction(L, -1)) {
                break;
            } else {
                if (LuaAPI.lua_isstring(L, -1) != 0) {
                    LuaAPI.lua_concat(L, 2);
                } else {
                    Lua.lua_pop(L, 1);
                }
            }
        }
        LuaAPI.lua_pushlightuserdata(L, sentinel);
        LuaAPI.lua_setfield(L, 2, name);
        LuaAPI.lua_pushstring(L, name);
        LuaAPI.lua_call(L, 1, 1);
        if (!Lua.lua_isnil(L, -1)) {
            LuaAPI.lua_setfield(L, 2, name);
        }
        LuaAPI.lua_getfield(L, 2, name);
        if (LuaAPI.lua_touserdata(L, -1) == sentinel) {
            LuaAPI.lua_pushboolean(L, 1);
            LuaAPI.lua_pushvalue(L, -1);
            LuaAPI.lua_setfield(L, 2, name);
        }
        return 1;
    }

    static void setfenv(LuaState.lua_State L)
    {
        Lua.lua_Debug ar = new Lua.lua_Debug();
        if (((LuaDebug.lua_getstack(L, 1, ar) == 0) || (LuaDebug.lua_getinfo(L, CLib.CharPtr.toCharPtr("f"), ar) == 0)) || LuaAPI.lua_iscfunction(L, -1)) {
            LuaAuxLib.luaL_error(L, CLib.CharPtr.toCharPtr(LuaConf.LUA_QL("module") + " not called from a Lua function"));
        }
        LuaAPI.lua_pushvalue(L, -2);
        LuaAPI.lua_setfenv(L, -2);
        Lua.lua_pop(L, 1);
    }

    static void dooptions(LuaState.lua_State L, int n)
    {
        int i;
        for ((i = 2); i <= n; i++) {
            LuaAPI.lua_pushvalue(L, i);
            LuaAPI.lua_pushvalue(L, -2);
            LuaAPI.lua_call(L, 1, 0);
        }
    }

    static void modinit(LuaState.lua_State L, CLib.CharPtr modname)
    {
        CLib.CharPtr dot;
        LuaAPI.lua_pushvalue(L, -1);
        LuaAPI.lua_setfield(L, -2, CLib.CharPtr.toCharPtr("_M"));
        LuaAPI.lua_pushstring(L, modname);
        LuaAPI.lua_setfield(L, -2, CLib.CharPtr.toCharPtr("_NAME"));
        dot = CLib.strrchr(modname, '.'.codeUnitAt(0));
        if (CLib.CharPtr.isEqual(dot, null)) {
            dot = modname;
        } else {
            dot = dot.next();
        }
        LuaAPI.lua_pushlstring(L, modname, CLib.CharPtr.minus(dot, modname));
        LuaAPI.lua_setfield(L, -2, CLib.CharPtr.toCharPtr("_PACKAGE"));
    }

    static int ll_module(LuaState.lua_State L)
    {
        CLib.CharPtr modname = LuaAuxLib.luaL_checkstring(L, 1);
        int loaded = (LuaAPI.lua_gettop(L) + 1);
        LuaAPI.lua_getfield(L, Lua.LUA_REGISTRYINDEX, CLib.CharPtr.toCharPtr("_LOADED"));
        LuaAPI.lua_getfield(L, loaded, modname);
        if (!Lua.lua_istable(L, -1)) {
            Lua.lua_pop(L, 1);
            if (CLib.CharPtr.isNotEqual(LuaAuxLib.luaL_findtable(L, Lua.LUA_GLOBALSINDEX, modname, 1), null)) {
                return LuaAuxLib.luaL_error(L, CLib.CharPtr.toCharPtr("name conflict for module " + LuaConf.getLUA_QS()), modname);
            }
            LuaAPI.lua_pushvalue(L, -1);
            LuaAPI.lua_setfield(L, loaded, modname);
        }
        LuaAPI.lua_getfield(L, -1, CLib.CharPtr.toCharPtr("_NAME"));
        if (!Lua.lua_isnil(L, -1)) {
            Lua.lua_pop(L, 1);
        } else {
            Lua.lua_pop(L, 1);
            modinit(L, modname);
        }
        LuaAPI.lua_pushvalue(L, -1);
        setfenv(L);
        dooptions(L, loaded - 1);
        return 0;
    }

    static int ll_seeall(LuaState.lua_State L)
    {
        LuaAuxLib.luaL_checktype(L, 1, Lua.LUA_TTABLE);
        if (LuaAPI.lua_getmetatable(L, 1) == 0) {
            LuaAPI.lua_createtable(L, 0, 1);
            LuaAPI.lua_pushvalue(L, -1);
            LuaAPI.lua_setmetatable(L, 1);
        }
        LuaAPI.lua_pushvalue(L, Lua.LUA_GLOBALSINDEX);
        LuaAPI.lua_setfield(L, -2, CLib.CharPtr.toCharPtr("__index"));
        return 0;
    }
    static final String AUXMARK = String_.format("%1\$s", 1);

    static void setpath(LuaState.lua_State L, CLib.CharPtr fieldname, CLib.CharPtr envname, CLib.CharPtr def)
    {
        CLib.CharPtr path = CLib.getenv(envname);
        if (CLib.CharPtr.isEqual(path, null)) {
            LuaAPI.lua_pushstring(L, def);
        } else {
            path = LuaAuxLib.luaL_gsub(L, path, CLib.CharPtr.toCharPtr(LuaConf.LUA_PATHSEP + LuaConf.LUA_PATHSEP), CLib.CharPtr.toCharPtr((LuaConf.LUA_PATHSEP + AUXMARK) + LuaConf.LUA_PATHSEP));
            LuaAuxLib.luaL_gsub(L, path, CLib.CharPtr.toCharPtr(AUXMARK), def);
            LuaAPI.lua_remove(L, -2);
        }
        setprogdir(L);
        LuaAPI.lua_setfield(L, -2, fieldname);
    }
    static final List<LuaAuxLib.luaL_Reg> pk_funcs = [new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("loadlib"), new LuaLoadLib_delegate("ll_loadlib")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("seeall"), new LuaLoadLib_delegate("ll_seeall")), new LuaAuxLib.luaL_Reg(null, null)];
    static final List<LuaAuxLib.luaL_Reg> ll_funcs = [new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("module"), new LuaLoadLib_delegate("ll_module")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("require"), new LuaLoadLib_delegate("ll_require")), new LuaAuxLib.luaL_Reg(null, null)];
    static final List<Lua.lua_CFunction> loaders = [new LuaLoadLib_delegate("loader_preload"), new LuaLoadLib_delegate("loader_Lua"), new LuaLoadLib_delegate("loader_C"), new LuaLoadLib_delegate("loader_Croot"), null];

    static int luaopen_package(LuaState.lua_State L)
    {
        int i;
        LuaAuxLib.luaL_newmetatable(L, CLib.CharPtr.toCharPtr("_LOADLIB"));
        Lua.lua_pushcfunction(L, new LuaLoadLib_delegate("gctm"));
        LuaAPI.lua_setfield(L, -2, CLib.CharPtr.toCharPtr("__gc"));
        LuaAuxLib.luaL_register(L, CLib.CharPtr.toCharPtr(LuaLib.LUA_LOADLIBNAME), pk_funcs);
        LuaAPI.lua_pushvalue(L, -1);
        LuaAPI.lua_replace(L, Lua.LUA_ENVIRONINDEX);
        LuaAPI.lua_createtable(L, 0, loaders.length - 1);
        for ((i = 0); loaders[i] != null; i++) {
            Lua.lua_pushcfunction(L, loaders[i]);
            LuaAPI.lua_rawseti(L, -2, i + 1);
        }
        LuaAPI.lua_setfield(L, -2, CLib.CharPtr.toCharPtr("loaders"));
        setpath(L, CLib.CharPtr.toCharPtr("path"), CLib.CharPtr.toCharPtr(LuaConf.LUA_PATH), CLib.CharPtr.toCharPtr(LuaConf.LUA_PATH_DEFAULT));
        setpath(L, CLib.CharPtr.toCharPtr("cpath"), CLib.CharPtr.toCharPtr(LuaConf.LUA_CPATH), CLib.CharPtr.toCharPtr(LuaConf.LUA_CPATH_DEFAULT));
        Lua.lua_pushliteral(L, CLib.CharPtr.toCharPtr((((((((LuaConf.LUA_DIRSEP + "\n") + LuaConf.LUA_PATHSEP) + "\n") + LuaConf.LUA_PATH_MARK) + "\n") + LuaConf.LUA_EXECDIR) + "\n") + LuaConf.LUA_IGMARK));
        LuaAPI.lua_setfield(L, -2, CLib.CharPtr.toCharPtr("config"));
        LuaAuxLib.luaL_findtable(L, Lua.LUA_REGISTRYINDEX, CLib.CharPtr.toCharPtr("_LOADED"), 2);
        LuaAPI.lua_setfield(L, -2, CLib.CharPtr.toCharPtr("loaded"));
        Lua.lua_newtable(L);
        LuaAPI.lua_setfield(L, -2, CLib.CharPtr.toCharPtr("preload"));
        LuaAPI.lua_pushvalue(L, Lua.LUA_GLOBALSINDEX);
        LuaAuxLib.luaL_register(L, null, ll_funcs);
        Lua.lua_pop(L, 1);
        return 1;
    }
}

class LuaLoadLib_delegate with Lua_lua_CFunction
{
    String name;

    LuaLoadLib_delegate_(String name)
    {
        this.name = name;
    }

    final int exec(LuaState.lua_State L)
    {
        if (new String("ll_loadlib") == name) {
            return ll_loadlib(L);
        } else {
            if (new String("ll_seeall") == name) {
                return ll_seeall(L);
            } else {
                if (new String("ll_module") == name) {
                    return ll_module(L);
                } else {
                    if (new String("ll_require") == name) {
                        return ll_require(L);
                    } else {
                        if (new String("loader_preload") == name) {
                            return loader_preload(L);
                        } else {
                            if (new String("loader_Lua") == name) {
                                return loader_Lua(L);
                            } else {
                                if (new String("loader_C") == name) {
                                    return loader_C(L);
                                } else {
                                    if (new String("loader_Croot") == name) {
                                        return loader_Croot(L);
                                    } else {
                                        if (new String("gctm") == name) {
                                            return gctm(L);
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
