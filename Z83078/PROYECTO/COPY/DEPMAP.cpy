       01 DEPMAPI.
          02 FILLER         PIC X(12).
          02 NROCUENTAL COMP
                            PIC S9(4).
          02 NROCUENTAF     PICTURE X.
          02 FILLER REDEFINES NROCUENTAF.
             03 NROCUENTAA  PICTURE X.
          02 NROCUENTAI     PIC X(10).
          02 MONTOL COMP    PIC S9(4).
          02 MONTOF         PICTURE X.
          02 FILLER REDEFINES MONTOF.
             03 MONTOA      PICTURE X.
          02 MONTOI         PIC X(15).
          02 MENSAJEL COMP  PIC S9(4).
          02 MENSAJEF       PICTURE X.
          02 FILLER REDEFINES MENSAJEF.
             03 MENSAJEA    PICTURE X.
          02 MENSAJEI       PIC X(60).
       01 DEPMAPO REDEFINES DEPMAPI.
          02 FILLER         PIC X(12).
          02 FILLER         PICTURE X(3).
          02 NROCUENTAO     PIC X(10).
          02 FILLER         PICTURE X(3).
          02 MONTOO         PIC X(15).
          02 FILLER         PICTURE X(3).
          02 MENSAJEO       PIC X(60).