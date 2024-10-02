library kurumi;

class LuaLex
{
    static const int FIRST_RESERVED = 257;
    static const int TOKEN_LEN = 9;
    static const int NUM_RESERVED = ((RESERVED.TK_WHILE - FIRST_RESERVED) + 1);

    static void next(LexState ls)
    {
        ls.current = LuaZIO.zgetc(ls.z);
    }

    static bool currIsNewline(LexState ls)
    {
        return (ls.current == '\n'.codeUnitAt(0)) || (ls.current == '\r'.codeUnitAt(0));
    }
    static final List<String> luaX_tokens = ["and", "break", "do", "else", "elseif", "end", "false", "for", "function", "if", "in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while", "..", "...", "==", ">=", "<=", "~=", "<number>", "<name>", "<string>", "<eof>"];

    static void save_and_next(LexState ls)
    {
        save(ls, ls.current);
        next(ls);
    }

    static void save(LexState ls, int c)
    {
        LuaZIO.Mbuffer b = ls.buff;
        if ((b.n + 1) > b.buffsize) {
            int newsize;
            if (b.buffsize >= (LuaLimits.MAX_SIZET ~/ 2)) {
                luaX_lexerror(ls, CLib.CharPtr.toCharPtr("lexical element too long"), 0);
            }
            newsize = (b.buffsize * 2);
            LuaZIO.luaZ_resizebuffer(ls.L, b, newsize);
        }
        b.buffer.set(b.n++, c);
    }

    static void luaX_init(LuaState.lua_State L)
    {
        int i;
        for ((i = 0); i < NUM_RESERVED; i++) {
            LuaObject.TString ts = LuaString.luaS_new(L, CLib.CharPtr.toCharPtr(luaX_tokens[i]));
            LuaString.luaS_fix(ts);
            LuaLimits.lua_assert((luaX_tokens[i].length + 1) <= TOKEN_LEN);
            ts.getTsv().reserved = LuaLimits.cast_byte(i + 1);
        }
    }
    static const int MAXSRC = 80;

    static CLib.CharPtr luaX_token2str(LexState ls, int token)
    {
        if (token < FIRST_RESERVED) {
            LuaLimits.lua_assert(token == token);
            return CLib.iscntrl(token) ? LuaObject.luaO_pushfstring(ls.L, CLib.CharPtr.toCharPtr("char(%d)"), token) : LuaObject.luaO_pushfstring(ls.L, CLib.CharPtr.toCharPtr("%c"), token);
        } else {
            return CLib.CharPtr.toCharPtr(luaX_tokens[token - FIRST_RESERVED]);
        }
    }

    static CLib.CharPtr txtToken(LexState ls, int token)
    {
        switch (token) {
            case RESERVED.TK_NAME:
            case RESERVED.TK_STRING:
            case RESERVED.TK_NUMBER:
                save(ls, '\0'.codeUnitAt(0));
                return LuaZIO.luaZ_buffer(ls.buff);
            default:
                return luaX_token2str(ls, token);
        }
    }

    static void luaX_lexerror(LexState ls, CLib.CharPtr msg, int token)
    {
        CLib.CharPtr buff = CLib.CharPtr.toCharPtr(new char[MAXSRC]);
        LuaObject.luaO_chunkid(buff, LuaObject.getstr(ls.source), MAXSRC);
        msg = LuaObject.luaO_pushfstring(ls.L, CLib.CharPtr.toCharPtr("%s:%d: %s"), buff, ls.linenumber, msg);
        if (token != 0) {
            LuaObject.luaO_pushfstring(ls.L, CLib.CharPtr.toCharPtr("%s near " + LuaConf.getLUA_QS()), msg, txtToken(ls, token));
        }
        LuaDo.luaD_throw(ls.L, Lua.LUA_ERRSYNTAX);
    }

    static void luaX_syntaxerror(LexState ls, CLib.CharPtr msg)
    {
        luaX_lexerror(ls, msg, ls.t.token);
    }

    static LuaObject.TString luaX_newstring(LexState ls, CLib.CharPtr str, int l)
    {
        LuaState.lua_State L = ls.L;
		    LuaObject.TString ts = LuaString.luaS_newlstr(L, str, l);
		    LuaObject.TValue o = LuaTable.luaH_setstr(L, ls.fs.h, ts); // entry for `str' 
        if (LuaObject.ttisnil(o)) {
            LuaObject.setbvalue(o, 1);
        }
        return ts;
    }

    static void inclinenumber(LexState ls)
    {
        int old = ls.current;
        LuaLimits.lua_assert(currIsNewline(ls));
        next(ls);
        if (currIsNewline(ls) && (ls.current != old)) {
            next(ls);
        }
        if ((++ls.linenumber) >= LuaLimits.MAX_INT) {
            luaX_syntaxerror(ls, CLib.CharPtr.toCharPtr("chunk has too many lines"));
        }
    }

    static void luaX_setinput(LuaState.lua_State L, LexState ls, LuaZIO.ZIO z, LuaObject.TString source)
    {
        ls.decpoint = '.'.codeUnitAt(0);
        ls.L = L;
        ls.lookahead.token = RESERVED.TK_EOS;
        ls.z = z;
        ls.fs = null;
        ls.linenumber = 1;
        ls.lastline = 1;
        ls.source = source;
        LuaZIO.luaZ_resizebuffer(ls.L, ls.buff, LuaLimits.LUA_MINBUFFER);
        next(ls);
    }

    static int check_next(LexState ls, CLib.CharPtr set)
    {
        if (CLib.CharPtr.isEqual(CLib.strchr(set, ls.current), null)) {
            return 0;
        }
        save_and_next(ls);
        return 1;
    }

    static void buffreplace(LexState ls, int from, int to)
    {
        int n = LuaZIO.luaZ_bufflen(ls.buff);
        CLib.CharPtr p = LuaZIO.luaZ_buffer(ls.buff);
        while (n-- != 0) {
            if (p.get(n) == from) {
                p.set(n, to);
            }
        }
    }

    static void trydecpoint(LexState ls, SemInfo seminfo)
    {
        int old = ls.decpoint;
        ls.decpoint = '.'.codeUnitAt(0);
        buffreplace(ls, old, ls.decpoint);
        List<double> r = new List<double>(1);
        r[0] = seminfo.r;
        int ret = LuaObject.luaO_str2d(LuaZIO.luaZ_buffer(ls.buff), r);
        seminfo.r = r[0];
        if (ret == 0) {
            buffreplace(ls, ls.decpoint, '.'.codeUnitAt(0));
            luaX_lexerror(ls, CLib.CharPtr.toCharPtr("malformed number"), RESERVED.TK_NUMBER);
        }
    }

    static void read_numeral(LexState ls, SemInfo seminfo)
    {
        LuaLimits.lua_assert(CLib.isdigit(ls.current));
        do {
            save_and_next(ls);
        } while (CLib.isdigit(ls.current) || (ls.current == '.'.codeUnitAt(0)));
        if (check_next(ls, CLib.CharPtr.toCharPtr("Ee")) != 0) {
            check_next(ls, CLib.CharPtr.toCharPtr("+-"));
        }
        while (CLib.isalnum(ls.current) || (ls.current == '_'.codeUnitAt(0))) {
            save_and_next(ls);
        }
        save(ls, '\0'.codeUnitAt(0));
        buffreplace(ls, '.'.codeUnitAt(0), ls.decpoint);
        List<double> r = new List<double>(1);
        r[0] = seminfo.r;
        int ret = LuaObject.luaO_str2d(LuaZIO.luaZ_buffer(ls.buff), r);
        seminfo.r = r[0];
        if (ret == 0) {
            trydecpoint(ls, seminfo);
        }
    }

    static int skip_sep(LexState ls)
    {
        int count = 0;
        int s = ls.current;
        LuaLimits.lua_assert((s == '['.codeUnitAt(0)) || (s == ']'.codeUnitAt(0)));
        save_and_next(ls);
        while (ls.current == '='.codeUnitAt(0)) {
            save_and_next(ls);
            count++;
        }
        return (ls.current == s) ? count : ((-count) - 1);
    }

    static void read_long_string(LexState ls, SemInfo seminfo, int sep)
    {
        save_and_next(ls);
        if (currIsNewline(ls)) {
            inclinenumber(ls);
        }
        for (; ; ) {
            bool endloop = false;
            switch (ls.current) {
                case LuaZIO.EOZ:
                    luaX_lexerror(ls, (seminfo != null) ? CLib.CharPtr.toCharPtr("unfinished long string") : CLib.CharPtr.toCharPtr("unfinished long comment"), RESERVED.TK_EOS);
                    break;
                case ']'.codeUnitAt(0):
                    if (skip_sep(ls) == sep) {
                        save_and_next(ls);
                        endloop = true;
                        break;
                    }
                    break;
                case '\n'.codeUnitAt(0):
                case '\r'.codeUnitAt(0):
                    save(ls, '\n'.codeUnitAt(0));
                    inclinenumber(ls);
                    if (seminfo == null) {
                        LuaZIO.luaZ_resetbuffer(ls.buff);
                    }
                    break;
                default:
                    if (seminfo != null) {
                        save_and_next(ls);
                    } else {
                        next(ls);
                    }
                    break;
            }
            if (endloop) {
                break;
            }
        }
        if (seminfo != null) {
            seminfo.ts = luaX_newstring(ls, CLib.CharPtr.plus(LuaZIO.luaZ_buffer(ls.buff), 2 + sep), LuaZIO.luaZ_bufflen(ls.buff) - (2 * (2 + sep)));
        }
    }

    static void read_string(LexState ls, int del, SemInfo seminfo)
    {
        save_and_next(ls);
        while (ls.current != del) {
            switch (ls.current) {
                case LuaZIO.EOZ:
                    luaX_lexerror(ls, CLib.CharPtr.toCharPtr("unfinished string"), RESERVED.TK_EOS);
                    continue;
                case '\n'.codeUnitAt(0):
                case '\r'.codeUnitAt(0):
                    luaX_lexerror(ls, CLib.CharPtr.toCharPtr("unfinished string"), RESERVED.TK_STRING);
                    continue;
                case '\\'.codeUnitAt(0):
                    int c;
                    next(ls);
                    switch (ls.current) {
                        case 'a'.codeUnitAt(0):
                            c = '\u0007'.codeUnitAt(0);
                            break;
                        case 'b'.codeUnitAt(0):
                            c = '\b'.codeUnitAt(0);
                            break;
                        case 'f'.codeUnitAt(0):
                            c = '\f'.codeUnitAt(0);
                            break;
                        case 'n'.codeUnitAt(0):
                            c = '\n'.codeUnitAt(0);
                            break;
                        case 'r'.codeUnitAt(0):
                            c = '\r'.codeUnitAt(0);
                            break;
                        case 't'.codeUnitAt(0):
                            c = '\t'.codeUnitAt(0);
                            break;
                        case 'v'.codeUnitAt(0):
                            c = '\u000B'.codeUnitAt(0);
                            break;
                        case '\n'.codeUnitAt(0):
                        case '\r'.codeUnitAt(0):
                            save(ls, '\n'.codeUnitAt(0));
                            inclinenumber(ls);
                            continue;
                        case LuaZIO.EOZ:
                            continue;
                        default:
                            if (!CLib.isdigit(ls.current)) {
                                save_and_next(ls);
                            } else {
                                int i = 0;
                                c = 0;
                                do {
                                    c = ((10 * c) + (ls.current - '0'.codeUnitAt(0)));
                                    next(ls);
                                } while (((++i) < 3) && CLib.isdigit(ls.current));
                                if (c > Byte.MAX_VALUE) {
                                    luaX_lexerror(ls, CLib.CharPtr.toCharPtr("escape sequence too large"), RESERVED.TK_STRING);
                                }
                                save(ls, c);
                            }
                            continue;
                    }
                    save(ls, c);
                    next(ls);
                    continue;
                default:
                    save_and_next(ls);
                    break;
            }
        }
        save_and_next(ls);
        seminfo.ts = luaX_newstring(ls, CLib.CharPtr.plus(LuaZIO.luaZ_buffer(ls.buff), 1), LuaZIO.luaZ_bufflen(ls.buff) - 2);
    }

    static int llex(LexState ls, SemInfo seminfo)
    {
        LuaZIO.luaZ_resetbuffer(ls.buff);
        for (; ; ) {
            switch (ls.current) {
                case '\n'.codeUnitAt(0):
                case '\r'.codeUnitAt(0):
                    inclinenumber(ls);
                    continue;
                case '-'.codeUnitAt(0):
                    next(ls);
                    if (ls.current != '-'.codeUnitAt(0)) {
                        return '-'.codeUnitAt(0);
                    }
                    next(ls);
                    if (ls.current == '['.codeUnitAt(0)) {
                        int sep = skip_sep(ls);
                        LuaZIO.luaZ_resetbuffer(ls.buff);
                        if (sep >= 0) {
                            read_long_string(ls, null, sep);
                            LuaZIO.luaZ_resetbuffer(ls.buff);
                            continue;
                        }
                    }
                    while ((!currIsNewline(ls)) && (ls.current != LuaZIO.EOZ)) {
                        next(ls);
                    }
                    continue;
                case '['.codeUnitAt(0):
                    int sep = skip_sep(ls);
                    if (sep >= 0) {
                        read_long_string(ls, seminfo, sep);
                        return RESERVED.TK_STRING;
                    } else {
                        if (sep == (-1)) {
                            return '['.codeUnitAt(0);
                        } else {
                            luaX_lexerror(ls, CLib.CharPtr.toCharPtr("invalid long string delimiter"), RESERVED.TK_STRING);
                        }
                    }
                    break;
                case '='.codeUnitAt(0):
                    next(ls);
                    if (ls.current != '='.codeUnitAt(0)) {
                        return '='.codeUnitAt(0);
                    } else {
                        next(ls);
                        return RESERVED.TK_EQ;
                    }
                case '<'.codeUnitAt(0):
                    next(ls);
                    if (ls.current != '='.codeUnitAt(0)) {
                        return '<'.codeUnitAt(0);
                    } else {
                        next(ls);
                        return RESERVED.TK_LE;
                    }
                case '>'.codeUnitAt(0):
                    next(ls);
                    if (ls.current != '='.codeUnitAt(0)) {
                        return '>'.codeUnitAt(0);
                    } else {
                        next(ls);
                        return RESERVED.TK_GE;
                    }
                case '~'.codeUnitAt(0):
                    next(ls);
                    if (ls.current != '='.codeUnitAt(0)) {
                        return '~'.codeUnitAt(0);
                    } else {
                        next(ls);
                        return RESERVED.TK_NE;
                    }
                case '"'.codeUnitAt(0):
                case '\''.codeUnitAt(0):
                    read_string(ls, ls.current, seminfo);
                    return RESERVED.TK_STRING;
                case '.'.codeUnitAt(0):
                    save_and_next(ls);
                    if (check_next(ls, CLib.CharPtr.toCharPtr(".")) != 0) {
                        if (check_next(ls, CLib.CharPtr.toCharPtr(".")) != 0) {
                            return RESERVED.TK_DOTS;
                        } else {
                            return RESERVED.TK_CONCAT;
                        }
                    } else {
                        if (!CLib.isdigit(ls.current)) {
                            return '.'.codeUnitAt(0);
                        } else {
                            read_numeral(ls, seminfo);
                            return RESERVED.TK_NUMBER;
                        }
                    }
                case LuaZIO.EOZ:
                    return RESERVED.TK_EOS;
                default:
                    if (CLib.isspace(ls.current)) {
                        LuaLimits.lua_assert(!currIsNewline(ls));
                        next(ls);
                        continue;
                    } else {
                        if (CLib.isdigit(ls.current)) {
                            read_numeral(ls, seminfo);
                            return RESERVED.TK_NUMBER;
                        } else {
                            if (CLib.isalpha(ls.current) || (ls.current == '_'.codeUnitAt(0))) {
                                LuaObject.TString ts;
                                do {
                                    save_and_next(ls);
                                } while (CLib.isalnum(ls.current) || (ls.current == '_'.codeUnitAt(0)));
                                ts = luaX_newstring(ls, LuaZIO.luaZ_buffer(ls.buff), LuaZIO.luaZ_bufflen(ls.buff));
                                if (ts.getTsv().reserved > 0) {
                                    return (ts.getTsv().reserved - 1) + FIRST_RESERVED;
                                } else {
                                    seminfo.ts = ts;
                                    return RESERVED.TK_NAME;
                                }
                            } else {
                                int c = ls.current;
                                next(ls);
                                return c;
                            }
                        }
                    }
            }
        }
    }

    static void luaX_next(LexState ls)
    {
        ls.lastline = ls.linenumber;
        if (ls.lookahead.token != RESERVED.TK_EOS) {
            ls.t = new Token(ls.lookahead);
            ls.lookahead.token = RESERVED.TK_EOS;
        } else {
            ls.t.token = llex(ls, ls.t.seminfo);
        }
    }

    static void luaX_lookahead(LexState ls)
    {
        LuaLimits.lua_assert(ls.lookahead.token == RESERVED.TK_EOS);
        ls.lookahead.token = llex(ls, ls.lookahead.seminfo);
    }
}

class RESERVED
{
    static const int TK_AND = LuaLex.FIRST_RESERVED;
    static const int TK_BREAK = (LuaLex.FIRST_RESERVED + 1);
    static const int TK_DO = (LuaLex.FIRST_RESERVED + 2);
    static const int TK_ELSE = (LuaLex.FIRST_RESERVED + 3);
    static const int TK_ELSEIF = (LuaLex.FIRST_RESERVED + 4);
    static const int TK_END = (LuaLex.FIRST_RESERVED + 5);
    static const int TK_FALSE = (LuaLex.FIRST_RESERVED + 6);
    static const int TK_FOR = (LuaLex.FIRST_RESERVED + 7);
    static const int TK_FUNCTION = (LuaLex.FIRST_RESERVED + 8);
    static const int TK_IF = (LuaLex.FIRST_RESERVED + 9);
    static const int TK_IN = (LuaLex.FIRST_RESERVED + 10);
    static const int TK_LOCAL = (LuaLex.FIRST_RESERVED + 11);
    static const int TK_NIL = (LuaLex.FIRST_RESERVED + 12);
    static const int TK_NOT = (LuaLex.FIRST_RESERVED + 13);
    static const int TK_OR = (LuaLex.FIRST_RESERVED + 14);
    static const int TK_REPEAT = (LuaLex.FIRST_RESERVED + 15);
    static const int TK_RETURN = (LuaLex.FIRST_RESERVED + 16);
    static const int TK_THEN = (LuaLex.FIRST_RESERVED + 17);
    static const int TK_TRUE = (LuaLex.FIRST_RESERVED + 18);
    static const int TK_UNTIL = (LuaLex.FIRST_RESERVED + 19);
    static const int TK_WHILE = (LuaLex.FIRST_RESERVED + 20);
    static const int TK_CONCAT = (LuaLex.FIRST_RESERVED + 21);
    static const int TK_DOTS = (LuaLex.FIRST_RESERVED + 22);
    static const int TK_EQ = (LuaLex.FIRST_RESERVED + 23);
    static const int TK_GE = (LuaLex.FIRST_RESERVED + 24);
    static const int TK_LE = (LuaLex.FIRST_RESERVED + 25);
    static const int TK_NE = (LuaLex.FIRST_RESERVED + 26);
    static const int TK_NUMBER = (LuaLex.FIRST_RESERVED + 27);
    static const int TK_NAME = (LuaLex.FIRST_RESERVED + 28);
    static const int TK_STRING = (LuaLex.FIRST_RESERVED + 29);
    static const int TK_EOS = (LuaLex.FIRST_RESERVED + 30);
}

class SemInfo
{
    double r;
    LuaObject.TString ts;

    SemInfo_()
    {
    }

    SemInfo_(SemInfo copy)
    {
        this.r = copy.r;
        this.ts = copy.ts;
    }
}

class Token
{
    int token;
    LuaLex.SemInfo seminfo = new LuaLex.SemInfo();

    Token_()
    {
    }

    Token_(Token copy)
    {
        this.token = copy.token;
        this.seminfo = new LuaLex.SemInfo(copy.seminfo);
    }
}

class LexState
{
    int current;
    int linenumber;
    int lastline;
    Token t = new Token();
    Token lookahead = new Token();
    LuaParser.FuncState fs;
    LuaState.lua_State L;
    LuaZIO.ZIO z;
    LuaZIO.Mbuffer buff;
    LuaObject.TString source;
    int decpoint;
}
