library kurumi;

class LuaGC
{
    static const int GCSpause = 0;
    static const int GCSpropagate = 1;
    static const int GCSsweepstring = 2;
    static const int GCSsweep = 3;
    static const int GCSfinalize = 4;

    static int resetbits(List<int> x, int m)
    {
        x[0] &= (~m);
        return x[0];
    }

    static int setbits(List<int> x, int m)
    {
        x[0] |= m;
        return x[0];
    }

    static bool testbits(int x, int m)
    {
        return (x & m) != 0;
    }

    static int bitmask(int b)
    {
        return 1 << b;
    }

    static int bit2mask(int b1, int b2)
    {
        return bitmask(b1) | bitmask(b2);
    }

    static int l_setbit(List<int> x, int b)
    {
        return setbits(x, bitmask(b));
    }

    static int resetbit(List<int> x, int b)
    {
        return resetbits(x, bitmask(b));
    }

    static bool testbit(int x, int b)
    {
        return testbits(x, bitmask(b));
    }

    static int set2bits(List<int> x, int b1, int b2)
    {
        return setbits(x, bit2mask(b1, b2));
    }

    static int reset2bits(List<int> x, int b1, int b2)
    {
        return resetbits(x, bit2mask(b1, b2));
    }

    static bool test2bits(int x, int b1, int b2)
    {
        return testbits(x, bit2mask(b1, b2));
    }
    static const int WHITE0BIT = 0;
    static const int WHITE1BIT = 1;
    static const int BLACKBIT = 2;
    static const int FINALIZEDBIT = 3;
    static const int KEYWEAKBIT = 3;
    static const int VALUEWEAKBIT = 4;
    static const int FIXEDBIT = 5;
    static const int SFIXEDBIT = 6;
    static const int WHITEBITS = bit2mask(WHITE0BIT, WHITE1BIT);

    static bool iswhite(LuaState.GCObject x)
    {
        return test2bits(x.getGch().marked, WHITE0BIT, WHITE1BIT);
    }

    static bool isblack(LuaState.GCObject x)
    {
        return testbit(x.getGch().marked, BLACKBIT);
    }

    static bool isgray(LuaState.GCObject x)
    {
        return (!isblack(x)) && (!iswhite(x));
    }

    static int otherwhite(LuaState.global_State g)
    {
        return g.currentwhite ^ WHITEBITS;
    }

    static bool isdead(LuaState.global_State g, LuaState.GCObject v)
    {
        return ((v.getGch().marked & otherwhite(g)) & WHITEBITS) != 0;
    }

    static void changewhite(LuaState.GCObject x)
    {
        x.getGch().marked ^= (byte)WHITEBITS;
    }

    static void gray2black(LuaState.GCObject x)
    {
        List<int> marked_ref = new List<int>(1);
        LuaObject.GCheader gcheader = x.getGch();
        marked_ref[0] = gcheader.marked;
        l_setbit(marked_ref, BLACKBIT);
        gcheader.marked = marked_ref[0];
    }

    static bool valiswhite(LuaObject.TValue x)
    {
        return LuaObject.iscollectable(x) && iswhite(LuaObject.gcvalue(x));
    }

    static int luaC_white(LuaState.global_State g)
    {
        return g.currentwhite & WHITEBITS;
    }

    static void luaC_checkGC(LuaState.lua_State L)
    {
        if (LuaState.G(L).totalbytes >= LuaState.G(L).GCthreshold) {
            luaC_step(L);
        }
    }

    static void luaC_barrier(LuaState.lua_State L, Object p, LuaObject.TValue v)
    {
        if (valiswhite(v) && isblack(LuaState.obj2gco(p))) {
            luaC_barrierf(L, LuaState.obj2gco(p), LuaObject.gcvalue(v));
        }
    }

    static void luaC_barriert(LuaState.lua_State L, LuaObject.Table t, LuaObject.TValue v)
    {
        if (valiswhite(v) && isblack(LuaState.obj2gco(t))) {
            luaC_barrierback(L, t);
        }
    }

    static void luaC_objbarrier(LuaState.lua_State L, Object p, Object o)
    {
        if (iswhite(LuaState.obj2gco(o)) && isblack(LuaState.obj2gco(p))) {
            luaC_barrierf(L, LuaState.obj2gco(p), LuaState.obj2gco(o));
        }
    }

    static void luaC_objbarriert(LuaState.lua_State L, LuaObject.Table t, Object o)
    {
        if (iswhite(LuaState.obj2gco(o)) && isblack(LuaState.obj2gco(t))) {
            luaC_barrierback(L, t);
        }
    }
    static const int GCSTEPSIZE = 1024;
    static const int GCSWEEPMAX = 40;
    static const int GCSWEEPCOST = 10;
    static const int GCFINALIZECOST = 100;
    static int maskmarks = (~(bitmask(BLACKBIT) | WHITEBITS));

    static void makewhite(LuaState.global_State g, LuaState.GCObject x)
    {
        x.getGch().marked = ((x.getGch().marked & maskmarks) | luaC_white(g));
    }

    static void white2gray(LuaState.GCObject x)
    {
        List<int> marked_ref = new List<int>(1);
        LuaObject.GCheader gcheader = x.getGch();
        marked_ref[0] = gcheader.marked;
        reset2bits(marked_ref, WHITE0BIT, WHITE1BIT);
        gcheader.marked = marked_ref[0];
    }

    static void black2gray(LuaState.GCObject x)
    {
        List<int> marked_ref = new List<int>(1);
        LuaObject.GCheader gcheader = x.getGch();
        marked_ref[0] = gcheader.marked;
        resetbit(marked_ref, BLACKBIT);
        gcheader.marked = marked_ref[0];
    }

    static void stringmark(LuaObject.TString s)
    {
        List<int> marked_ref = new List<int>(1);
        LuaObject.GCheader gcheader = s.getGch();
        marked_ref[0] = gcheader.marked;
        reset2bits(marked_ref, WHITE0BIT, WHITE1BIT);
        gcheader.marked = marked_ref[0];
    }

    static bool isfinalized(LuaObject.Udata_uv u)
    {
        return testbit(u.marked, FINALIZEDBIT);
    }

    static void markfinalized(LuaObject.Udata_uv u)
    {
        int marked = u.marked;
        List<int> marked_ref = new List<int>(1);
        marked_ref[0] = marked;
        l_setbit(marked_ref, FINALIZEDBIT);
        marked = marked_ref[0];
        u.marked = marked;
    }
    static int KEYWEAK = bitmask(KEYWEAKBIT);
    static int VALUEWEAK = bitmask(VALUEWEAKBIT);

    static void markvalue(LuaState.global_State g, LuaObject.TValue o)
    {
        LuaObject.checkconsistency(o);
        if (LuaObject.iscollectable(o) && iswhite(LuaObject.gcvalue(o))) {
            reallymarkobject(g, LuaObject.gcvalue(o));
        }
    }

    static void markobject(LuaState.global_State g, Object t)
    {
        if (iswhite(LuaState.obj2gco(t))) {
            reallymarkobject(g, LuaState.obj2gco(t));
        }
    }

    static void setthreshold(LuaState.global_State g)
    {
        g.GCthreshold = ((g.estimate ~/ 100) * g.gcpause);
    }

    static void removeentry(LuaObject.Node n)
    {
        LuaLimits.lua_assert(LuaObject.ttisnil(LuaTable.gval(n)));
        if (LuaObject.iscollectable(LuaTable.gkey(n))) {
            LuaObject.setttype(LuaTable.gkey(n), LuaObject.LUA_TDEADKEY);
        }
    }

    static void reallymarkobject(LuaState.global_State g, LuaState.GCObject o)
    {
        LuaLimits.lua_assert(iswhite(o) && (!isdead(g, o)));
        white2gray(o);
        switch (o.getGch().tt) {
            case Lua.LUA_TSTRING:
                return;
            case Lua.LUA_TUSERDATA:
                LuaObject.Table mt = LuaState.gco2u(o).metatable;
                gray2black(o);
                if (mt != null) {
                    markobject(g, mt);
                }
                markobject(g, LuaState.gco2u(o).env);
                return;
            case LuaObject.LUA_TUPVAL:
                LuaObject.UpVal uv = LuaState.gco2uv(o);
                markvalue(g, uv.v);
                if (uv.v == uv.u.value) {
                    gray2black(o);
                }
                return;
            case Lua.LUA_TFUNCTION:
                LuaState.gco2cl(o).c.setGclist(g.gray);
                g.gray = o;
                break;
            case Lua.LUA_TTABLE:
                LuaState.gco2h(o).gclist = g.gray;
                g.gray = o;
                break;
            case Lua.LUA_TTHREAD:
                LuaState.gco2th(o).gclist = g.gray;
                g.gray = o;
                break;
            case LuaObject.LUA_TPROTO:
                LuaState.gco2p(o).gclist = g.gray;
                g.gray = o;
                break;
            default:
                LuaLimits.lua_assert(0);
                break;
        }
    }

    static void marktmu(LuaState.global_State g)
    {
        LuaState.GCObject u = g.tmudata;
        if (u != null) {
            do {
                u = u.getGch().next;
                makewhite(g, u);
                reallymarkobject(g, u);
            } while (u != g.tmudata);
        }
    }

    static int luaC_separateudata(LuaState.lua_State L, int all)
    {
        LuaState.global_State g = LuaState.G(L);
        int deadmem = 0;
        LuaState.GCObjectRef p = new LuaState.NextRef(g.mainthread);
		    LuaState.GCObject curr;
        while ((curr = p.get()) != null) {
            if ((!(iswhite(curr) || (all != 0))) || isfinalized(LuaState.gco2u(curr))) {
                p = new LuaState.NextRef(curr.getGch());
            } else {
                if (LuaTM.fasttm(L, LuaState.gco2u(curr).metatable, LuaTM.TMS.TM_GC) == null) {
                    markfinalized(LuaState.gco2u(curr));
                    p = new LuaState.NextRef(curr.getGch());
                } else {
                    deadmem += LuaString.sizeudata(LuaState.gco2u(curr));
                    markfinalized(LuaState.gco2u(curr));
                    p.set(curr.getGch().next);
                    if (g.tmudata == null) {
                        g.tmudata = (curr.getGch().next = curr);
                    } else {
                        curr.getGch().next = g.tmudata.getGch().next;
                        g.tmudata.getGch().next = curr;
                        g.tmudata = curr;
                    }
                }
            }
        }
        return deadmem;
    }

    static int traversetable(LuaState.global_State g, LuaObject.Table h)
    {
        int i;
        int weakkey = 0;
        int weakvalue = 0;
        LuaObject.TValue mode;
        if (h.metatable != null) {
            markobject(g, h.metatable);
        }
        mode = LuaTM.gfasttm(g, h.metatable, LuaTM.TMS.TM_MODE);
        if ((mode != null) && LuaObject.ttisstring(mode)) {
            weakkey = (CLib.CharPtr.isNotEqual(CLib.strchr(LuaObject.svalue(mode), 'k'.codeUnitAt(0)), null) ? 1 : 0);
            weakvalue = (CLib.CharPtr.isNotEqual(CLib.strchr(LuaObject.svalue(mode), 'v'.codeUnitAt(0)), null) ? 1 : 0);
            if ((weakkey != 0) || (weakvalue != 0)) {
                h.marked &= (~(KEYWEAK | VALUEWEAK));
                h.marked |= LuaLimits.cast_byte((weakkey << KEYWEAKBIT) | (weakvalue << VALUEWEAKBIT));
                h.gclist = g.weak;
                g.weak = LuaState.obj2gco(h);
            }
        }
        if ((weakkey != 0) && (weakvalue != 0)) {
            return 1;
        }
        if (weakvalue == 0) {
            i = h.sizearray;
            while (i-- != 0) {
                markvalue(g, h.array[i]);
            }
        }
        i = LuaObject.sizenode(h);
        while (i-- != 0) {
            LuaObject.Node n = LuaTable.gnode(h, i);
            LuaLimits.lua_assert((LuaObject.ttype(LuaTable.gkey(n)) != LuaObject.LUA_TDEADKEY) || LuaObject.ttisnil(LuaTable.gval(n)));
            if (LuaObject.ttisnil(LuaTable.gval(n))) {
                removeentry(n);
            } else {
                LuaLimits.lua_assert(LuaObject.ttisnil(LuaTable.gkey(n)));
                if (weakkey == 0) {
                    markvalue(g, LuaTable.gkey(n));
                }
                if (weakvalue == 0) {
                    markvalue(g, LuaTable.gval(n));
                }
            }
        }
        return ((weakkey != 0) || (weakvalue != 0)) ? 1 : 0;
    }

    static void traverseproto(LuaState.global_State g, LuaObject.Proto f)
    {
        int i;
        if (f.source != null) {
            stringmark(f.source);
        }
        for ((i = 0); i < f.sizek; i++) {
            markvalue(g, f.k[i]);
        }
        for ((i = 0); i < f.sizeupvalues; i++) {
            if (f.upvalues[i] != null) {
                stringmark(f.upvalues[i]);
            }
        }
        for ((i = 0); i < f.sizep; i++) {
            if (f.p[i] != null) {
                markobject(g, f.p[i]);
            }
        }
        for ((i = 0); i < f.sizelocvars; i++) {
            if (f.locvars[i].varname != null) {
                stringmark(f.locvars[i].varname);
            }
        }
    }

    static void traverseclosure(LuaState.global_State g, LuaObject.Closure cl)
    {
        markobject(g, cl.c.getEnv());
        if (cl.c.getIsC() != 0) {
            int i;
            for ((i = 0); i < cl.c.getNupvalues(); i++) {
                markvalue(g, cl.c.upvalue[i]);
            }
        } else {
            int i;
            LuaLimits.lua_assert(cl.l.getNupvalues() == cl.l.p.nups);
            markobject(g, cl.l.p);
            for ((i = 0); i < cl.l.getNupvalues(); i++) {
                markobject(g, cl.l.upvals[i]);
            }
        }
    }

    static void checkstacksizes(LuaState.lua_State L, LuaObject.TValue max)
    {
        int ci_used = LuaLimits.cast_int(LuaState.CallInfo.minus(L.ci, L.base_ci[0]));
        int s_used = LuaLimits.cast_int(LuaObject.TValue.minus(max, L.stack));
        if (L.size_ci > LuaConf.LUAI_MAXCALLS) {
            return;
        }
        if (((4 * ci_used) < L.size_ci) && ((2 * LuaState.BASIC_CI_SIZE) < L.size_ci)) {
            LuaDo.luaD_reallocCI(L, L.size_ci ~/ 2);
        }
        if (((4 * s_used) < L.stacksize) && ((2 * (LuaState.BASIC_STACK_SIZE + LuaState.EXTRA_STACK)) < L.stacksize)) {
            LuaDo.luaD_reallocstack(L, L.stacksize ~/ 2);
        }
    }

    static void traversestack(LuaState.global_State g, LuaState.lua_State l)
    {
        LuaObject.TValue[] o = new LuaObject.TValue[1]; //StkId
        o[0] = new LuaObject.TValue();
        LuaObject.TValue lim; //StkId
		    LuaState.CallInfo[] ci = new LuaState.CallInfo[1];
        ci[0] = new LuaState.CallInfo();
        markvalue(g, LuaState.gt(l));
        lim = l.top;
        for ((ci[0] = l.base_ci[0]); LuaState.CallInfo.lessEqual(ci[0], l.ci); LuaState.CallInfo.inc(ci)) {
            LuaLimits.lua_assert(LuaObject.TValue.lessEqual(ci[0].top, l.stack_last));
            if (LuaObject.TValue.lessThan(lim, ci[0].top)) {
                lim = ci[0].top;
            }
        }
        for ((o[0] = l.stack[0]); LuaObject.TValue.lessThan(o[0], l.top); LuaObject.TValue.inc(o)) {
            markvalue(g, o[0]);
        }
        for (; LuaObject.TValue.lessEqual(o[0], lim); LuaObject.TValue.inc(o)) {
            LuaObject.setnilvalue(o[0]);
        }
        checkstacksizes(l, lim);
    }

    static int propagatemark(LuaState.global_State g)
    {
        LuaState.GCObject o = g.gray;
        LuaLimits.lua_assert(isgray(o));
        gray2black(o);
        switch (o.getGch().tt) {
            case Lua.LUA_TTABLE:
                LuaObject.Table h = LuaState.gco2h(o);
                g.gray = h.gclist;
                if (traversetable(g, h) != 0) {
                    black2gray(o);
                }
                return (CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_TABLE)) + (CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_TVALUE)) * h.sizearray)) + (CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_NODE)) * LuaObject.sizenode(h));
            case Lua.LUA_TFUNCTION:
                LuaObject.Closure cl = LuaState.gco2cl(o);
                g.gray = cl.c.getGclist();
                traverseclosure(g, cl);
                return (cl.c.getIsC() != 0) ? LuaFunc.sizeCclosure(cl.c.getNupvalues()) : LuaFunc.sizeLclosure(cl.l.getNupvalues());
            case Lua.LUA_TTHREAD:
                LuaState.lua_State th = LuaState.gco2th(o);
                g.gray = th.gclist;
                th.gclist = g.grayagain;
                g.grayagain = o;
                black2gray(o);
                traversestack(g, th);
                return (CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_LUA_STATE)) + (CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_TVALUE)) * th.stacksize)) + (CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_CALLINFO)) * th.size_ci);
            case LuaObject.LUA_TPROTO:
                LuaObject.Proto p = LuaState.gco2p(o);
                g.gray = p.gclist;
                traverseproto(g, p);
                return (((((CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_PROTO)) + (CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_LONG)) * p.sizecode)) + (CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_PROTO)) * p.sizep)) + (CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_TVALUE)) * p.sizek)) + (CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_INT)) * p.sizelineinfo)) + (CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_LOCVAR)) * p.sizelocvars)) + (CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_TSTRING)) * p.sizeupvalues);
            default:
                LuaLimits.lua_assert(0);
                return 0;
        }
    }

    static int propagateall(LuaState.global_State g)
    {
        int m = 0;
        while (g.gray != null) {
            m += propagatemark(g);
        }
        return m;
    }

    static bool iscleared(LuaObject.TValue o, bool iskey)
    {
        if (!LuaObject.iscollectable(o)) {
            return false;
        }
        if (LuaObject.ttisstring(o)) {
            stringmark(LuaObject.rawtsvalue(o));
            return false;
        }
        return iswhite(LuaObject.gcvalue(o)) || (LuaObject.ttisuserdata(o) && ((!iskey) && isfinalized(LuaObject.uvalue(o))));
    }

    static void cleartable(LuaState.GCObject l)
    {
        while (l != null) {
            LuaObject.Table h = LuaState.gco2h(l);
            int i = h.sizearray;
            LuaLimits.lua_assert(testbit(h.marked, VALUEWEAKBIT) || testbit(h.marked, KEYWEAKBIT));
            if (testbit(h.marked, VALUEWEAKBIT)) {
                while (i-- != 0) {
                    LuaObject.TValue o = h.array[i];
                    if (iscleared(o, false)) {
                        LuaObject.setnilvalue(o);
                    }
                }
            }
            i = LuaObject.sizenode(h);
            while (i-- != 0) {
                LuaObject.Node n = LuaTable.gnode(h, i);
                if ((!LuaObject.ttisnil(LuaTable.gval(n))) && (iscleared(LuaTable.key2tval(n), true) || iscleared(LuaTable.gval(n), false))) {
                    LuaObject.setnilvalue(LuaTable.gval(n));
                    removeentry(n);
                }
            }
            l = h.gclist;
        }
    }

    static void freeobj(LuaState.lua_State L, LuaState.GCObject o)
    {
        switch (o.getGch().tt) {
            case LuaObject.LUA_TPROTO:
                LuaFunc.luaF_freeproto(L, LuaState.gco2p(o));
                break;
            case Lua.LUA_TFUNCTION:
                LuaFunc.luaF_freeclosure(L, LuaState.gco2cl(o));
                break;
            case LuaObject.LUA_TUPVAL:
                LuaFunc.luaF_freeupval(L, LuaState.gco2uv(o));
                break;
            case Lua.LUA_TTABLE:
                LuaTable.luaH_free(L, LuaState.gco2h(o));
                break;
            case Lua.LUA_TTHREAD:
                LuaLimits.lua_assert((LuaState.gco2th(o) != L) && (LuaState.gco2th(o) != LuaState.G(L).mainthread));
                LuaState.luaE_freethread(L, LuaState.gco2th(o));
                break;
            case Lua.LUA_TSTRING:
                LuaState.G(L).strt.nuse--;
                LuaMem.SubtractTotalBytes(L, LuaString.sizestring(LuaState.gco2ts(o)));
                LuaMem.luaM_freemem_TString(L, LuaState.gco2ts(o), new ClassType(ClassType_.TYPE_TSTRING));
                break;
            case Lua.LUA_TUSERDATA:
                LuaMem.SubtractTotalBytes(L, LuaString.sizeudata(LuaState.gco2u(o)));
                LuaMem.luaM_freemem_Udata(L, LuaState.gco2u(o), new ClassType(ClassType_.TYPE_UDATA));
                break;
            default:
                LuaLimits.lua_assert(0);
                break;
        }
    }

    static void sweepwholelist(LuaState.lua_State L, LuaState.GCObjectRef p)
    {
        sweeplist(L, p, LuaLimits.MAX_LUMEM);
    }

    static LuaState.GCObjectRef sweeplist(LuaState.lua_State L, LuaState.GCObjectRef p, int count)
    {
        LuaState.GCObject curr;
		    LuaState.global_State g = LuaState.G(L);
        int deadmask = otherwhite(g);
        while (((curr = p.get()) != null) && (count-- > 0)) {
            if (curr.getGch().tt == Lua.LUA_TTHREAD) {
                sweepwholelist(L, new LuaState.OpenValRef(LuaState.gco2th(curr)));
            }
            if (((curr.getGch().marked ^ WHITEBITS) & deadmask) != 0) {
                LuaLimits.lua_assert(isdead(g, curr) || testbit(curr.getGch().marked, FIXEDBIT));
                makewhite(g, curr);
                p = new LuaState.NextRef(curr.getGch());
            } else {
                LuaLimits.lua_assert(isdead(g, curr) || (deadmask == bitmask(SFIXEDBIT)));
                p.set(curr.getGch().next);
                if (curr == g.rootgc) {
                    g.rootgc = curr.getGch().next;
                }
                freeobj(L, curr);
            }
        }
        return p;
    }

    static void checkSizes(LuaState.lua_State L)
    {
        LuaState.global_State g = LuaState.G(L);
        if ((g.strt.nuse < (g.strt.size ~/ 4)) && (g.strt.size > (LuaLimits.MINSTRTABSIZE * 2))) {
            LuaString.luaS_resize(L, g.strt.size ~/ 2);
        }
        if (LuaZIO.luaZ_sizebuffer(g.buff) > (LuaLimits.LUA_MINBUFFER * 2)) {
            int newsize = (LuaZIO.luaZ_sizebuffer(g.buff) ~/ 2);
            LuaZIO.luaZ_resizebuffer(L, g.buff, newsize);
        }
    }

    static void GCTM(LuaState.lua_State L)
    {
        LuaState.global_State g = LuaState.G(L);
		    LuaState.GCObject o = g.tmudata.getGch().next; // get first element 
		    LuaObject.Udata udata = LuaState.rawgco2u(o);
		    LuaObject.TValue tm;
        if (o == g.tmudata) {
            g.tmudata = null;
        } else {
            g.tmudata.getGch().next = udata.uv.next;
        }
        udata.uv.next = g.mainthread.next;
        g.mainthread.next = o;
        makewhite(g, o);
        tm = LuaTM.fasttm(L, udata.uv.metatable, LuaTM.TMS.TM_GC);
        if (tm != null) {
            int oldah = L.allowhook;
            int oldt = g.GCthreshold;
            L.allowhook = 0;
            g.GCthreshold = (2 * g.totalbytes);
            LuaObject.setobj2s(L, L.top, tm);
            LuaObject.setuvalue(L, LuaObject.TValue.plus(L.top, 1), udata);
            L.top = LuaObject.TValue.plus(L.top, 2);
            LuaDo.luaD_call(L, LuaObject.TValue.minus(L.top, 2), 0);
            L.allowhook = oldah;
            g.GCthreshold = oldt;
        }
    }

    static void luaC_callGCTM(LuaState.lua_State L)
    {
        while (LuaState.G(L).tmudata != null) {
            GCTM(L);
        }
    }

    static void luaC_freeall(LuaState.lua_State L)
    {
        LuaState.global_State g = LuaState.G(L);
        int i;
        g.currentwhite = (WHITEBITS | bitmask(SFIXEDBIT));
        sweepwholelist(L, new LuaState.RootGCRef(g));
        for ((i = 0); i < g.strt.size; i++) {
            sweepwholelist(L, new LuaState.ArrayRef(g.strt.hash, i));
        }
    }

    static void markmt(LuaState.global_State g)
    {
        int i;
        for ((i = 0); i < LuaObject.NUM_TAGS; i++) {
            if (g.mt[i] != null) {
                markobject(g, g.mt[i]);
            }
        }
    }

    static void markroot(LuaState.lua_State L)
    {
        LuaState.global_State g = LuaState.G(L);
        g.gray = null;
        g.grayagain = null;
        g.weak = null;
        markobject(g, g.mainthread);
        markvalue(g, LuaState.gt(g.mainthread));
        markvalue(g, LuaState.registry(L));
        markmt(g);
        g.gcstate = GCSpropagate;
    }

    static void remarkupvals(LuaState.global_State g)
    {
        LuaObject.UpVal uv;
        for ((uv = g.uvhead.u.l.next); uv != g.uvhead; (uv = uv.u.l.next)) {
            LuaLimits.lua_assert((uv.u.l.next.u.l.prev == uv) && (uv.u.l.prev.u.l.next == uv));
            if (isgray(LuaState.obj2gco(uv))) {
                markvalue(g, uv.v);
            }
        }
    }

    static void atomic(LuaState.lua_State L)
    {
        LuaState.global_State g = LuaState.G(L);
        int udsize;
        remarkupvals(g);
        propagateall(g);
        g.gray = g.weak;
        g.weak = null;
        LuaLimits.lua_assert(!iswhite(LuaState.obj2gco(g.mainthread)));
        markobject(g, L);
        markmt(g);
        propagateall(g);
        g.gray = g.grayagain;
        g.grayagain = null;
        propagateall(g);
        udsize = luaC_separateudata(L, 0);
        marktmu(g);
        udsize += propagateall(g);
        cleartable(g.weak);
        g.currentwhite = LuaLimits.cast_byte(otherwhite(g));
        g.sweepstrgc = 0;
        g.sweepgc = new LuaState.RootGCRef(g);
        g.gcstate = GCSsweepstring;
        g.estimate = (g.totalbytes - udsize);
    }

    static int singlestep(LuaState.lua_State L)
    {
        LuaState.global_State g = LuaState.G(L);
        switch (g.gcstate) {
            case GCSpause:
                markroot(L);
                return 0;
            case GCSpropagate:
                if (g.gray != null) {
                    return propagatemark(g);
                } else {
                    atomic(L);
                    return 0;
                }
            case GCSsweepstring:
                int old = g.totalbytes;
                sweepwholelist(L, new LuaState.ArrayRef(g.strt.hash, g.sweepstrgc++));
                if (g.sweepstrgc >= g.strt.size) {
                    g.gcstate = GCSsweep;
                }
                LuaLimits.lua_assert(old >= g.totalbytes);
                g.estimate -= (old - g.totalbytes);
                return GCSWEEPCOST;
            case GCSsweep:
                int old = g.totalbytes;
                g.sweepgc = sweeplist(L, g.sweepgc, GCSWEEPMAX);
                if (g.sweepgc.get() == null) {
                    checkSizes(L);
                    g.gcstate = GCSfinalize;
                }
                LuaLimits.lua_assert(old >= g.totalbytes);
                g.estimate -= (old - g.totalbytes);
                return GCSWEEPMAX * GCSWEEPCOST;
            case GCSfinalize:
                if (g.tmudata != null) {
                    GCTM(L);
                    if (g.estimate > GCFINALIZECOST) {
                        g.estimate -= GCFINALIZECOST;
                    }
                    return GCFINALIZECOST;
                } else {
                    g.gcstate = GCSpause;
                    g.gcdept = 0;
                    return 0;
                }
            default:
                LuaLimits.lua_assert(0);
                return 0;
        }
    }

    static void luaC_step(LuaState.lua_State L)
    {
        LuaState.global_State g = LuaState.G(L);
        int lim = ((GCSTEPSIZE ~/ 100) * g.gcstepmul);
        if (lim == 0) {
            lim = ((LuaLimits.MAX_LUMEM - 1) ~/ 2);
        }
        g.gcdept += (g.totalbytes - g.GCthreshold);
        do {
            lim -= singlestep(L);
            if (g.gcstate == GCSpause) {
                break;
            }
        } while (lim > 0);
        if (g.gcstate != GCSpause) {
            if (g.gcdept < GCSTEPSIZE) {
                g.GCthreshold = (g.totalbytes + GCSTEPSIZE);
            } else {
                g.gcdept -= GCSTEPSIZE;
                g.GCthreshold = g.totalbytes;
            }
        } else {
            LuaLimits.lua_assert(g.totalbytes >= g.estimate);
            setthreshold(g);
        }
    }

    static void luaC_fullgc(LuaState.lua_State L)
    {
        LuaState.global_State g = LuaState.G(L);
        if (g.gcstate <= GCSpropagate) {
            g.sweepstrgc = 0;
            g.sweepgc = new LuaState.RootGCRef(g);
            g.gray = null;
            g.grayagain = null;
            g.weak = null;
            g.gcstate = GCSsweepstring;
        }
        LuaLimits.lua_assert((g.gcstate != GCSpause) && (g.gcstate != GCSpropagate));
        while (g.gcstate != GCSfinalize) {
            LuaLimits.lua_assert((g.gcstate == GCSsweepstring) || (g.gcstate == GCSsweep));
            singlestep(L);
        }
        markroot(L);
        while (g.gcstate != GCSpause) {
            singlestep(L);
        }
        setthreshold(g);
    }

    static void luaC_barrierf(LuaState.lua_State L, LuaState.GCObject o, LuaState.GCObject v)
    {
        LuaState.global_State g = LuaState.G(L);
        LuaLimits.lua_assert(((isblack(o) && iswhite(v)) && (!isdead(g, v))) && (!isdead(g, o)));
        LuaLimits.lua_assert((g.gcstate != GCSfinalize) && (g.gcstate != GCSpause));
        LuaLimits.lua_assert(LuaObject.ttype(o.getGch()) != Lua.LUA_TTABLE);
        if (g.gcstate == GCSpropagate) {
            reallymarkobject(g, v);
        } else {
            makewhite(g, o);
        }
    }

    static void luaC_barrierback(LuaState.lua_State L, LuaObject.Table t)
    {
        LuaState.global_State g = LuaState.G(L);
		    LuaState.GCObject o = LuaState.obj2gco(t);
        LuaLimits.lua_assert(isblack(o) && (!isdead(g, o)));
        LuaLimits.lua_assert((g.gcstate != GCSfinalize) && (g.gcstate != GCSpause));
        black2gray(o);
        t.gclist = g.grayagain;
        g.grayagain = o;
    }

    static void luaC_link(LuaState.lua_State L, LuaState.GCObject o, int tt)
    {
        LuaState.global_State g = LuaState.G(L);
        o.getGch().next = g.rootgc;
        g.rootgc = o;
        o.getGch().marked = luaC_white(g);
        o.getGch().tt = tt;
    }

    static void luaC_linkupval(LuaState.lua_State L, LuaObject.UpVal uv)
    {
        LuaState.global_State g = LuaState.G(L);
		    LuaState.GCObject o = LuaState.obj2gco(uv);
        o.getGch().next = g.rootgc;
        g.rootgc = o;
        if (isgray(o)) {
            if (g.gcstate == GCSpropagate) {
                gray2black(o);
                luaC_barrier(L, uv, uv.v);
            } else {
                makewhite(g, o);
                LuaLimits.lua_assert((g.gcstate != GCSfinalize) && (g.gcstate != GCSpause));
            }
        }
    }
}
