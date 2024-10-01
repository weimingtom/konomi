library kurumi;

class LuaFunc
{
    static int sizeCclosure(int n)
    {
        return CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_CCLOSURE)) + (CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_TVALUE)) * (n - 1));
    }

    static int sizeLclosure(int n)
    {
        return CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_LCLOSURE)) + (CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_TVALUE)) * (n - 1));
    }

    static LuaObject.Closure luaF_newCclosure(LuaState.lua_State L, int nelems, LuaObject.Table e)
    {
        LuaObject.Closure c = LuaMem.luaM_new_Closure(L, new ClassType(ClassType.TYPE_CLOSURE));
        LuaMem.AddTotalBytes(L, sizeCclosure(nelems));
        LuaGC.luaC_link(L, LuaState.obj2gco(c), Lua.LUA_TFUNCTION);
        c.c.setIsC(1);
        c.c.setEnv(e);
        c.c.setNupvalues(LuaLimits.cast_byte(nelems));
        c.c.upvalue = new List<LuaObject.TValue>(nelems);
        for (int i = 0; i < nelems; i++) {
            c.c.upvalue[i] = new LuaObject.TValue();
        }
        return c;
    }

    static LuaObject.Closure luaF_newLclosure(LuaState.lua_State L, int nelems, LuaObject.Table e)
    {
        LuaObject.Closure c = LuaMem.luaM_new_Closure(L, new ClassType(ClassType.TYPE_CLOSURE));
        LuaMem.AddTotalBytes(L, sizeLclosure(nelems));
        LuaGC.luaC_link(L, LuaState.obj2gco(c), Lua.LUA_TFUNCTION);
        c.l.setIsC(0);
        c.l.setEnv(e);
        c.l.setNupvalues(LuaLimits.cast_byte(nelems));
        c.l.upvals = new List<LuaObject.UpVal>(nelems);
        for (int i = 0; i < nelems; i++) {
            c.l.upvals[i] = new LuaObject.UpVal();
        }
        while (nelems-- > 0) {
            c.l.upvals[nelems] = null;
        }
        return c;
    }

    static LuaObject.UpVal luaF_newupval(LuaState.lua_State L)
    {
        LuaObject.UpVal uv = LuaMem.luaM_new_UpVal(L, new ClassType(ClassType.TYPE_UPVAL));
        LuaGC.luaC_link(L, LuaState.obj2gco(uv), LuaObject.LUA_TUPVAL);
        uv.v = uv.u.value;
        LuaObject.setnilvalue(uv.v);
        return uv;
    }

    static LuaObject.UpVal luaF_findupval(LuaState.lua_State L, LuaObject.TValue level)
    {
        LuaState.global_State g = LuaState.G(L);
		LuaState.GCObjectRef pp = new LuaState.OpenValRef(L);
		LuaObject.UpVal p;
		LuaObject.UpVal uv;
        while ((pp.get() != null) && LuaObject.TValue.greaterEqual((p = LuaState.ngcotouv(pp.get())).v, level)) {
            LuaLimits.lua_assert(p.v != p.u.value);
            if (p.v == level) {
                if (LuaGC.isdead(g, LuaState.obj2gco(p))) {
                    LuaGC.changewhite(LuaState.obj2gco(p));
                }
                return p;
            }
            pp = new LuaState.NextRef(p);
        }
        uv = LuaMem.luaM_new_UpVal(L, new ClassType(ClassType_.TYPE_UPVAL));
        uv.tt = LuaObject.LUA_TUPVAL;
        uv.marked = LuaGC.luaC_white(g);
        uv.v = level;
        uv.next = pp.get();
        pp.set(LuaState.obj2gco(uv));
        uv.u.l.prev = g.uvhead;
        uv.u.l.next = g.uvhead.u.l.next;
        uv.u.l.next.u.l.prev = uv;
        g.uvhead.u.l.next = uv;
        LuaLimits.lua_assert((uv.u.l.next.u.l.prev == uv) && (uv.u.l.prev.u.l.next == uv));
        return uv;
    }

        static void unlinkupval(LuaObject.UpVal uv)
    {
        LuaLimits.lua_assert((uv.u.l.next.u.l.prev == uv) && (uv.u.l.prev.u.l.next == uv));
        uv.u.l.next.u.l.prev = uv.u.l.prev;
        uv.u.l.prev.u.l.next = uv.u.l.next;
    }

    static void luaF_freeupval(LuaState.lua_State L, LuaObject.UpVal uv)
    {
        if (uv.v != uv.u.value) {
            unlinkupval(uv);
        }
        LuaMem.luaM_free_UpVal(L, uv, new ClassType(ClassType_.TYPE_UPVAL));
    }

    static void luaF_close(LuaState.lua_State L, LuaObject.TValue level)
    {
        LuaObject.UpVal uv;
		LuaState.global_State g = LuaState.G(L);
        while ((L.openupval != null) && LuaObject.TValue.greaterEqual((uv = LuaState.ngcotouv(L.openupval)).v, level)) {
            LuaState.GCObject o = LuaState.obj2gco(uv);
            LuaLimits.lua_assert((!LuaGC.isblack(o)) && (uv.v != uv.u.value));
            L.openupval = uv.next;
            if (LuaGC.isdead(g, o)) {
                luaF_freeupval(L, uv);
            } else {
                unlinkupval(uv);
                LuaObject.setobj(L, uv.u.value, uv.v);
                uv.v = uv.u.value;
                LuaGC.luaC_linkupval(L, uv);
            }
        }
    }

    static void luaF_freeproto(LuaState.lua_State L, LuaObject.Proto f)
    {
        LuaMem.luaM_freearray_long(L, f.code, new ClassType(ClassType_.TYPE_LONG));
        LuaMem.luaM_freearray_Proto(L, f.p, new ClassType(ClassType_.TYPE_PROTO));
        LuaMem.luaM_freearray_TValue(L, f.k, new ClassType(ClassType_.TYPE_TVALUE));
        LuaMem.luaM_freearray_int(L, f.lineinfo, new ClassType(ClassType_.TYPE_INT32));
        LuaMem.luaM_freearray_LocVar(L, f.locvars, new ClassType(ClassType_.TYPE_LOCVAR));
        LuaMem.luaM_freearray_TString(L, f.upvalues, new ClassType(ClassType_.TYPE_TSTRING));
        LuaMem.luaM_free_Proto(L, f, new ClassType(ClassType_.TYPE_PROTO));
    }

    static void luaF_freeclosure(LuaState.lua_State L, LuaObject.Closure c)
    {
        int size = ((c.c.getIsC() != 0) ? sizeCclosure(c.c.getNupvalues()) : sizeLclosure(c.l.getNupvalues()));
        LuaMem.SubtractTotalBytes(L, size);
    }

    static CLib.CharPtr luaF_getlocalname(LuaObject.Proto f, int local_number, int pc)
    {
        int i;
        for ((i = 0); (i < f.sizelocvars) && (f.locvars[i].startpc <= pc); i++) {
            if (pc < f.locvars[i].endpc) {
                local_number--;
                if (local_number == 0) {
                    return LuaObject.getstr(f.locvars[i].varname);
                }
            }
        }
        return null;
    }

    static LuaObject.Proto luaF_newproto(LuaState.lua_State L)
    {
        LuaObject.Proto f = LuaMem.luaM_new_Proto(L, new ClassType(ClassType.TYPE_PROTO));
        LuaGC.luaC_link(L, LuaState.obj2gco(f), LuaObject.LUA_TPROTO);
        f.k = null;
        f.sizek = 0;
        f.p = null;
        f.sizep = 0;
        f.code = null;
        f.sizecode = 0;
        f.sizelineinfo = 0;
        f.sizeupvalues = 0;
        f.nups = 0;
        f.upvalues = null;
        f.numparams = 0;
        f.is_vararg = 0;
        f.maxstacksize = 0;
        f.lineinfo = null;
        f.sizelocvars = 0;
        f.locvars = null;
        f.linedefined = 0;
        f.lastlinedefined = 0;
        f.source = null;
        return f;
    }
}
