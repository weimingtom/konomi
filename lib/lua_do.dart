library kurumi;

class LuaDo
{

    static void luaD_checkstack(LuaState.lua_State L, int n)
    {
        if (LuaObject.TValue.minus(L.stack_last, L.top) <= n) {
            luaD_growstack(L, n);
        } else {
        }
    }

    static void incr_top(LuaState.lua_State L)
    {
        luaD_checkstack(L, 1);
        LuaObject.TValue[] top = new LuaObject.TValue[1];
        top[0] = L.top;
        LuaObject.TValue.inc(top);
        L.top = top[0];
    }

    static int savestack(LuaState.lua_State L, LuaObject.TValue p)
    {
        return LuaObject.TValue.toInt(p);
    }

    static LuaObject.TValue restorestack(LuaState.lua_State L, int n)
    {
        return L.stack[n];
    }

    static int saveci(LuaState.lua_State L, LuaState.CallInfo p)
    {
        return LuaState.CallInfo.minus(p, L.base_ci);
    }

    static LuaState.CallInfo restoreci(LuaState.lua_State L, int n)
    {
        return L.base_ci[n];
    }
    static const int PCRLUA = 0;
    static const int PCRC = 1;
    static const int PCRYIELD = 2;

    abstract class Pfunc
    {

        void exec(LuaState.lua_State L, Object ud);
    }

    abstract class luai_jmpbuf
    {

        void exec(int b);
    }

    static void luaD_seterrorobj(LuaState.lua_State L, int errcode, LuaObject.TValue oldtop)
    {
        switch (errcode) {
            case Lua.LUA_ERRMEM:
                LuaObject.setsvalue2s(L, oldtop, LuaString.luaS_newliteral(L, CLib.CharPtr.toCharPtr(LuaMem.MEMERRMSG)));
                break;
            case Lua.LUA_ERRERR:
                LuaObject.setsvalue2s(L, oldtop, LuaString.luaS_newliteral(L, CLib.CharPtr.toCharPtr("error in error handling")));
                break;
            case Lua.LUA_ERRSYNTAX:
            case Lua.LUA_ERRRUN:
                LuaObject.setobjs2s(L, oldtop, LuaObject.TValue.minus(L.top, 1));
                break;
        }
        L.top = LuaObject.TValue.plus(oldtop, 1);
    }

    static void restore_stack_limit(LuaState.lua_State L)
    {
        LuaLimits.lua_assert(LuaObject.TValue.toInt(L.stack_last) == ((L.stacksize - LuaState.EXTRA_STACK) - 1));
        if (L.size_ci > LuaConf.LUAI_MAXCALLS) {
            int inuse = LuaState.CallInfo.minus(L.ci, L.base_ci);
            if ((inuse + 1) < LuaConf.LUAI_MAXCALLS) {
                luaD_reallocCI(L, LuaConf.LUAI_MAXCALLS);
            }
        }
    }

    static void resetstack(LuaState.lua_State L, int status)
    {
        L.ci = L.base_ci[0];
        L.base_ = L.ci.base_;
        LuaFunc.luaF_close(L, L.base_);
        luaD_seterrorobj(L, status, L.base_);
        L.nCcalls = L.baseCcalls;
        L.allowhook = 1;
        restore_stack_limit(L);
        L.errfunc = 0;
        L.errorJmp = null;
    }

    static void luaD_throw(LuaState.lua_State L, int errcode)
    {
        if (L.errorJmp != null) {
            L.errorJmp.status = errcode;
            LuaConf.LUAI_THROW(L, L.errorJmp);
        } else {
            L.status = LuaLimits.cast_byte(errcode);
            if (LuaState.G(L).panic != null) {
                resetstack(L, errcode);
                LuaLimits.lua_unlock(L);
                LuaState.G(L).panic.exec(L);
            }
            System.exit(CLib.EXIT_FAILURE);
        }
    }

    static int luaD_rawrunprotected(LuaState.lua_State L, LuaDo.Pfunc f, Object ud)
    {
        lua_longjmp lj = new lua_longjmp();
        lj.status = 0;
        lj.previous = L.errorJmp;
        L.errorJmp = lj;
        if (LuaConf.CATCH_EXCEPTIONS) {
            try {
                f.exec(L, ud);
            } on java.lang.Exception catch (e) {
                if (lj.status == 0) {
                    lj.status = (-1);
                }
            }
        } else {
            try {
                f.exec(L, ud);
            } on LuaConf.LuaException catch (e) {
                if (lj.status == 0) {
                    lj.status = (-1);
                }
            }
        }
        L.errorJmp = lj.previous;
        return lj.status;
    }

    static void correctstack(LuaState.lua_State L, List<LuaObject.TValue> oldstack)
    {
    }

    static void luaD_reallocstack(LuaState.lua_State L, int newsize)
    {
        LuaObject.TValue[] oldstack = L.stack;
        int realsize = ((newsize + 1) + LuaState.EXTRA_STACK);
        LuaLimits.lua_assert(LuaObject.TValue.toInt(L.stack_last) == ((L.stacksize - LuaState.EXTRA_STACK) - 1));
        LuaObject.TValue[][] stack = new LuaObject.TValue[1][];
        stack[0] = L.stack;
        LuaMem.luaM_reallocvector_TValue(L, stack, L.stacksize, realsize, new ClassType(ClassType_.TYPE_TVALUE));
        L.stack = stack[0];
        L.stacksize = realsize;
        L.stack_last = L.stack[newsize];
        correctstack(L, oldstack);
    }

    static void luaD_reallocCI(LuaState.lua_State L, int newsize)
    {
        LuaState.CallInfo oldci = L.base_ci[0];
		    LuaState.CallInfo[][] base_ci = new LuaState.CallInfo[1][];
        base_ci[0] = L.base_ci;
        LuaMem.luaM_reallocvector_CallInfo(L, base_ci, L.size_ci, newsize, new ClassType(ClassType_.TYPE_CALLINFO));
        L.base_ci = base_ci[0];
        L.size_ci = newsize;
        L.ci = L.base_ci[LuaState.CallInfo.minus(L.ci, oldci)];
        L.end_ci = L.base_ci[L.size_ci - 1];
    }

    static void luaD_growstack(LuaState.lua_State L, int n)
    {
        if (n <= L.stacksize) {
            luaD_reallocstack(L, 2 * L.stacksize);
        } else {
            luaD_reallocstack(L, L.stacksize + n);
        }
    }

    static LuaState.CallInfo growCI(LuaState.lua_State L)
    {
        if (L.size_ci > LuaConf.LUAI_MAXCALLS) {
            luaD_throw(L, Lua.LUA_ERRERR);
        } else {
            luaD_reallocCI(L, 2 * L.size_ci);
            if (L.size_ci > LuaConf.LUAI_MAXCALLS) {
                LuaDebug.luaG_runerror(L, CLib.CharPtr.toCharPtr("stack overflow"));
            }
        }
        LuaState.CallInfo[] ci_ref = new LuaState.CallInfo[1];
        ci_ref[0] = L.ci;
        LuaState.CallInfo.inc(ci_ref);
        L.ci = ci_ref[0];
        return L.ci;
    }

    static void luaD_callhook(LuaState.lua_State L, int event_, int line)
    {
        Lua.lua_Hook hook = L.hook;
        if ((hook != null) && (L.allowhook != 0)) {
            int top = savestack(L, L.top);
            int ci_top = savestack(L, L.ci.top);
            Lua.lua_Debug ar = new Lua.lua_Debug();
            ar.event_ = event_;
            ar.currentline = line;
            if (event_ == Lua.LUA_HOOKTAILRET) {
                ar.i_ci = 0;
            } else {
                ar.i_ci = LuaState.CallInfo.minus(L.ci, L.base_ci);
            }
            luaD_checkstack(L, Lua.LUA_MINSTACK);
            L.ci.top = LuaObject.TValue.plus(L.top, Lua.LUA_MINSTACK);
            LuaLimits.lua_assert(LuaObject.TValue.lessEqual(L.ci.top, L.stack_last));
            L.allowhook = 0;
            LuaLimits.lua_unlock(L);
            hook.exec(L, ar);
            LuaLimits.lua_lock(L);
            LuaLimits.lua_assert(L.allowhook == 0);
            L.allowhook = 1;
            L.ci.top = restorestack(L, ci_top);
            L.top = restorestack(L, top);
        }
    }

    static LuaObject.TValue adjust_varargs(LuaState.lua_State L, LuaObject.Proto p, int actual)
    {
        int i;
        int nfixargs = p.numparams;
        LuaObject.Table htab = null;
		    LuaObject.TValue base_, fixed_; //StkId
        for (; actual < nfixargs; (++actual)) {
            LuaObject.TValue[] top = new LuaObject.TValue[1];
            top[0] = L.top;
            LuaObject.TValue ret = LuaObject.TValue.inc(top); //ref - StkId
            L.top = top[0];
            LuaObject.setnilvalue(ret);
        }
        if ((p.is_vararg & LuaObject.VARARG_NEEDSARG) != 0) {
            int nvar = (actual - nfixargs);
            LuaLimits.lua_assert(p.is_vararg & LuaObject.VARARG_HASARG);
            LuaGC.luaC_checkGC(L);
            htab = LuaTable.luaH_new(L, nvar, 1);
            for ((i = 0); i < nvar; i++) {
                LuaObject.setobj2n(L, LuaTable.luaH_setnum(L, htab, i + 1), LuaObject.TValue.plus(LuaObject.TValue.minus(L.top, nvar), i));
            }
            LuaObject.setnvalue(LuaTable.luaH_setstr(L, htab, LuaString.luaS_newliteral(L, CLib.CharPtr.toCharPtr("n"))), LuaLimits.cast_num(nvar));
        }
        fixed_ = LuaObject.TValue.minus(L.top, actual);
        base_ = L.top;
        for ((i = 0); i < nfixargs; i++) {
            LuaObject.TValue[] top = new LuaObject.TValue[1];
            top[0] = L.top;
            LuaObject.TValue ret = LuaObject.TValue.inc(top); //ref - StkId
            L.top = top[0];
            LuaObject.setobjs2s(L, ret, LuaObject.TValue.plus(fixed_, i));
            LuaObject.setnilvalue(LuaObject.TValue.plus(fixed_, i));
        }
        if (htab != null) {
            LuaObject.TValue top = L.top; //StkId
			      LuaObject.TValue[] top_ref = new LuaObject.TValue[1];
            top_ref[0] = L.top;
            LuaObject.TValue.inc(top_ref);
            L.top = top_ref[0];
            LuaObject.sethvalue(L, top, htab);
            LuaLimits.lua_assert(LuaGC.iswhite(LuaState.obj2gco(htab)));
        }
        return base_;
    }

    static LuaObject.TValue tryfuncTM(LuaState.lua_State L, LuaObject.TValue func)
    {
        LuaObject.TValue tm = LuaTM.luaT_gettmbyobj(L, func, LuaTM.TMS.TM_CALL);
		    LuaObject.TValue[] p = new LuaObject.TValue[1]; //StkId
        p[0] = new LuaObject.TValue();
        int funcr = savestack(L, func);
        if (!LuaObject.ttisfunction(tm)) {
            LuaDebug.luaG_typeerror(L, func, CLib.CharPtr.toCharPtr("call"));
        }
        for ((p[0] = L.top); LuaObject.TValue.greaterThan(p[0], func); LuaObject.TValue.dec(p)) {
            LuaObject.setobjs2s(L, p[0], LuaObject.TValue.minus(p[0], 1));
        }
        incr_top(L);
        func = restorestack(L, funcr);
        LuaObject.setobj2s(L, func, tm);
        return func;
    }

    static LuaState.CallInfo inc_ci(LuaState.lua_State L)
    {
        if (L.ci == L.end_ci) {
            return growCI(L);
        }
        LuaState.CallInfo[] ci_ref = new LuaState.CallInfo[1];
        ci_ref[0] = L.ci;
        LuaState.CallInfo.inc(ci_ref);
        L.ci = ci_ref[0];
        return L.ci;
    }

    static int luaD_precall(LuaState.lua_State L, LuaObject.TValue func, int nresults)
    {
        LuaObject.LClosure cl;
        int funcr;
        if (!LuaObject.ttisfunction(func)) {
            func = tryfuncTM(L, func);
        }
        funcr = savestack(L, func);
        cl = LuaObject.clvalue(func).l;
        L.ci.savedpc = LuaCode.InstructionPtr.Assign(L.savedpc);
        if (cl.getIsC() == 0) {
            LuaState.CallInfo ci;
			      LuaObject.TValue[] st = new LuaObject.TValue[1]; //StkId
            st[0] = new LuaObject.TValue();
            LuaObject.TValue base_; //StkId
			      LuaObject.Proto p = cl.p;
            luaD_checkstack(L, p.maxstacksize);
            func = restorestack(L, funcr);
            if (p.is_vararg == 0) {
                base_ = L.stack[LuaObject.TValue.toInt(LuaObject.TValue.plus(func, 1))];
                if (LuaObject.TValue.greaterThan(L.top, LuaObject.TValue.plus(base_, p.numparams))) {
                    L.top = LuaObject.TValue.plus(base_, p.numparams);
                }
            } else {
                int nargs = (LuaObject.TValue.minus(L.top, func) - 1);
                base_ = adjust_varargs(L, p, nargs);
                func = restorestack(L, funcr);
            }
            ci = inc_ci(L);
            ci.func = func;
            L.base_ = (ci.base_ = base_);
            ci.top = LuaObject.TValue.plus(L.base_, p.maxstacksize);
            LuaLimits.lua_assert(LuaObject.TValue.lessEqual(ci.top, L.stack_last));
            L.savedpc = new LuaCode.InstructionPtr(p.code, 0);
            ci.tailcalls = 0;
            ci.nresults = nresults;
            for ((st[0] = L.top); LuaObject.TValue.lessThan(st[0], ci.top); LuaObject.TValue.inc(st)) {
                LuaObject.setnilvalue(st[0]);
            }
            L.top = ci.top;
            if ((L.hookmask & Lua.LUA_MASKCALL) != 0) {
                LuaCode.InstructionPtr[] savedpc_ref = new LuaCode.InstructionPtr[1];
                savedpc_ref[0] = L.savedpc;
                LuaCode.InstructionPtr.inc(savedpc_ref);
                L.savedpc = savedpc_ref[0];
                luaD_callhook(L, Lua.LUA_HOOKCALL, -1);
                savedpc_ref[0] = L.savedpc;
                LuaCode.InstructionPtr.dec(savedpc_ref);
                L.savedpc = savedpc_ref[0];
            }
            return PCRLUA;
        } else {
            LuaState.CallInfo ci;
            int n;
            luaD_checkstack(L, Lua.LUA_MINSTACK);
            ci = inc_ci(L);
            ci.func = restorestack(L, funcr);
            L.base_ = (ci.base_ = LuaObject.TValue.plus(ci.func, 1));
            ci.top = LuaObject.TValue.plus(L.top, Lua.LUA_MINSTACK);
            LuaLimits.lua_assert(LuaObject.TValue.lessEqual(ci.top, L.stack_last));
            ci.nresults = nresults;
            if ((L.hookmask & Lua.LUA_MASKCALL) != 0) {
                luaD_callhook(L, Lua.LUA_HOOKCALL, -1);
            }
            LuaLimits.lua_unlock(L);
            n = LuaState.curr_func(L).c.f.exec(L);
            LuaLimits.lua_lock(L);
            if (n < 0) {
                return PCRYIELD;
            } else {
                luaD_poscall(L, LuaObject.TValue.minus(L.top, n));
                return PCRC;
            }
        }
    }

    static LuaObject.TValue callrethooks(LuaState.lua_State L, LuaObject.TValue firstResult)
    {
        int fr = savestack(L, firstResult);
        luaD_callhook(L, Lua.LUA_HOOKRET, -1);
        if (LuaState.f_isLua(L.ci)) {
            while (((L.hookmask & Lua.LUA_MASKRET) != 0) && (L.ci.tailcalls-- != 0)) {
                luaD_callhook(L, Lua.LUA_HOOKTAILRET, -1);
            }
        }
        return restorestack(L, fr);
    }

    static int luaD_poscall(LuaState.lua_State L, LuaObject.TValue firstResult)
    {
        LuaObject.TValue res; //StkId
        int wanted;
        int i;
        LuaState.CallInfo ci;
        if ((L.hookmask & Lua.LUA_MASKRET) != 0) {
            firstResult = callrethooks(L, firstResult);
        }
        LuaState.CallInfo[] ci_ref = new LuaState.CallInfo[1];
        ci_ref[0] = L.ci;
        ci = LuaState.CallInfo.dec(ci_ref);
        L.ci = ci_ref[0];
        res = ci.func;
        wanted = ci.nresults;
        L.base_ = LuaState.CallInfo.minus(ci, 1).base_;
        L.savedpc = LuaCode.InstructionPtr.Assign(LuaState.CallInfo.minus(ci, 1).savedpc);
        for ((i = wanted); (i != 0) && LuaObject.TValue.lessThan(firstResult, L.top); i--) {
            LuaObject.setobjs2s(L, res, firstResult);
            res = LuaObject.TValue.plus(res, 1);
            firstResult = LuaObject.TValue.plus(firstResult, 1);
        }
        while (i-- > 0) {
            LuaObject.TValue[] res_ref = new LuaObject.TValue[1];
            res_ref[0] = res;
            LuaObject.TValue ret = LuaObject.TValue.inc(res_ref); //ref - StkId 
            res = res_ref[0];
            LuaObject.setnilvalue(ret);
        }
        L.top = res;
        return wanted - Lua.LUA_MULTRET;
    }

    static void luaD_call(LuaState.lua_State L, LuaObject.TValue func, int nResults)
    {
        if ((++L.nCcalls) >= LuaConf.LUAI_MAXCCALLS) {
            if (L.nCcalls == LuaConf.LUAI_MAXCCALLS) {
                LuaDebug.luaG_runerror(L, CLib.CharPtr.toCharPtr("C stack overflow"));
            } else {
                if (L.nCcalls >= (LuaConf.LUAI_MAXCCALLS + (LuaConf.LUAI_MAXCCALLS >> 3))) {
                    luaD_throw(L, Lua.LUA_ERRERR);
                }
            }
        }
        if (luaD_precall(L, func, nResults) == PCRLUA) {
            LuaVM.luaV_execute(L, 1);
        }
        L.nCcalls--;
        LuaGC.luaC_checkGC(L);
    }

    static void resume(LuaState.lua_State L, Object ud)
    {
        LuaObject.TValue firstArg = (LuaObject.TValue)ud; //StkId - StkId
		    LuaState.CallInfo ci = L.ci;
        if (L.status == 0) {
            LuaLimits.lua_assert((ci == L.base_ci[0]) && LuaObject.TValue.greaterThan(firstArg, L.base_));
            if (luaD_precall(L, LuaObject.TValue.minus(firstArg, 1), Lua.LUA_MULTRET) != PCRLUA) {
                return;
            }
        } else {
            LuaLimits.lua_assert(L.status == Lua.LUA_YIELD);
            L.status = 0;
            if (!LuaState.f_isLua(ci)) {
                LuaLimits.lua_assert((LuaOpCodes.GET_OPCODE(LuaState.CallInfo.minus(ci, 1).savedpc.get(-1)) == LuaOpCodes.OpCode.OP_CALL) || (LuaOpCodes.GET_OPCODE(LuaState.CallInfo.minus(ci, 1).savedpc.get(-1)) == LuaOpCodes.OpCode.OP_TAILCALL));
                if (luaD_poscall(L, firstArg) != 0) {
                    L.top = L.ci.top;
                }
            } else {
                L.base_ = L.ci.base_;
            }
        }
        LuaVM.luaV_execute(L, LuaState.CallInfo.minus(L.ci, L.base_ci));
    }

    static int resume_error(LuaState.lua_State L, CLib.CharPtr msg)
    {
        L.top = L.ci.base_;
        LuaObject.setsvalue2s(L, L.top, LuaString.luaS_new(L, msg));
        incr_top(L);
        LuaLimits.lua_unlock(L);
        return Lua.LUA_ERRRUN;
    }

    static int lua_resume(LuaState.lua_State L, int nargs)
    {
        int status;
        LuaLimits.lua_lock(L);
        if ((L.status != Lua.LUA_YIELD) && ((L.status != 0) || (L.ci != L.base_ci[0]))) {
            return resume_error(L, CLib.CharPtr.toCharPtr("cannot resume non-suspended coroutine"));
        }
        if (L.nCcalls >= LuaConf.LUAI_MAXCCALLS) {
            return resume_error(L, CLib.CharPtr.toCharPtr("C stack overflow"));
        }
        LuaConf.luai_userstateresume(L, nargs);
        LuaLimits.lua_assert(L.errfunc == 0);
        L.baseCcalls = (++L.nCcalls);
        status = luaD_rawrunprotected(L, new resume_delegate(), LuaObject.TValue.minus(L.top, nargs));
        if (status != 0) {
            L.status = LuaLimits.cast_byte(status);
            luaD_seterrorobj(L, status, L.top);
            L.ci.top = L.top;
        } else {
            LuaLimits.lua_assert(L.nCcalls == L.baseCcalls);
            status = L.status;
        }
        --L.nCcalls;
        LuaLimits.lua_unlock(L);
        return status;
    }

    static int lua_yield(LuaState.lua_State L, int nresults)
    {
        LuaConf.luai_userstateyield(L, nresults);
        LuaLimits.lua_lock(L);
        if (L.nCcalls > L.baseCcalls) {
            LuaDebug.luaG_runerror(L, CLib.CharPtr.toCharPtr("attempt to yield across metamethod/C-call boundary"));
        }
        L.base_ = LuaObject.TValue.minus(L.top, nresults);
        L.status = Lua.LUA_YIELD;
        LuaLimits.lua_unlock(L);
        return -1;
    }

    static int luaD_pcall(LuaState.lua_State L, Pfunc func, Object u, int old_top, int ef)
    {
        int status;
        int oldnCcalls = L.nCcalls;
        int old_ci = saveci(L, L.ci);
        int old_allowhooks = L.allowhook;
        int old_errfunc = L.errfunc;
        L.errfunc = ef;
        status = luaD_rawrunprotected(L, func, u);
        if (status != 0) {
            LuaObject.TValue oldtop = restorestack(L, old_top); //StkId
            LuaFunc.luaF_close(L, oldtop);
            luaD_seterrorobj(L, status, oldtop);
            L.nCcalls = oldnCcalls;
            L.ci = restoreci(L, old_ci);
            L.base_ = L.ci.base_;
            L.savedpc = LuaCode.InstructionPtr.Assign(L.ci.savedpc);
            L.allowhook = old_allowhooks;
            restore_stack_limit(L);
        }
        L.errfunc = old_errfunc;
        return status;
    }

    static void f_parser(LuaState.lua_State L, Object ud)
    {
        int i;
        LuaObject.Proto tf;
		    LuaObject.Closure cl;
        SParser p = ud;
        int c = LuaZIO.luaZ_lookahead(p.z);
        LuaGC.luaC_checkGC(L);
        tf = ((c == Lua.LUA_SIGNATURE.codeUnitAt(0)) ? LuaUndump.luaU_undump(L, p.z, p.buff, p.name) : LuaParser.luaY_parser(L, p.z, p.buff, p.name));
        cl = LuaFunc.luaF_newLclosure(L, tf.nups, LuaObject.hvalue(LuaState.gt(L)));
        cl.l.p = tf;
        for ((i = 0); i < tf.nups; i++) {
            cl.l.upvals[i] = LuaFunc.luaF_newupval(L);
        }
        LuaObject.setclvalue(L, L.top, cl);
        incr_top(L);
    }

    static int luaD_protectedparser(LuaState.lua_State L, LuaZIO.ZIO z, CLib.CharPtr name)
    {
        SParser p = new SParser();
        int status;
        p.z = z;
        p.name = new CLib.CharPtr(name);
        LuaZIO.luaZ_initbuffer(L, p.buff);
        status = luaD_pcall(L, new f_parser_delegate(), p, savestack(L, L.top), L.errfunc);
        LuaZIO.luaZ_freebuffer(L, p.buff);
        return status;
    }
}

class lua_longjmp
{
    lua_longjmp previous;
    luai_jmpbuf b;
    int status;  /* error code */
}

class resume_delegate with LuaDo_Pfunc
{

    void exec(LuaState.lua_State L, Object ud)
    {
        LuaDo.resume(L, ud);
    }
}

class SParser
{
    LuaZIO.ZIO z;
    LuaZIO.Mbuffer buff = new LuaZIO.Mbuffer();
    CLib.CharPtr name;
}

class f_parser_delegate with Pfunc
{

    f_parser_delegate_()
    {
    }

    void exec(LuaState.lua_State L, Object ud)
    {
        LuaDo.f_parser(L, ud);
    }
}
