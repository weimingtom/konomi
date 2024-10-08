library kurumi;

class LuaProgram
{
    static LuaState.lua_State globalL = null;
    static CLib.CharPtr progname = CLib.CharPtr.toCharPtr(LuaConf.LUA_PROGNAME);

    static void lstop(LuaState.lua_State L, Lua.lua_Debug ar)
    {
        LuaDebug.lua_sethook(L, null, 0, 0);
        LuaAuxLib.luaL_error(L, CLib.CharPtr.toCharPtr("interrupted!"));
    }

    static void laction(int i)
    {
        LuaDebug.lua_sethook(globalL, new lstop_delegate(), (Lua.LUA_MASKCALL | Lua.LUA_MASKRET) | Lua.LUA_MASKCOUNT, 1);
    }

    static void print_usage()
    {
        StreamProxy.ErrorWrite((((((((((((((("usage: " + progname.toString()) + " [options] [script [args]].\n") + "Available options are:\n") + "  -e stat  execute string ") + LuaConf.LUA_QL("stat").toString()) + "\n") + "  -l name  require library ") + LuaConf.LUA_QL("name").toString()) + "\n") + "  -i       enter interactive mode after executing ") + LuaConf.LUA_QL("script").toString()) + "\n") + "  -v       show version information\n") + "  --       stop handling options\n") + "  -        execute stdin and stop handling options\n");
    }

    static void l_message(CLib.CharPtr pname, CLib.CharPtr msg)
    {
        if (CLib.CharPtr.isNotEqual(pname, null)) {
            CLib.fprintf(CLib.stderr, CLib.CharPtr.toCharPtr("%s: "), pname);
        }
        CLib.fprintf(CLib.stderr, CLib.CharPtr.toCharPtr("%s\n"), msg);
        CLib.fflush(CLib.stderr);
    }

    static int report(LuaState.lua_State L, int status)
    {
        if ((status != 0) && (!Lua.lua_isnil(L, -1))) {
            CLib.CharPtr msg = Lua.lua_tostring(L, -1);
            if (CLib.CharPtr.isEqual(msg, null)) {
                msg = CLib.CharPtr.toCharPtr("(error object is not a string)");
            }
            l_message(progname, msg);
            Lua.lua_pop(L, 1);
        }
        return status;
    }

    static int traceback(LuaState.lua_State L)
    {
        if (LuaAPI.lua_isstring(L, 1) == 0) {
            return 1;
        }
        LuaAPI.lua_getfield(L, Lua.LUA_GLOBALSINDEX, CLib.CharPtr.toCharPtr("debug"));
        if (!Lua.lua_istable(L, -1)) {
            Lua.lua_pop(L, 1);
            return 1;
        }
        LuaAPI.lua_getfield(L, -1, CLib.CharPtr.toCharPtr("traceback"));
        if (!Lua.lua_isfunction(L, -1)) {
            Lua.lua_pop(L, 2);
            return 1;
        }
        LuaAPI.lua_pushvalue(L, 1);
        LuaAPI.lua_pushinteger(L, 2);
        LuaAPI.lua_call(L, 2, 1);
        return 1;
    }

    static int docall(LuaState.lua_State L, int narg, int clear)
    {
        int status;
        int base_ = (LuaAPI.lua_gettop(L) - narg);
        Lua.lua_pushcfunction(L, new traceback_delegate());
        LuaAPI.lua_insert(L, base_);
        status = LuaAPI.lua_pcall(L, narg, (clear != 0) ? 0 : Lua.LUA_MULTRET, base_);
        LuaAPI.lua_remove(L, base_);
        if (status != 0) {
            LuaAPI.lua_gc(L, Lua.LUA_GCCOLLECT, 0);
        }
        return status;
    }

    static void print_version()
    {
        l_message(null, CLib.CharPtr.toCharPtr((Lua.LUA_RELEASE + "  ") + Lua.LUA_COPYRIGHT));
    }

    static int getargs(LuaState.lua_State L, List<String> argv, int n)
    {
        int narg;
        int i;
        int argc = argv.length;
        narg = (argc - (n + 1));
        LuaAuxLib.luaL_checkstack(L, narg + 3, CLib.CharPtr.toCharPtr("too many arguments to script"));
        for ((i = (n + 1)); i < argc; i++) {
            LuaAPI.lua_pushstring(L, CLib.CharPtr.toCharPtr(argv[i]));
        }
        LuaAPI.lua_createtable(L, narg, n + 1);
        for ((i = 0); i < argc; i++) {
            LuaAPI.lua_pushstring(L, CLib.CharPtr.toCharPtr(argv[i]));
            LuaAPI.lua_rawseti(L, -2, i - n);
        }
        return narg;
    }

    static int dofile(LuaState.lua_State L, CLib.CharPtr name)
    {
        int status = (((LuaAuxLib.luaL_loadfile(L, name) != 0) || (docall(L, 0, 1) != 0)) ? 1 : 0);
        return report(L, status);
    }

    static int dostring(LuaState.lua_State L, CLib.CharPtr s, CLib.CharPtr name)
    {
        int status = (((LuaAuxLib.luaL_loadbuffer(L, s, CLib.strlen(s), name) != 0) || (docall(L, 0, 1) != 0)) ? 1 : 0);
        return report(L, status);
    }

    static int dolibrary(LuaState.lua_State L, CLib.CharPtr name)
    {
        Lua.lua_getglobal(L, CLib.CharPtr.toCharPtr("require"));
        LuaAPI.lua_pushstring(L, name);
        return report(L, docall(L, 1, 1));
    }

    static CLib.CharPtr get_prompt(LuaState.lua_State L, int firstline)
    {
        CLib.CharPtr p;
        LuaAPI.lua_getfield(L, Lua.LUA_GLOBALSINDEX, (firstline != 0) ? CLib.CharPtr.toCharPtr("_PROMPT") : CLib.CharPtr.toCharPtr("_PROMPT2"));
        p = Lua.lua_tostring(L, -1);
        if (CLib.CharPtr.isEqual(p, null)) {
            p = ((firstline != 0) ? CLib.CharPtr.toCharPtr(LuaConf.LUA_PROMPT) : CLib.CharPtr.toCharPtr(LuaConf.LUA_PROMPT2));
        }
        Lua.lua_pop(L, 1);
        return p;
    }

    static int incomplete(LuaState.lua_State L, int status)
    {
        if (status == Lua.LUA_ERRSYNTAX) {
            List<int> lmsg = new List<int>(1);
            CLib.CharPtr msg = LuaAPI.lua_tolstring(L, -1, lmsg); //out
			      CLib.CharPtr tp = CLib.CharPtr.plus(msg, lmsg[0] - (CLib.strlen(LuaConf.LUA_QL("<eof>"))));
            if (CLib.CharPtr.isEqual(CLib.strstr(msg, LuaConf.LUA_QL("<eof>")), tp)) {
                Lua.lua_pop(L, 1);
                return 1;
            }
        }
        return 0;
    }

    static int pushline(LuaState.lua_State L, int firstline)
    {
        CLib.CharPtr buffer = CLib.CharPtr.toCharPtr(new char[LuaConf.LUA_MAXINPUT]);
		    CLib.CharPtr b = new CLib.CharPtr(buffer);
        int l;
        CLib.CharPtr prmt = get_prompt(L, firstline);
        if (!LuaConf.lua_readline(L, b, prmt)) {
            return 0;
        }
        l = CLib.strlen(b);
        if ((l > 0) && (b.get(l - 1) == '\n'.codeUnitAt(0))) {
            b.set(l - 1, '\0'.codeUnitAt(0));
        }
        if ((firstline != 0) && (b.get(0) == '='.codeUnitAt(0))) {
            LuaAPI.lua_pushfstring(L, CLib.CharPtr.toCharPtr("return %s"), CLib.CharPtr.plus(b, 1));
        } else {
            LuaAPI.lua_pushstring(L, b);
        }
        LuaConf.lua_freeline(L, b);
        return 1;
    }

    static int loadline(LuaState.lua_State L)
    {
        int status;
        LuaAPI.lua_settop(L, 0);
        if (pushline(L, 1) == 0) {
            return -1;
        }
        for (; ; ) {
            status = LuaAuxLib.luaL_loadbuffer(L, Lua.lua_tostring(L, 1), Lua.lua_strlen(L, 1), CLib.CharPtr.toCharPtr("=stdin"));
            if (incomplete(L, status) == 0) {
                break;
            }
            if (pushline(L, 0) == 0) {
                return -1;
            }
            Lua.lua_pushliteral(L, CLib.CharPtr.toCharPtr("\n"));
            LuaAPI.lua_insert(L, -2);
            LuaAPI.lua_concat(L, 3);
        }
        LuaConf.lua_saveline(L, 1);
        LuaAPI.lua_remove(L, 1);
        return status;
    }

    static void dotty(LuaState.lua_State L)
    {
        int status;
        CLib.CharPtr oldprogname = progname;
        progname = null;
        while ((status = loadline(L)) != (-1)) {
            if (status == 0) {
                status = docall(L, 0, 0);
            }
            report(L, status);
            if ((status == 0) && (LuaAPI.lua_gettop(L) > 0)) {
                Lua.lua_getglobal(L, CLib.CharPtr.toCharPtr("print"));
                LuaAPI.lua_insert(L, 1);
                if (LuaAPI.lua_pcall(L, LuaAPI.lua_gettop(L) - 1, 0, 0) != 0) {
                    l_message(progname, LuaAPI.lua_pushfstring(L, CLib.CharPtr.toCharPtr(("error calling " + LuaConf.LUA_QL("print").toString()) + " (%s)"), Lua.lua_tostring(L, -1)));
                }
            }
        }
        LuaAPI.lua_settop(L, 0);
        CLib.fputs(CLib.CharPtr.toCharPtr("\n"), CLib.stdout);
        CLib.fflush(CLib.stdout);
        progname = oldprogname;
    }

    static int handle_script(LuaState.lua_State L, List<String> argv, int n)
    {
        int status;
        CLib.CharPtr fname;
        int narg = getargs(L, argv, n);
        Lua.lua_setglobal(L, CLib.CharPtr.toCharPtr("arg"));
        fname = CLib.CharPtr.toCharPtr(argv[n]);
        if ((CLib.strcmp(fname, CLib.CharPtr.toCharPtr("-")) == 0) && (CLib.strcmp(CLib.CharPtr.toCharPtr(argv[n - 1]), CLib.CharPtr.toCharPtr("--")) != 0)) {
            fname = null;
        }
        status = LuaAuxLib.luaL_loadfile(L, fname);
        LuaAPI.lua_insert(L, -(narg + 1));
        if (status == 0) {
            status = docall(L, narg, 0);
        } else {
            Lua.lua_pop(L, narg);
        }
        return report(L, status);
    }

    static int collectargs(List<String> argv, List<int> pi, List<int> pv, List<int> pe)
    {
        int i;
        for ((i = 1); i < argv.length; i++) {
            if (argv[i].codeUnitAt(0) != '-'.codeUnitAt(0)) {
                return i;
            }
            int ch = argv[i].codeUnitAt(1);
            switch (ch) {
                case '-'.codeUnitAt(0):
                    if (argv[i].length != 2) {
                        return -1;
                    }
                    return ((i + 1) >= argv.length) ? (i + 1) : 0;
                case '\0'.codeUnitAt(0):
                    return i;
                case 'i'.codeUnitAt(0):
                    if (argv[i].length != 2) {
                        return -1;
                    }
                    pi[0] = 1;
                    if (argv[i].length != 2) {
                        return -1;
                    }
                    pv[0] = 1;
                    break;
                case 'v'.codeUnitAt(0):
                    if (argv[i].length != 2) {
                        return -1;
                    }
                    pv[0] = 1;
                    break;
                case 'e'.codeUnitAt(0):
                    pe[0] = 1;
                    if (argv[i].length == 2) {
                        i++;
                        if (argv[i] == null) {
                            return -1;
                        }
                    }
                    break;
                case 'l'.codeUnitAt(0):
                    if (argv[i].length == 2) {
                        i++;
                        if (i >= argv.length) {
                            return -1;
                        }
                    }
                    break;
                default:
                    return -1;
            }
        }
        return 0;
    }

    static int runargs(LuaState.lua_State L, List<String> argv, int n)
    {
        int i;
        for ((i = 1); i < n; i++) {
            if (argv[i] == null) {
                continue;
            }
            LuaLimits.lua_assert(argv[i].codeUnitAt(0) == '-'.codeUnitAt(0));
            int ch = argv[i].codeUnitAt(1);
            switch (ch) {
                case 'e'.codeUnitAt(0):
                    String chunk = argv[i].substring(2);
                    if (chunk == "") {
                        chunk = argv[++i];
                    }
                    LuaLimits.lua_assert(chunk != null);
                    if (dostring(L, CLib.CharPtr.toCharPtr(chunk), CLib.CharPtr.toCharPtr("=(command line)")) != 0) {
                        return 1;
                    }
                    break;
                case 'l'.codeUnitAt(0):
                    String filename = argv[i].substring(2);
                    if (filename == "") {
                        filename = argv[++i];
                    }
                    LuaLimits.lua_assert(filename != null);
                    if (dolibrary(L, CLib.CharPtr.toCharPtr(filename)) != 0) {
                        return 1;
                    }
                    break;
                default:
                    break;
            }
        }
        return 0;
    }

    static int handle_luainit(LuaState.lua_State L)
    {
        CLib.CharPtr init = CLib.getenv(CLib.CharPtr.toCharPtr(LuaConf.LUA_INIT));
        if (CLib.CharPtr.isEqual(init, null)) {
            return 0;
        } else {
            if (init.get(0) == '@'.codeUnitAt(0)) {
                return dofile(L, CLib.CharPtr.plus(init, 1));
            } else {
                return dostring(L, init, CLib.CharPtr.toCharPtr("=" + LuaConf.LUA_INIT));
            }
        }
    }

    static int pmain(LuaState.lua_State L)
    {
        SmainLua s = LuaAPI.lua_touserdata(L, 1);
        List<String> argv = s.argv;
        int script;
        List<int> has_i = new List<int>(1);
        List<int> has_v = new List<int>(1);
        List<int> has_e = new List<int>(1);
        has_i[0] = 0;
        has_v[0] = 0;
        has_e[0] = 0;
        globalL = L;
        if ((argv.length > 0) && (!(argv[0] == ""))) {
            progname = CLib.CharPtr.toCharPtr(argv[0]);
        }
        LuaAPI.lua_gc(L, Lua.LUA_GCSTOP, 0);
        LuaInit.luaL_openlibs(L);
        LuaAPI.lua_gc(L, Lua.LUA_GCRESTART, 0);
        s.status = handle_luainit(L);
        if (s.status != 0) {
            return 0;
        }
        script = collectargs(argv, has_i, has_v, has_e);
        if (script < 0) {
            print_usage();
            s.status = 1;
            return 0;
        }
        if (has_v[0] != 0) {
            print_version();
        }
        s.status = runargs(L, argv, (script > 0) ? script : s.argc);
        if (s.status != 0) {
            return 0;
        }
        if (script != 0) {
            s.status = handle_script(L, argv, script);
        }
        if (s.status != 0) {
            return 0;
        }
        if (has_i[0] != 0) {
            dotty(L);
        } else {
            if (((script == 0) && (has_e[0] == 0)) && (has_v[0] == 0)) {
                if (LuaConf.lua_stdin_is_tty() != 0) {
                    print_version();
                    dotty(L);
                } else {
                    dofile(L, null);
                }
            }
        }
        return 0;
    }

    static int MainLua(List<String> args)
    {
        List<String> newargs = new List<String>((((args != null) ? args.length : 0) + 1));
        newargs[0] = "lua";
        for (int idx = 0; idx < args.length; idx++) {
            newargs[idx + 1] = args[idx];
        }
        args = newargs;
        int status;
        SmainLua s = new SmainLua();
        LuaState.lua_State L = Lua.lua_open(); // create state 
        if (L == null) {
            l_message(CLib.CharPtr.toCharPtr(args[0]), CLib.CharPtr.toCharPtr("cannot create state: not enough memory"));
            return CLib.EXIT_FAILURE;
        }
        s.argc = args.length;
        s.argv = args;
        status = LuaAPI.lua_cpcall(L, new pmain_delegate(), s);
        report(L, status);
        LuaState.lua_close(L);
        return ((status != 0) || (s.status != 0)) ? CLib.EXIT_FAILURE : CLib.EXIT_SUCCESS;
    }
}

class lstop_delegate with Lua_lua_Hook
{

    final void exec(LuaState.lua_State L, Lua.lua_Debug ar)
    {
        lstop(L, ar);
    }
}

class SmainLua
{
    int argc;
    List<String> argv;
    int status;
}

class pmain_delegate with Lua_lua_CFunction
{

    final int exec(LuaState.lua_State L)
    {
        return pmain(L);
    }
}

class traceback_delegate with Lua_lua_CFunction
{

    final int exec(LuaState.lua_State L)
    {
        return traceback(L);
    }
}
