       01  CONMAPI.
           02  FILLER PIC X(12).
           02  NROCUENTAL    COMP  PIC  S9(4).
           02  NROCUENTAF    PICTURE X.
           02  FILLER REDEFINES NROCUENTAF.
             03 NROCUENTAA    PICTURE X.
           02  NROCUENTAI  PIC X(10).
           02  NOMBREL    COMP  PIC  S9(4).
           02  NOMBREF    PICTURE X.
           02  FILLER REDEFINES NOMBREF.
             03 NOMBREA    PICTURE X.
           02  NOMBREI  PIC X(30).
           02  APELLIDOL    COMP  PIC  S9(4).
           02  APELLIDOF    PICTURE X.
           02  FILLER REDEFINES APELLIDOF.
             03 APELLIDOA    PICTURE X.
           02  APELLIDOI  PIC X(30).
           02  SALDOL    COMP  PIC  S9(4).
           02  SALDOF    PICTURE X.
           02  FILLER REDEFINES SALDOF.
             03 SALDOA    PICTURE X.
           02  SALDOI  PIC X(15).
           02  MENSAJEL    COMP  PIC  S9(4).
           02  MENSAJEF    PICTURE X.
           02  FILLER REDEFINES MENSAJEF.
             03 MENSAJEA    PICTURE X.
           02  MENSAJEI  PIC X(60).
       01  CONMAPO REDEFINES CONMAPI.
           02  FILLER PIC X(12).
           02  FILLER PICTURE X(3).
           02  NROCUENTAO PIC X(10).
           02  FILLER PICTURE X(3).
           02  NOMBREO PIC X(30).
           02  FILLER PICTURE X(3).
           02  APELLIDOO PIC X(30).
           02  FILLER PICTURE X(3).
           02  SALDOO PIC X(15).
           02  FILLER PICTURE X(3).
           02  MENSAJEO  PIC X(60).
