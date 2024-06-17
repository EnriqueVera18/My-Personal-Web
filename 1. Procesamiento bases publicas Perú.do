
clear all
set more off, perm
set max_memory 100g
set type double


**DIRECTORIO
**============
global censo "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\BBDD\censo 2017"
global censo07 "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\BBDD\censo 2007"
global renamu "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\BBDD\renamu"
global cenagro "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\BBDD\cenagro 2012"
global encagro "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\BBDD\Encuesta agropecuaria"
global susalud "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\BBDD\susalud"
global cenacom "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\BBDD\cenacom"
global delitos "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\BBDD\Delitos PNP"
global sinadef "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\BBDD\sinadef"
global educenso "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\BBDD\censo educativo"
global enaho "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\BBDD\enaho"
global a "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\PROYECTOS TEBAN\SHAHUINDO\a_Bases_iniciales"
global b "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\PROYECTOS TEBAN\SHAHUINDO\b_Bases_intermedias"
global c "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\PROYECTOS TEBAN\SHAHUINDO\c_Outputs"
global d "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\PROYECTOS TEBAN\SHAHUINDO\Do's"

********************************************************************************
************		LBS AREA ESTUDIO GENERAL PROYECTO SHAHUINDO		************
********************************************************************************

**Extraemos los ambitos de interes
**=================================

**PARA CAMBIAR RESULTADOS DE OTROS AMBITOS SOLO CAMBIAR LOS UBIGEOS EN LA SIGUIENTE LINEA
global ubig "06 0602 060202 060203 0602020056 0602020043 0602020059 0602020092 0602020105 0602020001 0602030011 0602030061 0602030032 0602030034 0602030039 0602030058" //ambitos de analisis

/**
Leyenda
- 06 Cajamarca
- 0602 Cajabamba
- 060202 Cachachi
- 060203 Condebamba
**/

**Se generan las bases //CORRER PRIMERO ESTO PARA GENERAR LAS BASES, LUEGO EL RESTO
/*local f=1
local bases "viv hog pob" //para nombres de bases
foreach r in CPV2017_VIV CPV2017_HOG CPV2017_POB{
local base=word("`bases'",`f')
use if ccdd=="06" using "$censo/`r'", clear
gen prov=ccdd+ccpp
gen localidad=ubigeo+codccpp
save "$a\censo_`base'_shahuindo", replace
local f=`f'+1
}
*/


**VARIABLES DE CPV 2017
**=======================


foreach jevo of global ubig{

putexcel set "$c/`jevo'.xlsx", sheet("CENSO NIVEL VIV") modify
putexcel C2="Variables de Censo 2017 - Nivel Vivienda"

**Generacion de variables a nivel Vivienda
**==========================================
use "$a\censo_viv_shahuindo",clear

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo=="`jevo'"
}

if `jevo'>251000 {
keep if localidad=="`jevo'"
}


**Material paredes
**------------------
preserve
table c2_p3 , c(freq) center col row replace
order c2_p3 table1
gen porc=table1/table1[1]
gsort c2_p3
label def c2_p3 999 "Total", add
replace c2_p3=999 if mi(c2_p3)
export excel using "$c/`jevo'.xlsx", sheet("paredes", modify) firstrow(var) cell(C3)
restore

**Material techos
**------------------
preserve
table c2_p4 , c(freq) center col row replace
order c2_p4 table1
gen porc=table1/table1[1]
gsort c2_p4
label def c2_p4 999 "Total", add
replace c2_p4=999 if mi(c2_p4)
export excel using "$c/`jevo'.xlsx", sheet("techo", modify) firstrow(var) cell(C3)
restore

**Material piso
**------------------
preserve
table c2_p5 , c(freq) center col row replace
order c2_p5 table1
gen porc=table1/table1[1]
gsort c2_p5
label def c2_p5 999 "Total", add
replace c2_p5=999 if mi(c2_p5)
export excel using "$c/`jevo'.xlsx", sheet("piso", modify) firstrow(var) cell(C3)
restore

**Agua de abastecimiento
**-----------------------
preserve
table c2_p6 , c(freq) center col row replace
order c2_p6 table1
gen porc=table1/table1[1]
gsort c2_p6
label def c2_p6 999 "Total", add
replace c2_p6=999 if mi(c2_p6)
export excel using "$c/`jevo'.xlsx", sheet("agua_abaste", modify) firstrow(var) cell(C3)
restore

**Alcantarillado
**----------------
preserve
table c2_p10 , c(freq) center col row replace
order c2_p10 table1
gen porc=table1/table1[1]
gsort c2_p10
label def c2_p10 999 "Total", add
replace c2_p10=999 if mi(c2_p10)
export excel using "$c/`jevo'.xlsx", sheet("serv_hig", modify) firstrow(var) cell(C3)
restore

**Alumbrado publico
**------------------
preserve
table c2_p11 , c(freq) center col row replace
order c2_p11 table1
gen porc=table1/table1[1]
gsort c2_p11
label def c2_p11 999 "Total", add
replace c2_p11=999 if mi(c2_p11)
export excel using "$c/`jevo'.xlsx", sheet("alumbrado", modify) firstrow(var) cell(C3)
restore

**Habitaciones en Vivienda
**-------------------------
preserve
table c2_p12 , c(freq) center col row replace
order c2_p12 table1
gen porc=table1/table1[1]
gsort c2_p12
label def c2_p12 999 "Total", add
replace c2_p12=999 if mi(c2_p12)
export excel using "$c/`jevo'.xlsx", sheet("habita_viv", modify) firstrow(var) cell(C3)
restore

**Tenencia de Vivienda
**-----------------------
preserve
table c2_p13 , c(freq) center col row replace
order c2_p13 table1
gen porc=table1/table1[1]
gsort c2_p13
label def c2_p13 999 "Total", add
replace c2_p13=999 if mi(c2_p13)
export excel using "$c/`jevo'.xlsx", sheet("tenencia_viv", modify) firstrow(var) cell(C3)
restore

**Hogares por vivienda
**---------------------
preserve
table thogar if c2_p2==1, c(freq) center col row replace
order thogar table1
gen porc=table1/table1[1]
gsort thogar
label def thogar 999 "Total", add
replace thogar=999 if mi(thogar)
export excel using "$c/`jevo'.xlsx", sheet("hog por viv", modify) firstrow(var) cell(C3)
restore
}

**Generacion de variables a nivel Hogar
**==========================================
foreach jevo of global ubig{

putexcel set "$c/`jevo'.xlsx", sheet("CENSO NIVEL HOG") modify
putexcel C2="Variables de Censo 2017 - Nivel Hogar"

use "$a\censo_hog_shahuindo",clear

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo=="`jevo'"
}

if `jevo'>251000 {
keep if localidad=="`jevo'"
}

**Combustible para cocina
**-----------------------
putexcel set "$c/`jevo'.xlsx", sheet("combustible") modify
mat def C=J(1,2,.)

foreach w of varlist c3_p1_1-c3_p1_8{
tab `w' , matcell(A)
mat def B=[[A[1,1] , A[2,1]]\ [A[1,1]/`r(N)' , A[2,1]/`r(N)']]
mat def C=C\B
}
mat rownames C= a electricidad porc gas_glp porc gas_natural porc carbon porc leña porc estiercol porc otro porc no_cocina porc
mat colnames C=no_usa usa

putexcel C3=matrix(C), names nformat(number_sep_d2)

**Activos del hogar
**------------------
putexcel set "$c/`jevo'.xlsx", sheet("activos_hog") modify
mat def C=J(1,2,.)

foreach w of varlist c3_p2_1-c3_p2_15{
tab `w' , matcell(A)
mat def B=[[A[1,1] , A[2,1]]\ [A[1,1]/`r(N)' , A[2,1]/`r(N)']]
mat def C=C\B
}
mat rownames C= a equipo_sonido porc tv_color porc cocina porc refri porc lavadora porc horno_micro porc licuadora porc plancha porc compu_laptop porc celular porc telef_fijo porc tv_cable porc internet porc automovil porc motocicleta porc
mat colnames C=tiene no_tiene

putexcel C3=matrix(C), names nformat(number_sep_d2)

**Servicios de Telecomunicaciones
**---------------------------------
egen serv_telecom=anycount(c3_p2_10-c3_p2_13), v(1)
replace serv_telecom=. if mi(c3_p2_10) | mi(c3_p2_11) | mi(c3_p2_12) | mi(c3_p2_13) 

preserve
table serv_telecom , c(freq) center col row replace
order serv_telecom table1
gen porc=table1/table1[1]
gsort serv_telecom
label def serv_telecom 0"0 serv" 1"1 serv" 2"2 serv" 3"3 serv" 4"4 serv" 999 "Total", modify
label val serv_telecom serv_telecom
replace serv_telecom=999 if mi(serv_telecom)
export excel using "$c/`jevo'.xlsx", sheet("telecom", modify) firstrow(var) cell(C3)
restore

**Personas por hogar
**---------------------
preserve
table c4_p1, c(freq) center col row replace
order c4_p1 table1
gen porc=table1/table1[1]
gsort c4_p1
label def c4_p1 999 "Total", add
replace c4_p1=999 if mi(c4_p1)
export excel using "$c/`jevo'.xlsx", sheet("pers por hogar", modify) firstrow(var) cell(C3)
restore
}

**Hacinamiento
**---------------
foreach jevo of global ubig{

use "$a\censo_hog_shahuindo", clear
merge m:1 id_viv* using "$a\censo_viv_shahuindo", keepus(c2_p2-c2_p5 c2_p10 c2_p12 t_c4_p1) nogen keep(1 3)
keep if c2_p2==1

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo=="`jevo'"
}

if `jevo'>251000 {
keep if localidad=="`jevo'"
}

putexcel set "$c/`jevo'.xlsx", sheet("hacinamiento") modify
mat def C=J(2,4,.)

gen hacina=t_c4_p1/c2_p12
gen hacina_viv=(hacina>3.4 & !mi(hacina))


forval p=1/2{

tab hacina_viv if area=="`p'", matcell(A)
if `r(N)'>0{
mat def C[`p',1.]=[A[1,1] , [A[1,1]/`r(N)'] , A[2,1] , [A[2,1]/`r(N)']]
}
}

mat rownames C=urbano rural
mat colnames C=hogar_no_hacinado porc hogar_hacinado porc
putexcel C3=matrix(C), names hcenter vcenter nformat(number_sep_d2) overwritefmt 
}


**Generacion de variables a nivel Población
**==========================================
foreach jevo of global ubig{

putexcel set "$c/`jevo'.xlsx", sheet("CENSO NIVEL POB") modify
putexcel C2="Variables de Censo 2017 - Nivel Poblacion"

use "$a\censo_pob_shahuindo",clear

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo=="`jevo'"
}

if `jevo'>251000 {
keep if localidad=="`jevo'"
}

**Edad, sexo y ambito urbano
**---------------------------
cap recode c5_p4_1 (0/4=1 "De 0 a 4 años") (5/9=2 "De 5 a 9 años") ///
(10/14=3 "De 10 a 14 años") (15/19=4 "De 15 a 19 años") ///
(20/24=5 "De 20 a 24 años") (25/29=6 "De 25 a 29 años") ///
(30/34=7 "De 30 a 34 años") (35/39=8 "De 35 a 39 años") ///
(40/44=9 "De 40 a 44 años") (45/49=10 "De 45 a 49 años") ///
(50/54=11 "De 50 a 54 años") (55/59=12 "De 55 a 59 años") ///
(60/64=13 "De 60 a 64 años") (65/69=14 "De 65 a 69 años") ///
(70/74=15 "De 70 a 74 años") (75/79=16 "De 75 a 79 años") ///
(80/84=17 "De 80 a 84 años") (85/89=18 "De 85 a 89 años") ///
(90/94=19 "De 90 a 94 años") (95/160=20 "De 95 a mas"), g(edad)

preserve
table edad c5_p2 area [iw=fac], c(freq) center col row replace
label def edad 99 "Total", add
label def c5_p2 99 "Total", add
recode edad c5_p2 (.=99)
reshape wide table1, i(edad c5_p2) j(area)

cap dis table11 table12
	if _rc==0{
		reshape wide table11 table12, i(edad) j(c5_p2)
		gsort edad
		rename (table111 table112 table1199 table121 table122 table1299) (H_Urbano M_Urbano T_Urbano H_Rural M_Rural T_Rural)
		order edad H_Urbano M_Urbano T_Urbano H_Rural M_Rural T_Rural
		}

	else {
		cap dis table11
		if _rc==0{
			reshape wide table11, i(edad) j(c5_p2)
			gsort edad
			rename (table111 table112 table1199) (H_Urbano M_Urbano T_Urbano)
			order edad H_Urbano M_Urbano T_Urbano
			}
		
		else{
			reshape wide table12, i(edad) j(c5_p2)
			gsort edad
			rename (table121 table122 table1299) (H_Rural M_Rural T_Rural)
			order edad H_Rural M_Rural T_Rural
			}
		}
export excel using "$c/`jevo'.xlsx", sheet("edad sexo area", modify) firstrow(var) cell(C3)
restore

**Poblacion permanente por sexo
**------------------------------
preserve
table c5_p5 c5_p2 [iw=fac], c(freq) center col row replace
order c5_p5 c5_p2 table1
label def c5_p5 99 "Total", add
label def c5_p2 99 "Total", add
recode c5_p5 c5_p2 (.=99)
reshape wide table1, i(c5_p5) j(c5_p2) 
gen porc_h=table11/table11[_N] //porc hombres
gen porc_m=table12/table12[_N] //porc mujeres
gen porc_t=table199/table199[_N] //porc tot
gsort c5_p5
rename (table11 table12 table199) (Masc Fem Total)
order c5_p5 Masc porc_h Fem porc_m Total porc_t
export excel using "$c/`jevo'.xlsx", sheet("pob perm sexo", modify) firstrow(var) cell(C3)
restore

**Composición del hogar
**---------------------------
gen padres=1 if c5_p1==1 | c5_p1==2
gen hijos=1 if c5_p1==3
sort id_hog_imp
recode padres hijos (.=0)

preserve
collapse (sum) tipo_familia=padres (sum) hijos [iw=fac], by(id_viv id_hog)
merge m:1 id_viv* using "$a\censo_viv_shahuindo", keepus(c2_p2) nogen keep(1 3)
keep if c2_p2==1

replace tipo_fam=round(tipo_fam)
replace hijos=round(hijos)
replace tipo_fam=1 if tipo_fam==0 //existen familias donde no hay jefe de hogar ni esposa, se asume que es un monoparental
replace tipo_fam=2 if tipo_fam>1 //familias biparentales
table hijos tipo_fam, center col row replace
label def hijos 99 "Total", add
replace hijos=99 if mi(hijos)
replace tipo_fam=3 if mi(tipo_fam)
reshape wide table1, i(hijos) j(tipo_fam)
rename (table11 table12 table13) (Monoparental Biparental Total)
export excel using "$c/`jevo'.xlsx", sheet("composicion familia", modify) firstrow(var) cell(C3)
restore

putexcel set "$c/`jevo'.xlsx", sheet("composicion familia") modify
putexcel C2="Nota: Información a Nivel Hogar"

** Migración
**---------------
gen pob_migra=1 if c5_p7==1 & c5_p5==1
replace pob_migra=2 if c5_p7==1 & c5_p5==2
replace pob_migra=3 if c5_p7==2 & c5_p5==1
replace pob_migra=4 if c5_p7==2 & c5_p5==2

label def pob_migra 1"Nativo que vive permanente en su distrito de nacimiento" ///
2"Nativo que vive permanente en otro distrito (emigrante)" ///
3"No nativo que vive permanente en el distrito encuestado (inmigrante permanente)" ///
4"No nativo que vive permanente en otro distrito (inmigrante temporal)" //
label val pob_migra pob_migra


preserve
table pob_migra [iw=fac], c(freq) center col row replace
order pob_migra table1
gen porc=table1/table1[1]
gsort pob_migra
label def pob_migra 999 "Total", add
replace pob_migra=999 if mi(pob_migra)
export excel using "$c/`jevo'.xlsx", sheet("pob_migra", modify) firstrow(var) cell(C3)
restore

**Seguro de salud
**-----------------
putexcel set "$c/`jevo'.xlsx", sheet("salud_seg") modify
mat def C=J(1,2,.)

foreach w of varlist c5_p8_1-c5_p8_6{
tab `w' [iw=fac], matcell(A)
mat def B=[[A[1,1] , A[2,1]]\ [A[1,1]/`r(N)' , A[2,1]/`r(N)']]
mat def C=C\B
}
mat rownames C= a sis porc essalud porc ffaa porc privado porc otro porc ninguno porc
mat colnames C=no_afiliado si_afiliado

putexcel C3=matrix(C), names nformat(number_sep_d2)

**Analfabetismo
**--------------
putexcel set "$c/`jevo'.xlsx", sheet("analfabetismo") modify

tab c5_p12 [iw=fac] if c5_p2==1, matcell(A) //hombres
mat def B1=[[A[1,1] \ A[2,1]], [A[1,1]/`r(N)' \ A[2,1]/`r(N)']]

tab c5_p12 [iw=fac] if c5_p2==2, matcell(A)
mat def B2=[[A[1,1] \ A[2,1]], [A[1,1]/`r(N)' \ A[2,1]/`r(N)']]
mat def B=B1,B2
mat colnames B= Masc_leer_escribir porc Fem_leer_escribir porc
mat rownames B= sabe no_sabe

putexcel C3=matrix(B), names nformat(number_sep_d2)
putexcel C2="Nota: Para personas de 3 a más años"

**Nivel de educación alcanzados por la población
**------------------------------------------------
gen nivel_educ=1 if c5_p13_niv==1 //sin nivel
replace nivel_educ=2 if c5_p13_niv==2 | ///
(c5_p13_niv==3 & c5_p13_gra<6 & !mi(c5_p13_gra)) | ///
(c5_p13_niv==3 & c5_p13_anio_pri<5 & !mi(c5_p13_anio_pri)) // inicial
replace nivel_educ=3 if (c5_p13_niv==3 & c5_p13_gra==6) | ///
(c5_p13_niv==3 & c5_p13_anio_pri==5) | ///
(c5_p13_niv==4 & c5_p13_anio_sec<5 & !mi(c5_p13_anio_sec)) // primaria
replace nivel_educ=4 if c5_p13_niv==4 & c5_p13_anio_sec>=5 & !mi(c5_p13_anio_sec) | ///
c5_p13_niv==6 | c5_p13_niv==8 //secundaria
replace nivel_educ=5 if c5_p13_niv==5 //basica especial
replace nivel_educ=6 if c5_p13_niv==7 | c5_p13_niv==9 | c5_p13_niv==10 //superior

label def nivel_educ 1"Sin nivel" 2"Inicial" 3"Primaria" 4"Secundaria" ///
5"Basica especial" 6"Superior"
label val nivel_educ nivel_educ

preserve
table nivel_educ [iw=fac], c(freq) center col row replace
order nivel_educ table1
label def nivel_educ 999 "Total", add
replace nivel_educ=999 if mi(nivel_educ)
gen porc=table1/table1[1]
gsort -porc
export excel using "$c/`jevo'.xlsx", sheet("nivel_educ", modify) firstrow(var) cell(C3)
restore

putexcel set "$c/`jevo'.xlsx", sheet("nivel_educ") modify
putexcel C2="Nota: Para personas de 3 a más años"

**Nivel de educación por sexo de 15 a más años
**------------------------------------------------
preserve
table nivel_educ c5_p2 [iw=fac] if  c5_p4_1>=15, c(freq) center col row replace
order nivel_educ c5_p2 table1
label def nivel_educ 99 "Total", add
label def c5_p2 99 "Total", add
recode nivel_educ c5_p2 (.=99)
reshape wide table1, i(nivel_educ) j(c5_p2)
gen porc_h=table11/table11[_N] //porc hombres
gen porc_m=table12/table12[_N] //porc mujeres
gen porc_t=table199/table199[_N] //porc tot
gsort nivel_educ
rename (table11 table12 table199) (Masc Fem Total)
order nivel_educ Masc porc_h Fem porc_m Total porc_t
export excel using "$c/`jevo'.xlsx", sheet("nivel_educ 15a", modify) firstrow(var) cell(C3)
restore

putexcel set "$c/`jevo'.xlsx", sheet("nivel_educ 15a") modify
putexcel C2="Nota: Para personas de 15 a más años"

**Asistencia escolar de edades
**-------------------------------
gen pers_prim=c5_p4_1>=6 & c5_p4_1<=11
gen pers_sec=c5_p4_1>=12 & c5_p4_1<=16
gen asiste_prim=(c5_p14==1 & c5_p4_1>=6 & c5_p4_1<=11)
gen asiste_sec=(c5_p14==1 & c5_p4_1>=12 & c5_p4_1<=16)

preserve
replace ubigeo="`jevo'"
collapse (sum) asiste_prim asiste_sec pers_prim pers_sec [iw=fac], by(ubigeo)
gen tasa_asistencia_prim=asiste_prim/pers_prim
gen tasa_asistencia_sec=asiste_sec/pers_sec
order ubigeo, first
export excel using "$c/`jevo'.xlsx", sheet("tasa de asistencia neta", modify) firstrow(var) cell(C3)
restore

putexcel set "$c/`jevo'.xlsx", sheet("tasa de asistencia neta") modify
putexcel C2="Nota: Solo para personas que asisten actualmente al nivel primaria y secundaria. Variable Pers_prim contiene a toda persona de entre 5 y 11 años. Variable Pers_sec contiene a toda persona de entre 12 y 16 años"

**Atraso escolar segun INEI
**--------------------------
gen atraso_prim= 	(c5_p13_niv==2 & c5_p4_1>=8 & c5_p14==1) | /// con 6 años se cursa 1° grado
					((c5_p13_niv==3 & (c5_p13_gra==1 | c5_p13_anio_pri==1)) & c5_p4_1>=9 & c5_p14==1) | /// con 7 años se cursa 2° grado
					((c5_p13_niv==3 & (c5_p13_gra==2 | c5_p13_anio_pri==2)) & c5_p4_1>=10 & c5_p14==1) | /// con 8 años se cursa 3° grado
					((c5_p13_niv==3 & (c5_p13_gra==3 | c5_p13_anio_pri==3)) & c5_p4_1>=11 & c5_p14==1) | /// con 9 años se cursa 4° grado
					((c5_p13_niv==3 & (c5_p13_gra==4 | c5_p13_anio_pri==4)) & c5_p4_1>=12 & c5_p14==1) | /// con 10 años se cursa 5° grado
					((c5_p13_niv==3 & (c5_p13_gra==5 | c5_p13_anio_pri==5)) & c5_p4_1>=13 & c5_p14==1)   // con 11 años se cursa 6° grado
					
gen atraso_sec= 	((c5_p13_niv==3 & (c5_p13_gra==6 | c5_p13_anio_pri==6)) & c5_p4_1>=14 & c5_p14==1) | /// con 12 años se cursa 1° sec
					((c5_p13_niv==4 & c5_p13_anio_sec==1) & c5_p4_1>=15 & c5_p14==1) | /// con 13 años se cursa 2° sec
					((c5_p13_niv==4 & c5_p13_anio_sec==2) & c5_p4_1>=16 & c5_p14==1) | /// con 14 años se cursa 3° sec
					((c5_p13_niv==4 & c5_p13_anio_sec==3) & c5_p4_1>=17 & c5_p14==1) | /// con 15 años se cursa 4° sec
					((c5_p13_niv==4 & c5_p13_anio_sec==4) & c5_p4_1>=18 & c5_p14==1)   // con 16 años se cursa 5° sec

					
preserve
replace ubigeo="`jevo'"
collapse (sum) atraso_prim atraso_sec pers_prim pers_sec [iw=fac], by(ubigeo)
gen tasa_atraso_prim=atraso_prim/pers_prim
gen tasa_atraso_sec=atraso_sec/pers_sec
order ubigeo, first
export excel using "$c/`jevo'.xlsx", sheet("atraso escolar", modify) firstrow(var) cell(C3)
restore

**Tasa de deserción escolar (se asume que si asiste se encuentra matriculado)
**----------------------------------------------------------------------------
gen prim_incompleta= (c5_p13_niv==3 & (c5_p13_anio_pri<5 | c5_p13_gra<6)) & c5_p4_1<=14
gen sec_incompleta= (c5_p13_niv==4 & c5_p13_anio_sec<5) & c5_p4_1<=19
gen noasiste_prim= prim_incompleta==1 & c5_p14==2
gen noasiste_sec= sec_incompleta==1 & c5_p14==2

preserve
replace ubigeo="`jevo'"
collapse (sum) prim_incompleta sec_incompleta noasiste_prim noasiste_sec [iw=fac], by(ubigeo)
gen tasa_desercion_prim=noasiste_prim/prim_incompleta
gen tasa_desercion_sec=noasiste_sec/sec_incompleta
order ubigeo, first
export excel using "$c/`jevo'.xlsx", sheet("desercion escolar", modify) firstrow(var) cell(C3)
restore

**Nivel educativo jefe de hogar
**-------------------------------
preserve
table nivel_educ [iw=fac] if c5_p1==1, c(freq) center col row replace
order nivel_educ table1
label def nivel_educ 999 "Total", add
replace nivel_educ=999 if mi(nivel_educ)
gen porc=table1/table1[1]
gsort -porc
export excel using "$c/`jevo'.xlsx", sheet("nivel_educ jh", modify) firstrow(var) cell(C3)
restore

putexcel set "$c/`jevo'.xlsx", sheet("nivel_educ jh") modify
putexcel C2="Nota: Solo para jefes de hogar"

}

foreach jevo of global ubig{

use "$a\censo_pob_shahuindo",clear

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo=="`jevo'"
}

if `jevo'>251000 {
keep if localidad=="`jevo'"
}

**PET, PEA, Desempleo
**--------------------
putexcel set "$c/`jevo'.xlsx", sheet("empleo") modify
mat def J=J(5,10,.)

**PET**
gen pet=c5_p4_1>=14

tab pet [iw=fac], matcell(A)
mat def J[1,1]=A[2,1]

**PEA**
gen pea=1 if (c5_p16==1 | (c5_p17>=1 & c5_p17<=5 & !mi(c5_p17)) | c5_p18==1) & pet==1
replace pea=2 if mi(pea) & pet==1
label def pea 1"PEA" 2"NO PEA", modify
label val pea pea

tab pea [iw=fac], matcell(A)
mat def J[2,1]=A[1,1]
mat def J[5,1]=A[2,1]

**PEA ocupada y desocupada**
gen pea_ocup=1 if (c5_p16==1 | (c5_p17>=1 & c5_p17<=5 & !mi(c5_p17))) & pea==1
replace pea_ocup=2 if c5_p18==1 & pea==1
label def pea_ocup 1"Pea ocupada" 2"Pea desocupada"
label val pea_ocup pea_ocup

tab pea_ocup [iw=fac], matcell(A)
mat def J[3,1]=A[1,1]
mat def J[4,1]=A[2,1]

mat def J[1.,2]=[1\ (J[2,1]/J[1,1])  \ (J[3,1]/J[2,1]) \ ///
  (J[4,1]/J[2,1])\ (J[5,1]/J[1,1])]

**Por edades**
recode c5_p4_1 (0/13=.) (14/29=1 "14 a 29 años") (30/44=2 "30 a 44 años") ///
(45/64=3 "45 a 64 años") (65/150=4 "65 a más"), g(edades_grup)

tab pet edades_grup [iw=fac], matcell(A) //pet por edades
local t=3
local q=4
forval k=1/4{
mat def J[1,`t']=A[1,`k'] //pet
mat def J[1,`q']=1 //porc pet
local t=`t'+2
local q=`q'+2
}

tab pea edades_grup [iw=fac], matcell(A) //pea por edades
local t=3
local q=4
forval k=1/4{
mat def J[2,`t']=A[1,`k'] //pea
mat def J[2,`q']=A[1,`k']/J[1,`t'] //porc pea
mat def J[5,`t']=A[2,`k'] //no pea
mat def J[5,`q']=A[2,`k']/J[1,`t'] //porc no pea
local t=`t'+2
local q=`q'+2
}

tab pea_ocup edades_grup [iw=fac], matcell(A) //pea ocupada por edades
local t=3
local q=4
forval k=1/4{
mat def J[3,`t']=A[1,`k'] //pea ocupada
mat def J[3,`q']=A[1,`k']/J[2,`t'] //porc pea ocupada
mat def J[4,`t']=A[2,`k'] //pea desocupada //desempleo
mat def J[4,`q']=A[2,`k']/J[2,`t'] //porc pea desocupada
local t=`t'+2
local q=`q'+2
}

mat rownames J=pet pea pea_ocup pea_desocup no_pea
mat colnames J=N porc N porc N porc N porc N porc
putexcel B4=matrix(J), names nformat(number_sep_d2)
putexcel B2="Categoria", hcenter vcenter overwritefmt
putexcel C2="Total",  hcenter vcenter overwritefmt
putexcel E3="14 a 29 años",  hcenter vcenter overwritefmt 
putexcel G3="30 a 44 años",  hcenter vcenter overwritefmt
putexcel I3="45 a 64 años",  hcenter vcenter overwritefmt
putexcel K3="65 a mas",  hcenter vcenter overwritefmt
putexcel E2="Grupos de edad",  hcenter vcenter overwritefmt

**PEA según categorías ocupacionales
**-----------------------------------
preserve
table c5_p21 [iw=fac] if pea_ocup==1, c(freq) center col row replace
order c5_p21 table1
gen porc=table1/table1[1]
gsort c5_p21
label def c5_p21 999 "Total", add
replace c5_p21=999 if mi(c5_p21)
export excel using "$c/`jevo'.xlsx", sheet("pea_cat_ocup", modify) firstrow(var) cell(C3)
restore

putexcel set "$c/`jevo'.xlsx", sheet("pea_cat_ocup") modify
putexcel C2="Nota: Restringido a PEA ocupada"

** Actividades económicas
**-------------------------
destring c5_p20_cod, replace
gen  Sector4=1  if c5_p20_cod>=111 & c5_p20_cod<=240 //agropecuaria
replace Sector4=2  if c5_p20_cod>=311 & c5_p20_cod<=322 //pesca
replace Sector4=3  if c5_p20_cod>=510 & c5_p20_cod<=990 //mina
replace Sector4=4  if c5_p20_cod>=1010 & c5_p20_cod<=3320 //manufac
replace Sector4=5  if c5_p20_cod>=3510 & c5_p20_cod<=3530 //electricidad
replace Sector4=6  if c5_p20_cod>=3600 & c5_p20_cod<=3900 //agua
replace Sector4=7  if c5_p20_cod>=4100 & c5_p20_cod<=4390 //construccion
replace Sector4=8  if c5_p20_cod>=4510 & c5_p20_cod<=4799 //comercio
replace Sector4=9  if c5_p20_cod>=4911 & c5_p20_cod<=5320 // transporte y almacenamiento
replace Sector4=10  if c5_p20_cod>=5510 & c5_p20_cod<=5630 // actividades de alojamiento y serv comidas
replace Sector4=11  if c5_p20_cod>=5811 & c5_p20_cod<=6399 // informacion y comunicaciones
replace Sector4=12  if c5_p20_cod>=6411 & c5_p20_cod<=6630 // actividades financieras
replace Sector4=13  if c5_p20_cod>=6810 & c5_p20_cod<=6820 // actividades inmobiliarias
replace Sector4=14  if c5_p20_cod>=6910 & c5_p20_cod<=7500 // Actividades profesionales
replace Sector4=15  if c5_p20_cod>=7710 & c5_p20_cod<=8299 // Actividades servicios administrativos
replace Sector4=16  if c5_p20_cod>=8411 & c5_p20_cod<=8430 // Administracion publica
replace Sector4=17  if c5_p20_cod>=8510 & c5_p20_cod<=8550 // EnseÃ±anza
replace Sector4=18  if c5_p20_cod>=8610 & c5_p20_cod<=8890 // Atencion salud y asistencia social
replace Sector4=19  if c5_p20_cod>=9000 & c5_p20_cod<=9329 // Actividades artÃ­sticas
replace Sector4=20  if c5_p20_cod>=9411 & c5_p20_cod<=9609 // Otras actividades de servicios
replace Sector4=21  if c5_p20_cod>=9700 & c5_p20_cod<=9820 // Act hogares como empleadores
replace Sector4=22 if c5_p20_cod>=9900 & c5_p20_cod<=9999 // Actividades organos extraterritoriales
label define Sector4 1  "Agricultura y Ganaderia" ///
2  "Pesca" ///
3  "Explotacion de minas y canteras" ///
4  "Industrias manufactureras" ///
5  "Suministro de electricidad, gas, vapor y aire acondicionado" ///
6  "Suministro de agua, evacuacion aguas residucales, gestion desechos y descontaminacion" ///
7  "Construccion" ///
8  "Comercio" ///
9  "Transporte y almacenamiento" ///
10  "Actividades de alojamiento y servicio de comidas" ///
11 "Informacion y comunicaciones" ///
12 "Actividades financieras y de seguros" ///
13 "Actividades inmobiliarias" ///
14 "Actividades profesionales, cientificas y tecnicas" ///
15 "Actividades de servicios administrativos y de apoyo" ///
16 "Administracion publica y defensa, planes de seguridad social de afiliacion obligatoria" ///
17 "Enseñanza (privada)" ///
18 "Actividades de atencion salud humana y de asistencia social" ///
19 "Actividades artisticas, de entretenimiento y recreativas" ///
20 "Otras actividades de servicios" ///
21 "Actividades de los hogares como empleadores" ///
22 "Actividades de organizaciones y organos extraterritoriales" 
label values Sector4 Sector4
recode Sector4 (1=1 "Agricultura y ganadería") (2=2 "Pesca") (3=3 "Minería")  ///
(4=4 "Manufactura") (5 6=5 "Electricidad y agua") (7=6 "Construcción") ///
(8=7 "Comercio") (9/22=8 "Servicios"), g(act_econ)

**Tipo de trabajador
gen pea_cond=1 if pea_ocup==1 & (c5_p21==1 | c5_p21==2)
replace pea_cond=2 if pea_ocup==1 & (c5_p21>=3 & c5_p21<=6 & !mi(c5_p21))
label def pea_cond 1"Independientes" 2"Dependientes", modify
label val pea_cond pea_cond

preserve
table act_econ pea_cond [iw=fac], c(freq) col row center replace
label def act_econ 99 "Total", add
label def pea_cond 99 "Total", add
recode act_econ pea_cond (.=99)
reshape wide table1, i(act_econ) j(pea_cond)

gen porc_indep=table11/table11[_N] //porc indep
gen porc_dep=table12/table12[_N] //porc dep
gen porc_t=table199/table199[_N] //porc tot
rename (table11 table12 table199) (Independiente Dependiente Total)
gsort act_econ
order act_econ Indep porc_indep Dep porc_dep Total porc_t
export excel using "$c/`jevo'.xlsx", sheet("act_econ", modify) firstrow(var) cell(C3)
restore

putexcel set "$c/`jevo'.xlsx", sheet("act_econ") modify
putexcel C2="Nota: Restringido a PEA ocupada"

** Empleo por tipo de ocupacion
**-------------------------------
destring c5_p19_cod, replace
gen ocupacion=1 if c5_p19_cod<1000
replace ocupacion=2 if c5_p19_cod>=1000 & c5_p19_cod<2000
replace ocupacion=3 if c5_p19_cod>=2000 & c5_p19_cod<3000
replace ocupacion=4 if c5_p19_cod>=3000 & c5_p19_cod<4000
replace ocupacion=5 if c5_p19_cod>=4000 & c5_p19_cod<5000
replace ocupacion=6 if c5_p19_cod>=5000 & c5_p19_cod<6000
replace ocupacion=7 if c5_p19_cod>=6000 & c5_p19_cod<7000
replace ocupacion=8 if c5_p19_cod>=7000 & c5_p19_cod<8000
replace ocupacion=9 if c5_p19_cod>=8000 & c5_p19_cod<9000
replace ocupacion=10 if c5_p19_cod>=9000 & c5_p19_cod<10000
label def ocupacion 1"Militares y policias" 2"Funcionarios públicos y de alta dirección" 3"Profesionales científicos e intelectuales" 4"Profesionales técnicos" ///
					5"Jefes y empleados administrativos" 6"Comerciantes" 7"Trabajadores agropecuarios" 8"Trabajadores de contrucción" 9"Operadores de maquinaria y transporte" 10"Peones y servicios domésticos"
label val ocupacion ocupacion

preserve
table ocupacion pea_cond [iw=fac], c(freq) center col row replace
order ocupacion pea_cond table1
label def ocupacion 99 "Total", add
label def pea_cond 99 "Total", add
recode ocupacion pea_cond (.=99)
reshape wide table1, i(ocupacion) j(pea_cond)

gen porc_indep=table11/table11[_N] //porc indep
gen porc_dep=table12/table12[_N] //porc dep
gen porc_t=table199/table199[_N] //porc tot
rename (table11 table12 table199) (Independiente Dependiente Total)
gsort ocupacion
order ocupacion Indep porc_indep Dep porc_dep Total porc_t
export excel using "$c/`jevo'.xlsx", sheet("ocupacion", modify) firstrow(var) cell(C3)
restore

putexcel set "$c/`jevo'.xlsx", sheet("ocupacion") modify
putexcel C2="Nota: Restringido a PEA ocupada"

** Raza
**--------
preserve
table c5_p25_i_mc [iw=fac], c(freq) center col row replace
order c5_p25_i_mc table1
gen porc=table1/table1[1]
drop if mi(c5_p25_i_mc)
gsort -porc
gen n=_n
replace c5_p25_i_mc=8 if n>4 & c5_p25_i_mc!=9
collapse (sum) table1 porc n, by(c5_p25_i_mc)
drop n
export excel using "$c/`jevo'.xlsx", sheet("raza", modify) firstrow(var) cell(C3)
putexcel set "$c/`jevo'.xlsx", sheet("raza") modify
putexcel C2="Nota: Para personas de 12 a más años"
restore

** Lengua Materna
**-------------------
preserve
table c5_p11 [iw=fac], c(freq) center col row replace
order c5_p11 table1
gen porc=table1/table1[1]
drop if mi(c5_p11)
gsort -porc
gen n=_n
replace c5_p11=9 if (n>3 & c5_p11!=13 & c5_p11!=14) | c5_p11==46
collapse (sum) table1 porc n, by(c5_p11)
drop n
label def c5_p11 9"Otra lengua" 13"Lengua de señas", modify
export excel using "$c/`jevo'.xlsx", sheet("lengua_materna", modify) firstrow(var) cell(C3)
putexcel set "$c/`jevo'.xlsx", sheet("lengua_materna") modify
putexcel C2="Nota: Para personas de 3 a más años"
restore

** Religión
**-------------------
preserve
table c5_p26 [iw=fac], c(freq) center col row replace
order c5_p26 table1
gen porc=table1/table1[1]
gsort c5_p26
label def c5_p26 999 "Total", add
replace c5_p26=999 if mi(c5_p26)
export excel using "$c/`jevo'.xlsx", sheet("religion", modify) firstrow(var) cell(C3)
putexcel set "$c/`jevo'.xlsx", sheet("religion") modify
putexcel C2="Nota: Para personas de 12 a más años"
restore

**Población vulnerable
**------------------------------
preserve
table c5_p9_7 c5_p2 [iw=fac], c(freq) center col row replace
order c5_p9_7 c5_p2 table1
label def c5_p9_7 99 "Total", add
label def c5_p2 99 "Total", add
recode c5_p9_7 c5_p2 (.=99)
reshape wide table1, i(c5_p9_7) j(c5_p2) 
gen porc_h=table11/table11[_N] //porc hombres
gen porc_m=table12/table12[_N] //porc mujeres
gen porc_t=table199/table199[_N] //porc tot
gsort c5_p9_7
rename (table11 table12 table199) (Masc Fem Total)
order c5_p9_7 Masc porc_h Fem porc_m Total porc_t
export excel using "$c/`jevo'.xlsx", sheet("poblacion vulnerable", modify) firstrow(var) cell(C3)
restore
}

**Generacion de variables NBI's
**------------------------------
foreach jevo of global ubig{

use "$a\censo_hog_shahuindo", clear
merge m:1 id_viv* using "$a\censo_viv_shahuindo", keepus(c2_p3-c2_p5 c2_p10 c2_p12 t_c4_p1) nogen 

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo=="`jevo'"
}

if `jevo'>251000 {
keep if localidad=="`jevo'"
}

*A) Hogares en viviendas con características físicas inadecuadas:
*	- Paredes exteriores predominantes de estera.
*	- Vivienda con piso de tierra y paredes exteriores de quincha, piedra con barro, madera u otros materiales.
*	- Viviendas improvisadas (de cartón, lata, ladrillos y adobes superpuestos, etc.)

gen viv_precaria=1 if c2_p3==8 | ///
(c2_p5==6 & c2_p3>=5 & c2_p3<=9 & !mi(c2_p3)) | ///
(c2_p4>=5 & c2_p4<=8 & !mi(c2_p4))
replace viv_precaria=0 if mi(viv_precaria)

*B) Hogares en viviendas con hacinamiento:
*	- La relación existente entre el número de personas con el número total de habitaciones que tiene la
*	  vivienda, sin contar el baño, cocina ni pasadizo. Se determina que hay hacinamiento cuando residen
*	  más de 3,4 personas por habitación.

gen hacina=c2_p12/t_c4_p1
gen hacina_viv=(hacina>3.4 & !mi(hacina))

*C) Hogares en viviendas sin desague de ningun tipo:
*	- Los hogares que no disponen de servicio higiénico por red de tuberías o pozo ciego (es decir, no disponen del servicio o está conectado a acequia/canal).

gen desague_viv=1 if c2_p10>=4 & c2_p10!=5 & !mi(c2_p10)
replace desague_viv=0 if mi(desague_viv)

save "$b\nbi_hog",replace

*D) Hogares con niños que no asisten a la escuela:
*	- Aquellos hogares con presencia de al menos un niño de 6 a 12 años que no asiste a un centro educativo.

use "$a\censo_pob_shahuindo",clear

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo=="`jevo'"
}

if `jevo'>251000 {
keep if localidad=="`jevo'"
}

gen nino_escuela=1 if c5_p4_1>5 & c5_p4_1<13 & !mi(c5_p4_1) & c5_p14==2
replace nino_escuela=0 if mi(nino_escuela)

bysort id_hog*: egen nino_esc=sum(nino_escuela)

*E) Hogares con alta dependencia economica:
*	- Hogares que no tienen ningún miembro ocupado
*	- Jefe de hogar sólo cuenta con primaria incompleta
*	- Existe población ocupada y la relación entre la población no ocupada y ocupada es superior a 3.


*Jh con prim incompleta
gen jh_primaria=1 if c5_p1==1 & (c5_p13_niv<2 & !mi(c5_p13_niv) | ///
(c5_p13_niv==3 & c5_p13_gra<6 & !mi(c5_p13_gra)) | ///
(c5_p13_niv==3 & c5_p13_anio_pri<5 & !mi(c5_p13_anio_pri))) // sin nivel, inicial y primaria incompleta
replace jh_primaria=0 if mi(jh_primaria)

bysort id_hog*: egen jh_prim=sum(jh_primaria)

*Ratio pob no ocup/pob ocup es mayor a 3
gen pet=c5_p4_1>=14 //pet

**PEA**
gen pea=1 if (c5_p16==1 | (c5_p17>=1 & c5_p17<=5 & !mi(c5_p17)) | c5_p18==1) & pet==1
replace pea=2 if mi(pea) & pet==1
label def pea 1"PEA" 2"NO PEA", modify
label val pea pea

**PEA ocupada y desocupada**
gen pea_ocup=1 if (c5_p16==1 | (c5_p17>=1 & c5_p17<=5 & !mi(c5_p17))) & pea==1
replace pea_ocup=2 if c5_p18==1 & pea==1
label def pea_ocup 1"Pea ocupada" 2"Pea desocupada"
label val pea_ocup pea_ocup

gen per_no_cup=1 if pea_ocup==2 | pea==2
gen per_ocup=1 if pea_ocup==1
bysort id_hog*: egen hg_nocup=sum(per_no_cup)
bysort id_hog*: egen hg_ocup=sum(per_ocup)
replace hg_ocup=0.99 if hg_ocup==0
gen ratio=hg_nocup/hg_ocup //ratio

*Hogares sin miembro ocupado
gen hog_nocup=1 if hg_ocup==0.99
replace hog_nocup=0 if mi(hog_nocup)

gen dep_econ=1 if ((ratio>3 & !mi(ratio)) | hog_nocup==1) & jh_prim==1
replace dep_econ=0 if mi(dep_econ)

collapse dep_econ nino_esc, by(id_hog*)
save "$b\nbi_pob", replace

**Se junta los 5 NBI's
use "$b\nbi_hog", clear
merge 1:1 id_hog* using "$b\nbi_pob", nogen
drop hacina
replace nino_esc=1 if nino_esc>1 & !mi(nino_esc)
replace dep_econ=1 if dep_econ>1 & !mi(dep_econ)
egen nbi=rsum(viv_precaria-nino_esc)
replace nbi=. if mi(c3_p1_1)

label def nbi 0"Hogares con 0 NBIs" 1"Hogares con 1 NBIs" 2"Hogares con 2 NBIs" 3"Hogares con 3 NBIs" 4"Hogares con 4 NBIs" 5"Hogares con 5 NBIs", add
label val nbi nbi

preserve
table nbi, c(freq) center col row replace
order nbi table1
gen porc=table1/table1[1]
gsort nbi
label def nbi 999 "Total", add
replace nbi=999 if mi(nbi)
export excel using "$c/`jevo'.xlsx", sheet("hogares nbi", modify) firstrow(var) cell(C3)
restore

putexcel set "$c/`jevo'.xlsx", sheet("hogares nbi") modify
putexcel C2="Nota: Información a nivel hogar"

}


**VARIABLES DE RENAMU
**======================
global ubig "06 0602 060202 060203" //ambitos de analisis

**Residuos solidos
**-------------------
foreach jevo of global ubig { 

putexcel set "$c/`jevo'.xlsx", sheet("RENAMU") modify
putexcel C2="Variables de Renamu 2019 - Nivel municipalidad"

use "$renamu/2019/656-Modulo1486/c10", clear
gen prov=ccdd+ccpp

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if idmunici=="`jevo'"
}

keep ccdd prov idmunici p41_1 p42_1 p43_1 p44* p45_* p46_1

**Frecuencia de recojo
preserve
table p41_1, c(freq) center col row replace
order p41_1 table1
gen porc=table1/table1[1]
gsort p41_1
label def p41_1 999 "Total", add
replace p41_1=999 if mi(p41_1)
export excel using "$c/`jevo'.xlsx", sheet("recojo_basura", modify) firstrow(var) cell(C3)
restore

**Cobertura de recojo
preserve
table p43_1, c(freq) center col row replace
order p43_1 table1
gen porc=table1/table1[1]
gsort p43_1
label def p43_1 999 "Total", add
replace p43_1=999 if mi(p43_1)
export excel using "$c/`jevo'.xlsx", sheet("cobertura_basura", modify) firstrow(var) cell(C3)
restore

**Recojo promedio y costo promedio
preserve
gen ubigeo="`jevo'"
collapse (mean) recojo_prom=p42_1 costo_prom=p46_1 (count) tot_mun_recojo=p42_1 tot_mun_costo=p46_1, by(ubigeo)
export excel using "$c/`jevo'.xlsx", sheet("Recojo_costo_basura", modify) firstrow(var) cell(C3)
restore

**Destino basura
putexcel set "$c/`jevo'.xlsx", sheet("Destino basura") modify
mat def C=J(1,2,.)

forval w=1/5{
tab p45_`w', matcell(A)
mat def B=[[A[1,1] , A[2,1]]\ [A[1,1]/`r(N)' , A[2,1]/`r(N)']]
mat def C=C\B
}
mat rownames C= a relleno_sanitario porc botadero porc reciclados porc quemados porc otro
mat colnames C=utiliza no_utiliza
putexcel C3=matrix(C), names nformat(number_sep_d2)

**Instrumentos gestion
putexcel set "$c/`jevo'.xlsx", sheet("Gestion basura") modify
mat def C=J(1,2,.)

forval w=1/5{
tab p45_`w', matcell(A)
mat def B=[[A[1,1] , A[2,1]]\ [A[1,1]/`r(N)' , A[2,1]/`r(N)']]
mat def C=C\B
}
mat rownames C= a plan_integral porc plan_manejo porc sistema_recojo porc prog_trans porc prog_segreg porc
mat colnames C=no_tiene tiene 
putexcel C3=matrix(C), names nformat(number_sep_d2)

}

**Infraestructura recreativa
**---------------------------
foreach jevo of global ubig { 

use "$renamu/2019/656-Modulo1486/c12", clear
gen prov=ccdd+ccpp

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if idmunici=="`jevo'"
}

putexcel set "$c/`jevo'.xlsx", sheet("Infra social") modify
mat def C=J(1,2,.)
drop p59_*_1
foreach w of varlist p52 p58_1 p58_2 p58_3 p59_1-p59_10{
tab `w', matcell(A)
mat def B=[[A[1,1] , A[2,1]]\ [A[1,1]/`r(N)' , A[2,1]/`r(N)']]
mat def C=C\B
}
mat rownames C= a biblioteca porc casas_cultura porc teatro porc museo porc ///
				estadio comp_deport coliseo_deport losa_multidep losa_fulbito ///
				losa_voley losa_basquet parque_zonal piscina gimnasio
mat colnames C=tiene no_tiene
putexcel C3=matrix(C), names nformat(number_sep_d2)
}

**Organizaciones sociales
**-------------------------
foreach jevo of global ubig { 

use "$renamu/2019/656-Modulo1486/c13", clear
gen prov=ccdd+ccpp

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if idmunici=="`jevo'"
}

keep idmunici p60a_*_*
drop p60a_5*

local a=1
foreach x in vaso_leche comedor_pop club_madres org_juv{
rename p60a_`a'_1 cantidad`x'
rename p60a_`a'_2 beneficiarios`x'
local a=`a'+1
}
gen x=1
collapse (sum) cantidadvaso_leche - beneficiariosorg_juv, by(x)
reshape long cantidad beneficiarios, i(x) j(tipo) string
recode cant benef (.=0) 
drop x
export excel using "$c/`jevo'.xlsx", sheet("org_social", modify)  firstrow(var) cell(C3) 

putexcel set "$c/`jevo'.xlsx", sheet("org_social") modify
putexcel C2="Nota: Cantidad de organizaciones y beneficiarios"
}

**CENSO DE COMISARIAS 2017
**==========================
foreach jevo of global ubig { 

putexcel set "$c/`jevo'.xlsx", sheet("CENSO COMISARIAS") modify
putexcel C2="Variables de Censo Comisarías 2017"

**Dependencias policiales
**-------------------------
use "$cenacom/2017/cap_100_infraestructura_2017", clear

gen ccdd=substr(ubigeo,1,2)
gen prov=substr(ubigeo,1,4)

if `jevo'<25 { //para ambitos departamentales
	keep if ccdd=="`jevo'"

	preserve
	table inf109, c(freq sum inf110_tot) center col row replace
	label def inf109 999 "Total", add
	replace inf109=999 if mi(inf109)
	gen porc_com=table1/table1[1]
	rename (inf109 table1 table2) (Cobertura Comisarias Policias)
	order Cobertura Comisarias porc_com Policias
	export excel using "$c/`jevo'.xlsx", sheet("comisarias", modify) firstrow(var) cell(C3)
	restore
	}

else {
	if `jevo'>25 & `jevo'<2505 {
	keep if prov=="`jevo'"
	}

	if `jevo'>2505 & `jevo'<251000 {
	keep if ubigeo=="`jevo'"
	}

	keep nombredi id_n inf109 inf109a inf109a_o inf110_tot gps*
	rename (inf109 inf109a inf109a_o inf110_tot) (Cobertura Ambito Otro_ambito Policias)
	export excel using "$c/`jevo'.xlsx", sheet("comisarias", modify) firstrow(var) cell(C3)

	}

**Organizaciones vecinales
**-------------------------
use "$cenacom/2017/cap_600_seguridad_2017", clear
drop ubi
merge 1:1 id_n using "$cenacom/2017/cap_100_infraestructura_2017", nogen keepus(ubigeo) keep(1 2 3)
gen ccdd=substr(ubigeo,1,2)
gen prov=substr(ubigeo,1,4)

if `jevo'<25 { //para ambitos departamentales
	keep if ccdd=="`jevo'"
	recode inf641_a (.=2) 
	preserve
	table inf641_a, c(freq sum inf645_a sum inf645_b sum inf646_tot) center replace
	gen porc_com=table1/table1[1]
	rename (inf641_a table1 table2 table3 table4) (Implem_JV Comisarias JuntasV_activas JuntasV_noactivas Miembros_JV)
	order Implem_JV Comisarias porc_com JuntasV_activas JuntasV_activas Miembros_JV
	export excel using "$c/`jevo'.xlsx", sheet("org vecinales", modify) firstrow(var) cell(C3)
	restore
	}

else {
	if `jevo'>25 & `jevo'<2505 {
	keep if prov=="`jevo'"
	}

	if `jevo'>2505 & `jevo'<251000 {
	keep if ubigeo=="`jevo'"
	}

	keep nombredi id_n inf641_a inf645_a inf645_b inf646_tot
	rename (inf641_a inf645_a inf645_b inf646_tot) (Implem_JV JuntasV_activas JuntasV_noactivas Miembros_JV)
	export excel using "$c/`jevo'.xlsx", sheet("org vecinales", modify) firstrow(var) cell(C3)

	}

**Intervenciones policiales
**-------------------------
use "$cenacom/2017/cap_600_seguridad_2017", clear
drop ubi
merge 1:1 id_n using "$cenacom/2017/cap_100_infraestructura_2017", nogen keepus(ubigeo) keep(1 3)
gen ccdd=substr(ubigeo,1,2)
gen prov=substr(ubigeo,1,4)

if `jevo'<25 { //para ambitos departamentales
	keep if ccdd=="`jevo'"
	preserve
	gen x=1
	keep inf601 x inf65*_tot_2016 inf65*_tot_2017
	collapse (count) comisarias=inf601 (sum) inf650_tot_2016-inf652_tot_2017, by(x)
	drop x
	rename (inf650_tot_2016 inf650_tot_2017 inf651_tot_2016 inf651_tot_2017 inf652_tot_2016 inf652_tot_2017) (Bandas_capt2016 Bandas_capt2017 Pers_interv2016 Pers_interv2017 Pers_capt2016 Pers_capt2017)
	export excel using "$c/`jevo'.xlsx", sheet("interv policial", modify) firstrow(var) cell(C3)
	restore
	putexcel set "$c/`jevo'.xlsx", sheet("interv policial") modify
	putexcel C2="Nota: Acotado a comisarías básicas"

	}

else {
	if `jevo'>25 & `jevo'<2505 {
	keep if prov=="`jevo'"
	}

	if `jevo'>2505 & `jevo'<251000 {
	keep if ubigeo=="`jevo'"
	}

	keep nombredi id_n inf650_tot_2016-inf652_tot_2017
	rename (inf650_tot_2016 inf650_tot_2017 inf651_tot_2016 inf651_tot_2017 inf652_tot_2016 inf652_tot_2017) (Bandas_capt2016 Bandas_capt2017 Pers_interv2016 Pers_interv2017 Pers_capt2016 Pers_capt2017)
	export excel using "$c/`jevo'.xlsx", sheet("interv policial", modify) firstrow(var) cell(C3)
	
	putexcel set "$c/`jevo'.xlsx", sheet("interv policial") modify
	putexcel C2="Acotado a comisarías básicas"

	}
}

**DELITOS Y FALTAS 2017 - PNP - SIDPOL
**=====================================

foreach jevo of global ubig { 

putexcel set "$c/`jevo'.xlsx", sheet("PNP SIDPOL") modify
putexcel C2="Variables de SIDPOL 2017 - Nivel Delitos"

**Organizaciones vecinales
**-------------------------

use "$delitos/2017/capitulo_200_denuncia_de_delitos_2017", clear
gen ccdd=substr(ubigeo_hecho,1,2)
gen prov=substr(ubigeo_hecho,1,4)

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo_hecho=="`jevo'"
}

preserve
recode ih208_a (2 99=.)
table ih208_generico, c(freq sum ih208_a) center col row replace
replace ih208_generico="TOTAL" if ih208_generico==""
gen porc=table1/table1[1]
order ih208_generico table1 porc table2
rename (ih208_generico table1 porc table2) (Tipo_delito Delitos Porc Causada_Org_Criminal)
export excel using "$c/`jevo'.xlsx", sheet("delitos", modify) firstrow(var) cell(C3)
restore

**Puntos de comercializacion
**----------------------------
keep if strpos(ih208_modalidad, "DROG") & !strpos(ih208_modalidad, "EBRIEDAD")
if _N>0 { 
collapse (count) delitos_droga=id_denuncia, by(ubigeo_h h206 ih207_b) 
export excel using "$c/`jevo'.xlsx", sheet("comercio droga", modify) firstrow(var) cell(C3)
}

else {
set obs 1
export excel using "$c/`jevo'.xlsx", sheet("comercio droga", modify) firstrow(var) cell(C3)
}

}

**SUSALUD
**============

***Correr el siguiente do file una sola vez
*do "$d/2. Bases susalud.do"

global ubig "06 0602 060202 060203" //ambitos de analisis

foreach jevo of global ubig { 

putexcel set "$c/`jevo'.xlsx", sheet("SUSALUD") modify
putexcel C2="Variables de SUSALUD"

**Postas medicas
**----------------
use "$susalud/2021/establecimiento_salud", clear

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo=="`jevo'"
}
destring cod_ipress, replace
collapse (count) Centro_salud=cod_ipress , by(categoria)
drop if categoria=="0"
export excel using "$c/`jevo'.xlsx", sheet("eess_salud", modify) firstrow(var) cell(C3)

putexcel set "$c/`jevo'.xlsx", sheet("eess_salud") modify
putexcel C2="Nota: Cantidad de EESS 2021"

**Recursos de la salud
**-----------------------
use "$susalud/2020/recursos_salud_2020", clear //se uso 2020 porque la data 2021 aun no registraba información de muchos EESS

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo=="`jevo'"
}

drop if categoria=="0"
drop if mes!=8
if _N>0{
collapse (count) Centro_salud=co_ipress (sum) ca_medicos_total ca_camas ca_enferm ca_tecnologos ca_obstetr ca_auxiliar, by(categoria)
export excel using "$c/`jevo'.xlsx", sheet("recursos_salud", modify) firstrow(var) cell(C3)
}

else{
set obs 1
export excel using "$c/`jevo'.xlsx", sheet("recursos_salud", modify) firstrow(var) cell(C3)
}

putexcel set "$c/`jevo'.xlsx", sheet("recursos_salud") modify
putexcel C2="Nota: Se uso data 2020 porque la versión 2021 aun no registraba información de muchos EESS. Por ello, difieren las cantidades de EESS"


**Atendidos y atenciones 
**------------------------
use "$susalud/2019/atendidos_atenciones_2019", clear //se uso 2019 porque 2020 y 2021 son años atipicos por pandemia

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo=="`jevo'"
}

drop if categoria=="0"
if _N>0{
collapse (sum) atenc_medicas-personas_atendidas, by(categoria co_ipress)
collapse (count) Centro_salud=co_ipress (sum) atenc_medicas-personas_atendidas, by(categoria)
export excel using "$c/`jevo'.xlsx", sheet("atendidos_atenciones", modify) firstrow(var) cell(C3)
}

else{
set obs 1
export excel using "$c/`jevo'.xlsx", sheet("atendidos_atenciones", modify) firstrow(var) cell(C3)
}

putexcel set "$c/`jevo'.xlsx", sheet("atendidos_atenciones") modify
putexcel C2="Nota: Se uso data 2019 porque 2020 y 2021 son años atípicos por pandemia. Por ello, difieren las cantidades de EESS"


**Morbilidad
**------------------------
use "$susalud/2019/morbilidad_emergencia_2019", clear
gen tipo="emergencia"
append using "$susalud/2019/morbilidad_ambulatorio_2019"
replace tipo="ambulatorio" if tipo==""
drop if nu_>6000 & nu<.
replace diagnostico="" if strpos(diagnostico, "NE_")

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo=="`jevo'"
}

gen letra_morb=substr(diagnostico,1,1)
gen num_morb=substr(diagnostico,2,2)
destring num_morb, replace

gen morbilidad=.
replace morbilidad=1 if letra_morb=="A" | letra_morb=="B"
replace morbilidad=2 if letra_morb=="C" | (letra_morb=="D" & num_morb<50 & num_morb!=.)
replace morbilidad=3 if (letra_morb=="D" & num_morb>=50 & num_morb!=.)
replace morbilidad=4 if letra_morb=="E"
replace morbilidad=5 if letra_morb=="F"
replace morbilidad=6 if letra_morb=="G"
replace morbilidad=7 if (letra_morb=="H" & num_morb<60 & num_morb!=.)
replace morbilidad=8 if (letra_morb=="H" & num_morb>=60 & num_morb!=.)
replace morbilidad=9 if letra_morb=="I"
replace morbilidad=10 if letra_morb=="J"
replace morbilidad=11 if letra_morb=="K"
replace morbilidad=12 if letra_morb=="L"
replace morbilidad=13 if letra_morb=="M"
replace morbilidad=14 if letra_morb=="N"
replace morbilidad=15 if letra_morb=="O"
replace morbilidad=16 if letra_morb=="P"
replace morbilidad=17 if letra_morb=="Q"
replace morbilidad=18 if letra_morb=="R"
replace morbilidad=19 if letra_morb=="S" | letra_morb=="T"
replace morbilidad=20 if letra_morb=="V" | letra_morb=="W" | letra_morb=="X" | letra_morb=="Y" | letra_morb=="Z"

label def morbilidad 	1"Enfermedades infecciosas y parasitarias" 2"Tumores" 3"Enfermedades de la sangre que afectan sistema inmunológico" ///
						4"Enfermedades endocrinas, nutricionales y metabólicas" 5"Trastornos mentales" ///
						6"Enfermedades del sistema nervioso" 7"Enfermedades del ojo" 8"Enfermedades del oído" 9"Enfermedades del sistema circulatorio" ///
						10"Enfermedades del sistema respiratorio" 11"Enfermedades del sistema digestivo" 12"Enfermedades de la piel" ///
						13"Enfermedades del sistema osteomuscular" 14"Enfermedades del sistema genitourinario" 15"Embarazo, parto y puerperio" ///
						16"Afecciones originadas en periodo perinatal" 17"Malformaciones congénitas" 18"Sintomas anormales" 19"Traumatismos" 20"Causas externas" // CLASIFICACION INTERNACIONAL DE ENFERMEDADES (CIE) - OMS
label val morbilidad morbilidad

drop if morbilidad==.

cap recode edad (0/4=1 "De 0 a 4 años") (5/9=2 "De 5 a 9 años") ///
(10/15=3 "De 10 a 15 años") (16/19=4 "De 16 a 19 años") (20/29=5 "De 20 a 29 años") ///
(30/39=6 "De 30 a 39 años") (40/49=7 "De 40 a 49 años") ///
(50/59=8 "De 50 a 59 años") (60/69=9 "De 60 a 69 años") ///
(70/160=10 "De 70 a mas"), g(grupo_edad)

**Tasa de morbilidad por sexo y edades // Enfermedades frecuentes
**-----------------------------------------------------------------
preserve
if _N>0{
collapse (sum) casos=nu_tot, by(morbilidad sexo grupo_edad)
reshape wide casos, i(morbilidad grupo_edad) j(sexo)
rename (casos1 casos2) (Casos_H Casos_M)
export excel using "$c/`jevo'.xlsx", sheet("morbilidades", modify) firstrow(var) cell(C3)
}

else{
set obs 1
keep razon_soc
rename razon_soc No_se_reportan_casos
export excel using "$c/`jevo'.xlsx", sheet("morbilidades", modify) firstrow(var) cell(C3)
}
restore


**Metales pesados en la sangre
**------------------------------
preserve
keep if strpos(diagnostico, "R78.7") //codigo de metales pesados en la sangre

if _N>0{
collapse (sum) casos=nu_tot, by(morbilidad sexo grupo_edad)
reshape wide casos, i(morbilidad grupo_edad) j(sexo)
rename (casos1 casos2) (Casos_H Casos_M)
export excel using "$c/`jevo'.xlsx", sheet("metales en sangre", modify) firstrow(var) cell(C3)
}

else{
set obs 1
keep razon_soc
rename razon_soc No_se_reportan_casos
export excel using "$c/`jevo'.xlsx", sheet("metales en sangre", modify) firstrow(var) cell(C3)
}
restore


**TBC, paludismo y fiebre amarilla
**---------------------------------
preserve
keep if letra_morb=="A" & num_morb>=15 & num_morb>=19 | /// TBC
		letra_morb=="B" & num_morb==50 | ///paludismo
		letra_morb=="A" & num_morb==95 //fiebre amarilla
		
gen enfermedad=1 if letra_morb=="A" & num_morb>=15 & num_morb>=19
replace enfermedad=2 if letra_morb=="B" & num_morb==50
replace enfermedad=3 if letra_morb=="A" & num_morb==95

label def enfermedad 1"TBC" 2"Paludismo" 3"Fiebre Amarilla"
label val enfermedad enfermedad

if _N>0{
collapse (sum) casos=nu_tot, by(enfermedad sexo grupo_edad)
reshape wide casos, i(enfermedad grupo_edad) j(sexo)
rename (casos1 casos2) (Casos_H Casos_M)
export excel using "$c/`jevo'.xlsx", sheet("tbc_paludismo_fiebre", modify) firstrow(var) cell(C3)
}

else{
set obs 1
keep razon_soc
rename razon_soc No_se_reportan_casos
export excel using "$c/`jevo'.xlsx", sheet("tbc_paludismo_fiebre", modify) firstrow(var) cell(C3)
}
restore

}

**SINADEF
**============

foreach jevo of global ubig { 

putexcel set "$c/`jevo'.xlsx", sheet("SINADEF") modify
putexcel C2="Variables de SINADEF 2019"

**Mortalidad
**------------

use "$sinadef//sinadef_muertes 2017-2021.dta", clear
gen ccdd=substr(ubigeo,1,2)
gen prov=substr(ubigeo,1,4)

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo=="`jevo'"
}

replace edad="" if real(edad)==.
destring edad, replace

replace edad=0 if (	tiempoedad=="DIAS" & (edad<365 & edad<.)) | (tiempoedad=="HORAS" & (edad<8765 & edad<.)) | ///
					tiempoedad=="MESES" & (edad<12 & edad<.) | tiempoedad=="MINUTOS" | tiempoedad=="SEGUNDOS" 
replace edad=1 if 	tiempoedad=="MESES" & (edad>=12 & edad<24) 
replace edad=2 if 	tiempoedad=="MESES" & (edad>=24 & edad<36) 
replace edad=3 if 	tiempoedad=="MESES" & (edad>=36 & edad<48) 
replace edad=4 if 	tiempoedad=="MESES" & (edad>=48 & edad<60) 
replace edad=5 if 	tiempoedad=="MESES" & (edad>=60 & edad<78) 
replace edad=6 if 	tiempoedad=="MESES" & (edad>=78 & edad<90) 
replace edad=7 if 	tiempoedad=="MESES" & (edad>=90 & edad<102) 
replace edad=8 if 	tiempoedad=="MESES" & (edad>=102 & edad<114) 

drop tiempoedad //todas las obs de la variable edad están en años


replace causaaciex = "" if causaaciex=="SIN REGISTRO"
gen letra_morb=substr(causaaciex,1,1)
gen num_morb=substr(causaaciex,2,2)
destring num_morb, replace

**Sexo
gen sexo_r=1 if sexo=="M"
replace sexo_r=2 if sexo=="F"


**Mortalidad infantil
**---------------------
preserve
drop if edad==.
collapse (count) Muerte_infantil=edad if año==2019 & edad<5, by(ccdd prov ubigeo sexo_r) 
drop if sexo_r==.
gen x="1"

if _N>0{
reshape wide Muerte_infantil, i(ubigeo x) j(sexo_r)
merge 1:1 ubigeo using "$b/poblacion_edades_sexo", nogen keep(1 3) keepus(tot_pers11 tot_pers21)

order ccdd prov, first
collapse (sum) Muerte_infantil* tot_pers*1 , by(x)
rename x ubigeo
replace ubigeo="`jevo'" if ubigeo=="1"
cap gen tasa_mort_infantil_H=Muerte_infantil1/tot_pers11*1000
cap gen tasa_mort_infantil_M=Muerte_infantil2/tot_pers21*1000
cap rename (Muerte_infantil1 tot_pers11) (Muerte_infantil_H Infantes_H)
cap rename (Muerte_infantil2 tot_pers21) (Muerte_infantil_M Infantes_M)
export excel using "$c/`jevo'.xlsx", sheet("mortalidad infantil", modify) firstrow(var) cell(C3)

}

else{
set obs 1
keep ubigeo
rename ubigeo No_se_reportan_casos
export excel using "$c/`jevo'.xlsx", sheet("mortalidad infantil", modify) firstrow(var) cell(C3)
}

restore

putexcel set "$c/`jevo'.xlsx", sheet("mortalidad infantil") modify
putexcel C2="Nota: Solo para menores de 5 años"

**Mortalidad materna
**---------------------
preserve
keep if (letra_morb=="O" | letra_morb=="P") & edad>=11
replace ubigeo="`jevo'"

if _N>0{

collapse (count) Muerte_materna=edad if año==2019, by(ubigeo)
export excel using "$c/`jevo'.xlsx", sheet("mortalidad materna", modify) firstrow(var) cell(C3)
}

else{
set obs 1
keep ubigeo
rename ubigeo No_se_reportan_casos
export excel using "$c/`jevo'.xlsx", sheet("mortalidad materna", modify) firstrow(var) cell(C3)
}

restore
}

** CENSO EDUCATIVO - MINEDU
**==============================
global ubig "06 0602 060202 060203 0602020056 0602020043 0602020059 0602020092 0602020105 0602020001 0602030011 0602030061 0602030032 0602030034 0602030039 0602030058" //ambitos de analisis

foreach jevo of global ubig { 

putexcel set "$c/`jevo'.xlsx", sheet("CENSO EDUCATIVO") modify
putexcel C2="Variables de Censo Educativo 2019"

use "$educenso/2019/padron", clear
rename (codgeo prov) (ubigeo provincia)
gen ccdd=substr(ubigeo,1,2)
gen prov=substr(ubigeo,1,4)
keep if anexo=="0"

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo=="`jevo'"
}

if `jevo'>251000 {
keep if codcp_inei=="`jevo'"
}

if _N>0{

**IE y niveles de enseñanza
**--------------------------
gen nivel_enseñanza=1 if strpos(niv_mod, "A")
replace nivel_enseñanza=2 if strpos(niv_mod, "B")
replace nivel_enseñanza=3 if strpos(niv_mod, "F")
replace nivel_enseñanza=4 if strpos(niv_mod, "D")
replace nivel_enseñanza=5 if strpos(niv_mod, "E")
replace nivel_enseñanza=6 if strpos(niv_mod, "K")
replace nivel_enseñanza=7 if strpos(niv_mod, "T")
replace nivel_enseñanza=8 if strpos(niv_mod, "M")
replace nivel_enseñanza=9 if strpos(niv_mod, "L")

label def nivel_enseñanza 	1"Inicial" 2"Primaria" 3"Secundaria" 4"Básica Alternativa" 5"Básica Especial" ///
							6"Superior pedagógica" 7"Superior Tecnológica" 8"Superior Artística" 9"Técnico Productiva"
label value nivel_enseñanza nivel_enseñanza

destring gestion, replace
recode gestion (1=1 "Privado") (2/3=2 "Público"), gen(gestion_r)

preserve
table nivel_enseñanza gestion_r, c(freq) center col row replace
label def nivel_enseñanza 99 "Total", add
label def gestion_r 99 "Total", add
recode nivel_enseñanza gestion_r (.=99)
reshape wide table*, i(nivel_enseñanza) j(gestion_r)

cap gen porc_priv=table11/table11[_N]
cap gen porc_pub=table12/table12[_N]
cap gen porc_tot=table199/table199[_N]
cap rename table11 IE_priv 
cap rename table12 IE_pub 
cap rename table199 IE_Total
export excel using "$c/`jevo'.xlsx", sheet("IE y niveles de enseñanza", modify) firstrow(var) cell(C3)
restore

**Caracteristicas de serv educativos
**------------------------------------
destring tipssexo, replace
recode tipssexo (1=1 "Varones") (2=2 "Mujeres") (3=3 "Mixto"), gen(tipssexo_r)

destring cod_tur, replace
recode cod_tur (11=1 "Mañana") (12=2 "Tarde") (14=3 "Noche") ///
				(13=4 "Mañana-Tarde") (16=5 "Mañana-Noche") (17=6 "Tarde-Noche") (15=7 "Mañana-Tarde-Noche"), gen(cod_tur_r)

preserve
table nivel_enseñanza tipssexo_r, c(freq) center col row replace
label def nivel_enseñanza 99 "Total", add
label def tipssexo_r 99 "Total", add
recode nivel_enseñanza tipssexo_r (.=99)
reshape wide table*, i(nivel_enseñanza) j(tipssexo_r)

cap rename table11 IE_H 
cap rename table12 IE_M 
cap rename table13 IE_Mixto 
cap rename table199 IE_Total
export excel using "$c/`jevo'.xlsx", sheet("Servicios educativos 1", modify) firstrow(var) cell(C3)
restore

preserve
table nivel_enseñanza cod_tur_r, c(freq) center col row replace
label def nivel_enseñanza 99 "Total", add
label def cod_tur_r 99 "Total", add
recode nivel_enseñanza cod_tur (.=99)
reshape wide table*, i(nivel_enseñanza) j(cod_tur_r)

cap rename table11 Turno_M 
cap rename table12 Turno_T 
cap rename table13 Turno_N 
cap rename table14 Turno_MT 
cap rename table15 Turno_MN 
cap rename table16 Turno_TN 
cap rename table17 Turno_MTN 
cap rename table199 Turno_Tot
export excel using "$c/`jevo'.xlsx", sheet("Servicios educativos 2", modify) firstrow(var) cell(C3)
restore

}

else {
cap drop _all
set obs 1
cap gen x=.
rename x No_se_identifican_escuelas
export excel using "$c/`jevo'.xlsx", sheet("IE y niveles de enseñanza", modify) firstrow(var) cell(C3)

}

}


**Tasa de alumnos por docente
**-----------------------------
foreach jevo of global ubig { 

**Alumnos
use "$educenso/2019/matricula_01", clear

sort cod_mod anexo tiporeg nroced cuadro tipdato //identificador
drop if strpos(niv_mod, "T") & (cod_mod =="0391151" | cod_mod =="0611525" | cod_mod =="0696385" | cod_mod =="0714725" | cod_mod =="1113224")
merge m:1 cod_mod anexo using "$educenso/2019/padron", nogen keep(1 3) keepus(codcp_inei)
rename codgeo ubigeo
gen ccdd=substr(ubigeo,1,2)
gen prov=substr(ubigeo,1,4)

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo=="`jevo'"
}

if `jevo'>251000 {
keep if codcp_inei=="`jevo'"
}


if _N>0{

egen matriculados= rsum (d01-d20)

**Nivel de enseñanza
gen nivel_enseñanza=1 if strpos(niv_mod, "A")
replace nivel_enseñanza=2 if strpos(niv_mod, "B")
replace nivel_enseñanza=3 if strpos(niv_mod, "F")
replace nivel_enseñanza=4 if strpos(niv_mod, "D")
replace nivel_enseñanza=5 if strpos(niv_mod, "E")
replace nivel_enseñanza=6 if strpos(niv_mod, "K")
replace nivel_enseñanza=7 if strpos(niv_mod, "T")
replace nivel_enseñanza=8 if strpos(niv_mod, "M")
replace nivel_enseñanza=9 if strpos(niv_mod, "L")
label def nivel_enseñanza 	1"Inicial" 2"Primaria" 3"Secundaria" 4"Básica Alternativa" 5"Básica Especial" ///
							6"Superior pedagógica" 7"Superior Tecnológica" 8"Superior Artística" 9"Técnico Productiva"
label value nivel_enseñanza nivel_enseñanza


collapse (sum) matriculados, by(nivel_enseñanza cod_mod)
gen x=1
collapse (count) IE=x (sum) matriculados, by(nivel_enseñanza)
tempfile tot_alumnos
save `tot_alumnos', replace
}


**Docentes
use "$educenso/2019/docentes_01", clear
keep if cuadro=="C301"
drop if strpos(niv_mod, "T") & (cod_mod =="0391151" | cod_mod =="0611525" | cod_mod =="0696385" | cod_mod =="0714725" | cod_mod =="1113224")

merge m:1 cod_mod anexo using "$educenso/2019/padron", nogen keep(1 3) keepus(codcp_inei)
rename codgeo ubigeo
gen ccdd=substr(ubigeo,1,2)
gen prov=substr(ubigeo,1,4)

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo=="`jevo'"
}

if `jevo'>251000 {
keep if codcp_inei=="`jevo'"
}



if _N>0 { 
gen docentes=.
replace docentes=d07+d08+d09+d10+d11+d12+d13 if nroced=="1A" | nroced=="3AP" | nroced=="4AI" 
replace docentes=d07+d08+d09+d10+d11+d12+d13+d14 if nroced=="4AA"
replace docentes=d01+d02 if nroced=="2A"
replace docentes=d17+d18+d19+d20+d21+d22+d23+d24+d25 if nroced=="3AS"
replace docentes=d29+d32 if nroced=="5A" | nroced=="7A"
replace docentes=d21+d24 if nroced=="6A" | nroced=="9A"
replace docentes=d05+d06+d07+d08 if nroced=="8AI" | nroced=="8AP"

**Nivel de enseñanza
gen nivel_enseñanza=1 if strpos(niv_mod, "A")
replace nivel_enseñanza=2 if strpos(niv_mod, "B")
replace nivel_enseñanza=3 if strpos(niv_mod, "F")
replace nivel_enseñanza=4 if strpos(niv_mod, "D")
replace nivel_enseñanza=5 if strpos(niv_mod, "E")
replace nivel_enseñanza=6 if strpos(niv_mod, "K")
replace nivel_enseñanza=7 if strpos(niv_mod, "T")
replace nivel_enseñanza=8 if strpos(niv_mod, "M")
replace nivel_enseñanza=9 if strpos(niv_mod, "L")
label def nivel_enseñanza 	1"Inicial" 2"Primaria" 3"Secundaria" 4"Básica Alternativa" 5"Básica Especial" ///
							6"Superior pedagógica" 7"Superior Tecnológica" 8"Superior Artística" 9"Técnico Productiva"
label value nivel_enseñanza nivel_enseñanza


collapse (sum) docentes, by(nivel_enseñanza)
rename docentes docentes_aula
tempfile tot_docentes
save `tot_docentes', replace


use `tot_alumnos', clear
merge 1:1 nivel_enseñanza using `tot_docentes', nogen
gen tasa_alumno_docente=matriculados/docente
export excel using "$c/`jevo'.xlsx", sheet("Tasa alumnos doc", modify) firstrow(var) cell(C3)

}


else{
cap drop _all
set obs 1
cap gen x=.
rename x No_se_identifican_escuelas
export excel using "$c/`jevo'.xlsx", sheet("Tasa alumnos doc", modify) firstrow(var) cell(C3)

}

}

**Escuelas y matriculados por Idioma de aprendizaje
**---------------------------------------------------
foreach jevo of global ubig { 

**Alumnos
use "$educenso/2019/matricula_01", clear

sort cod_mod anexo tiporeg nroced cuadro tipdato //identificador
drop if strpos(niv_mod, "T") & (cod_mod =="0391151" | cod_mod =="0611525" | cod_mod =="0696385" | cod_mod =="0714725" | cod_mod =="1113224")
merge m:1 cod_mod anexo using "$educenso/2019/padron", nogen keep(1 3) keepus(codcp_inei)
merge m:1 cod_mod anexo using "$educenso/escuelas eib 2019", nogen keep(1 3) keepus(lengua*)
rename codgeo ubigeo
gen ccdd=substr(ubigeo,1,2)
gen prov=substr(ubigeo,1,4)

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo=="`jevo'"
}

if `jevo'>251000 {
keep if codcp_inei=="`jevo'"
}


if _N>0{

**Lengua de enseñanza
gen lengua_enseñanza=lengua_orig1
replace lengua_enseñanza="español" if lengua_enseñanza==""

egen matriculados= rsum (d01-d20)

collapse (sum) matriculados, by(lengua_enseñanza cod_mod)
gen x=1
collapse (count) IE=x (sum) matriculados, by(lengua_enseñanza)
export excel using "$c/`jevo'.xlsx", sheet("Lengua enseñanza", modify) firstrow(var) cell(C3)
}

else{
cap drop _all
set obs 1
cap gen x=.
rename x No_se_identifican_escuelas
export excel using "$c/`jevo'.xlsx", sheet("Lengua enseñanza", modify) firstrow(var) cell(C3)
}

}

**Tasa de alumnos no matriculados
**---------------------------------
foreach jevo of global ubig { 

use "$educenso/2019/matricula_01", clear

sort cod_mod anexo tiporeg nroced cuadro tipdato //identificador
merge m:1 cod_mod anexo using "$educenso/2019/padron", nogen keep(1 3) keepus(codcp_inei)
keep if anexo=="0"
rename codgeo ubigeo
gen ccdd=substr(ubigeo,1,2)
gen prov=substr(ubigeo,1,4)


if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo=="`jevo'"
}

if `jevo'>251000 {
keep if codcp_inei=="`jevo'"
}

if _N>0{

	**Primaria y Secundaria
	preserve
	keep if (nroced=="3AP" | nroced=="3AS") & cuadro=="C201"

	if _N>0{
		egen h_=rsum(d01 d03 d05 d07 d09 d11)
		egen m_=rsum(d02 d04 d06 d08 d10 d12)


		collapse (sum) h_ m_, by(tipdato)
		keep if real(tipdato)<=18
		rename tipdato edad
		rename (h_ m_) (hombres_matricula mujeres_matricula)
		destring edad, replace
		tempfile matriculados
		save `matriculados', replace
	}
	restore

	**Total de personas con edad 5-18 años
	use "$a\censo_pob_shahuindo",clear


	if `jevo'<25 {
	keep if ccdd=="`jevo'"
	}

	if `jevo'>25 & `jevo'<2505 {
	keep if prov=="`jevo'"
	}

	if `jevo'>2505 & `jevo'<251000 {
	keep if ubigeo=="`jevo'"
	}

	if `jevo'>251000 {
	keep if localidad=="`jevo'"
	}


	**Edad y sexo
	**--------------
	preserve
	keep if c5_p4_1>=5 & c5_p4_1<=18
	table c5_p4_1 c5_p2 [iw=fac], c(freq) center col row replace
	drop if mi(c5_p2) | mi(c5_p4_1)
	reshape wide table1, i(c5_p4_1) j(c5_p2)
	rename (c5_p4_1 table11 table12) (edad hombres_tot mujeres_tot)

	tempfile matricula_edad_sexo_tot
	save `matricula_edad_sexo_tot', replace
	restore


	***Tabla final
	use `matriculados', clear
	merge 1:1 edad using `matricula_edad_sexo_tot', nogen 
	replace hombres_tot=hombres_m if hombres_tot<hombres_m
	replace mujeres_tot=mujeres_m if mujeres_tot<mujeres_m
	gen tasa_no_matricula_h=1-(hombres_m/hombres_tot)
	gen tasa_no_matricula_m=1-(mujeres_m/mujeres_tot)
	replace tasa_no_matricula_h=0 if tasa_no_matricula_h<0 & tasa_no_matricula_h<.
	replace tasa_no_matricula_m=0 if tasa_no_matricula_m<0 & tasa_no_matricula_m<.
	sort edad
	export excel using "$c/`jevo'.xlsx", sheet("Tasa no matricula", modify) firstrow(var) cell(C3)

}

else{
cap drop _all
set obs 1
cap gen x=.
rename x No_se_identifican_escuelas
export excel using "$c/`jevo'.xlsx", sheet("Tasa no matricula", modify) firstrow(var) cell(C3)
}

putexcel set "$c/`jevo'.xlsx", sheet("Tasa no matricula") modify
putexcel C2="Nota: Solo considera a matriculados de entre 5 y 18 años"

}

**CENSO NACIONAL AGRARIO 2012 - INEI
**=====================================
global ubig "06 0602 060202 060203" //ambitos de analisis

foreach jevo of global ubig{
putexcel set "$c/`jevo'.xlsx", sheet("CENSO AGRARIO") modify
putexcel C2="Variables de Censo Agrario 2012"

use "$cenagro/Cajamarca/01_ivcenagro_rec01", clear
gen ubigeo=p001+p002+p003
gen ccdd=substr(ubigeo,1,2)
gen prov=substr(ubigeo,1,4)
keep if resultado==1 | resultado==2 //universo que aceptó realizar el censo

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo=="`jevo'"
}

**Redondeo
gen double rp020_01=round(p020_01,.001)
cap drop p020_01
cap rename rp020_01 p020_01
foreach j of varlist wsup03-wsup19{
gen double r`j'=round(`j',.001)
drop `j'
cap rename r`j' `j'
}
format p020_01 wsup03-wsup19 %9.2fc g


**Total de productores según tamaño de Unid. Agropecu
**------------------------------------------------------
putexcel set "$c/`jevo'.xlsx", sheet("parcela_productor") modify

preserve
table wsup02a, c(count p016 sum p019 sum p020_01) center col row replace
order wsup02a table*
label def wsup02a 999 "Total", add
replace wsup02a=999 if mi(wsup02a)
rename (table1 table2 table3) (num_productores num_parcelas tot_ha)
export excel using "$c/`jevo'.xlsx", sheet("parcela_productor", modify) firstrow(var) cell(C3)
restore

tab p019_01
putexcel C13="Unidades agropecuarias sin tierras"
putexcel D13=`r(N)'

**Superficie agrícola
**----------------------
/*FYI: Variable p020_01 es el total de superficie registrada de las UA en la base
- La suma de wsup03a + wsup03b da el total de wsup03
- wsup06(labranza) = wsup07(cult. transitorio) + wsup08(barbecho) + wsup09(descanso)
- wsup18(Superficie cultivada) = wsup07(cult. transitorio) + wsup08(barbecho) + wsup10(cult. permanente) + wsup11(pasto cultivado) + wsup12(cult. forestal) + wsup13(cult. asociado)
- wsup14(pastos naturales) = wsup15 + wsup16
- p020_01(tot sup) = wsup05(otras tierras: casa-caminos) + wsup09(tierras descanso) + wsup14(pastos naturales) + wsup17(montes-bosques) + wsup18(sup cultivada)
- p020_01(tot sup) = wsup03(sup agricola) + wsup04(sup no agricola) + wsup05(otras tierras)

*/
gen sup_7=p020_01
gen sup_2=wsup08
gen sup_3=wsup09
gen sup_4=wsup15+wsup16
gen sup_5=wsup17
gen sup_6=wsup05
gen sup_1=wsup18-wsup08
replace sup_7=sup_1+ sup_2+ sup_3+ sup_4+ sup_5 + sup_6

preserve
collapse (sum) sup_*
gen i=1
reshape long sup_, i(i) j(uso_tierra)
drop i
label def uso_tierra 1"Superficie con cultivos" 2"Tierras en barbecho" ///
				3"Superficie agrícola en descanso" ///
				4"Pastos naturales" 5"Montes y bosques" ///
				6"Superficie dedicada a otros usos" 7"Superficie total"
label val uso_tierra uso_tierra
rename sup_ superficie
label var superficie "Superficie (ha)"
gen porc=superficie/superficie[_N]
export excel using "$c/`jevo'.xlsx", sheet("usos_tierra", modify) firstrow(var) cell(C3)
restore


**Cultivos sembrados
**--------------------
use "$cenagro/Cajamarca/03_ivcenagro_rec02", clear

gen ubigeo=p001+p002+p003
gen ccdd=substr(ubigeo,1,2)
gen prov=substr(ubigeo,1,4)
keep if p024_03!=. //cultivo no especificado

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo=="`jevo'"
}

**Redondeo
gen double rp025=round(p025,.001)
cap drop p025
cap rename rp025 p025
format p025 %9.2fc g


preserve
table p024_03, c(sum p025) row replace
rename table1 Superficie
gen porc=Superficie/Superficie[1]
gsort - porc
gen orden=_n
replace p024_03=100000 if orden>16
collapse (sum) Superficie porc, by(p024_03)
merge 1:1 p024_03 using "$cenagro\cod_cultivos", nogen keep(1 3)
replace cultivo="Resto cultivos" if p024_03==100000
replace tipo="Resto" if cultivo=="Resto cultivos"
replace cultivo="Total" if mi(p024_03)
drop p024_03
gsort -tipo -porc
order tipo cultivo Superficie porc
export excel using "$c/`jevo'.xlsx", sheet("cultivos_cenagro", modify) firstrow(var) cell(C3)
restore

putexcel set "$c/`jevo'.xlsx", sheet("cultivos_cenagro") modify
putexcel C2="Nota: Restringido a superficie con cultivos"

**Tipo de riego
**--------------------
replace p027=5 if p026==2
replace p027=6 if p026==1 & p027==.
label def p027 5"Secano" 6"Riego No especificado", add

preserve
table p027, c(sum p025) center col row replace
order p027 table1
gen porc=table1/table1[1]
gsort p027
label def p027 999 "Total", add
replace p027=999 if mi(p027)
rename table1 sup_ha
export excel using "$c/`jevo'.xlsx", sheet("tipo_riego", modify) firstrow(var) cell(C3)
restore

putexcel set "$c/`jevo'.xlsx", sheet("tipo_riego") modify
putexcel C2="Nota: Restringido a superficie con cultivos"

**Distribución de superficie sembrada por destino de producción
**--------------------------------------------------------------
preserve
table p028 , c(sum p025) center col row replace
order p028 table1
gen porc=table1/table1[1]
gsort p028
label def p028 999 "Total", add
replace p028=999 if mi(p028)
export excel using "$c/`jevo'.xlsx", sheet("destino_prod", modify) firstrow(var) cell(C3)
restore

putexcel set "$c/`jevo'.xlsx", sheet("destino_prod") modify
putexcel C2="Nota: Restringido a superficie con cultivos"

**Estructura de propiedad agrícola
**-----------------------------------
use "$cenagro/Cajamarca/04_ivcenagro_rec02a", clear
gen ubigeo=p001+p002+p003
gen ccdd=substr(ubigeo,1,2)
gen prov=substr(ubigeo,1,4)

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo=="`jevo'"
}


preserve
gen a=1
collapse (count) tot_parcelas=nparcy p037_0*_01 (sum) p037_0*_02 tot_ha=p037_ss, by(a)

forval p=1/5{
	rename p037_0`p'_01 p037a_01_`p'
	rename p037_0`p'_02 p037a_02_`p'
}
drop a

reshape long p037a_01_ p037a_02_, i(tot_parcelas) j(regimen_tenencia)
label def regimen_tenencia 1"Propietario" 2"Comunero" 3"Arrendatario" 4"Posesionario" 5"Otro", add
label val regimen_tenencia regimen_tenencia 
rename (p037a_01_ p037a_02_) (num_parcela sup_ha)
order regimen_tenencia num_parcela sup_ha tot_parcelas sup_ha
export excel using "$c/`jevo'.xlsx", sheet("regimen_tenencia", modify) firstrow(var) cell(C3)
restore


preserve
table p037_01_03, c(sum p037_01_02 count p037_01_01) center row col replace
rename (p037_01_03 table1 table2) (documento_propiedad sup_ha num_parcela)
order documento_propiedad sup_ha num_parcela
replace documento_propiedad=999 if mi(documento_propiedad)
label def documento_propiedad 1"Título en registros públicos" 2"Título no inscrito" 3"Título en trámite" 4"Sin título ni trámite" 999 "Total", modify
label val documento_propiedad documento_propiedad
export excel using "$c/`jevo'.xlsx", sheet("regimen_tenencia", modify) firstrow(var) cell(C10)
restore

putexcel set "$c/`jevo'.xlsx", sheet("regimen_tenencia") modify
putexcel C2="Nota: Superficie total de tierras. Variable documento_propiedad solo considera a superficie de Propietarios"

**Prácticas agricolas
**-------------------------
use "$cenagro/Cajamarca/07_ivcenagro_rec04", clear
gen ubigeo=p001+p002+p003
gen ccdd=substr(ubigeo,1,2)
gen prov=substr(ubigeo,1,4)

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo=="`jevo'"
}

putexcel set "$c/`jevo'.xlsx", sheet("practicas_agri") modify
mat def C=J(9,4,.)

tab p051, matcell(A) //semillas y plantones certificados
mat def C[1,1.]=[A[1,1] , [A[1,1]/`r(N)'] , A[2,1] , [A[2,1]/`r(N)']]

local q=2
foreach k in p052 p053{
replace `k'=1 if `k'==2
tab `k', matcell(A) //abono y fertilizante
mat def C[`q',1.]=[A[1,1] , [A[1,1]/`r(N)'] , A[2,1] , [A[2,1]/`r(N)']]
local q=`q'+1
}


foreach k in 1 2 3 4{
tab p054_0`k', matcell(A) //fertilizante
mat def C[`q',1.]=[A[1,1] , [A[1,1]/`r(N)'] , A[2,1] , [A[2,1]/`r(N)']]
local q=`q'+1
}

foreach k in 6 7{
tab p05`k', matcell(A) //control biologico y certificacion organica
mat def C[`q',1.]=[A[1,1] , [A[1,1]/`r(N)'] , A[2,1] , [A[2,1]/`r(N)']]
local q=`q'+1
}
mat rownames C= semillas abono fertilizante insect_quim insect_noquim herbicida fungicida control_bio cert_organica
mat colnames C= si porc no porc

putexcel C3=matrix(C), names nformat(number_sep_d2)
putexcel C2="Nota: A nivel de productores con Unidades Agropecuarias con tierras"


**Uso de energía electrica, mecanica y animal
**---------------------------------------------
putexcel set "$c/`jevo'.xlsx", sheet("energia_agri") modify
mat def C=J(3,4,.)

local q=1
foreach k in 59 61 63{
tab p0`k', matcell(A) 
mat def C[`q',1.]=[A[1,1] , [A[1,1]/`r(N)'] , A[2,1] , [A[2,1]/`r(N)']]
local q=`q'+1
}
mat rownames C= energia animal tractor
mat colnames C= si porc no porc

putexcel C3=matrix(C), names nformat(number_sep_d2)
putexcel C2="Nota: A nivel de productores con Unidades Agropecuarias con tierras"


**Tipo de Maquinaria y equipos utilizados
**---------------------------------------------
putexcel set "$c/`jevo'.xlsx", sheet("maquinaria_equipos") modify
mat def C=J(15,5,.)
local q=1
forval k=1/9{
tab p065_0`k'_01, matcell(A)
mat def C[`q',1.]=[A[1,1] , [A[1,1]/`r(N)'] , A[2,1] , [A[2,1]/`r(N)']]
egen o=sum(p065_0`k'_03)
mat def C[`q',5]=`=o[1]'
local q=`q'+1
drop o
}

forval k=10/15{
tab p065_`k'_01, matcell(A)
mat def C[`q',1.]=[A[1,1] , [A[1,1]/`r(N)'] , A[2,1] , [A[2,1]/`r(N)']]
egen o=sum(p065_`k'_03)
mat def C[`q',5]=`=o[1]'
local q=`q'+1
drop o
}
mat rownames C= arado_hierro arado_palo cosechadora chaqui fumig_motor fumig_manual ///
molino picadora trilladora bomba_pozo motor_bombeo gen_electr tractor camion bote
mat colnames C= si porc no porc cantidad_productos

putexcel C3=matrix(C), names nformat(number_sep_d2)
putexcel C2="Nota: A nivel de productores con Unidades Agropecuarias con tierras"


**Tipo de ganadería
**---------------------------------------------
use "$cenagro/Cajamarca/08_ivcenagro_rec04a", clear
gen ubigeo=p001+p002+p003
gen ccdd=substr(ubigeo,1,2)
gen prov=substr(ubigeo,1,4)

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo=="`jevo'"
}

label list p067_01
gen cod_animal=1 if p067_01>=671 & p067_01<=677
replace cod_animal=2 if p067_01>=701 & p067_01<=706
replace cod_animal=3 if p067_01>=721 & p067_01<=725
replace cod_animal=4 if p067_01>=741 & p067_01<=746
replace cod_animal=5 if p067_01==751
replace cod_animal=6 if p067_01>=752 & p067_01<=753
replace cod_animal=7 if p067_01>=754 & p067_01<=755
replace cod_animal=8 if p067_01>=756 & p067_01<=757
replace cod_animal=9 if p067_01>=761 & p067_01<=765
label def cod_animal 1"Ganado vacuno" 2"Ganado ovino" 3"Ganado porcino" 4"Alpacas" 5"Ganado caprino" 6"Camelidos" 7"Ganado equino" 8"Cunicultura" 9"Aves de corral"
label val cod_animal cod_animal

collapse (sum) total_anim=p067_03, by(p007x p008 cod_animal)
collapse (sum) tot_anim=total_anim (count) tot_prod=total_anim , by(cod_animal)
export excel using "$c/`jevo'.xlsx", sheet("ganado", modify) firstrow(var) cell(C3)

putexcel set "$c/`jevo'.xlsx", sheet("ganado") modify
putexcel C2="Nota: Solo para productores pecuarios"

}


global ubig "06 0602 060202 060203" //ambitos de analisis

foreach jevo of global ubig{

**Otras actividades agricolas
**----------------------------
use "$cenagro/Cajamarca/09_ivcenagro_rec04b", clear
gen ubigeo=p001+p002+p003
gen ccdd=substr(ubigeo,1,2)
gen prov=substr(ubigeo,1,4)

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

if `jevo'>25 & `jevo'<2505 {
keep if prov=="`jevo'"
}

if `jevo'>2505 & `jevo'<251000 {
keep if ubigeo=="`jevo'"
}

putexcel set "$c/`jevo'.xlsx", sheet("subprod_agri") modify
mat def C=J(6,4,.)

local r=1
foreach w of varlist p104_01-p104_06{
tab `w' , matcell(A)
mat def C[`r',1.]=[A[1,1] , [A[1,1]/`r(N)'] , A[2,1] , [A[2,1]/`r(N)']]
*mat def C=C\B
local r=`r'+1
}
mat rownames C= artesania abarrotes derivados mecanica alquiler otro
mat colnames C= si porc no porc

putexcel C3=matrix(C), names nformat(number_sep_d2)
putexcel C2="Nota: Incluye a productores con Unidades Agropecuarias sin tierras"

**Practicas pecuarias
**---------------------
putexcel set "$c/`jevo'.xlsx", sheet("practicas_pec") modify
mat def C=J(6,4,.)

local q=1
forval k=79/84 {
tab p0`k', matcell(A) 
mat def C[`q',1.]=[A[1,1] , [A[1,1]/`r(N)'] , A[2,1] , [A[2,1]/`r(N)']]
local q=`q'+1
}
mat rownames C= vacuna baña dosificacion balanceados inseminación semental
mat colnames C= si porc no porc

putexcel C3=matrix(C), names nformat(number_sep_d2)
putexcel C2="Nota: Solo para productores pecuarios"

**Asistencia técnica
**---------------------
putexcel set "$c/`jevo'.xlsx", sheet("asist_tecnica") modify
mat def C=J(5,4,.)

local q=1
forval k=1/5 {
recode p087_0`k' (.=2)
tab p087_0`k', matcell(A) 
mat def C[`q',1.]=[A[1,1] , [A[1,1]/`r(N)'] , A[2,1] , [A[2,1]/`r(N)']]
local q=`q'+1
}
mat rownames C= cultivos ganadería manejo_conservacion producc_comercializacion negocio_comercializa
mat colnames C= si porc no porc

putexcel C3=matrix(C), names nformat(number_sep_d2)
putexcel C2="Nota: Incluye a productores con Unidades Agropecuarias sin tierras"

**Credito
**---------------------
putexcel set "$c/`jevo'.xlsx", sheet("credito") modify
mat def C=J(5,4,.)

recode p092 (.=2)

tab p092, matcell(A) 
mat def C[1,1.]=[A[1,1] , [A[1,1]/`r(N)'] , A[2,1] , [A[2,1]/`r(N)']]

local q=2
forval k=1/4 {
recode p094_0`k' (.=2)
tab p094_0`k', matcell(A) 
mat def C[`q',1.]=[A[1,1] , [A[1,1]/`r(N)'] , A[2,1] , [A[2,1]/`r(N)']]
local q=`q'+1
}

mat rownames C= recibió_prestamo insumos_producc compra_maquinaria compra_herramientas comercialización
mat colnames C= si porc no porc

putexcel C3=matrix(C), names nformat(number_sep_d2)
putexcel C2="Nota: Incluye a productores con Unidades Agropecuarias sin tierras"

}


**ENCUESTA NACIONAL AGRARIO 2019 - INEI
**=====================================

global ubig "06" //ambitos de analisis

foreach jevo of global ubig{
putexcel set "$c/`jevo'.xlsx", sheet("ENCUESTA AGRARIA") modify
putexcel C2="Variables de Encuesta Agraria 2019"

**Superficie cosechada
**---------------------------------
use "$encagro/2019/02_Cap200ab", clear
gen ubigeo=ccdd+ccpp+ccdi
rename ccpp prov

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

gen produccion_tn=p219_cant_1*p219_equiv_kg/1000

preserve
table p204_nom [iw=factor], c(sum p217_sup_ha sum produccion_tn ) center row col replace
gen rendimiento=table2/table1
gsort -table1
gen orden=_n
replace p204_nom="RESTO CULTIVOS" if orden>26
cap drop orden
collapse (sum) table* rendimiento, by(p204_nom)
replace p204_nom="Total" if p204_nom==""
rename (p204_nom table1 table2) (Cultivo Sup_cosecha Produccion_tn)
export excel using "$c/`jevo'.xlsx", sheet("culivo_cosecha_producc", modify) firstrow(var) cell(C3)
restore

**Precio de chacra
**----------------------
preserve
table p204_nom [iw=factor] if p221_1==1, c(sum p217_sup_ha mean p220_1_pre_kg) center row col replace
gsort -table1
gen orden=_n
replace p204_nom="RESTO CULTIVOS" if orden>26
cap drop orden
collapse (sum) table* , by(p204_nom)
drop table1
replace p204_nom="Total" if p204_nom==""
rename (p204_nom table2) (Cultivo Preciokg_chacra)
export excel using "$c/`jevo'.xlsx", sheet("precio chacra", modify) firstrow(var) cell(C3)
restore

**Composición de Ingresos anuales por cultivos
**--------------------------------------------

**Calculamos total de productores
preserve
use "$encagro/2019/01_Cap100_1", clear
gen ubigeo=ccdd+ccpp+ccdi
rename ccpp prov
keep if ccdd=="`jevo'"
collapse (count) anio [iw=fac], by(ubigeo conglomerado nselua ua)
tempfile prod_cultivos
save `prod_cultivos', replace
restore

**Calculamos ingreso total por cultivo
preserve
collapse (sum) p220_1_val [iw=factor], by(ubigeo conglomerado nselua ua p204_nom)
merge m:1 ubigeo conglomerado nselua ua using `prod_cultivos', nogen
drop if p220_1_val ==0 | p220_1_val ==.
table p204_nom , c(sum p220_1_val sum anio) center row col replace
format table* %15.0fc
gsort -table1
gen orden=_n
replace p204_nom="RESTO CULTIVOS" if orden>26
cap drop orden
collapse (sum) table* , by(p204_nom)
replace p204_nom="TOTAL" if p204_nom==""
gen Ing_xproductor=table1/table2
rename (p204_nom table1 table2) (Cultivo Ingreso_anual Cant_productor)
export excel using "$c/`jevo'.xlsx", sheet("ingresos cultivos", modify) firstrow(var) cell(C3)
restore

**Ingresos promedios segun destino de produccion
**-----------------------------------------------
forval p=1/5{
preserve
collapse (sum) ingr_`p'=p220_1_val (count) tot_cosechas`p'=p205_tot [iw=factor] if p223_`p'==1, by(p204_nom)
gen ingr_prom_xcosecha`p'=ingr_`p'/tot_cosechas`p'
cap drop ingr_`p' tot_cosechas`p'
tempfile destino_`p'
save `destino_`p'', replace
restore
}

use `destino_1', clear
forval p=2/5{
merge 1:1 p204_nom using `destino_`p'', nogen
}

local p=1
foreach x in mcdo_local mcdo_reg mcdo_ext agroindust mcdo_lima {
rename ingr_prom_xcosecha`p' ing_prom_xcosecha_`x'
local p=`p'+1
}
egen tot=rsum(ing_prom_xcosecha_mcdo_local-ing_prom_xcosecha_mcdo_lima)
gsort -tot
gen orden=_n
replace p204_nom="RESTO CULTIVOS" if orden>26
cap drop orden
collapse (sum) ing_prom_xcosecha_* , by(p204_nom)
replace p204_nom="TOTAL" if p204_nom==""
export excel using "$c/`jevo'.xlsx", sheet("ingr destino prod", modify) firstrow(var) cell(C3)


**Composición de ingreso pecuario
**---------------------------------
use "$encagro/2019/10_Cap400a_1", clear
gen ubigeo=ccdd+ccpp+ccdi
rename ccpp prov

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

cap drop ingreso cant_vendida
egen ingreso=rsum(p403a_4_1_val p403a_4_2_val)
egen cant_vendida=rsum(p403a_4_1_ent p403a_4_2_ent)
drop if p401a>16

preserve
table p401a [iw=factor], c(sum ingreso sum cant_vendida) center row col replace
drop if table1==0 & table2==0
order p401a table*
gen porc_ingr=table1/table1[1]
gsort p401a
label def P401A 999 "Total", add
replace p401a=999 if mi(p401a)
rename (p401a table1 table2) (Pecuario Ingreso Cant_vendida)
export excel using "$c/`jevo'.xlsx", sheet("ingreso_pecuario", modify) firstrow(var) cell(C3)
restore

**Tipo de subproductos agricolas
**-------------------------------

use "$encagro/2019/07_Cap200d", clear
gen ubigeo=ccdd+ccpp+ccdi
rename ccpp prov

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

gen produccion_tn=p229h_cant_ent*p229h_equiv/1000

preserve
table p229g_nom [iw=factor], c(sum produccion_tn) center row col replace
order p229g_nom table1
gsort -table1
replace p229g_nom ="Total" if p229g_nom==""
rename (p229g_nom  table1) (Subproducto_agricola Produccion_tn)
export excel using "$c/`jevo'.xlsx", sheet("subproducto agricola", modify) firstrow(var) cell(C3)
restore

**Costos de produccion 
**----------------------

**Calculamos total de ha cosechadas
preserve
use "$encagro/2019/02_Cap200ab", clear
gen ubigeo=ccdd+ccpp+ccdi
rename ccpp prov

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

collapse (sum) p217_sup_ha (count) tot_cosechas=p205_tot [iw=factor], by(p204_nom)
tempfile sup_ha
save `sup_ha', replace
restore

**Costos de produccion
use "$encagro/2019/08_Cap200e", clear
gen ubigeo=ccdd+ccpp+ccdi
rename ccpp prov

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

rename p234_nom p204_nom
collapse (sum) semillas=p235_val abono=p237_val fertilizante=p239 plagicidas=p241 [iw=factor], by(p204_nom)
merge 1:1 p204_nom using `sup_ha', nogen keep(1 3) keepus(tot_cosechas) 
drop if p204_nom=="" | p204_nom==" "

gsort -tot
gen orden=_n
replace p204_nom="RESTO CULTIVOS" if orden>26
cap drop orden
collapse (sum) semillas abono fertilizante plagicidas tot_cosechas , by(p204_nom)
replace p204_nom="TOTAL" if p204_nom==""

foreach x in semillas abono fertilizante plagicidas {
replace `x'=`x'/tot_cosechas
rename `x' `x'_costoxcosecha
}

export excel using "$c/`jevo'.xlsx", sheet("costos producc", modify) firstrow(var) cell(C3)


**Derivados pecuarios
**---------------------
use "$encagro/2019/12_Cap400c", clear
gen ubigeo=ccdd+ccpp+ccdi
rename ccpp prov

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

drop if p419_nom==""
gen produccion=p420_cant_ent*p420_equiv
preserve
table p419_nom [iw=factor], c(sum produccion) center row col replace
order p419_nom table1
gen porc=table1/table1[1]
gsort p419_nom
replace p419_nom="Total" if p419_nom==""
rename (p419_nom table1) (Derivado_pec Produccion_kg)
export excel using "$c/`jevo'.xlsx", sheet("derivado_pecua", modify) firstrow(var) cell(C3)
restore
}

**VARIABLES ENAHO 2019 - INEI
**============================
global ubig "06" //ambitos de analisis

foreach jevo of global ubig{
putexcel set "$c/`jevo'.xlsx", sheet("ENAHO") modify
putexcel C2="Variables de ENAHO 2019"

use "$enaho/2019/enaho01a-2019-500", clear
gen ccdd=substr(ubigeo,1,2)

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

**Ingreso laboral mensual segun actividad economica
**---------------------------------------------------
gen ingreso_lab=i524a1/12
replace ingreso_lab=i530a/12 if mi(ingreso_lab)

**Actividad economica
destring p506r4, replace
gen  Sector4=1  if p506r4>=111 & p506r4<=240 //agropecuaria
replace Sector4=2  if p506r4>=311 & p506r4<=322 //pesca
replace Sector4=3  if p506r4>=510 & p506r4<=990 //mina
replace Sector4=4  if p506r4>=1010 & p506r4<=3320 //manufac
replace Sector4=5  if p506r4>=3510 & p506r4<=3530 //electricidad
replace Sector4=6  if p506r4>=3600 & p506r4<=3900 //agua
replace Sector4=7  if p506r4>=4100 & p506r4<=4390 //construccion
replace Sector4=8  if p506r4>=4510 & p506r4<=4799 //comercio
replace Sector4=9  if p506r4>=4911 & p506r4<=5320 // transporte y almacenamiento
replace Sector4=10  if p506r4>=5510 & p506r4<=5630 // actividades de alojamiento y serv comidas
replace Sector4=11  if p506r4>=5811 & p506r4<=6399 // informacion y comunicaciones
replace Sector4=12  if p506r4>=6411 & p506r4<=6630 // actividades financieras
replace Sector4=13  if p506r4>=6810 & p506r4<=6820 // actividades inmobiliarias
replace Sector4=14  if p506r4>=6910 & p506r4<=7500 // Actividades profesionales
replace Sector4=15  if p506r4>=7710 & p506r4<=8299 // Actividades servicios administrativos
replace Sector4=16  if p506r4>=8411 & p506r4<=8430 // Administracion publica
replace Sector4=17  if p506r4>=8510 & p506r4<=8550 // EnseÃ±anza
replace Sector4=18  if p506r4>=8610 & p506r4<=8890 // Atencion salud y asistencia social
replace Sector4=19  if p506r4>=9000 & p506r4<=9329 // Actividades artÃ­sticas
replace Sector4=20  if p506r4>=9411 & p506r4<=9609 // Otras actividades de servicios
replace Sector4=21  if p506r4>=9700 & p506r4<=9820 // Act hogares como empleadores
replace Sector4=22 if p506r4>=9900 & p506r4<=9999 // Actividades organos extraterritoriales
label define Sector4 1  "Agricultura y Ganaderia" ///
2  "Pesca" ///
3  "Explotacion de minas y canteras" ///
4  "Industrias manufactureras" ///
5  "Suministro de electricidad, gas, vapor y aire acondicionado" ///
6  "Suministro de agua, evacuacion aguas residucales, gestion desechos y descontaminacion" ///
7  "Construccion" ///
8  "Comercio" ///
9  "Transporte y almacenamiento" ///
10  "Actividades de alojamiento y servicio de comidas" ///
11 "Informacion y comunicaciones" ///
12 "Actividades financieras y de seguros" ///
13 "Actividades inmobiliarias" ///
14 "Actividades profesionales, cientificas y tecnicas" ///
15 "Actividades de servicios administrativos y de apoyo" ///
16 "Administracion publica y defensa, planes de seguridad social de afiliacion obligatoria" ///
17 "Enseñanza (privada)" ///
18 "Actividades de atencion salud humana y de asistencia social" ///
19 "Actividades artisticas, de entretenimiento y recreativas" ///
20 "Otras actividades de servicios" ///
21 "Actividades de los hogares como empleadores" ///
22 "Actividades de organizaciones y organos extraterritoriales" 
label values Sector4 Sector4
recode Sector4 (1=1 "Agricultura y ganadería") (2=2 "Pesca") (3=3 "Minería")  ///
(4=4 "Manufactura") (5 6=5 "Electricidad y agua") (7=6 "Construcción") ///
(8=7 "Comercio") (9/22=8 "Servicios"), g(act_econ)

preserve
table act_econ [iw=fac500a], c(freq mean ingreso_lab) col row center replace
label def act_econ 99 "Total", add
recode act_econ (.=99)
rename (table1 table2) (Frec Ingreso_lab)
gsort act_econ
order act_econ  Frec Ingreso_lab
export excel using "$c/`jevo'.xlsx", sheet("ingreso_lab mensual", modify) firstrow(var) cell(C3)
restore

putexcel set "$c/`jevo'.xlsx", sheet("ingreso_lab mensual") modify
putexcel C2="Nota: A nivel poblacional. Restringido a PEA"

**Composicion ingreso mensual 
**-----------------------------
egen r6_1    = rowtotal(i524a1 d529t i530a d536), m
egen r6_2    = rowtotal(i538a1 d540t i541a d543), m
egen  r6_3    = rowtotal(d544t d558t)
gen r6_4 = d556t1
gen r6_5 = d557t

preserve
gen x=1
collapse (mean) r6_* [iw=fac500a], by(x)
reshape long r6_, i(x) j(fuentes_ing)
drop x
rename r6_ ingreso_prom_mensual
replace ing=ing/12 //montos anualizados convertidos a mensual
label def fuentes_ing 1"Ingreso ocupacion principal" 2"Ingreso ocupación seucndaria" 3"Ingresos extraordinarios" 4"Transferencias" 5"Rentas de propiedad", add
label val fuentes_ing fuentes_ing
export excel using "$c/`jevo'.xlsx", sheet("composicion ingreso", modify) firstrow(var) cell(C3)
restore


**Subempleo visible (por horas)
**--------------------------------------------
rename i513t horas
gen subempleo=1 if (horas<35 & !mi(horas))
replace subempleo=2 if (horas>=35 & !mi(horas))

label def subempleo 1"Trabajador subempleado" 2"Trabajador no subempleado", add
label val subempleo subempleo

preserve
table subempleo [iw=fac500a], c(freq) col row center replace
gen porc=table1/table1[1]
label def subempleo 99 "Total", add
recode subempleo (.=99)
rename (table1) (Frec)
gsort subempleo
order subempleo  Frec porc
export excel using "$c/`jevo'.xlsx", sheet("subempleo", modify) firstrow(var) cell(C3)
restore

putexcel set "$c/`jevo'.xlsx", sheet("subempleo") modify
putexcel C2="Nota: A nivel poblacional. Restringido a PEA"


**Tipo de negocio segun registro en SUNAT
**--------------------------------------------
use "$enaho/2019/enaho04-2019-1-preg-1-a-13", clear
gen ccdd=substr(ubigeo,1,2)

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

preserve
table e1 [iw=fac], c(freq) col row center replace
gen porc=table1/table1[1]
label def e1 99 "Total", add
recode e1 (.=99)
rename (table1) (Frec)
gsort e1
order e1  Frec porc
export excel using "$c/`jevo'.xlsx", sheet("tipo negocio", modify) firstrow(var) cell(C3)
restore

putexcel set "$c/`jevo'.xlsx", sheet("tipo negocio") modify
putexcel C2="Nota: Restringido a Trabajadores indepedientes"

**Rubro de actividad de negocio
**--------------------------------------------
putexcel set "$c/`jevo'.xlsx", sheet("tipo actividad") modify
mat def C=J(3,4,.)

local q=1
foreach k in a b c {
tab e13`k' [iw=fac], matcell(A)
mat def C[`q',1.]=[A[2,1] , [A[2,1]/`r(N)'] , A[1,1] , [A[1,1]/`r(N)']]
local q=`q'+1
}
mat rownames C= produccion_entracción_bien compra_venta_mercadería prestación_servicios
mat colnames C= si porc no porc
putexcel C3=matrix(C), names nformat(number_sep_d2)

putexcel set "$c/`jevo'.xlsx", sheet("tipo actividad") modify
putexcel C2="Nota: Restringido a Trabajadores indepedientes"

**Tiempo de negocio
**-------------------
gen aa=e6b/12
egen tiempo_neg=rsum(e6a aa)
replace tiempo_neg=. if mi(e6a) & mi(aa)

preserve
table e1 [iw=fac], c(mean tiempo_neg) col row center replace
drop if table1==.
label def e1 99 "Total", add
recode e1 (.=99)
rename (table1) (Tiempo_neg_años)
gsort e1
order e1 Tiempo_neg_años
export excel using "$c/`jevo'.xlsx", sheet("tiempo negocio", modify) firstrow(var) cell(C3)
restore

**Ingresos y gastos en negocio
**------------------------------
use "$enaho/2019/enaho04-2019-2-preg-14-a-22", clear
gen ccdd=substr(ubigeo,1,2)

if `jevo'<25 {
keep if ccdd=="`jevo'"
}

collapse (mean) montotot [iw=fac], by(modulo) 
export excel using "$c/`jevo'.xlsx", sheet("ingresos_gastos", modify) firstrow(var) cell(C3)

}



