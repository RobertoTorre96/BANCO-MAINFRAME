       IDENTIFICATION DIVISION.
       PROGRAM-ID. MOVREP.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT MOV-VSAM ASSIGN TO MOVVSAM
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS MOV-CLAVE
               FILE STATUS IS WS-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
         FD  MOV-VSAM
            RECORD CONTAINS 85 CHARACTERS.
       01 MOV-REGISTRO.
          05 MOV-CLAVE       PIC X(36).
          05 MOV-CUENTA      PIC 9(10).
          05 MOV-TIPO        PIC X(8).
          05 MOV-MONTO       PIC S9(7)V99 COMP-3.
          05 MOV-FECHA-HORA  PIC X(26).

       WORKING-STORAGE SECTION.
       01 WS-FILE-STATUS     PIC XX.
       01 WS-EOF             PIC X        VALUE 'N'.
       01 WS-CONTADOR        PIC 9(7)     VALUE 0.
       01 WS-DEPOSITOS       PIC S9(9)V99 COMP-3
                                          VALUE 0.
       01 WS-RETIROS         PIC S9(9)V99 COMP-3
                                          VALUE 0.
       01 WS-MONTO-EDIT      PIC Z(9)9.99.
       01 WS-NETO-EDIT       PIC -(9)9.99.

           EXEC SQL INCLUDE SQLCA END-EXEC.

       01 WS-CUENTA          PIC S9(9) COMP.
       01 WS-CUENTA-EDIT     PIC 9(10).
       01 WS-TIPO            PIC X(8).
       01 WS-MONTO           PIC S9(7)V99 COMP-3.
       01 WS-FECHA-HORA      PIC X(26).
       01 WS-CLAVE           PIC X(36).

           EXEC SQL
                DECLARE C-MOV-DIA CURSOR FOR
                SELECT NRO_CUENTA, TIPO_MOV, MONTO, CHAR(FECHA_HORA)
                  FROM Z83078.MOVIMIENTOS
                 WHERE DATE(FECHA_HORA) = CURRENT DATE
                 ORDER BY FECHA_HORA, NRO_CUENTA
           END-EXEC.

       PROCEDURE DIVISION.
           OPEN OUTPUT MOV-VSAM
           IF WS-FILE-STATUS NOT = '00'
              DISPLAY 'ERROR OPEN VSAM STATUS=' WS-FILE-STATUS
              MOVE 8 TO RETURN-CODE
              GOBACK
           END-IF

           EXEC SQL OPEN C-MOV-DIA END-EXEC
           IF SQLCODE NOT = 0
              DISPLAY 'ERROR OPEN CURSOR SQLCODE=' SQLCODE
              MOVE 8 TO RETURN-CODE
              CLOSE MOV-VSAM
              GOBACK
           END-IF

           DISPLAY 'REPORTE DE MOVIMIENTOS DEL DIA'
           DISPLAY 'CUENTA     TIPO     MONTO       FECHA-HORA'

           PERFORM UNTIL WS-EOF = 'S'
              EXEC SQL
                   FETCH C-MOV-DIA
                    INTO :WS-CUENTA, :WS-TIPO, :WS-MONTO,
                         :WS-FECHA-HORA
              END-EXEC
                   EVALUATE SQLCODE
                   WHEN 0
                        MOVE WS-CUENTA TO MOV-CUENTA
                        MOVE WS-TIPO TO MOV-TIPO
                        MOVE WS-MONTO TO MOV-MONTO
                        MOVE WS-FECHA-HORA TO MOV-FECHA-HORA
                        MOVE WS-CUENTA TO WS-CUENTA-EDIT
                        STRING WS-FECHA-HORA WS-CUENTA-EDIT
                           DELIMITED BY SIZE INTO WS-CLAVE
                        MOVE WS-CLAVE TO MOV-CLAVE
                        WRITE MOV-REGISTRO
                        IF WS-FILE-STATUS NOT = '00'
                           DISPLAY 'ERROR WRITE VSAM STATUS='
                                   WS-FILE-STATUS
                           MOVE 8 TO RETURN-CODE
                           MOVE 'S' TO WS-EOF
                        ELSE
                           ADD 1 TO WS-CONTADOR
                           IF WS-TIPO = 'DEPOSITO'
                              ADD WS-MONTO TO WS-DEPOSITOS
                           ELSE
                              ADD WS-MONTO TO WS-RETIROS
                           END-IF
                           MOVE WS-MONTO TO WS-MONTO-EDIT
                           DISPLAY WS-CUENTA
                                   ' '
                                   WS-TIPO
                                   ' '
                                   WS-MONTO-EDIT
                                   ' '
                                   WS-FECHA-HORA
                        END-IF
                   WHEN 100
                        MOVE 'S' TO WS-EOF
                   WHEN OTHER
                        DISPLAY 'ERROR FETCH SQLCODE=' SQLCODE
                        MOVE 8 TO RETURN-CODE
                        MOVE 'S' TO WS-EOF
                   END-EVALUATE
           END-PERFORM

           EXEC SQL CLOSE C-MOV-DIA END-EXEC
           MOVE WS-DEPOSITOS TO WS-MONTO-EDIT
           DISPLAY 'TOTAL DEPOSITOS: ' WS-MONTO-EDIT
           MOVE WS-RETIROS TO WS-MONTO-EDIT
           DISPLAY 'TOTAL RETIROS:   ' WS-MONTO-EDIT
           DISPLAY 'TRANSACCIONES:   ' WS-CONTADOR
           COMPUTE WS-DEPOSITOS = WS-DEPOSITOS - WS-RETIROS
           MOVE WS-DEPOSITOS TO WS-NETO-EDIT
           DISPLAY 'NETO DEL DIA:    ' WS-NETO-EDIT
           CLOSE MOV-VSAM
           GOBACK.
