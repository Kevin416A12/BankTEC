.model small 

.data ;Aqui se guardan en memoria los mensajes y el buffer con el arreglo de las cuentas
 menu db 13,10,"Bienvenido a BankTEC, por favor indique su solicitud:",13,10
      db "1. Crear cuenta",13,10
      db "2. Hacer deposito",13,10
      db "3. Hacer retiro",13,10
      db "4. Consultar saldo",13,10
      db "5. Mostrar reporte de cuenta",13,10
      db "6. Desactivar cuenta",13,10
      db "7. Salir",13,10  
      db "-Opcion:",13,10,"$"
 msg1 db "Crear cuenta:$"
 msg2 db "Hacer Deposito$"
 msg3 db "Hacer retiro$"
 msg4 db "Consultar Saldo$"
 msg5 db "Mostrar reporte de cuenta$"
 msg6 db "Desactivar cuenta$"

 msgErr db 13,10,"!Opcion invalida, intente de nuevo$"
  
.code

main proc
    mov ax, @data       ;carga la direccion del segmento en ax
    mov ds, ax          ;ahora ds apunta al segmento donde estan las variables cargados en memoria
                        
    
     
        
    ;Imprime el menu principal y recibe un caracter con el cual se elige una opcion
    menu_principal:
        mov ah, 09h         ; carga la funcion 09h de DOS para imprimir cadena terminada en $
        lea dx, menu        ; carga en DX la direccion donde comienza el mensaje en memoria
        int 21h             ; llamo a DOS para mostrar el mensaje en pantalla
        
        mov ah,01h          ; carga la funcion 01h de DOS para leer un solo caracter, el cual se guarda en al
        int 21h             ; llamo a DOS para leer el mensaje
        

    
    ; En las siguientes lineas se compara el valor del caracter ingresado con la opcion   
        cmp al, '1'
        je opcion1
                  
        cmp al, '2'
        je opcion2
                  
        cmp al, '3'
        je opcion3
     
        cmp al, '4'
        je opcion4
                  
        cmp al, '5'
        je opcion5              
                  
        cmp al, '6'
        je opcion6
        
        cmp al, '7'
        je fin              
    
        
        jmp opcion_invalida ; si no hay resultados, se salta a la etiqueta "opcion_invalida" 
              
    opcion1: 
        call limpiar_pantalla ; limpio la pantalla        
        mov ah, 09h         ; carga la funcion 09h de DOS para imprimir cadena terminada en $
        lea dx, msg1        ; carga en DX la direccion donde comienza el mensaje en memoria
        int 21h             ; llamo a DOS para mostrar el mensaje en pantalla
        jmp fin
             
    opcion2:
        call limpiar_pantalla ; limpio la pantalla        
        mov ah, 09h         ; carga la funcion 09h de DOS para imprimir cadena terminada en $
        lea dx, msg2        ; carga en DX la direccion donde comienza el mensaje en memoria
        int 21h             ; llamo a DOS para mostrar el mensaje en pantalla       
        jmp fin
              
    opcion3:
        call limpiar_pantalla ; limpio la pantalla        
        mov ah, 09h         ; carga la funcion 09h de DOS para imprimir cadena terminada en $
        lea dx, msg3        ; carga en DX la direccion donde comienza el mensaje en memoria
        int 21h             ; llamo a DOS para mostrar el mensaje en pantalla
        jmp fin       
               
    opcion4:
        call limpiar_pantalla ; limpio la pantalla        
        mov ah, 09h         ; carga la funcion 09h de DOS para imprimir cadena terminada en $
        lea dx, msg4        ; carga en DX la direccion donde comienza el mensaje en memoria
        int 21h             ; llamo a DOS para mostrar el mensaje en pantalla
        jmp fin
               
    opcion5:
        call limpiar_pantalla ; limpio la pantalla        
        mov ah, 09h         ; carga la funcion 09h de DOS para imprimir cadena terminada en $
        lea dx, msg5        ; carga en DX la direccion donde comienza el mensaje en memoria
        int 21h             ; llamo a DOS para mostrar el mensaje en pantalla
        jmp fin
              
    opcion6:
        call limpiar_pantalla ; limpio la pantalla        
        mov ah, 09h         ; carga la funcion 09h de DOS para imprimir cadena terminada en $
        lea dx, msg6        ; carga en DX la direccion donde comienza el mensaje en memoria
        int 21h             ; llamo a DOS para mostrar el mensaje en pantalla
        jmp fin
        
    ;Se encarga de limpiar la pantalla y volver a mostrar el menu principal
    opcion_invalida:
        
        call limpiar_pantalla   ; usando call, voy a la etiqueta de "limpiar_pantalla" y vuelvo
        
        mov ah, 09h             ; cargo la funcion 09h de DOS para imprimir cadena terminada en $
        lea dx, msgErr          ; cargo en DX la direccion donde comienza el mensaje en memoria
        int 21h                 ; llamo a DOS para mostrar el mensaje en pantalla
        jmp menu_principal      ; salto de nuevo para imprimir la pantalla principal
          
    ;termina el proceso del programa
    fin:
        mov ah, 4Ch             ; cargo la funcion 4Ch de DOS para retornar al SO
        int 21h                 ; llamo a DOS para salir del programa
    

    
    ;limpia la pantalla y retorna el cursor a la esquina superior izquierda usando la interrupcion de video del BIOS 
    limpiar_pantalla:
        mov ax,0600h  ; cargo en 'ah' la funcion 06(funcion scroll up) y en 'al' la cantidad de linea, en este casoo 00 significa todo
        mov bh,07h    ; cargo en bh el atributo del color para rellenar la pantalla, en este caso 07 es blanco y negro 
        mov cx,0000h  ; cargo la posicion inicial de la limpieza, en 'ch' va la fila y en 'cl' la columna
        mov dx,184Fh  ; cargo la posicion final de la limpieza, en este caso la pantalla es de 80x25 entonces 18h =>24 y 4Fh => 79 
        int 10h       ; llamo la interrupcion de video del BIOS
        
        mov ah,02h    ; cargo en ah la funcion 02(funcion posicionar cursor en pantalla)
        mov bh,00     ; indico cual pagina de video se esta usando, en este caso como imprimimos las cosas con DOS se usa la pagina 0
        mov dh,00     ; indico la fila
        mov dl,00     ; indico la columna
        int 10h       ; llamo la interrupcion de video del BIOS
        
        ret           ; retorno a la linea siguiente de donde fue llamada la funcion 
    
    

    
main endp               ; fin del procedimiento principal
end main                ; punto de entrada del programa
