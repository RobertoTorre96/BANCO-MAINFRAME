       IDENTIFICATION DIVISION.
       PROGRAM-ID. BCPDEP.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-RESP         PIC S9(8) COMP.
       01 WS-NRO-CUENTA   PIC S9(9) COMP.
       01 WS-MONTO        PIC S9(7)V99 COMP-3.
       01 WS-MONTO-OUT    PIC X(15).
       01 WS-CUENTA-OUT   PIC X(10).
       01 WS-TIPO-MOV     PIC X(8)     VALUE 'DEPOSITO'.
       01 WS-SQLCODE-OUT  PIC -9(9).

           EXEC SQL INCLUDE SQLCA END-EXEC.

             COPY DEPMAP.
             COPY DFHAID.

          LINKAGE SECTION.
       01 DFHCOMMAREA.
                COPY SESSION.

       PROCEDURE DIVISION.

           IF SESSION-STATE NOT = 'D' AND
              SESSION-STATE NOT = 'M'
              EXEC CICS RETURN
                   TRANSID('BLOG')
                   END-EXEC
           ELSE
              IF EIBCALEN = 0 OR SESSION-STATE = 'D'
                 MOVE LOW-VALUES TO DEPMAPO
                 MOVE SESSION-CUENTA TO NROCUENTAO
                 MOVE 'Ingrese cuenta y monto' TO MENSAJEO
                 MOVE 'M' TO SESSION-STATE
                 EXEC CICS SEND MAP('DEPMAP')
                      MAPSET('DEPSET')
                      ERASE
                      RESP(WS-RESP)
                      END-EXEC
              ELSE
                 EXEC CICS RECEIVE MAP('DEPMAP')
                      MAPSET('DEPSET')
                      RESP(WS-RESP)
                      END-EXEC

                 IF EIBAID = DFHPF3
                    EXEC CICS SEND CONTROL
                         ERASE
                         END-EXEC
                    EXEC CICS RETURN
                         TRANSID('BMEN')
                         END-EXEC
                 ELSE
                    MOVE SESSION-CUENTA TO WS-CUENTA-OUT
                    IF SESSION-CUENTA NOT = SPACES AND
                       FUNCTION TEST-NUMVAL(MONTOI) = 0
                       COMPUTE WS-NRO-CUENTA = FUNCTION NUMVAL
                          (SESSION-CUENTA)
                       COMPUTE WS-MONTO = FUNCTION NUMVAL(MONTOI)
                       IF WS-MONTO > 0
                          PERFORM 100-REALIZAR-DEPOSITO
                          EVALUATE SQLCODE
                          WHEN 0
                               MOVE MONTOI TO WS-MONTO-OUT
                               MOVE WS-MONTO-OUT TO MONTOO
                               MOVE 'Deposito realizado' TO MENSAJEO
                          WHEN 100
                               MOVE LOW-VALUES TO DEPMAPO
                               MOVE WS-CUENTA-OUT TO NROCUENTAO
                               MOVE SPACES TO MONTOO
                               MOVE 'Cuenta no encontrada' TO MENSAJEO
                          WHEN OTHER
                               MOVE LOW-VALUES TO DEPMAPO
                               MOVE WS-CUENTA-OUT TO NROCUENTAO
                               MOVE SPACES TO MONTOO
                               MOVE SQLCODE TO WS-SQLCODE-OUT
                               MOVE SPACES TO MENSAJEO
                               STRING 'SQLCODE=' DELIMITED BY SIZE
                                      WS-SQLCODE-OUT DELIMITED BY SIZE
                                  INTO MENSAJEO
                               END-STRING
                          END-EVALUATE
                       ELSE
                          MOVE LOW-VALUES TO DEPMAPO
                          MOVE WS-CUENTA-OUT TO NROCUENTAO
                          MOVE SPACES TO MONTOO
                          MOVE 'Monto invalido' TO MENSAJEO
                       END-IF
                    ELSE
                       MOVE LOW-VALUES TO DEPMAPO
                       MOVE WS-CUENTA-OUT TO NROCUENTAO
                       MOVE SPACES TO MONTOO
                       MOVE 'Datos invalidos' TO MENSAJEO
                    END-IF

                    EXEC CICS SEND MAP('DEPMAP')
                         MAPSET('DEPSET')
                         ERASE
                         RESP(WS-RESP)
                         END-EXEC
                 END-IF
              END-IF
           END-IF.

           EXEC CICS RETURN
                TRANSID('BDEP')
                COMMAREA(DFHCOMMAREA)
                LENGTH(56)
                END-EXEC.

       100-REALIZAR-DEPOSITO.
            COPY BCPDEP.
           EXIT.