       IDENTIFICATION DIVISION.
       PROGRAM-ID. BCPMOV.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-RESP        PIC S9(8) COMP.
       01 WS-NRO-CUENTA  PIC S9(9) COMP.
       01 WS-TIPO-MOV    PIC X(8).
       01 WS-MONTO       PIC S9(7)V99 COMP-3.
       01 WS-MONTO-EDIT  PIC Z(7)9.99.
       01 WS-FECHA-HORA  PIC X(26).
       01 WS-MOV-OUT     PIC X(60).
       01 WS-HAY-MOV     PIC X        VALUE 'N'.

           EXEC SQL INCLUDE SQLCA END-EXEC.
             COPY MOVMAP.
             COPY DFHAID.

          LINKAGE SECTION.
       01 DFHCOMMAREA.
                COPY SESSION.

       PROCEDURE DIVISION.

           IF SESSION-STATE NOT = 'V' AND
              SESSION-STATE NOT = 'M'
              EXEC CICS RETURN
                   TRANSID('BLOG')
                   END-EXEC
           ELSE
              IF EIBCALEN = 0 OR SESSION-STATE = 'V'
                 MOVE LOW-VALUES TO MOVMAPO
                 MOVE 'Ingrese el numero de cuenta' TO MENSAJEO
                 MOVE 'M' TO SESSION-STATE
                 EXEC CICS SEND MAP('MOVMAP')
                      MAPSET('MOVSET')
                      ERASE
                      RESP(WS-RESP)
                      END-EXEC
              ELSE
                 EXEC CICS RECEIVE MAP('MOVMAP')
                      MAPSET('MOVSET')
                      RESP(WS-RESP)
                      END-EXEC

                 IF EIBAID = DFHPF3
                    EXEC CICS SEND CONTROL ERASE
                         END-EXEC
                    EXEC CICS RETURN TRANSID('BMEN')
                         END-EXEC
                 ELSE
                    IF NROCUENTAI NOT = LOW-VALUES AND
                       NROCUENTAI NOT = SPACES AND
                       FUNCTION TEST-NUMVAL(NROCUENTAI) = 0
                       COMPUTE WS-NRO-CUENTA = FUNCTION NUMVAL
                          (NROCUENTAI)
                       PERFORM 100-CARGAR-MOVIMIENTOS
                       IF SQLCODE = 100
                          MOVE 'Cuenta no encontrada' TO MENSAJEO
                       ELSE
                          MOVE 'Movimientos encontrados' TO MENSAJEO
                       END-IF
                    ELSE
                       MOVE SPACES TO MOVIM1O MOVIM2O MOVIM3O MOVIM4O
                       MOVE 'Datos invalidos' TO MENSAJEO
                    END-IF

                    EXEC CICS SEND MAP('MOVMAP')
                         MAPSET('MOVSET')
                         DATAONLY
                         RESP(WS-RESP)
                         END-EXEC
                 END-IF
              END-IF
           END-IF.

           EXEC CICS RETURN
                TRANSID('BMOV')
                COMMAREA(DFHCOMMAREA)
                LENGTH(56)
                END-EXEC.

       100-CARGAR-MOVIMIENTOS.
           MOVE SPACES TO MOVIM1O MOVIM2O MOVIM3O MOVIM4O.
           COPY BCPMOV.

       110-LEER-MOVIMIENTO.
           MOVE SPACES TO WS-MOV-OUT.
             EXEC SQL
                FETCH C-MOVIMIENTOS
                 INTO :WS-TIPO-MOV, :WS-MONTO, :WS-FECHA-HORA
             END-EXEC.
           IF SQLCODE = 0
              MOVE 'S' TO WS-HAY-MOV
              MOVE WS-MONTO TO WS-MONTO-EDIT
              STRING WS-TIPO-MOV DELIMITED BY SPACE
                     ' ' DELIMITED BY SIZE
                     WS-MONTO-EDIT DELIMITED BY SIZE
                     ' ' DELIMITED BY SIZE
                     WS-FECHA-HORA DELIMITED BY SPACE
                 INTO WS-MOV-OUT
              END-STRING
           END-IF
           EXIT.