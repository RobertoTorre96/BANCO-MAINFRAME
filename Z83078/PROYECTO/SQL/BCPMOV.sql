                 MOVE 'N' TO WS-HAY-MOV.
                 EXEC SQL
                          DECLARE C-MOVIMIENTOS CURSOR FOR
                          SELECT TIPO_MOV, MONTO, FECHA_HORA
                              FROM Z83078.MOVIMIENTOS
                                                                  WHERE NRO_CUENTA = :WS-NRO-CUENTA
                                                                       AND NRO_TITULAR = :SESSION-TITULAR
                           ORDER BY FECHA_HORA DESC
                 END-EXEC.
                 EXEC SQL
                          OPEN C-MOVIMIENTOS
                 END-EXEC.
                 IF SQLCODE = 0
                      PERFORM 110-LEER-MOVIMIENTO
                      MOVE WS-MOV-OUT TO MOVIM1O
                      PERFORM 110-LEER-MOVIMIENTO
                      MOVE WS-MOV-OUT TO MOVIM2O
                      PERFORM 110-LEER-MOVIMIENTO
                      MOVE WS-MOV-OUT TO MOVIM3O
                      PERFORM 110-LEER-MOVIMIENTO
                      MOVE WS-MOV-OUT TO MOVIM4O
                      EXEC SQL
                               CLOSE C-MOVIMIENTOS
                      END-EXEC
                      IF WS-HAY-MOV = 'S'
                           MOVE 0 TO SQLCODE
                      ELSE
                           MOVE 100 TO SQLCODE
                      END-IF
                 END-IF.