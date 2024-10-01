library kurumi;

class LuaMathLib
{
    static final double PI = 3.141592653589793;
    static final double RADIANS_PER_DEGREE = (PI ~/ 180);

    static int math_abs(LuaState.lua_State L)
    {
        LuaAPI.lua_pushnumber(L, Math.abs(LuaAuxLib.luaL_checknumber(L, 1)));
        return 1;
    }

    static int math_sin(LuaState.lua_State L)
    {
        LuaAPI.lua_pushnumber(L, Math.sin(LuaAuxLib.luaL_checknumber(L, 1)));
        return 1;
    }

    static int math_sinh(LuaState.lua_State L)
    {
        LuaAPI.lua_pushnumber(L, Math.sinh(LuaAuxLib.luaL_checknumber(L, 1)));
        return 1;
    }

    static int math_cos(LuaState.lua_State L)
    {
        LuaAPI.lua_pushnumber(L, Math.cos(LuaAuxLib.luaL_checknumber(L, 1)));
        return 1;
    }

    static int math_cosh(LuaState.lua_State L)
    {
        LuaAPI.lua_pushnumber(L, Math.cosh(LuaAuxLib.luaL_checknumber(L, 1)));
        return 1;
    }

    static int math_tan(LuaState.lua_State L)
    {
        LuaAPI.lua_pushnumber(L, Math.tan(LuaAuxLib.luaL_checknumber(L, 1)));
        return 1;
    }

    static int math_tanh(LuaState.lua_State L)
    {
        LuaAPI.lua_pushnumber(L, Math.tanh(LuaAuxLib.luaL_checknumber(L, 1)));
        return 1;
    }

    static int math_asin(LuaState.lua_State L)
    {
        LuaAPI.lua_pushnumber(L, Math.asin(LuaAuxLib.luaL_checknumber(L, 1)));
        return 1;
    }

    static int math_acos(LuaState.lua_State L)
    {
        LuaAPI.lua_pushnumber(L, Math.acos(LuaAuxLib.luaL_checknumber(L, 1)));
        return 1;
    }

    static int math_atan(LuaState.lua_State L)
    {
        LuaAPI.lua_pushnumber(L, Math.atan(LuaAuxLib.luaL_checknumber(L, 1)));
        return 1;
    }

    static int math_atan2(LuaState.lua_State L)
    {
        LuaAPI.lua_pushnumber(L, Math.atan2(LuaAuxLib.luaL_checknumber(L, 1), LuaAuxLib.luaL_checknumber(L, 2)));
        return 1;
    }

    static int math_ceil(LuaState.lua_State L)
    {
        LuaAPI.lua_pushnumber(L, Math.ceil(LuaAuxLib.luaL_checknumber(L, 1)));
        return 1;
    }

    static int math_floor(LuaState.lua_State L)
    {
        LuaAPI.lua_pushnumber(L, Math.floor(LuaAuxLib.luaL_checknumber(L, 1)));
        return 1;
    }

    static int math_fmod(LuaState.lua_State L)
    {
        LuaAPI.lua_pushnumber(L, CLib.fmod(LuaAuxLib.luaL_checknumber(L, 1), LuaAuxLib.luaL_checknumber(L, 2)));
        return 1;
    }

    static int math_modf(LuaState.lua_State L)
    {
        List<double> ip = new List<double>(1);
        double fp = CLib.modf(LuaAuxLib.luaL_checknumber(L, 1), ip);
        LuaAPI.lua_pushnumber(L, ip[0]);
        LuaAPI.lua_pushnumber(L, fp);
        return 2;
    }

    static int math_sqrt(LuaState.lua_State L)
    {
        LuaAPI.lua_pushnumber(L, Math.sqrt(LuaAuxLib.luaL_checknumber(L, 1)));
        return 1;
    }

    static int math_pow(LuaState.lua_State L)
    {
        LuaAPI.lua_pushnumber(L, Math.pow(LuaAuxLib.luaL_checknumber(L, 1), LuaAuxLib.luaL_checknumber(L, 2)));
        return 1;
    }

    static int math_log(LuaState.lua_State L)
    {
        LuaAPI.lua_pushnumber(L, Math.log(LuaAuxLib.luaL_checknumber(L, 1)));
        return 1;
    }

    static int math_log10(LuaState.lua_State L)
    {
        LuaAPI.lua_pushnumber(L, Math.log10(LuaAuxLib.luaL_checknumber(L, 1)));
        return 1;
    }

    static int math_exp(LuaState.lua_State L)
    {
        LuaAPI.lua_pushnumber(L, Math.exp(LuaAuxLib.luaL_checknumber(L, 1)));
        return 1;
    }

    static int math_deg(LuaState.lua_State L)
    {
        LuaAPI.lua_pushnumber(L, LuaAuxLib.luaL_checknumber(L, 1) ~/ RADIANS_PER_DEGREE);
        return 1;
    }

    static int math_rad(LuaState.lua_State L)
    {
        LuaAPI.lua_pushnumber(L, LuaAuxLib.luaL_checknumber(L, 1) * RADIANS_PER_DEGREE);
        return 1;
    }

    static int math_frexp(LuaState.lua_State L)
    {
        List<int> e = new List<int>(1);
        LuaAPI.lua_pushnumber(L, CLib.frexp(LuaAuxLib.luaL_checknumber(L, 1), e));
        LuaAPI.lua_pushinteger(L, e[0]);
        return 2;
    }

    static int math_ldexp(LuaState.lua_State L)
    {
        LuaAPI.lua_pushnumber(L, CLib.ldexp(LuaAuxLib.luaL_checknumber(L, 1), LuaAuxLib.luaL_checkint(L, 2)));
        return 1;
    }

    static int math_min(LuaState.lua_State L)
    {
        int n = LuaAPI.lua_gettop(L);
        double dmin = LuaAuxLib.luaL_checknumber(L, 1);
        int i;
        for ((i = 2); i <= n; i++) {
            double d = LuaAuxLib.luaL_checknumber(L, i);
            if (d < dmin) {
                dmin = d;
            }
        }
        LuaAPI.lua_pushnumber(L, dmin);
        return 1;
    }

    static int math_max(LuaState.lua_State L)
    {
        int n = LuaAPI.lua_gettop(L);
        double dmax = LuaAuxLib.luaL_checknumber(L, 1);
        int i;
        for ((i = 2); i <= n; i++) {
            double d = LuaAuxLib.luaL_checknumber(L, i);
            if (d > dmax) {
                dmax = d;
            }
        }
        LuaAPI.lua_pushnumber(L, dmax);
        return 1;
    }
    static java.util.Random rng = new java.util.Random();

    static int math_random(LuaState.lua_State L)
    {
        double r = rng.nextDouble();
        switch (LuaAPI.lua_gettop(L)) {
            case 0:
                LuaAPI.lua_pushnumber(L, r);
                break;
            case 1:
                int u = LuaAuxLib.luaL_checkint(L, 1);
                LuaAuxLib.luaL_argcheck(L, 1 <= u, 1, "interval is empty");
                LuaAPI.lua_pushnumber(L, Math.floor(r * u) + 1);
                break;
            case 2:
                int l = LuaAuxLib.luaL_checkint(L, 1);
                int u = LuaAuxLib.luaL_checkint(L, 2);
                LuaAuxLib.luaL_argcheck(L, l <= u, 2, "interval is empty");
                LuaAPI.lua_pushnumber(L, Math.floor(r * ((u - l) + 1)) + l);
                break;
            default:
                return LuaAuxLib.luaL_error(L, CLib.CharPtr.toCharPtr("wrong number of arguments"));
        }
        return 1;
    }

    static int math_randomseed(LuaState.lua_State L)
    {
        rng = new java.util.Random(LuaAuxLib.luaL_checkint(L, 1));
        return 0;
    }
    static final List<LuaAuxLib.luaL_Reg> mathlib = [new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("abs"), new LuaMathLib_delegate("math_abs")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("acos"), new LuaMathLib_delegate("math_acos")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("asin"), new LuaMathLib_delegate("math_asin")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("atan2"), new LuaMathLib_delegate("math_atan2")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("atan"), new LuaMathLib_delegate("math_atan")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("ceil"), new LuaMathLib_delegate("math_ceil")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("cosh"), new LuaMathLib_delegate("math_cosh")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("cos"), new LuaMathLib_delegate("math_cos")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("deg"), new LuaMathLib_delegate("math_deg")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("exp"), new LuaMathLib_delegate("math_exp")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("floor"), new LuaMathLib_delegate("math_floor")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("fmod"), new LuaMathLib_delegate("math_fmod")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("frexp"), new LuaMathLib_delegate("math_frexp")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("ldexp"), new LuaMathLib_delegate("math_ldexp")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("log10"), new LuaMathLib_delegate("math_log10")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("log"), new LuaMathLib_delegate("math_log")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("max"), new LuaMathLib_delegate("math_max")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("min"), new LuaMathLib_delegate("math_min")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("modf"), new LuaMathLib_delegate("math_modf")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("pow"), new LuaMathLib_delegate("math_pow")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("rad"), new LuaMathLib_delegate("math_rad")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("random"), new LuaMathLib_delegate("math_random")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("randomseed"), new LuaMathLib_delegate("math_randomseed")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("sinh"), new LuaMathLib_delegate("math_sinh")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("sin"), new LuaMathLib_delegate("math_sin")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("sqrt"), new LuaMathLib_delegate("math_sqrt")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("tanh"), new LuaMathLib_delegate("math_tanh")), new LuaAuxLib.luaL_Reg(CLib.CharPtr.toCharPtr("tan"), new LuaMathLib_delegate("math_tan")), new LuaAuxLib.luaL_Reg(null, null)];

    static int luaopen_math(LuaState.lua_State L)
    {
        LuaAuxLib.luaL_register(L, CLib.CharPtr.toCharPtr(LuaLib.LUA_MATHLIBNAME), mathlib);
        LuaAPI.lua_pushnumber(L, PI);
        LuaAPI.lua_setfield(L, -2, CLib.CharPtr.toCharPtr("pi"));
        LuaAPI.lua_pushnumber(L, CLib.HUGE_VAL);
        LuaAPI.lua_setfield(L, -2, CLib.CharPtr.toCharPtr("huge"));
        LuaAPI.lua_getfield(L, -1, CLib.CharPtr.toCharPtr("fmod"));
        LuaAPI.lua_setfield(L, -2, CLib.CharPtr.toCharPtr("mod"));
        return 1;
    }
}

class LuaMathLib_delegate with Lua_lua_CFunction
{
    String name;

    LuaMathLib_delegate_(String name)
    {
        this.name = name;
    }

    final int exec(LuaState.lua_State L)
    {
        if (new String("math_abs") == name) {
            return math_abs(L);
        } else {
            if (new String("math_acos") == name) {
                return math_acos(L);
            } else {
                if (new String("math_asin") == name) {
                    return math_asin(L);
                } else {
                    if (new String("math_atan2") == name) {
                        return math_atan2(L);
                    } else {
                        if (new String("math_atan") == name) {
                            return math_atan(L);
                        } else {
                            if (new String("math_ceil") == name) {
                                return math_ceil(L);
                            } else {
                                if (new String("math_cosh") == name) {
                                    return math_cosh(L);
                                } else {
                                    if (new String("math_cos") == name) {
                                        return math_cos(L);
                                    } else {
                                        if (new String("math_deg") == name) {
                                            return math_deg(L);
                                        } else {
                                            if (new String("math_exp") == name) {
                                                return math_exp(L);
                                            } else {
                                                if (new String("math_floor") == name) {
                                                    return math_floor(L);
                                                } else {
                                                    if (new String("math_fmod") == name) {
                                                        return math_fmod(L);
                                                    } else {
                                                        if (new String("math_frexp") == name) {
                                                            return math_frexp(L);
                                                        } else {
                                                            if (new String("math_ldexp") == name) {
                                                                return math_ldexp(L);
                                                            } else {
                                                                if (new String("math_log10") == name) {
                                                                    return math_log10(L);
                                                                } else {
                                                                    if (new String("math_log") == name) {
                                                                        return math_log(L);
                                                                    } else {
                                                                        if (new String("math_max") == name) {
                                                                            return math_max(L);
                                                                        } else {
                                                                            if (new String("math_min") == name) {
                                                                                return math_min(L);
                                                                            } else {
                                                                                if (new String("math_modf") == name) {
                                                                                    return math_modf(L);
                                                                                } else {
                                                                                    if (new String("math_pow") == name) {
                                                                                        return math_pow(L);
                                                                                    } else {
                                                                                        if (new String("math_rad") == name) {
                                                                                            return math_rad(L);
                                                                                        } else {
                                                                                            if (new String("math_random") == name) {
                                                                                                return math_random(L);
                                                                                            } else {
                                                                                                if (new String("math_randomseed") == name) {
                                                                                                    return math_randomseed(L);
                                                                                                } else {
                                                                                                    if (new String("math_sinh") == name) {
                                                                                                        return math_sinh(L);
                                                                                                    } else {
                                                                                                        if (new String("math_sin") == name) {
                                                                                                            return math_sin(L);
                                                                                                        } else {
                                                                                                            if (new String("math_sqrt") == name) {
                                                                                                                return math_sqrt(L);
                                                                                                            } else {
                                                                                                                if (new String("math_tanh") == name) {
                                                                                                                    return math_tanh(L);
                                                                                                                } else {
                                                                                                                    if (new String("math_tan") == name) {
                                                                                                                        return math_tan(L);
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
