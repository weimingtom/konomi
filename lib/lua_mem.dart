library kurumi;

class LuaMem
{
    static final String MEMERRMSG = "not enough memory";

    static List<int> luaM_reallocv_char(LuaState.lua_State L, List<int> block, int new_size, ClassType t)
    {
      return (char[])luaM_realloc__char(L, block, new_size, t);
    }

    static List<LuaObject.TValue> luaM_reallocv_TValue(LuaState.lua_State L, List<LuaObject.TValue> block, int new_size, ClassType t)
    {
      return (LuaObject.TValue[])luaM_realloc__TValue(L, block, new_size, t);
    }

    static List<LuaObject.TString> luaM_reallocv_TString(LuaState.lua_State L, List<LuaObject.TString> block, int new_size, ClassType t)
    {
      return (LuaObject.TString[])luaM_realloc__TString(L, block, new_size, t);
    }

    static List<LuaState.CallInfo> luaM_reallocv_CallInfo(LuaState.lua_State L, List<LuaState.CallInfo> block, int new_size, ClassType t)
    {
      return (LuaState.CallInfo[])luaM_realloc__CallInfo(L, block, new_size, t);
    }

    static List<int> luaM_reallocv_long(LuaState.lua_State L, List<int> block, int new_size, ClassType t)
    {
      return (long[])luaM_realloc__long(L, block, new_size, t);
    }

    static List<int> luaM_reallocv_int(LuaState.lua_State L, List<int> block, int new_size, ClassType t)
    {
      return (int[])luaM_realloc__int(L, block, new_size, t);
    }

    static List<LuaObject.Proto> luaM_reallocv_Proto(LuaState.lua_State L, List<LuaObject.Proto> block, int new_size, ClassType t)
    {
      return (LuaObject.Proto[])luaM_realloc__Proto(L, block, new_size, t);
    }

    static List<LuaObject.LocVar> luaM_reallocv_LocVar(LuaState.lua_State L, List<LuaObject.LocVar> block, int new_size, ClassType t)
    {
      return (LuaObject.LocVar[])luaM_realloc__LocVar(L, block, new_size, t);
    }

    static List<LuaObject.Node> luaM_reallocv_Node(LuaState.lua_State L, List<LuaObject.Node> block, int new_size, ClassType t)
    {
      return (LuaObject.Node[])luaM_realloc__Node(L, block, new_size, t);
    }

    static List<LuaState.GCObject> luaM_reallocv_GCObject(LuaState.lua_State L, List<LuaState.GCObject> block, int new_size, ClassType t)
    {
      return (LuaState.GCObject[])luaM_realloc__GCObject(L, block, new_size, t);
    }

    static void luaM_freemem_Udata(LuaState.lua_State L, LuaObject.Udata b, ClassType t)
    {
      luaM_realloc__Udata(L, new LuaObject.Udata[] {b}, 0, t);
    }

    static void luaM_freemem_TString(LuaState.lua_State L, LuaObject.TString b, ClassType t)
    {
        luaM_realloc__TString(L, new List<LuaObject.TString>.from([b]), 0, t);
    }

    static void luaM_free_Table(LuaState.lua_State L, LuaObject.Table b, ClassType t)
    {
        luaM_realloc__Table(L, new List<LuaObject.Table>.from([b]), 0, t);
    }

    static void luaM_free_UpVal(LuaState.lua_State L, LuaObject.UpVal b, ClassType t)
    {
        luaM_realloc__UpVal(L, new List<LuaObject.UpVal>.from([b]), 0, t);
    }

    static void luaM_free_Proto(LuaState.lua_State L, LuaObject.Proto b, ClassType t)
    {
        luaM_realloc__Proto(L, new List<LuaObject.Proto>.from([b]), 0, t);
    }

    static void luaM_freearray_long(LuaState.lua_State L, List<int> b, ClassType t)
    {
        luaM_reallocv_long(L, b, 0, t);
    }

    static void luaM_freearray_Proto(LuaState.lua_State L, List<LuaObject.Proto> b, ClassType t)
    {
        luaM_reallocv_Proto(L, b, 0, t);
    }

    static void luaM_freearray_TValue(LuaState.lua_State L, List<LuaObject.TValue> b, ClassType t)
    {
        luaM_reallocv_TValue(L, b, 0, t);
    }

    static void luaM_freearray_int(LuaState.lua_State L, List<int> b, ClassType t)
    {
        luaM_reallocv_int(L, b, 0, t);
    }

    static void luaM_freearray_LocVar(LuaState.lua_State L, List<LuaObject.LocVar> b, ClassType t)
    {
        luaM_reallocv_LocVar(L, b, 0, t);
    }

    static void luaM_freearray_TString(LuaState.lua_State L, List<LuaObject.TString> b, ClassType t)
    {
        luaM_reallocv_TString(L, b, 0, t);
    }

    static void luaM_freearray_Node(LuaState.lua_State L, List<LuaObject.Node> b, ClassType t)
    {
        luaM_reallocv_Node(L, b, 0, t);
    }

    static void luaM_freearray_CallInfo(LuaState.lua_State L, List<LuaState.CallInfo> b, ClassType t)
    {
        luaM_reallocv_CallInfo(L, b, 0, t);
    }

    static void luaM_freearray_GCObject(LuaState.lua_State L, List<LuaState.GCObject> b, ClassType t)
    {
        luaM_reallocv_GCObject(L, b, 0, t);
    }

    static LuaObject.Proto luaM_new_Proto(LuaState.lua_State L, ClassType t)
    {
      return (LuaObject.Proto)luaM_realloc__Proto(L, t);
    }

    static LuaObject.Closure luaM_new_Closure(LuaState.lua_State L, ClassType t)
    {
      return (LuaObject.Closure)luaM_realloc__Closure(L, t);
    }

    static LuaObject.UpVal luaM_new_UpVal(LuaState.lua_State L, ClassType t)
    {
      return (LuaObject.UpVal)luaM_realloc__UpVal(L, t);
    }

    static LuaState.lua_State luaM_new_lua_State(LuaState.lua_State L, ClassType t)
    {
      return (LuaState.lua_State)luaM_realloc__lua_State(L, t);
    }

    static LuaObject.Table luaM_new_Table(LuaState.lua_State L, ClassType t)
    {
      return (LuaObject.Table)luaM_realloc__Table(L, t);
    }

    static List<int> luaM_newvector_long(LuaState.lua_State L, int n, ClassType t)
    {
        return luaM_reallocv_long(L, null, n, t);
    }

    static List<LuaObject.TString> luaM_newvector_TString(LuaState.lua_State L, int n, ClassType t)
    {
        return luaM_reallocv_TString(L, null, n, t);
    }

    static List<LuaObject.LocVar> luaM_newvector_LocVar(LuaState.lua_State L, int n, ClassType t)
    {
        return luaM_reallocv_LocVar(L, null, n, t);
    }

    static List<int> luaM_newvector_int(LuaState.lua_State L, int n, ClassType t)
    {
        return luaM_reallocv_int(L, null, n, t);
    }

    static List<LuaObject.Proto> luaM_newvector_Proto(LuaState.lua_State L, int n, ClassType t)
    {
        return luaM_reallocv_Proto(L, null, n, t);
    }

    static List<LuaObject.TValue> luaM_newvector_TValue(LuaState.lua_State L, int n, ClassType t)
    {
        return luaM_reallocv_TValue(L, null, n, t);
    }

    static List<LuaState.CallInfo> luaM_newvector_CallInfo(LuaState.lua_State L, int n, ClassType t)
    {
        return luaM_reallocv_CallInfo(L, null, n, t);
    }

    static List<LuaObject.Node> luaM_newvector_Node(LuaState.lua_State L, int n, ClassType t)
    {
        return luaM_reallocv_Node(L, null, n, t);
    }

    static void luaM_growvector_long(LuaState.lua_State L, List<List<int>> v, int nelems, List<int> size, int limit, CLib.CharPtr e, ClassType t)
    {
        if ((nelems + 1) > size[0]) {
          v[0] = (long[])luaM_growaux__long(L, v, size, limit, e, t); //ref - ref
        }
    }

    static void luaM_growvector_Proto(LuaState.lua_State L, List<List<LuaObject.Proto>> v, int nelems, List<int> size, int limit, CLib.CharPtr e, ClassType t)
    {
        if ((nelems + 1) > size[0]) {
          v[0] = (LuaObject.Proto[])luaM_growaux__Proto(L, v, size, limit, e, t); //ref - ref
        }
    }

    static void luaM_growvector_TString(LuaState.lua_State L, List<List<LuaObject.TString>> v, int nelems, List<int> size, int limit, CLib.CharPtr e, ClassType t)
    {
        if ((nelems + 1) > size[0]) {
          v[0] = (LuaObject.TString[])luaM_growaux__TString(L, v, size, limit, e, t); //ref - ref
        }
    }

    static void luaM_growvector_TValue(LuaState.lua_State L, List<List<LuaObject.TValue>> v, int nelems, List<int> size, int limit, CLib.CharPtr e, ClassType t)
    {
        if ((nelems + 1) > size[0]) {
          v[0] = (LuaObject.TValue[])luaM_growaux__TValue(L, v, size, limit, e, t); //ref - ref
        }
    }

    static void luaM_growvector_LocVar(LuaState.lua_State L, List<List<LuaObject.LocVar>> v, int nelems, List<int> size, int limit, CLib.CharPtr e, ClassType t)
    {
        if ((nelems + 1) > size[0]) {
          v[0] = (LuaObject.LocVar[])luaM_growaux__LocVar(L, v, size, limit, e, t); //ref - ref
        }
    }

    static void luaM_growvector_int(LuaState.lua_State L, List<List<int>> v, int nelems, List<int> size, int limit, CLib.CharPtr e, ClassType t)
    {
        if ((nelems + 1) > size[0]) {
          v[0] = (int[])luaM_growaux__int(L, v, size, limit, e, t); //ref - ref
        }
    }

    static List<int> luaM_reallocvector_char(LuaState.lua_State L, List<List<int>> v, int oldn, int n, ClassType t)
    {
        ClassType_.Assert(((v[0] == null) && (oldn == 0)) || (v[0].length == oldn));
        v[0] = luaM_reallocv_char(L, v[0], n, t);
        return v[0];
    }

    static List<LuaObject.TValue> luaM_reallocvector_TValue(LuaState.lua_State L, List<List<LuaObject.TValue>> v, int oldn, int n, ClassType t)
    {
        ClassType_.Assert(((v[0] == null) && (oldn == 0)) || (v[0].length == oldn));
        v[0] = luaM_reallocv_TValue(L, v[0], n, t);
        return v[0];
    }

    static List<LuaObject.TString> luaM_reallocvector_TString(LuaState.lua_State L, List<List<LuaObject.TString>> v, int oldn, int n, ClassType t)
    {
        ClassType_.Assert(((v[0] == null) && (oldn == 0)) || (v[0].length == oldn));
        v[0] = luaM_reallocv_TString(L, v[0], n, t);
        return v[0];
    }

    static List<LuaState.CallInfo> luaM_reallocvector_CallInfo(LuaState.lua_State L, List<List<LuaState.CallInfo>> v, int oldn, int n, ClassType t)
    {
        ClassType_.Assert(((v[0] == null) && (oldn == 0)) || (v[0].length == oldn));
        v[0] = luaM_reallocv_CallInfo(L, v[0], n, t);
        return v[0];
    }

    static List<int> luaM_reallocvector_long(LuaState.lua_State L, List<List<int>> v, int oldn, int n, ClassType t)
    {
        ClassType_.Assert(((v[0] == null) && (oldn == 0)) || (v[0].length == oldn));
        v[0] = luaM_reallocv_long(L, v[0], n, t);
        return v[0];
    }

    static List<int> luaM_reallocvector_int(LuaState.lua_State L, List<List<int>> v, int oldn, int n, ClassType t)
    {
        ClassType_.Assert(((v[0] == null) && (oldn == 0)) || (v[0].length == oldn));
        v[0] = luaM_reallocv_int(L, v[0], n, t);
        return v[0];
    }

    static List<LuaObject.Proto> luaM_reallocvector_Proto(LuaState.lua_State L, List<List<LuaObject.Proto>> v, int oldn, int n, ClassType t)
    {
        ClassType_.Assert(((v[0] == null) && (oldn == 0)) || (v[0].length == oldn));
        v[0] = luaM_reallocv_Proto(L, v[0], n, t);
        return v[0];
    }

    static List<LuaObject.LocVar> luaM_reallocvector_LocVar(LuaState.lua_State L, List<List<LuaObject.LocVar>> v, int oldn, int n, ClassType t)
    {
        ClassType_.Assert(((v[0] == null) && (oldn == 0)) || (v[0].length == oldn));
        v[0] = luaM_reallocv_LocVar(L, v[0], n, t);
        return v[0];
    }
    static const int MINSIZEARRAY = 4;

    static List<int> luaM_growaux__long(LuaState.lua_State L, List<List<int>> block, List<int> size, int limit, CLib.CharPtr errormsg, ClassType t)
    {
        List<int> newblock;
        int newsize;
        if (size[0] >= (limit ~/ 2)) {
            if (size[0] >= limit) {
                LuaDebug.luaG_runerror(L, errormsg);
            }
            newsize = limit;
        } else {
            newsize = (size[0] * 2);
            if (newsize < MINSIZEARRAY) {
                newsize = MINSIZEARRAY;
            }
        }
        newblock = luaM_reallocv_long(L, block[0], newsize, t);
        size[0] = newsize;
        return newblock;
    }

    static List<LuaObject.Proto> luaM_growaux__Proto(LuaState.lua_State L, List<List<LuaObject.Proto>> block, List<int> size, int limit, CLib.CharPtr errormsg, ClassType t)
    {
        LuaObject.Proto[] newblock;
        int newsize;
        if (size[0] >= (limit ~/ 2)) {
            if (size[0] >= limit) {
                LuaDebug.luaG_runerror(L, errormsg);
            }
            newsize = limit;
        } else {
            newsize = (size[0] * 2);
            if (newsize < MINSIZEARRAY) {
                newsize = MINSIZEARRAY;
            }
        }
        newblock = luaM_reallocv_Proto(L, block[0], newsize, t);
        size[0] = newsize;
        return newblock;
    }

    static List<LuaObject.TString> luaM_growaux__TString(LuaState.lua_State L, List<List<LuaObject.TString>> block, List<int> size, int limit, CLib.CharPtr errormsg, ClassType t)
    {
        LuaObject.TString[] newblock;
        int newsize;
        if (size[0] >= (limit ~/ 2)) {
            if (size[0] >= limit) {
                LuaDebug.luaG_runerror(L, errormsg);
            }
            newsize = limit;
        } else {
            newsize = (size[0] * 2);
            if (newsize < MINSIZEARRAY) {
                newsize = MINSIZEARRAY;
            }
        }
        newblock = luaM_reallocv_TString(L, block[0], newsize, t);
        size[0] = newsize;
        return newblock;
    }

    static List<LuaObject.TValue> luaM_growaux__TValue(LuaState.lua_State L, List<List<LuaObject.TValue>> block, List<int> size, int limit, CLib.CharPtr errormsg, ClassType t)
    {
        LuaObject.TValue[] newblock;
        int newsize;
        if (size[0] >= (limit ~/ 2)) {
            if (size[0] >= limit) {
                LuaDebug.luaG_runerror(L, errormsg);
            }
            newsize = limit;
        } else {
            newsize = (size[0] * 2);
            if (newsize < MINSIZEARRAY) {
                newsize = MINSIZEARRAY;
            }
        }
        newblock = luaM_reallocv_TValue(L, block[0], newsize, t);
        size[0] = newsize;
        return newblock;
    }

    static List<LuaObject.LocVar> luaM_growaux__LocVar(LuaState.lua_State L, List<List<LuaObject.LocVar>> block, List<int> size, int limit, CLib.CharPtr errormsg, ClassType t)
    {
        LuaObject.LocVar[] newblock;
        int newsize;
        if (size[0] >= (limit ~/ 2)) {
            if (size[0] >= limit) {
                LuaDebug.luaG_runerror(L, errormsg);
            }
            newsize = limit;
        } else {
            newsize = (size[0] * 2);
            if (newsize < MINSIZEARRAY) {
                newsize = MINSIZEARRAY;
            }
        }
        newblock = luaM_reallocv_LocVar(L, block[0], newsize, t);
        size[0] = newsize;
        return newblock;
    }

    static List<int> luaM_growaux__int(LuaState.lua_State L, List<List<int>> block, List<int> size, int limit, CLib.CharPtr errormsg, ClassType t)
    {
        List<int> newblock;
        int newsize;
        if (size[0] >= (limit ~/ 2)) {
            if (size[0] >= limit) {
                LuaDebug.luaG_runerror(L, errormsg);
            }
            newsize = limit;
        } else {
            newsize = (size[0] * 2);
            if (newsize < MINSIZEARRAY) {
                newsize = MINSIZEARRAY;
            }
        }
        newblock = luaM_reallocv_int(L, block[0], newsize, t);
        size[0] = newsize;
        return newblock;
    }

    static Object luaM_toobig(LuaState.lua_State L)
    {
        LuaDebug.luaG_runerror(L, CLib.CharPtr.toCharPtr("memory allocation error: block too big"));
        return null;
    }

    static Object luaM_realloc_(LuaState.lua_State L, ClassType t)
    {
        int unmanaged_size = CLib.GetUnmanagedSize(t);
        int nsize = unmanaged_size;
        Object new_obj = t.Alloc();
        AddTotalBytes(L, nsize);
        return new_obj;
    }

    static Object luaM_realloc__Proto(LuaState.lua_State L, ClassType t)
    {
        int unmanaged_size = t.GetUnmanagedSize();
        int nsize = unmanaged_size;
        LuaObject.Proto new_obj = (LuaObject.Proto)t.Alloc(); //System.Activator.CreateInstance(typeof(T));
        AddTotalBytes(L, nsize);
        return new_obj;
    }

    static Object luaM_realloc__Closure(LuaState.lua_State L, ClassType t)
    {
        int unmanaged_size = t.GetUnmanagedSize();
        int nsize = unmanaged_size;
        LuaObject.Closure new_obj = (LuaObject.Closure)t.Alloc(); //System.Activator.CreateInstance(typeof(T));
        AddTotalBytes(L, nsize);
        return new_obj;
    }

    static Object luaM_realloc__UpVal(LuaState.lua_State L, ClassType t)
    {
        int unmanaged_size = t.GetUnmanagedSize();
        int nsize = unmanaged_size;
        LuaObject.UpVal new_obj = (LuaObject.UpVal)t.Alloc(); //System.Activator.CreateInstance(typeof(T));
        AddTotalBytes(L, nsize);
        return new_obj;
    }

    static Object luaM_realloc__lua_State(LuaState.lua_State L, ClassType t)
    {
        int unmanaged_size = t.GetUnmanagedSize();
        int nsize = unmanaged_size;
        LuaState.lua_State new_obj = (LuaState.lua_State)t.Alloc(); //System.Activator.CreateInstance(typeof(T));
        AddTotalBytes(L, nsize);
        return new_obj;
    }

    static Object luaM_realloc__Table(LuaState.lua_State L, ClassType t)
    {
        int unmanaged_size = t.GetUnmanagedSize();
        int nsize = unmanaged_size;
        LuaObject.Table new_obj = (LuaObject.Table)t.Alloc(); //System.Activator.CreateInstance(typeof(T));
        AddTotalBytes(L, nsize);
        return new_obj;
    }

    static Object luaM_realloc__Table(LuaState.lua_State L, List<LuaObject.Table> old_block, int new_size, ClassType t)
    {
        int unmanaged_size = t.GetUnmanagedSize();
        int old_size = ((old_block == null) ? 0 : old_block.length);
        int osize = (old_size * unmanaged_size);
        int nsize = (new_size * unmanaged_size);
        LuaObject.Table[] new_block = new LuaObject.Table[new_size];
        for (int i = 0; i < Math.min(old_size, new_size); i++) {
            new_block[i] = old_block[i];
        }
        for (int i = old_size; i < new_size; i++) {
          new_block[i] = (LuaObject.Table)t.Alloc(); // System.Activator.CreateInstance(typeof(T));
        }
        if (CanIndex(t)) {
            for (int i = 0; i < new_size; i++) {
                LuaObject.ArrayElement elem = (LuaObject.ArrayElement)((new_block[i] instanceof LuaObject.ArrayElement) ? new_block[i] : null);
                ClassType_.Assert(elem != null, String_.format("Need to derive type %1\$s from ArrayElement", t.GetTypeString()));
                elem.set_index(i);
                elem.set_array(new_block);
            }
        }
        SubtractTotalBytes(L, osize);
        AddTotalBytes(L, nsize);
        return new_block;
    }

    static Object luaM_realloc__UpVal(LuaState.lua_State L, List<LuaObject.UpVal> old_block, int new_size, ClassType t)
    {
        int unmanaged_size = t.GetUnmanagedSize();
        int old_size = ((old_block == null) ? 0 : old_block.length);
        int osize = (old_size * unmanaged_size);
        int nsize = (new_size * unmanaged_size);
        LuaObject.UpVal[] new_block = new LuaObject.UpVal[new_size];
        for (int i = 0; i < Math.min(old_size, new_size); i++) {
            new_block[i] = old_block[i];
        }
        for (int i = old_size; i < new_size; i++) {
            new_block[i] = (LuaObject.UpVal)t.Alloc(); // System.Activator.CreateInstance(typeof(T));
        }
        if (CanIndex(t)) {
            for (int i = 0; i < new_size; i++) {
                LuaObject.ArrayElement elem = (LuaObject.ArrayElement)((new_block[i] instanceof LuaObject.ArrayElement) ? new_block[i] : null);
                ClassType_.Assert(elem != null, String_.format("Need to derive type %1\$s from ArrayElement", t.GetTypeString()));
                elem.set_index(i);
                elem.set_array(new_block);
            }
        }
        SubtractTotalBytes(L, osize);
        AddTotalBytes(L, nsize);
        return new_block;
    }

    static Object luaM_realloc__char(LuaState.lua_State L, List<int> old_block, int new_size, ClassType t)
    {
        int unmanaged_size = t.GetUnmanagedSize();
        int old_size = ((old_block == null) ? 0 : old_block.length);
        int osize = (old_size * unmanaged_size);
        int nsize = (new_size * unmanaged_size);
        List<int> new_block = new List<int>(new_size);
        for (int i = 0; i < Math.min(old_size, new_size); i++) {
            new_block[i] = old_block[i];
        }
        for (int i = old_size; i < new_size; i++) {
            new_block[i] = t.Alloc().charValue();
        }
        if (CanIndex(t)) {
        }
        SubtractTotalBytes(L, osize);
        AddTotalBytes(L, nsize);
        return new_block;
    }

    static Object luaM_realloc__TValue(LuaState.lua_State L, List<LuaObject.TValue> old_block, int new_size, ClassType t)
    {
        int unmanaged_size = t.GetUnmanagedSize();
        int old_size = ((old_block == null) ? 0 : old_block.length);
        int osize = (old_size * unmanaged_size);
        int nsize = (new_size * unmanaged_size);
        LuaObject.TValue[] new_block = new LuaObject.TValue[new_size];
        for (int i = 0; i < Math.min(old_size, new_size); i++) {
            new_block[i] = old_block[i];
        }
        for (int i = old_size; i < new_size; i++) {
          new_block[i] = (LuaObject.TValue)t.Alloc(); // System.Activator.CreateInstance(typeof(T));
        }
        if (CanIndex(t)) {
            for (int i = 0; i < new_size; i++) {
                LuaObject.ArrayElement elem = (LuaObject.ArrayElement)((new_block[i] instanceof LuaObject.ArrayElement) ? new_block[i] : null);
                ClassType_.Assert(elem != null, String_.format("Need to derive type %1\$s from ArrayElement", t.GetTypeString()));
                elem.set_index(i);
                elem.set_array(new_block);
            }
        }
        SubtractTotalBytes(L, osize);
        AddTotalBytes(L, nsize);
        return new_block;
    }

    static Object luaM_realloc__TString(LuaState.lua_State L, List<LuaObject.TString> old_block, int new_size, ClassType t)
    {
        int unmanaged_size = t.GetUnmanagedSize();
        int old_size = ((old_block == null) ? 0 : old_block.length);
        int osize = (old_size * unmanaged_size);
        int nsize = (new_size * unmanaged_size);
        LuaObject.TString[] new_block = new LuaObject.TString[new_size];
        for (int i = 0; i < Math.min(old_size, new_size); i++) {
            new_block[i] = old_block[i];
        }
        for (int i = old_size; i < new_size; i++) {
            new_block[i] = (LuaObject.TString)t.Alloc(); // System.Activator.CreateInstance(typeof(T));
        }
        if (CanIndex(t)) {
            for (int i = 0; i < new_size; i++) {
                LuaObject.ArrayElement elem = (LuaObject.ArrayElement)((new_block[i] instanceof LuaObject.ArrayElement) ? new_block[i] : null);
                ClassType_.Assert(elem != null, String_.format("Need to derive type %1\$s from ArrayElement", t.GetTypeString()));
                elem.set_index(i);
                elem.set_array(new_block);
            }
        }
        SubtractTotalBytes(L, osize);
        AddTotalBytes(L, nsize);
        return new_block;
    }

    static Object luaM_realloc__Udata(LuaState.lua_State L, List<LuaObject.Udata> old_block, int new_size, ClassType t)
    {
        int unmanaged_size = t.GetUnmanagedSize();
        int old_size = ((old_block == null) ? 0 : old_block.length);
        int osize = (old_size * unmanaged_size);
        int nsize = (new_size * unmanaged_size);
        LuaObject.Udata[] new_block = new LuaObject.Udata[new_size];
        for (int i = 0; i < Math.min(old_size, new_size); i++) {
            new_block[i] = old_block[i];
        }
        for (int i = old_size; i < new_size; i++) {
          new_block[i] = (LuaObject.Udata)t.Alloc(); // System.Activator.CreateInstance(typeof(T));
        }
        if (CanIndex(t)) {
            for (int i = 0; i < new_size; i++) {
                LuaObject.ArrayElement elem = (LuaObject.ArrayElement)((new_block[i] instanceof LuaObject.ArrayElement) ? new_block[i] : null);
                ClassType_.Assert(elem != null, String_.format("Need to derive type %1\$s from ArrayElement", t.GetTypeString()));
                elem.set_index(i);
                elem.set_array(new_block);
            }
        }
        SubtractTotalBytes(L, osize);
        AddTotalBytes(L, nsize);
        return new_block;
    }

    static Object luaM_realloc__CallInfo(LuaState.lua_State L, List<LuaState.CallInfo> old_block, int new_size, ClassType t)
    {
        int unmanaged_size = t.GetUnmanagedSize();
        int old_size = ((old_block == null) ? 0 : old_block.length);
        int osize = (old_size * unmanaged_size);
        int nsize = (new_size * unmanaged_size);
        LuaState.CallInfo[] new_block = new LuaState.CallInfo[new_size];
        for (int i = 0; i < Math.min(old_size, new_size); i++) {
            new_block[i] = old_block[i];
        }
        for (int i = old_size; i < new_size; i++) {
            new_block[i] = (LuaState.CallInfo)t.Alloc(); // System.Activator.CreateInstance(typeof(T));
        }
        if (CanIndex(t)) {
            for (int i = 0; i < new_size; i++) {
                LuaObject.ArrayElement elem = (LuaObject.ArrayElement)((new_block[i] instanceof LuaObject.ArrayElement) ? new_block[i] : null);
                ClassType_.Assert(elem != null, String_.format("Need to derive type %1\$s from ArrayElement", t.GetTypeString()));
                elem.set_index(i);
                elem.set_array(new_block);
            }
        }
        SubtractTotalBytes(L, osize);
        AddTotalBytes(L, nsize);
        return new_block;
    }

    static Object luaM_realloc__long(LuaState.lua_State L, List<int> old_block, int new_size, ClassType t)
    {
        int unmanaged_size = t.GetUnmanagedSize();
        int old_size = ((old_block == null) ? 0 : old_block.length);
        int osize = (old_size * unmanaged_size);
        int nsize = (new_size * unmanaged_size);
        long[] new_block = new long[new_size];
        for (int i = 0; i < Math.min(old_size, new_size); i++) {
            new_block[i] = old_block[i];
        }
        for (int i = old_size; i < new_size; i++) {
          new_block[i] = ((Long)t.Alloc()).longValue(); // System.Activator.CreateInstance(typeof(T));
        }
        if (CanIndex(t)) {
        }
        SubtractTotalBytes(L, osize);
        AddTotalBytes(L, nsize);
        return new_block;
    }

    static Object luaM_realloc__int(LuaState.lua_State L, List<int> old_block, int new_size, ClassType t)
    {
        int unmanaged_size = t.GetUnmanagedSize();
        int old_size = ((old_block == null) ? 0 : old_block.length);
        int osize = (old_size * unmanaged_size);
        int nsize = (new_size * unmanaged_size);
        int[] new_block = new int[new_size];
        for (int i = 0; i < Math.min(old_size, new_size); i++) {
            new_block[i] = old_block[i];
        }
        for (int i = old_size; i < new_size; i++) {
          new_block[i] = ((Integer)t.Alloc()).intValue(); // System.Activator.CreateInstance(typeof(T));
        }
        if (CanIndex(t)) {
        }
        SubtractTotalBytes(L, osize);
        AddTotalBytes(L, nsize);
        return new_block;
    }

    static Object luaM_realloc__Proto(LuaState.lua_State L, List<LuaObject.Proto> old_block, int new_size, ClassType t)
    {
        int unmanaged_size = t.GetUnmanagedSize();
        int old_size = ((old_block == null) ? 0 : old_block.length);
        int osize = (old_size * unmanaged_size);
        int nsize = (new_size * unmanaged_size);
        LuaObject.Proto[] new_block = new LuaObject.Proto[new_size];
        for (int i = 0; i < Math.min(old_size, new_size); i++) {
            new_block[i] = old_block[i];
        }
        for (int i = old_size; i < new_size; i++) {
          new_block[i] = (LuaObject.Proto)t.Alloc(); // System.Activator.CreateInstance(typeof(T));
        }
        if (CanIndex(t)) {
            for (int i = 0; i < new_size; i++) {
                LuaObject.ArrayElement elem = (LuaObject.ArrayElement)((new_block[i] instanceof LuaObject.ArrayElement) ? new_block[i] : null);
                ClassType_.Assert(elem != null, String_.format("Need to derive type %1\$s from ArrayElement", t.GetTypeString()));
                elem.set_index(i);
                elem.set_array(new_block);
            }
        }
        SubtractTotalBytes(L, osize);
        AddTotalBytes(L, nsize);
        return new_block;
    }

    static Object luaM_realloc__LocVar(LuaState.lua_State L, List<LuaObject.LocVar> old_block, int new_size, ClassType t)
    {
        int unmanaged_size = t.GetUnmanagedSize();
        int old_size = ((old_block == null) ? 0 : old_block.length);
        int osize = (old_size * unmanaged_size);
        int nsize = (new_size * unmanaged_size);
        LuaObject.LocVar[] new_block = new LuaObject.LocVar[new_size];
        for (int i = 0; i < Math.min(old_size, new_size); i++) {
            new_block[i] = old_block[i];
        }
        for (int i = old_size; i < new_size; i++) {
          new_block[i] = (LuaObject.LocVar)t.Alloc(); // System.Activator.CreateInstance(typeof(T));
        }
        if (CanIndex(t)) {
            for (int i = 0; i < new_size; i++) {
                //FIXME:???
                LuaObject.ArrayElement elem = (LuaObject.ArrayElement)((new_block[i] instanceof LuaObject.ArrayElement) ? new_block[i] : null);
                ClassType_.Assert(elem != null, String_.format("Need to derive type %1\$s from ArrayElement", t.GetTypeString()));
                elem.set_index(i);
                elem.set_array(new_block);
            }
        }
        SubtractTotalBytes(L, osize);
        AddTotalBytes(L, nsize);
        return new_block;
    }

    static Object luaM_realloc__Node(LuaState.lua_State L, List<LuaObject.Node> old_block, int new_size, ClassType t)
    {
        int unmanaged_size = t.GetUnmanagedSize();
        int old_size = ((old_block == null) ? 0 : old_block.length);
        int osize = (old_size * unmanaged_size);
        int nsize = (new_size * unmanaged_size);
        LuaObject.Node[] new_block = new LuaObject.Node[new_size];
        for (int i = 0; i < Math.min(old_size, new_size); i++) {
            new_block[i] = old_block[i];
        }
        for (int i = old_size; i < new_size; i++) {
            new_block[i] = (LuaObject.Node)t.Alloc(); // System.Activator.CreateInstance(typeof(T));
        }
        if (CanIndex(t)) {
            for (int i = 0; i < new_size; i++) {
                LuaObject.ArrayElement elem = (LuaObject.ArrayElement)((new_block[i] instanceof LuaObject.ArrayElement) ? new_block[i] : null);
                ClassType_.Assert(elem != null, String_.format("Need to derive type %1\$s from ArrayElement", t.GetTypeString()));
                elem.set_index(i);
                elem.set_array(new_block);
            }
        }
        SubtractTotalBytes(L, osize);
        AddTotalBytes(L, nsize);
        return new_block;
    }

    static Object luaM_realloc__GCObject(LuaState.lua_State L, List<LuaState.GCObject> old_block, int new_size, ClassType t)
    {
        int unmanaged_size = t.GetUnmanagedSize();
        int old_size = ((old_block == null) ? 0 : old_block.length);
        int osize = (old_size * unmanaged_size);
        int nsize = (new_size * unmanaged_size);
        LuaState.GCObject[] new_block = new LuaState.GCObject[new_size];
        for (int i = 0; i < Math.min(old_size, new_size); i++) {
            new_block[i] = old_block[i];
        }
        for (int i = old_size; i < new_size; i++) {
            new_block[i] = (LuaState.GCObject)t.Alloc(); // System.Activator.CreateInstance(typeof(T));
        }
        if (CanIndex(t)) {
            for (int i = 0; i < new_size; i++) {
                LuaObject.ArrayElement elem = (LuaObject.ArrayElement)((new_block[i] instanceof LuaObject.ArrayElement) ? new_block[i] : null);
                ClassType_.Assert(elem != null, String_.format("Need to derive type %1\$s from ArrayElement", t.GetTypeString()));
                elem.set_index(i);
                elem.set_array(new_block);
            }
        }
        SubtractTotalBytes(L, osize);
        AddTotalBytes(L, nsize);
        return new_block;
    }

    static bool CanIndex(ClassType t)
    {
        return t.CanIndex();
    }

    static void AddTotalBytes(LuaState.lua_State L, int num_bytes)
    {
        LuaState.G(L).totalbytes += num_bytes;
    }

    static void SubtractTotalBytes(LuaState.lua_State L, int num_bytes)
    {
        LuaState.G(L).totalbytes -= num_bytes;
    }
}
