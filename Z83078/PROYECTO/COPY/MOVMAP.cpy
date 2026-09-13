       01 MOVMAPI.
          02 FILLER         PIC X(12).
          02 NROCUENTAL COMP
                            PIC S9(4).
          02 NROCUENTAF     PICTURE X.
          02 FILLER REDEFINES NROCUENTAF.
             03 NROCUENTAA  PICTURE X.
          02 NROCUENTAI     PIC X(10).
          02 FILLER         PIC X(9).
          02 MOVIM1L COMP   PIC S9(4).
          02 MOVIM1F        PICTURE X.
          02 FILLER REDEFINES MOVIM1F.
             03 MOVIM1A     PICTURE X.
          02 MOVIM1I        PIC X(60).
          02 MOVIM2L COMP   PIC S9(4).
          02 MOVIM2F        PICTURE X.
          02 FILLER REDEFINES MOVIM2F.
             03 MOVIM2A     PICTURE X.
          02 MOVIM2I        PIC X(60).
          02 MOVIM3L COMP   PIC S9(4).
          02 MOVIM3F        PICTURE X.
          02 FILLER REDEFINES MOVIM3F.
             03 MOVIM3A     PICTURE X.
          02 MOVIM3I        PIC X(60).
          02 MOVIM4L COMP   PIC S9(4).
          02 MOVIM4F        PICTURE X.
          02 FILLER REDEFINES MOVIM4F.
             03 MOVIM4A     PICTURE X.
          02 MOVIM4I        PIC X(60).
          02 MENSAJEL COMP  PIC S9(4).
          02 MENSAJEF       PICTURE X.
          02 FILLER REDEFINES MENSAJEF.
             03 MENSAJEA    PICTURE X.
          02 MENSAJEI       PIC X(60).
       01 MOVMAPO REDEFINES MOVMAPI.
          02 FILLER         PIC X(12).
          02 FILLER         PIC X(3).
          02 NROCUENTAO     PIC X(10).
          02 FILLER         PIC X(9).
          02 MOVIM1O        PIC X(60).
          02 FILLER         PIC X(3).
          02 MOVIM2O        PIC X(60).
          02 FILLER         PIC X(3).
          02 MOVIM3O        PIC X(60).
          02 FILLER         PIC X(3).
          02 MOVIM4O        PIC X(60).
          02 FILLER         PIC X(3).
          02 MENSAJEO       PIC X(60).