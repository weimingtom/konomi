library kurumi;

class LuacProgram
{
    static CLib.CharPtr PROGNAME = CLib.CharPtr.toCharPtr("luac");
    static CLib.CharPtr OUTPUT = CLib.CharPtr.toCharPtr(PROGNAME + ".out");
    static int listing = 0;
    static int dumping = 1;
    static int stripping = 0;
    static CLib.CharPtr Output = OUTPUT;
    static CLib.CharPtr output = Output;
    static CLib.CharPtr progname = PROGNAME;

    static void fatal(CLib.CharPtr message)
    {
        CLib.fprintf(CLib.stderr, CLib.CharPtr.toCharPtr("%s: %s\n"), progname, message);
        System.exit(CLib.EXIT_FAILURE);
    }

    static void cannot(CLib.CharPtr what)
    {
        CLib.fprintf(CLib.stderr, CLib.CharPtr.toCharPtr("%s: cannot %s %s: %s\n"), progname, what, output, CLib.strerror(CLib.errno()));
        System.exit(CLib.EXIT_FAILURE);
    }

    static void usage(CLib.CharPtr message)
    {
        if (message.get(0) == '-'.codeUnitAt(0)) {
            CLib.fprintf(CLib.stderr, CLib.CharPtr.toCharPtr(("%s: unrecognized option " + LuaConf.getLUA_QS()) + "\n"), progname, message);
        } else {
            CLib.fprintf(CLib.stderr, CLib.CharPtr.toCharPtr("%s: %s\n"), progname, message);
        }
        CLib.fprintf(CLib.stderr, CLib.CharPtr.toCharPtr(((((((((("usage: %s [options] [filenames].\n" + "Available options are:\n") + "  -        process stdin\n") + "  -l       list\n") + "  -o name  output to file ") + LuaConf.LUA_QL("name")) + " (default is \"%s\")\n") + "  -p       parse only\n") + "  -s       strip debug information\n") + "  -v       show version information\n") + "  --       stop handling options\n"), progname, Output);
        System.exit(CLib.EXIT_FAILURE);
    }

    static int doargs(int argc, List<String> argv)
    {
        int i;
        int version = 0;
        if ((argv.length > 0) && (!(argv[0] == ""))) {
            progname = CLib.CharPtr.toCharPtr(argv[0]);
        }
        for ((i = 1); i < argc; i++) {
            if (argv[i].codeUnitAt(0) != '-'.codeUnitAt(0)) {
                break;
            } else {
                if (CLib.strcmp(CLib.CharPtr.toCharPtr(argv[i]), CLib.CharPtr.toCharPtr("--")) == 0) {
                    ++i;
                    if (version != 0) {
                        ++version;
                    }
                    break;
                } else {
                    if (CLib.strcmp(CLib.CharPtr.toCharPtr(argv[i]), CLib.CharPtr.toCharPtr("-")) == 0) {
                        break;
                    } else {
                        if (CLib.strcmp(CLib.CharPtr.toCharPtr(argv[i]), CLib.CharPtr.toCharPtr("-l")) == 0) {
                            ++listing;
                        } else {
                            if (CLib.strcmp(CLib.CharPtr.toCharPtr(argv[i]), CLib.CharPtr.toCharPtr("-o")) == 0) {
                                output = CLib.CharPtr.toCharPtr(argv[++i]);
                                if (CLib.CharPtr.isEqual(output, null) || (output.get(0) == 0)) {
                                    usage(CLib.CharPtr.toCharPtr(LuaConf.LUA_QL("-o") + " needs argument"));
                                }
                                if (CLib.strcmp(CLib.CharPtr.toCharPtr(argv[i]), CLib.CharPtr.toCharPtr("-")) == 0) {
                                    output = null;
                                }
                            } else {
                                if (CLib.strcmp(CLib.CharPtr.toCharPtr(argv[i]), CLib.CharPtr.toCharPtr("-p")) == 0) {
                                    dumping = 0;
                                } else {
                                    if (CLib.strcmp(CLib.CharPtr.toCharPtr(argv[i]), CLib.CharPtr.toCharPtr("-s")) == 0) {
                                        stripping = 1;
                                    } else {
                                        if (CLib.strcmp(CLib.CharPtr.toCharPtr(argv[i]), CLib.CharPtr.toCharPtr("-v")) == 0) {
                                            ++version;
                                        } else {
                                            usage(CLib.CharPtr.toCharPtr(argv[i]));
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        if ((i == argc) && ((listing != 0) || (dumping == 0))) {
            dumping = 0;
            argv[--i] = Output.toString();
        }
        if (version != 0) {
            CLib.printf(CLib.CharPtr.toCharPtr("%s  %s\n"), Lua.LUA_RELEASE, Lua.LUA_COPYRIGHT);
            if (version == (argc - 1)) {
                System.exit(CLib.EXIT_SUCCESS);
            }
        }
        return i;
    }

    static LuaObject.Proto toproto(LuaState.lua_State L, int i)
    {
        return LuaObject.clvalue(LuaObject.TValue.plus(L.top, i)).l.p;
    }

    static LuaObject.Proto combine(LuaState.lua_State L, int n)
    {
        if (n == 1) {
            return toproto(L, -1);
        } else {
            int i;
            int pc;
            LuaObject.Proto f = LuaFunc.luaF_newproto(L);
            LuaObject.setptvalue2s(L, L.top, f);
            LuaDo.incr_top(L);
            f.source = LuaString.luaS_newliteral(L, CLib.CharPtr.toCharPtr(("=(" + PROGNAME) + ")"));
            f.maxstacksize = 1;
            pc = ((2 * n) + 1);
            f.code = (long[])LuaMem.luaM_newvector_long(L, pc, new ClassType(ClassType.TYPE_LONG));
            f.sizecode = pc;
            f.p = LuaMem.luaM_newvector_Proto(L, n, new ClassType(ClassType_.TYPE_PROTO));
            f.sizep = n;
            pc = 0;
            for ((i = 0); i < n; i++) {
                f.p[i] = toproto(L, (i - n) - 1);
                f.code[pc++] = LuaOpCodes.CREATE_ABx(LuaOpCodes.OpCode.OP_CLOSURE, 0, i);
                f.code[pc++] = LuaOpCodes.CREATE_ABC(LuaOpCodes.OpCode.OP_CALL, 0, 1, 1);
            }
            f.code[pc++] = LuaOpCodes.CREATE_ABC(LuaOpCodes.OpCode.OP_RETURN, 0, 1, 0);
            return f;
        }
    }

    static int writer(LuaState.lua_State L, CLib.CharPtr p, int size, Object u)
    {
        return ((CLib.fwrite(p, size, 1, u) != 1) && (size != 0)) ? 1 : 0;
    }

    static int pmain(LuaState.lua_State L)
    {
        SmainLuac s = LuaAPI.lua_touserdata(L, 1);
        int argc = s.argc;
        List<String> argv = s.argv;
        LuaObject.Proto f;
        int i;
        if (LuaAPI.lua_checkstack(L, argc) == 0) {
            fatal(CLib.CharPtr.toCharPtr("too many input files"));
        }
        for ((i = 0); i < argc; i++) {
            CLib.CharPtr filename = (CLib.strcmp(CLib.CharPtr.toCharPtr(argv[i]), CLib.CharPtr.toCharPtr("-")) == 0) ? null : CLib.CharPtr.toCharPtr(argv[i]);
            if (LuaAuxLib.luaL_loadfile(L, filename) != 0) {
                fatal(Lua.lua_tostring(L, -1));
            }
        }
        f = combine(L, argc);
        if (listing != 0) {
            LuaPrint.luaU_print(f, (listing > 1) ? 1 : 0);
        }
        if (dumping != 0) {
            StreamProxy D = (CLib.CharPtr.isEqual(output, null) ? CLib.stdout : CLib.fopen(output, CLib.CharPtr.toCharPtr("wb")));
            if (D == null) {
                cannot(CLib.CharPtr.toCharPtr("open"));
            }
            LuaLimits.lua_lock(L);
            LuaDump.luaU_dump(L, f, new writer_delegate(), D, stripping);
            LuaLimits.lua_unlock(L);
            if (CLib.ferror(D) != 0) {
                cannot(CLib.CharPtr.toCharPtr("write"));
            }
            if (CLib.fclose(D) != 0) {
                cannot(CLib.CharPtr.toCharPtr("close"));
            }
        }
        return 0;
    }

    static int MainLuac(List<String> args)
    {
        List<String> newargs = new List<String>((((args != null) ? args.length : 0) + 1));
        newargs[0] = "luac";
        for (int idx = 0; idx < args.length; idx++) {
            newargs[idx + 1] = args[idx];
        }
        args = newargs;
        LuaState.lua_State L;
        SmainLuac s = new SmainLuac();
        int argc = args.length;
        int i = doargs(argc, args);
        List<String> newargs2 = new List<String>((newargs.length - i));
        for (int idx = (newargs.length - i); idx < newargs.length; idx++) {
            newargs2[idx - (newargs.length - i)] = newargs[idx];
        }
        argc -= i;
        args = newargs2;
        if (argc <= 0) {
            usage(CLib.CharPtr.toCharPtr("no input files given"));
        }
        L = Lua.lua_open();
        if (L == null) {
            fatal(CLib.CharPtr.toCharPtr("not enough memory for state"));
        }
        s.argc = argc;
        s.argv = args;
        if (LuaAPI.lua_cpcall(L, new pmain_delegate(), s) != 0) {
            fatal(Lua.lua_tostring(L, -1));
        }
        LuaState.lua_close(L);
        return CLib.EXIT_SUCCESS;
    }
}

class writer_delegate with Lua_lua_Writer
{

    final int exec(LuaState.lua_State L, CLib.CharPtr p, int sz, Object ud)
    {
        return writer(L, p, sz, ud);
    }
}

class SmainLuac
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
