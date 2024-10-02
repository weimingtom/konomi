library kurumi;

class LuaTable
{

    static LuaObject.Node gnode(LuaObject.Table t, int i)
    {
        return t.node[i];
    }

    static LuaObject.TKey_nk gkey(LuaObject.Node n)
    {
        return n.i_key.nk;
    }

    static LuaObject.TValue gval(LuaObject.Node n)
    {
        return n.i_val;
    }

    static LuaObject.Node gnext(LuaObject.Node n)
    {
        return n.i_key.nk.next;
    }

    static void gnext_set(LuaObject.Node n, LuaObject.Node v)
    {
        n.i_key.nk.next = v;
    }

    static LuaObject.TValue key2tval(LuaObject.Node n)
    {
        return n.i_key.getTvk();
    }
    static const int MAXBITS = 26;
    static const int MAXASIZE = (1 << MAXBITS);

    static LuaObject.Node hashpow2(LuaObject.Table t, double n)
    {
        return gnode(t, CLib.lmod(n, LuaObject.sizenode(t)));
    }

    static LuaObject.Node hashstr(LuaObject.Table t, LuaObject.TString str)
    {
        return hashpow2(t, str.getTsv().hash);
    }

    static LuaObject.Node hashboolean(LuaObject.Table t, int p)
    {
        return hashpow2(t, p);
    }

    static LuaObject.Node hashmod(LuaObject.Table t, int n)
    {
        return gnode(t, n % ((LuaObject.sizenode(t) - 1) | 1));
    }

    static LuaObject.Node hashpointer(LuaObject.Table t, Object p)
    {
        return hashmod(t, p.hashCode());
    }
    static const int numints = ClassType.GetNumInts();
    static LuaObject.Node dummynode_ = new LuaObject.Node(new LuaObject.TValue(new LuaObject.Value(), Lua.LUA_TNIL), new LuaObject.TKey(new LuaObject.Value(), Lua.LUA_TNIL, null));
    static LuaObject.Node dummynode = dummynode_;

    static LuaObject.Node hashnum(LuaObject.Table t, double n)
    {
        List<int> a = ClassType.GetBytes(n);
        for (int i = 1; i < a.length; i++) {
            a[0] += a[i];
        }
        return hashmod(t, a[0] & 15);
    }

    static LuaObject.Node mainposition(LuaObject.Table t, LuaObject.TValue key)
    {
        switch (LuaObject.ttype(key)) {
            case Lua.LUA_TNUMBER:
                return hashnum(t, LuaObject.nvalue(key));
            case Lua.LUA_TSTRING:
                return hashstr(t, LuaObject.rawtsvalue(key));
            case Lua.LUA_TBOOLEAN:
                return hashboolean(t, LuaObject.bvalue(key));
            case Lua.LUA_TLIGHTUSERDATA:
                return hashpointer(t, LuaObject.pvalue(key));
            default:
                return hashpointer(t, LuaObject.gcvalue(key));
        }
    }

    static int arrayindex(LuaObject.TValue key)
    {
        if (LuaObject.ttisnumber(key)) {
            double n = LuaObject.nvalue(key);
            List<int> k = new List<int>(1);
            LuaConf.lua_number2int(k, n);
            if (LuaConf.luai_numeq(LuaLimits.cast_num(k[0]), n)) {
                return k[0];
            }
        }
        return -1;
    }

    static int findindex(LuaState.lua_State L, LuaObject.Table t, LuaObject.TValue key)
    {
        int i;
        if (LuaObject.ttisnil(key)) {
            return -1;
        }
        i = arrayindex(key);
        if ((0 < i) && (i <= t.sizearray)) {
            return i - 1;
        } else {
            LuaObject.Node n = mainposition(t, key);
            do {
                if ((LuaObject.luaO_rawequalObj(key2tval(n), key) != 0) || (((LuaObject.ttype(gkey(n)) == LuaObject.LUA_TDEADKEY) && LuaObject.iscollectable(key)) && (LuaObject.gcvalue(gkey(n)) == LuaObject.gcvalue(key)))) {
                    i = LuaLimits.cast_int(LuaObject.Node.minus(n, gnode(t, 0)));
                    return i + t.sizearray;
                } else {
                    n = gnext(n);
                }
            } while (LuaObject.Node.isNotEqual(n, null));
            LuaDebug.luaG_runerror(L, CLib.CharPtr.toCharPtr("invalid key to " + LuaConf.LUA_QL("next")));
            return 0;
        }
    }

    static int luaH_next(LuaState.lua_State L, LuaObject.Table t, LuaObject.TValue key)
    {
        int i = findindex(L, t, key);
        for (i++; i < t.sizearray; i++) {
            if (!LuaObject.ttisnil(t.array[i])) {
                LuaObject.setnvalue(key, LuaLimits.cast_num(i + 1));
                LuaObject.setobj2s(L, LuaObject.TValue.plus(key, 1), t.array[i]);
                return 1;
            }
        }
        for ((i -= t.sizearray); i < LuaObject.sizenode(t); i++) {
            if (!LuaObject.ttisnil(gval(gnode(t, i)))) {
                LuaObject.setobj2s(L, key, key2tval(gnode(t, i)));
                LuaObject.setobj2s(L, LuaObject.TValue.plus(key, 1), gval(gnode(t, i)));
                return 1;
            }
        }
        return 0;
    }

    static int computesizes(List<int> nums, List<int> narray)
    {
        int i;
        int twotoi;
        int a = 0;
        int na = 0;
        int n = 0;
        (i = 0);
        (twotoi = 1);
        for (; (twotoi ~/ 2) < narray[0]; i++, (twotoi *= 2)) {
            if (nums[i] > 0) {
                a += nums[i];
                if (a > (twotoi ~/ 2)) {
                    n = twotoi;
                    na = a;
                }
            }
            if (a == narray[0]) {
                break;
            }
        }
        narray[0] = n;
        LuaLimits.lua_assert(((narray[0] ~/ 2) <= na) && (na <= narray[0]));
        return na;
    }

    static int countint(LuaObject.TValue key, List<int> nums)
    {
        int k = arrayindex(key);
        if ((0 < k) && (k <= MAXASIZE)) {
            nums[LuaObject.ceillog2(k)]++;
            return 1;
        } else {
            return 0;
        }
    }

    static int numusearray(LuaObject.Table t, List<int> nums)
    {
        int lg;
        int ttlg;
        int ause = 0;
        int i = 1;
        (lg = 0);
        (ttlg = 1);
        for (; lg <= MAXBITS; lg++, (ttlg *= 2)) {
            int lc = 0;
            int lim = ttlg;
            if (lim > t.sizearray) {
                lim = t.sizearray;
                if (i > lim) {
                    break;
                }
            }
            for (; i <= lim; i++) {
                if (!LuaObject.ttisnil(t.array[i - 1])) {
                    lc++;
                }
            }
            nums[lg] += lc;
            ause += lc;
        }
        return ause;
    }

    static int numusehash(LuaObject.Table t, List<int> nums, List<int> pnasize)
    {
        int totaluse = 0;
        int ause = 0;
        int i = LuaObject.sizenode(t);
        while (i-- != 0) {
            LuaObject.Node n = t.node[i];
            if (!LuaObject.ttisnil(gval(n))) {
                ause += countint(key2tval(n), nums);
                totaluse++;
            }
        }
        pnasize[0] += ause;
        return totaluse;
    }

    static void setarrayvector(LuaState.lua_State L, LuaObject.Table t, int size)
    {
        int i;
        LuaObject.TValue[][] array_ref = new LuaObject.TValue[1][];
        array_ref[0] = t.array;
        LuaMem.luaM_reallocvector_TValue(L, array_ref, t.sizearray, size, new ClassType(ClassType_.TYPE_TVALUE));
        t.array = array_ref[0];
        for ((i = t.sizearray); i < size; i++) {
            LuaObject.setnilvalue(t.array[i]);
        }
        t.sizearray = size;
    }

    static void setnodevector(LuaState.lua_State L, LuaObject.Table t, int size)
    {
        int lsize;
        if (size == 0) {
            t.node = new LuaObject.Node[] { dummynode }; // use common `dummynode' 
            lsize = 0;
        } else {
            int i;
            lsize = LuaObject.ceillog2(size);
            if (lsize > MAXBITS) {
                LuaDebug.luaG_runerror(L, CLib.CharPtr.toCharPtr("table overflow"));
            }
            size = LuaObject.twoto(lsize);
            LuaObject.Node[] nodes = LuaMem.luaM_newvector_Node(L, size, new ClassType(ClassType.TYPE_NODE));
            t.node = nodes;
            for ((i = 0); i < size; i++) {
                LuaObject.Node n = gnode(t, i);
                gnext_set(n, null);
                LuaObject.setnilvalue(gkey(n));
                LuaObject.setnilvalue(gval(n));
            }
        }
        t.lsizenode = LuaLimits.cast_byte(lsize);
        t.lastfree = size;
    }

    static void resize(LuaState.lua_State L, LuaObject.Table t, int nasize, int nhsize)
    {
        int i;
        int oldasize = t.sizearray;
        int oldhsize = t.lsizenode;
        LuaObject.Node[] nold = t.node; // save old hash... 
        if (nasize > oldasize) {
            setarrayvector(L, t, nasize);
        }
        setnodevector(L, t, nhsize);
        if (nasize < oldasize) {
            t.sizearray = nasize;
            for ((i = nasize); i < oldasize; i++) {
                if (!LuaObject.ttisnil(t.array[i])) {
                    LuaObject.setobjt2t(L, luaH_setnum(L, t, i + 1), t.array[i]);
                }
            }
            LuaObject.TValue[][] array_ref = new LuaObject.TValue[1][];
            array_ref[0] = t.array;
            LuaMem.luaM_reallocvector_TValue(L, array_ref, oldasize, nasize, new ClassType(ClassType_.TYPE_TVALUE));
            t.array = array_ref[0];
        }
        for ((i = (LuaObject.twoto(oldhsize) - 1)); i >= 0; i--) {
            LuaObject.Node old = nold[i];
            if (!LuaObject.ttisnil(gval(old))) {
                LuaObject.setobjt2t(L, luaH_set(L, t, key2tval(old)), gval(old));
            }
        }
        if (LuaObject.Node.isNotEqual(nold[0], dummynode)) {
            LuaMem.luaM_freearray_Node(L, nold, new ClassType(ClassType_.TYPE_NODE));
        }
    }

    static void luaH_resizearray(LuaState.lua_State L, LuaObject.Table t, int nasize)
    {
        int nsize = (LuaObject.Node.isEqual(t.node[0], dummynode) ? 0 : LuaObject.sizenode(t));
        resize(L, t, nasize, nsize);
    }

    static void rehash(LuaState.lua_State L, LuaObject.Table t, LuaObject.TValue ek)
    {
        List<int> nasize = new List<int>(1);
        int na;
        List<int> nums = new List<int>((MAXBITS + 1));
        int i;
        int totaluse;
        for ((i = 0); i <= MAXBITS; i++) {
            nums[i] = 0;
        }
        nasize[0] = numusearray(t, nums);
        totaluse = nasize[0];
        totaluse += numusehash(t, nums, nasize);
        nasize[0] += countint(ek, nums);
        totaluse++;
        na = computesizes(nums, nasize);
        resize(L, t, nasize[0], totaluse - na);
    }

    static LuaObject.Table luaH_new(LuaState.lua_State L, int narray, int nhash)
    {
        LuaObject.Table t = LuaMem.luaM_new_Table(L, new ClassType(ClassType.TYPE_TABLE));
        LuaGC.luaC_link(L, LuaState.obj2gco(t), Lua.LUA_TTABLE);
        t.metatable = null;
        t.flags = LuaLimits.cast_byte(~0);
        t.array = null;
        t.sizearray = 0;
        t.lsizenode = 0;
        t.node = new List<LuaObject.Node>.from([dummynode]);
        setarrayvector(L, t, narray);
        setnodevector(L, t, nhash);
        return t;
    }

    static void luaH_free(LuaState.lua_State L, LuaObject.Table t)
    {
        if (LuaObject.Node.isNotEqual(t.node[0], dummynode)) {
            LuaMem.luaM_freearray_Node(L, t.node, new ClassType(ClassType_.TYPE_NODE));
        }
        LuaMem.luaM_freearray_TValue(L, t.array, new ClassType(ClassType_.TYPE_TVALUE));
        LuaMem.luaM_free_Table(L, t, new ClassType(ClassType_.TYPE_TABLE));
    }

    static LuaObject.Node getfreepos(LuaObject.Table t)
    {
        while (t.lastfree-- > 0) {
            if (LuaObject.ttisnil(gkey(t.node[t.lastfree]))) {
                return t.node[t.lastfree];
            }
        }
        return null;
    }

    static LuaObject.TValue newkey(LuaState.lua_State L, LuaObject.Table t, LuaObject.TValue key)
    {
        LuaObject.Node mp = mainposition(t, key);
        if ((!LuaObject.ttisnil(gval(mp))) || LuaObject.Node.isEqual(mp, dummynode)) {
            LuaObject.Node othern;
			      LuaObject.Node n = getfreepos(t); // get a free place 
            if (LuaObject.Node.isEqual(n, null)) {
                rehash(L, t, key);
                return luaH_set(L, t, key);
            }
            LuaLimits.lua_assert(LuaObject.Node.isNotEqual(n, dummynode));
            othern = mainposition(t, key2tval(mp));
            if (LuaObject.Node.isNotEqual(othern, mp)) {
                while (LuaObject.Node.isNotEqual(gnext(othern), mp)) {
                    othern = gnext(othern);
                }
                gnext_set(othern, n);
                n.i_val = new LuaObject.TValue(mp.i_val);
                n.i_key = new LuaObject.TKey(mp.i_key);
                gnext_set(mp, null);
                LuaObject.setnilvalue(gval(mp));
            } else {
                gnext_set(n, gnext(mp));
                gnext_set(mp, n);
                mp = n;
            }
        }
        gkey(mp).value.copyFrom(key.value);
        gkey(mp).tt = key.tt;
        LuaGC.luaC_barriert(L, t, key);
        LuaLimits.lua_assert(LuaObject.ttisnil(gval(mp)));
        return gval(mp);
    }

    static LuaObject.TValue luaH_getnum(LuaObject.Table t, int key)
    {
        if ((long)(((long)(key - 1)) & 0xffffffffL) < (long)(((long)t.sizearray) & 0xffffffffL)) { //uint - uint
            return t.array[key - 1];
        } else {
            double nk = LuaLimits.cast_num(key);
            LuaObject.Node n = hashnum(t, nk);
            do {
                if (LuaObject.ttisnumber(gkey(n)) && LuaConf.luai_numeq(LuaObject.nvalue(gkey(n)), nk)) {
                    return gval(n);
                } else {
                    n = gnext(n);
                }
            } while (LuaObject.Node.isNotEqual(n, null));
            return LuaObject.luaO_nilobject;
        }
    }

    static LuaObject.TValue luaH_getstr(LuaObject.Table t, LuaObject.TString key)
    {
        LuaObject.Node n = hashstr(t, key);
        do {
            if (LuaObject.ttisstring(gkey(n)) && (LuaObject.rawtsvalue(gkey(n)) == key)) {
                return gval(n);
            } else {
                n = gnext(n);
            }
        } while (LuaObject.Node.isNotEqual(n, null));
        return LuaObject.luaO_nilobject;
    }

    static LuaObject.TValue luaH_get(LuaObject.Table t, LuaObject.TValue key)
    {
        switch (LuaObject.ttype(key)) {
            case Lua.LUA_TNIL:
                return LuaObject.luaO_nilobject;
            case Lua.LUA_TSTRING:
                return luaH_getstr(t, LuaObject.rawtsvalue(key));
            case Lua.LUA_TNUMBER:
                List<int> k = new List<int>(1);
                double n = LuaObject.nvalue(key);
                LuaConf.lua_number2int(k, n);
                if (LuaConf.luai_numeq(LuaLimits.cast_num(k[0]), LuaObject.nvalue(key))) {
                    return luaH_getnum(t, k[0]);
                }
                LuaObject.Node node = mainposition(t, key);
                do {
                    if (LuaObject.luaO_rawequalObj(key2tval(node), key) != 0) {
                        return gval(node);
                    } else {
                        node = gnext(node);
                    }
                } while (LuaObject.Node.isNotEqual(node, null));
                return LuaObject.luaO_nilobject;
            default:
                LuaObject.Node node = mainposition(t, key);
                do {
                    if (LuaObject.luaO_rawequalObj(key2tval(node), key) != 0) {
                        return gval(node);
                    } else {
                        node = gnext(node);
                    }
                } while (LuaObject.Node.isNotEqual(node, null));
                return LuaObject.luaO_nilobject;
        }
    }

    static LuaObject.TValue luaH_set(LuaState.lua_State L, LuaObject.Table t, LuaObject.TValue key)
    {
        LuaObject.TValue p = luaH_get(t, key);
        t.flags = 0;
        if (p != LuaObject.luaO_nilobject) {
            return (LuaObject.TValue)p;
        } else {
            if (LuaObject.ttisnil(key)) {
                LuaDebug.luaG_runerror(L, CLib.CharPtr.toCharPtr("table index is nil"));
            } else {
                if (LuaObject.ttisnumber(key) && LuaConf.luai_numisnan(LuaObject.nvalue(key))) {
                    LuaDebug.luaG_runerror(L, CLib.CharPtr.toCharPtr("table index is NaN"));
                }
            }
            return newkey(L, t, key);
        }
    }

    static LuaObject.TValue luaH_setnum(LuaState.lua_State L, LuaObject.Table t, int key)
    {
        LuaObject.TValue p = luaH_getnum(t, key);
        if (p != LuaObject.luaO_nilobject) {
            return (LuaObject.TValue)p;
        } else {
            LuaObject.TValue k = new LuaObject.TValue();
            LuaObject.setnvalue(k, LuaLimits.cast_num(key));
            return newkey(L, t, k);
        }
    }

    static LuaObject.TValue luaH_setstr(LuaState.lua_State L, LuaObject.Table t, LuaObject.TString key)
    {
        LuaObject.TValue p = luaH_getstr(t, key);
        if (p != LuaObject.luaO_nilobject) {
            return (LuaObject.TValue)p;
        } else {
            LuaObject.TValue k = new LuaObject.TValue();
            LuaObject.setsvalue(L, k, key);
            return newkey(L, t, k);
        }
    }

    static int unbound_search(LuaObject.Table t, int j)
    {
        int i = j;
        j++;
        while (!LuaObject.ttisnil(luaH_getnum(t, j))) {
            i = j;
            j *= 2;
            if (j > LuaLimits.MAX_INT) {
                i = 1;
                while (!LuaObject.ttisnil(luaH_getnum(t, i))) {
                    i++;
                }
                return i - 1;
            }
        }
        while ((j - i) > 1) {
            int m = ((i + j) ~/ 2);
            if (LuaObject.ttisnil(luaH_getnum(t, m))) {
                j = m;
            } else {
                i = m;
            }
        }
        return i;
    }

    static int luaH_getn(LuaObject.Table t)
    {
        int j = t.sizearray;
        if ((j > 0) && LuaObject.ttisnil(t.array[j - 1])) {
            int i = 0;
            while ((j - i) > 1) {
                int m = ((i + j) ~/ 2);
                if (LuaObject.ttisnil(t.array[m - 1])) {
                    j = m;
                } else {
                    i = m;
                }
            }
            return i;
        } else {
            if (LuaObject.Node.isEqual(t.node[0], dummynode)) {
                return j;
            } else {
                return unbound_search(t, j);
            }
        }
    }
}
