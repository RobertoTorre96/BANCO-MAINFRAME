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

           IF SESSION-STATE NOT = 'C' AND
              SESSION-STATE NOT = 'M'
              EXEC CICS RETURN
                   TRANSID('BLOG')
                   END-EXEC
           ELSE
              IF EIBCALEN = 0 OR SESSION-STATE = 'C'
                 MOVE LOW-VALUES TO CONMAPO
                 MOVE 'Ingrese el numero de cuenta' TO MENSAJEO
                 MOVE 'M' TO SESSION-STATE
                 EXEC CICS SEND MAP('CONMAP')
                      MAPSET('CONSET')
                      ERASE
                      RESP(WS-RESP)
                      END-EXEC
              ELSE
                 EXEC CICS RECEIVE MAP('CONMAP')
                      MAPSET('CONSET')
                      RESP(WS-RESP)
                      END-EXEC

                 IF EIBAID = DFHPF3
                    EXEC CICS SEND CONTROL
                         ERASE
                         END-EXEC
                    EXEC CICS RETURN
                         TRANSID('BMEN')
                         COMMAREA(DFHCOMMAREA)
                         LENGTH(56)
                         END-EXEC
                 ELSE
                    IF NROCUENTAI NOT = LOW-VALUES AND
                       NROCUENTAI NOT = SPACES

                       COMPUTE WS-NRO-CUENTA = FUNCTION NUMVAL
                          (NROCUENTAI)

      *             --- LLAMADA SEGURA AL COPY SQL ---
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
                         END-EXEC
                 END-IF
              END-IF
           END-IF.

           EXEC CICS RETURN
                TRANSID('BCON')
                COMMAREA(DFHCOMMAREA)
                LENGTH(56)
                END-EXEC.

      * --- PÁRRAFO AISLADO PARA EL SQL ---
       100-CONSULTAR-DB2.
           COPY BCPCON.
           EXIT.