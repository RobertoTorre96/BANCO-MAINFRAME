       01  SELMAPI.
           02  FILLER PIC X(12).
           02  CUENTA1L    COMP  PIC  S9(4).
           02  CUENTA1F    PICTURE X.
           02  FILLER REDEFINES CUENTA1F.
             03 CUENTA1A    PICTURE X.
           02  CUENTA1I  PIC X(10).
           02  CUENTA2L    COMP  PIC  S9(4).
           02  CUENTA2F    PICTURE X.
           02  FILLER REDEFINES CUENTA2F.
             03 CUENTA2A    PICTURE X.
           02  CUENTA2I  PIC X(10).
           02  CUENTA3L    COMP  PIC  S9(4).
           02  CUENTA3F    PICTURE X.
           02  FILLER REDEFINES CUENTA3F.
             03 CUENTA3A    PICTURE X.
           02  CUENTA3I  PIC X(10).
           02  CUENTA4L    COMP  PIC  S9(4).
           02  CUENTA4F    PICTURE X.
           02  FILLER REDEFINES CUENTA4F.
             03 CUENTA4A    PICTURE X.
           02  CUENTA4I  PIC X(10).
           02  OPCIONL    COMP  PIC  S9(4).
           02  OPCIONF    PICTURE X.
           02  FILLER REDEFINES OPCIONF.
             03 OPCIONA    PICTURE X.
           02  OPCIONI  PIC X(1).
           02  MENSAJEL    COMP  PIC  S9(4).
           02  MENSAJEF    PICTURE X.
           02  FILLER REDEFINES MENSAJEF.
             03 MENSAJEA    PICTURE X.
           02  MENSAJEI  PIC X(60).
       01  SELMAPO REDEFINES SELMAPI.
           02  FILLER PIC X(12).
           02  FILLER PICTURE X(3).
           02  CUENTA1O PIC X(10).
           02  FILLER PICTURE X(3).
           02  CUENTA2O PIC X(10).
           02  FILLER PICTURE X(3).
           02  CUENTA3O PIC X(10).
           02  FILLER PICTURE X(3).
           02  CUENTA4O PIC X(10).
           02  FILLER PICTURE X(3).
           02  OPCIONO  PIC X(1).
           02  FILLER PICTURE X(3).
           02  MENSAJEO  PIC X(60).
