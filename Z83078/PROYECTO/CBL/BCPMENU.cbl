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

           IF EIBCALEN = 0 OR SESSION-STATE NOT = 'M'
              MOVE LOW-VALUES TO MENUMAPO
              MOVE SPACES TO MENSAJEO
              MOVE 'M' TO SESSION-STATE
              EXEC CICS SEND MAP('MENUMAP')
                   MAPSET('MENUSET')
                   ERASE
                   RESP(WS-RESP)
                   END-EXEC
              EXEC CICS RETURN
                   TRANSID('BMEN')
                   COMMAREA(DFHCOMMAREA)
                   LENGTH(56)
                   END-EXEC
           ELSE
              EXEC CICS RECEIVE MAP('MENUMAP')
                   MAPSET('MENUSET')
                   RESP(WS-RESP)
                   END-EXEC

              IF EIBAID = DFHPF3
                 EXEC CICS SEND CONTROL
                      ERASE
                      END-EXEC
                 EXEC CICS RETURN
                      END-EXEC
              ELSE
                 EVALUATE OPCIONI
                 WHEN '1'
                      MOVE 'C' TO SESSION-OPER
                      MOVE 'S' TO SESSION-STATE
                      EXEC CICS RETURN
                           TRANSID('BSEL')
                           COMMAREA(DFHCOMMAREA)
                           LENGTH(56)
                           END-EXEC
                 WHEN '2'
                      MOVE 'D' TO SESSION-OPER
                      MOVE 'S' TO SESSION-STATE
                      EXEC CICS RETURN
                           TRANSID('BSEL')
                           COMMAREA(DFHCOMMAREA)
                           LENGTH(56)
                           END-EXEC
                 WHEN '3'
                      MOVE 'R' TO SESSION-OPER
                      MOVE 'S' TO SESSION-STATE
                      EXEC CICS RETURN
                           TRANSID('BSEL')
                           COMMAREA(DFHCOMMAREA)
                           LENGTH(56)
                           END-EXEC
                 WHEN '4'
                      MOVE 'V' TO SESSION-STATE
                      EXEC CICS RETURN
                           TRANSID('BMOV')
                           COMMAREA(DFHCOMMAREA)
                           LENGTH(56)
                           END-EXEC
                 WHEN OTHER
                      MOVE 'Opcion invalida' TO MENSAJEO
                 END-EVALUATE

                 EXEC CICS SEND MAP('MENUMAP')
                      MAPSET('MENUSET')
                      DATAONLY
                      RESP(WS-RESP)
                      END-EXEC
              END-IF
           END-IF.

           EXEC CICS RETURN
                TRANSID('BMEN')
                COMMAREA(DFHCOMMAREA)
                LENGTH(56)
                END-EXEC.