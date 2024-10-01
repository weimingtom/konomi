library kurumi;

class Lua
{
    static final String LUA_VERSION = "Lua 5.1";
    static final String LUA_RELEASE = "Lua 5.1.4";
    static const int LUA_VERSION_NUM = 501;
    static final String LUA_COPYRIGHT = "Copyright (C) 1994-2008 Lua.org, PUC-Rio";
    static final String LUA_AUTHORS = "R. Ierusalimschy, L. H. de Figueiredo & W. Celes";
    static final String LUA_SIGNATURE = "\u001bLua";
    static const int LUA_MULTRET = (-1);
    static const int LUA_REGISTRYINDEX = (-10000);
    static const int LUA_ENVIRONINDEX = (-10001);
    static const int LUA_GLOBALSINDEX = (-10002);

    static int lua_upvalueindex(int i)
    {
        return LUA_GLOBALSINDEX - i;
    }
    static const int LUA_YIELD = 1;
    static const int LUA_ERRRUN = 2;
    static const int LUA_ERRSYNTAX = 3;
    static const int LUA_ERRMEM = 4;
    static const int LUA_ERRERR = 5;

    abstract class lua_CFunction
    {

        int exec(LuaState.lua_State L);
    }

    abstract class lua_Reader
    {

        CLib.CharPtr exec(LuaState.lua_State L, Object ud, List<int> sz);
    }

    abstract class lua_Writer
    {

        int exec(LuaState.lua_State L, CLib.CharPtr p, int sz, Object ud);
    }

    abstract class lua_Alloc
    {

        Object exec(ClassType t);
    }
    static const int LUA_TNONE = (-1);
    static const int LUA_TNIL = 0;
    static const int LUA_TBOOLEAN = 1;
    static const int LUA_TLIGHTUSERDATA = 2;
    static const int LUA_TNUMBER = 3;
    static const int LUA_TSTRING = 4;
    static const int LUA_TTABLE = 5;
    static const int LUA_TFUNCTION = 6;
    static const int LUA_TUSERDATA = 7;
    static const int LUA_TTHREAD = 8;
    static const int LUA_MINSTACK = 20;
    static const int LUA_GCSTOP = 0;
    static const int LUA_GCRESTART = 1;
    static const int LUA_GCCOLLECT = 2;
    static const int LUA_GCCOUNT = 3;
    static const int LUA_GCCOUNTB = 4;
    static const int LUA_GCSTEP = 5;
    static const int LUA_GCSETPAUSE = 6;
    static const int LUA_GCSETSTEPMUL = 7;

    static void lua_pop(LuaState.lua_State L, int n)
    {
        LuaAPI.lua_settop(L, -(-1));
    }

    static void lua_newtable(LuaState.lua_State L)
    {
        LuaAPI.lua_createtable(L, 0, 0);
    }

    static void lua_register(LuaState.lua_State L, CLib.CharPtr n, lua_CFunction f)
    {
        lua_pushcfunction(L, f);
        lua_setglobal(L, n);
    }

    static void lua_pushcfunction(LuaState.lua_State L, lua_CFunction f)
    {
        LuaAPI.lua_pushcclosure(L, f, 0);
    }

    static int lua_strlen(LuaState.lua_State L, int i)
    {
        return LuaAPI.lua_objlen(L, i);
    }

    static bool lua_isfunction(LuaState.lua_State L, int n)
    {
        return LuaAPI.lua_type(L, n) == LUA_TFUNCTION;
    }

    static bool lua_istable(LuaState.lua_State L, int n)
    {
        return LuaAPI.lua_type(L, n) == LUA_TTABLE;
    }

    static bool lua_islightuserdata(LuaState.lua_State L, int n)
    {
        return LuaAPI.lua_type(L, n) == LUA_TLIGHTUSERDATA;
    }

    static bool lua_isnil(LuaState.lua_State L, int n)
    {
        return LuaAPI.lua_type(L, n) == LUA_TNIL;
    }

    static bool lua_isboolean(LuaState.lua_State L, int n)
    {
        return LuaAPI.lua_type(L, n) == LUA_TBOOLEAN;
    }

    static bool lua_isthread(LuaState.lua_State L, int n)
    {
        return LuaAPI.lua_type(L, n) == LUA_TTHREAD;
    }

    static bool lua_isnone(LuaState.lua_State L, int n)
    {
        return LuaAPI.lua_type(L, n) == LUA_TNONE;
    }

    static bool lua_isnoneornil(LuaState.lua_State L, double n)
    {
        return LuaAPI.lua_type(L, n) <= 0;
    }

    static void lua_pushliteral(LuaState.lua_State L, CLib.CharPtr s)
    {
        LuaAPI.lua_pushstring(L, s);
    }

    static void lua_setglobal(LuaState.lua_State L, CLib.CharPtr s)
    {
        LuaAPI.lua_setfield(L, LUA_GLOBALSINDEX, s);
    }

    static void lua_getglobal(LuaState.lua_State L, CLib.CharPtr s)
    {
        LuaAPI.lua_getfield(L, LUA_GLOBALSINDEX, s);
    }

    static CLib.CharPtr lua_tostring(LuaState.lua_State L, int i)
    {
        List<int> blah = new List<int>(1);
        return LuaAPI.lua_tolstring(L, i, blah);
    }

    static LuaState.lua_State lua_open()
    {
        return LuaAuxLib.luaL_newstate();
    }

    static void lua_getregistry(LuaState.lua_State L)
    {
        LuaAPI.lua_pushvalue(L, LUA_REGISTRYINDEX);
    }

    static int lua_getgccount(LuaState.lua_State L)
    {
        return LuaAPI.lua_gc(L, LUA_GCCOUNT, 0);
    }
    static const int LUA_HOOKCALL = 0;
    static const int LUA_HOOKRET = 1;
    static const int LUA_HOOKLINE = 2;
    static const int LUA_HOOKCOUNT = 3;
    static const int LUA_HOOKTAILRET = 4;
    static const int LUA_MASKCALL = (1 << LUA_HOOKCALL);
    static const int LUA_MASKRET = (1 << LUA_HOOKRET);
    static const int LUA_MASKLINE = (1 << LUA_HOOKLINE);
    static const int LUA_MASKCOUNT = (1 << LUA_HOOKCOUNT);

    abstract class lua_Hook
    {

        void exec(LuaState.lua_State L, Lua.lua_Debug ar);
    }
}

class lua_Debug
{
    int event_;
    CLib.CharPtr name;
    CLib.CharPtr namewhat;
    CLib.CharPtr what;
    CLib.CharPtr source;
    int currentline;
    int nups;
    int linedefined;
    int lastlinedefined;
    CLib.CharPtr short_src = CLib.CharPtr.toCharPtr(new List<int>(LuaConf.LUA_IDSIZE));
    int i_ci;
}
