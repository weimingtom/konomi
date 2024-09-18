library kurumi;

import 'java.dart';

class StreamProxy
{
    static const int TYPE_FILE = 0;
    static const int TYPE_STDOUT = 1;
    static const int TYPE_STDIN = 2;
    static const int TYPE_STDERR = 3;
    int type = TYPE_FILE;
    bool isOK = false;
    RandomAccessFile _file = null;

    StreamProxy()
    {
        this.isOK = false;
    }

    StreamProxy(String path, String modeStr)
    {
        this.isOK = false;
        try {
            this._file = new RandomAccessFile(path, modeStr);
            this.isOK = true;
        } on FileNotFoundException catch (e) {
            e.printStackTrace();
        }
        this.type = TYPE_FILE;
    }

    final void Flush()
    {
        if (this.type == TYPE_STDOUT) {
        }
    }

    final void Close()
    {
        if (this.type == TYPE_STDOUT) {
            if (this._file != null) {
                try {
                    this._file.close();
                } on IOException catch (e) {
                    e.printStackTrace();
                }
                this._file = null;
            }
        }
    }

    final void Write(List<int> buffer, int offset, int count)
    {
        if (this.type == TYPE_STDOUT) {
            System.out.print(new String(buffer, offset, count));
        } else {
            if (this.type == TYPE_STDERR) {
                System.err.print(new String(buffer, offset, count));
            } else {
                if (this.type == TYPE_FILE) {
                    if (this._file != null) {
                        try {
                            this._file.writeBytes(new String(buffer, offset, count));
                        } on IOException catch (e) {
                            e.printStackTrace();
                        }
                    }
                } else {
                }
            }
        }
    }

    final int Read(List<int> buffer, int offset, int count)
    {
        if (type == TYPE_FILE) {
            if (this._file != null) {
                try {
                    return this._file.read(buffer, offset, count);
                } on IOException catch (e) {
                    e.printStackTrace();
                }
            }
        }
        return 0;
    }

    final int Seek(int offset, int origin)
    {
        if (type == TYPE_FILE) {
            if (this._file != null) {
                int pos = (-1);
                if (origin == CLib.SEEK_CUR) {
                    pos = offset;
                } else {
                    if (origin == CLib.SEEK_CUR) {
                        try {
                            pos = (this._file.getFilePointer() + offset);
                        } on IOException catch (e) {
                            e.printStackTrace();
                        }
                    } else {
                        if (origin == CLib.SEEK_END) {
                            try {
                                pos = (this._file.length + offset);
                            } on IOException catch (e) {
                                e.printStackTrace();
                            }
                        }
                    }
                }
                try {
                    this._file.seek(pos);
                } on IOException catch (e) {
                    e.printStackTrace();
                }
            }
        }
        return 0;
    }

    final int ReadByte()
    {
        if (type == TYPE_STDIN) {
            try {
                return System.in_.read();
            } on IOException catch (e) {
                e.printStackTrace();
            }
            return 0;
        } else {
            if (type == TYPE_FILE) {
                if (this._file != null) {
                    try {
                        return this._file.read();
                    } on IOException catch (e) {
                        e.printStackTrace();
                    }
                }
                return 0;
            } else {
                return 0;
            }
        }
    }

    final void ungetc(int c)
    {
        if (type == TYPE_FILE) {
            if (this._file != null) {
                try {
                    this._file.seek(this._file.getFilePointer() - 1);
                } on IOException catch (e) {
                    e.printStackTrace();
                }
            }
        }
    }

    final int getPosition()
    {
        if (type == TYPE_FILE) {
            if (this._file != null) {
                try {
                    return this._file.getFilePointer();
                } on IOException catch (e) {
                    e.printStackTrace();
                }
            }
        }
        return 0;
    }

    final bool isEof()
    {
        if (type == TYPE_FILE) {
            if (this._file != null) {
                try {
                    return this._file.getFilePointer() >= this._file.length;
                } on IOException catch (e) {
                    e.printStackTrace();
                }
            }
        }
        return true;
    }

    static StreamProxy tmpfile()
    {
        StreamProxy result = new StreamProxy();
        return result;
    }

    static StreamProxy OpenStandardOutput()
    {
        StreamProxy result = new StreamProxy();
        result.type = TYPE_STDOUT;
        result.isOK = true;
        return result;
    }

    static StreamProxy OpenStandardInput()
    {
        StreamProxy result = new StreamProxy();
        result.type = TYPE_STDIN;
        result.isOK = true;
        return result;
    }

    static StreamProxy OpenStandardError()
    {
        StreamProxy result = new StreamProxy();
        result.type = TYPE_STDERR;
        result.isOK = true;
        return result;
    }

    static String GetCurrentDirectory()
    {
        File directory = new File("");
        return directory.getAbsolutePath();
    }

    static void Delete(String path)
    {
        new File(path).delete();
    }

    static void Move(String path1, String path2)
    {
        new File(path1).renameTo(new File(path2));
    }

    static String GetTempFileName()
    {
        try {
            return File_.createTempFile("abc", ".tmp").getAbsolutePath();
        } on IOException catch (e) {
            e.printStackTrace();
        }
        return null;
    }

    static String ReadLine()
    {
        BufferedReader in_ = new BufferedReader(new InputStreamReader(System.in_));
        try {
            return in_.readLine();
        } on IOException catch (e) {
            e.printStackTrace();
        }
        return null;
    }

    static void Write(String str)
    {
        System.out.print(str);
    }

    static void WriteLine()
    {
        System.out.println();
    }

    static void ErrorWrite(String str)
    {
        System.err.print(str);
        System.err.flush();
    }
}
