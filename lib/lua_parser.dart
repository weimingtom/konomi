library kurumi;

class LuaParser
{

    static int expkindToInt(LuaParser.expkind exp)
    {
        switch (exp) {
            case VVOID:
                return 0;
            case VNIL:
                return 1;
            case VTRUE:
                return 2;
            case VFALSE:
                return 3;
            case VK:
                return 4;
            case VKNUM:
                return 5;
            case VLOCAL:
                return 6;
            case VUPVAL:
                return 7;
            case VGLOBAL:
                return 8;
            case VINDEXED:
                return 9;
            case VJMP:
                return 10;
            case VRELOCABLE:
                return 11;
            case VNONRELOC:
                return 12;
            case VCALL:
                return 13;
            case VVARARG:
                return 14;
        }
        throw new RuntimeException("expkindToInt error");
    }

    static int hasmultret(expkind k)
    {
        return ((k == expkind_.VCALL) || (k == expkind_.VVARARG)) ? 1 : 0;
    }

    static LuaObject.LocVar getlocvar(FuncState fs, int i)
    {
        return fs.f.locvars[fs.actvar[i]];
    }

    static void luaY_checklimit(FuncState fs, int v, int l, CLib.CharPtr m)
    {
        if (v > l) {
            errorlimit(fs, l, m);
        }
    }

    static void anchor_token(LuaLex.LexState ls)
    {
        if ((ls.t.token == LuaLex.RESERVED.TK_NAME) || (ls.t.token == LuaLex.RESERVED.TK_STRING)) {
            LuaObject.TString ts = ls.t.seminfo.ts;
            LuaLex.luaX_newstring(ls, LuaObject.getstr(ts), ts.getTsv().len);
        }
    }

    static void error_expected(LuaLex.LexState ls, int token)
    {
        LuaLex.luaX_syntaxerror(ls, LuaObject.luaO_pushfstring(ls.L, CLib.CharPtr.toCharPtr(LuaConf.getLUA_QS() + " expected"), LuaLex.luaX_token2str(ls, token)));
    }

    static void errorlimit(FuncState fs, int limit, CLib.CharPtr what)
    {
        CLib.CharPtr msg = (fs.f.linedefined == 0) ? LuaObject.luaO_pushfstring(fs.L, CLib.CharPtr.toCharPtr("main function has more than %d %s"), limit, what) : LuaObject.luaO_pushfstring(fs.L, CLib.CharPtr.toCharPtr("function at line %d has more than %d %s"), fs.f.linedefined, limit, what);
        LuaLex.luaX_lexerror(fs.ls, msg, 0);
    }

    static int testnext(LuaLex.LexState ls, int c)
    {
        if (ls.t.token == c) {
            LuaLex.luaX_next(ls);
            return 1;
        } else {
            return 0;
        }
    }

    static void check(LuaLex.LexState ls, int c)
    {
        if (ls.t.token != c) {
            error_expected(ls, c);
        }
    }

    static void checknext(LuaLex.LexState ls, int c)
    {
        check(ls, c);
        LuaLex.luaX_next(ls);
    }

    static void check_condition(LuaLex.LexState ls, bool c, CLib.CharPtr msg)
    {
        if (!c) {
            LuaLex.luaX_syntaxerror(ls, msg);
        }
    }

    static void check_match(LuaLex.LexState ls, int what, int who, int where)
    {
        if (testnext(ls, what) == 0) {
            if (where == ls.linenumber) {
                error_expected(ls, what);
            } else {
                LuaLex.luaX_syntaxerror(ls, LuaObject.luaO_pushfstring(ls.L, CLib.CharPtr.toCharPtr(((LuaConf.getLUA_QS() + " expected (to close ") + LuaConf.getLUA_QS()) + " at line %d)"), LuaLex.luaX_token2str(ls, what), LuaLex.luaX_token2str(ls, who), where));
            }
        }
    }

    static LuaObject.TString str_checkname(LuaLex.LexState ls)
    {
        LuaObject.TString ts;
        check(ls, LuaLex.RESERVED.TK_NAME);
        ts = ls.t.seminfo.ts;
        LuaLex.luaX_next(ls);
        return ts;
    }

    static void init_exp(expdesc e, expkind k, int i)
    {
        e.f = (e.t = LuaCode.NO_JUMP);
        e.k = k;
        e.u.s.info = i;
    }

    static void codestring(LuaLex.LexState ls, expdesc e, LuaObject.TString s)
    {
        init_exp(e, expkind_.VK, LuaCode.luaK_stringK(ls.fs, s));
    }

    static void checkname(LuaLex.LexState ls, expdesc e)
    {
        codestring(ls, e, str_checkname(ls));
    }

    static int registerlocalvar(LuaLex.LexState ls, LuaObject.TString varname)
    {
        FuncState fs = ls.fs;
        LuaObject.Proto f = fs.f;
        int oldsize = f.sizelocvars;
        LuaObject.LocVar[][] locvars_ref = new LuaObject.LocVar[1][];
        locvars_ref[0] = f.locvars;
        List<int> sizelocvars_ref = new List<int>(1);
        sizelocvars_ref[0] = f.sizelocvars;
        LuaMem.luaM_growvector_LocVar(ls.L, locvars_ref, fs.nlocvars, sizelocvars_ref, CLib.SHRT_MAX, CLib.CharPtr.toCharPtr("too many local variables"), new ClassType(ClassType_.TYPE_LOCVAR));
        f.sizelocvars = sizelocvars_ref[0];
        f.locvars = locvars_ref[0];
        while (oldsize < f.sizelocvars) {
            f.locvars[oldsize++].varname = null;
        }
        f.locvars[fs.nlocvars].varname = varname;
        LuaGC.luaC_objbarrier(ls.L, f, varname);
        return fs.nlocvars++;
    }

    static void new_localvarliteral(LuaLex.LexState ls, CLib.CharPtr v, int n)
    {
        new_localvar(ls, LuaLex.luaX_newstring(ls, CLib.CharPtr.toCharPtr("" + v), v.chars.length - 1), n);
    }

    static void new_localvar(LuaLex.LexState ls, LuaObject.TString name, int n)
    {
        FuncState fs = ls.fs;
        luaY_checklimit(fs, (fs.nactvar + n) + 1, LuaConf.LUAI_MAXVARS, CLib.CharPtr.toCharPtr("local variables"));
        fs.actvar[fs.nactvar + n] = registerlocalvar(ls, name);
    }

    static void adjustlocalvars(LuaLex.LexState ls, int nvars)
    {
        FuncState fs = ls.fs;
        fs.nactvar = LuaLimits.cast_byte(fs.nactvar + nvars);
        for (; nvars != 0; nvars--) {
            getlocvar(fs, fs.nactvar - nvars).startpc = fs.pc;
        }
    }

    static void removevars(LuaLex.LexState ls, int tolevel)
    {
        FuncState fs = ls.fs;
        while (fs.nactvar > tolevel) {
            getlocvar(fs, --fs.nactvar).endpc = fs.pc;
        }
    }

    static int indexupvalue(FuncState fs, LuaObject.TString name, expdesc v)
    {
        int i;
        LuaObject.Proto f = fs.f;
        int oldsize = f.sizeupvalues;
        for ((i = 0); i < f.nups; i++) {
            if ((fs.upvalues[i].k == expkindToInt(v.k)) && (fs.upvalues[i].info == v.u.s.info)) {
                LuaLimits.lua_assert(f.upvalues[i] == name);
                return i;
            }
        }
        luaY_checklimit(fs, f.nups + 1, LuaConf.LUAI_MAXUPVALUES, CLib.CharPtr.toCharPtr("upvalues"));
        LuaObject.TString[][] upvalues_ref = new LuaObject.TString[1][];
        upvalues_ref[0] = f.upvalues;
        List<int> sizeupvalues_ref = new List<int>(1);
        sizeupvalues_ref[0] = f.sizeupvalues;
        LuaMem.luaM_growvector_TString(fs.L, upvalues_ref, f.nups, sizeupvalues_ref, LuaLimits.MAX_INT, CLib.CharPtr.toCharPtr(""), new ClassType(ClassType_.TYPE_TSTRING));
        f.sizeupvalues = sizeupvalues_ref[0];
        f.upvalues = upvalues_ref[0];
        while (oldsize < f.sizeupvalues) {
            f.upvalues[oldsize++] = null;
        }
        f.upvalues[f.nups] = name;
        LuaGC.luaC_objbarrier(fs.L, f, name);
        LuaLimits.lua_assert((v.k == expkind_.VLOCAL) || (v.k == expkind_.VUPVAL));
        fs.upvalues[f.nups].k = LuaLimits.cast_byte(expkindToInt(v.k));
        fs.upvalues[f.nups].info = LuaLimits.cast_byte(v.u.s.info);
        return f.nups++;
    }

    static int searchvar(FuncState fs, LuaObject.TString n)
    {
        int i;
        for ((i = (fs.nactvar - 1)); i >= 0; i--) {
            if (n == getlocvar(fs, i).varname) {
                return i;
            }
        }
        return -1;
    }

    static void markupval(FuncState fs, int level)
    {
        BlockCnt bl = fs.bl;
        while ((bl != null) && (bl.nactvar > level)) {
            bl = bl.previous;
        }
        if (bl != null) {
            bl.upval = 1;
        }
    }

    static expkind singlevaraux(FuncState fs, LuaObject.TString n, expdesc var, int base_)
    {
        if (fs == null) {
            init_exp(var, expkind_.VGLOBAL, LuaOpCodes.NO_REG);
            return expkind_.VGLOBAL;
        } else {
            int v = searchvar(fs, n);
            if (v >= 0) {
                init_exp(var, expkind_.VLOCAL, v);
                if (base_ == 0) {
                    markupval(fs, v);
                }
                return expkind_.VLOCAL;
            } else {
                if (singlevaraux(fs.prev, n, var, 0) == expkind_.VGLOBAL) {
                    return expkind_.VGLOBAL;
                }
                var.u.s.info = indexupvalue(fs, n, var);
                var.k = expkind_.VUPVAL;
                return expkind_.VUPVAL;
            }
        }
    }

    static void singlevar(LuaLex.LexState ls, expdesc var)
    {
        LuaObject.TString varname = str_checkname(ls);
        FuncState fs = ls.fs;
        if (singlevaraux(fs, varname, var, 1) == expkind_.VGLOBAL) {
            var.u.s.info = LuaCode.luaK_stringK(fs, varname);
        }
    }

    static void adjust_assign(LuaLex.LexState ls, int nvars, int nexps, expdesc e)
    {
        FuncState fs = ls.fs;
        int extra = (nvars - nexps);
        if (hasmultret(e.k) != 0) {
            extra++;
            if (extra < 0) {
                extra = 0;
            }
            LuaCode.luaK_setreturns(fs, e, extra);
            if (extra > 1) {
                LuaCode.luaK_reserveregs(fs, extra - 1);
            }
        } else {
            if (e.k != expkind_.VVOID) {
                LuaCode.luaK_exp2nextreg(fs, e);
            }
            if (extra > 0) {
                int reg = fs.freereg;
                LuaCode.luaK_reserveregs(fs, extra);
                LuaCode.luaK_nil(fs, reg, extra);
            }
        }
    }

    static void enterlevel(LuaLex.LexState ls)
    {
        if ((++ls.L.nCcalls) > LuaConf.LUAI_MAXCCALLS) {
            LuaLex.luaX_lexerror(ls, CLib.CharPtr.toCharPtr("chunk has too many syntax levels"), 0);
        }
    }

    static void leavelevel(LuaLex.LexState ls)
    {
        ls.L.nCcalls--;
    }

    static void enterblock(FuncState fs, BlockCnt bl, int isbreakable)
    {
        bl.breaklist = LuaCode.NO_JUMP;
        bl.isbreakable = isbreakable;
        bl.nactvar = fs.nactvar;
        bl.upval = 0;
        bl.previous = fs.bl;
        fs.bl = bl;
        LuaLimits.lua_assert(fs.freereg == fs.nactvar);
    }

    static void leaveblock(FuncState fs)
    {
        BlockCnt bl = fs.bl;
        fs.bl = bl.previous;
        removevars(fs.ls, bl.nactvar);
        if (bl.upval != 0) {
            LuaCode.luaK_codeABC(fs, LuaOpCodes.OpCode.OP_CLOSE, bl.nactvar, 0, 0);
        }
        LuaLimits.lua_assert((bl.isbreakable == 0) || (bl.upval == 0));
        LuaLimits.lua_assert(bl.nactvar == fs.nactvar);
        fs.freereg = fs.nactvar;
        LuaCode.luaK_patchtohere(fs, bl.breaklist);
    }

    static void pushclosure(LuaLex.LexState ls, FuncState func, expdesc v)
    {
        FuncState fs = ls.fs;
        LuaObject.Proto f = fs.f;
        int oldsize = f.sizep;
        int i;
        LuaObject.Proto[][] p_ref = new LuaObject.Proto[1][];
        p_ref[0] = f.p;
        List<int> sizep_ref = new List<int>(1);
        sizep_ref[0] = f.sizep;
        LuaMem.luaM_growvector_Proto(ls.L, p_ref, fs.np, sizep_ref, LuaOpCodes.MAXARG_Bx, CLib.CharPtr.toCharPtr("constant table overflow"), new ClassType(ClassType_.TYPE_PROTO));
        f.sizep = sizep_ref[0];
        f.p = p_ref[0];
        while (oldsize < f.sizep) {
            f.p[oldsize++] = null;
        }
        f.p[fs.np++] = func.f;
        LuaGC.luaC_objbarrier(ls.L, f, func.f);
        init_exp(v, expkind_.VRELOCABLE, LuaCode.luaK_codeABx(fs, LuaOpCodes.OpCode.OP_CLOSURE, 0, fs.np - 1));
        for ((i = 0); i < func.f.nups; i++) {
            LuaOpCodes.OpCode o = ((int)func.upvalues[i].k == expkind.VLOCAL.getValue()) ? LuaOpCodes.OpCode.OP_MOVE : LuaOpCodes.OpCode.OP_GETUPVAL;
            LuaCode.luaK_codeABC(fs, o, 0, func.upvalues[i].info, 0);
        }
    }

    static void open_func(LuaLex.LexState ls, FuncState fs)
    {
        LuaState.lua_State L = ls.L;
		    LuaObject.Proto f = LuaFunc.luaF_newproto(L);
        fs.f = f;
        fs.prev = ls.fs;
        fs.ls = ls;
        fs.L = L;
        ls.fs = fs;
        fs.pc = 0;
        fs.lasttarget = (-1);
        fs.jpc = LuaCode.NO_JUMP;
        fs.freereg = 0;
        fs.nk = 0;
        fs.np = 0;
        fs.nlocvars = 0;
        fs.nactvar = 0;
        fs.bl = null;
        f.source = ls.source;
        f.maxstacksize = 2;
        fs.h = LuaTable.luaH_new(L, 0, 0);
        LuaObject.sethvalue2s(L, L.top, fs.h);
        LuaDo.incr_top(L);
        LuaObject.setptvalue2s(L, L.top, f);
        LuaDo.incr_top(L);
    }
    static LuaObject.Proto lastfunc;

    static void close_func(LuaLex.LexState ls)
    {
        LuaState.lua_State L = ls.L;
        FuncState fs = ls.fs;
        LuaObject.Proto f = fs.f;
        lastfunc = f;
        removevars(ls, 0);
        LuaCode.luaK_ret(fs, 0, 0);
        long[][] code_ref = new long[1][];
        code_ref[0] = f.code;
        LuaMem.luaM_reallocvector_long(L, code_ref, f.sizecode, fs.pc, new ClassType(ClassType_.TYPE_LONG));
        f.code = code_ref[0];
        f.sizecode = fs.pc;
        int[][] lineinfo_ref = new int[1][];
        lineinfo_ref[0] = f.lineinfo;
        LuaMem.luaM_reallocvector_int(L, lineinfo_ref, f.sizelineinfo, fs.pc, new ClassType(ClassType_.TYPE_INT));
        f.lineinfo = lineinfo_ref[0];
        f.sizelineinfo = fs.pc;
        LuaObject.TValue[][] k_ref = new LuaObject.TValue[1][];
        k_ref[0] = f.k;
        LuaMem.luaM_reallocvector_TValue(L, k_ref, f.sizek, fs.nk, new ClassType(ClassType_.TYPE_TVALUE));
        f.k = k_ref[0];
        f.sizek = fs.nk;
        LuaObject.Proto[][] p_ref = new LuaObject.Proto[1][];
        p_ref[0] = f.p;
        LuaMem.luaM_reallocvector_Proto(L, p_ref, f.sizep, fs.np, new ClassType(ClassType_.TYPE_PROTO));
        f.p = p_ref[0];
        f.sizep = fs.np;
        for (int i = 0; i < f.p.length; i++) {
            f.p[i].protos = f.p;
            f.p[i].index = i;
        }
        LuaObject.LocVar[][] locvars_ref = new LuaObject.LocVar[1][];
        locvars_ref[0] = f.locvars;
        LuaMem.luaM_reallocvector_LocVar(L, locvars_ref, f.sizelocvars, fs.nlocvars, new ClassType(ClassType_.TYPE_LOCVAR));
        f.locvars = locvars_ref[0];
        f.sizelocvars = fs.nlocvars;
        LuaObject.TString[][] upvalues_ref = new LuaObject.TString[1][];
        upvalues_ref[0] = f.upvalues;
        LuaMem.luaM_reallocvector_TString(L, upvalues_ref, f.sizeupvalues, f.nups, new ClassType(ClassType_.TYPE_TSTRING));
        f.upvalues = upvalues_ref[0];
        f.sizeupvalues = f.nups;
        LuaLimits.lua_assert(LuaDebug.luaG_checkcode(f));
        LuaLimits.lua_assert(fs.bl == null);
        ls.fs = fs.prev;
        L.top = LuaObject.TValue.minus(L.top, 2);
        if (fs != null) {
            anchor_token(ls);
        }
    }

    static LuaObject.Proto luaY_parser(LuaState.lua_State L, LuaZIO.ZIO z, LuaZIO.Mbuffer buff, CLib.CharPtr name)
    {
        LuaLex.LexState lexstate = new LuaLex.LexState();
        FuncState funcstate = new FuncState();
        lexstate.buff = buff;
        LuaLex.luaX_setinput(L, lexstate, z, LuaString.luaS_new(L, name));
        open_func(lexstate, funcstate);
        funcstate.f.is_vararg = LuaObject.VARARG_ISVARARG;
        LuaLex.luaX_next(lexstate);
        chunk(lexstate);
        check(lexstate, LuaLex.RESERVED.TK_EOS);
        close_func(lexstate);
        LuaLimits.lua_assert(funcstate.prev == null);
        LuaLimits.lua_assert(funcstate.f.nups == 0);
        LuaLimits.lua_assert(lexstate.fs == null);
        return funcstate.f;
    }

    static void field(LuaLex.LexState ls, expdesc v)
    {
        FuncState fs = ls.fs;
        expdesc key = new expdesc();
        LuaCode.luaK_exp2anyreg(fs, v);
        LuaLex.luaX_next(ls);
        checkname(ls, key);
        LuaCode.luaK_indexed(fs, v, key);
    }

    static void yindex(LuaLex.LexState ls, expdesc v)
    {
        LuaLex.luaX_next(ls);
        expr(ls, v);
        LuaCode.luaK_exp2val(ls.fs, v);
        checknext(ls, ']'.codeUnitAt(0));
    }

    static void recfield(LuaLex.LexState ls, ConsControl cc)
    {
        FuncState fs = ls.fs;
        int reg = ls.fs.freereg;
        expdesc key = new expdesc();
        expdesc val = new expdesc();
        int rkkey;
        if (ls.t.token == LuaLex.RESERVED.TK_NAME) {
            luaY_checklimit(fs, cc.nh, LuaLimits.MAX_INT, CLib.CharPtr.toCharPtr("items in a constructor"));
            checkname(ls, key);
        } else {
            yindex(ls, key);
        }
        cc.nh++;
        checknext(ls, '='.codeUnitAt(0));
        rkkey = LuaCode.luaK_exp2RK(fs, key);
        expr(ls, val);
        LuaCode.luaK_codeABC(fs, LuaOpCodes.OpCode.OP_SETTABLE, cc.t.u.s.info, rkkey, LuaCode.luaK_exp2RK(fs, val));
        fs.freereg = reg;
    }

    static void closelistfield(FuncState fs, ConsControl cc)
    {
        if (cc.v.k == expkind_.VVOID) {
            return;
        }
        LuaCode.luaK_exp2nextreg(fs, cc.v);
        cc.v.k = expkind_.VVOID;
        if (cc.tostore == LuaOpCodes.LFIELDS_PER_FLUSH) {
            LuaCode.luaK_setlist(fs, cc.t.u.s.info, cc.na, cc.tostore);
            cc.tostore = 0;
        }
    }

    static void lastlistfield(FuncState fs, ConsControl cc)
    {
        if (cc.tostore == 0) {
            return;
        }
        if (hasmultret(cc.v.k) != 0) {
            LuaCode.luaK_setmultret(fs, cc.v);
            LuaCode.luaK_setlist(fs, cc.t.u.s.info, cc.na, Lua.LUA_MULTRET);
            cc.na--;
        } else {
            if (cc.v.k != expkind_.VVOID) {
                LuaCode.luaK_exp2nextreg(fs, cc.v);
            }
            LuaCode.luaK_setlist(fs, cc.t.u.s.info, cc.na, cc.tostore);
        }
    }

    static void listfield(LuaLex.LexState ls, ConsControl cc)
    {
        expr(ls, cc.v);
        luaY_checklimit(ls.fs, cc.na, LuaLimits.MAX_INT, CLib.CharPtr.toCharPtr("items in a constructor"));
        cc.na++;
        cc.tostore++;
    }

    static void constructor(LuaLex.LexState ls, expdesc t)
    {
        FuncState fs = ls.fs;
        int line = ls.linenumber;
        int pc = LuaCode.luaK_codeABC(fs, LuaOpCodes.OpCode.OP_NEWTABLE, 0, 0, 0);
        ConsControl cc = new ConsControl();
        cc.na = (cc.nh = (cc.tostore = 0));
        cc.t = t;
        init_exp(t, expkind_.VRELOCABLE, pc);
        init_exp(cc.v, expkind_.VVOID, 0);
        LuaCode.luaK_exp2nextreg(ls.fs, t);
        checknext(ls, '{'.codeUnitAt(0));
        do {
            LuaLimits.lua_assert((cc.v.k == expkind_.VVOID) || (cc.tostore > 0));
            if (ls.t.token == '}'.codeUnitAt(0)) {
                break;
            }
            closelistfield(fs, cc);
            switch (ls.t.token) {
                case LuaLex.RESERVED.TK_NAME:
                    LuaLex.luaX_lookahead(ls);
                    if (ls.lookahead.token != '='.codeUnitAt(0)) {
                        listfield(ls, cc);
                    } else {
                        recfield(ls, cc);
                    }
                    break;
                case '['.codeUnitAt(0):
                    recfield(ls, cc);
                    break;
                default:
                    listfield(ls, cc);
                    break;
            }
        } while ((testnext(ls, ','.codeUnitAt(0)) != 0) || (testnext(ls, ';'.codeUnitAt(0)) != 0));
        check_match(ls, '}'.codeUnitAt(0), '{'.codeUnitAt(0), line);
        lastlistfield(fs, cc);
        LuaOpCodes.SETARG_B(new LuaCode.InstructionPtr(fs.f.code, pc), LuaObject.luaO_int2fb(cc.na));
        LuaOpCodes.SETARG_C(new LuaCode.InstructionPtr(fs.f.code, pc), LuaObject.luaO_int2fb(cc.nh));
    }

    static void parlist(LuaLex.LexState ls)
    {
        FuncState fs = ls.fs;
        LuaObject.Proto f = fs.f;
        int nparams = 0;
        f.is_vararg = 0;
        if (ls.t.token != ')'.codeUnitAt(0)) {
            do {
                switch (ls.t.token) {
                    case LuaLex.RESERVED.TK_NAME:
                        new_localvar(ls, str_checkname(ls), nparams++);
                        break;
                    case LuaLex.RESERVED.TK_DOTS:
                        LuaLex.luaX_next(ls);
                        new_localvarliteral(ls, CLib.CharPtr.toCharPtr("arg"), nparams++);
                        f.is_vararg = (LuaObject.VARARG_HASARG | LuaObject.VARARG_NEEDSARG);
                        f.is_vararg |= LuaObject.VARARG_ISVARARG;
                        break;
                    default:
                        LuaLex.luaX_syntaxerror(ls, CLib.CharPtr.toCharPtr(("<name> or " + LuaConf.LUA_QL("...")) + " expected"));
                        break;
                }
            } while ((f.is_vararg == 0) && (testnext(ls, ','.codeUnitAt(0)) != 0));
        }
        adjustlocalvars(ls, nparams);
        f.numparams = LuaLimits.cast_byte(fs.nactvar - (f.is_vararg & LuaObject.VARARG_HASARG));
        LuaCode.luaK_reserveregs(fs, fs.nactvar);
    }

    static void body(LuaLex.LexState ls, expdesc e, int needself, int line)
    {
        FuncState new_fs = new FuncState();
        open_func(ls, new_fs);
        new_fs.f.linedefined = line;
        checknext(ls, '('.codeUnitAt(0));
        if (needself != 0) {
            new_localvarliteral(ls, CLib.CharPtr.toCharPtr("self"), 0);
            adjustlocalvars(ls, 1);
        }
        parlist(ls);
        checknext(ls, ')'.codeUnitAt(0));
        chunk(ls);
        new_fs.f.lastlinedefined = ls.linenumber;
        check_match(ls, LuaLex.RESERVED.TK_END, LuaLex.RESERVED.TK_FUNCTION, line);
        close_func(ls);
        pushclosure(ls, new_fs, e);
    }

    static int explist1(LuaLex.LexState ls, expdesc v)
    {
        int n = 1;
        expr(ls, v);
        while (testnext(ls, ','.codeUnitAt(0)) != 0) {
            LuaCode.luaK_exp2nextreg(ls.fs, v);
            expr(ls, v);
            n++;
        }
        return n;
    }

    static void funcargs(LuaLex.LexState ls, expdesc f)
    {
        FuncState fs = ls.fs;
        expdesc args = new expdesc();
        int base_;
        int nparams;
        int line = ls.linenumber;
        switch (ls.t.token) {
            case '('.codeUnitAt(0):
                if (line != ls.lastline) {
                    LuaLex.luaX_syntaxerror(ls, CLib.CharPtr.toCharPtr("ambiguous syntax (function call x new statement)"));
                }
                LuaLex.luaX_next(ls);
                if (ls.t.token == ')'.codeUnitAt(0)) {
                    args.k = expkind_.VVOID;
                } else {
                    explist1(ls, args);
                    LuaCode.luaK_setmultret(fs, args);
                }
                check_match(ls, ')'.codeUnitAt(0), '('.codeUnitAt(0), line);
                break;
            case '{'.codeUnitAt(0):
                constructor(ls, args);
                break;
            case LuaLex.RESERVED.TK_STRING:
                codestring(ls, args, ls.t.seminfo.ts);
                LuaLex.luaX_next(ls);
                break;
            default:
                LuaLex.luaX_syntaxerror(ls, CLib.CharPtr.toCharPtr("function arguments expected"));
                return;
        }
        LuaLimits.lua_assert(f.k == expkind_.VNONRELOC);
        base_ = f.u.s.info;
        if (hasmultret(args.k) != 0) {
            nparams = Lua.LUA_MULTRET;
        } else {
            if (args.k != expkind_.VVOID) {
                LuaCode.luaK_exp2nextreg(fs, args);
            }
            nparams = (fs.freereg - (base_ + 1));
        }
        init_exp(f, expkind_.VCALL, LuaCode.luaK_codeABC(fs, LuaOpCodes.OpCode.OP_CALL, base_, nparams + 1, 2));
        LuaCode.luaK_fixline(fs, line);
        fs.freereg = (base_ + 1);
    }

    static void prefixexp(LuaLex.LexState ls, expdesc v)
    {
        switch (ls.t.token) {
            case '('.codeUnitAt(0):
                int line = ls.linenumber;
                LuaLex.luaX_next(ls);
                expr(ls, v);
                check_match(ls, ')'.codeUnitAt(0), '('.codeUnitAt(0), line);
                LuaCode.luaK_dischargevars(ls.fs, v);
                return;
            case LuaLex.RESERVED.TK_NAME:
                singlevar(ls, v);
                return;
            default:
                LuaLex.luaX_syntaxerror(ls, CLib.CharPtr.toCharPtr("unexpected symbol"));
                return;
        }
    }

    static void primaryexp(LuaLex.LexState ls, expdesc v)
    {
        FuncState fs = ls.fs;
        prefixexp(ls, v);
        for (; ; ) {
            switch (ls.t.token) {
                case '.'.codeUnitAt(0):
                    field(ls, v);
                    break;
                case '['.codeUnitAt(0):
                    expdesc key = new expdesc();
                    LuaCode.luaK_exp2anyreg(fs, v);
                    yindex(ls, key);
                    LuaCode.luaK_indexed(fs, v, key);
                    break;
                case ':'.codeUnitAt(0):
                    expdesc key = new expdesc();
                    LuaLex.luaX_next(ls);
                    checkname(ls, key);
                    LuaCode.luaK_self(fs, v, key);
                    funcargs(ls, v);
                    break;
                case '('.codeUnitAt(0):
                case LuaLex.RESERVED.TK_STRING:
                case '{'.codeUnitAt(0):
                    LuaCode.luaK_exp2nextreg(fs, v);
                    funcargs(ls, v);
                    break;
                default:
                    return;
            }
        }
    }

    static void simpleexp(LuaLex.LexState ls, expdesc v)
    {
        switch (ls.t.token) {
            case LuaLex.RESERVED.TK_NUMBER:
                init_exp(v, expkind_.VKNUM, 0);
                v.u.nval = ls.t.seminfo.r;
                break;
            case LuaLex.RESERVED.TK_STRING:
                codestring(ls, v, ls.t.seminfo.ts);
                break;
            case LuaLex.RESERVED.TK_NIL:
                init_exp(v, expkind_.VNIL, 0);
                break;
            case LuaLex.RESERVED.TK_TRUE:
                init_exp(v, expkind_.VTRUE, 0);
                break;
            case LuaLex.RESERVED.TK_FALSE:
                init_exp(v, expkind_.VFALSE, 0);
                break;
            case LuaLex.RESERVED.TK_DOTS:
                FuncState fs = ls.fs;
                check_condition(ls, fs.f.is_vararg != 0, CLib.CharPtr.toCharPtr(("cannot use " + LuaConf.LUA_QL("...")) + " outside a vararg function"));
                fs.f.is_vararg &= ((~LuaObject.VARARG_NEEDSARG) & 15);
                init_exp(v, expkind_.VVARARG, LuaCode.luaK_codeABC(fs, LuaOpCodes.OpCode.OP_VARARG, 0, 1, 0));
                break;
            case '{'.codeUnitAt(0):
                constructor(ls, v);
                return;
            case LuaLex.RESERVED.TK_FUNCTION:
                LuaLex.luaX_next(ls);
                body(ls, v, 0, ls.linenumber);
                return;
            default:
                primaryexp(ls, v);
                return;
        }
        LuaLex.luaX_next(ls);
    }

    static LuaCode.UnOpr getunopr(int op)
    {
        switch (op) {
            case LuaLex.RESERVED.TK_NOT:
                return LuaCode.UnOpr.OPR_NOT;
            case '-'.codeUnitAt(0):
                return LuaCode.UnOpr.OPR_MINUS;
            case '#'.codeUnitAt(0):
                return LuaCode.UnOpr.OPR_LEN;
            default:
                return LuaCode.UnOpr.OPR_NOUNOPR;
        }
    }

    static LuaCode.BinOpr getbinopr(int op)
    {
        switch (op) {
            case '+'.codeUnitAt(0):
                return LuaCode.BinOpr.OPR_ADD;
            case '-'.codeUnitAt(0):
                return LuaCode.BinOpr.OPR_SUB;
            case '*'.codeUnitAt(0):
                return LuaCode.BinOpr.OPR_MUL;
            case '/'.codeUnitAt(0):
                return LuaCode.BinOpr.OPR_DIV;
            case '%'.codeUnitAt(0):
                return LuaCode.BinOpr.OPR_MOD;
            case '^'.codeUnitAt(0):
                return LuaCode.BinOpr.OPR_POW;
            case LuaLex.RESERVED.TK_CONCAT:
                return LuaCode.BinOpr.OPR_CONCAT;
            case LuaLex.RESERVED.TK_NE:
                return LuaCode.BinOpr.OPR_NE;
            case LuaLex.RESERVED.TK_EQ:
                return LuaCode.BinOpr.OPR_EQ;
            case '<'.codeUnitAt(0):
                return LuaCode.BinOpr.OPR_LT;
            case LuaLex.RESERVED.TK_LE:
                return LuaCode.BinOpr.OPR_LE;
            case '>'.codeUnitAt(0):
                return LuaCode.BinOpr.OPR_GT;
            case LuaLex.RESERVED.TK_GE:
                return LuaCode.BinOpr.OPR_GE;
            case LuaLex.RESERVED.TK_AND:
                return LuaCode.BinOpr.OPR_AND;
            case LuaLex.RESERVED.TK_OR:
                return LuaCode.BinOpr.OPR_OR;
            default:
                return LuaCode.BinOpr.OPR_NOBINOPR;
        }
    }
    static List<priority_> priority = [new priority_(6, 6), new priority_(6, 6), new priority_(7, 7), new priority_(7, 7), new priority_(7, 7), new priority_(10, 9), new priority_(5, 4), new priority_(3, 3), new priority_(3, 3), new priority_(3, 3), new priority_(3, 3), new priority_(3, 3), new priority_(3, 3), new priority_(2, 2), new priority_(1, 1)];
    static const int UNARY_PRIORITY = 8;

    static LuaCode.BinOpr subexpr(LuaLex.LexState ls, expdesc v, int limit)
    {
        LuaCode.BinOpr op; // = new BinOpr();
		    LuaCode.UnOpr uop; // = new UnOpr();
        enterlevel(ls);
        uop = getunopr(ls.t.token);
        if (uop != LuaCode.UnOpr.OPR_NOUNOPR) {
            LuaLex.luaX_next(ls);
            subexpr(ls, v, UNARY_PRIORITY);
            LuaCode.luaK_prefix(ls.fs, uop, v);
        } else {
            simpleexp(ls, v);
        }
        op = getbinopr(ls.t.token);
        while ((op != LuaCode.BinOpr.OPR_NOBINOPR) && (priority[op.getValue()].left > limit)) {
            expdesc v2 = new expdesc();
            LuaCode.BinOpr nextop;
            LuaLex.luaX_next(ls);
            LuaCode.luaK_infix(ls.fs, op, v);
            nextop = subexpr(ls, v2, priority[op.getValue()].right);
            LuaCode.luaK_posfix(ls.fs, op, v, v2);
            op = nextop;
        }
        leavelevel(ls);
        return op;
    }

    static void expr(LuaLex.LexState ls, expdesc v)
    {
        subexpr(ls, v, 0);
    }

    static int block_follow(int token)
    {
        switch (token) {
            case LuaLex.RESERVED.TK_ELSE:
            case LuaLex.RESERVED.TK_ELSEIF:
            case LuaLex.RESERVED.TK_END:
            case LuaLex.RESERVED.TK_UNTIL:
            case LuaLex.RESERVED.TK_EOS:
                return 1;
            default:
                return 0;
        }
    }

    static void block(LuaLex.LexState ls)
    {
        FuncState fs = ls.fs;
        BlockCnt bl = new BlockCnt();
        enterblock(fs, bl, 0);
        chunk(ls);
        LuaLimits.lua_assert(bl.breaklist == LuaCode.NO_JUMP);
        leaveblock(fs);
    }

    static void check_conflict(LuaLex.LexState ls, LHS_assign lh, expdesc v)
    {
        FuncState fs = ls.fs;
        int extra = fs.freereg;
        int conflict = 0;
        for (; lh != null; (lh = lh.prev)) {
            if (lh.v.k == expkind_.VINDEXED) {
                if (lh.v.u.s.info == v.u.s.info) {
                    conflict = 1;
                    lh.v.u.s.info = extra;
                }
                if (lh.v.u.s.aux == v.u.s.info) {
                    conflict = 1;
                    lh.v.u.s.aux = extra;
                }
            }
        }
        if (conflict != 0) {
            LuaCode.luaK_codeABC(fs, LuaOpCodes.OpCode.OP_MOVE, fs.freereg, v.u.s.info, 0);
            LuaCode.luaK_reserveregs(fs, 1);
        }
    }

    static void assignment(LuaLex.LexState ls, LHS_assign lh, int nvars)
    {
        expdesc e = new expdesc();
        check_condition(ls, (expkindToInt(expkind_.VLOCAL) <= expkindToInt(lh.v.k)) && (expkindToInt(lh.v.k) <= expkindToInt(expkind_.VINDEXED)), CLib.CharPtr.toCharPtr("syntax error"));
        if (testnext(ls, ','.codeUnitAt(0)) != 0) {
            LHS_assign nv = new LHS_assign();
            nv.prev = lh;
            primaryexp(ls, nv.v);
            if (nv.v.k == expkind_.VLOCAL) {
                check_conflict(ls, lh, nv.v);
            }
            luaY_checklimit(ls.fs, nvars, LuaConf.LUAI_MAXCCALLS - ls.L.nCcalls, CLib.CharPtr.toCharPtr("variables in assignment"));
            assignment(ls, nv, nvars + 1);
        } else {
            int nexps;
            checknext(ls, '='.codeUnitAt(0));
            nexps = explist1(ls, e);
            if (nexps != nvars) {
                adjust_assign(ls, nvars, nexps, e);
                if (nexps > nvars) {
                    ls.fs.freereg -= (nexps - nvars);
                }
            } else {
                LuaCode.luaK_setoneret(ls.fs, e);
                LuaCode.luaK_storevar(ls.fs, lh.v, e);
                return;
            }
        }
        init_exp(e, expkind_.VNONRELOC, ls.fs.freereg - 1);
        LuaCode.luaK_storevar(ls.fs, lh.v, e);
    }

    static int cond(LuaLex.LexState ls)
    {
        expdesc v = new expdesc();
        expr(ls, v);
        if (v.k == expkind_.VNIL) {
            v.k = expkind_.VFALSE;
        }
        LuaCode.luaK_goiftrue(ls.fs, v);
        return v.f;
    }

    static void breakstat(LuaLex.LexState ls)
    {
        FuncState fs = ls.fs;
        BlockCnt bl = fs.bl;
        int upval = 0;
        while ((bl != null) && (bl.isbreakable == 0)) {
            upval |= bl.upval;
            bl = bl.previous;
        }
        if (bl == null) {
            LuaLex.luaX_syntaxerror(ls, CLib.CharPtr.toCharPtr("no loop to break"));
        }
        if (upval != 0) {
            LuaCode.luaK_codeABC(fs, LuaOpCodes.OpCode.OP_CLOSE, bl.nactvar, 0, 0);
        }
        List<int> breaklist_ref = new List<int>(1);
        breaklist_ref[0] = bl.breaklist;
        LuaCode.luaK_concat(fs, breaklist_ref, LuaCode.luaK_jump(fs));
        bl.breaklist = breaklist_ref[0];
    }

    static void whilestat(LuaLex.LexState ls, int line)
    {
        FuncState fs = ls.fs;
        int whileinit;
        int condexit;
        BlockCnt bl = new BlockCnt();
        LuaLex.luaX_next(ls);
        whileinit = LuaCode.luaK_getlabel(fs);
        condexit = cond(ls);
        enterblock(fs, bl, 1);
        checknext(ls, LuaLex.RESERVED.TK_DO);
        block(ls);
        LuaCode.luaK_patchlist(fs, LuaCode.luaK_jump(fs), whileinit);
        check_match(ls, LuaLex.RESERVED.TK_END, LuaLex.RESERVED.TK_WHILE, line);
        leaveblock(fs);
        LuaCode.luaK_patchtohere(fs, condexit);
    }

    static void repeatstat(LuaLex.LexState ls, int line)
    {
        int condexit;
        FuncState fs = ls.fs;
        int repeat_init = LuaCode.luaK_getlabel(fs);
        BlockCnt bl1 = new BlockCnt();
        BlockCnt bl2 = new BlockCnt();
        enterblock(fs, bl1, 1);
        enterblock(fs, bl2, 0);
        LuaLex.luaX_next(ls);
        chunk(ls);
        check_match(ls, LuaLex.RESERVED.TK_UNTIL, LuaLex.RESERVED.TK_REPEAT, line);
        condexit = cond(ls);
        if (bl2.upval == 0) {
            leaveblock(fs);
            LuaCode.luaK_patchlist(ls.fs, condexit, repeat_init);
        } else {
            breakstat(ls);
            LuaCode.luaK_patchtohere(ls.fs, condexit);
            leaveblock(fs);
            LuaCode.luaK_patchlist(ls.fs, LuaCode.luaK_jump(fs), repeat_init);
        }
        leaveblock(fs);
    }

    static int exp1(LuaLex.LexState ls)
    {
        expdesc e = new expdesc();
        int k;
        expr(ls, e);
        k = expkindToInt(e.k);
        LuaCode.luaK_exp2nextreg(ls.fs, e);
        return k;
    }

    static void forbody(LuaLex.LexState ls, int base_, int line, int nvars, int isnum)
    {
        BlockCnt bl = new BlockCnt();
        FuncState fs = ls.fs;
        int prep;
        int endfor;
        adjustlocalvars(ls, 3);
        checknext(ls, LuaLex.RESERVED.TK_DO);
        prep = ((isnum != 0) ? LuaCode.luaK_codeAsBx(fs, LuaOpCodes.OpCode.OP_FORPREP, base_, LuaCode.NO_JUMP) : LuaCode.luaK_jump(fs));
        enterblock(fs, bl, 0);
        adjustlocalvars(ls, nvars);
        LuaCode.luaK_reserveregs(fs, nvars);
        block(ls);
        leaveblock(fs);
        LuaCode.luaK_patchtohere(fs, prep);
        endfor = ((isnum != 0) ? LuaCode.luaK_codeAsBx(fs, LuaOpCodes.OpCode.OP_FORLOOP, base_, LuaCode.NO_JUMP) : LuaCode.luaK_codeABC(fs, LuaOpCodes.OpCode.OP_TFORLOOP, base_, 0, nvars));
        LuaCode.luaK_fixline(fs, line);
        LuaCode.luaK_patchlist(fs, (isnum != 0) ? endfor : LuaCode.luaK_jump(fs), prep + 1);
    }

    static void fornum(LuaLex.LexState ls, LuaObject.TString varname, int line)
    {
        FuncState fs = ls.fs;
        int base_ = fs.freereg;
        new_localvarliteral(ls, CLib.CharPtr.toCharPtr("(for index)"), 0);
        new_localvarliteral(ls, CLib.CharPtr.toCharPtr("(for limit)"), 1);
        new_localvarliteral(ls, CLib.CharPtr.toCharPtr("(for step)"), 2);
        new_localvar(ls, varname, 3);
        checknext(ls, '='.codeUnitAt(0));
        exp1(ls);
        checknext(ls, ','.codeUnitAt(0));
        exp1(ls);
        if (testnext(ls, ','.codeUnitAt(0)) != 0) {
            exp1(ls);
        } else {
            LuaCode.luaK_codeABx(fs, LuaOpCodes.OpCode.OP_LOADK, fs.freereg, LuaCode.luaK_numberK(fs, 1));
            LuaCode.luaK_reserveregs(fs, 1);
        }
        forbody(ls, base_, line, 1, 1);
    }

    static void forlist(LuaLex.LexState ls, LuaObject.TString indexname)
    {
        FuncState fs = ls.fs;
        expdesc e = new expdesc();
        int nvars = 0;
        int line;
        int base_ = fs.freereg;
        new_localvarliteral(ls, CLib.CharPtr.toCharPtr("(for generator)"), nvars++);
        new_localvarliteral(ls, CLib.CharPtr.toCharPtr("(for state)"), nvars++);
        new_localvarliteral(ls, CLib.CharPtr.toCharPtr("(for control)"), nvars++);
        new_localvar(ls, indexname, nvars++);
        while (testnext(ls, ','.codeUnitAt(0)) != 0) {
            new_localvar(ls, str_checkname(ls), nvars++);
        }
        checknext(ls, LuaLex.RESERVED.TK_IN);
        line = ls.linenumber;
        adjust_assign(ls, 3, explist1(ls, e), e);
        LuaCode.luaK_checkstack(fs, 3);
        forbody(ls, base_, line, nvars - 3, 0);
    }

    static void forstat(LuaLex.LexState ls, int line)
    {
        FuncState fs = ls.fs;
        LuaObject.TString varname;
        BlockCnt bl = new BlockCnt();
        enterblock(fs, bl, 1);
        LuaLex.luaX_next(ls);
        varname = str_checkname(ls);
        switch (ls.t.token) {
            case '='.codeUnitAt(0):
                fornum(ls, varname, line);
                break;
            case ','.codeUnitAt(0):
            case LuaLex.RESERVED.TK_IN:
                forlist(ls, varname);
                break;
            default:
                LuaLex.luaX_syntaxerror(ls, CLib.CharPtr.toCharPtr(((LuaConf.LUA_QL("=") + " or ") + LuaConf.LUA_QL("in")) + " expected"));
                break;
        }
        check_match(ls, LuaLex.RESERVED.TK_END, LuaLex.RESERVED.TK_FOR, line);
        leaveblock(fs);
    }

    static int test_then_block(LuaLex.LexState ls)
    {
        int condexit;
        LuaLex.luaX_next(ls);
        condexit = cond(ls);
        checknext(ls, LuaLex.RESERVED.TK_THEN);
        block(ls);
        return condexit;
    }

    static void ifstat(LuaLex.LexState ls, int line)
    {
        FuncState fs = ls.fs;
        int flist;
        List<int> escapelist = new List<int>(1);
        escapelist[0] = LuaCode.NO_JUMP;
        flist = test_then_block(ls);
        while (ls.t.token == LuaLex.RESERVED.TK_ELSEIF) {
            LuaCode.luaK_concat(fs, escapelist, LuaCode.luaK_jump(fs));
            LuaCode.luaK_patchtohere(fs, flist);
            flist = test_then_block(ls);
        }
        if (ls.t.token == LuaLex.RESERVED.TK_ELSE) {
            LuaCode.luaK_concat(fs, escapelist, LuaCode.luaK_jump(fs));
            LuaCode.luaK_patchtohere(fs, flist);
            LuaLex.luaX_next(ls);
            block(ls);
        } else {
            LuaCode.luaK_concat(fs, escapelist, flist);
        }
        LuaCode.luaK_patchtohere(fs, escapelist[0]);
        check_match(ls, LuaLex.RESERVED.TK_END, LuaLex.RESERVED.TK_IF, line);
    }

    static void localfunc(LuaLex.LexState ls)
    {
        expdesc v = new expdesc();
        expdesc b = new expdesc();
        FuncState fs = ls.fs;
        new_localvar(ls, str_checkname(ls), 0);
        init_exp(v, expkind_.VLOCAL, fs.freereg);
        LuaCode.luaK_reserveregs(fs, 1);
        adjustlocalvars(ls, 1);
        body(ls, b, 0, ls.linenumber);
        LuaCode.luaK_storevar(fs, v, b);
        getlocvar(fs, fs.nactvar - 1).startpc = fs.pc;
    }

    static void localstat(LuaLex.LexState ls)
    {
        int nvars = 0;
        int nexps;
        expdesc e = new expdesc();
        do {
            new_localvar(ls, str_checkname(ls), nvars++);
        } while (testnext(ls, ','.codeUnitAt(0)) != 0);
        if (testnext(ls, '='.codeUnitAt(0)) != 0) {
            nexps = explist1(ls, e);
        } else {
            e.k = expkind_.VVOID;
            nexps = 0;
        }
        adjust_assign(ls, nvars, nexps, e);
        adjustlocalvars(ls, nvars);
    }

    static int funcname(LuaLex.LexState ls, expdesc v)
    {
        int needself = 0;
        singlevar(ls, v);
        while (ls.t.token == '.'.codeUnitAt(0)) {
            field(ls, v);
        }
        if (ls.t.token == ':'.codeUnitAt(0)) {
            needself = 1;
            field(ls, v);
        }
        return needself;
    }

    static void funcstat(LuaLex.LexState ls, int line)
    {
        int needself;
        expdesc v = new expdesc();
        expdesc b = new expdesc();
        LuaLex.luaX_next(ls);
        needself = funcname(ls, v);
        body(ls, b, needself, line);
        LuaCode.luaK_storevar(ls.fs, v, b);
        LuaCode.luaK_fixline(ls.fs, line);
    }

    static void exprstat(LuaLex.LexState ls)
    {
        FuncState fs = ls.fs;
        LHS_assign v = new LHS_assign();
        primaryexp(ls, v.v);
        if (v.v.k == expkind_.VCALL) {
            LuaOpCodes.SETARG_C(LuaCode.getcode(fs, v.v), 1);
        } else {
            v.prev = null;
            assignment(ls, v, 1);
        }
    }

    static void retstat(LuaLex.LexState ls)
    {
        FuncState fs = ls.fs;
        expdesc e = new expdesc();
        int first;
        int nret;
        LuaLex.luaX_next(ls);
        if ((block_follow(ls.t.token) != 0) || (ls.t.token == ';'.codeUnitAt(0))) {
            first = (nret = 0);
        } else {
            nret = explist1(ls, e);
            if (hasmultret(e.k) != 0) {
                LuaCode.luaK_setmultret(fs, e);
                if ((e.k == expkind_.VCALL) && (nret == 1)) {
                    LuaOpCodes.SET_OPCODE(LuaCode.getcode(fs, e), LuaOpCodes.OpCode.OP_TAILCALL);
                    LuaLimits.lua_assert(LuaOpCodes.GETARG_A(LuaCode.getcode(fs, e)) == fs.nactvar);
                }
                first = fs.nactvar;
                nret = Lua.LUA_MULTRET;
            } else {
                if (nret == 1) {
                    first = LuaCode.luaK_exp2anyreg(fs, e);
                } else {
                    LuaCode.luaK_exp2nextreg(fs, e);
                    first = fs.nactvar;
                    LuaLimits.lua_assert(nret == (fs.freereg - first));
                }
            }
        }
        LuaCode.luaK_ret(fs, first, nret);
    }

    static int statement(LuaLex.LexState ls)
    {
        int line = ls.linenumber;
        switch (ls.t.token) {
            case LuaLex.RESERVED.TK_IF:
                ifstat(ls, line);
                return 0;
            case LuaLex.RESERVED.TK_WHILE:
                whilestat(ls, line);
                return 0;
            case LuaLex.RESERVED.TK_DO:
                LuaLex.luaX_next(ls);
                block(ls);
                check_match(ls, LuaLex.RESERVED.TK_END, LuaLex.RESERVED.TK_DO, line);
                return 0;
            case LuaLex.RESERVED.TK_FOR:
                forstat(ls, line);
                return 0;
            case LuaLex.RESERVED.TK_REPEAT:
                repeatstat(ls, line);
                return 0;
            case LuaLex.RESERVED.TK_FUNCTION:
                funcstat(ls, line);
                return 0;
            case LuaLex.RESERVED.TK_LOCAL:
                LuaLex.luaX_next(ls);
                if (testnext(ls, LuaLex.RESERVED.TK_FUNCTION) != 0) {
                    localfunc(ls);
                } else {
                    localstat(ls);
                }
                return 0;
            case LuaLex.RESERVED.TK_RETURN:
                retstat(ls);
                return 1;
            case LuaLex.RESERVED.TK_BREAK:
                LuaLex.luaX_next(ls);
                breakstat(ls);
                return 1;
            default:
                exprstat(ls);
                return 0;
        }
    }

    static void chunk(LuaLex.LexState ls)
    {
        int islast = 0;
        enterlevel(ls);
        while ((islast == 0) && (block_follow(ls.t.token) == 0)) {
            islast = statement(ls);
            testnext(ls, ';'.codeUnitAt(0));
            LuaLimits.lua_assert((ls.fs.f.maxstacksize >= ls.fs.freereg) && (ls.fs.freereg >= ls.fs.nactvar));
            ls.fs.freereg = ls.fs.nactvar;
        }
        leavelevel(ls);
    }
}

class expdesc
{
    _u u = new _u();
    int t;
    int f;
    expkind k = expkind_.forValue(0);

    void Copy(expdesc e)
    {
        this.k = e.k;
        this.u.Copy(e.u);
        this.t = e.t;
        this.f = e.f;
    }
}

class _u
{
    _s s = new _s();
    double nval;

    void Copy(_u u)
    {
        this.s.Copy(u.s);
        this.nval = u.nval;
    }
}

class _s
{
    int info;
    int aux;

    void Copy(_s s)
    {
        this.info = s.info;
        this.aux = s.aux;
    }
}

class upvaldesc
{
    int k;
    int info;
}

class FuncState
{
    LuaObject.Proto f;
    LuaObject.Table h;
    FuncState prev;
    LuaLex.LexState ls;
    LuaState.lua_State L;
    LuaParser.BlockCnt bl;
    int pc;
    int lasttarget;
    int jpc;
    int freereg;
    int nk;
    int np;
    int nlocvars;
    int nactvar;
    List<upvaldesc> upvalues = new List<upvaldesc>(LuaConf.LUAI_MAXUPVALUES);
    List<int> actvar = new List<int>(LuaConf.LUAI_MAXVARS);

    FuncState_()
    {
        for (int i = 0; i < this.upvalues.length; i++) {
            this.upvalues[i] = new upvaldesc();
        }
    }
}

class BlockCnt
{
    BlockCnt previous;
    int breaklist;
    int nactvar;
    int upval;
    int isbreakable;
}

class ConsControl
{
    expdesc v = new expdesc();
    expdesc t;
    int nh;
    int na;
    int tostore;
}

class priority_
{
    int left;
    int right;

    priority__(int left, int right)
    {
        this.left = left;
        this.right = right;
    }
}

class LHS_assign
{
    LHS_assign prev;
    LuaParser.expdesc v = new LuaParser.expdesc();
}


	/*
	 ** Expression descriptor
	 */
	public static enum expkind {
		VVOID(0),	/* no value */
		VNIL(1),
		VTRUE(2),
		VFALSE(3),
		VK(4),		/* info = index of constant in `k' */
		VKNUM(5),	/* nval = numerical value */
		VLOCAL(6),	/* info = local register */
		VUPVAL(7),       /* info = index of upvalue in `upvalues' */
		VGLOBAL(8),	/* info = index of table; aux = index of global name in `k' */
		VINDEXED(9),	/* info = table register; aux = index register (or `k') */
		VJMP(10),		/* info = instruction pc */
		VRELOCABLE(11),	/* info = instruction pc */
		VNONRELOC(12),	/* info = result register */
		VCALL(13),	/* info = instruction pc */
		VVARARG(14);	/* info = instruction pc */

		private int intValue;
		private static java.util.HashMap<Integer, expkind> mappings;
		private synchronized static java.util.HashMap<Integer, expkind> getMappings() {
			if (mappings == null) {
				mappings = new java.util.HashMap<Integer, expkind>();
			}
			return mappings;
		}

		private expkind(int value) {
			intValue = value;
			expkind.getMappings().put(value, this);
		}

		public int getValue() {
			return intValue;
		}

		public static expkind forValue(int value) {
			return getMappings().get(value);
		}
	}	

