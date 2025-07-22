'---------------------------------------------------------------------------
'---                                                                     ---
'---                       T E T R 1 S - C L O N                         ---
'---                                                                     ---
'---                 Programado por: Juan Eguia, 2025                    ---
'---                                                                     ---
'===========================================================================
'---                       C O N S T A N T E S                           ---
'---------------------------------------------------------------------------
CONST blanco = _RGB32(245, 245, 245)
CONST gris = _RGB32(70, 75, 75)
CONST negro = _RGB32(5, 5, 5)

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

CONST TILE_X = 30
CONST TILE_Y = 30
CONST NRO_COLUMNAS = 10
CONST NRO_FILAS = 20
CONST RES_X = TILE_X * NRO_COLUMNAS
CONST RES_Y = TILE_Y * NRO_FILAS
CONST FPS = 50

'===========================================================================
'---                      Variables  O B J E T O S
'---------------------------------------------------------------------------
TYPE fondo
    x AS INTEGER
    y AS INTEGER
    ancho AS INTEGER
    alto AS INTEGER
    vacio AS INTEGER
END TYPE

TYPE pieza
    x AS INTEGER
    y AS INTEGER
    ancho AS INTEGER
    alto AS INTEGER
    rotacion AS INTEGER
    id AS INTEGER
    qcolor AS INTEGER
END TYPE

'-----------------------------------------------------------------------
'---      A S I G N A R   E S P A C I O   E N   M E M O R I A        ---
'-----------------------------------------------------------------------
DIM fondo(NRO_COLUMNAS, NRO_FILAS) AS fondo
DIM pieza AS pieza

DIM control_abajo AS _BIT
DIM control_izquierda AS _BIT
DIM control_derecha AS _BIT
DIM control_rotar AS _BIT

DIM a AS INTEGER
DIM b AS INTEGER
DIM ciclos AS INTEGER
DIM cadencia AS INTEGER
DIM gameover AS _BIT
DIM salir AS _BIT

'------------------------------------------------------------------------------------
'---            D A T A   P I E Z A S  (Y ROTACIONES)                             ---
'------------------------------------------------------------------------------------
'--- pieza z + las 3 rotaciones ---
DATA 0,0,0,-1,-1,-1,1,0
DATA 0,0,0,-1,-1,0,-1,1
DATA 0,0,0,-1,-1,-1,1,0
DATA 0,0,0,-1,-1,0,-1,1

'--- pieza s + las 3 rotaciones ---
'--- pieza l + las 3 rotaciones ---
'--- pieza j + las 3 rotaciones ---
'--- pieza o + las 3 rotaciones ---
'--- pieza i + las 3 rotaciones ---
'--- pieza t + las 3 rotaciones ---
'===============================================================
'--------                                               --------
'--------            INICIALIZACION GENERAL             --------
'--------                                               --------
'---------------------------------------------------------------
SCREEN _NEWIMAGE(RES_X * 3, RES_Y, 32)
_TITLE " TetrisClon  by Juan Eguia "
_SCREENMOVE _DESKTOPWIDTH / 2 - _WIDTH / 2, _DESKTOPHEIGHT / 2 - _HEIGHT / 2

_PRINTMODE _KEEPBACKGROUND
RANDOMIZE TIMER

CLS

'updatesSonidos
updatesGenerales

'============================================================
'--------                                            --------
'--------      B U C L E   P R I N C I P A L         --------
'--------                                            --------
'============================================================
DO
    _LIMIT FPS
    'PCopy _Display, 1

    'IF _KEYDOWN(9) THEN cambia_modo cadencia 'Pulsando TAB cambia 2D/3D
    'IF _KEYDOWN(84) OR _KEYDOWN(116) THEN cambia_render cadencia
    IF _KEYDOWN(27) THEN salir = -1

    dibuja_fondo
    leer_teclado_controles
    logica_pieza
    mostrar_marcadores

    ciclos = ciclos + 1

    IF ciclos >= 32000 THEN ciclos = 1
    IF cadencia > 0 THEN cadencia = cadencia - 1

    _DISPLAY
    'PCopy 1, _Display

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

END SUB

'===================================================================
SUB logica_pieza

    SHARED pieza AS pieza

END SUB

'-------------------------------------------------------------------
SUB leer_teclado_controles

    DIM tecla AS LONG

    tecla = _KEYHIT

    'IF tecla = 18432 THEN control_rotar = -1
    'IF tecla = -18432 THEN control_rotar = 0

    IF tecla = 20480 THEN control_abajo = -1
    IF tecla = -20480 THEN control_abajo = 0

    IF tecla = 19200 THEN control_izquierda = -1
    IF tecla = -19200 THEN control_izquierda = 0

    IF tecla = 19712 THEN control_derecha = -1
    IF tecla = -19712 THEN control_derecha = 0

END SUB

'=======================================================================
SUB mostrar_marcadores

    'Shared mostrarFPS As Integer
    SHARED renderTexturas AS _BIT

    'Color amarillo
    'Locate 1, 1
    'Print " Fps: ";

    'Color blanco
    'Print LTrim$(Str$(mostrarFPS))

    COLOR amarillo
    LOCATE 1, 11
    PRINT " TAB: ";

    COLOR blanco
    IF NOT modo THEN PRINT "3D" ELSE PRINT "2D"

    COLOR amarillo
    LOCATE 1, 21
    PRINT " T: ";

    COLOR blanco
    IF NOT renderTexturas THEN PRINT "Texturas ON" ELSE PRINT "Texturas OFF"

    COLOR amarillo
    LOCATE 1, 41
    PRINT " Alt+ENTER: ";

    COLOR blanco
    PRINT "Pantalla Completa"

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

    SHARED pieza AS pieza
    SHARED fondo() AS fondo

    ciclos = 0
    cadencia = 0
    gameover = 0

    instancia_fondo fondo(), pieza
    instancia_pieza pieza

END SUB

'-------------------------------------------------------------------
SUB instancia_fondo (fondo() AS fondo, pieza AS pieza)

    DIM a AS INTEGER

    FOR a = 1 TO 1
    NEXT a

END SUB

'-------------------------------------------------------------------
SUB instancia_pieza (pieza AS pieza)

    jugador.x = TILE_X * 9
    jugador.y = TILE_Y * 5
    jugador.ancho = 6
    jugador.alto = 6

    jugador.anguloRotacion = 40 * (_PI / 180)
    jugador.gira = 0
    jugador.avanza = 0
    jugador.velGiro = 3 * (_PI / 180)
    jugador.velMovimiento = 3

END SUB



