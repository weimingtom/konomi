library kurumi;

class LuaDebug
{

    static int pcRel(LuaCode.InstructionPtr pc, LuaObject.Proto p)
    {
        ClassType.Assert(pc.codes == p.code);
        return pc.pc - 1;
    }

    static int getline(LuaObject.Proto f, int pc)
    {
        return (f.lineinfo != null) ? f.lineinfo[pc] : 0;
    }

    static void resethookcount(LuaState.lua_State L)
    {
        L.hookcount = L.basehookcount;
    }

    static int currentpc(LuaState.lua_State L, LuaState.CallInfo ci)
    {
        if (!LuaState.isLua(ci)) {
            return -1;
        }
        if (ci == L.ci) {
            ci.savedpc = LuaCode.InstructionPtr.Assign(L.savedpc);
        }
        return pcRel(ci.savedpc, LuaState.ci_func(ci).l.p);
    }

    static int currentline(LuaState.lua_State L, LuaState.CallInfo ci)
    {
        int pc = currentpc(L, ci);
        if (pc < 0) {
            return -1;
        } else {
            return getline(LuaState.ci_func(ci).l.p, pc);
        }
    }

    static int lua_sethook(LuaState.lua_State L, Lua.lua_Hook func, int mask, int count)
    {
        if ((func == null) || (mask == 0)) {
            mask = 0;
            func = null;
        }
        L.hook = func;
        L.basehookcount = count;
        resethookcount(L);
        L.hookmask = LuaLimits.cast_byte(mask);
        return 1;
    }

    static Lua.lua_Hook lua_gethook(LuaState.lua_State L)
    {
        return L.hook;
    }

    static int lua_gethookmask(LuaState.lua_State L)
    {
        return L.hookmask;
    }

    static int lua_gethookcount(LuaState.lua_State L)
    {
        return L.basehookcount;
    }

    static int lua_getstack(LuaState.lua_State L, int level, Lua.lua_Debug ar)
    {
        int status;
        LuaState.CallInfo[] ci = new LuaState.CallInfo[1];
        ci[0] = new LuaState.CallInfo();
        LuaLimits.lua_lock(L);
        for ((ci[0] = L.ci); (level > 0) && LuaState.CallInfo.greaterThan(ci[0], L.base_ci[0]); LuaState.CallInfo.dec(ci)) {
            level--;
            if (LuaState.f_isLua(ci[0])) {
                level -= ci[0].tailcalls;
            }
        }
        if ((level == 0) && LuaState.CallInfo.greaterThan(ci[0], L.base_ci[0])) {
            status = 1;
            ar.i_ci = LuaState.CallInfo.minus(ci[0], L.base_ci[0]);
        } else {
            if (level < 0) {
                status = 1;
                ar.i_ci = 0;
            } else {
                status = 0;
            }
        }
        LuaLimits.lua_unlock(L);
        return status;
    }

    static LuaObject.Proto getluaproto(LuaState.CallInfo ci)
    {
        return LuaState.isLua(ci) ? LuaState.ci_func(ci).l.p : null;
    }

    static CLib.CharPtr findlocal(LuaState.lua_State L, LuaState.CallInfo ci, int n)
    {
        CLib.CharPtr name;
		    LuaObject.Proto fp = getluaproto(ci);
        if ((fp != null) && CLib.CharPtr.isNotEqual(name = LuaFunc.luaF_getlocalname(fp, n, currentpc(L, ci)), null)) {
            return name;
        } else {
            LuaObject.TValue limit = (ci == L.ci) ? L.top : (LuaState.CallInfo.plus(ci, 1)).func; //StkId
            if ((LuaObject.TValue.minus(limit, ci.base_) >= n) && (n > 0)) {
                return CLib.CharPtr.toCharPtr("(*temporary)");
            } else {
                return null;
            }
        }
    }

    static CLib.CharPtr lua_getlocal(LuaState.lua_State L, Lua.lua_Debug ar, int n)
    {
        LuaState.CallInfo ci = L.base_ci[ar.i_ci];
		    CLib.CharPtr name = findlocal(L, ci, n);
        LuaLimits.lua_lock(L);
        if (CLib.CharPtr.isNotEqual(name, null)) {
            LuaAPI.luaA_pushobject(L, ci.base_.get(n - 1));
        }
        LuaLimits.lua_unlock(L);
        return name;
    }

    static CLib.CharPtr lua_setlocal(LuaState.lua_State L, Lua.lua_Debug ar, int n)
    {
        LuaState.CallInfo ci = L.base_ci[ar.i_ci];
		    CLib.CharPtr name = findlocal(L, ci, n);
        LuaLimits.lua_lock(L);
        if (CLib.CharPtr.isNotEqual(name, null)) {
            LuaObject.setobjs2s(L, ci.base_.get(n - 1), LuaObject.TValue.minus(L.top, 1));
        }
        LuaObject.TValue[] top = new LuaObject.TValue[1];
        top[0] = L.top;
        LuaObject.TValue.dec(top);
        L.top = top[0];
        LuaLimits.lua_unlock(L);
        return name;
    }

    static void funcinfo(Lua.lua_Debug ar, LuaObject.Closure cl)
    {
        if (cl.c.getIsC() != 0) {
            ar.source = CLib.CharPtr.toCharPtr("=[C]");
            ar.linedefined = (-1);
            ar.lastlinedefined = (-1);
            ar.what = CLib.CharPtr.toCharPtr("C");
        } else {
            ar.source = LuaObject.getstr(cl.l.p.source);
            ar.linedefined = cl.l.p.linedefined;
            ar.lastlinedefined = cl.l.p.lastlinedefined;
            ar.what = ((ar.linedefined == 0) ? CLib.CharPtr.toCharPtr("main") : CLib.CharPtr.toCharPtr("Lua"));
        }
        LuaObject.luaO_chunkid(ar.short_src, ar.source, LuaConf.LUA_IDSIZE);
    }

    static void info_tailcall(Lua.lua_Debug ar)
    {
        ar.name = (ar.namewhat = CLib.CharPtr.toCharPtr(""));
        ar.what = CLib.CharPtr.toCharPtr("tail");
        ar.lastlinedefined = (ar.linedefined = (ar.currentline = (-1)));
        ar.source = CLib.CharPtr.toCharPtr("=(tail call)");
        LuaObject.luaO_chunkid(ar.short_src, ar.source, LuaConf.LUA_IDSIZE);
        ar.nups = 0;
    }

    static void collectvalidlines(LuaState.lua_State L, LuaObject.Closure f)
    {
        if ((f == null) || (f.c.getIsC() != 0)) {
            LuaObject.setnilvalue(L.top);
        } else {
            LuaObject.Table t = LuaTable.luaH_new(L, 0, 0);
            List<int> lineinfo = f.l.p.lineinfo;
            int i;
            for ((i = 0); i < f.l.p.sizelineinfo; i++) {
                LuaObject.setbvalue(LuaTable.luaH_setnum(L, t, lineinfo[i]), 1);
            }
            LuaObject.sethvalue(L, L.top, t);
        }
        LuaDo.incr_top(L);
    }

    static int auxgetinfo(LuaState.lua_State L, CLib.CharPtr what, Lua.lua_Debug ar, LuaObject.Closure f, LuaState.CallInfo ci)
    {
        int status = 1;
        if (f == null) {
            info_tailcall(ar);
            return status;
        }
        for (; what.get(0) != 0; (what = what.next())) {
            switch (what.get(0)) {
                case 'S'.codeUnitAt(0):
                    funcinfo(ar, f);
                    break;
                case 'l'.codeUnitAt(0):
                    ar.currentline = ((ci != null) ? currentline(L, ci) : (-1));
                    break;
                case 'u'.codeUnitAt(0):
                    ar.nups = f.c.getNupvalues();
                    break;
                case 'n'.codeUnitAt(0):
                    CLib.CharPtr[] name_ref = new CLib.CharPtr[1];
                    name_ref[0] = ar.name;
                    ar.namewhat = ((ci != null) ? getfuncname(L, ci, name_ref) : null);
                    ar.name = name_ref[0];
                    if (CLib.CharPtr.isEqual(ar.namewhat, null)) {
                        ar.namewhat = CLib.CharPtr.toCharPtr("");
                        ar.name = null;
                    }
                    break;
                case 'L'.codeUnitAt(0):
                case 'f'.codeUnitAt(0):
                    break;
                default:
                    status = 0;
                    break;
            }
        }
        return status;
    }

    static int lua_getinfo(LuaState.lua_State L, CLib.CharPtr what, Lua.lua_Debug ar)
    {
        int status;
        LuaObject.Closure f = null;
		    LuaState.CallInfo ci = null;
        LuaLimits.lua_lock(L);
        if (CLib.CharPtr.isEqualChar(what, '>'.codeUnitAt(0))) {
            LuaObject.TValue func = LuaObject.TValue.minus(L.top, 1); //StkId
            LuaConf.luai_apicheck(L, LuaObject.ttisfunction(func));
            what = what.next();
            f = LuaObject.clvalue(func);
            LuaObject.TValue[] top = new LuaObject.TValue[1];
            top[0] = L.top;
            LuaObject.TValue.dec(top);
            L.top = top[0];
        } else {
            if (ar.i_ci != 0) {
                ci = L.base_ci[ar.i_ci];
                LuaLimits.lua_assert(LuaObject.ttisfunction(ci.func));
                f = LuaObject.clvalue(ci.func);
            }
        }
        status = auxgetinfo(L, what, ar, f, ci);
        if (CLib.CharPtr.isNotEqual(CLib.strchr(what, 'f'.codeUnitAt(0)), null)) {
            if (f == null) {
                LuaObject.setnilvalue(L.top);
            } else {
                LuaObject.setclvalue(L, L.top, f);
            }
            LuaDo.incr_top(L);
        }
        if (CLib.CharPtr.isNotEqual(CLib.strchr(what, 'L'.codeUnitAt(0)), null)) {
            collectvalidlines(L, f);
        }
        LuaLimits.lua_unlock(L);
        return status;
    }

    static int checkjump(LuaObject.Proto pt, int pc)
    {
        if (!((0 <= pc) && (pc < pt.sizecode))) {
            return 0;
        }
        return 1;
    }

    static int checkreg(LuaObject.Proto pt, int reg)
    {
        if (!(reg < pt.maxstacksize)) {
            return 0;
        }
        return 1;
    }

    static int precheck(LuaObject.Proto pt)
    {
        if (!(pt.maxstacksize <= LuaLimits.MAXSTACK)) {
            return 0;
        }
        if (!((pt.numparams + (pt.is_vararg & LuaObject.VARARG_HASARG)) <= pt.maxstacksize)) {
            return 0;
        }
        if (!(((pt.is_vararg & LuaObject.VARARG_NEEDSARG) == 0) || ((pt.is_vararg & LuaObject.VARARG_HASARG) != 0))) {
            return 0;
        }
        if (!(pt.sizeupvalues <= pt.nups)) {
            return 0;
        }
        if (!((pt.sizelineinfo == pt.sizecode) || (pt.sizelineinfo == 0))) {
            return 0;
        }
        if (!((pt.sizecode > 0) && (LuaOpCodes.GET_OPCODE(pt.code[pt.sizecode - 1]) == LuaOpCodes.OpCode.OP_RETURN))) {
            return 0;
        }
        return 1;
    }

    static int checkopenop(LuaObject.Proto pt, int pc)
    {
        return luaG_checkopenop(pt.code[pc + 1]);
    }

    static int luaG_checkopenop(int i)
    {
        switch (LuaOpCodes.GET_OPCODE(i)) {
            case OP_CALL:
            case OP_TAILCALL:
            case OP_RETURN:
            case OP_SETLIST:
                if (!(LuaOpCodes.GETARG_B(i) == 0)) {
                    return 0;
                }
                return 1;
            default:
                return 0;
        }
    }

    static int checkArgMode(LuaObject.Proto pt, int r, LuaOpCodes.OpArgMask mode)
    {
        switch (mode) {
            case OpArgN:
                if (r != 0) {
                    return 0;
                }
                break;
            case OpArgU:
                break;
            case OpArgR:
                checkreg(pt, r);
                break;
            case OpArgK:
                if (!((LuaOpCodes.ISK(r) != 0) ? (LuaOpCodes.INDEXK(r) < pt.sizek) : (r < pt.maxstacksize))) {
                    return 0;
                }
                break;
        }
        return 1;
    }

    static int symbexec(LuaObject.Proto pt, int lastpc, int reg)
    {
        int pc;
        int last;
        int dest;
        last = (pt.sizecode - 1);
        if (precheck(pt) == 0) {
            return 0;
        }
        for ((pc = 0); pc < lastpc; pc++) {
            int i = pt.code[pc];
            LuaOpCodes.OpCode op = LuaOpCodes.GET_OPCODE(i);
            int a = LuaOpCodes.GETARG_A(i);
            int b = 0;
            int c = 0;
            if (!(op.getValue() < LuaOpCodes.NUM_OPCODES)) {
                return 0;
            }
            checkreg(pt, a);
            switch (LuaOpCodes.getOpMode(op)) {
                case iABC:
                    b = LuaOpCodes.GETARG_B(i);
                    c = LuaOpCodes.GETARG_C(i);
                    if (checkArgMode(pt, b, LuaOpCodes.getBMode(op)) == 0) {
                        return 0;
                    }
                    if (checkArgMode(pt, c, LuaOpCodes.getCMode(op)) == 0) {
                        return 0;
                    }
                    break;
                case iABx:
                    b = LuaOpCodes.GETARG_Bx(i);
                    if (LuaOpCodes.getBMode(op) == LuaOpCodes.OpArgMask.OpArgK) {
                        if (!(b < pt.sizek)) {
                            return 0;
                        }
                    }
                    break;
                case iAsBx:
                    b = LuaOpCodes.GETARG_sBx(i);
                    if (LuaOpCodes.getBMode(op) == LuaOpCodes.OpArgMask.OpArgR) {
                        dest = ((pc + 1) + b);
                        if (!((0 <= dest) && (dest < pt.sizecode))) {
                            return 0;
                        }
                        if (dest > 0) {
                            int j;
                            for ((j = 0); j < dest; j++) {
                                int d = pt.code[(dest - 1) - j];
                                if (!((LuaOpCodes.GET_OPCODE(d) == LuaOpCodes.OpCode.OP_SETLIST) && (LuaOpCodes.GETARG_C(d) == 0))) {
                                    break;
                                }
                            }
                            if ((j & 1) != 0) {
                                return 0;
                            }
                        }
                    }
                    break;
            }
            if (LuaOpCodes.testAMode(op) != 0) {
                if (a == reg) {
                    last = pc;
                }
            }
            if (LuaOpCodes.testTMode(op) != 0) {
                if (!((pc + 2) < pt.sizecode)) {
                    return 0;
                }
                if (!(LuaOpCodes.GET_OPCODE(pt.code[pc + 1]) == LuaOpCodes.OpCode.OP_JMP)) {
                    return 0;
                }
            }
            switch (op) {
                case OP_LOADBOOL:
                    if (c == 1) {
                        if (!((pc + 2) < pt.sizecode)) {
                            return 0;
                        }
                        if (!((LuaOpCodes.GET_OPCODE(pt.code[pc + 1]) != LuaOpCodes.OpCode.OP_SETLIST) || (LuaOpCodes.GETARG_C(pt.code[pc + 1]) != 0))) {
                            return 0;
                        }
                    }
                    break;
                case OP_LOADNIL:
                    if ((a <= reg) && (reg <= b)) {
                        last = pc;
                    }
                    break;
                case OP_GETUPVAL:
                case OP_SETUPVAL:
                    if (!(b < pt.nups)) {
                        return 0;
                    }
                    break;
                case OP_GETGLOBAL:
                case OP_SETGLOBAL:
                    if (!LuaObject.ttisstring(pt.k[b])) {
                        return 0;
                    }
                    break;
                case OP_SELF:
                    checkreg(pt, a + 1);
                    if (reg == (a + 1)) {
                        last = pc;
                    }
                    break;
                case OP_CONCAT:
                    if (!(b < c)) {
                        return 0;
                    }
                    break;
                case OP_TFORLOOP:
                    if (!(c >= 1)) {
                        return 0;
                    }
                    checkreg(pt, (a + 2) + c);
                    if (reg >= (a + 2)) {
                        last = pc;
                    }
                    break;
                case OP_FORLOOP:
                case OP_FORPREP:
                    checkreg(pt, a + 3);
                    dest = ((pc + 1) + b);
                    if (((reg != LuaOpCodes.NO_REG) && (pc < dest)) && (dest <= lastpc)) {
                        pc += b;
                    }
                    break;
                case OP_JMP:
                    dest = ((pc + 1) + b);
                    if (((reg != LuaOpCodes.NO_REG) && (pc < dest)) && (dest <= lastpc)) {
                        pc += b;
                    }
                    break;
                case OP_CALL:
                case OP_TAILCALL:
                    if (b != 0) {
                        checkreg(pt, (a + b) - 1);
                    }
                    c--;
                    if (c == Lua.LUA_MULTRET) {
                        if (checkopenop(pt, pc) == 0) {
                            return 0;
                        }
                    } else {
                        if (c != 0) {
                            checkreg(pt, (a + c) - 1);
                        }
                    }
                    if (reg >= a) {
                        last = pc;
                    }
                    break;
                case OP_RETURN:
                    b--;
                    if (b > 0) {
                        checkreg(pt, (a + b) - 1);
                    }
                    break;
                case OP_SETLIST:
                    if (b > 0) {
                        checkreg(pt, a + b);
                    }
                    if (c == 0) {
                        pc++;
                        if (!(pc < (pt.sizecode - 1))) {
                            return 0;
                        }
                    }
                    break;
                case OP_CLOSURE:
                    int nup;
                    int j;
                    if (!(b < pt.sizep)) {
                        return 0;
                    }
                    nup = pt.p[b].nups;
                    if (!((pc + nup) < pt.sizecode)) {
                        return 0;
                    }
                    for ((j = 1); j <= nup; j++) {
                        LuaOpCodes.OpCode op1 = LuaOpCodes.GET_OPCODE(pt.code[pc + j]);
                        if (!((op1 == LuaOpCodes.OpCode.OP_GETUPVAL) || (op1 == LuaOpCodes.OpCode.OP_MOVE))) {
                            return 0;
                        }
                    }
                    if (reg != LuaOpCodes.NO_REG) {
                        pc += nup;
                    }
                    break;
                case OP_VARARG:
                    if (!(((pt.is_vararg & LuaObject.VARARG_ISVARARG) != 0) && ((pt.is_vararg & LuaObject.VARARG_NEEDSARG) == 0))) {
                        return 0;
                    }
                    b--;
                    if (b == Lua.LUA_MULTRET) {
                        if (checkopenop(pt, pc) == 0) {
                            return 0;
                        }
                    }
                    checkreg(pt, (a + b) - 1);
                    break;
                default:
                    break;
            }
        }
        return pt.code[last];
    }

    static int luaG_checkcode(LuaObject.Proto pt)
    {
        return (symbexec(pt, pt.sizecode, LuaOpCodes.NO_REG) != 0) ? 1 : 0;
    }

    static CLib.CharPtr kname(LuaObject.Proto p, int c)
    {
        if ((LuaOpCodes.ISK(c) != 0) && LuaObject.ttisstring(p.k[LuaOpCodes.INDEXK(c)])) {
            return LuaObject.svalue(p.k[LuaOpCodes.INDEXK(c)]);
        } else {
            return CLib.CharPtr.toCharPtr("?");
        }
    }

    static CLib.CharPtr getobjname(LuaState.lua_State L, LuaState.CallInfo ci, int stackpos, List<CLib.CharPtr> name)
    {
        if (LuaState.isLua(ci)) {
            LuaObject.Proto p = LuaState.ci_func(ci).l.p;
            int pc = currentpc(L, ci);
            int i;
            name[0] = LuaFunc.luaF_getlocalname(p, stackpos + 1, pc);
            if (CLib.CharPtr.isNotEqual(name[0], null)) {
                return CLib.CharPtr.toCharPtr("local");
            }
            i = symbexec(p, pc, stackpos);
            LuaLimits.lua_assert(pc != (-1));
            switch (LuaOpCodes.GET_OPCODE(i)) {
                case OP_GETGLOBAL:
                    int g = LuaOpCodes.GETARG_Bx(i);
                    LuaLimits.lua_assert(LuaObject.ttisstring(p.k[g]));
                    name[0] = LuaObject.svalue(p.k[g]);
                    return CLib.CharPtr.toCharPtr("global");
                case OP_MOVE:
                    int a = LuaOpCodes.GETARG_A(i);
                    int b = LuaOpCodes.GETARG_B(i);
                    if (b < a) {
                        return getobjname(L, ci, b, name);
                    }
                    break;
                case OP_GETTABLE:
                    int k = LuaOpCodes.GETARG_C(i);
                    name[0] = kname(p, k);
                    return CLib.CharPtr.toCharPtr("field");
                case OP_GETUPVAL:
                    int u = LuaOpCodes.GETARG_B(i);
                    name[0] = ((p.upvalues != null) ? LuaObject.getstr(p.upvalues[u]) : CLib.CharPtr.toCharPtr("?"));
                    return CLib.CharPtr.toCharPtr("upvalue");
                case OP_SELF:
                    int k = LuaOpCodes.GETARG_C(i);
                    name[0] = kname(p, k);
                    return CLib.CharPtr.toCharPtr("method");
                default:
                    break;
            }
        }
        return null;
    }

    static CLib.CharPtr getfuncname(LuaState.lua_State L, LuaState.CallInfo ci, List<CLib.CharPtr> name)
    {
        int i;
        if ((LuaState.isLua(ci) && (ci.tailcalls > 0)) || (!LuaState.isLua(LuaState.CallInfo.minus(ci, 1)))) {
            return null;
        }
        LuaState.CallInfo[] ci_ref = new LuaState.CallInfo[1];
        ci_ref[0] = ci;
        LuaState.CallInfo.dec(ci_ref);
        ci = ci_ref[0];
        i = LuaState.ci_func(ci).l.p.code[currentpc(L, ci)];
        if (((LuaOpCodes.GET_OPCODE(i) == LuaOpCodes.OpCode.OP_CALL) || (LuaOpCodes.GET_OPCODE(i) == LuaOpCodes.OpCode.OP_TAILCALL)) || (LuaOpCodes.GET_OPCODE(i) == LuaOpCodes.OpCode.OP_TFORLOOP)) {
            return getobjname(L, ci, LuaOpCodes.GETARG_A(i), name);
        } else {
            return null;
        }
    }

    static int isinstack(LuaState.CallInfo ci, LuaObject.TValue o)
    {
        LuaObject.TValue[] p = new LuaObject.TValue[1]; //StkId
        p[0] = new LuaObject.TValue();
        for ((p[0] = ci.base_); LuaObject.TValue.lessThan(p[0], ci.top); LuaObject.TValue.inc(p)) {
            if (o == p[0]) {
                return 1;
            }
        }
        return 0;
    }

    static void luaG_typeerror(LuaState.lua_State L, LuaObject.TValue o, CLib.CharPtr op)
    {
        CLib.CharPtr name = null;
		    CLib.CharPtr t = LuaTM.luaT_typenames[LuaObject.ttype(o)];
		    CLib.CharPtr[] name_ref = new CLib.CharPtr[1];
        name_ref[0] = name;
        CLib.CharPtr kind = (isinstack(L.ci, o)) != 0 ? getobjname(L, L.ci, LuaLimits.cast_int(LuaObject.TValue.minus(o, L.base_)), name_ref) : null; //ref
        name = name_ref[0];
        if (CLib.CharPtr.isNotEqual(kind, null)) {
            luaG_runerror(L, CLib.CharPtr.toCharPtr(("attempt to %s %s " + LuaConf.getLUA_QS()) + " (a %s value)"), op, kind, name, t);
        } else {
            luaG_runerror(L, CLib.CharPtr.toCharPtr("attempt to %s a %s value"), op, t);
        }
    }

    static void luaG_concaterror(LuaState.lua_State L, LuaObject.TValue p1, LuaObject.TValue p2)
    {
        if (LuaObject.ttisstring(p1) || LuaObject.ttisnumber(p1)) {
            p1 = p2;
        }
        LuaLimits.lua_assert((!LuaObject.ttisstring(p1)) && (!LuaObject.ttisnumber(p1)));
        luaG_typeerror(L, p1, CLib.CharPtr.toCharPtr("concatenate"));
    }

    static void luaG_aritherror(LuaState.lua_State L, LuaObject.TValue p1, LuaObject.TValue p2)
    {
        LuaObject.TValue temp = new LuaObject.TValue();
        if (LuaVM.luaV_tonumber(p1, temp) == null) {
            p2 = p1;
        }
        luaG_typeerror(L, p2, CLib.CharPtr.toCharPtr("perform arithmetic on"));
    }

    static int luaG_ordererror(LuaState.lua_State L, LuaObject.TValue p1, LuaObject.TValue p2)
    {
        CLib.CharPtr t1 = LuaTM.luaT_typenames[LuaObject.ttype(p1)];
		    CLib.CharPtr t2 = LuaTM.luaT_typenames[LuaObject.ttype(p2)];
        if (t1.get(2) == t2.get(2)) {
            luaG_runerror(L, CLib.CharPtr.toCharPtr("attempt to compare two %s values"), t1);
        } else {
            luaG_runerror(L, CLib.CharPtr.toCharPtr("attempt to compare %s with %s"), t1, t2);
        }
        return 0;
    }

    static void addinfo(LuaState.lua_State L, CLib.CharPtr msg)
    {
        LuaState.CallInfo ci = L.ci;
        if (LuaState.isLua(ci)) {
            CLib.CharPtr buff = new CLib.CharPtr(new char[LuaConf.LUA_IDSIZE]); // add file:line information
            int line = currentline(L, ci);
            LuaObject.luaO_chunkid(buff, LuaObject.getstr(getluaproto(ci).source), LuaConf.LUA_IDSIZE);
            LuaObject.luaO_pushfstring(L, CLib.CharPtr.toCharPtr("%s:%d: %s"), buff, line, msg);
        }
    }

    static void luaG_errormsg(LuaState.lua_State L)
    {
        if (L.errfunc != 0) {
            LuaObject.TValue errfunc = LuaDo.restorestack(L, L.errfunc); //StkId
            if (!LuaObject.ttisfunction(errfunc)) {
                LuaDo.luaD_throw(L, Lua.LUA_ERRERR);
            }
            LuaObject.setobjs2s(L, L.top, LuaObject.TValue.minus(L.top, 1));
            LuaObject.setobjs2s(L, LuaObject.TValue.minus(L.top, 1), errfunc);
            LuaDo.incr_top(L);
            LuaDo.luaD_call(L, LuaObject.TValue.minus(L.top, 2), 1);
        }
        LuaDo.luaD_throw(L, Lua.LUA_ERRRUN);
    }

    static void luaG_runerror(LuaState.lua_State L, CLib.CharPtr fmt, List<Object> argp /*XXX*/)
    {
        addinfo(L, LuaObject.luaO_pushvfstring(L, fmt, argp));
        luaG_errormsg(L);
    }
}
