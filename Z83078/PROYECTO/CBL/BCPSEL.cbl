       IDENTIFICATION DIVISION.
       PROGRAM-ID. BCPSEL.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-RESP           PIC S9(8) COMP.
       01 WS-CUENTA-1       PIC S9(9) COMP.
       01 WS-CUENTA-2       PIC S9(9) COMP.
       01 WS-CUENTA-3       PIC S9(9) COMP.
       01 WS-CUENTA-4       PIC S9(9) COMP.
       01 WS-CUENTA-1-EDIT  PIC 9(10).
       01 WS-CUENTA-2-EDIT  PIC 9(10).
       01 WS-CUENTA-3-EDIT  PIC 9(10).
       01 WS-CUENTA-4-EDIT  PIC 9(10).

           EXEC SQL INCLUDE SQLCA END-EXEC.
             COPY SELMAP.
             COPY DFHAID.

          LINKAGE SECTION.
       01 DFHCOMMAREA.
                COPY SESSION.

       PROCEDURE DIVISION.

           IF SESSION-STATE NOT = 'S' AND
              SESSION-STATE NOT = 'A'
              EXEC CICS RETURN
                   TRANSID('BLOG')
                   END-EXEC
           ELSE
              IF SESSION-STATE = 'S'
                 PERFORM 100-CARGAR-CUENTAS
                 MOVE 'A' TO SESSION-STATE
                 MOVE SPACES TO OPCIONI
                 MOVE 'Seleccione una cuenta' TO MENSAJEO
                 EXEC CICS SEND MAP('SELMAP')
                      MAPSET('SELSET')
                      ERASE
                      RESP(WS-RESP)
                      END-EXEC
              ELSE
                 EXEC CICS RECEIVE MAP('SELMAP')
                      MAPSET('SELSET')
                      RESP(WS-RESP)
                      END-EXEC

                 IF EIBAID = DFHPF3
                    MOVE 'M' TO SESSION-STATE
                    EXEC CICS RETURN
                         TRANSID('BMEN')
                         COMMAREA(DFHCOMMAREA)
                         LENGTH(56)
                         END-EXEC
                 ELSE
                    PERFORM 200-SELECCIONAR-CUENTA
                    IF SQLCODE = 0
                       IF SESSION-OPER = 'D'
                          MOVE 'D' TO SESSION-STATE
                          EXEC CICS RETURN
                               TRANSID('BDEP')
                               COMMAREA(DFHCOMMAREA)
                               LENGTH(56)
                               END-EXEC
                       ELSE
                          MOVE 'R' TO SESSION-STATE
                          EXEC CICS RETURN
                               TRANSID('BRET')
                               COMMAREA(DFHCOMMAREA)
                               LENGTH(56)
                               END-EXEC
                       END-IF
                    ELSE
                       EXEC CICS SEND MAP('SELMAP')
                            MAPSET('SELSET')
                            DATAONLY
                            RESP(WS-RESP)
                            END-EXEC
                    END-IF
                 END-IF
              END-IF
           END-IF.

           EXEC CICS RETURN
                TRANSID('BSEL')
                COMMAREA(DFHCOMMAREA)
                LENGTH(56)
                END-EXEC.

       100-CARGAR-CUENTAS.
           MOVE 0 TO WS-CUENTA-1
                     WS-CUENTA-2
                     WS-CUENTA-3
                     WS-CUENTA-4.
           MOVE SPACES TO CUENTA1O CUENTA2O CUENTA3O CUENTA4O.
           COPY BCPSEL.
           EXIT.

       200-SELECCIONAR-CUENTA.
           MOVE 100 TO SQLCODE.
           EVALUATE OPCIONI
           WHEN '1'
                IF WS-CUENTA-1 NOT = 0
                   MOVE WS-CUENTA-1-EDIT TO SESSION-CUENTA
                   MOVE 0 TO SQLCODE
                END-IF
           WHEN '2'
                IF WS-CUENTA-2 NOT = 0
                   MOVE WS-CUENTA-2-EDIT TO SESSION-CUENTA
                   MOVE 0 TO SQLCODE
                END-IF
           WHEN '3'
                IF WS-CUENTA-3 NOT = 0
                   MOVE WS-CUENTA-3-EDIT TO SESSION-CUENTA
                   MOVE 0 TO SQLCODE
                END-IF
           WHEN '4'
                IF WS-CUENTA-4 NOT = 0
                   MOVE WS-CUENTA-4-EDIT TO SESSION-CUENTA
                   MOVE 0 TO SQLCODE
                END-IF
           WHEN OTHER
                MOVE 'Seleccione una opcion valida' TO MENSAJEO
           END-EVALUATE.