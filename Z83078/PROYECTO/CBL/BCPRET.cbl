       IDENTIFICATION DIVISION.
       PROGRAM-ID. BCPRET.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-RESP        PIC S9(8) COMP.
       01 WS-NRO-CUENTA  PIC S9(9) COMP.
       01 WS-MONTO       PIC S9(7)V99 COMP-3.
       01 WS-MONTO-OUT   PIC X(15).
       01 WS-CUENTA-OUT  PIC X(10).
       01 WS-TIPO-MOV    PIC X(8)     VALUE 'RETIRO'.

           EXEC SQL INCLUDE SQLCA END-EXEC.

             COPY RETMAP.
             COPY DFHAID.

          LINKAGE SECTION.
       01 DFHCOMMAREA.
                COPY SESSION.

       PROCEDURE DIVISION.

           IF SESSION-STATE NOT = 'R' AND
              SESSION-STATE NOT = 'M'
              EXEC CICS RETURN
                   TRANSID('BLOG')
                   END-EXEC
           ELSE
              IF EIBCALEN = 0 OR SESSION-STATE = 'R'
                 MOVE LOW-VALUES TO RETMAPO
                 MOVE SESSION-CUENTA TO NROCUENTAO
                 MOVE 'Ingrese cuenta y monto' TO MENSAJEO
                 MOVE 'M' TO SESSION-STATE
                 EXEC CICS SEND MAP('RETMAP')
                      MAPSET('RETSET')
                      ERASE
                      RESP(WS-RESP)
                      END-EXEC
              ELSE
                 EXEC CICS RECEIVE MAP('RETMAP')
                      MAPSET('RETSET')
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
                          PERFORM 100-REALIZAR-RETIRO
                          EVALUATE SQLCODE
                          WHEN 0
                               MOVE LOW-VALUES TO RETMAPO
                               MOVE 'Retiro realizado' TO MENSAJEO
                          WHEN 100
                               MOVE LOW-VALUES TO RETMAPO
                               MOVE WS-CUENTA-OUT TO NROCUENTAO
                               MOVE SPACES TO MONTOO
                               MOVE
                              'Cuenta inexistente o saldo insuficiente'
                                  TO MENSAJEO
                          WHEN OTHER
                               MOVE LOW-VALUES TO RETMAPO
                               MOVE WS-CUENTA-OUT TO NROCUENTAO
                               MOVE SPACES TO MONTOO
                               MOVE 'Error de actualizacion DB2' TO
                                  MENSAJEO
                          END-EVALUATE
                       ELSE
                          MOVE LOW-VALUES TO RETMAPO
                          MOVE WS-CUENTA-OUT TO NROCUENTAO
                          MOVE SPACES TO MONTOO
                          MOVE 'Monto invalido' TO MENSAJEO
                       END-IF
                    ELSE
                       MOVE LOW-VALUES TO RETMAPO
                       MOVE WS-CUENTA-OUT TO NROCUENTAO
                       MOVE SPACES TO MONTOO
                       MOVE 'Datos invalidos' TO MENSAJEO
                    END-IF

                    EXEC CICS SEND MAP('RETMAP')
                         MAPSET('RETSET')
                         ERASE
                         RESP(WS-RESP)
                         END-EXEC
                 END-IF
              END-IF
           END-IF.

           EXEC CICS RETURN
                TRANSID('BRET')
                COMMAREA(DFHCOMMAREA)
                LENGTH(56)
                END-EXEC.

       100-REALIZAR-RETIRO.
            COPY BCPRET.
           EXIT.