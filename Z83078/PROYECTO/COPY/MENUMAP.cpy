       01 MENUMAPI.
          02 FILLER       PIC X(12).
          02 OPCIONL COMP PIC  S9(4).
          02 OPCIONF      PICTURE X.
          02 FILLER REDEFINES OPCIONF.
             03 OPCIONA   PICTURE X.
          02 OPCIONI      PIC X(1).
          02 MENSAJEL COMP
                          PIC  S9(4).
          02 MENSAJEF     PICTURE X.
          02 FILLER REDEFINES MENSAJEF.
             03 MENSAJEA  PICTURE X.
          02 MENSAJEI     PIC X(40).
       01 MENUMAPO REDEFINES MENUMAPI.
          02 FILLER       PIC X(12).
          02 FILLER       PICTURE X(3).
          02 OPCIONO      PIC X(1).
          02 FILLER       PICTURE X(3).
          02 MENSAJEO     PIC X(40).