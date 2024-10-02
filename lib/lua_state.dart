library kurumi;

class LuaState
{

    static LuaObject.TValue gt(lua_State L)
    {
        return L.l_gt;
    }

    static LuaObject.TValue registry(lua_State L)
    {
        return G(L).l_registry;
    }
    static const int EXTRA_STACK = 5;
    static const int BASIC_CI_SIZE = 8;
    static const int BASIC_STACK_SIZE = (2 * Lua.LUA_MINSTACK);

    static LuaObject.Closure curr_func(lua_State L)
    {
        return LuaObject.clvalue(L.ci.func);
    }

    static LuaObject.Closure ci_func(CallInfo ci)
    {
        return LuaObject.clvalue(ci.func);
    }

    static bool f_isLua(CallInfo ci)
    {
        return ci_func(ci).c.getIsC() == 0;
    }

    static bool isLua(CallInfo ci)
    {
        return LuaObject.ttisfunction(ci.func) && f_isLua(ci);
    }

    static global_State G(lua_State L)
    {
        return L.l_G;
    }

    static void G_set(lua_State L, global_State s)
    {
        L.l_G = s;
    }

    abstract class GCObjectRef
    {

        void set(LuaState.GCObject value);

        LuaState.GCObject get();
    }

    static LuaObject.TString rawgco2ts(GCObject o)
    {
      return (LuaObject.TString)LuaLimits.check_exp(o.getGch().tt == Lua.LUA_TSTRING, o.getTs());
    }

    static LuaObject.TString gco2ts(GCObject o)
    {
      return (LuaObject.TString)(rawgco2ts(o).getTsv());
    }

    static LuaObject.Udata rawgco2u(GCObject o)
    {
      return (LuaObject.Udata)LuaLimits.check_exp(o.getGch().tt == Lua.LUA_TUSERDATA, o.getU());
    }

    static LuaObject.Udata gco2u(GCObject o)
    {
      return (LuaObject.Udata)(rawgco2u(o).uv);
    }

    static LuaObject.Closure gco2cl(GCObject o)
    {
      return (LuaObject.Closure)LuaLimits.check_exp(o.getGch().tt == Lua.LUA_TFUNCTION, o.getCl());
    }

    static LuaObject.Table gco2h(GCObject o)
    {
      return (LuaObject.Table)LuaLimits.check_exp(o.getGch().tt == Lua.LUA_TTABLE, o.getH());
    }

    static LuaObject.Proto gco2p(GCObject o)
    {
      return (LuaObject.Proto)LuaLimits.check_exp(o.getGch().tt == LuaObject.LUA_TPROTO, o.getP());
    }

    static LuaObject.UpVal gco2uv(GCObject o)
    {
      return (LuaObject.UpVal)LuaLimits.check_exp(o.getGch().tt == LuaObject.LUA_TUPVAL, o.getUv());
    }

    static LuaObject.UpVal ngcotouv(GCObject o)
    {
      return (LuaObject.UpVal)LuaLimits.check_exp((o == null) || (o.getGch().tt == LuaObject.LUA_TUPVAL), o.getUv());
    }

    static lua_State gco2th(GCObject o)
    {
      return (lua_State)LuaLimits.check_exp(o.getGch().tt == Lua.LUA_TTHREAD, o.getTh());
    }

    static GCObject obj2gco(Object v)
    {
        return v;
    }

    static int state_size(Object x, ClassType t)
    {
        return t.GetMarshalSizeOf() + LuaConf.LUAI_EXTRASPACE;
    }

    static lua_State tostate(Object l)
    {
        ClassType_.Assert(LuaConf.LUAI_EXTRASPACE == 0, "LUAI_EXTRASPACE not supported");
        return l;
    }

    static void stack_init(lua_State L1, lua_State L)
    {
        L1.base_ci = LuaMem.luaM_newvector_CallInfo(L, BASIC_CI_SIZE, new ClassType(ClassType_.TYPE_CALLINFO));
        L1.ci = L1.base_ci[0];
        L1.size_ci = BASIC_CI_SIZE;
        L1.end_ci = L1.base_ci[L1.size_ci - 1];
        L1.stack = LuaMem.luaM_newvector_TValue(L, BASIC_STACK_SIZE + EXTRA_STACK, new ClassType(ClassType_.TYPE_TVALUE));
        L1.stacksize = (BASIC_STACK_SIZE + EXTRA_STACK);
        L1.top = L1.stack[0];
        L1.stack_last = L1.stack[(L1.stacksize - EXTRA_STACK) - 1];
        L1.ci.func = L1.top;
        LuaObject.TValue[] top = new LuaObject.TValue[1];
        top[0] = L1.top;
        LuaObject.TValue ret = LuaObject.TValue.inc(top); //ref - StkId
        L1.top = top[0];
        LuaObject.setnilvalue(ret);
        L1.base_ = (L1.ci.base_ = L1.top);
        L1.ci.top = LuaObject.TValue.plus(L1.top, Lua.LUA_MINSTACK);
    }

    static void freestack(lua_State L, lua_State L1)
    {
        LuaMem.luaM_freearray_CallInfo(L, L1.base_ci, new ClassType(ClassType_.TYPE_CALLINFO));
        LuaMem.luaM_freearray_TValue(L, L1.stack, new ClassType(ClassType_.TYPE_TVALUE));
    }

    static void f_luaopen(lua_State L, Object ud)
    {
        global_State g = G(L);
        stack_init(L, L);
        LuaObject.sethvalue(L, gt(L), LuaTable.luaH_new(L, 0, 2));
        LuaObject.sethvalue(L, registry(L), LuaTable.luaH_new(L, 0, 2));
        LuaString.luaS_resize(L, LuaLimits.MINSTRTABSIZE);
        LuaTM.luaT_init(L);
        LuaLex.luaX_init(L);
        LuaString.luaS_fix(LuaString.luaS_newliteral(L, CLib.CharPtr.toCharPtr(LuaMem.MEMERRMSG)));
        g.GCthreshold = (4 * g.totalbytes);
    }

    static void preinit_state(lua_State L, global_State g)
    {
        G_set(L, g);
        L.stack = null;
        L.stacksize = 0;
        L.errorJmp = null;
        L.hook = null;
        L.hookmask = 0;
        L.basehookcount = 0;
        L.allowhook = 1;
        LuaDebug.resethookcount(L);
        L.openupval = null;
        L.size_ci = 0;
        L.nCcalls = (L.baseCcalls = 0);
        L.status = 0;
        L.base_ci = null;
        L.ci = null;
        L.savedpc = new LuaCode.InstructionPtr();
        L.errfunc = 0;
        LuaObject.setnilvalue(gt(L));
    }

    static void close_state(lua_State L)
    {
        global_State g = G(L);
        LuaFunc.luaF_close(L, L.stack[0]);
        LuaGC.luaC_freeall(L);
        LuaLimits.lua_assert(g.rootgc == obj2gco(L));
        LuaLimits.lua_assert(g.strt.nuse == 0);
        LuaMem.luaM_freearray_GCObject(L, G(L).strt.hash, new ClassType(ClassType_.TYPE_GCOBJECT));
        LuaZIO.luaZ_freebuffer(L, g.buff);
        freestack(L, L);
        LuaLimits.lua_assert(g.totalbytes == CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_LG)));
    }

    static lua_State luaE_newthread(lua_State L)
    {
        lua_State L1 = LuaMem.luaM_new_lua_State(L, new ClassType(ClassType_.TYPE_LUA_STATE));
        LuaGC.luaC_link(L, obj2gco(L1), Lua.LUA_TTHREAD);
        preinit_state(L1, G(L));
        stack_init(L1, L);
        LuaObject.setobj2n(L, gt(L1), gt(L));
        L1.hookmask = L.hookmask;
        L1.basehookcount = L.basehookcount;
        L1.hook = L.hook;
        LuaDebug.resethookcount(L1);
        LuaLimits.lua_assert(LuaGC.iswhite(obj2gco(L1)));
        return L1;
    }

    static void luaE_freethread(lua_State L, lua_State L1)
    {
        LuaFunc.luaF_close(L1, L1.stack[0]);
        LuaLimits.lua_assert(L1.openupval == null);
        LuaConf.luai_userstatefree(L1);
        freestack(L, L1);
    }

    static lua_State lua_newstate(Lua.lua_Alloc f, Object ud)
    {
        int i;
        lua_State L;
        global_State g;
        Object l = f.exec(new ClassType(ClassType_.TYPE_LG));
        if (l == null) {
            return null;
        }
        L = tostate(l);
        g = ((LG)((L instanceof LG) ? L : null)).g;
        L.next = null;
        L.tt = Lua.LUA_TTHREAD;
        g.currentwhite = LuaGC.bit2mask(LuaGC.WHITE0BIT, LuaGC.FIXEDBIT);
        L.marked = LuaGC.luaC_white(g);
        int marked = L.marked;
        List<int> marked_ref = new List<int>(1);
        marked_ref[0] = marked;
        LuaGC.set2bits(marked_ref, LuaGC.FIXEDBIT, LuaGC.SFIXEDBIT);
        marked = marked_ref[0];
        L.marked = marked;
        preinit_state(L, g);
        g.frealloc = f;
        g.ud = ud;
        g.mainthread = L;
        g.uvhead.u.l.prev = g.uvhead;
        g.uvhead.u.l.next = g.uvhead;
        g.GCthreshold = 0;
        g.strt.size = 0;
        g.strt.nuse = 0;
        g.strt.hash = null;
        LuaObject.setnilvalue(registry(L));
        LuaZIO.luaZ_initbuffer(L, g.buff);
        g.panic = null;
        g.gcstate = LuaGC.GCSpause;
        g.rootgc = obj2gco(L);
        g.sweepstrgc = 0;
        g.sweepgc = new RootGCRef(g);
        g.gray = null;
        g.grayagain = null;
        g.weak = null;
        g.tmudata = null;
        g.totalbytes = CLib.GetUnmanagedSize(new ClassType(ClassType_.TYPE_LG));
        g.gcpause = LuaConf.LUAI_GCPAUSE;
        g.gcstepmul = LuaConf.LUAI_GCMUL;
        g.gcdept = 0;
        for ((i = 0); i < LuaObject.NUM_TAGS; i++) {
            g.mt[i] = null;
        }
        if (LuaDo.luaD_rawrunprotected(L, new f_luaopen_delegate(), null) != 0) {
            close_state(L);
            L = null;
        } else {
            LuaConf.luai_userstateopen(L);
        }
        return L;
    }

    static void callallgcTM(lua_State L, Object ud)
    {
        LuaGC.luaC_callGCTM(L);
    }

    static void lua_close(lua_State L)
    {
        L = G(L).mainthread;
        LuaLimits.lua_lock(L);
        LuaFunc.luaF_close(L, L.stack[0]);
        LuaGC.luaC_separateudata(L, 1);
        L.errfunc = 0;
        do {
            L.ci = L.base_ci[0];
            L.base_ = (L.top = L.ci.base_);
            L.nCcalls = (L.baseCcalls = 0);
        } while (LuaDo.luaD_rawrunprotected(L, new callallgcTM_delegate(), null) != 0);
        LuaLimits.lua_assert(G(L).tmudata == null);
        LuaConf.luai_userstateclose(L);
        close_state(L);
    }
}

class stringtable
{
    List<LuaState.GCObject> hash;
    int nuse;
    int size;
}

class CallInfo with LuaObject_ArrayElement
{
    List<CallInfo> values = null;
    int index = (-1);
    LuaObject.TValue base_;
    LuaObject.TValue func;
    LuaObject.TValue top;
    LuaCode.InstructionPtr savedpc;
    int nresults;
    int tailcalls;

    void set_index(int index)
    {
        this.index = index;
    }

    void set_array(Object array)
    {
        this.values = (CallInfo[])array;
        ClassType_.Assert(this.values != null);
    }

    CallInfo get(int offset)
    {
        return values[index + offset];
    }

    static CallInfo plus(CallInfo value, int offset)
    {
        return value.values[value.index + offset];
    }

    static CallInfo minus(CallInfo value, int offset)
    {
        return value.values[value.index - offset];
    }

    static int minus(CallInfo ci, List<CallInfo> values)
    {
        ClassType_.Assert(ci.values == values);
        return ci.index;
    }

    static int minus(CallInfo ci1, CallInfo ci2)
    {
        ClassType_.Assert(ci1.values == ci2.values);
        return ci1.index - ci2.index;
    }

    static bool lessThan(CallInfo ci1, CallInfo ci2)
    {
        ClassType_.Assert(ci1.values == ci2.values);
        return ci1.index < ci2.index;
    }

    static bool lessEqual(CallInfo ci1, CallInfo ci2)
    {
        ClassType_.Assert(ci1.values == ci2.values);
        return ci1.index <= ci2.index;
    }

    static bool greaterThan(CallInfo ci1, CallInfo ci2)
    {
        ClassType_.Assert(ci1.values == ci2.values);
        return ci1.index > ci2.index;
    }

    static bool greaterEqual(CallInfo ci1, CallInfo ci2)
    {
        ClassType_.Assert(ci1.values == ci2.values);
        return ci1.index >= ci2.index;
    }

    static CallInfo inc(List<CallInfo> value)
    {
        value[0] = value[0].get(1);
        return value[0].get(-1);
    }

    static CallInfo dec(List<CallInfo> value)
    {
        value[0] = value[0].get(-1);
        return value[0].get(1);
    }
}

class global_State
{
    stringtable strt = new stringtable();
    Lua.lua_Alloc frealloc;
    Object ud;
    int currentwhite;
    int gcstate;
    int sweepstrgc;
    LuaState.GCObject rootgc;
    LuaState.GCObjectRef sweepgc;
    LuaState.GCObject gray;
    LuaState.GCObject grayagain;
    LuaState.GCObject weak;
    LuaState.GCObject tmudata;
    LuaZIO.Mbuffer buff = new LuaZIO.Mbuffer();
    int GCthreshold;
    int totalbytes;
    int estimate;
    int gcdept;
    int gcpause;
    int gcstepmul;
    Lua.lua_CFunction panic;
    LuaObject.TValue l_registry = new LuaObject.TValue();
    lua_State mainthread;
    LuaObject.UpVal uvhead = new LuaObject.UpVal();
    List<LuaObject.Table> mt = new List<LuaObject.Table>(LuaObject.NUM_TAGS);
    List<LuaObject.TString> tmname = new List<LuaObject.TString>(LuaTM.TMS.TM_N.getValue());
}

class lua_State extends LuaState_GCObject
{
    int status;
    LuaObject.TValue top;
    LuaObject.TValue base_;
    LuaState.global_State l_G;
    LuaState.CallInfo ci;
    LuaCode.InstructionPtr savedpc = new LuaCode.InstructionPtr();
    LuaObject.TValue stack_last;
    List<LuaObject.TValue> stack;
    LuaState.CallInfo end_ci;
    List<LuaState.CallInfo> base_ci;
    int stacksize;
    int size_ci;
    int nCcalls;
    int baseCcalls;
    int hookmask;
    int allowhook;
    int basehookcount;
    int hookcount;
    Lua.lua_Hook hook;
    LuaObject.TValue l_gt = new LuaObject.TValue();
    LuaObject.TValue env = new LuaObject.TValue();
    LuaState.GCObject openupval;
    LuaState.GCObject gclist;
    LuaDo.lua_longjmp errorJmp;
    int errfunc;
}

class GCObject extends LuaObject_GCheader with LuaObject_ArrayElement
{

    void set_index(int index)
    {
    }

    void set_array(Object array)
    {
    }

    LuaObject.GCheader getGch()
    {
      return (LuaObject.GCheader)this;
    }

    LuaObject.TString getTs()
    {
        return (LuaObject.TString)this;
    }

    LuaObject.Udata getU()
    {
      return (LuaObject.Udata)this;
    }

    LuaObject.Closure getCl()
    {
      return (LuaObject.Closure)this;
    }

    LuaObject.Table getH()
    {
      return (LuaObject.Table)this;
    }

    LuaObject.Proto getP()
    {
      return (LuaObject.Proto)this;
    }

    LuaObject.UpVal getUv()
    {
      return (LuaObject.UpVal)this;
    }

    lua_State getTh()
    {
      return (lua_State)this;
    }
}

class ArrayRef with GCObjectRef, LuaObject_ArrayElement
{
    List<GCObject> array_elements;
    int array_index;
    List<ArrayRef> vals;
    int index;

    ArrayRef_()
    {
        this.array_elements = null;
        this.array_index = 0;
        this.vals = null;
        this.index = 0;
    }

    ArrayRef_(List<GCObject> array_elements, int array_index)
    {
        this.array_elements = array_elements;
        this.array_index = array_index;
        this.vals = null;
        this.index = 0;
    }

    void set(GCObject value)
    {
        array_elements[array_index] = value;
    }

    GCObject get()
    {
        return array_elements[array_index];
    }

    void set_index(int index)
    {
        this.index = index;
    }

    void set_array(Object vals)
    {
        this.vals = (ArrayRef[])vals;
        ClassType_.Assert(this.vals != null);
    }
}

class OpenValRef with LuaState_GCObjectRef
{
    LuaState.lua_State L;

    OpenValRef(LuaState.lua_State L)
    {
        this.L = L;
    }

    void set(LuaState.GCObject value)
    {
        this.L.openupval = value;
    }

    LuaState.GCObject get()
    {
        return this.L.openupval;
    }
}

class RootGCRef with LuaState_GCObjectRef
{
    LuaState.global_State g;

    RootGCRef_(LuaState.global_State g)
    {
        this.g = g;
    }

    void set(LuaState.GCObject value)
    {
        this.g.rootgc = value;
    }

    LuaState.GCObject get()
    {
        return this.g.rootgc;
    }
}

class NextRef with LuaState_GCObjectRef
{
    LuaObject.GCheader header;

    NextRef(LuaObject.GCheader header)
    {
        this.header = header;
    }

    void set(LuaState.GCObject value)
    {
        this.header.next = value;
    }

    LuaState.GCObject get()
    {
        return this.header.next;
    }
}

class LG extends lua_State
{
    LuaState.global_State g = new LuaState.global_State();

    lua_State getL()
    {
        return this;
    }
}

class f_luaopen_delegate with LuaDo_Pfunc
{

    final void exec(lua_State L, Object ud)
    {
        f_luaopen(L, ud);
    }
}

class callallgcTM_delegate with LuaDo_Pfunc
{

    final void exec(lua_State L, Object ud)
    {
        callallgcTM(L, ud);
    }
}
