library kurumi;

class ClassType
{
    static final bool DONNOT_USE_REIMPLEMENT = false;
    static const int TYPE_CHAR = 1;
    static const int TYPE_INT = 2;
    static const int TYPE_DOUBLE = 3;
    static const int TYPE_LONG = 4;
    static const int TYPE_LG = 5;
    static const int TYPE_FILEPTR = 6;
    static const int TYPE_TVALUE = 7;
    static const int TYPE_CCLOSURE = 8;
    static const int TYPE_LCLOSURE = 9;
    static const int TYPE_TABLE = 10;
    static const int TYPE_GCOBJECTREF = 11;
    static const int TYPE_TSTRING = 12;
    static const int TYPE_NODE = 13;
    static const int TYPE_UDATA = 14;
    static const int TYPE_LUA_STATE = 15;
    static const int TYPE_CALLINFO = 16;
    static const int TYPE_PROTO = 17;
    static const int TYPE_LOCVAR = 18;
    static const int TYPE_CLOSURE = 19;
    static const int TYPE_UPVAL = 20;
    static const int TYPE_INT32 = 21;
    static const int TYPE_GCOBJECT = 22;
    static const int TYPE_CHARPTR = 23;
    int type = 0;

    ClassType(int type)
    {
        this.type = type;
    }

    final int GetTypeID()
    {
        return this.type;
    }

    final String GetTypeString()
    {
        if (DONNOT_USE_REIMPLEMENT) {
            return GetTypeString_csharp();
        } else {
            String result = null;
            if (type == TYPE_CHAR) {
                result = "Char";
            } else {
                if (type == TYPE_INT) {
                    result = "Int";
                } else {
                    if (type == TYPE_DOUBLE) {
                        result = "Double";
                    } else {
                        if (type == TYPE_LONG) {
                            result = "Int64";
                        } else {
                            if (type == TYPE_LG) {
                                result = "LG";
                            } else {
                                if (type == TYPE_FILEPTR) {
                                    result = "FilePtr";
                                } else {
                                    if (type == TYPE_TVALUE) {
                                        result = "TValue";
                                    } else {
                                        if (type == TYPE_CCLOSURE) {
                                            result = "CClosure";
                                        } else {
                                            if (type == TYPE_LCLOSURE) {
                                                result = "LClosure";
                                            } else {
                                                if (type == TYPE_TABLE) {
                                                    result = "Table";
                                                } else {
                                                    if (type == TYPE_GCOBJECTREF) {
                                                        result = "GCObjectRef";
                                                    } else {
                                                        if (type == TYPE_TSTRING) {
                                                            result = "TString";
                                                        } else {
                                                            if (type == TYPE_NODE) {
                                                                result = "Node";
                                                            } else {
                                                                if (type == TYPE_UDATA) {
                                                                    result = "Udata";
                                                                } else {
                                                                    if (type == TYPE_LUA_STATE) {
                                                                        result = "lua_State";
                                                                    } else {
                                                                        if (type == TYPE_CALLINFO) {
                                                                            result = "CallInfo";
                                                                        } else {
                                                                            if (type == TYPE_PROTO) {
                                                                                result = "Proto";
                                                                            } else {
                                                                                if (type == TYPE_LOCVAR) {
                                                                                    result = "LocVar";
                                                                                } else {
                                                                                    if (type == TYPE_CLOSURE) {
                                                                                        result = "Closure";
                                                                                    } else {
                                                                                        if (type == TYPE_UPVAL) {
                                                                                            result = "UpVal";
                                                                                        } else {
                                                                                            if (type == TYPE_INT32) {
                                                                                                result = "Int32";
                                                                                            } else {
                                                                                                if (type == TYPE_GCOBJECT) {
                                                                                                    result = "GCObject";
                                                                                                } else {
                                                                                                    if (type == TYPE_CHARPTR) {
                                                                                                        result = "CharPtr";
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
            if (result == null) {
                return "unknown type";
            } else {
                return result;
            }
        }
    }

    final Object Alloc()
    {
        if (DONNOT_USE_REIMPLEMENT) {
            return Alloc_csharp();
        } else {
            Object result = null;
            if (type == TYPE_CHAR) {
                result = new Character('\0'.codeUnitAt(0));
            } else {
                if (type == TYPE_INT) {
                    result = new Integer(0);
                } else {
                    if (type == TYPE_DOUBLE) {
                        result = new Double(0);
                    } else {
                        if (type == TYPE_LONG) {
                            result = new Long(0);
                        } else {
                            if (type == TYPE_LG) {
                                result = new LuaState.LG();
                            } else {
                                if (type == TYPE_FILEPTR) {
                                    result = new LuaIOLib.FilePtr();
                                } else {
                                    if (type == TYPE_TVALUE) {
                                        result = new LuaObject.TValue();
                                    } else {
                                        if (type == TYPE_CCLOSURE) {
                                            throw new RuntimeException("alloc CClosure error");
                                        } else {
                                            if (type == TYPE_LCLOSURE) {
                                                throw new RuntimeException("alloc LClosure error");
                                            } else {
                                                if (type == TYPE_TABLE) {
                                                    result = new LuaObject.Table();
                                                } else {
                                                    if (type == TYPE_GCOBJECTREF) {
                                                        throw new RuntimeException("alloc GCObjectRef error");
                                                    } else {
                                                        if (type == TYPE_TSTRING) {
                                                            result = new LuaObject.TString();
                                                        } else {
                                                            if (type == TYPE_NODE) {
                                                                result = new LuaObject.Node();
                                                            } else {
                                                                if (type == TYPE_UDATA) {
                                                                    result = new LuaObject.Udata();
                                                                } else {
                                                                    if (type == TYPE_LUA_STATE) {
                                                                        result = new LuaState.lua_State();
                                                                    } else {
                                                                        if (type == TYPE_CALLINFO) {
                                                                            result = new LuaState.CallInfo();
                                                                        } else {
                                                                            if (type == TYPE_PROTO) {
                                                                                result = new LuaObject.Proto();
                                                                            } else {
                                                                                if (type == TYPE_LOCVAR) {
                                                                                    result = new LuaObject.LocVar();
                                                                                } else {
                                                                                    if (type == TYPE_CLOSURE) {
                                                                                        result = new LuaObject.Closure();
                                                                                    } else {
                                                                                        if (type == TYPE_UPVAL) {
                                                                                            result = new LuaObject.UpVal();
                                                                                        } else {
                                                                                            if (type == TYPE_INT32) {
                                                                                                result = new Integer(0);
                                                                                            } else {
                                                                                                if (type == TYPE_GCOBJECT) {
                                                                                                    result = new LuaState.GCObject();
                                                                                                } else {
                                                                                                    if (type == TYPE_CHARPTR) {
                                                                                                        result = new CLib.CharPtr();
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
            if (result == null) {
                throw new RuntimeException("alloc unknown type error");
            } else {
                return result;
            }
        }
    }

    final bool CanIndex()
    {
        if (DONNOT_USE_REIMPLEMENT) {
            return CanIndex_csharp();
        } else {
            if (type == TYPE_CHAR) {
                return false;
            } else {
                if (type == TYPE_INT) {
                    return false;
                } else {
                    if (type == TYPE_LOCVAR) {
                        return false;
                    } else {
                        if (type == TYPE_LONG) {
                            return false;
                        } else {
                            return true;
                        }
                    }
                }
            }
        }
    }

    final int GetUnmanagedSize()
    {
        if (DONNOT_USE_REIMPLEMENT) {
            return GetUnmanagedSize_csharp();
        } else {
            int result = (-1);
            if (type == TYPE_LG) {
                result = 376;
            } else {
                if (type == TYPE_CALLINFO) {
                    result = 24;
                } else {
                    if (type == TYPE_TVALUE) {
                        result = 16;
                    } else {
                        if (type == TYPE_TABLE) {
                            result = 32;
                        } else {
                            if (type == TYPE_NODE) {
                                result = 32;
                            } else {
                                if (type == TYPE_GCOBJECT) {
                                    result = 120;
                                } else {
                                    if (type == TYPE_GCOBJECTREF) {
                                        result = 4;
                                    } else {
                                        if (type == TYPE_CLOSURE) {
                                            result = 0;
                                        } else {
                                            if (type == TYPE_PROTO) {
                                                result = 76;
                                            } else {
                                                if (type == TYPE_LUA_STATE) {
                                                    result = 120;
                                                } else {
                                                    if (type == TYPE_TVALUE) {
                                                        result = 16;
                                                    } else {
                                                        if (type == TYPE_TSTRING) {
                                                            result = 16;
                                                        } else {
                                                            if (type == TYPE_LOCVAR) {
                                                                result = 12;
                                                            } else {
                                                                if (type == TYPE_UPVAL) {
                                                                    result = 32;
                                                                } else {
                                                                    if (type == TYPE_CCLOSURE) {
                                                                        result = 40;
                                                                    } else {
                                                                        if (type == TYPE_LCLOSURE) {
                                                                            result = 24;
                                                                        } else {
                                                                            if (type == TYPE_FILEPTR) {
                                                                                result = 4;
                                                                            } else {
                                                                                if (type == TYPE_UDATA) {
                                                                                    result = 24;
                                                                                } else {
                                                                                    if (type == TYPE_CHAR) {
                                                                                        result = 1;
                                                                                    } else {
                                                                                        if (type == TYPE_INT32) {
                                                                                            result = 4;
                                                                                        } else {
                                                                                            if (type == TYPE_INT) {
                                                                                                result = 4;
                                                                                            } else {
                                                                                                if (type == TYPE_LONG) {
                                                                                                    result = 8;
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
            if (result < 0) {
                throw new RuntimeException("Trying to get unknown sized of unmanaged type " + GetTypeString());
            } else {
                return result;
            }
        }
    }

    final int GetMarshalSizeOf()
    {
        if (DONNOT_USE_REIMPLEMENT) {
            return GetMarshalSizeOf_csharp();
        } else {
            return GetUnmanagedSize();
        }
    }

    final List<int> ObjToBytes(Object b)
    {
        if (DONNOT_USE_REIMPLEMENT) {
            return ObjToBytes_csharp(b);
        } else {
            return null;
        }
    }

    final List<int> ObjToBytes2(Object b)
    {
        if (DONNOT_USE_REIMPLEMENT) {
            return ObjToBytes2_csharp(b);
        } else {
            return ObjToBytes(b);
        }
    }

    final Object bytesToObj(List<int> bytes)
    {
        if (DONNOT_USE_REIMPLEMENT) {
            return bytesToObj_csharp(bytes);
        } else {
            return null;
        }
    }

    static int GetNumInts()
    {
        return 8 ~/ 4;
    }

    static int SizeOfInt()
    {
        return 4;
    }

    static int SizeOfLong()
    {
        return 8;
    }

    static int SizeOfDouble()
    {
        return 8;
    }

    static double ConvertToSingle(Object o)
    {
        return Float.parseFloat(o.toString());
    }

    static int ConvertToChar(String str)
    {
        return (str.length > 0) ? str.codeUnitAt(0) : '\0'.codeUnitAt(0);
    }

    static int ConvertToInt32(String str)
    {
        return Integer_.parseInt(str);
    }

    static int ConvertToInt32(int i)
    {
        return i;
    }

    static int ConvertToInt32_object(Object i)
    {
        return Integer_.parseInt(i.toString());
    }

    static double ConvertToDouble(String str, List<bool> isSuccess)
    {
        if (isSuccess != null) {
            isSuccess[0] = true;
        }
        try {
            return Double_.parseDouble(str);
        } on java.lang.Exception catch (e2) {
            if (isSuccess != null) {
                isSuccess[0] = false;
            }
            return 0;
        }
    }

    static bool isNaN(double d)
    {
        return Double_.isNaN(d);
    }

    static int log2(double x)
    {
        if (DONNOT_USE_REIMPLEMENT) {
            return log2_csharp(x);
        } else {
            return Math.log(x) ~/ Math.log(2);
        }
    }

    static double ConvertToInt32(Object obj)
    {
        return Integer_.parseInt(obj.toString());
    }

    static bool IsPunctuation(int c)
    {
        if ((((((((((c == ','.codeUnitAt(0)) || (c == '.'.codeUnitAt(0))) || (c == ';'.codeUnitAt(0))) || (c == ':'.codeUnitAt(0))) || (c == '!'.codeUnitAt(0))) || (c == '?'.codeUnitAt(0))) || (c == '/'.codeUnitAt(0))) || (c == '\\'.codeUnitAt(0))) || (c == '\''.codeUnitAt(0))) || (c == '\"'.codeUnitAt(0))) {
            return true;
        } else {
            return false;
        }
    }

    static int IndexOfAny(String str, List<int> anyOf)
    {
        if (DONNOT_USE_REIMPLEMENT) {
            return IndexOfAny_csharp(str, anyOf);
        } else {
            int index = (-1);
            for (int i = 0; i < anyOf.length; i++) {
                int index2 = str.indexOf(anyOf[i]);
                if (index2 >= 0) {
                    if (index == (-1)) {
                        index = index2;
                    } else {
                        if (index2 < index) {
                            index = index2;
                        }
                    }
                }
            }
            return index;
        }
    }

    static void Assert(bool condition)
    {
        if (DONNOT_USE_REIMPLEMENT) {
            Assert_csharp(condition);
        } else {
            if (!condition) {
                throw new RuntimeException("Assert");
            }
        }
    }

    static void Assert(bool condition, String message)
    {
        if (DONNOT_USE_REIMPLEMENT) {
            Assert_csharp(condition, message);
        } else {
            if (!condition) {
                throw new RuntimeException(message);
            }
        }
    }

    static int processExec(String strCmdLine)
    {
        if (DONNOT_USE_REIMPLEMENT) {
            return processExec_csharp(strCmdLine);
        } else {
            return 0;
        }
    }

    final Object ToArray(List<Object> arr)
    {
        if (DONNOT_USE_REIMPLEMENT) {
            return ToArray_csharp(arr);
        } else {
            return null;
        }
    }

    static List<int> GetBytes(double d)
    {
        int value = Double_.doubleToRawLongBits(d);
        List<int> byteRet = new List<int>(8);
        for (int i = 0; i < 8; i++) {
            byteRet[i] = ((value >> (8 * i)) & 15);
        }
        return byteRet;
    }

    List<int> ObjToBytes2_csharp(Object b)
    {
        return null;
    }

    int GetMarshalSizeOf_csharp()
    {
        return 0;
    }

    Object bytesToObj_csharp(List<int> bytes)
    {
        return null;
    }

    List<int> ObjToBytes_csharp(Object b)
    {
        return null;
    }

    static int processExec_csharp(String strCmdLine)
    {
        return 0;
    }

    Object Alloc_csharp()
    {
        return null;
    }

    static void Assert_csharp(bool condition)
    {
    }

    static void Assert_csharp(bool condition, String message)
    {
    }

    java.lang.Class GetOriginalType_csharp()
    {
        return null;
    }

    Object ToArray_csharp(List<Object> arr)
    {
        return null;
    }

    bool CanIndex_csharp()
    {
        return false;
    }

    String GetTypeString_csharp()
    {
        return null;
    }

    int GetUnmanagedSize_csharp()
    {
        return 0;
    }

    static int IndexOfAny_csharp(String str, List<int> anyOf)
    {
        return 0;
    }

    static int log2_csharp(double x)
    {
        return 0;
    }
}
