library kurumi;

class CLib
{

    static bool isalpha(int c)
    {
        return Character.isLetter(c);
    }

    static bool iscntrl(int c)
    {
        return Character.isISOControl(c);
    }

    static bool isdigit(int c)
    {
        return Character.isDigit(c);
    }

    static bool islower(int c)
    {
        return Character.isLowerCase(c);
    }

    static bool ispunct(int c)
    {
        return ClassType.IsPunctuation(c);
    }

    static bool isspace(int c)
    {
        return (c == ' '.codeUnitAt(0)) || ((c >= 9) && (c <= 13));
    }

    static bool isupper(int c)
    {
        return Character.isUpperCase(c);
    }

    static bool isalnum(int c)
    {
        return Character.isLetterOrDigit(c);
    }

    static bool isxdigit(int c)
    {
        return new String("0123456789ABCDEFabcdef").indexOf(c) >= 0;
    }

    static bool isalpha(int c)
    {
        return Character.isLetter(c);
    }

    static bool iscntrl(int c)
    {
        return Character.isISOControl(c);
    }

    static bool isdigit(int c)
    {
        return Character.isDigit(c);
    }

    static bool islower(int c)
    {
        return Character.isLowerCase(c);
    }

    static bool ispunct(int c)
    {
        return (c != ' '.codeUnitAt(0)) && (!isalnum(c));
    }

    static bool isspace(int c)
    {
        return (c == ' '.codeUnitAt(0)) || ((c >= 9) && (c <= 13));
    }

    static bool isupper(int c)
    {
        return Character.isUpperCase(c);
    }

    static bool isalnum(int c)
    {
        return Character.isLetterOrDigit(c);
    }

    static int tolower(int c)
    {
        return Character.toLowerCase(c);
    }

    static int toupper(int c)
    {
        return Character.toUpperCase(c);
    }

    static int tolower(int c)
    {
        return Character.toLowerCase(c);
    }

    static int toupper(int c)
    {
        return Character.toUpperCase(c);
    }

    static int strtoul(CharPtr s, List<CharPtr> end, int base_)
    {
        try {
            end[0] = new CharPtr(s.chars, s.index);
            while (end[0].get(0) == ' '.codeUnitAt(0)) {
                end[0] = end[0].next();
            }
            if ((end[0].get(0) == '0'.codeUnitAt(0)) && (end[0].get(1) == 'x'.codeUnitAt(0))) {
                end[0] = end[0].next().next();
            } else {
                if ((end[0].get(0) == '0'.codeUnitAt(0)) && (end[0].get(1) == 'X'.codeUnitAt(0))) {
                    end[0] = end[0].next().next();
                }
            }
            bool negate = false;
            if (end[0].get(0) == '+'.codeUnitAt(0)) {
                end[0] = end[0].next();
            } else {
                if (end[0].get(0) == '-'.codeUnitAt(0)) {
                    negate = true;
                    end[0] = end[0].next();
                }
            }
            bool invalid = false;
            bool had_digits = false;
            int result = 0;
            while (true) {
                int ch = end[0].get(0);
                int this_digit = 0;
                if (isdigit(ch)) {
                    this_digit = (ch - '0'.codeUnitAt(0));
                } else {
                    if (isalpha(ch)) {
                        this_digit = ((tolower(ch) - 'a'.codeUnitAt(0)) + 10);
                    } else {
                        break;
                    }
                }
                if (this_digit >= base_) {
                    invalid = true;
                } else {
                    had_digits = true;
                    result = ((result * base_) + this_digit);
                }
                end[0] = end[0].next();
            }
            if (invalid || (!had_digits)) {
                end[0] = s;
                return Long.MAX_VALUE;
            }
            if (negate) {
                result = (-result);
            }
            return result;
        } on java.lang.Exception catch (e) {
            end[0] = s;
            return 0;
        }
    }

    static void putchar(int ch)
    {
        StreamProxy.Write("" + ch);
    }

    static void putchar(int ch)
    {
        StreamProxy.Write("" + ch);
    }

    static bool isprint(int c)
    {
        return (c >= ' '.codeUnitAt(0)) && (c <= 127);
    }

    static int parse_scanf(String str, CharPtr fmt, List<Object> argp /*XXX*/)
    {
        int parm_index = 0;
        int index = 0;
        while (fmt.get(index) != 0) {
            if (fmt.get(index++) == '%'.codeUnitAt(0)) {
                switch (fmt.get(index++)) {
                    case 's'.codeUnitAt(0):
                        argp[parm_index++] = str;
                        break;
                    case 'c'.codeUnitAt(0):
                        argp[parm_index++] = ClassType.ConvertToChar(str);
                        break;
                    case 'd'.codeUnitAt(0):
                        argp[parm_index++] = ClassType.ConvertToInt32(str);
                        break;
                    case 'l'.codeUnitAt(0):
                        argp[parm_index++] = ClassType.ConvertToDouble(str, null);
                        break;
                    case 'f'.codeUnitAt(0):
                        argp[parm_index++] = ClassType.ConvertToDouble(str, null);
                        break;
                }
            }
        }
        return parm_index;
    }

    static void printf(CharPtr str, List<Object> argv /*XXX*/)
    {
        Tools.printf(str.toString(), argv);
    }

    static void sprintf(CharPtr buffer, CharPtr str, List<Object> argv /*XXX*/)
    {
        String temp = Tools.sprintf(str.toString(), argv);
        strcpy(buffer, CharPtr_.toCharPtr(temp));
    }

    static int fprintf(StreamProxy stream, CharPtr str, List<Object> argv /*XXX*/)
    {
        String result = Tools.sprintf(str.toString(), argv);
        List<int> chars = result.toCharArray();
        List<int> bytes = new List<int>(chars.length);
        for (int i = 0; i < chars.length; i++) {
            bytes[i] = chars[i];
        }
        stream.Write(bytes, 0, bytes.length);
        return 1;
    }
    static const int EXIT_SUCCESS = 0;
    static const int EXIT_FAILURE = 1;

    static int errno()
    {
        return -1;
    }

    static CharPtr strerror(int error)
    {
        return CharPtr_.toCharPtr(String_.format("error #%1\$s", error));
    }

    static CharPtr getenv(CharPtr envname)
    {
        String result = System.getenv(envname.toString());
        return (result != null) ? new CharPtr(result) : null;
    }














































































      static int memcmp(CharPtr ptr1, CharPtr ptr2, int size)
    {
        for (int i = 0; i < size; i++) {
            if (ptr1.get(i) != ptr2.get(i)) {
                if (ptr1.get(i) < ptr2.get(i)) {
                    return -1;
                } else {
                    return 1;
                }
            }
        }
        return 0;
    }

    static CharPtr memchr(CharPtr ptr, int c, int count)
    {
        for (int i = 0; i < count; i++) {
            if (ptr.get(i) == c) {
                return new CharPtr(ptr.chars, ptr.index + i);
            }
        }
        return null;
    }

    static CharPtr strpbrk(CharPtr str, CharPtr charset)
    {
        for (int i = 0; str.get(i) != '\0'.codeUnitAt(0); i++) {
            for (int j = 0; charset.get(j) != '\0'.codeUnitAt(0); j++) {
                if (str.get(i) == charset.get(j)) {
                    return new CharPtr(str.chars, str.index + i);
                }
            }
        }
        return null;
    }

    static CharPtr strchr(CharPtr str, int c)
    {
        for (int index = str.index; str.chars[index] != 0; index++) {
            if (str.chars[index] == c) {
                return new CharPtr(str.chars, index);
            }
        }
        return null;
    }

    static CharPtr strcpy(CharPtr dst, CharPtr src)
    {
        int i;
        for ((i = 0); src.get(i) != '\0'.codeUnitAt(0); i++) {
            dst.set(i, src.get(i));
        }
        dst.set(i, '\0'.codeUnitAt(0));
        return dst;
    }

    static CharPtr strcat(CharPtr dst, CharPtr src)
    {
        int dst_index = 0;
        while (dst.get(dst_index) != '\0'.codeUnitAt(0)) {
            dst_index++;
        }
        int src_index = 0;
        while (src.get(src_index) != '\0'.codeUnitAt(0)) {
            dst.set(dst_index++, src.get(src_index++));
        }
        dst.set(dst_index++, '\0'.codeUnitAt(0));
        return dst;
    }

    static CharPtr strncat(CharPtr dst, CharPtr src, int count)
    {
        int dst_index = 0;
        while (dst.get(dst_index) != '\0'.codeUnitAt(0)) {
            dst_index++;
        }
        int src_index = 0;
        while ((src.get(src_index) != '\0'.codeUnitAt(0)) && (count-- > 0)) {
            dst.set(dst_index++, src.get(src_index++));
        }
        return dst;
    }

    static int strcspn(CharPtr str, CharPtr charset)
    {
        int index = ClassType.IndexOfAny(str.toString(), charset.toString().toCharArray());
        if (index < 0) {
            index = str.toString().length;
        }
        return index;
    }

    static CharPtr strncpy(CharPtr dst, CharPtr src, int length)
    {
        int index = 0;
        while ((src.get(index) != '\0'.codeUnitAt(0)) && (index < length)) {
            dst.set(index, src.get(index));
            index++;
        }
        while (index < length) {
            dst.set(index++, '\0'.codeUnitAt(0));
        }
        return dst;
    }

    static int strlen(CharPtr str)
    {
        int index = 0;
        while (str.get(index) != '\0'.codeUnitAt(0)) {
            index++;
        }
        return index;
    }

    static double fmod(double a, double b)
    {
        double quotient = Math.floor(a ~/ b);
        return a - (quotient * b);
    }

    static double modf(double a, List<double> b)
    {
        b[0] = Math.floor(a);
        return a - Math.floor(a);
    }

    static int lmod(double a, double b)
    {
        return a % b;
    }

    static int getc(StreamProxy f)
    {
        return f.ReadByte();
    }

    static void ungetc(int c, StreamProxy f)
    {
        f.ungetc(c);
    }
    static StreamProxy stdout = StreamProxy_.OpenStandardOutput();
    static StreamProxy stdin = StreamProxy_.OpenStandardInput();
    static StreamProxy stderr = StreamProxy_.OpenStandardError();
    static int EOF = (-1);

    static void fputs(CharPtr str, StreamProxy stream)
    {
        StreamProxy_.Write(str.toString());
    }

    static int feof(StreamProxy s)
    {
        return s.isEof() ? 1 : 0;
    }

    static int fread(CharPtr ptr, int size, int num, StreamProxy stream)
    {
        int num_bytes = (num * size);
        List<int> bytes = new List<int>(num_bytes);
        try {
            int result = stream.Read(bytes, 0, num_bytes);
            for (int i = 0; i < result; i++) {
                ptr.set(i, bytes[i]);
            }
            return result ~/ size;
        } on java.lang.Exception catch (e) {
            return 0;
        }
    }

    static int fwrite(CharPtr ptr, int size, int num, StreamProxy stream)
    {
        int num_bytes = (num * size);
        List<int> bytes = new List<int>(num_bytes);
        for (int i = 0; i < num_bytes; i++) {
            bytes[i] = ptr.get(i);
        }
        try {
            stream.Write(bytes, 0, num_bytes);
        } on java.lang.Exception catch (e) {
            return 0;
        }
        return num;
    }

    static int strcmp(CharPtr s1, CharPtr s2)
    {
        if (CharPtr_.isEqual(s1, s2)) {
            return 0;
        }
        if (CharPtr_.isEqual(s1, null)) {
            return -1;
        }
        if (CharPtr_.isEqual(s2, null)) {
            return 1;
        }
        for (int i = 0; ; i++) {
            if (s1.get(i) != s2.get(i)) {
                if (s1.get(i) < s2.get(i)) {
                    return -1;
                } else {
                    return 1;
                }
            }
            if (s1.get(i) == '\0'.codeUnitAt(0)) {
                return 0;
            }
        }
    }

    static CharPtr fgets(CharPtr str, StreamProxy stream)
    {
        int index = 0;
        try {
            while (true) {
                str.set(index, stream.ReadByte());
                if (str.get(index) == '\n'.codeUnitAt(0)) {
                    break;
                }
                if (index >= str.chars.length) {
                    break;
                }
                index++;
            }
        } on java.lang.Exception catch (e) {
        }
        return str;
    }

    static double frexp(double x, List<int> expptr)
    {
        expptr[0] = (ClassType.log2(x) + 1);
        double s = (x ~/ Math.pow(2, expptr[0]));
        return s;
    }

    static double ldexp(double x, int expptr)
    {
        return x * Math.pow(2, expptr);
    }

    static CharPtr strstr(CharPtr str, CharPtr substr)
    {
        int index = str.toString().indexOf(substr.toString());
        if (index < 0) {
            return null;
        }
        return new CharPtr(CharPtr_.plus(str, index));
    }

    static CharPtr strrchr(CharPtr str, int ch)
    {
        int index = str.toString().lastIndexOf(ch);
        if (index < 0) {
            return null;
        }
        return CharPtr_.plus(str, index);
    }

    static StreamProxy fopen(CharPtr filename, CharPtr mode)
    {
        String str = filename.toString();
        String modeStr = "";
        for (int i = 0; mode.get(i) != '\0'.codeUnitAt(0); i++) {
            modeStr += mode.get(i);
        }
        try {
            StreamProxy result = new StreamProxy(str, modeStr);
            if (result.isOK) {
                return result;
            } else {
                return null;
            }
        } on java.lang.Exception catch (e) {
            return null;
        }
    }

    static StreamProxy freopen(CharPtr filename, CharPtr mode, StreamProxy stream)
    {
        try {
            stream.Flush();
            stream.Close();
        } on java.lang.Exception catch (e) {
        }
        return fopen(filename, mode);
    }

    static void fflush(StreamProxy stream)
    {
        stream.Flush();
    }

    static int ferror(StreamProxy stream)
    {
        return 0;
    }

    static int fclose(StreamProxy stream)
    {
        stream.Close();
        return 0;
    }

    static StreamProxy tmpfile()
    {
        return StreamProxy_.tmpfile();
    }

    static int fscanf(StreamProxy f, CharPtr format, List<Object> argp /*XXX*/)
    {
        String str = StreamProxy_.ReadLine();
        return parse_scanf(str, format, argp);
    }

    static int fseek(StreamProxy f, int offset, int origin)
    {
        return f.Seek(offset, origin);
    }

    static int ftell(StreamProxy f)
    {
        return f.getPosition();
    }

    static int clearerr(StreamProxy f)
    {
        return 0;
    }

    static int setvbuf(StreamProxy stream, CharPtr buffer, int mode, int size)
    {
        ClassType.Assert(false, "setvbuf not implemented yet - mjf");
        return 0;
    }

    static void memcpy_char(List<int> dst, int offset, List<int> src, int length)
    {
        for (int i = 0; i < length; i++) {
            dst[offset + i] = src[i];
        }
    }

    static void memcpy_char(List<int> dst, List<int> src, int srcofs, int length)
    {
        for (int i = 0; i < length; i++) {
            dst[i] = src[srcofs + i];
        }
    }

    static void memcpy(CharPtr ptr1, CharPtr ptr2, int size)
    {
        for (int i = 0; i < size; i++) {
            ptr1.set(i, ptr2.get(i));
        }
    }

    static Object VOID(Object f)
    {
        return f;
    }
    static final double HUGE_VAL = Double.MAX_VALUE;
    static const int SHRT_MAX = Short.MAX_VALUE;
    static const int _IONBF = 0;
    static const int _IOFBF = 1;
    static const int _IOLBF = 2;
    static const int SEEK_SET = 0;
    static const int SEEK_CUR = 1;
    static const int SEEK_END = 2;

    static int GetUnmanagedSize(ClassType t)
    {
        return t.GetUnmanagedSize();
    }
}


class CharPtr
{
    List<int> chars;
    int index;

    int get(int offset)
    {
        return chars[index + offset];
    }

    void set(int offset, int val)
    {
        chars[index + offset] = val;
    }

    int get(int offset)
    {
        return chars[index + offset];
    }

    void set(int offset, int val)
    {
        chars[index + offset] = val;
    }

    static CharPtr toCharPtr(String str)
    {
        return new CharPtr(str);
    }

    static CharPtr toCharPtr(List<int> chars)
    {
        return new CharPtr(chars);
    }

    CharPtr_()
    {
        this.chars = null;
        this.index = 0;
    }

    CharPtr_(String str)
    {
        this.chars = (str + '\0'.codeUnitAt(0)).toCharArray();
        this.index = 0;
    }

    CharPtr_(CharPtr ptr)
    {
        this.chars = ptr.chars;
        this.index = ptr.index;
    }

    CharPtr_(CharPtr ptr, int index)
    {
        this.chars = ptr.chars;
        this.index = index;
    }

    CharPtr_(List<int> chars)
    {
        this.chars = chars;
        this.index = 0;
    }

    CharPtr_(List<int> chars, int index)
    {
        this.chars = chars;
        this.index = index;
    }

    static CharPtr plus(CharPtr ptr, int offset)
    {
        return new CharPtr(ptr.chars, ptr.index + offset);
    }

    static CharPtr minus(CharPtr ptr, int offset)
    {
        return new CharPtr(ptr.chars, ptr.index - offset);
    }

    void inc()
    {
        this.index++;
    }

    void dec()
    {
        this.index--;
    }

    CharPtr next()
    {
        return new CharPtr(this.chars, this.index + 1);
    }

    CharPtr prev()
    {
        return new CharPtr(this.chars, this.index - 1);
    }

    CharPtr add(int ofs)
    {
        return new CharPtr(this.chars, this.index + ofs);
    }

    CharPtr sub(int ofs)
    {
        return new CharPtr(this.chars, this.index - ofs);
    }

    static bool isEqualChar(CharPtr ptr, int ch)
    {
        return ptr.get(0) == ch;
    }

    static bool isEqualChar(int ch, CharPtr ptr)
    {
        return ptr.get(0) == ch;
    }

    static bool isNotEqualChar(CharPtr ptr, int ch)
    {
        return ptr.get(0) != ch;
    }

    static bool isNotEqualChar(int ch, CharPtr ptr)
    {
        return ptr.get(0) != ch;
    }

    static CharPtr plus(CharPtr ptr1, CharPtr ptr2)
    {
        String result = "";
        for (int i = 0; ptr1.get(i) != '\0'.codeUnitAt(0); i++) {
            result += ptr1.get(i);
        }
        for (int i = 0; ptr2.get(i) != '\0'.codeUnitAt(0); i++) {
            result += ptr2.get(i);
        }
        return new CharPtr(result);
    }

    static int minus(CharPtr ptr1, CharPtr ptr2)
    {
        ClassType.Assert(ptr1.chars == ptr2.chars);
        return ptr1.index - ptr2.index;
    }

    static bool lessThan(CharPtr ptr1, CharPtr ptr2)
    {
        ClassType.Assert(ptr1.chars == ptr2.chars);
        return ptr1.index < ptr2.index;
    }

    static bool lessEqual(CharPtr ptr1, CharPtr ptr2)
    {
        ClassType.Assert(ptr1.chars == ptr2.chars);
        return ptr1.index <= ptr2.index;
    }

    static bool greaterThan(CharPtr ptr1, CharPtr ptr2)
    {
        ClassType.Assert(ptr1.chars == ptr2.chars);
        return ptr1.index > ptr2.index;
    }

    static bool greaterEqual(CharPtr ptr1, CharPtr ptr2)
    {
        ClassType.Assert(ptr1.chars == ptr2.chars);
        return ptr1.index >= ptr2.index;
    }

    static bool isEqual(CharPtr ptr1, CharPtr ptr2)
    {
        Object o1 = (CharPtr)((ptr1 instanceof CharPtr) ? ptr1 : null);
			  Object o2 = (CharPtr)((ptr2 instanceof CharPtr) ? ptr2 : null);
        if ((o1 == null) && (o2 == null)) {
            return true;
        }
        if (o1 == null) {
            return false;
        }
        if (o2 == null) {
            return false;
        }
        return (ptr1.chars == ptr2.chars) && (ptr1.index == ptr2.index);
    }

    static bool isNotEqual(CharPtr ptr1, CharPtr ptr2)
    {
        return !CharPtr_.isEqual(ptr1, ptr2);
    }

    public boolean equals(Object o) 
		{
			return CharPtr.isEqual(this, ((CharPtr)((o instanceof CharPtr) ? o : null)));
		}
		
		public int hashCode() 
		{
			return 0;
		}
		
		public String toString() 
		{
			String result = "";
			for (int i = index; (i < chars.length) && (chars[i] != '\0'); i++) 
			{
				result += chars[i];
			}
			return result;
		}
}
