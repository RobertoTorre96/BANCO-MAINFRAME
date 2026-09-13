       01 LOGMAPI.
          02 FILLER        PIC X(12).
          02 EMAILL COMP   PIC  S9(4).
          02 EMAILF        PICTURE X.
          02 FILLER REDEFINES EMAILF.
             03 EMAILA     PICTURE X.
          02 EMAILI        PIC X(40).
          02 PASSWORDL COMP
                           PIC  S9(4).
          02 PASSWORDF     PICTURE X.
          02 FILLER REDEFINES PASSWORDF.
             03 PASSWORDA  PICTURE X.
          02 PASSWORDI     PIC X(20).
          02 MENSAJEL COMP PIC  S9(4).
          02 MENSAJEF      PICTURE X.
          02 FILLER REDEFINES MENSAJEF.
             03 MENSAJEA   PICTURE X.
          02 MENSAJEI      PIC X(60).
       01 LOGMAPO REDEFINES LOGMAPI.
          02 FILLER        PIC X(12).
          02 FILLER        PICTURE X(3).
          02 EMAILO        PIC X(40).
          02 FILLER        PICTURE X(3).
          02 PASSWORDO     PIC X(20).
          02 FILLER        PICTURE X(3).
          02 MENSAJEO      PIC X(60).