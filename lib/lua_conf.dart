library kurumi;

class LuaConf
{
    static final bool CATCH_EXCEPTIONS = false;
    static final String LUA_PATH = "LUA_PATH";
    static final String LUA_CPATH = "LUA_CPATH";
    static final String LUA_INIT = "LUA_INIT";
    static final String LUA_LDIR = "!\\lua\\";
    static final String LUA_CDIR = "!\\";
    static final String LUA_PATH_DEFAULT = ((((((((".\\?.lua;" + LUA_LDIR) + "?.lua;") + LUA_LDIR) + "?\\init.lua;") + LUA_CDIR) + "?.lua;") + LUA_CDIR) + "?\\init.lua");
    static final String LUA_CPATH_DEFAULT = ((((".\\?.dll;" + LUA_CDIR) + "?.dll;") + LUA_CDIR) + "loadall.dll");
    static final String LUA_DIRSEP = "\\";
    static final String LUA_PATHSEP = ";";
    static final String LUA_PATH_MARK = "?";
    static final String LUA_EXECDIR = "!";
    static final String LUA_IGMARK = "-";

    static CLib.CharPtr LUA_QL(String x)
    {
        return CLib.CharPtr.toCharPtr(("'" + x) + "'");
    }

    static CLib.CharPtr getLUA_QS()
    {
        return LUA_QL("%s");
    }
    static const int LUA_IDSIZE = 60;

    static int lua_stdin_is_tty()
    {
        return 1;
    }
    static final String LUA_PROMPT = "> ";
    static final String LUA_PROMPT2 = ">> ";
    static final String LUA_PROGNAME = "lua";
    static const int LUA_MAXINPUT = 512;

    static bool lua_readline(LuaState.lua_State L, CLib.CharPtr b, CLib.CharPtr p)
    {
        CLib.fputs(p, CLib.stdout);
        CLib.fflush(CLib.stdout);
        return CLib.CharPtr.isNotEqual(CLib.fgets(b, CLib.stdin), null);
    }

    static void lua_saveline(LuaState.lua_State L, int idx)
    {
    }

    static void lua_freeline(LuaState.lua_State L, CLib.CharPtr b)
    {
    }
    static const int LUAI_GCPAUSE = 200;
    static const int LUAI_GCMUL = 200;

    static void luai_apicheck(LuaState.lua_State L, bool o)
    {
    }

    static void luai_apicheck(LuaState.lua_State L, int o)
    {
    }
    static const int LUAI_BITSINT = 32;
    static const int LUAI_MAXCALLS = 20000;
    static const int LUAI_MAXCSTACK = 8000;
    static const int LUAI_MAXCCALLS = 200;
    static const int LUAI_MAXVARS = 200;
    static const int LUAI_MAXUPVALUES = 60;
    static const int LUAL_BUFFERSIZE = 1024;
    static final String LUA_NUMBER_SCAN = "%lf";
    static final String LUA_NUMBER_FMT = "%.14g";

    static CLib.CharPtr lua_number2str(double n)
    {
        if (n == n) {
            return CLib.CharPtr.toCharPtr(Long.toString(n));
        } else {
            return CLib.CharPtr.toCharPtr(Double.toString(n));
        }
    }
    static const int LUAI_MAXNUMBER2STR = 32;
    static final String number_chars = "0123456789+-eE.";

    static double lua_str2number(CLib.CharPtr s, List<CLib.CharPtr> end)
    {
        end[0] = new CLib.CharPtr(s.chars, s.index);
        String str = "";
        while (end[0].get(0) == ' '.codeUnitAt(0)) {
            end[0] = end[0].next();
        }
        while (number_chars.indexOf(end[0].get(0)) >= 0) {
            str += end[0].get(0);
            end[0] = end[0].next();
        }
        List<bool> isSuccess = new List<bool>(1);
        double result = ClassType.ConvertToDouble(str.toString(), isSuccess);
        if (isSuccess[0] == false) {
            end[0] = new CLib.CharPtr(s.chars, s.index);
        }
        return result;
    }

    abstract class op_delegate
    {

        double exec(double a, double b);
    }

    static double luai_numadd(double a, double b)
    {
        return +b;
    }

    static double luai_numsub(double a, double b)
    {
        return -b;
    }

    static double luai_nummul(double a, double b)
    {
        return a * b;
    }

    static double luai_numdiv(double a, double b)
    {
        return a ~/ b;
    }

    static double luai_nummod(double a, double b)
    {
        return (-Math.floor(a ~/ b)) * b;
    }

    static double luai_numpow(double a, double b)
    {
        return Math.pow(a, b);
    }

    static double luai_numunm(double a)
    {
        return -a;
    }

    static bool luai_numeq(double a, double b)
    {
        return a == b;
    }

    static bool luai_numlt(double a, double b)
    {
        return a < b;
    }

    static bool luai_numle(double a, double b)
    {
        return a <= b;
    }

    static bool luai_numisnan(double a)
    {
        return ClassType.isNaN(a);
    }

    static void lua_number2int(List<int> i, double d)
    {
        i[0] = d;
    }

    static void lua_number2integer(List<int> i, double n)
    {
        i[0] = n;
    }

    static void LUAI_THROW(LuaState.lua_State L, LuaDo.lua_longjmp c)
    {
        throw new LuaException(L, c);
    }

    static void LUAI_TRY(LuaState.lua_State L, LuaDo.lua_longjmp c, Object a)
    {
        if (c.status == 0) {
            c.status = (-1);
        }
    }
    static const int LUA_MAXCAPTURES = 32;

    static StreamProxy lua_popen(LuaState.lua_State L, CLib.CharPtr c, CLib.CharPtr m)
    {
        LuaAuxLib.luaL_error(L, CLib.CharPtr.toCharPtr(LUA_QL("popen") + " not supported"));
        return null;
    }

    static int lua_pclose(LuaState.lua_State L, StreamProxy file)
    {
        return 0;
    }
    static const int LUAI_EXTRASPACE = 0;

    static void luai_userstateopen(LuaState.lua_State L)
    {
    }

    static void luai_userstateclose(LuaState.lua_State L)
    {
    }

    static void luai_userstatethread(LuaState.lua_State L, LuaState.lua_State L1)
    {
    }

    static void luai_userstatefree(LuaState.lua_State L)
    {
    }

    static void luai_userstateresume(LuaState.lua_State L, int n)
    {
    }

    static void luai_userstateyield(LuaState.lua_State L, int n)
    {
    }
    static final String LUA_INTFRMLEN = "l";
}

class luai_numadd_delegate with op_delegate
{

    final double exec(double a, double b)
    {
        return luai_numadd(a, b);
    }
}

class luai_numsub_delegate with op_delegate
{

    final double exec(double a, double b)
    {
        return luai_numsub(a, b);
    }
}

class luai_nummul_delegate with op_delegate
{

    final double exec(double a, double b)
    {
        return luai_nummul(a, b);
    }
}

class luai_numdiv_delegate with op_delegate
{

    final double exec(double a, double b)
    {
        return luai_numdiv(a, b);
    }
}

class luai_nummod_delegate with op_delegate
{

    final double exec(double a, double b)
    {
        return luai_nummod(a, b);
    }
}

class luai_numpow_delegate with op_delegate
{

    final double exec(double a, double b)
    {
        return luai_numpow(a, b);
    }
}

class LuaException extends RuntimeException
{
    LuaState.lua_State L;
    LuaDo.lua_longjmp c;

    LuaException_(LuaState.lua_State L, LuaDo.lua_longjmp c)
    {
        this.L = L;
        this.c = c;
    }
}
