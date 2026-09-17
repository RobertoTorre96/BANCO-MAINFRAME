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

       MAIN-LOGIC SECTION.
      *----------------------------------------------------------------*
      * Control principal del flujo de login                           *
      *----------------------------------------------------------------*
           IF EIBCALEN = 0
              PERFORM 1000-FIRST-TIME
           ELSE
              PERFORM 2000-PROCESS-INPUT
           END-IF.

           EXEC CICS RETURN
                TRANSID('BLOG')
                COMMAREA(WS-COMMAREA)
                LENGTH(56)
                END-EXEC.

       MAIN-LOGIC-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Primera ejecución: pinta el mapa de login vacío                *
      *----------------------------------------------------------------*
       1000-FIRST-TIME.
           MOVE LOW-VALUES TO LOGMAPO
           MOVE 'Ingrese sus credenciales' TO MENSAJEO

           EXEC CICS SEND MAP('LOGMAP')
                MAPSET('LOGSET')
                ERASE
                RESP(WS-RESP)
                END-EXEC.

       1000-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Procesa la entrada del usuario (credenciales o PF3)            *
      *----------------------------------------------------------------*
       2000-PROCESS-INPUT.
           EXEC CICS RECEIVE MAP('LOGMAP')
                MAPSET('LOGSET')
                RESP(WS-RESP)
                END-EXEC

           IF EIBAID = DFHPF3
              PERFORM 2100-HANDLE-EXIT
           ELSE
              PERFORM 2200-VALIDATE-CREDENTIALS
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
      * Valida email/password contra la base y decide el flujo         *
      *----------------------------------------------------------------*
       2200-VALIDATE-CREDENTIALS.
           MOVE EMAILI TO WS-EMAIL
           MOVE PASSWORDI TO WS-PASSWORD

           PERFORM 100-VALIDAR-LOGIN

           IF SQLCODE = 0 AND WS-HASH-GUARDADO = WS-HASH-CALCULADO
              PERFORM 2300-LOGIN-OK
           ELSE
              PERFORM 2400-LOGIN-FAILED
           END-IF.

       2200-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Login correcto: setea la sesion y transfiere a BMEN            *
      *----------------------------------------------------------------*
       2300-LOGIN-OK.
           MOVE WS-NRO-TITULAR TO SESSION-TITULAR
           MOVE WS-EMAIL TO SESSION-EMAIL
           MOVE 'A' TO SESSION-STATE

           EXEC CICS RETURN
                TRANSID('BMEN')
                COMMAREA(WS-COMMAREA)
                LENGTH(56)
                END-EXEC.

       2300-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Login incorrecto: reintenta en la misma pantalla                *
      *----------------------------------------------------------------*
       2400-LOGIN-FAILED.
           MOVE 'Email o password incorrectos' TO MENSAJEO

           EXEC CICS SEND MAP('LOGMAP')
                MAPSET('LOGSET')
                ERASE
                RESP(WS-RESP)
                END-EXEC.

       2400-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Valida credenciales contra Z83078.TITULARES                    *
      *----------------------------------------------------------------*
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

       100-EXIT.
           EXIT.
