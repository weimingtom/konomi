library kurumi;

class LuaStrLib
{

    static int str_len(LuaState.lua_State L)
    {
        List<int> l = new List<int>(1);
        LuaAuxLib.luaL_checklstring(L, 1, l);
        LuaAPI.lua_pushinteger(L, l[0]);
        return 1;
    }

    static int posrelat(int pos, int len)
    {
        if (pos < 0) {
            pos += (len + 1);
        }
        return (pos >= 0) ? pos : 0;
    }

    static int str_sub(LuaState.lua_State L)
    {
        List<int> l = new List<int>(1);
        CLib.CharPtr s = LuaAuxLib.luaL_checklstring(L, 1, l); //out
        int start = posrelat(LuaAuxLib.luaL_checkinteger(L, 2), l[0]);
        int end = posrelat(LuaAuxLib.luaL_optinteger(L, 3, -1), l[0]);
        if (start < 1) {
            start = 1;
        }
        if (end > l[0]) {
            end = l[0];
        }
        if (start <= end) {
            LuaAPI.lua_pushlstring(L, CLib.CharPtr.plus(s, start - 1), (end - start) + 1);
        } else {
            Lua.lua_pushliteral(L, CLib.CharPtr.toCharPtr(""));
        }
        return 1;
    }

    static int str_reverse(LuaState.lua_State L)
    {
        LuaAuxLib.luaL_Buffer b = new LuaAuxLib.luaL_Buffer();
		    CLib.CharPtr s = LuaAuxLib.luaL_checklstring(L, 1, l); //out
        List<int> l = new List<int>(1);
        LuaAuxLib.luaL_buffinit(L, b);
        while (l[0]-- != 0) {
            LuaAuxLib.luaL_addchar(b, s.get(l[0]));
        }
        LuaAuxLib.luaL_pushresult(b);
        return 1;
    }

    static int str_lower(LuaState.lua_State L)
    {
        List<int> l = new List<int>(1);
        int i;
        LuaAuxLib.luaL_Buffer b = new LuaAuxLib.luaL_Buffer();
		    CLib.CharPtr s = LuaAuxLib.luaL_checklstring(L, 1, l); //out
        LuaAuxLib.luaL_buffinit(L, b);
        for ((i = 0); i < l[0]; i++) {
            LuaAuxLib.luaL_addchar(b, CLib.tolower(s.get(i)));
        }
        LuaAuxLib.luaL_pushresult(b);
        return 1;
    }

    static int str_upper(LuaState.lua_State L)
    {
        List<int> l = new List<int>(1);
        int i;
        LuaAuxLib.luaL_Buffer b = new LuaAuxLib.luaL_Buffer();
		    CLib.CharPtr s = LuaAuxLib.luaL_checklstring(L, 1, l); //out
        LuaAuxLib.luaL_buffinit(L, b);
        for ((i = 0); i < l[0]; i++) {
            LuaAuxLib.luaL_addchar(b, CLib.toupper(s.get(i)));
        }
        LuaAuxLib.luaL_pushresult(b);
        return 1;
    }

    static int str_rep(LuaState.lua_State L)
    {
        List<int> l = new List<int>(1);
        LuaAuxLib.luaL_Buffer b = new LuaAuxLib.luaL_Buffer();
		    CLib.CharPtr s = LuaAuxLib.luaL_checklstring(L, 1, l); //out
        int n = LuaAuxLib.luaL_checkint(L, 2);
        LuaAuxLib.luaL_buffinit(L, b);
        while (n-- > 0) {
            LuaAuxLib.luaL_addlstring(b, s, l[0]);
        }
        LuaAuxLib.luaL_pushresult(b);
        return 1;
    }

    static int str_byte(LuaState.lua_State L)
    {
        List<int> l = new List<int>(1);
        CLib.CharPtr s = LuaAuxLib.luaL_checklstring(L, 1, l); //out
        int posi = posrelat(LuaAuxLib.luaL_optinteger(L, 2, 1), l[0]);
        int pose = posrelat(LuaAuxLib.luaL_optinteger(L, 3, posi), l[0]);
        int n;
        int i;
        if (posi <= 0) {
            posi = 1;
        }
        if (pose > l[0]) {
            pose = l[0];
        }
        if (posi > pose) {
            return 0;
        }
        n = ((pose - posi) + 1);
        if ((posi + n) <= pose) {
            LuaAuxLib.luaL_error(L, CLib.CharPtr.toCharPtr("string slice too long"));
        }
        LuaAuxLib.luaL_checkstack(L, n, CLib.CharPtr.toCharPtr("string slice too long"));
        for ((i = 0); i < n; i++) {
            LuaAPI.lua_pushinteger(L, s.get((posi + i) - 1));
        }
        return n;
    }

    static int str_char(LuaState.lua_State L)
    {
        int n = LuaAPI.lua_gettop(L);
        int i;
        LuaAuxLib.luaL_Buffer b = new LuaAuxLib.luaL_Buffer();
        LuaAuxLib.luaL_buffinit(L, b);
        for ((i = 1); i <= n; i++) {
            int c = LuaAuxLib.luaL_checkint(L, i);
            LuaAuxLib.luaL_argcheck(L, c == c, i, "invalid value");
            LuaAuxLib.luaL_addchar(b, c);
        }
        LuaAuxLib.luaL_pushresult(b);
        return 1;
    }

    static int writer(LuaState.lua_State L, Object b, int size, Object B, ClassType t)
    {
        if (t.GetTypeID() == ClassType_.TYPE_CHARPTR) {
            List<int> bytes = t.ObjToBytes2(b);
            List<int> chars = new List<int>(bytes.length);
            for (int i = 0; i < bytes.length; i++) {
                chars[i] = bytes[i];
            }
            b = new CLib.CharPtr(chars);
        }
        LuaAuxLib.luaL_addlstring((LuaAuxLib.luaL_Buffer)B, (CLib.CharPtr)b, size);
        return 0;
    }

    static int str_dump(LuaState.lua_State L)
    {
        LuaAuxLib.luaL_Buffer b = new LuaAuxLib.luaL_Buffer();
        LuaAuxLib.luaL_checktype(L, 1, Lua.LUA_TFUNCTION);
        LuaAPI.lua_settop(L, 1);
        LuaAuxLib.luaL_buffinit(L, b);
        if (LuaAPI.lua_dump(L, new writer_delegate(), b) != 0) {
            LuaAuxLib.luaL_error(L, CLib.CharPtr.toCharPtr("unable to dump given function"));
        }
        LuaAuxLib.luaL_pushresult(b);
        return 1;
    }
    static const int CAP_UNFINISHED = (-1);
    static const int CAP_POSITION = (-2);
    static const int L_ESC = '%'.codeUnitAt(0);
    static final String SPECIALS = "^\$*+?.([%-";

    static int check_capture(MatchState ms, int l)
    {
        l -= '1'.codeUnitAt(0);
        if (((l < 0) || (l >= ms.level)) || (ms.capture[l].len == CAP_UNFINISHED)) {
            return LuaAuxLib.luaL_error(ms.L, CLib.CharPtr.toCharPtr("invalid capture index"));
        }
        return l;
    }

    static int capture_to_close(MatchState ms)
    {
        int level = ms.level;
        for (level--; level >= 0; level--) {
            if (ms.capture[level].len == CAP_UNFINISHED) {
                return level;
            }
        }
        return LuaAuxLib.luaL_error(ms.L, CLib.CharPtr.toCharPtr("invalid pattern capture"));
    }

    static CLib.CharPtr classend(MatchState ms, CLib.CharPtr p)
    {
        p = new CLib.CharPtr(p);
        int c = p.get(0);
        p = p.next();
        switch (c) {
            case L_ESC:
                if (p.get(0) == '\0'.codeUnitAt(0)) {
                    LuaAuxLib.luaL_error(ms.L, CLib.CharPtr.toCharPtr(("malformed pattern (ends with " + LuaConf.LUA_QL("%%")) + ")"));
                }
                return CLib.CharPtr.plus(p, 1);
            case '['.codeUnitAt(0):
                if (p.get(0) == '^'.codeUnitAt(0)) {
                    p = p.next();
                }
                do {
                    if (p.get(0) == '\0'.codeUnitAt(0)) {
                        LuaAuxLib.luaL_error(ms.L, CLib.CharPtr.toCharPtr(("malformed pattern (missing " + LuaConf.LUA_QL("]")) + ")"));
                    }
                    c = p.get(0);
                    p = p.next();
                    if ((c == L_ESC) && (p.get(0) != '\0'.codeUnitAt(0))) {
                        p = p.next();
                    }
                } while (p.get(0) != ']'.codeUnitAt(0));
                return CLib.CharPtr.plus(p, 1);
            default:
                return p;
        }
    }

    static int match_class(int c, int cl)
    {
        bool res;
        switch (CLib.tolower(cl)) {
            case 'a'.codeUnitAt(0):
                res = CLib.isalpha(c);
                break;
            case 'c'.codeUnitAt(0):
                res = CLib.iscntrl(c);
                break;
            case 'd'.codeUnitAt(0):
                res = CLib.isdigit(c);
                break;
            case 'l'.codeUnitAt(0):
                res = CLib.islower(c);
                break;
            case 'p'.codeUnitAt(0):
                res = CLib.ispunct(c);
                break;
            case 's'.codeUnitAt(0):
                res = CLib.isspace(c);
                break;
            case 'u'.codeUnitAt(0):
                res = CLib.isupper(c);
                break;
            case 'w'.codeUnitAt(0):
                res = CLib.isalnum(c);
                break;
            case 'x'.codeUnitAt(0):
                res = CLib.isxdigit(c);
                break;
            case 'z'.codeUnitAt(0):
                res = (c == 0);
                break;
            default:
                return (cl == c) ? 1 : 0;
        }
        return CLib.islower(cl) ? (res ? 1 : 0) : ((!res) ? 1 : 0);
    }

    static int matchbracketclass(int c, CLib.CharPtr p, CLib.CharPtr ec)
    {
        int sig = 1;
        if (p.get(1) == '^'.codeUnitAt(0)) {
            sig = 0;
            p = p.next();
        }
        while (CLib.CharPtr.lessThan(p = p.next(), ec)) {
            if (CLib.CharPtr.isEqualChar(p, L_ESC)) {
                p = p.next();
                if (match_class(c, p.get(0)) != 0) {
                    return sig;
                }
            } else {
                if ((p.get(1) == '-'.codeUnitAt(0)) && CLib.CharPtr.lessThan(CLib.CharPtr.plus(p, 2), ec)) {
                    p = CLib.CharPtr.plus(p, 2);
                    if ((p.get(-2) <= c) && (c <= p.get(0))) {
                        return sig;
                    }
                } else {
                    if (p.get(0) == c) {
                        return sig;
                    }
                }
            }
        }
        return (sig == 0) ? 1 : 0;
    }

    static int singlematch(int c, CLib.CharPtr p, CLib.CharPtr ep)
    {
        switch (p.get(0)) {
            case '.'.codeUnitAt(0):
                return 1;
            case L_ESC:
                return match_class(c, p.get(1));
            case '['.codeUnitAt(0):
                return matchbracketclass(c, p, CLib.CharPtr.minus(ep, 1));
            default:
                return (p.get(0) == c) ? 1 : 0;
        }
    }

    static CLib.CharPtr matchbalance(MatchState ms, CLib.CharPtr s, CLib.CharPtr p)
    {
        if ((p.get(0) == 0) || (p.get(1) == 0)) {
            LuaAuxLib.luaL_error(ms.L, CLib.CharPtr.toCharPtr("unbalanced pattern"));
        }
        if (s.get(0) != p.get(0)) {
            return null;
        } else {
            int b = p.get(0);
            int e = p.get(1);
            int cont = 1;
            while (CLib.CharPtr.lessThan(s = s.next(), ms.src_end)) {
                if (s.get(0) == e) {
                    if ((--cont) == 0) {
                        return CLib.CharPtr.plus(s, 1);
                    }
                } else {
                    if (s.get(0) == b) {
                        cont++;
                    }
                }
            }
        }
        return null;
    }

    static CLib.CharPtr max_expand(MatchState ms, CLib.CharPtr s, CLib.CharPtr p, CLib.CharPtr ep)
    {
        int i = 0;
        while (CLib.CharPtr.lessThan(CLib.CharPtr.plus(s, i), ms.src_end) && (singlematch(s.get(i), p, ep) != 0)) {
            i++;
        }
        while (i >= 0) {
            CLib.CharPtr res = match(ms, CLib.CharPtr.plus(s, i), CLib.CharPtr.plus(ep, 1));
            if (CLib.CharPtr.isNotEqual(res, null)) {
                return res;
            }
            i--;
        }
        return null;
    }

    static CLib.CharPtr min_expand(MatchState ms, CLib.CharPtr s, CLib.CharPtr p, CLib.CharPtr ep)
    {
        for (; ; ) {
            CLib.CharPtr res = match(ms, s, CLib.CharPtr.plus(ep, 1));
            if (CLib.CharPtr.isNotEqual(res, null)) {
                return res;
            } else {
                if (CLib.CharPtr.lessThan(s, ms.src_end) && (singlematch(s.get(0), p, ep) != 0)) {
                    s = s.next();
                } else {
                    return null;
                }
            }
        }
    }

    static CLib.CharPtr start_capture(MatchState ms, CLib.CharPtr s, CLib.CharPtr p, int what)
    {
        CLib.CharPtr res;
        int level = ms.level;
        if (level >= LuaConf.LUA_MAXCAPTURES) {
            LuaAuxLib.luaL_error(ms.L, CLib.CharPtr.toCharPtr("too many captures"));
        }
        ms.capture[level].init = s;
        ms.capture[level].len = what;
        ms.level = (level + 1);
        if (CLib.CharPtr.isEqual(res = match(ms, s, p), null)) {
            ms.level--;
        }
        return res;
    }

    static CLib.CharPtr end_capture(MatchState ms, CLib.CharPtr s, CLib.CharPtr p)
    {
        int l = capture_to_close(ms);
        CLib.CharPtr res;
        ms.capture[l].len = CLib.CharPtr.minus(s, ms.capture[l].init);
        if (CLib.CharPtr.isEqual(res = match(ms, s, p), null)) {
            ms.capture[l].len = CAP_UNFINISHED;
        }
        return res;
    }

    static CLib.CharPtr match_capture(MatchState ms, CLib.CharPtr s, int l)
    {
        int len;
        l = check_capture(ms, l);
        len = ms.capture[l].len;
        if ((CLib.CharPtr.minus(ms.src_end, s) >= len) && (CLib.memcmp(ms.capture[l].init, s, len) == 0)) {
            return CLib.CharPtr.plus(s, len);
        } else {
            return null;
        }
    }

    static CLib.CharPtr match(MatchState ms, CLib.CharPtr s, CLib.CharPtr p)
    {
        s = new CLib.CharPtr(s);
        p = new CLib.CharPtr(p);
        while (true) {
            bool init = false;
            switch (p.get(0)) {
                case '('.codeUnitAt(0):
                    if (p.get(1) == ')'.codeUnitAt(0)) {
                        return start_capture(ms, s, CLib.CharPtr.plus(p, 2), CAP_POSITION);
                    } else {
                        return start_capture(ms, s, CLib.CharPtr.plus(p, 1), CAP_UNFINISHED);
                    }
                case ')'.codeUnitAt(0):
                    return end_capture(ms, s, CLib.CharPtr.plus(p, 1));
                case L_ESC:
                    bool init2 = false;
                    switch (p.get(1)) {
                        case 'b'.codeUnitAt(0):
                            s = matchbalance(ms, s, CLib.CharPtr.plus(p, 2));
                            if (CLib.CharPtr.isEqual(s, null)) {
                                return null;
                            }
                            p = CLib.CharPtr.plus(p, 4);
                            init2 = true;
                            break;
                        case 'f'.codeUnitAt(0):
                            CLib.CharPtr ep;
                            int previous;
                            p = CLib.CharPtr.plus(p, 2);
                            if (p.get(0) != '['.codeUnitAt(0)) {
                                LuaAuxLib.luaL_error(ms.L, CLib.CharPtr.toCharPtr(((("missing " + LuaConf.LUA_QL("[")) + " after ") + LuaConf.LUA_QL("%%f")) + " in pattern"));
                            }
                            ep = classend(ms, p);
                            previous = (CLib.CharPtr.isEqual(s, ms.src_init) ? '\0'.codeUnitAt(0) : s.get(-1));
                            if ((matchbracketclass(previous, p, CLib.CharPtr.minus(ep, 1)) != 0) || (matchbracketclass(s.get(0), p, CLib.CharPtr.minus(ep, 1)) == 0)) {
                                return null;
                            }
                            p = ep;
                            init2 = true;
                            break;
                        default:
                            if (CLib.isdigit(p.get(1))) {
                                s = match_capture(ms, s, p.get(1));
                                if (CLib.CharPtr.isEqual(s, null)) {
                                    return null;
                                }
                                p = CLib.CharPtr.plus(p, 2);
                                init2 = true;
                                break;
                            }
                            if (true) {
                                CLib.CharPtr ep = classend(ms, p); // points to what is next 
                                int m = ((CLib.CharPtr.lessThan(s, ms.src_end) && (singlematch(s.get(0), p, ep) != 0)) ? 1 : 0);
                                bool init3 = false;
                                switch (ep.get(0)) {
                                    case '?'.codeUnitAt(0):
                                        CLib.CharPtr res;
                                        if ((m != 0) && CLib.CharPtr.isNotEqual(res = match(ms, CLib.CharPtr.plus(s, 1), CLib.CharPtr.plus(ep, 1)), null)) {
                                            return res;
                                        }
                                        p = CLib.CharPtr.plus(ep, 1);
                                        init3 = true;
                                        break;
                                    case '*'.codeUnitAt(0):
                                        return max_expand(ms, s, p, ep);
                                    case '+'.codeUnitAt(0):
                                        return (m != 0) ? max_expand(ms, CLib.CharPtr.plus(s, 1), p, ep) : null;
                                    case '-'.codeUnitAt(0):
                                        return min_expand(ms, s, p, ep);
                                    default:
                                        if (m == 0) {
                                            return null;
                                        }
                                        s = s.next();
                                        p = ep;
                                        init3 = true;
                                        break;
                                }
                                if (init3 == true) {
                                    init2 = true;
                                    break;
                                } else {
                                    break;
                                }
                            }
                    }
                    if (init2 == true) {
                        init = true;
                        break;
                    } else {
                        break;
                    }
                case '\0'.codeUnitAt(0):
                    return s;
                case '\$'.codeUnitAt(0):
                    if (p.get(1) == '\0'.codeUnitAt(0)) {
                        return CLib.CharPtr.isEqual(s, ms.src_end) ? s : null;
                    } else {
                        CLib.CharPtr ep = classend(ms, p); // points to what is next 
                        int m = ((CLib.CharPtr.lessThan(s, ms.src_end) && (singlematch(s.get(0), p, ep) != 0)) ? 1 : 0);
                        bool init2 = false;
                        switch (ep.get(0)) {
                            case '?'.codeUnitAt(0):
                                CLib.CharPtr res;
                                if ((m != 0) && CLib.CharPtr.isNotEqual(res = match(ms, CLib.CharPtr.plus(s, 1), CLib.CharPtr.plus(ep, 1)), null)) {
                                    return res;
                                }
                                p = CLib.CharPtr.plus(ep, 1);
                                init2 = true;
                                break;
                            case '*'.codeUnitAt(0):
                                return max_expand(ms, s, p, ep);
                            case '+'.codeUnitAt(0):
                                return (m != 0) ? max_expand(ms, CLib.CharPtr.plus(s, 1), p, ep) : null;
                            case '-'.codeUnitAt(0):
                                return min_expand(ms, s, p, ep);
                            default:
                                if (m == 0) {
                                    return null;
                                }
                                s = s.next();
                                p = ep;
                                init2 = true;
                                break;
                        }
                        if (init2 == true) {
                            init = true;
                            break;
                        } else {
                            break;
                        }
                    }
                default:
                    CLib.CharPtr ep = classend(ms, p); // points to what is next 
                    int m = ((CLib.CharPtr.lessThan(s, ms.src_end) && (singlematch(s.get(0), p, ep) != 0)) ? 1 : 0);
                    bool init2 = false;
                    switch (ep.get(0)) {
                        case '?'.codeUnitAt(0):
                            CLib.CharPtr res;
                            if ((m != 0) && CLib.CharPtr.isNotEqual(res = match(ms, CLib.CharPtr.plus(s, 1), CLib.CharPtr.plus(ep, 1)), null)) {
                                return res;
                            }
                            p = CLib.CharPtr.plus(ep, 1);
                            init2 = true;
                            break;
                        case '*'.codeUnitAt(0):
                            return max_expand(ms, s, p, ep);
                        case '+'.codeUnitAt(0):
                            return (m != 0) ? max_expand(ms, CLib.CharPtr.plus(s, 1), p, ep) : null;
                        case '-'.codeUnitAt(0):
                            return min_expand(ms, s, p, ep);
                        default:
                            if (m == 0) {
                                return null;
                            }
                            s = s.next();
                            p = ep;
                            init2 = true;
                            break;
                    }
                    if (init2 == true) {
                        init = true;
                        break;
                    } else {
                        break;
                    }
            }
            if (init == true) {
                continue;
            } else {
                break;
            }
        }
        return null;
    }

    static CLib.CharPtr lmemfind(CLib.CharPtr s1, int l1, CLib.CharPtr s2, int l2)
    {
        if (l2 == 0) {
            return s1;
        } else {
            if (l2 > l1) {
                return null;
            } else {
                CLib.CharPtr init; // to search for a `*s2' inside `s1' 
                l2--;
                l1 = (l1 - l2);
                while ((l1 > 0) && CLib.CharPtr.isNotEqual(init = CLib.memchr(s1, s2.get(0), l1), null)) {
                    init = init.next();
                    if (CLib.memcmp(init, CLib.CharPtr.plus(s2, 1), l2) == 0) {
                        return CLib.CharPtr.minus(init, 1);
                    } else {
                        l1 -= CLib.CharPtr.minus(init, s1);
                        s1 = init;
                    }
                }
                return null;
            }
        }
    }

    static void push_onecapture(MatchState ms, int i, CLib.CharPtr s, CLib.CharPtr e)
    {
        if (i >= ms.level) {
            if (i == 0) {
                LuaAPI.lua_pushlstring(ms.L, s, CLib.CharPtr.minus(e, s));
            } else {
                LuaAuxLib.luaL_error(ms.L, CLib.CharPtr.toCharPtr("invalid capture index"));
            }
        } else {
            int l = ms.capture[i].len;
            if (l == CAP_UNFINISHED) {
                LuaAuxLib.luaL_error(ms.L, CLib.CharPtr.toCharPtr("unfinished capture"));
            }
            if (l == CAP_POSITION) {
                LuaAPI.lua_pushinteger(ms.L, CLib.CharPtr.minus(ms.capture[i].init, ms.src_init) + 1);
            } else {
                LuaAPI.lua_pushlstring(ms.L, ms.capture[i].init, l);
            }
        }
    }

    static int push_captures(MatchState ms, CLib.CharPtr s, CLib.CharPtr e)
    {
        int i;
        int nlevels = (((ms.level == 0) && CLib.CharPtr.isNotEqual(s, null)) ? 1 : ms.level);
        LuaAuxLib.luaL_checkstack(ms.L, nlevels, CLib.CharPtr.toCharPtr("too many captures"));
        for ((i = 0); i < nlevels; i++) {
            push_onecapture(ms, i, s, e);
        }
        return nlevels;
    }

    static int str_find_aux(LuaState.lua_State L, int find)
    {
        List<int> l1 = new List<int>(1);
        List<int> l2 = new List<int>(1);
        CLib.CharPtr s = LuaAuxLib.luaL_checklstring(L, 1, l1); //out
		    CLib.CharPtr p = LuaAuxLib.luaL_checklstring(L, 2, l2); //out
        int init = (posrelat(LuaAuxLib.luaL_optinteger(L, 3, 1), l1[0]) - 1);
        if (init < 0) {
            init = 0;
        } else {
            if (init > l1[0]) {
                init = l1[0];
            }
        }
        if ((find != 0) && ((LuaAPI.lua_toboolean(L, 4) != 0) || CLib.CharPtr.isEqual(CLib.strpbrk(p, CLib.CharPtr.toCharPtr(SPECIALS)), null))) {
            CLib.CharPtr s2 = lmemfind(CLib.CharPtr.plus(s, init), (int)(l1[0] - init), p, (int)(l2[0])); //uint - uint
            if (CLib.CharPtr.isNotEqual(s2, null)) {
                LuaAPI.lua_pushinteger(L, CLib.CharPtr.minus(s2, s) + 1);
                LuaAPI.lua_pushinteger(L, CLib.CharPtr.minus(s2, s) + l2[0]);
                return 2;
            }
        } else {
            MatchState ms = new MatchState();
            int anchor = 0;
            if (p.get(0) == '^'.codeUnitAt(0)) {
                p = p.next();
                anchor = 1;
            }
            CLib.CharPtr s1 = CLib.CharPtr.plus(s, init);
            ms.L = L;
            ms.src_init = s;
            ms.src_end = CLib.CharPtr.plus(s, l1[0]);
            do {
                CLib.CharPtr res;
                ms.level = 0;
                if (CLib.CharPtr.isNotEqual(res = match(ms, s1, p), null)) {
                    if (find != 0) {
                        LuaAPI.lua_pushinteger(L, CLib.CharPtr.minus(s1, s) + 1);
                        LuaAPI.lua_pushinteger(L, CLib.CharPtr.minus(res, s));
                        return push_captures(ms, null, null) + 2;
                    } else {
                        return push_captures(ms, s1, res);
                    }
                }
            } while (CLib.CharPtr.lessEqual(s1 = s1.next(), ms.src_end) && (anchor == 0));
        }
        LuaAPI.lua_pushnil(L);
        return 1;
    }

    static int str_find(LuaState.lua_State L)
    {
        return str_find_aux(L, 1);
    }

    static int str_match(LuaState.lua_State L)
    {
        return str_find_aux(L, 0);
    }

    static int gmatch_aux(LuaState.lua_State L)
    {
        MatchState ms = new MatchState();
        List<int> ls = new List<int>(1);
        CLib.CharPtr s = LuaAPI.lua_tolstring(L, Lua.lua_upvalueindex(1), ls); //out
		    CLib.CharPtr p = Lua.lua_tostring(L, Lua.lua_upvalueindex(2));
		    CLib.CharPtr src;
        ms.L = L;
        ms.src_init = s;
        ms.src_end = CLib.CharPtr.plus(s, ls[0]);
        for ((src = CLib.CharPtr.plus(s, LuaAPI.lua_tointeger(L, Lua.lua_upvalueindex(3)))); CLib.CharPtr.lessEqual(src, ms.src_end); (src = src.next())) {
            CLib.CharPtr e;
            ms.level = 0;
            if (CLib.CharPtr.isNotEqual(e = match(ms, src, p), null)) {
                int newstart = CLib.CharPtr.minus(e, s);
                if (CLib.CharPtr.isEqual(e, src)) {
                    newstart++;
                }
                LuaAPI.lua_pushinteger(L, newstart);
                LuaAPI.lua_replace(L, Lua.lua_upvalueindex(3));
                return push_captures(ms, src, e);
            }
        }
        return 0;
    }

    static int gmatch(LuaState.lua_State L)
    {
        LuaAuxLib.luaL_checkstring(L, 1);
        LuaAuxLib.luaL_checkstring(L, 2);
        LuaAPI.lua_settop(L, 2);
        LuaAPI.lua_pushinteger(L, 0);
        LuaAPI.lua_pushcclosure(L, new LuaStrLib_delegate("gmatch_aux"), 3);
        return 1;
    }

    static int gfind_nodef(LuaState.lua_State L)
    {
        return LuaAuxLib.luaL_error(L, CLib.CharPtr.toCharPtr((LuaConf.LUA_QL("string.gfind") + " was renamed to ") + LuaConf.LUA_QL("string.gmatch")));
    }

    static void add_s(MatchState ms, LuaAuxLib.luaL_Buffer b, CLib.CharPtr s, CLib.CharPtr e)
    {
        List<int> l = new List<int>(1);
        int i;
        CLib.CharPtr news = LuaAPI.lua_tolstring(ms.L, 3, l); //out
        for ((i = 0); i < l[0]; i++) {
            if (news.get(i) != L_ESC) {
                LuaAuxLib.luaL_addchar(b, news.get(i));
            } else {
                i++;
                if (!CLib.isdigit(news.get(i))) {
                    LuaAuxLib.luaL_addchar(b, news.get(i));
                } else {
                    if (news.get(i) == '0'.codeUnitAt(0)) {
                        LuaAuxLib.luaL_addlstring(b, s, CLib.CharPtr.minus(e, s));
                    } else {
                        push_onecapture(ms, news.get(i) - '1'.codeUnitAt(0), s, e);
                        LuaAuxLib.luaL_addvalue(b);
                    }
                }
            }
        }
    }

    static void add_value(MatchState ms, LuaAuxLib.luaL_Buffer b, CLib.CharPtr s, CLib.CharPtr e)
    {
        LuaState.lua_State L = ms.L;
        switch (LuaAPI.lua_type(L, 3)) {
            case Lua.LUA_TNUMBER:
            case Lua.LUA_TSTRING:
                add_s(ms, b, s, e);
                return;
            case Lua.LUA_TFUNCTION:
                int n;
                LuaAPI.lua_pushvalue(L, 3);
                n = push_captures(ms, s, e);
                LuaAPI.lua_call(L, n, 1);
                break;
            case Lua.LUA_TTABLE:
                push_onecapture(ms, 0, s, e);
                LuaAPI.lua_gettable(L, 3);
                break;
        }
        if (LuaAPI.lua_toboolean(L, -1) == 0) {
            Lua.lua_pop(L, 1);
            LuaAPI.lua_pushlstring(L, s, CLib.CharPtr.minus(e, s));
        } else {
            if (LuaAPI.lua_isstring(L, -1) == 0) {
                LuaAuxLib.luaL_error(L, CLib.CharPtr.toCharPtr("invalid replacement value (a %s)"), LuaAuxLib.luaL_typename(L, -1));
            }
        }
        LuaAuxLib.luaL_addvalue(b);
    }

    static int str_gsub(LuaState.lua_State L)
    {
        List<int> srcl = new List<int>(1);
        CLib.CharPtr src = LuaAuxLib.luaL_checklstring(L, 1, srcl); //out
		    CLib.CharPtr p = LuaAuxLib.luaL_checkstring(L, 2);
        int tr = LuaAPI.lua_type(L, 3);
        int max_s = LuaAuxLib.luaL_optint(L, 4, srcl[0] + 1);
        int anchor = 0;
        if (p.get(0) == '^'.codeUnitAt(0)) {
            p = p.next();
            anchor = 1;
        }
        int n = 0;
        MatchState ms = new MatchState();
        LuaAuxLib.luaL_Buffer b = new LuaAuxLib.luaL_Buffer();
        LuaAuxLib.luaL_argcheck(L, (((tr == Lua.LUA_TNUMBER) || (tr == Lua.LUA_TSTRING)) || (tr == Lua.LUA_TFUNCTION)) || (tr == Lua.LUA_TTABLE), 3, "string/function/table expected");
        LuaAuxLib.luaL_buffinit(L, b);
        ms.L = L;
        ms.src_init = src;
        ms.src_end = CLib.CharPtr.plus(src, srcl[0]);
        while (n < max_s) {
            CLib.CharPtr e;
            ms.level = 0;
            e = match(ms, src, p);
            if (CLib.CharPtr.isNotEqual(e, null)) {
                n++;
                add_value(ms, b, src, e);
            }
            if (CLib.CharPtr.isNotEqual(e, null) && CLib.CharPtr.greaterThan(e, src)) {
                src = e;
            } else {
                if (CLib.CharPtr.lessThan(src, ms.src_end)) {
                    int c = src.get(0);
                    src = src.next();
                    LuaAuxLib.luaL_addchar(b, c);
                } else {
                    break;
                }
            }
            if (anchor != 0) {
                break;
            }
        }
        LuaAuxLib.luaL_addlstring(b, src, CLib.CharPtr.minus(ms.src_end, src));
        LuaAuxLib.luaL_pushresult(b);
        LuaAPI.lua_pushinteger(L, n);
        return 2;
    }
    static const int MAX_ITEM = 512;
    static final String FLAGS = "-+ #0";
    static const int MAX_FORMAT = (((FLAGS.length + 1) + (LuaConf.LUA_INTFRMLEN.length + 1)) + 10);

    static void addquoted(LuaState.lua_State L, LuaAuxLib.luaL_Buffer b, int arg)
    {
        List<int> l = new List<int>(1);
        CLib.CharPtr s = LuaAuxLib.luaL_checklstring(L, arg, l); //out
        LuaAuxLib.luaL_addchar(b, '"'.codeUnitAt(0));
        while (l[0]-- != 0) {
            switch (s.get(0)) {
                case '"'.codeUnitAt(0):
                case '\\'.codeUnitAt(0):
                case '\n'.codeUnitAt(0):
                    LuaAuxLib.luaL_addchar(b, '\\'.codeUnitAt(0));
                    LuaAuxLib.luaL_addchar(b, s.get(0));
                    break;
                case '\r'.codeUnitAt(0):
                    LuaAuxLib.luaL_addlstring(b, CLib.CharPtr.toCharPtr("\\r"), 2);
                    break;
                case '\0'.codeUnitAt(0):
                    LuaAuxLib.luaL_addlstring(b, CLib.CharPtr.toCharPtr("\\000"), 4);
                    break;
                default:
                    LuaAuxLib.luaL_addchar(b, s.get(0));
                    break;
            }
            s = s.next();
        }
        LuaAuxLib.luaL_addchar(b, '"'.codeUnitAt(0));
    }

    static CLib.CharPtr scanformat(LuaState.lua_State L, CLib.CharPtr strfrmt, CLib.CharPtr form)
    {
        CLib.CharPtr p = strfrmt;
        while ((p.get(0) != '\0'.codeUnitAt(0)) && CLib.CharPtr.isNotEqual(CLib.strchr(CLib.CharPtr.toCharPtr(FLAGS), p.get(0)), null)) {
            p = p.next();
        }
        if (CLib.CharPtr.minus(p, strfrmt) >= (FLAGS.length + 1)) {
            LuaAuxLib.luaL_error(L, CLib.CharPtr.toCharPtr("invalid format (repeated flags)"));
        }
        if (CLib.isdigit(p.get(0))) {
            p = p.next();
        }
        if (CLib.isdigit(p.get(0))) {
            p = p.next();
        }
        if (p.get(0) == '.'.codeUnitAt(0)) {
            p = p.next();
            if (CLib.isdigit(p.get(0))) {
                p = p.next();
            }
            if (CLib.isdigit(p.get(0))) {
                p = p.next();
            }
        }
        if (CLib.isdigit(p.get(0))) {
            LuaAuxLib.luaL_error(L, CLib.CharPtr.toCharPtr("invalid format (width or precision too long)"));
        }
        form.set(0, '%'.codeUnitAt(0));
        form = form.next();
        CLib.strncpy(form, strfrmt, CLib.CharPtr.minus(p, strfrmt) + 1);
        form = CLib.CharPtr.plus(form, CLib.CharPtr.minus(p, strfrmt) + 1);
        form.set(0, '\0'.codeUnitAt(0));
        return p;
    }

    static void addintlen(CLib.CharPtr form)
    {
        int l = CLib.strlen(form);
        int spec = form.get(l - 1);
        CLib.strcpy(CLib.CharPtr.plus(form, l - 1), CLib.CharPtr.toCharPtr(LuaConf.LUA_INTFRMLEN));
        form.set((l + (LuaConf.LUA_INTFRMLEN.length + 1)) - 2, spec);
        form.set((l + (LuaConf.LUA_INTFRMLEN.length + 1)) - 1, '\0'.codeUnitAt(0));
    }

    static int str_format(LuaState.lua_State L)
    {
        int arg = 1;
        List<int> sfl = new List<int>(1);
        CLib.CharPtr strfrmt = LuaAuxLib.luaL_checklstring(L, arg, sfl); //out
		    CLib.CharPtr strfrmt_end = CLib.CharPtr.plus(strfrmt, sfl[0]);
		    LuaAuxLib.luaL_Buffer b = new LuaAuxLib.luaL_Buffer();
		    LuaAuxLib.luaL_buffinit(L, b);
        while (CLib.CharPtr.lessThan(strfrmt, strfrmt_end)) {
            if (strfrmt.get(0) != L_ESC) {
                LuaAuxLib.luaL_addchar(b, strfrmt.get(0));
                strfrmt = strfrmt.next();
            } else {
                if (strfrmt.get(1) == L_ESC) {
                    LuaAuxLib.luaL_addchar(b, strfrmt.get(0));
                    strfrmt = CLib.CharPtr.plus(strfrmt, 2);
                } else {
                    strfrmt = strfrmt.next();
                    CLib.CharPtr form = CLib.CharPtr.toCharPtr(new char[MAX_FORMAT]); // to store the format (`%...') 
				            CLib.CharPtr buff = CLib.CharPtr.toCharPtr(new char[MAX_ITEM]); // to store the formatted item 
                    arg++;
                    strfrmt = scanformat(L, strfrmt, form);
                    int ch = strfrmt.get(0);
                    strfrmt = strfrmt.next();
                    switch (ch) {
                        case 'c'.codeUnitAt(0):
                            CLib.sprintf(buff, form, LuaAuxLib.luaL_checknumber(L, arg));
                            break;
                        case 'd'.codeUnitAt(0):
                        case 'i'.codeUnitAt(0):
                            addintlen(form);
                            CLib.sprintf(buff, form, LuaAuxLib.luaL_checknumber(L, arg));
                            break;
                        case 'o'.codeUnitAt(0):
                        case 'u'.codeUnitAt(0):
                        case 'x'.codeUnitAt(0):
                        case 'X'.codeUnitAt(0):
                            addintlen(form);
                            CLib.sprintf(buff, form, LuaAuxLib.luaL_checknumber(L, arg));
                            break;
                        case 'e'.codeUnitAt(0):
                        case 'E'.codeUnitAt(0):
                        case 'f'.codeUnitAt(0):
                        case 'g'.codeUnitAt(0):
                        case 'G'.codeUnitAt(0):
                            CLib.sprintf(buff, form, LuaAuxLib.luaL_checknumber(L, arg));
                            break;
                        case 'q'.codeUnitAt(0):
                            addquoted(L, b, arg);
                            continue;
                        case 's'.codeUnitAt(0):
                            List<int> l = new List<int>(1);
                            CLib.CharPtr s = LuaAuxLib.luaL_checklstring(L, arg, l); //out
                            if (CLib.CharPtr.isEqual(CLib.strchr(form, '.'.codeUnitAt(0)), null) && (l[0] >= 100)) {
                                LuaAPI.lua_pushvalue(L, arg);
                                LuaAuxLib.luaL_addvalue(b);
                                continue;
                            } else {
                                CLib.sprintf(buff, form, s);
                                break;
                            }
                        default:
                            return LuaAuxLib.luaL_error(L, CLib.CharPtr.toCharPtr((("invalid option " + LuaConf.LUA_QL("%%%c")) + " to ") + LuaConf.LUA_QL("format")), strfrmt.get(-1));
                    }
                    LuaAuxLib.luaL_addlstring(b, buff, CLib.strlen(buff));
                }
            }
        }
        LuaAuxLib.luaL_pushresult(b);
        return 1;
    }
    static final List<LuaAuxLib.luaL_Reg> strlib = [new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("byte"), new LuaStrLib_delegate("str_byte")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("char"), new LuaStrLib_delegate("str_char")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("dump"), new LuaStrLib_delegate("str_dump")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("find"), new LuaStrLib_delegate("str_find")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("format"), new LuaStrLib_delegate("str_format")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("gfind"), new LuaStrLib_delegate("gfind_nodef")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("gmatch"), new LuaStrLib_delegate("gmatch")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("gsub"), new LuaStrLib_delegate("str_gsub")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("len"), new LuaStrLib_delegate("str_len")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("lower"), new LuaStrLib_delegate("str_lower")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("match"), new LuaStrLib_delegate("str_match")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("rep"), new LuaStrLib_delegate("str_rep")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("reverse"), new LuaStrLib_delegate("str_reverse")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("sub"), new LuaStrLib_delegate("str_sub")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("upper"), new LuaStrLib_delegate("str_upper")), new LuaAuxLib.luaL_Reg(null, null)];

    static void createmetatable(LuaState.lua_State L)
    {
        LuaAPI.lua_createtable(L, 0, 1);
        Lua.lua_pushliteral(L, CLib.CharPtr.toCharPtr(""));
        LuaAPI.lua_pushvalue(L, -2);
        LuaAPI.lua_setmetatable(L, -2);
        Lua.lua_pop(L, 1);
        LuaAPI.lua_pushvalue(L, -2);
        LuaAPI.lua_setfield(L, -2, CLib.CharPtr.toCharPtr("__index"));
        Lua.lua_pop(L, 1);
    }

    static int luaopen_string(LuaState.lua_State L)
    {
        LuaAuxLib.luaL_register(L, CLib.CharPtr.toCharPtr(LuaLib.LUA_STRLIBNAME), strlib);
        LuaAPI.lua_getfield(L, -1, CLib.CharPtr.toCharPtr("gmatch"));
        LuaAPI.lua_setfield(L, -2, CLib.CharPtr.toCharPtr("gfind"));
        createmetatable(L);
        return 1;
    }
}

class writer_delegate with Lua_lua_Writer
{

    final int exec(LuaState.lua_State L, CLib.CharPtr p, int sz, Object ud)
    {
        return writer(L, p, sz, ud, new ClassType(ClassType_.TYPE_CHARPTR));
    }
}

class MatchState
{
    CLib.CharPtr src_init;
    CLib.CharPtr src_end;
    LuaState.lua_State L;
    int level;
    List<capture_> capture = new List<capture_>(LuaConf.LUA_MAXCAPTURES);

    MatchState_()
    {
        for (int i = 0; i < LuaConf.LUA_MAXCAPTURES; i++) {
            capture[i] = new capture_();
        }
    }
}

class capture_
{
    CLib.CharPtr init;
    int len;
}

class LuaStrLib_delegate with Lua_lua_CFunction
{
    String name;

    LuaStrLib_delegate_(String name)
    {
        this.name = name;
    }

    int exec(LuaState.lua_State L)
    {
        if ("str_byte" == name) {
            return LuaStrLib.str_byte(L);
        } else {
            if ("str_char" == name) {
                return LuaStrLib.str_char(L);
            } else {
                if ("str_dump" == name) {
                    return LuaStrLib.str_dump(L);
                } else {
                    if ("str_find" == name) {
                        return LuaStrLib.str_find(L);
                    } else {
                        if ("str_format" == name) {
                            return LuaStrLib.str_format(L);
                        } else {
                            if ("gfind_nodef" == name) {
                                return LuaStrLib.gfind_nodef(L);
                            } else {
                                if ("gmatch" == name) {
                                    return LuaStrLib.gmatch(L);
                                } else {
                                    if ("str_gsub" == name) {
                                        return LuaStrLib.str_gsub(L);
                                    } else {
                                        if ("str_len" == name) {
                                            return LuaStrLib.str_len(L);
                                        } else {
                                            if ("str_lower" == name) {
                                                return LuaStrLib.str_lower(L);
                                            } else {
                                                if ("str_match" == name) {
                                                    return LuaStrLib.str_match(L);
                                                } else {
                                                    if ("str_rep" == name) {
                                                        return LuaStrLib.str_rep(L);
                                                    } else {
                                                        if ("str_reverse" == name) {
                                                            return LuaStrLib.str_reverse(L);
                                                        } else {
                                                            if ("str_sub" == name) {
                                                                return LuaStrLib.str_sub(L);
                                                            } else {
                                                                if ("str_upper" == name) {
                                                                    return LuaStrLib.str_upper(L);
                                                                } else {
                                                                    if ("gmatch_aux" == name) {
                                                                        return LuaStrLib.gmatch_aux(L);
                                                                    } else {
                                                                        return 0;
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
