       IDENTIFICATION DIVISION.
       PROGRAM-ID. BCPMENU.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY MENUMAP.
           COPY DFHAID.
       01 WS-RESP      PIC S9(8) COMP.

       LINKAGE SECTION.
       01 DFHCOMMAREA.
              COPY SESSION.

       PROCEDURE DIVISION.

       MAIN-LOGIC SECTION.
      *----------------------------------------------------------------*
      * Control principal del flujo conversacional                       *
      *----------------------------------------------------------------*
           IF EIBCALEN = 0 OR SESSION-STATE NOT = 'M'
              PERFORM 1000-FIRST-TIME
           ELSE
              PERFORM 2000-PROCESS-INPUT
           END-IF.

           PERFORM 9000-RETURN-MENU.

       MAIN-LOGIC-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Primera ejecución o inicialización del menú                    *
      *----------------------------------------------------------------*
       1000-FIRST-TIME.
           MOVE LOW-VALUES TO MENUMAPO
           MOVE SPACES TO MENSAJEO
           MOVE 'M' TO SESSION-STATE

           EXEC CICS SEND MAP('MENUMAP')
                MAPSET('MENUSET')
                ERASE
                RESP(WS-RESP)
                END-EXEC.

       1000-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Procesamiento de la entrada del usuario                        *
      *----------------------------------------------------------------*
       2000-PROCESS-INPUT.
           EXEC CICS RECEIVE MAP('MENUMAP')
                MAPSET('MENUSET')
                RESP(WS-RESP)
                END-EXEC

           IF EIBAID = DFHPF3
              PERFORM 2100-HANDLE-EXIT
           ELSE
              PERFORM 2200-EVALUATE-OPTION
           END-IF.

       2000-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Salida de la transacción (PF3)                                 *
      *----------------------------------------------------------------*
       2100-HANDLE-EXIT.
           EXEC CICS SEND CONTROL
                ERASE
                END-EXEC
           EXEC CICS RETURN
                END-EXEC.

       2100-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Evaluación de la opción ingresada en el mapa                   *
      *----------------------------------------------------------------*
       2200-EVALUATE-OPTION.
           EVALUATE OPCIONI
           WHEN '1'
                MOVE 'C' TO SESSION-OPER
                MOVE 'S' TO SESSION-STATE
                PERFORM 3000-XFER-BSEL

           WHEN '2'
                MOVE 'D' TO SESSION-OPER
                MOVE 'S' TO SESSION-STATE
                PERFORM 3000-XFER-BSEL

           WHEN '3'
                MOVE 'R' TO SESSION-OPER
                MOVE 'S' TO SESSION-STATE
                PERFORM 3000-XFER-BSEL

           WHEN '4'
                MOVE 'V' TO SESSION-OPER
                MOVE 'S' TO SESSION-STATE
                PERFORM 3000-XFER-BSEL

           WHEN OTHER
                MOVE 'Opcion invalida' TO MENSAJEO
                EXEC CICS SEND MAP('MENUMAP')
                     MAPSET('MENUSET')
                     DATAONLY
                     RESP(WS-RESP)
                     END-EXEC
           END-EVALUATE.

       2200-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Transferencia de control a BSEL                                *
      *----------------------------------------------------------------*
       3000-XFER-BSEL.
           EXEC CICS RETURN
                TRANSID('BSEL')
                COMMAREA(DFHCOMMAREA)
                LENGTH(56)
                END-EXEC.

       3000-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Transferencia de control a BMOV                                *
      * NOTA: ya no se invoca desde ningun lado (la opcion 4 ahora     *
      * pasa primero por BSEL). Se deja por si se vuelve a necesitar,  *
      * pero confirmar si se debe eliminar.                            *
      *----------------------------------------------------------------*
       3100-XFER-BMOV.
           EXEC CICS RETURN
                TRANSID('BMOV')
                COMMAREA(DFHCOMMAREA)
                LENGTH(56)
                END-EXEC.

       3100-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Retorno general al menú (Transacción BMEN)                     *
      *----------------------------------------------------------------*
       9000-RETURN-MENU.
           EXEC CICS RETURN
                TRANSID('BMEN')
                COMMAREA(DFHCOMMAREA)
                LENGTH(56)
                END-EXEC.

       9000-EXIT.
           EXIT.
