           EXEC SQL
                UPDATE Z83078.CUENTAS
                   SET SALDO = SALDO + :WS-MONTO
                 WHERE NRO_CUENTA = :WS-NRO-CUENTA
                            AND NRO_TITULAR = :SESSION-TITULAR
           END-EXEC.

           IF SQLCODE = 0 AND SQLERRD(3) = 1
              EXEC SQL
                   INSERT INTO Z83078.MOVIMIENTOS
                    (NRO_CUENTA, TIPO_MOV, MONTO, FECHA_HORA)
                  VALUES (:WS-NRO-CUENTA, :WS-TIPO-MOV,
                           :WS-MONTO, CURRENT TIMESTAMP)
              END-EXEC
              IF SQLCODE NOT = 0
                 EXEC CICS SYNCPOINT ROLLBACK
                      END-EXEC
              END-IF
           ELSE
              IF SQLCODE = 0
                 MOVE 100 TO SQLCODE
               ELSE
                  EXEC CICS SYNCPOINT ROLLBACK
                       END-EXEC
              END-IF
           END-IF.