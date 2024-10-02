library kurumi;

class LuaOpCodes
{
    static const int SIZE_C = 9;
    static const int SIZE_B = 9;
    static const int SIZE_Bx = (SIZE_C + SIZE_B);
    static const int SIZE_A = 8;
    static const int SIZE_OP = 6;
    static const int POS_OP = 0;
    static const int POS_A = (POS_OP + SIZE_OP);
    static const int POS_C = (POS_A + SIZE_A);
    static const int POS_B = (POS_C + SIZE_C);
    static const int POS_Bx = POS_C;
    static const int MAXARG_Bx = ((1 << SIZE_Bx) - 1);
    static const int MAXARG_sBx = (MAXARG_Bx >> 1);
    static const int MAXARG_A = (((1 << SIZE_A) - 1) & 268435455);
    static const int MAXARG_B = (((1 << SIZE_B) - 1) & 268435455);
    static const int MAXARG_C = (((1 << SIZE_C) - 1) & 268435455);

    static int MASK1(int n, int p)
    {
        return ((~((~0) << n)) << p) & 268435455;
    }

    static int MASK0(int n, int p)
    {
        return (~MASK1(n, p)) & 268435455;
    }

    static OpCode GET_OPCODE(int i)
    {
        return longToOpCode((i >> POS_OP) & MASK1(SIZE_OP, 0));
    }

    static OpCode GET_OPCODE(LuaCode.InstructionPtr i)
    {
        return GET_OPCODE(i.get(0));
    }

    static void SET_OPCODE(List<int> i, int o)
    {
        i[0] = ((i[0] & MASK0(SIZE_OP, POS_OP)) | ((o << POS_OP) & MASK1(SIZE_OP, POS_OP)));
    }

    static void SET_OPCODE(List<int> i, OpCode opcode)
    {
        i[0] = ((i[0] & MASK0(SIZE_OP, POS_OP)) | ((opcode.getValue() << POS_OP) & MASK1(SIZE_OP, POS_OP)));
    }

    static void SET_OPCODE(LuaCode.InstructionPtr i, OpCode opcode)
    {
        List<int> c_ref = new List<int>(1);
        c_ref[0] = i.codes[i.pc];
        SET_OPCODE(c_ref, opcode);
        i.codes[i.pc] = c_ref[0];
    }

    static int GETARG_A(int i)
    {
        return (i >> POS_A) & MASK1(SIZE_A, 0);
    }

    static int GETARG_A(LuaCode.InstructionPtr i)
    {
        return GETARG_A(i.get(0));
    }

    static void SETARG_A(LuaCode.InstructionPtr i, int u)
    {
        i.set(0, (i.get(0) & MASK0(SIZE_A, POS_A)) | ((u << POS_A) & MASK1(SIZE_A, POS_A)));
    }

    static int GETARG_B(int i)
    {
        return (i >> POS_B) & MASK1(SIZE_B, 0);
    }

    static int GETARG_B(LuaCode.InstructionPtr i)
    {
        return GETARG_B(i.get(0));
    }

    static void SETARG_B(LuaCode.InstructionPtr i, int b)
    {
        i.set(0, (i.get(0) & MASK0(SIZE_B, POS_B)) | ((b << POS_B) & MASK1(SIZE_B, POS_B)));
    }

    static int GETARG_C(int i)
    {
        return (i >> POS_C) & MASK1(SIZE_C, 0);
    }

    static int GETARG_C(LuaCode.InstructionPtr i)
    {
        return GETARG_C(i.get(0));
    }

    static void SETARG_C(LuaCode.InstructionPtr i, int b)
    {
        i.set(0, (i.get(0) & MASK0(SIZE_C, POS_C)) | ((b << POS_C) & MASK1(SIZE_C, POS_C)));
    }

    static int GETARG_Bx(int i)
    {
        return (i >> POS_Bx) & MASK1(SIZE_Bx, 0);
    }

    static int GETARG_Bx(LuaCode.InstructionPtr i)
    {
        return GETARG_Bx(i.get(0));
    }

    static void SETARG_Bx(LuaCode.InstructionPtr i, int b)
    {
        i.set(0, (i.get(0) & MASK0(SIZE_Bx, POS_Bx)) | ((b << POS_Bx) & MASK1(SIZE_Bx, POS_Bx)));
    }

    static int GETARG_sBx(int i)
    {
        return GETARG_Bx(i) - MAXARG_sBx;
    }

    static int GETARG_sBx(LuaCode.InstructionPtr i)
    {
        return GETARG_sBx(i.get(0));
    }

    static void SETARG_sBx(LuaCode.InstructionPtr i, int b)
    {
        SETARG_Bx(i, b + MAXARG_sBx);
    }

    static int CREATE_ABC(OpCode o, int a, int b, int c)
    {
        return (((o.getValue() << POS_OP) | (a << POS_A)) | (b << POS_B)) | (c << POS_C);
    }

    static int CREATE_ABx(OpCode o, int a, int bc)
    {
        int result = (((o.getValue() << POS_OP) | (a << POS_A)) | (bc << POS_Bx));
        return ((o.getValue() << POS_OP) | (a << POS_A)) | (bc << POS_Bx);
    }
    static const int BITRK = (1 << (SIZE_B - 1));

    static int ISK(int x)
    {
        return x & BITRK;
    }

    static int INDEXK(int r)
    {
        return r & (~BITRK);
    }
    static const int MAXINDEXRK = (BITRK - 1);

    static int RKASK(int x)
    {
        return x | BITRK;
    }
    static const int NO_REG = MAXARG_A;








    
    static int opCodeToLong(LuaOpCodes.OpCode code)
    {
        switch (code) {
            case OP_MOVE:
                return 0;
            case OP_LOADK:
                return 1;
            case OP_LOADBOOL:
                return 2;
            case OP_LOADNIL:
                return 3;
            case OP_GETUPVAL:
                return 4;
            case OP_GETGLOBAL:
                return 5;
            case OP_GETTABLE:
                return 6;
            case OP_SETGLOBAL:
                return 7;
            case OP_SETUPVAL:
                return 8;
            case OP_SETTABLE:
                return 9;
            case OP_NEWTABLE:
                return 10;
            case OP_SELF:
                return 11;
            case OP_ADD:
                return 12;
            case OP_SUB:
                return 13;
            case OP_MUL:
                return 14;
            case OP_DIV:
                return 15;
            case OP_MOD:
                return 16;
            case OP_POW:
                return 17;
            case OP_UNM:
                return 18;
            case OP_NOT:
                return 19;
            case OP_LEN:
                return 20;
            case OP_CONCAT:
                return 21;
            case OP_JMP:
                return 22;
            case OP_EQ:
                return 23;
            case OP_LT:
                return 24;
            case OP_LE:
                return 25;
            case OP_TEST:
                return 26;
            case OP_TESTSET:
                return 27;
            case OP_CALL:
                return 28;
            case OP_TAILCALL:
                return 29;
            case OP_RETURN:
                return 30;
            case OP_FORLOOP:
                return 31;
            case OP_FORPREP:
                return 32;
            case OP_TFORLOOP:
                return 33;
            case OP_SETLIST:
                return 34;
            case OP_CLOSE:
                return 35;
            case OP_CLOSURE:
                return 36;
            case OP_VARARG:
                return 37;
        }
        throw new RuntimeException("OpCode error");
    }

    static LuaOpCodes.OpCode longToOpCode(int code)
    {
        switch (code) {
            case 0:
                return LuaOpCodes.OpCode.OP_MOVE;
            case 1:
                return LuaOpCodes.OpCode.OP_LOADK;
            case 2:
                return LuaOpCodes.OpCode.OP_LOADBOOL;
            case 3:
                return LuaOpCodes.OpCode.OP_LOADNIL;
            case 4:
                return LuaOpCodes.OpCode.OP_GETUPVAL;
            case 5:
                return LuaOpCodes.OpCode.OP_GETGLOBAL;
            case 6:
                return LuaOpCodes.OpCode.OP_GETTABLE;
            case 7:
                return LuaOpCodes.OpCode.OP_SETGLOBAL;
            case 8:
                return LuaOpCodes.OpCode.OP_SETUPVAL;
            case 9:
                return LuaOpCodes.OpCode.OP_SETTABLE;
            case 10:
                return LuaOpCodes.OpCode.OP_NEWTABLE;
            case 11:
                return LuaOpCodes.OpCode.OP_SELF;
            case 12:
                return LuaOpCodes.OpCode.OP_ADD;
            case 13:
                return LuaOpCodes.OpCode.OP_SUB;
            case 14:
                return LuaOpCodes.OpCode.OP_MUL;
            case 15:
                return LuaOpCodes.OpCode.OP_DIV;
            case 16:
                return LuaOpCodes.OpCode.OP_MOD;
            case 17:
                return LuaOpCodes.OpCode.OP_POW;
            case 18:
                return LuaOpCodes.OpCode.OP_UNM;
            case 19:
                return LuaOpCodes.OpCode.OP_NOT;
            case 20:
                return LuaOpCodes.OpCode.OP_LEN;
            case 21:
                return LuaOpCodes.OpCode.OP_CONCAT;
            case 22:
                return LuaOpCodes.OpCode.OP_JMP;
            case 23:
                return LuaOpCodes.OpCode.OP_EQ;
            case 24:
                return LuaOpCodes.OpCode.OP_LT;
            case 25:
                return LuaOpCodes.OpCode.OP_LE;
            case 26:
                return LuaOpCodes.OpCode.OP_TEST;
            case 27:
                return LuaOpCodes.OpCode.OP_TESTSET;
            case 28:
                return LuaOpCodes.OpCode.OP_CALL;
            case 29:
                return LuaOpCodes.OpCode.OP_TAILCALL;
            case 30:
                return LuaOpCodes.OpCode.OP_RETURN;
            case 31:
                return LuaOpCodes.OpCode.OP_FORLOOP;
            case 32:
                return LuaOpCodes.OpCode.OP_FORPREP;
            case 33:
                return LuaOpCodes.OpCode.OP_TFORLOOP;
            case 34:
                return LuaOpCodes.OpCode.OP_SETLIST;
            case 35:
                return LuaOpCodes.OpCode.OP_CLOSE;
            case 36:
                return LuaOpCodes.OpCode.OP_CLOSURE;
            case 37:
                return LuaOpCodes.OpCode.OP_VARARG;
        }
        throw new RuntimeException("OpCode error");
    }

        static OpMode getOpMode(OpCode m)
    {
        switch ((luaP_opmodes[m.getValue()] & 3)) {
            default:
            case 0:
                return OpMode_.iABC;
            case 1:
                return OpMode_.iABx;
            case 2:
                return OpMode_.iAsBx;
        }
    }

    static OpArgMask getBMode(OpCode m)
    {
        switch (((luaP_opmodes[m.getValue()] >> 4) & 3)) {
            default:
            case 0:
                return OpArgMask_.OpArgN;
            case 1:
                return OpArgMask_.OpArgU;
            case 2:
                return OpArgMask_.OpArgR;
            case 3:
                return OpArgMask_.OpArgK;
        }
    }

    static OpArgMask getCMode(OpCode m)
    {
        switch (((luaP_opmodes[m.getValue()] >> 2) & 3)) {
            default:
            case 0:
                return OpArgMask_.OpArgN;
            case 1:
                return OpArgMask_.OpArgU;
            case 2:
                return OpArgMask_.OpArgR;
            case 3:
                return OpArgMask_.OpArgK;
        }
    }

    static int testAMode(OpCode m)
    {
        return luaP_opmodes[m.getValue()] & (1 << 6);
    }

    static int testTMode(OpCode m)
    {
        return luaP_opmodes[m.getValue()] & (1 << 7);
    }
    static const int LFIELDS_PER_FLUSH = 50;
    static final List<CLib.CharPtr> luaP_opnames = [CLib.CharPtr.toCharPtr("MOVE"), CLib.CharPtr.toCharPtr("LOADK"), CLib.CharPtr.toCharPtr("LOADBOOL"), CLib.CharPtr.toCharPtr("LOADNIL"), CLib.CharPtr.toCharPtr("GETUPVAL"), CLib.CharPtr.toCharPtr("GETGLOBAL"), CLib.CharPtr.toCharPtr("GETTABLE"), CLib.CharPtr.toCharPtr("SETGLOBAL"), CLib.CharPtr.toCharPtr("SETUPVAL"), CLib.CharPtr.toCharPtr("SETTABLE"), CLib.CharPtr.toCharPtr("NEWTABLE"), CLib.CharPtr.toCharPtr("SELF"), CLib.CharPtr.toCharPtr("ADD"), CLib.CharPtr.toCharPtr("SUB"), CLib.CharPtr.toCharPtr("MUL"), CLib.CharPtr.toCharPtr("DIV"), CLib.CharPtr.toCharPtr("MOD"), CLib.CharPtr.toCharPtr("POW"), CLib.CharPtr.toCharPtr("UNM"), CLib.CharPtr.toCharPtr("NOT"), CLib.CharPtr.toCharPtr("LEN"), CLib.CharPtr.toCharPtr("CONCAT"), CLib.CharPtr.toCharPtr("JMP"), CLib.CharPtr.toCharPtr("EQ"), CLib.CharPtr.toCharPtr("LT"), CLib.CharPtr.toCharPtr("LE"), CLib.CharPtr.toCharPtr("TEST"), CLib.CharPtr.toCharPtr("TESTSET"), CLib.CharPtr.toCharPtr("CALL"), CLib.CharPtr.toCharPtr("TAILCALL"), CLib.CharPtr.toCharPtr("RETURN"), CLib.CharPtr.toCharPtr("FORLOOP"), CLib.CharPtr.toCharPtr("FORPREP"), CLib.CharPtr.toCharPtr("TFORLOOP"), CLib.CharPtr.toCharPtr("SETLIST"), CLib.CharPtr.toCharPtr("CLOSE"), CLib.CharPtr.toCharPtr("CLOSURE"), CLib.CharPtr.toCharPtr("VARARG")];

    static int opmode(int t, int a, OpArgMask b, OpArgMask c, OpMode m)
    {
        int bValue = 0;
        int cValue = 0;
        int mValue = 0;
        switch (b) {
            case OpArgN:
                bValue = 0;
                break;
            case OpArgU:
                bValue = 1;
                break;
            case OpArgR:
                bValue = 2;
                break;
            case OpArgK:
                bValue = 3;
                break;
        }
        switch (c) {
            case OpArgN:
                cValue = 0;
                break;
            case OpArgU:
                cValue = 1;
                break;
            case OpArgR:
                cValue = 2;
                break;
            case OpArgK:
                cValue = 3;
                break;
        }
        switch (m) {
            case iABC:
                mValue = 0;
                break;
            case iABx:
                mValue = 1;
                break;
            case iAsBx:
                mValue = 2;
                break;
        }
        return ((((t << 7) | (a << 6)) | (bValue << 4)) | (cValue << 2)) | mValue;
    }
    static final List<int> luaP_opmodes = [opmode(0, 1, OpArgMask_.OpArgR, OpArgMask_.OpArgN, OpMode_.iABC), opmode(0, 1, OpArgMask_.OpArgK, OpArgMask_.OpArgN, OpMode_.iABx), opmode(0, 1, OpArgMask_.OpArgU, OpArgMask_.OpArgU, OpMode_.iABC), opmode(0, 1, OpArgMask_.OpArgR, OpArgMask_.OpArgN, OpMode_.iABC), opmode(0, 1, OpArgMask_.OpArgU, OpArgMask_.OpArgN, OpMode_.iABC), opmode(0, 1, OpArgMask_.OpArgK, OpArgMask_.OpArgN, OpMode_.iABx), opmode(0, 1, OpArgMask_.OpArgR, OpArgMask_.OpArgK, OpMode_.iABC), opmode(0, 0, OpArgMask_.OpArgK, OpArgMask_.OpArgN, OpMode_.iABx), opmode(0, 0, OpArgMask_.OpArgU, OpArgMask_.OpArgN, OpMode_.iABC), opmode(0, 0, OpArgMask_.OpArgK, OpArgMask_.OpArgK, OpMode_.iABC), opmode(0, 1, OpArgMask_.OpArgU, OpArgMask_.OpArgU, OpMode_.iABC), opmode(0, 1, OpArgMask_.OpArgR, OpArgMask_.OpArgK, OpMode_.iABC), opmode(0, 1, OpArgMask_.OpArgK, OpArgMask_.OpArgK, OpMode_.iABC), opmode(0, 1, OpArgMask_.OpArgK, OpArgMask_.OpArgK, OpMode_.iABC), opmode(0, 1, OpArgMask_.OpArgK, OpArgMask_.OpArgK, OpMode_.iABC), opmode(0, 1, OpArgMask_.OpArgK, OpArgMask_.OpArgK, OpMode_.iABC), opmode(0, 1, OpArgMask_.OpArgK, OpArgMask_.OpArgK, OpMode_.iABC), opmode(0, 1, OpArgMask_.OpArgK, OpArgMask_.OpArgK, OpMode_.iABC), opmode(0, 1, OpArgMask_.OpArgR, OpArgMask_.OpArgN, OpMode_.iABC), opmode(0, 1, OpArgMask_.OpArgR, OpArgMask_.OpArgN, OpMode_.iABC), opmode(0, 1, OpArgMask_.OpArgR, OpArgMask_.OpArgN, OpMode_.iABC), opmode(0, 1, OpArgMask_.OpArgR, OpArgMask_.OpArgR, OpMode_.iABC), opmode(0, 0, OpArgMask_.OpArgR, OpArgMask_.OpArgN, OpMode_.iAsBx), opmode(1, 0, OpArgMask_.OpArgK, OpArgMask_.OpArgK, OpMode_.iABC), opmode(1, 0, OpArgMask_.OpArgK, OpArgMask_.OpArgK, OpMode_.iABC), opmode(1, 0, OpArgMask_.OpArgK, OpArgMask_.OpArgK, OpMode_.iABC), opmode(1, 1, OpArgMask_.OpArgR, OpArgMask_.OpArgU, OpMode_.iABC), opmode(1, 1, OpArgMask_.OpArgR, OpArgMask_.OpArgU, OpMode_.iABC), opmode(0, 1, OpArgMask_.OpArgU, OpArgMask_.OpArgU, OpMode_.iABC), opmode(0, 1, OpArgMask_.OpArgU, OpArgMask_.OpArgU, OpMode_.iABC), opmode(0, 0, OpArgMask_.OpArgU, OpArgMask_.OpArgN, OpMode_.iABC), opmode(0, 1, OpArgMask_.OpArgR, OpArgMask_.OpArgN, OpMode_.iAsBx), opmode(0, 1, OpArgMask_.OpArgR, OpArgMask_.OpArgN, OpMode_.iAsBx), opmode(1, 0, OpArgMask_.OpArgN, OpArgMask_.OpArgU, OpMode_.iABC), opmode(0, 0, OpArgMask_.OpArgU, OpArgMask_.OpArgU, OpMode_.iABC), opmode(0, 0, OpArgMask_.OpArgN, OpArgMask_.OpArgN, OpMode_.iABC), opmode(0, 1, OpArgMask_.OpArgU, OpArgMask_.OpArgN, OpMode_.iABx), opmode(0, 1, OpArgMask_.OpArgU, OpArgMask_.OpArgN, OpMode_.iABC)];
    static const int NUM_OPCODES = OpCode_.OP_VARARG.getValue();
}


//        ===========================================================================
//		  We assume that instructions are unsigned numbers.
//		  All instructions have an opcode in the first 6 bits.
//		  Instructions can have the following fields:
//			`A' : 8 bits
//			`B' : 9 bits
//			`C' : 9 bits
//			`Bx' : 18 bits (`B' and `C' together)
//			`sBx' : signed Bx
//
//		  A signed argument is represented in excess K; that is, the number
//		  value is the unsigned value minus K. K is exactly the maximum value
//		  for that argument (so that -max is represented by 0, and +max is
//		  represented by 2*max), which is half the maximum for the corresponding
//		  unsigned argument.
//		===========================================================================

public static enum OpMode 
{ 
  /* basic instruction format */
  iABC, 
  iABx, 
  iAsBx;

  public int getValue() {
    return this.ordinal();
  }

  public static OpMode forValue(int value) {
    return values()[value];
  }
}


//        
//		 ** R(x) - register
//		 ** Kst(x) - constant (in constant table)
//		 ** RK(x) == if ISK(x) then Kst(INDEXK(x)) else R(x)
//		 


	
	public static enum OpCode {
		/*----------------------------------------------------------------------
		name		args	description
		------------------------------------------------------------------------*/
		OP_MOVE(0),/*	A B	R(A) := R(B)					*/
		OP_LOADK(1),/*	A Bx	R(A) := Kst(Bx)					*/
		OP_LOADBOOL(2),/*	A B C	R(A) := (Bool)B; if (C) pc++			*/
		OP_LOADNIL(3),/*	A B	R(A) := ... := R(B) := nil			*/
		OP_GETUPVAL(4),/*	A B	R(A) := UpValue[B]				*/
		
		OP_GETGLOBAL(5),/*	A Bx	R(A) := Gbl[Kst(Bx)]				*/
		OP_GETTABLE(6),/*	A B C	R(A) := R(B)[RK(C)]				*/
		
		OP_SETGLOBAL(7),/*	A Bx	Gbl[Kst(Bx)] := R(A)				*/
		OP_SETUPVAL(8),/*	A B	UpValue[B] := R(A)				*/
		OP_SETTABLE(9),/*	A B C	R(A)[RK(B)] := RK(C)				*/
		
		OP_NEWTABLE(10),/*	A B C	R(A) := {} (size = B,C)				*/
		
		OP_SELF(11),/*	A B C	R(A+1) := R(B); R(A) := R(B)[RK(C)]		*/
		
		OP_ADD(12),/*	A B C	R(A) := RK(B) + RK(C)				*/
		OP_SUB(13),/*	A B C	R(A) := RK(B) - RK(C)				*/
		OP_MUL(14),/*	A B C	R(A) := RK(B) * RK(C)				*/
		OP_DIV(15),/*	A B C	R(A) := RK(B) / RK(C)				*/
		OP_MOD(16),/*	A B C	R(A) := RK(B) % RK(C)				*/
		OP_POW(17),/*	A B C	R(A) := RK(B) ^ RK(C)				*/
		OP_UNM(18),/*	A B	R(A) := -R(B)					*/
		OP_NOT(19),/*	A B	R(A) := not R(B)				*/
		OP_LEN(20),/*	A B	R(A) := length of R(B)				*/
		
		OP_CONCAT(21),/*	A B C	R(A) := R(B).. ... ..R(C)			*/
		
		OP_JMP(22),/*	sBx	pc+=sBx					*/
		
		OP_EQ(23),/*	A B C	if ((RK(B) == RK(C)) ~= A) then pc++		*/
		OP_LT(24),/*	A B C	if ((RK(B) <  RK(C)) ~= A) then pc++  		*/
		OP_LE(25),/*	A B C	if ((RK(B) <= RK(C)) ~= A) then pc++  		*/
		
		OP_TEST(26),/*	A C	if not (R(A) <=> C) then pc++			*/
		OP_TESTSET(27),/*	A B C	if (R(B) <=> C) then R(A) := R(B) else pc++	*/
		
		OP_CALL(28),/*	A B C	R(A), ... ,R(A+C-2) := R(A)(R(A+1), ... ,R(A+B-1)) */
		OP_TAILCALL(29),/*	A B C	return R(A)(R(A+1), ... ,R(A+B-1))		*/
		OP_RETURN(30),/*	A B	return R(A), ... ,R(A+B-2)	(see note)	*/
		
		OP_FORLOOP(31),/*	A sBx	R(A)+=R(A+2);
					if R(A) <?= R(A+1) then { pc+=sBx; R(A+3)=R(A) }*/
		OP_FORPREP(32),/*	A sBx	R(A)-=R(A+2); pc+=sBx				*/
		
		OP_TFORLOOP(33),/*	A C	R(A+3), ... ,R(A+2+C) := R(A)(R(A+1), R(A+2));
								if R(A+3) ~= nil then R(A+2)=R(A+3) else pc++	*/
		OP_SETLIST(34),/*	A B C	R(A)[(C-1)*FPF+i] := R(A+i), 1 <= i <= B	*/
		
		OP_CLOSE(35),/*	A 	close all variables in the stack up to (>=) R(A)*/
		OP_CLOSURE(36),/*	A Bx	R(A) := closure(KPROTO[Bx], R(A), ... ,R(A+n))	*/
		
		OP_VARARG(37);/*	A B	R(A), R(A+1), ..., R(A+B-1) = vararg		*/

		private int intValue;
		private static java.util.HashMap<Integer, OpCode> mappings;
		private synchronized static java.util.HashMap<Integer, OpCode> getMappings() {
			if (mappings == null) {
				mappings = new java.util.HashMap<Integer, OpCode>();
			}
			return mappings;
		}

		private OpCode(int value) {
			intValue = value;
			OpCode.getMappings().put(value, this);
		}

		public int getValue() {
			return intValue;
		}

		public static OpCode forValue(int value) {
			return getMappings().get(value);
		}
	}


	
	/*===========================================================================
    Notes:
    (*) In OP_CALL, if (B == 0) then B = top. C is the number of returns - 1,
  	  and can be 0: OP_CALL then sets `top' to last_result+1, so
  	  next open instruction (OP_CALL, OP_RETURN, OP_SETLIST) may use `top'.
  
    (*) In OP_VARARG, if (B == 0) then use actual number of varargs and
  	  set top (like in OP_CALL with C == 0).
  
    (*) In OP_RETURN, if (B == 0) then return up to `top'
  
    (*) In OP_SETLIST, if (B == 0) then B = `top';
  	  if (C == 0) then next `instruction' is real C
  
    (*) For comparisons, A specifies what condition the test should accept
  	  (true or false).
  
    (*) All `skips' (pc++) assume that next instruction is a jump
  	===========================================================================*/
	
	
	/*
	 ** masks for instruction properties. The format is:
	 ** bits 0-1: op mode
	 ** bits 2-3: C arg mode
	 ** bits 4-5: B arg mode
	 ** bit 6: instruction set register A
	 ** bit 7: operator is a test
	 */
	
	public static enum OpArgMask {
		OpArgN,  /* argument is not used */
		OpArgU,  /* argument is used */
		OpArgR,  /* argument is a register or a jump offset */
		OpArgK;   /* argument is a constant or register/constant */

		public int getValue() {
			return this.ordinal();
		}

		public static OpArgMask forValue(int value) {
			return values()[value];
		}
	}
