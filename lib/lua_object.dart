library kurumi;

class LuaObject
{
    static const int LAST_TAG = Lua.LUA_TTHREAD;
    static const int NUM_TAGS = (LAST_TAG + 1);
    static const int LUA_TPROTO = (LAST_TAG + 1);
    static const int LUA_TUPVAL = (LAST_TAG + 2);
    static const int LUA_TDEADKEY = (LAST_TAG + 3);

    abstract class ArrayElement
    {

        void set_index(int index);

        void set_array(Object array);
    }

    static bool ttisnil(TValue o)
    {
        return ttype(o) == Lua.LUA_TNIL;
    }

    static bool ttisnumber(TValue o)
    {
        return ttype(o) == Lua.LUA_TNUMBER;
    }

    static bool ttisstring(TValue o)
    {
        return ttype(o) == Lua.LUA_TSTRING;
    }

    static bool ttistable(TValue o)
    {
        return ttype(o) == Lua.LUA_TTABLE;
    }

    static bool ttisfunction(TValue o)
    {
        return ttype(o) == Lua.LUA_TFUNCTION;
    }

    static bool ttisboolean(TValue o)
    {
        return ttype(o) == Lua.LUA_TBOOLEAN;
    }

    static bool ttisuserdata(TValue o)
    {
        return ttype(o) == Lua.LUA_TUSERDATA;
    }

    static bool ttisthread(TValue o)
    {
        return ttype(o) == Lua.LUA_TTHREAD;
    }

    static bool ttislightuserdata(TValue o)
    {
        return ttype(o) == Lua.LUA_TLIGHTUSERDATA;
    }

    static int ttype(TValue o)
    {
        return o.tt;
    }

    static int ttype(CommonHeader o)
    {
        return o.tt;
    }

    static LuaState.GCObject gcvalue(TValue o)
    {
        return (LuaState.GCObject)LuaLimits.check_exp(iscollectable(o), o.value.gc);
    }

    static Object pvalue(TValue o)
    {
        return LuaLimits.check_exp(ttislightuserdata(o), o.value.p);
    }

    static double nvalue(TValue o)
    {
        return LuaLimits.check_exp(ttisnumber(o), o.value.n).doubleValue();
    }

    static TString rawtsvalue(TValue o)
    {
        return LuaLimits.check_exp(ttisstring(o), o.value.gc.getTs());
    }

    static TString_tsv tsvalue(TValue o)
    {
        return rawtsvalue(o).getTsv();
    }

    static Udata rawuvalue(TValue o)
    {
        return LuaLimits.check_exp(ttisuserdata(o), o.value.gc.getU());
    }

    static Udata_uv uvalue(TValue o)
    {
        return rawuvalue(o).uv;
    }

    static Closure clvalue(TValue o)
    {
        return LuaLimits.check_exp(ttisfunction(o), o.value.gc.getCl());
    }

    static Table hvalue(TValue o)
    {
        return LuaLimits.check_exp(ttistable(o), o.value.gc.getH());
    }

    static int bvalue(TValue o)
    {
        return LuaLimits.check_exp(ttisboolean(o), o.value.b).intValue();
    }

    static LuaState.lua_State thvalue(TValue o)
    {
        return (LuaState.lua_State)LuaLimits.check_exp(ttisthread(o), o.value.gc.getTh());
    }

    static int l_isfalse(TValue o)
    {
        return (ttisnil(o) || (ttisboolean(o) && (bvalue(o) == 0))) ? 1 : 0;
    }

    static void checkconsistency(TValue obj)
    {
        LuaLimits.lua_assert((!iscollectable(obj)) || (ttype(obj) == obj.value.gc.getGch().tt));
    }

    static void checkliveness(LuaState.global_State g, TValue obj)
    {
        LuaLimits.lua_assert((!iscollectable(obj)) || ((ttype(obj) == obj.value.gc.getGch().tt) && (!LuaGC.isdead(g, obj.value.gc))));
    }

    static void setnilvalue(TValue obj)
    {
        obj.tt = Lua.LUA_TNIL;
    }

    static void setnvalue(TValue obj, double x)
    {
        obj.value.n = x;
        obj.tt = Lua.LUA_TNUMBER;
    }

    static void setpvalue(TValue obj, Object x)
    {
        obj.value.p = x;
        obj.tt = Lua.LUA_TLIGHTUSERDATA;
    }

    static void setbvalue(TValue obj, int x)
    {
        obj.value.b = x;
        obj.tt = Lua.LUA_TBOOLEAN;
    }

    static void setsvalue(LuaState.lua_State L, TValue obj, LuaState.GCObject x)
    {
        obj.value.gc = x;
        obj.tt = Lua.LUA_TSTRING;
        checkliveness(LuaState.G(L), obj);
    }

    static void setuvalue(LuaState.lua_State L, TValue obj, LuaState.GCObject x)
    {
        obj.value.gc = x;
        obj.tt = Lua.LUA_TUSERDATA;
        checkliveness(LuaState.G(L), obj);
    }

    static void setthvalue(LuaState.lua_State L, TValue obj, LuaState.GCObject x)
    {
        obj.value.gc = x;
        obj.tt = Lua.LUA_TTHREAD;
        checkliveness(LuaState.G(L), obj);
    }

    static void setclvalue(LuaState.lua_State L, TValue obj, Closure x)
    {
        obj.value.gc = x;
        obj.tt = Lua.LUA_TFUNCTION;
        checkliveness(LuaState.G(L), obj);
    }

    static void sethvalue(LuaState.lua_State L, TValue obj, Table x)
    {
        obj.value.gc = x;
        obj.tt = Lua.LUA_TTABLE;
        checkliveness(LuaState.G(L), obj);
    }

    static void setptvalue(LuaState.lua_State L, TValue obj, Proto x)
    {
        obj.value.gc = x;
        obj.tt = LUA_TPROTO;
        checkliveness(LuaState.G(L), obj);
    }

    static void setobj(LuaState.lua_State L, TValue obj1, TValue obj2)
    {
        obj1.value.copyFrom(obj2.value);
        obj1.tt = obj2.tt;
        checkliveness(LuaState.G(L), obj1);
    }

    static void setobjs2s(LuaState.lua_State L, TValue obj, TValue x)
    {
        setobj(L, obj, x);
    }

    static void setobj2s(LuaState.lua_State L, TValue obj, TValue x)
    {
        setobj(L, obj, x);
    }

    static void setsvalue2s(LuaState.lua_State L, TValue obj, TString x)
    {
        setsvalue(L, obj, x);
    }

    static void sethvalue2s(LuaState.lua_State L, TValue obj, Table x)
    {
        sethvalue(L, obj, x);
    }

    static void setptvalue2s(LuaState.lua_State L, TValue obj, Proto x)
    {
        setptvalue(L, obj, x);
    }

    static void setobjt2t(LuaState.lua_State L, TValue obj, TValue x)
    {
        setobj(L, obj, x);
    }

    static void setobj2t(LuaState.lua_State L, TValue obj, TValue x)
    {
        setobj(L, obj, x);
    }

    static void setobj2n(LuaState.lua_State L, TValue obj, TValue x)
    {
        setobj(L, obj, x);
    }

    static void setsvalue2n(LuaState.lua_State L, TValue obj, TString x)
    {
        setsvalue(L, obj, x);
    }

    static void setttype(TValue obj, int tt)
    {
        obj.tt = tt;
    }

    static bool iscollectable(TValue o)
    {
        return ttype(o) >= Lua.LUA_TSTRING;
    }

    static CLib.CharPtr getstr(TString ts)
    {
        return ts.str;
    }

    static CLib.CharPtr svalue(TValue o)
    {
        return getstr(rawtsvalue(o));
    }
    static const int VARARG_HASARG = 1;
    static const int VARARG_ISVARARG = 2;
    static const int VARARG_NEEDSARG = 4;

    static bool iscfunction(TValue o)
    {
        return (ttype(o) == Lua.LUA_TFUNCTION) && (clvalue(o).c.getIsC() != 0);
    }

    static bool isLfunction(TValue o)
    {
        return (ttype(o) == Lua.LUA_TFUNCTION) && (clvalue(o).c.getIsC() == 0);
    }

    static int twoto(int x)
    {
        return 1 << x;
    }

    static int sizenode(Table t)
    {
        return twoto(t.lsizenode);
    }
    static TValue luaO_nilobject_ = new TValue(new Value(), Lua.LUA_TNIL);
    static TValue luaO_nilobject = luaO_nilobject_;

    static int ceillog2(int x)
    {
        return luaO_log2(x - 1) + 1;
    }

    static int luaO_int2fb(int x)
    {
        int e = 0;
        while (x >= 16) {
            x = ((x + 1) >> 1);
            e++;
        }
        if (x < 8) {
            return x;
        } else {
            return ((e + 1) << 3) | (LuaLimits.cast_int(x) - 8);
        }
    }

    static int luaO_fb2int(int x)
    {
        int e = ((x >> 3) & 31);
        if (e == 0) {
            return x;
        } else {
            return ((x & 7) + 8) << (e - 1);
        }
    }
    static final List<int> log_2 = [0, 1, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8];


    static int luaO_log2(long x) { //uint
      int l = -1;
      while (x >= 256) {
        l += 8;
        x >>= 8;
      }
		  return l + log_2[(int)x];
	  }

    static int luaO_rawequalObj(TValue t1, TValue t2)
    {
        if (ttype(t1) != ttype(t2)) {
            return 0;
        } else {
            switch (ttype(t1)) {
                case Lua.LUA_TNIL:
                    return 1;
                case Lua.LUA_TNUMBER:
                    return LuaConf.luai_numeq(nvalue(t1), nvalue(t2)) ? 1 : 0;
                case Lua.LUA_TBOOLEAN:
                    return (bvalue(t1) == bvalue(t2)) ? 1 : 0;
                case Lua.LUA_TLIGHTUSERDATA:
                    return (pvalue(t1) == pvalue(t2)) ? 1 : 0;
                default:
                    LuaLimits.lua_assert(iscollectable(t1));
                    return (gcvalue(t1) == gcvalue(t2)) ? 1 : 0;
            }
        }
    }

    static int luaO_str2d(CLib.CharPtr s, List<double> result)
    {
        CLib.CharPtr[] endptr = new CLib.CharPtr[1];
        endptr[0] = new CLib.CharPtr();
        result[0] = LuaConf.lua_str2number(s, endptr);
        if (CLib.CharPtr.isEqual(endptr[0], s)) {
            return 0;
        }
        if ((endptr[0].get(0) == 'x'.codeUnitAt(0)) || (endptr[0].get(0) == 'X'.codeUnitAt(0))) {
            result[0] = LuaLimits.cast_num(CLib.strtoul(s, endptr, 16));
        }
        if (endptr[0].get(0) == '\0'.codeUnitAt(0)) {
            return 1;
        }
        while (CLib.isspace(endptr[0].get(0))) {
            endptr[0] = endptr[0].next();
        }
        if (endptr[0].get(0) != '\0'.codeUnitAt(0)) {
            return 0;
        }
        return 1;
    }

    static void pushstr(LuaState.lua_State L, CLib.CharPtr str)
    {
        setsvalue2s(L, L.top, LuaString.luaS_new(L, str));
        LuaDo.incr_top(L);
    }

    static CLib.CharPtr luaO_pushvfstring(LuaState.lua_State L, CLib.CharPtr fmt, List<Object> argp /*XXX*/)
    {
        int parm_index = 0;
        int n = 1;
        pushstr(L, CLib.CharPtr.toCharPtr(""));
        for (; ; ) {
            CLib.CharPtr e = CLib.strchr(fmt, '%');
            if (CLib.CharPtr.isEqual(e, null)) {
                break;
            }
            setsvalue2s(L, L.top, LuaString.luaS_newlstr(L, fmt, CLib.CharPtr.minus(e, fmt)));
            LuaDo.incr_top(L);
            switch (e.get(1)) {
                case 's'.codeUnitAt(0):
                    Object o = argp[parm_index++];
                    CLib.CharPtr s = (CLib.CharPtr)((o instanceof CLib.CharPtr) ? o : null);
                    if (CLib.CharPtr.isEqual(s, null)) {
                        s = CLib.CharPtr.toCharPtr(o);
                    }
                    if (CLib.CharPtr.isEqual(s, null)) {
                        s = CLib.CharPtr.toCharPtr("(null)");
                    }
                    pushstr(L, s);
                    break;
                case 'c'.codeUnitAt(0):
                    CLib.CharPtr buff = CLib.CharPtr.toCharPtr(new char[2]);
                    buff.set(0, argp[parm_index++].intValue());
                    buff.set(1, '\0'.codeUnitAt(0));
                    pushstr(L, buff);
                    break;
                case 'd'.codeUnitAt(0):
                    setnvalue(L.top, argp[parm_index++].intValue());
                    LuaDo.incr_top(L);
                    break;
                case 'f'.codeUnitAt(0):
                    setnvalue(L.top, argp[parm_index++].doubleValue());
                    LuaDo.incr_top(L);
                    break;
                case 'p'.codeUnitAt(0):
                    CLib.CharPtr buff = CLib.CharPtr.toCharPtr(new char[32]);
                    CLib.sprintf(buff, CLib.CharPtr.toCharPtr("0x%08x"), argp[parm_index++].hashCode());
                    pushstr(L, buff);
                    break;
                case '%'.codeUnitAt(0):
                    pushstr(L, CLib.CharPtr.toCharPtr("%"));
                    break;
                default:
                    CLib.CharPtr buff = CLib.CharPtr.toCharPtr(new char[3]);
                    buff.set(0, '%'.codeUnitAt(0));
                    buff.set(1, e.get(1));
                    buff.set(2, '\0'.codeUnitAt(0));
                    pushstr(L, buff);
                    break;
            }
            n += 2;
            fmt = CLib.CharPtr.plus(e, 2);
        }
        pushstr(L, fmt);
        LuaVM.luaV_concat(L, n + 1, LuaLimits.cast_int(TValue_.minus(L.top, L.base_)) - 1);
        L.top = TValue_.minus(L.top, n);
        return svalue(TValue_.minus(L.top, 1));
    }

    static CLib.CharPtr luaO_pushfstring(LuaState.lua_State L, CLib.CharPtr fmt, List<Object> args /*XXX*/)
    {
        return luaO_pushvfstring(L, fmt, args);
    }

    static void luaO_chunkid(CLib.CharPtr out_, CLib.CharPtr source, int bufflen)
    {
        if (source.get(0) == '='.codeUnitAt(0)) {
            CLib.strncpy(out_, CLib.CharPtr.plus(source, 1), bufflen);
            out_.set(bufflen - 1, '\0'.codeUnitAt(0));
        } else {
            if (source.get(0) == '@'.codeUnitAt(0)) {
                int l;
                source = source.next();
                bufflen -= (new String(" '...' ").length + 1);
                l = CLib.strlen(source);
                CLib.strcpy(out_, CLib.CharPtr.toCharPtr(""));
                if (l > bufflen) {
                    source = CLib.CharPtr.plus(source, l - bufflen);
                    CLib.strcat(out_, CLib.CharPtr.toCharPtr("..."));
                }
                CLib.strcat(out_, source);
            } else {
                int len = CLib.strcspn(source, CLib.CharPtr.toCharPtr("\n\r"));
                bufflen -= (new String(" [string \"...\"] ").length + 1);
                if (len > bufflen) {
                    len = bufflen;
                }
                CLib.strcpy(out_, CLib.CharPtr.toCharPtr("[string \""));
                if (source.get(len) != '\0'.codeUnitAt(0)) {
                    CLib.strncat(out_, source, len);
                    CLib.strcat(out_, CLib.CharPtr.toCharPtr("..."));
                } else {
                    CLib.strcat(out_, source);
                }
                CLib.strcat(out_, CLib.CharPtr.toCharPtr("\"]"));
            }
        }
    }
}

class CommonHeader
{
    LuaState.GCObject next;
    int tt;
    int marked;
}

class GCheader extends LuaObject_CommonHeader
{
}

class Value
{
    LuaState.GCObject gc;
    Object p;
    double n;
    int b;

    Value_()
    {
    }

    Value_(Value copy)
    {
        this.gc = copy.gc;
        this.p = copy.p;
        this.n = copy.n;
        this.b = copy.b;
    }

    void copyFrom(Value copy)
    {
        this.gc = copy.gc;
        this.p = copy.p;
        this.n = copy.n;
        this.b = copy.b;
    }
}

class TValue with LuaObject_ArrayElement
{
    List<TValue> values = null;
    int index = (-1);
    Value value = new Value();
    int tt;

    void set_index(int index)
    {
        this.index = index;
    }

    void set_array(Object array)
    {
        this.values = (TValue[])array;
        ClassType.Assert(this.values != null);
    }

    TValue get(int offset)
    {
        return this.values[this.index + offset];
    }

    static TValue plus(TValue value, int offset)
    {
        return value.values[value.index + offset];
    }

    static TValue plus(int offset, TValue value)
    {
        return value.values[value.index + offset];
    }

    static TValue minus(TValue value, int offset)
    {
        return value.values[value.index - offset];
    }

    static int minus(TValue value, List<TValue> array)
    {
        ClassType.Assert(value.values == array);
        return value.index;
    }

    static int minus(TValue a, TValue b)
    {
        ClassType.Assert(a.values == b.values);
        return a.index - b.index;
    }

    static bool lessThan(TValue a, TValue b)
    {
        ClassType.Assert(a.values == b.values);
        return a.index < b.index;
    }

    static bool lessEqual(TValue a, TValue b)
    {
        ClassType.Assert(a.values == b.values);
        return a.index <= b.index;
    }

    static bool greaterThan(TValue a, TValue b)
    {
        ClassType.Assert(a.values == b.values);
        return a.index > b.index;
    }

    static bool greaterEqual(TValue a, TValue b)
    {
        ClassType.Assert(a.values == b.values);
        return a.index >= b.index;
    }

    static TValue inc(List<TValue> value)
    {
        value[0] = value[0].get(1);
        return value[0].get(-1);
    }

    static TValue dec(List<TValue> value)
    {
        value[0] = value[0].get(-1);
        return value[0].get(1);
    }

    static int toInt(TValue value)
    {
        return value.index;
    }

    TValue_()
    {
        this.values = null;
        this.index = 0;
        this.value = new Value();
        this.tt = 0;
    }

    TValue_(TValue value)
    {
        this.values = value.values;
        this.index = value.index;
        this.value = new Value(value.value);
        this.tt = value.tt;
    }

    TValue_(Value value, int tt)
    {
        this.values = null;
        this.index = 0;
        this.value = new Value(value);
        this.tt = tt;
    }
}

class Udata_uv extends LuaState_GCObject
{
    LuaObject.Table metatable;
    LuaObject.Table env;
    int len;
}

class Udata extends LuaObject_Udata_uv
{
    LuaObject.Udata_uv uv;
    Object user_data;

    Udata_()
    {
        this.uv = this;
    }
}

class TString_tsv extends LuaState_GCObject
{
    int reserved;
    int hash;
    int len;
}

class TString extends LuaObject_TString_tsv
{
    public CLib.CharPtr str;

    LuaObject.TString_tsv getTsv()
    {
        return this;
    }

    TString_()
    {
    }

    TString_(CLib.CharPtr str)
    {
        this.str = str;
    }

    String toString() 
		{
			return str.toString();
		} // for debugging
}

class Proto extends LuaState_GCObject
{
    List<Proto> protos = null;
    int index = 0;
    List<TValue> k;
    List<int> code;
    List<Proto> p;
    List<int> lineinfo;
    List<LuaObject.LocVar> locvars;
    List<TString> upvalues;
    TString source;
    int sizeupvalues;
    int sizek;
    int sizecode;
    int sizelineinfo;
    int sizep;
    int sizelocvars;
    int linedefined;
    int lastlinedefined;
    LuaState.GCObject gclist;
    int nups;
    int numparams;
    int is_vararg;
    int maxstacksize;

    Proto get(int offset)
    {
        return this.protos[this.index + offset];
    }
}

class LocVar
{
    TString varname;
    int startpc;
    int endpc;
}

class UpVal extends LuaState_GCObject
{
    _u u = new _u();
    LuaObject.TValue v;
}

class _u
{
    LuaObject.TValue value = new LuaObject.TValue();
    _l l = new _l();
}

class _l
{
    UpVal prev;
    UpVal next;
}

class ClosureHeader extends LuaState_GCObject
{
    int isC;
    int nupvalues;
    LuaState.GCObject gclist;
    Table env;
}

class ClosureType
{
    LuaObject.ClosureHeader header;

    static LuaObject.ClosureHeader toClosureHeader(ClosureType ctype)
    {
        return ctype.header;
    }

    ClosureType_(LuaObject.ClosureHeader header)
    {
        this.header = header;
    }

    int getIsC()
    {
        return header.isC;
    }

    void setIsC(int val)
    {
        header.isC = val;
    }

    int getNupvalues()
    {
        return header.nupvalues;
    }

    void setNupvalues(int val)
    {
        header.nupvalues = val;
    }

    LuaState.GCObject getGclist()
    {
        return header.gclist;
    }

    void setGclist(LuaState.GCObject val)
    {
        header.gclist = val;
    }

    Table getEnv()
    {
        return header.env;
    }

    void setEnv(Table val)
    {
        header.env = val;
    }
}

class CClosure extends ClosureType
{
    Lua.lua_CFunction f;
    List<TValue> upvalue;

    CClosure(ClosureHeader header)
    {
        super(header);
    }
}

class LClosure extends LuaObject_ClosureType
{
    Proto p;
    List<UpVal> upvals;

    LClosure(LuaObject.ClosureHeader header)
    {
        super(header);
    }
}

class Closure extends ClosureHeader
{
    LuaObject.CClosure c;
    LClosure l;

    Closure_()
    {
        c = new LuaObject.CClosure(this);
        l = new LClosure(this);
    }
}

class TKey_nk extends TValue
{
    LuaObject.Node next;

    TKey_nk()
    {
    }

    TKey_nk(Value value, int tt, LuaObject.Node next)
    {
        super(new Value(value), tt);
        this.next = next;
    }
}

class TKey
{
    LuaObject.TKey_nk nk = new LuaObject.TKey_nk();

    TKey()
    {
        this.nk = new LuaObject.TKey_nk();
    }

    TKey(TKey copy)
    {
        this.nk = new LuaObject.TKey_nk(new Value(copy.nk.value), copy.nk.tt, copy.nk.next);
    }

    TKey_(Value value, int tt, LuaObject.Node next)
    {
        this.nk = new LuaObject.TKey_nk(new Value(value), tt, next);
    }

    TValue getTvk()
    {
        return this.nk;
    }
}

class Node with LuaObject_ArrayElement
{
    List<Node> values = null;
    int index = (-1);
    static int ids = 0;
    int id = ids++;
    TValue i_val;
    TKey i_key;

    void set_index(int index)
    {
        this.index = index;
    }

    void set_array(Object array)
    {
        this.values = (Node[])array;
        ClassType.Assert(this.values != null);
    }

    Node_()
    {
        this.i_val = new TValue();
        this.i_key = new TKey();
    }

    Node_(Node copy)
    {
        this.values = copy.values;
        this.index = copy.index;
        this.i_val = new TValue(copy.i_val);
        this.i_key = new TKey(copy.i_key);
    }

    Node_(TValue i_val, TKey i_key)
    {
        this.values = new List<Node>.from([this]);
        this.index = 0;
        this.i_val = i_val;
        this.i_key = i_key;
    }

    Node get(int offset)
    {
        return this.values[this.index + offset];
    }

    static int minus(Node n1, Node n2)
    {
        ClassType.Assert(n1.values == n2.values);
        return n1.index - n2.index;
    }

    static Node inc(List<Node> node)
    {
        node[0] = node[0].get(1);
        return node[0].get(-1);
    }

    static Node dec(List<Node> node)
    {
        node[0] = node[0].get(-1);
        return node[0].get(1);
    }

    static bool greaterThan(Node n1, Node n2)
    {
        ClassType.Assert(n1.values == n2.values);
        return n1.index > n2.index;
    }

    static bool greaterEqual(Node n1, Node n2)
    {
        ClassType.Assert(n1.values == n2.values);
        return n1.index >= n2.index;
    }

    static bool lessThan(Node n1, Node n2)
    {
        ClassType.Assert(n1.values == n2.values);
        return n1.index < n2.index;
    }

    static bool lessEqual(Node n1, Node n2)
    {
        ClassType.Assert(n1.values == n2.values);
        return n1.index <= n2.index;
    }

    static bool isEqual(Node n1, Node n2)
    {
        Object o1 = (Node)((n1 instanceof Node) ? n1 : null);
			  Object o2 = (Node)((n2 instanceof Node) ? n2 : null);
        if ((o1 == null) && (o2 == null)) {
            return true;
        }
        if (o1 == null) {
            return false;
        }
        if (o2 == null) {
            return false;
        }
        if (n1.values != n2.values) {
            return false;
        }
        return n1.index == n2.index;
    }

    static bool isNotEqual(Node n1, Node n2)
    {
        return !isEqual(n1, n2);
    }

    boolean equals(Object o) 
		{ 
			//return this == (Node)o; 
            return Node.isEqual(this, (Node)o);
		}
		
		int hashCode() 
		{ 
			return 0; 
		}
}

class Table extends LuaState_GCObject
{
    int flags;
    int lsizenode;
    Table metatable;
    List<TValue> array;
    List<LuaObject.Node> node;
    int lastfree;
    LuaState.GCObject gclist;
    int sizearray;
}
