       IDENTIFICATION DIVISION.
       PROGRAM-ID. BCPLOG.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-RESP            PIC S9(8) COMP.
       01 WS-COMMAREA.
          COPY SESSION.
       01 WS-NRO-TITULAR     PIC S9(9) COMP.
       01 WS-EMAIL           PIC X(40).
       01 WS-PASSWORD        PIC X(20).
       01 WS-HASH-GUARDADO   PIC X(64).
       01 WS-HASH-CALCULADO  PIC X(64).
           EXEC SQL INCLUDE SQLCA END-EXEC.
          COPY LOGMAP.
          COPY DFHAID.

       PROCEDURE DIVISION.

           IF EIBCALEN = 0
              MOVE LOW-VALUES TO LOGMAPO
              MOVE 'Ingrese sus credenciales' TO MENSAJEO
              EXEC CICS SEND MAP('LOGMAP')
                   MAPSET('LOGSET')
                   ERASE
                   RESP(WS-RESP)
                   END-EXEC
           ELSE
              EXEC CICS RECEIVE MAP('LOGMAP')
                   MAPSET('LOGSET')
                   RESP(WS-RESP)
                   END-EXEC

              IF EIBAID = DFHPF3
                 EXEC CICS SEND CONTROL
                      ERASE
                      END-EXEC
                 EXEC CICS RETURN
                      END-EXEC
              ELSE
                 MOVE EMAILI TO WS-EMAIL
                 MOVE PASSWORDI TO WS-PASSWORD
                 PERFORM 100-VALIDAR-LOGIN
                 IF SQLCODE = 0 AND
                    WS-HASH-GUARDADO = WS-HASH-CALCULADO
                    MOVE WS-NRO-TITULAR TO SESSION-TITULAR
                    MOVE WS-EMAIL TO SESSION-EMAIL
                    MOVE 'A' TO SESSION-STATE
                    EXEC CICS RETURN
                         TRANSID('BMEN')
                         COMMAREA(WS-COMMAREA)
                         LENGTH(56)
                         END-EXEC
                 ELSE
                    MOVE 'Email o password incorrectos' TO MENSAJEO
                    EXEC CICS SEND MAP('LOGMAP')
                         MAPSET('LOGSET')
                         ERASE
                         RESP(WS-RESP)
                         END-EXEC
                 END-IF
              END-IF
           END-IF.

           EXEC CICS RETURN
                TRANSID('BLOG')
                COMMAREA(WS-COMMAREA)
                LENGTH(56)
                END-EXEC.

       100-VALIDAR-LOGIN.
            EXEC SQL
               SELECT NRO_TITULAR
                              , PASSWORD_HASH
                              , HEX(HASH(RTRIM(SALT) CONCAT
                                             RTRIM(:WS-PASSWORD), 2))
                         INTO :WS-NRO-TITULAR
                              , :WS-HASH-GUARDADO
                              , :WS-HASH-CALCULADO
                 FROM Z83078.TITULARES
                     WHERE UPPER(RTRIM(EMAIL)) = UPPER(RTRIM(:WS-EMAIL))
            END-EXEC.