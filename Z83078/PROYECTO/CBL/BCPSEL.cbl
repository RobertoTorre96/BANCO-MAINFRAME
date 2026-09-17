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

       MAIN-LOGIC SECTION.
      *----------------------------------------------------------------*
      * Control principal del flujo de seleccion de cuenta              *
      *----------------------------------------------------------------*
           IF SESSION-STATE NOT = 'S' AND
              SESSION-STATE NOT = 'A'
              EXEC CICS RETURN
                   TRANSID('BLOG')
                   END-EXEC
           ELSE
              IF SESSION-STATE = 'S'
                 PERFORM 1000-FIRST-TIME
              ELSE
                 PERFORM 2000-PROCESS-INPUT
              END-IF
           END-IF.

           EXEC CICS RETURN
                TRANSID('BSEL')
                COMMAREA(DFHCOMMAREA)
                LENGTH(56)
                END-EXEC.

       MAIN-LOGIC-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Primera vez: limpia el mapa, carga las cuentas del titular     *
      * y pinta la pantalla                                            *
      *----------------------------------------------------------------*
       1000-FIRST-TIME.
           MOVE LOW-VALUES TO SELMAPO
           PERFORM 100-CARGAR-CUENTAS

           MOVE SPACES TO OPCIONI
           MOVE 'A' TO SESSION-STATE
           MOVE 'Seleccione una cuenta' TO MENSAJEO

           EXEC CICS SEND MAP('SELMAP')
                MAPSET('SELSET')
                ERASE
                RESP(WS-RESP)
                END-EXEC.

       1000-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Procesa la entrada del usuario (opcion elegida o PF3)          *
      *----------------------------------------------------------------*
       2000-PROCESS-INPUT.
           EXEC CICS RECEIVE MAP('SELMAP')
                MAPSET('SELSET')
                RESP(WS-RESP)
                END-EXEC

           IF EIBAID = DFHPF3
              PERFORM 2100-HANDLE-EXIT
           ELSE
              PERFORM 2200-EVALUATE-SELECTION
           END-IF.

       2000-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Salida hacia el menu (PF3)                                     *
      *----------------------------------------------------------------*
       2100-HANDLE-EXIT.
           MOVE 'M' TO SESSION-STATE

           EXEC CICS RETURN
                TRANSID('BMEN')
                COMMAREA(DFHCOMMAREA)
                LENGTH(56)
                END-EXEC.

       2100-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Evalua la cuenta elegida y deriva a BCON/BDEP/BRET/BMOV        *
      *----------------------------------------------------------------*
       2200-EVALUATE-SELECTION.
           PERFORM 200-SELECCIONAR-CUENTA

           IF SQLCODE = 0
              PERFORM 2300-XFER-BY-OPERATION
           ELSE
              EXEC CICS SEND MAP('SELMAP')
                   MAPSET('SELSET')
                   DATAONLY
                   RESP(WS-RESP)
                   END-EXEC
           END-IF.

       2200-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Cuenta valida: transfiere segun la operacion pedida            *
      * (C=Consulta, D=Deposito, R=Retiro, V=Ver movimientos)          *
      *----------------------------------------------------------------*
       2300-XFER-BY-OPERATION.
           EVALUATE SESSION-OPER
               WHEN 'C'
                   MOVE 'C' TO SESSION-STATE
                   EXEC CICS RETURN
                        TRANSID('BCON')
                        COMMAREA(DFHCOMMAREA)
                        LENGTH(56)
                        END-EXEC
               WHEN 'D'
                   MOVE 'D' TO SESSION-STATE
                   EXEC CICS RETURN
                        TRANSID('BDEP')
                        COMMAREA(DFHCOMMAREA)
                        LENGTH(56)
                        END-EXEC
               WHEN 'V'
                   MOVE 'V' TO SESSION-STATE
                   EXEC CICS RETURN
                        TRANSID('BMOV')
                        COMMAREA(DFHCOMMAREA)
                        LENGTH(56)
                        END-EXEC
               WHEN OTHER
                   MOVE 'R' TO SESSION-STATE
                   EXEC CICS RETURN
                        TRANSID('BRET')
                        COMMAREA(DFHCOMMAREA)
                        LENGTH(56)
                        END-EXEC
           END-EVALUATE.

       2300-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Carga las cuentas del titular vía cursor SQL (COPY externo)    *
      *----------------------------------------------------------------*
       100-CARGAR-CUENTAS.
           MOVE 0 TO WS-CUENTA-1
                     WS-CUENTA-2
                     WS-CUENTA-3
                     WS-CUENTA-4.
           MOVE SPACES TO CUENTA1O CUENTA2O CUENTA3O CUENTA4O.
           COPY BCPSEL.
           EXIT.

      *----------------------------------------------------------------*
      * Valida la opcion tipeada contra las cuentas ya cargadas        *
      *----------------------------------------------------------------*
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

       200-EXIT.
           EXIT.
