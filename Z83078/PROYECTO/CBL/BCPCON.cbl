       IDENTIFICATION DIVISION.
       PROGRAM-ID. BCPCON.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-RESP        PIC S9(8) COMP.

      * --- VARIABLES HOST PARA DB2 ---
       01 WS-NRO-CUENTA  PIC S9(9) COMP.

       01 WS-NOMBRE      PIC X(30).
       01 WS-APELLIDO    PIC X(30).

       01 WS-SALDO       PIC S9(10)V99 COMP-3.
      * -------------------------------

       01 WS-SALDO-EDIT  PIC -(9)9.99.
          COPY CONMAP.
          COPY DFHAID.
           EXEC SQL INCLUDE SQLCA END-EXEC.

          LINKAGE SECTION.
       01 DFHCOMMAREA.
                COPY SESSION.

       PROCEDURE DIVISION.

       MAIN-LOGIC SECTION.
      *----------------------------------------------------------------*
      * Control principal del flujo de consulta de cuenta               *
      *----------------------------------------------------------------*
           IF SESSION-STATE NOT = 'C' AND
              SESSION-STATE NOT = 'M'
              EXEC CICS RETURN
                   TRANSID('BLOG')
                   END-EXEC
           ELSE
              IF EIBCALEN = 0 OR SESSION-STATE = 'C'
                 PERFORM 1000-FIRST-TIME
              ELSE
                 PERFORM 2000-PROCESS-INPUT
              END-IF
           END-IF.

           EXEC CICS RETURN
                TRANSID('BCON')
                COMMAREA(DFHCOMMAREA)
                LENGTH(56)
                END-EXEC.

       MAIN-LOGIC-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Primera vez: cuenta ya viene seleccionada desde BSEL, o         *
      * todavia no hay cuenta y hay que pedirla                        *
      *----------------------------------------------------------------*
       1000-FIRST-TIME.
           IF SESSION-CUENTA NOT = SPACES
              PERFORM 1100-CONSULTAR-CUENTA-SESION
           ELSE
              PERFORM 1200-PEDIR-CUENTA
           END-IF.

       1000-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Consulta la cuenta que llego seleccionada en SESSION-CUENTA    *
      *----------------------------------------------------------------*
       1100-CONSULTAR-CUENTA-SESION.
           IF SESSION-CUENTA NOT = LOW-VALUES AND
              SESSION-CUENTA NOT = SPACES AND
              FUNCTION TEST-NUMVAL(SESSION-CUENTA) = 0
              MOVE SESSION-CUENTA TO NROCUENTAO
              COMPUTE WS-NRO-CUENTA = FUNCTION NUMVAL(SESSION-CUENTA)

              PERFORM 100-CONSULTAR-DB2

              EVALUATE SQLCODE
              WHEN 0
                   MOVE WS-NOMBRE TO NOMBREO
                   MOVE WS-APELLIDO TO APELLIDOO
                   MOVE WS-SALDO TO WS-SALDO-EDIT
                   MOVE WS-SALDO-EDIT TO SALDOO
                   MOVE 'Cuenta encontrada' TO MENSAJEO
              WHEN 100
                   MOVE SPACES TO NOMBREO
                   MOVE SPACES TO APELLIDOO
                   MOVE SPACES TO SALDOO
                   MOVE 'Cuenta no encontrada' TO MENSAJEO
              WHEN OTHER
                   MOVE SPACES TO NOMBREO
                   MOVE SPACES TO APELLIDOO
                   MOVE SPACES TO SALDOO
                   MOVE 'Error al consultar cuenta' TO MENSAJEO
              END-EVALUATE
           ELSE
              MOVE SPACES TO NOMBREO
              MOVE SPACES TO APELLIDOO
              MOVE SPACES TO SALDOO
              MOVE 'Cuenta no encontrada' TO MENSAJEO
           END-IF

           MOVE 'M' TO SESSION-STATE

           EXEC CICS SEND MAP('CONMAP')
                MAPSET('CONSET')
                ERASE
                RESP(WS-RESP)
                END-EXEC.

       1100-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * No hay cuenta todavia: pinta el mapa vacio pidiendo el numero  *
      *----------------------------------------------------------------*
       1200-PEDIR-CUENTA.
           MOVE LOW-VALUES TO CONMAPO
           MOVE 'Ingrese el numero de cuenta' TO MENSAJEO
           MOVE 'M' TO SESSION-STATE

           EXEC CICS SEND MAP('CONMAP')
                MAPSET('CONSET')
                ERASE
                RESP(WS-RESP)
                END-EXEC.

       1200-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Procesa la entrada del usuario (numero de cuenta o PF3)        *
      *----------------------------------------------------------------*
       2000-PROCESS-INPUT.
           EXEC CICS RECEIVE MAP('CONMAP')
                MAPSET('CONSET')
                RESP(WS-RESP)
                END-EXEC

           IF EIBAID = DFHPF3
              PERFORM 2100-HANDLE-EXIT
           ELSE
              PERFORM 2200-CONSUL-CUENTA-INGRESADA
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
      * Consulta la cuenta que el usuario tipeo en el mapa             *
      *----------------------------------------------------------------*
       2200-CONSUL-CUENTA-INGRESADA.
           IF NROCUENTAI NOT = LOW-VALUES AND
              NROCUENTAI NOT = SPACES AND
              FUNCTION TEST-NUMVAL(NROCUENTAI) = 0

              COMPUTE WS-NRO-CUENTA = FUNCTION NUMVAL(NROCUENTAI)

      *        --- LLAMADA SEGURA AL COPY SQL ---
              PERFORM 100-CONSULTAR-DB2

              EVALUATE SQLCODE
              WHEN 0
                   MOVE WS-NOMBRE TO NOMBREO
                   MOVE WS-APELLIDO TO APELLIDOO
                   MOVE WS-SALDO TO WS-SALDO-EDIT
                   MOVE WS-SALDO-EDIT TO SALDOO
                   MOVE 'Cuenta encontrada' TO MENSAJEO
              WHEN 100
                   MOVE SPACES TO NOMBREO
                   MOVE SPACES TO APELLIDOO
                   MOVE SPACES TO SALDOO
                   MOVE 'Cuenta no encontrada' TO MENSAJEO
              WHEN OTHER
                   MOVE SPACES TO NOMBREO
                   MOVE SPACES TO APELLIDOO
                   MOVE SPACES TO SALDOO
                   MOVE SPACES TO MENSAJEO
                   STRING 'ST=' DELIMITED BY SIZE
                          SQLSTATE DELIMITED BY SIZE
                          ' ' DELIMITED BY SIZE
                          SQLERRMC DELIMITED BY SIZE
                      INTO MENSAJEO
                   END-STRING
              END-EVALUATE
           ELSE
              MOVE SPACES TO NOMBREO
              MOVE SPACES TO APELLIDOO
              MOVE SPACES TO SALDOO
              MOVE 'Cuenta no encontrada' TO MENSAJEO
           END-IF

           EXEC CICS SEND MAP('CONMAP')
                MAPSET('CONSET')
                ERASE
                RESP(WS-RESP)
                END-EXEC.

       2200-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Parrafo aislado para el SQL (COPY externo)                     *
      *----------------------------------------------------------------*
       100-CONSULTAR-DB2.
           COPY BCPCON.
           EXIT.