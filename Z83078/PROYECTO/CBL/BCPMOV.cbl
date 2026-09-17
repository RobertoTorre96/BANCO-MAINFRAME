       IDENTIFICATION DIVISION.
       PROGRAM-ID. BCPMOV.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-RESP        PIC S9(8) COMP.
       01 WS-NRO-CUENTA  PIC S9(9) COMP.
       01 WS-TIPO-MOV    PIC X(8).
       01 WS-MONTO       PIC S9(7)V99 COMP-3.
       01 WS-MONTO-EDIT  PIC Z(7)9.99.
       01 WS-FECHA-HORA  PIC X(26).
       01 WS-MOV-OUT     PIC X(60).
       01 WS-HAY-MOV     PIC X        VALUE 'N'.

           EXEC SQL INCLUDE SQLCA END-EXEC.
           COPY MOVMAP.
           COPY DFHAID.

          LINKAGE SECTION.
       01 DFHCOMMAREA.
                COPY SESSION.

       PROCEDURE DIVISION.

       MAIN-LOGIC SECTION.
      *----------------------------------------------------------------*
      * Control principal del flujo de movimientos                      *
      *----------------------------------------------------------------*
           IF SESSION-STATE NOT = 'V' AND
              SESSION-STATE NOT = 'M'
              EXEC CICS RETURN
                   TRANSID('BLOG')
                   END-EXEC
           ELSE
              IF EIBCALEN = 0 OR SESSION-STATE = 'V'
                 PERFORM 1000-FIRST-TIME
              ELSE
                 PERFORM 2000-PROCESS-INPUT
              END-IF
           END-IF.

           EXEC CICS RETURN
                TRANSID('BMOV')
                COMMAREA(DFHCOMMAREA)
                LENGTH(56)
                END-EXEC.

       MAIN-LOGIC-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Primera vez: pinta el mapa con la cuenta ya seleccionada        *
      *----------------------------------------------------------------*
       1000-FIRST-TIME.
           MOVE LOW-VALUES TO MOVMAPO
           MOVE SESSION-CUENTA TO NROCUENTAO
           MOVE 'Cuenta seleccionada' TO MENSAJEO
           MOVE 'M' TO SESSION-STATE

           EXEC CICS SEND MAP('MOVMAP')
                MAPSET('MOVSET')
                ERASE
                RESP(WS-RESP)
                END-EXEC.

       1000-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Procesa la entrada del usuario (PF3 o consulta de movimientos) *
      *----------------------------------------------------------------*
       2000-PROCESS-INPUT.
           EXEC CICS RECEIVE MAP('MOVMAP')
                MAPSET('MOVSET')
                RESP(WS-RESP)
                END-EXEC

           IF EIBAID = DFHPF3
              PERFORM 2100-HANDLE-EXIT
           ELSE
              PERFORM 2200-CONSULTAR-MOVIMIENTOS
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
      * Valida la cuenta en sesion y carga sus movimientos             *
      *----------------------------------------------------------------*
       2200-CONSULTAR-MOVIMIENTOS.
           IF SESSION-CUENTA NOT = LOW-VALUES AND
              SESSION-CUENTA NOT = SPACES AND
              FUNCTION TEST-NUMVAL(SESSION-CUENTA) = 0

              COMPUTE WS-NRO-CUENTA = FUNCTION NUMVAL(SESSION-CUENTA)
              PERFORM 100-CARGAR-MOVIMIENTOS

              IF SQLCODE = 100
                 MOVE 'Cuenta no encontrada' TO MENSAJEO
              ELSE
                 MOVE 'Movimientos encontrados' TO MENSAJEO
              END-IF
           ELSE
              MOVE SPACES TO MOVIM1O MOVIM2O MOVIM3O MOVIM4O
              MOVE 'Datos invalidos' TO MENSAJEO
           END-IF

           EXEC CICS SEND MAP('MOVMAP')
                MAPSET('MOVSET')
                DATAONLY
                RESP(WS-RESP)
                END-EXEC.

       2200-EXIT.
           EXIT.

      *----------------------------------------------------------------*
      * Carga los movimientos de la cuenta vía cursor SQL (COPY)       *
      * NOTA: revisar que el copybook BCPMOV termine su propio loop   *
      * de FETCH con un EXIT (o CLOSE + salto explícito), ya que este *
      * parrafo no tiene EXIT antes de 110-LEER-MOVIMIENTO y podria   *
      * haber fall-through no intencional si el copy no lo maneja.    *
      *----------------------------------------------------------------*
       100-CARGAR-MOVIMIENTOS.
           MOVE SPACES TO MOVIM1O MOVIM2O MOVIM3O MOVIM4O.
           COPY BCPMOV.
           EXIT.

      *----------------------------------------------------------------*
      * Lee un movimiento del cursor y arma la linea de salida         *
      *----------------------------------------------------------------*
       110-LEER-MOVIMIENTO.
           MOVE SPACES TO WS-MOV-OUT.
           EXEC SQL
                FETCH C-MOVIMIENTOS
                 INTO :WS-TIPO-MOV, :WS-MONTO, :WS-FECHA-HORA
           END-EXEC.
           IF SQLCODE = 0
              MOVE 'S' TO WS-HAY-MOV
              MOVE WS-MONTO TO WS-MONTO-EDIT
              STRING WS-TIPO-MOV DELIMITED BY SPACE
                     ' ' DELIMITED BY SIZE
                     WS-MONTO-EDIT DELIMITED BY SIZE
                     ' ' DELIMITED BY SIZE
                     WS-FECHA-HORA DELIMITED BY SPACE
                 INTO WS-MOV-OUT
              END-STRING
           END-IF.

       110-EXIT.
           EXIT.
