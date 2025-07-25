'---------------------------------------------------------------------------
'---                                                                     ---
'---                     T E T R 1 S  -  C L O N                         ---
'---                                                                     ---
'---                 Programado por: Juan Eguia, 2025                    ---
'---                                                                     ---
'===========================================================================
'---                       C O N S T A N T E S                           ---
'---------------------------------------------------------------------------
CONST blanco = _RGB32(245, 245, 245)
CONST gris_fondo_ui = _RGB32(99, 99, 99)
CONST gris_borde = _RGB32(132, 132, 132)
CONST negro_vacio = _RGB32(30, 30, 30)
CONST rastro_pieza = _RGB32(133, 128, 11)

CONST amarillo = _RGB32(188, 183, 44)
CONST amarillo_2 = _RGB32(150, 144, 0)

CONST verde = _RGB32(89, 200, 11)
CONST verde_2 = _RGB32(0, 155, 6)

CONST rojo = _RGB32(194, 39, 6)
CONST rojo_2 = _RGB32(139, 17, 0)

CONST azul_osc = _RGB32(17, 11, 139)
CONST azul_osc_2 = _RGB32(0, 0, 67)

CONST azul_cel = _RGB32(11, 161, 194)
CONST azul_cel_2 = _RGB32(17, 105, 139)

CONST rosa = _RGB32(205, 55, 188)
CONST rosa_2 = _RGB32(150, 0, 133)

CONST marron = _RGB32(128, 100, 50)
CONST marron_2 = _RGB32(111, 78, 55)

CONST amarillo_ui = _RGB32(255, 255, 12)

CONST TILE_X = 30
CONST TILE_Y = 30
CONST NRO_COLUMNAS = 10
CONST NRO_FILAS = 20
CONST RES_X = TILE_X * NRO_COLUMNAS
CONST RES_Y = (TILE_Y * NRO_FILAS) + (TILE_Y * 2)
CONST NRO_PIEZAS = 7
CONST CADENCIA_PULSACION = 12
CONST FPS = 50

CONST PIEZA_POS_INICIAL_X = 5
CONST PIEZA_POS_INICIAL_Y = 2

'===========================================================================
'---                      Variables  O B J E T O S
'---------------------------------------------------------------------------
TYPE fondo
    x AS INTEGER
    y AS INTEGER
    vacio_lleno AS INTEGER
END TYPE

TYPE pieza
    x AS INTEGER
    y AS INTEGER
    rotacion AS INTEGER
END TYPE

TYPE raton
    x AS INTEGER
    y AS INTEGER
END TYPE

'-----------------------------------------------------------------------
'---      A S I G N A R   E S P A C I O   E N   M E M O R I A        ---
'-----------------------------------------------------------------------
DIM fondo(NRO_COLUMNAS, NRO_FILAS) AS fondo
DIM pieza AS pieza
DIM SHARED raton AS raton

DIM SHARED control_abajo AS _BIT
DIM SHARED control_izquierda AS _BIT
DIM SHARED control_derecha AS _BIT
DIM SHARED control_rotar AS _BIT

DIM SHARED pieza_actual AS INTEGER
DIM SHARED score AS INTEGER
DIM SHARED record AS INTEGER

DIM a AS INTEGER
DIM b AS INTEGER
DIM SHARED show_valores AS _BIT
DIM ciclos AS INTEGER
DIM SHARED cadencia AS INTEGER
DIM gameover AS _BIT
DIM salir AS _BIT

'====================================================================================
'---            D A T A   P I E Z A S  (Y ROTACIONES)                             ---
'------------------------------------------------------------------------------------
'--- pieza z + las 3 rotaciones ---
pieza_z:
DATA 0,0,0,-1,-1,-1,1,0
DATA 0,0,0,-1,-1,0,-1,1
DATA 0,0,0,-1,-1,-1,1,0
DATA 0,0,0,-1,-1,0,-1,1

'--- pieza s + las 3 rotaciones ---
pieza_s:
DATA 0,0,0,-1,1,-1,-1,0
DATA 0,0,0,1,-1,-1,-1,0
DATA 0,0,0,-1,1,-1,-1,0
DATA 0,0,0,1,-1,-1,-1,0

'--- pieza l + las 3 rotaciones ---
pieza_l:
DATA 0,0,0,-1,0,-2,1,0,
DATA 0,0,-1,0,1,0,1,-1
DATA 0,0,0,-1,0,-2,-1,-2
DATA 0,0,0,-1,1,-1,2,-1

'--- pieza j + las 3 rotaciones ---
pieza_j:
DATA 0,0,1,0,1,-1,1,-2
DATA 0,0,0,-1,-1,-1,-2,-1
DATA 0,0,0,-1,0,-2,1,-2
DATA 0,0,0,-1,1,0,2,0

'--- pieza o + las 3 rotaciones ---
pieza_o:
DATA 0,0,0,-1,1,-1,1,0
DATA 0,0,0,-1,1,-1,1,0
DATA 0,0,0,-1,1,-1,1,0
DATA 0,0,0,-1,1,-1,1,0

'--- pieza i + las 3 rotaciones ---
pieza_i:
DATA 0,0,-1,0,1,0,2,0
DATA 0,0,0,-1,0,-2,0,-3
DATA 0,0,-1,0,1,0,2,0
DATA 0,0,0,-1,0,-2,0,-3

'--- pieza t + las 3 rotaciones ---
pieza_t:
DATA 0,0,0,-1,-1,0,1,0
DATA 0,0,0,-1,0,-2,-1,-1
DATA 0,0,-1,0,1,0,0,1
DATA 0,0,0,-1,0,-2,1,-1

'===============================================================
'--------                                               --------
'--------            INICIALIZACION GENERAL             --------
'--------                                               --------
'---------------------------------------------------------------
SCREEN _NEWIMAGE(RES_X * 3, RES_Y, 32)
_TITLE " TETRIS CLON  By Juan Eguia "
_SCREENMOVE _DESKTOPWIDTH / 2 - _WIDTH / 2, _DESKTOPHEIGHT / 2 - _HEIGHT / 2

_PRINTMODE _KEEPBACKGROUND
RANDOMIZE TIMER

CLS
LINE (0, 0)-(RES_X * 3, RES_Y), gris_fondo_ui, BF

'updatesSonidos
updatesGenerales

'============================================================
'--------               SORTEAR PIEZA                --------
'------------------------------------------------------------
pieza_actual = INT(RND * NRO_PIEZAS)

'============================================================
'--------                                            --------
'--------      B U C L E   P R I N C I P A L         --------
'--------                                            --------
'============================================================
DO
    _LIMIT FPS
    PCOPY _DISPLAY, 1

    '---------------------------------------------
    ' LEER TECLADO (ESC, TAB) Y RATON
    '---------------------------------------------
    IF _KEYDOWN(27) THEN salir = -1
    IF _KEYDOWN(9) THEN show_valores = show_valores + 1

    WHILE _MOUSEINPUT
        raton.x = _MOUSEX
        raton.y = _MOUSEY

        IF _MOUSEBUTTON(1) OR _MOUSEBUTTON(2) THEN
        END IF
    WEND

    '------------ LLAMADAS A SUBS -----------------
    dibuja_fondo
    leer_teclado_controles
    logica_pieza
    mostrar_marcadores

    '-------------- CONTADORES -------------------
    ciclos = ciclos + 1

    IF ciclos >= 32000 THEN ciclos = 1
    IF cadencia > 0 THEN cadencia = cadencia - 1

    _DISPLAY
    PCOPY 1, _DISPLAY

LOOP UNTIL gameover OR salir

'===================================================================
'---                   F I N   P R O G R A M A                   ---
'===================================================================
'salir
BEEP
SYSTEM

'===================================================================
'---                                                             ---
'---                    S U B R U T I N A S                      ---
'---                                                             ---
'-------------------------------------------------------------------
SUB dibuja_fondo

    DIM x AS INTEGER
    DIM y AS INTEGER
    DIM fondo_grid_x AS INTEGER
    DIM fondo_grid_y AS INTEGER

    SHARED fondo() AS fondo

    '----------- ADORNOS ZONA PIEZAS (BORDES Y ZONA SUPERIOR) --------------
    LINE (TILE_X, 0)-(TILE_X * (NRO_COLUMNAS + 1), TILE_Y), negro_vacio, BF

    LINE (TILE_X - 2, 0)-(TILE_X - 1, (TILE_Y * (NRO_FILAS + 1)) + 1), gris_borde, BF
    LINE -((TILE_X * (NRO_COLUMNAS + 1)) + 2, (TILE_Y * (NRO_FILAS + 1)) + 2), gris_borde, BF
    LINE -((TILE_X * (NRO_COLUMNAS + 1)) + 1, 0), gris_borde, BF
    'fondo(1, 20).vacio_lleno = 5

    '-------------------- DIBUJA ZONA PIEZAS (FONDO) -----------------------
    FOR y = 1 TO NRO_FILAS
        FOR x = 1 TO NRO_COLUMNAS

            fondo_grid_x = x * TILE_X
            fondo_grid_y = y * TILE_Y

            IF fondo(x, y).vacio_lleno <> 0 THEN
                LINE (fondo_grid_x, fondo_grid_y)-(fondo_grid_x + TILE_X, fondo_grid_y + TILE_Y), rastro_pieza, BF
            ELSE
                LINE (fondo_grid_x, fondo_grid_y)-(fondo_grid_x + TILE_X, fondo_grid_y + TILE_Y), negro_vacio, BF
            END IF

        NEXT x
    NEXT y

END SUB

'===================================================================
SUB leer_teclado_controles

    DIM tecla AS LONG

    tecla = _KEYHIT

    IF tecla = 32 THEN control_rotar = -1
    IF tecla = -32 THEN control_rotar = 0

    IF tecla = 20480 THEN control_abajo = -1
    IF tecla = -20480 THEN control_abajo = 0

    IF tecla = 19200 THEN control_izquierda = -1
    IF tecla = -19200 THEN control_izquierda = 0

    IF tecla = 19712 THEN control_derecha = -1
    IF tecla = -19712 THEN control_derecha = 0

    IF tecla = 13 THEN
        pieza_actual = INT(RND * NRO_PIEZAS)
    END IF

    'IF tecla <> 0 THEN PRINT tecla

END SUB

'===================================================================
SUB logica_pieza

    DIM a AS INTEGER
    DIM x AS INTEGER
    DIM y AS INTEGER

    DIM pieza_grid_x AS INTEGER
    DIM pieza_grid_y AS INTEGER

    SHARED pieza AS pieza

    '------------------------------------------------
    mover_pieza
    rotar_pieza
    seleccionar_data_pieza

    ' SELECCIONAR ROTACION (IR HASTA EL DATA CORRESPONDIENTE):
    FOR a = 0 TO (pieza.rotacion * 4) - 1
        READ x, y
    NEXT a

    '-------------- DIBUJAR LA PIEZA ----------------
    FOR a = 1 TO 4
        READ x, y

        pieza_grid_x = (pieza.x + x) * TILE_X
        pieza_grid_y = (pieza.y + y) * TILE_Y

        dibujar_pieza_y_selecc_color pieza_grid_x, pieza_grid_y
    NEXT a

END SUB

'=======================================================================
SUB mover_pieza

    SHARED pieza AS pieza

    IF cadencia > 0 THEN EXIT SUB

    IF control_izquierda THEN
        cadencia = CADENCIA_PULSACION
        pieza.x = pieza.x - 1

        IF check_colision_pieza THEN pieza.x = pieza.x + 1

        EXIT SUB
    END IF

    IF control_derecha THEN
        cadencia = CADENCIA_PULSACION
        pieza.x = pieza.x + 1

        IF check_colision_pieza THEN pieza.x = pieza.x - 1

        EXIT SUB
    END IF

END SUB

'=======================================================================
SUB rotar_pieza

    SHARED pieza AS pieza

    IF cadencia > 0 THEN EXIT SUB

    IF control_rotar THEN

        cadencia = CADENCIA_PULSACION
        backup_rotacion = pieza.rotacion
        pieza.rotacion = pieza.rotacion + 1

        IF pieza.rotacion >= 4 THEN pieza.rotacion = 0

        IF check_colision_pieza THEN pieza.rotacion = backup_rotacion

    END IF

END SUB

'=======================================================================
SUB seleccionar_data_pieza

    SELECT CASE pieza_actual
        CASE 0: RESTORE pieza_z
        CASE 1: RESTORE pieza_s
        CASE 2: RESTORE pieza_l
        CASE 3: RESTORE pieza_j
        CASE 4: RESTORE pieza_o
        CASE 5: RESTORE pieza_i
        CASE 6: RESTORE pieza_t
        CASE ELSE: RESTORE pieza_z
    END SELECT

END SUB

'=======================================================================
SUB dibujar_pieza_y_selecc_color (pieza_grid_x AS INTEGER, pieza_grid_y AS INTEGER)

    DIM x AS INTEGER
    DIM y AS INTEGER

    x = pieza_grid_x
    y = pieza_grid_y

    SELECT CASE pieza_actual
        CASE 0: LINE (x, y)-(x + TILE_X, y + TILE_Y), marron, BF
        CASE 1: LINE (x, y)-(x + TILE_X, y + TILE_Y), rosa, BF
        CASE 2: LINE (x, y)-(x + TILE_X, y + TILE_Y), amarillo, BF
        CASE 3: LINE (x, y)-(x + TILE_X, y + TILE_Y), azul_cel, BF
        CASE 4: LINE (x, y)-(x + TILE_X, y + TILE_Y), azul_osc, BF
        CASE 5: LINE (x, y)-(x + TILE_X, y + TILE_Y), rojo, BF
        CASE 6: LINE (x, y)-(x + TILE_X, y + TILE_Y), verde, BF
        CASE ELSE: LINE (x, y)-(x + TILE_X, y + TILE_Y), rojo, BF
    END SELECT

END SUB

'=======================================================================
FUNCTION check_colision_pieza

    DIM a AS INTEGER
    DIM x AS INTEGER
    DIM y AS INTEGER

    SHARED pieza AS pieza
    SHARED fondo() AS fondo

    check_colision_pieza = 0
    seleccionar_data_pieza

    FOR a = 1 TO 4
        READ x, y

        IF pieza.x + x > NRO_COLUMNAS OR pieza.x + x < 1 OR pieza.y + y > NRO_FILAS OR pieza.y + y < 1 THEN
            check_colision_pieza = -1
            EXIT SUB
        END IF

        IF fondo(pieza.x + x, pieza.y + y).vacio_lleno <> 0 THEN
            check_colision_pieza = -1
            EXIT SUB
        END IF
    NEXT a

END FUNCTION

'=======================================================================
SUB mostrar_marcadores

    COLOR amarillo_ui
    LOCATE 3, 50
    PRINT " Score:   ";

    COLOR blanco
    PRINT USING "###"; score

    COLOR amarillo_ui
    LOCATE 6, 50
    PRINT " Record:  ";

    COLOR blanco
    PRINT USING "###"; record

    COLOR amarillo_ui
    LOCATE 10, 50
    PRINT " Alt+ENTER: ";

    COLOR blanco
    PRINT "Pantalla Completa"

    IF show_valores / 2 <> INT(show_valores / 2) THEN
        LOCATE 18, 60
        PRINT raton.x; ":"; raton.y; ":";
        PRINT POINT(raton.x, raton.y)

        LOCATE 20, 60
        PRINT "Cadencia: "; cadencia
    END IF

END SUB

'=======================================================================
SUB soniquete (uno AS INTEGER, dos AS INTEGER)

    DIM a AS INTEGER
    FOR a = uno TO dos STEP 50
        SOUND a, 0.2
    NEXT a

END SUB

'===================================================================
SUB updatesGenerales

    SHARED ciclos AS INTEGER
    SHARED cadencia AS INTEGER
    SHARED gameover AS _BIT
    SHARED salir AS _BIT

    SHARED pieza AS pieza
    SHARED fondo() AS fondo

    show_valores = 0
    ciclos = 0
    cadencia = 0
    gameover = 0
    salir = 0

    control_abajo = 0
    control_izquierda = 0
    control_derecha = 0
    control_rotar = 0

    instancia_fondo fondo()
    instancia_pieza pieza

END SUB

'-------------------------------------------------------------------
SUB instancia_fondo (fondo() AS fondo)

    DIM x AS INTEGER
    DIM y AS INTEGER

    FOR y = 1 TO NRO_FILAS
        FOR x = 1 TO NRO_COLUMNAS
            fondo(x, y).vacio_lleno = 0
        NEXT x
    NEXT y

END SUB

'-------------------------------------------------------------------
SUB instancia_pieza (pieza AS pieza)

    pieza.x = PIEZA_POS_INICIAL_X
    pieza.y = PIEZA_POS_INICIAL_Y
    pieza.rotacion = 0

END SUB



