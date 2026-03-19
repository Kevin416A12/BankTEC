.model small 

.data ;Aqui se guardan en memoria los mensajes y el buffer con el arreglo de las cuentas
 menu db 13,10,"Bienvenido a BankTEC, por favor indique su solicitud:",13,10
      db "1. Crear cuenta",13,10
      db "2. Hacer deposito",13,10
      db "3. Hacer retiro",13,10
      db "4. Consultar saldo",13,10
      db "5. Mostrar reporte de cuentas",13,10
      db "6. Desactivar cuenta",13,10
      db "7. Salir",13,10  
      db "-Opcion:",13,10,"$"
 msg1 db "Crear cuenta:$"
 msg2 db "Hacer Deposito$"
 msg3 db "Hacer retiro$"
 msg4 db "Consultar Saldo$"
 msg5 db "Mostrar reporte de cuentas$"
 msg6 db "Desactivar cuenta$"

 msgErr db 13,10,"!Opcion invalida, intente de nuevo$" 
 msgSinCuenta db 13, 10, "La cuenta no existe, intente nuevamente$"  
 msgErrorNumero db 13,10,"Entrada invalida$" 
 msgVacio db 13,10,"No puede dejar el campo vacio$"
 
 msgPedirNumero   db 13,10,"Ingrese el numero de cuenta: $"
 msgCuentaExiste  db 13,10,"Ese numero de cuenta ya existe$"
 msgCuentaCreada  db 13,10,"Cuenta creada correctamente y su numero de cuenta es $"
 msgCuentaLlena   db 13,10,"Ya no se pueden crear mas cuentas$"
 
 msgPedirDeposito   db 13,10,"Ingrese el numero de cuenta para depositar: $"
 msgPedirMonto      db 13,10,"Ingrese el monto a depositar: $"
 msgDepositoExito   db 13,10,"Deposito realizado correctamente$"
 msgMontoInvalido   db 13,10,"El monto debe ser mayor que cero$"  
 
 msgPedirConsulta  db 13,10,"Ingrese el numero de cuenta a consultar: $"
 msgSaldoActual    db 13,10,"El saldo actual es: $"
                                                      
         
 msgPedirRetiro      db 13,10,"Ingrese el numero de cuenta para retirar: $"
 msgPedirMontoRet    db 13,10,"Ingrese el monto a retirar: $"
 msgRetiroExito      db 13,10,"Retiro realizado correctamente$"
 msgFondosInsuf      db 13,10,"Fondos insuficientes$"
 msgOverflow db 13,10, "Saldo demasiado grande para mostrar$"
 msgFormatoMonto db 13,10, "Ingrese monto sin punto (ej: 12345678 = 1234.5678)$" 
 msgSaldoTotal db 13, 10, "El saldo total del banco es: $"
 
 msgActiva db " Activa$"
 msgInactiva db " Inactiva$" 
 
 msgCuentaActivada db 13,10,"Cuenta activada$"
 msgCuentaDesactivada db 13,10,"Cuenta desactivada$"
 msgCuentaInactiva db 13,10,"Cuenta inactiva$" 
 
 msgHeader db 13,10,"Cuenta   Nombre               Saldo   Estado",13,10,"------------------------------------------------",13,10,"$"
 msgLinea  db 13,10,"------------------------",13,10,"$"
 msgTotal  db "Total: $"
 
 msgPedirNombre   db 13,10,"Ingrese el nombre del titular: $"

 
 
 ; La estructura de datos suma 27 bytes en total por cuenta, sin embargo se redondeara a 32 para mayor facilidad
 ; Con un total de 10 cuentas se reservaran 320 bytes de memoria en total.     
 
 max_cuentas equ 10
 tam_cuenta equ 32
 
 cuentas db 320 dup(?) 
 
 contador_cuentas db 0 
 
 numero_buscado dw 0
 
 buffer_numero db 10
               db ?
               db 10 dup(?)  ; Reserva un arreglo de 5 bits sin inicializar para que se puedan utilizar 4 decimales + el bit de ENTER             
 
 ; Segun la especificacion, las cuentas bancarias se manejaran de la siguiente manera 
 ; Variable                     Offset (en bytes)
 
 ; Numero de cuenta             0 
 ; Nombre                       2
 ; Saldo                        22
 ; Estado                       26
 
buffer_nombre    db 21        ; maximo 20 caracteres + ENTER
                 db ?
                 db 21 dup(?) ; buffer de 21 bytes                    
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
        
        xor cx, cx
        mov cl, contador_cuentas ; carga el contador en el regitro cx
        mov si, 0
        

    
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
        call crear_cuenta            
        jmp menu_principal
             
    opcion2:
        call limpiar_pantalla   ;limpia la pantalla
        call depositar          ;llama a la funcion depositar
        jmp menu_principal
              
    opcion3:
        call limpiar_pantalla
        call retirar
        jmp menu_principal     
               
    opcion4:
        call limpiar_pantalla
        call consultar_saldo
        jmp menu_principal
               
    opcion5:
        call limpiar_pantalla ; limpio la pantalla        
        call reporte_cuentas
        jmp menu_principal
              
    opcion6:
        call limpiar_pantalla ; limpio la pantalla        
        call cambiar_estado
        jmp menu_principal
        
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



; ----------------------
; Procedimientos
; ---------------------- 

                         

; Util para depositar, retirar y consultar saldo.                    
buscar_cuenta proc
    push bx 
    push cx       ; Anade los registros a la pila
    push dx
    push si
    
    xor cx, cx
    mov cl, contador_cuentas  
    cmp cl, 0                ; Caso base, si no la encuentra
    je no_encontrada
    
    xor si, si               ; Deja en 0 el registro SI
    mov numero_buscado, ax 
    
    
; implementa la busqueda lineal en la estructura de datos
buscar_loop:  
    mov bx, si
    shl bx, 5 
    
    mov dx, word ptr [cuentas + bx] ; en DX se encuentra el resultado de la cuenta actual mas el offset requerido
    cmp dx, numero_buscado ; compara si DX es igual al numero buscado y salta de serlo
    je encontrada
        
        
    inc si
    loop buscar_loop     ; de lo contrario continua la iteracion
    
     
no_encontrada:
    stc    
    jmp salir


encontrada:
    clc
    mov ax, bx ; devuelve el offset    
         

salir:
    pop si
    pop dx
    pop cx
    pop bx
    ret 
    
buscar_cuenta endp  
; Como usarlo

; mov ax, numero_de_cuenta
; call buscar_cuenta

; AX devuelve el offset de la cuenta encontrada
; ese offset se usa con:
; cuentas + AX + offset_del_campo



; Procedimiento que permite leer numeros enteros de hasta 4 digitos; manejo de ASCII
leer_numero proc
    push bx 
    push cx
    push dx
    push si
    
    mov ah, 0ah
    lea dx, buffer_numero
    int 21h
    
    xor ax, ax
    xor bx, bx
    
    lea si, buffer_numero+2
    mov cl, buffer_numero+1
    xor ch, ch      
    
    cmp cx,0
    je error_vacio     ; Error cuando hay un enter vacio
    
convertir_loop:
    xor bx, bx
    mov bl, [si] 
               
    cmp bl,'0'
    jb error

    cmp bl,'9' 
    ja error   
    
    sub bl, '0'
    
    mov dx, 10
    mul dx  ; multiplica el valor de AX por 10  y luego lo suma
                                 
    add ax, bx 
    
    inc si 
    loop convertir_loop
     
    clc
    pop si
    pop dx
    pop cx
    pop bx
    ret    
    
    
error:
    mov ah,09h
    lea dx,msgErrorNumero
    int 21h
    stc 
    
    pop si
    pop dx
    pop cx
    pop bx
    ret   
    
    
error_vacio:
    mov ah,09h
    lea dx,msgVacio
    int 21h
    stc

    pop si
    pop dx
    pop cx
    pop bx
    ret
    
   
leer_numero endp


; Como usarlo

; call leer_numero
; mov numero_buscado,ax

; call buscar_cuenta

; jc cuenta_no_existe 
; cuenta_no_existe.   
                    
crear_cuenta proc
    push ax
    push bx
    push cx
    push dx

    
    mov al, contador_cuentas    
    cmp al, max_cuentas         ; Verifica si ya se llego al maximo de cuentas
    je cuentas_llenas

    
    ; generar numero automatico
    xor ax, ax
    mov al, contador_cuentas
    inc ax                  ; cuentas empiezan en 1

    mov numero_buscado, ax

    
    xor bx, bx
    mov bl, contador_cuentas    ; Calcula offset de la nueva cuenta
    shl bx, 5

    
    mov ax, numero_buscado      ; Guarda numero de cuenta
    mov word ptr [cuentas + bx], ax
    
    
    mov ah, 09h
    lea dx, msgPedirNombre
    int 21h

    ; Leer nombre con funcion 0Ah (entrada con buffer)
    mov ah, 0Ah
    lea dx, buffer_nombre
    int 21h

    ; Copiar nombre al campo offset+2 de la cuenta
    ; bx ya tiene el offset de la cuenta (ej: 0, 32, 64...)
    lea si, buffer_nombre + 2   ; SI apunta al texto ingresado
    xor ch, ch
    mov cl, buffer_nombre + 1   ; CL = cantidad real de caracteres leidos
    
    cmp cx, 0
    je nombre_vacio             ; si no escribio nada, saltar

    lea di, cuentas             ; DI apunta al arreglo de cuentas
    add di, bx                  ; DI apunta al inicio de esta cuenta
    add di, 2                   ; DI ahora apunta al campo Nombre (offset 2)

copiar_nombre:
    mov al, [si]
    mov [di], al
    inc si
    inc di
    loop copiar_nombre

    jmp nombre_ok

nombre_vacio:
    ; Guardar un espacio o dejar en 0 si no escribio nada (opcional)
    lea di, cuentas
    add di, bx
    add di, 2
    mov byte ptr [di], 0        ; primer byte del nombre = null

nombre_ok:
    
    
    
    
    
    
    
    
    

    mov word ptr [cuentas + bx + 22], 0 ; Saldo inicial = 0
    mov word ptr [cuentas + bx + 24], 0

    
    mov byte ptr [cuentas + bx + 26], 1 ; Estado = activa

  
    inc contador_cuentas        ; Aumenta contador

    
    mov ah, 09h
    lea dx, msgCuentaCreada     ; Mensaje de exito
    int 21h 
    mov ax, numero_buscado
    call imprimir_numero
    
    jmp salir_crear

cuenta_ya_existe:
    mov ah, 09h
    lea dx, msgCuentaExiste
    int 21h
    jmp salir_crear

cuentas_llenas:
    mov ah, 09h
    lea dx, msgCuentaLlena
    int 21h

salir_crear:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
crear_cuenta endp 
; Como usarlo

; call crear_cuenta

; pide el numero de cuenta
; verificar si ya existe
; crear la cuenta si es valida



depositar proc
    push ax
    push bx
    push cx
    push dx

    
    mov ah, 09h
    lea dx, msgPedirDeposito    ; Pedir numero de cuenta
    int 21h

    
    call leer_numero            ; Leer numero de cuenta
    jc salir_depositar

   
    call buscar_cuenta          ; Buscar cuenta
    jc cuenta_no_existe        

    
    mov bx, ax                  ; AX tiene el offset de la cuenta encontrada

    
    mov ah, 09h
    lea dx, msgPedirMonto       ; Pedir monto
    int 21h

                                ; Leer monto
    call leer_numero
    jc salir_depositar

    
    cmp ax, 0                   ; Validar que sea mayor que 0
    je monto_invalido

    
    add word ptr [cuentas + bx + 22], ax ; Sumar monto al saldo

    
    mov ah, 09h
    lea dx, msgDepositoExito   ; Mensaje de exito
    int 21h
    jmp salir_depositar

cuenta_no_existe:
    mov ah, 09h
    lea dx, msgSinCuenta       ;Mensaje cuenta no existe
    int 21h
    jmp salir_depositar

monto_invalido:
    mov ah, 09h
    lea dx, msgMontoInvalido   ;Mensaje monto invalido
    int 21h

salir_depositar:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
depositar endp  

; Como usarlo

; call depositar

; pide numero de cuenta
; verificar si existe
; pedir monto
; sumar el monto al saldo


retirar proc
    push ax
    push bx
    push cx
    push dx

    
    mov ah, 09h
    lea dx, msgPedirRetiro    ; Pedir numero de cuenta
    int 21h

    
    call leer_numero          ; Leer numero de cuenta
    jc salir_retirar

    
    call buscar_cuenta        ; Buscar cuenta
    jc cuenta_no_existe_retiro

    
    mov bx, ax                ; AX tiene el offset de la cuenta encontrada

    
    mov ah, 09h
    lea dx, msgPedirMontoRet  ; Pedir monto a retirar
    int 21h

    
    call leer_numero          ; Leer monto
    jc salir_retirar

    
    cmp ax, 0
    je monto_invalido_retiro  ; Validar que sea mayor que 0

    
    cmp ax, word ptr [cuentas + bx + 22]  ; Comparar monto con saldo actual
    ja fondos_insuficientes

    
    sub word ptr [cuentas + bx + 22], ax ; Restar monto al saldo

    
    mov ah, 09h
    lea dx, msgRetiroExito    ; Mensaje de exito
    int 21h
    jmp salir_retirar

cuenta_no_existe_retiro:
    mov ah, 09h
    lea dx, msgSinCuenta
    int 21h
    jmp salir_retirar

monto_invalido_retiro:
    mov ah, 09h
    lea dx, msgMontoInvalido
    int 21h
    jmp salir_retirar

fondos_insuficientes:
    mov ah, 09h
    lea dx, msgFondosInsuf
    int 21h

salir_retirar:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
retirar endp   
; Como usarlo

; call retirar

; El procedimiento se encarga de:
; - pedir numero de cuenta
; - verificar si existe
; - pedir monto
; - validar que haya saldo suficiente
; - restar el monto

; No devuelve valores, solo modifica memoria y muestra mensajes



consultar_saldo proc
    push ax
    push bx
    push cx
    push dx

    
    mov ah, 09h
    lea dx, msgPedirConsulta   ; Pedir numero de cuenta
    int 21h

    
    call leer_numero           ;Leer numero de cuenta
    jc salir_consulta

    
    call buscar_cuenta         ; Buscar cuenta
    jc cuenta_no_existe_consulta

    
    mov bx, ax                 ; AX tiene el offset de la cuenta encontrada

    
    mov ah, 09h
    lea dx, msgSaldoActual     ; Mostrar mensaje
    int 21h

    
    mov ax, word ptr [cuentas + bx + 22]  ; Cargar saldo en AX

    
    call imprimir_numero      ; Imprimir saldo

    jmp salir_consulta

cuenta_no_existe_consulta:
    mov ah, 09h
    lea dx, msgSinCuenta
    int 21h

salir_consulta:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
consultar_saldo endp
; Como usarlo

; call consultar_saldo

; El procedimiento se encarga de:
; - pedir numero de cuenta
; - verificar si existe
; - imprimir el saldo usando imprimir_numero               
                
                

imprimir_numero proc
    push ax
    push bx
    push cx
    push dx

    cmp ax, 0
    jne convertir

    mov dl, '0'
    mov ah, 02h
    int 21h
    jmp terminar_imprimir

convertir:
    mov cx, 0
    mov bx, 10

ciclo_convertir:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne ciclo_convertir

imprimir:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop imprimir

terminar_imprimir:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
imprimir_numero endp


; Como usarlo

; mov ax, numero
; call imprimir_numero

; Imprime el numero contenido en AX en pantalla  




saldo_total proc 
    push bx
    push cx
    push dx
    push si
    
    xor ax, ax    ; acumulador total = 0 
    
    lea di, cuentas ; pointer a las cuentas
    
    xor cx, cx
    mov cl, contador_cuentas  
    
    xor si, si
    
sumar_loop:
             
    cmp cx, 0
    je fin_st
    
    mov bx, si ; saldo de la cuenta
    shl bx, 5       ; acumular          
                                            
    add ax, word ptr [cuentas + bx + 22]
    
    inc si
    dec cx
    jmp sumar_loop
    
fin_st: 
    ; resultado queda en AX
    pop si
    pop dx
    pop cx
    pop bx    
    
    ret
    
saldo_total endp

; Se usa llamando a saldo_total y luego a imprimir saldo

reporte_cuentas proc
    push ax
    push bx
    push cx
    push dx
    push si

    mov cl, contador_cuentas
    xor ch, ch
    xor si, si
    
    mov ah,09h
    lea dx,msgHeader
    int 21h

reporte_loop:

    cmp cx,0 
    je fin_reporte

    ; calcular offset
    mov bx, si
    shl bx,5

    ; imprimir numero de cuenta
    mov ax, word ptr [cuentas + bx]
    call imprimir_numero 
    
    ; espacios para alinear
    mov ah,02h
    mov dl,' '
    int 21h
    mov dl,' '
    int 21h
    mov dl,' '
    int 21h
    
    
 ; imprimir nombre del titular
    push cx                     ; guardar contador del loop
                            
    lea di, cuentas
    add di, bx
    add di, 2                   ; DI apunta al campo Nombre

    mov cx, 20                  ; maximo 20 caracteres

imprimir_nombre_loop:
    mov al, [di]
    cmp al, 0                   ; si encuentra null, terminar nombre
    je rellenar_espacios
    cmp al, 13                  ; si encuentra CR, terminar nombre
    je rellenar_espacios

    mov ah, 02h
    mov dl, al
    int 21h

    inc di
    dec cx
    jnz imprimir_nombre_loop
    jmp nombre_impreso

rellenar_espacios:              ; rellenar con espacios para alinear columnas
    cmp cx, 0
    je nombre_impreso
    mov ah, 02h
    mov dl, ' '
    int 21h
    dec cx
    jmp rellenar_espacios

nombre_impreso:
    pop cx 
    mov ah,02h
    mov dl,' '
    int 21h
    mov dl,' '
    int 21h
    mov dl,' '
    int 21h 
    mov dl,' '
    int 21h 
    mov dl,' '
    int 21h 
    mov dl,' '
    int 21h 
    mov dl,' '
    int 21h    
    
    
   
    ; imprimir saldo    
    mov ax, word ptr [cuentas + bx + 22]
    call imprimir_numero 
    
    mov ah,02h
    mov dl,' '
    int 21h
    mov dl,' '
    int 21h
    mov al, byte ptr [cuentas + bx + 26]

    cmp al,1
    je es_activa

    ; inactiva
    mov ah,09h
    lea dx,msgInactiva
    int 21h
    jmp continuar

    es_activa:
    mov ah,09h
    lea dx,msgActiva
    int 21h

    ; salto de linea
    mov ah,02h
    mov dl,13
    int 21h
    mov dl,10
    int 21h
    
continuar:

    inc si
    loop reporte_loop

fin_reporte:     

    mov ah,02h
    mov dl,13
    int 21h
    mov dl,10
    int 21h

    ; calcular saldo total
    call saldo_total

    ; imprimir mensaje
    mov bx, ax
    mov ah, 09h
    lea dx, msgSaldoTotal
    int 21h
    
    mov ax, bx
    ; imprimir total
    call imprimir_numero

    mov ah,02h
    mov dl,13
    int 21h
    mov dl,10
    int 21h
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
    
reporte_cuentas endp 


cambiar_estado proc
    push ax
    push bx
    push cx
    push dx

    ; pedir cuenta
    mov ah,09h
    lea dx,msgPedirConsulta
    int 21h

    call leer_numero
    jc salir_cam_es

    call buscar_cuenta
    jc no_existe

    mov bx,ax

    ; leer estado actual
    mov al, byte ptr [cuentas + bx + 26]

    cmp al,1
    je desactivar

activar:
    mov al,1
    mov byte ptr [cuentas + bx + 26],al

    mov ah,09h
    lea dx,msgCuentaActivada
    int 21h
    jmp salir_cam_es

desactivar:
    mov al,0
    mov byte ptr [cuentas + bx + 26],al

    mov ah,09h
    lea dx,msgCuentaDesactivada
    int 21h
    jmp salir_cam_es

no_existe:
    mov ah,09h
    lea dx,msgSinCuenta
    int 21h

salir_cam_es:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
cambiar_estado endp 
                 

    
end main                ; punto de entrada del programa