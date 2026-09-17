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
       01 WS-MENSAJE     PIC X(40).

           EXEC SQL INCLUDE SQLCA END-EXEC.

           COPY RETMAP.
           COPY DFHAID.

          LINKAGE SECTION.
       01 DFHCOMMAREA.
                COPY SESSION.

       PROCEDURE DIVISION.

       MAIN-LOGIC SECTION.
      *----------------------------------------------------------------*
      * Control principal del flujo de retiro                          *
      *----------------------------------------------------------------*
           IF SESSION-STATE NOT = 'R' AND
              SESSION-STATE NOT = 'M'
               EXEC CICS RETURN
                    TRANSID('BLOG')
               END-EXEC
           ELSE
               IF EIBCALEN = 0 OR SESSION-STATE = 'R'
                   PERFORM 1000-FIRST-TIME THRU 1000-EXIT
               ELSE
                   PERFORM 2000-PROCESS-INPUT THRU 2000-EXIT
               END-IF
           END-IF.

           EXEC CICS RETURN
                TRANSID('BRET')
                COMMAREA(DFHCOMMAREA)
                LENGTH(56)
           END-EXEC.

       MAIN-LOGIC-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Primera vez: pinta el mapa con la cuenta y pide el monto       *
      *----------------------------------------------------------------*
       1000-FIRST-TIME.
           MOVE LOW-VALUES TO RETMAPO
           MOVE SESSION-CUENTA TO NROCUENTAO
           MOVE 'Ingrese el monto' TO MENSAJEO
           MOVE 'M' TO SESSION-STATE

           EXEC CICS SEND MAP('RETMAP')
                     MAPSET('RETSET')
                     ERASE
                     RESP(WS-RESP)
           END-EXEC.

       1000-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Procesa la entrada del usuario (PF3 o monto a retirar)         *
      *----------------------------------------------------------------*
       2000-PROCESS-INPUT.
           EXEC CICS RECEIVE MAP('RETMAP')
                     MAPSET('RETSET')
                     RESP(WS-RESP)
           END-EXEC

           IF EIBAID = DFHPF3
               PERFORM 2100-HANDLE-EXIT THRU 2100-EXIT
           ELSE
               PERFORM 2200-EVALUATE-RETIRO THRU 2200-EXIT
           END-IF.

       2000-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Salida hacia el menu (PF3)                                     *
      *----------------------------------------------------------------*
       2100-HANDLE-EXIT.
           EXEC CICS SEND CONTROL
                     ERASE
           END-EXEC
           EXEC CICS RETURN
                TRANSID('BMEN')
                COMMAREA(DFHCOMMAREA)
                LENGTH(56)
           END-EXEC.

       2100-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Valida cuenta/monto ingresados y deriva a la validacion de     *
      * monto, o marca datos invalidos                                 *
      *----------------------------------------------------------------*
       2200-EVALUATE-RETIRO.
           MOVE SESSION-CUENTA TO WS-CUENTA-OUT

           IF SESSION-CUENTA NOT = SPACES AND
              FUNCTION TEST-NUMVAL(MONTOI) = 0
               COMPUTE WS-NRO-CUENTA = FUNCTION NUMVAL(SESSION-CUENTA)
               COMPUTE WS-MONTO = FUNCTION NUMVAL(MONTOI)
               PERFORM 2300-VALIDAR-MONTO THRU 2300-EXIT
           ELSE
               MOVE 'Datos invalidos' TO WS-MENSAJE
               PERFORM 9000-MOSTRAR-ERROR THRU 9000-EXIT
           END-IF

           EXEC CICS SEND MAP('RETMAP')
                     MAPSET('RETSET')
                     ERASE
                     RESP(WS-RESP)
           END-EXEC.

       2200-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Valida que el monto sea positivo antes de ejecutar el retiro   *
      *----------------------------------------------------------------*
       2300-VALIDAR-MONTO.
           IF WS-MONTO > 0
               PERFORM 2400-EJECUTAR-RETIRO THRU 2400-EXIT
           ELSE
               MOVE 'Monto invalido' TO WS-MENSAJE
               PERFORM 9000-MOSTRAR-ERROR THRU 9000-EXIT
           END-IF.

       2300-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Ejecuta el retiro contra DB2 y arma el mensaje segun SQLCODE   *
      *----------------------------------------------------------------*
       2400-EJECUTAR-RETIRO.
           PERFORM 2500-REALIZAR-RETIRO THRU 2500-EXIT

           EVALUATE SQLCODE
               WHEN 0
                   MOVE LOW-VALUES TO RETMAPO
                   MOVE 'Retiro realizado' TO MENSAJEO
               WHEN 100
                   MOVE 'Cuenta inexistente o saldo insuficiente'
                       TO WS-MENSAJE
                   PERFORM 9000-MOSTRAR-ERROR THRU 9000-EXIT
               WHEN OTHER
                   MOVE 'Error de actualizacion DB2' TO WS-MENSAJE
                   PERFORM 9000-MOSTRAR-ERROR THRU 9000-EXIT
           END-EVALUATE.

       2400-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Ejecuta el retiro vía SQL (COPY externo)                       *
      *----------------------------------------------------------------*
       2500-REALIZAR-RETIRO.
           COPY BCPRET.

       2500-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Rutina comun para mostrar un mensaje de error en el mapa,      *
      * conservando la cuenta ingresada y limpiando el monto           *
      *----------------------------------------------------------------*
       9000-MOSTRAR-ERROR.
           MOVE LOW-VALUES TO RETMAPO
           MOVE WS-CUENTA-OUT TO NROCUENTAO
           MOVE SPACES TO MONTOO
           MOVE WS-MENSAJE TO MENSAJEO.

       9000-EXIT.
           EXIT.
