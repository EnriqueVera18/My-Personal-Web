
clear all
set more off
set excelxlsxlargefile on 

**Definimos directorio (solo modificar global path)
**==================================================
*global path "C:\Users\HP\OneDrive - Macroconsult S.A\2022.11.22\Estimación" 
global path "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\OIT\Economía del Cuidado\Estimación" 
global a "$path\\a_Do"
global b "$path\\b_BD"
global c "$path\\c_Temp"
global d "$path\\d_Tabla"
global bd "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\BBDD"
global m "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\MAPAS"

**Definimos carpeta que guardará los resultados
**==============================================
confirmdir "$d\\ENAHO"

	if `r(confirmdir)'==0 { 
	global d "$d\\ENAHO"
	}

	else{
	mkdir "$d\\ENAHO" //Si no existe el directorio, se genera la carpeta
	global d "$d\\ENAHO"
	}

********************************************************************************
**						TRABAJADORES DEL CUIDADO - ENAHO					  **
********************************************************************************

*-------------------------------------------------------------------------------
* CARACTERÍSTICAS SOCIOECONÓMICAS Y LABORALES DE LA POBLACION
*-------------------------------------------------------------------------------

use "$b/ENAHO_consolidado_2021", clear

* Poblacion total
cap drop pob
gen pob= 	(p204==1 & p205==2) | /// miembro de hogar que vive +30dias
			(p204==2 & p206==1)  // no miembro de hogar que vive +30dias

* Edad
cap drop edadg
recode p208a 	(0/9=1 "De 0 a 9") (10/19=2 "De 10 a 19") (20/29=3 "De 20 a 29") ///
				(30/39=4 "De 30 a 39") (40/49=5 "De 40 a 49") (50/59=6 "De 50 a 59") ///
				(60/69=7 "De 60 a 69") (70/179=8 "De 70 a más") if pob==1, gen(edadg) //  Rangos de edad (como edadg) 

cap drop g_etario
recode p208a 	(0/4=.) (5/13 = 1 "De 5 a 13") (14/17 = 2 "De 14 a 17") (18/29 = 3 "De 18 a 29") ///
				(30/64 = 4 "De 30 a 64") (65/179=5 "De 65 a más") if pob==1, gen(g_etario) //  Grupos etarios

* Sexo
rename p207 sexo
label def sexo 1"Hombre" 2"Mujer"
label val sexo sexo

* Ambito urbano/rural
cap drop ambito
gen ambito=1 if estrato>0 & estrato<7 & !mi(estrato) & pob==1
replace ambito=2 if estrato>6 & !mi(estrato) & pob==1
label def ambito 1 "Urbano" 2 "Rural"
label val ambito ambito

* Peruanos
tostring p401g, replace
cap drop extranjero
gen extranjero = length(p401g)<5 & p401g!="."

* Poblacion de 5 a 17 años
cap drop pob5a17
gen pob5a17 = inlist(g_etario,1,2)

* PET
cap drop pet
gen pet = p208a>=14 if pob==1

* PEA
gen pea=(ocu500==1|ocu500==2)==1 if pet==1
recode pea (0=2)
label define pea 1 "PEA" 2 "PEI"
label values pea pea

* PEI
gen pei = (p545 == 2) 
replace pei = . if p545 == . 

* PEA ocupada
gen pea_ocupada=(ocu500==1)==1 if pea==1
recode pea_ocupada (0=2)
label define pea_ocupada 1 "pea ocupada" 2 "pea desocupada"
label values pea_ocupada pea_ocupada

* Trabaja
gen trabaja = pea_ocupada==1 if pet==1

* Departamento
cap drop dpto
gen dpto= real(substr(ubigeo,1,2))
replace dpto=15 if (dpto==7)
label define dpto 	1"Amazonas" 2"Ancash" 3"Apurimac" 4"Arequipa" 5"Ayacucho" 6"Cajamarca" 8"Cusco" 9"Huancavelica" 10"Huanuco" 11"Ica" ///
					12"Junin" 13"La_Libertad" 14"Lambayeque" 15"Lima" 16"Loreto" 17"Madre_de_Dios" 18"Moquegua" 19"Pasco" 20"Piura" 21"Puno" 22"San_Martin" ///
					23"Tacna" 24"Tumbes" 25"Ucayali" 
lab val dpto dpto 

* Acceso integrado de servicios
cap drop serv_basico
gen serv_basico = 		inlist(p110,1,2) & ///agua
						inlist(p111,1,2) & ///desague
						inlist(p1121,1) & ///alumbrado
						inlist(p1141,0) // acceso a telecomunicaciones (fijo, cel, cable e internet)

* Pobreza monetaria
cap drop pobreza_m
gen pobreza_m = inlist(pobreza,1,2)

*Pobreza no monetaria
cap drop pobreza_nm
egen pobreza_nm = rowtotal(nbi1-nbi5)
recode pobreza_nm (0=0) (1/4=1)

* Etnia
cap drop etnia
recode p558c (5 6 7 = 1 "Blanco, mestizo")  (1 2 3 9= 2 "Quechua, aimara e Indígena") (4 = 3 "Afroperuano") (8 = 4 "No sabe"), gen(etnia)

* Estado civil
rename p209 estado_civil

* Migrante provincial
tostring p401g p401g2, replace
replace p401g="0"+p401g if length(p401g)==5
replace p401g2="0"+p401g2 if length(p401g2)==5
gen prov_act=substr(ubigeo,1,4)
gen prov_madre=substr(p401g2,1,4)
gen migrante_prov= prov_act!=prov_madre if pob==1 //se considera migrante si se encuentra en una provincia distinta a donde nacio
label def migrante_prov 0"No migrante" 1"Migrante"
label val migrante_prov migrante_prov

* Nivel educativo
cap drop nivel_edu
gen nivel_edu= 1 if (p301a==1 | p301a==2 | p301a==3 | p301a==4 | p301a==5 | p301a==12)
replace nivel_edu=2 if (p301a==6 | p301a==7 | p301a==9 )
replace nivel_edu=3 if (p301a==8 | p301a==10 | p301a==11)
recode nivel_edu (1 2 3=.) if pob!=1
label define nivel_edu 1 "primaria" 2 "secundaria" 3 "superior"
label values nivel_edu nivel_edu

* Años de educación
gen educ=.
replace educ=0 if p301a<=2
replace educ=p301b if p301a==3 & p301b!=0
replace educ=p301c if p301a==3 & p301c!=.
replace educ = 6 if p301a==4
replace educ = 6+ p301b if p301a==5
replace educ = 11 if p301a==6
replace educ = 11+ p301b if inlist(p301a, 7, 8, 9, 10)
replace educ = 16+ p301b if p301a==11
replace educ = . if pob!=1
gen educ2 = educ*educ

* Tasa total de matricula (Pob de 5 a 17 matriculado respecto a total de 5 a 17)
gen pers_prim = inlist(p208a,5,6,7,8,9,10,11)
gen pers_sec = inlist(p208a,12,13,14,15,16,17)
gen matricula_prim = p306==1 & inlist(p208a,5,6,7,8,9,10,11)
gen matricula_sec = p306==1 & inlist(p208a,12,13,14,15,16,17)

* Tasa total de asistencia escolar (Pob de 5 a 17 que asiste respecto a total de 5 a 17)
gen asist_prim = p307==1 & inlist(p208a,5,6,7,8,9,10,11)
gen asist_sec = p307==1 & inlist(p208a,12,13,14,15,16,17)

* Tasa Desercion escolar (% Pob con estudios incompletos que no se encuentra matriculada respecto a total con estudios incompletos)
gen prim_incomp = inlist(p208a,7,8,9,10,11,12,13,14) & p304a==2 & p304c<6
gen sec_incomp = inlist(p208a,13,14,15,16,17,18,19) & p304a==3 & p304b<5
gen prim_nomatr = inlist(p208a,7,8,9,10,11,12,13,14) & p304a==2 & p304c<6 & p306==2
gen sec_nomatr = inlist(p208a,13,14,15,16,17,18,19) & p304a==3 & p304b<5 & p306==2

* Atraso escolar (Matriculados con dos años mas que edad teorica segun grado)
gen atraso_prim = 	p304a==2 & p304c==1 & p208a>=8 | /// con 6 años se cursa 1° grado
					p304a==2 & p304c==2 & p208a>=9 | /// con 7 años se cursa 2° grado
					p304a==2 & p304c==3 & p208a>=10 | /// con 8 años se cursa 3° grado
					p304a==2 & p304c==4 & p208a>=11 | /// con 9 años se cursa 4° grado
					p304a==2 & p304c==5 & p208a>=12 | /// con 10 años se cursa 5° grado
					p304a==2 & p304c==6 & p208a>=13 // con 11 años se cursa 6° grado

gen atraso_sec = 	p304a==3 & p304b==1 & p208a>=14 | /// con 12 años se cursa 1° sec
					p304a==3 & p304b==2 & p208a>=15 | /// con 13 años se cursa 2° sec
					p304a==3 & p304b==3 & p208a>=16 | /// con 14 años se cursa 3° sec
					p304a==3 & p304b==4 & p208a>=17 | /// con 15 años se cursa 4° sec
					p304a==3 & p304b==5 & p208a>=18 // con 16 años se cursa 5° sec

* Repitencia escolar (desaprobación y retirados)
gen repite_prim = matricula_prim==1 & inlist(p305,2,3)
gen repite_sec = matricula_sec==1 & inlist(p305,2,3)
				
* Seguro de salud
cap drop temp_seguro
cap drop seguro_salud
egen temp_seguro= anycount(p4191- p4198) if pob==1, v(2)
recode temp_seguro (0=.) (8=0 "No tiene seguro") (1/7=3 "Tiene seguro"), g(seguro_salud)
replace seguro_salud = 1 if p4191==1 & seguro_salud==3
replace seguro_salud = 2 if p4195==1 & seguro_salud==3
label def seguro_salud 0"No tiene seguro" 1"ESSALUD" 2 "SIS" 3"Otro seguro", modify
label val seguro_salud seguro_salud

* Sistema de pensiones
cap drop pensiones
gen pensiones= p558a5==0 if p558a5!=. & pob==1
replace pensiones = 1 if p558a1==1 & pob==1
replace pensiones = 2 if (p558a2==2 | p558a3==3 | p558a4==4) & pob==1
label def pensiones 0"No afiliado" 1"Afiliado a SPP" 2 "Afiliado a ONP", modify
label val pensiones pensiones

* Tiene hijos
cap drop temp_h
gen temp_h=(p203==3 | p203==5) 
cap drop hijos
bys ubigeo conglome vivienda hogar: egen hijos=sum(temp_h) //toma valor 1 si hay hijos en el hogar
recode hijos (1/15=0) if (p203!=1 & p203!=2) | edad<=12 //solo para los jefes y esposos, mayores de 12a
replace hijos=1 if p203==6 & p203==4 //los suegros y padres
replace hijos=1 if p203==3 & p203==4 | p203==6 //si en la casa hay un nieto, se asume que el hijo es padre
replace hijos=. if p203==0 | p203==. | pob!=1
recode hijos (1/15=1)

* Enfermo
gen enfermo=(p401==1 | p4023==1 | p4024==1) if pob==1
bys ubigeo conglome vivienda hogar: egen enfermo_h = sum(enfermo)
recode enfermo_h (1/1000000 = 1)

*Discapacitados
recode p401h* (2=0)
cap drop discapacidad
egen discapacidad=rowtotal(p401h1-p401h6) if pob==1
recode discapacidad (2/8=1)
bys ubigeo conglome vivienda hogar: egen discap_h = sum(discapacidad)
recode discap_h (1/1000000 = 1)

* Estudia o no
gen estudia= p306==1 if p306!=. & pob==1
label def estudia 0"No estudia" 1"Estudia"
label val estudia estudia

* NNA en el hogar
gen nna=p208a<=17 if pob==1
bys ubigeo conglome vivienda hogar: egen nna_h = sum(nna)
recode nna_h (1/1000000 = 1)

* Infantes en el hogar
gen infante=p208a<=5 if pob==1
bys ubigeo conglome vivienda hogar: egen infante_h = sum(infante)
recode infante_h (1/1000000 = 1)

* Adulto mayor
gen mayor=p208a>=65 if pob==1
bys ubigeo conglome vivienda hogar: egen mayor_h = sum(mayor)
recode mayor_h (1/1000000 = 1)

* Demandantes de cuidados en el hogar
cap drop demanda
egen demanda = rowtotal(nna_h mayor_h discap_h)
cap drop demanda_cuid
gen demanda_cuid=.
replace demanda_cuid= 0 if demanda==0
replace demanda_cuid= 1 if nna_h==1 & demanda==1
replace demanda_cuid= 2 if mayor_h==1 & demanda==1
replace demanda_cuid= 3 if discap_h==1 & demanda==1
replace demanda_cuid= 4 if mayor_h==1 & discap_h==1 & demanda==2
replace demanda_cuid= 5 if nna_h==1 & discap_h==1 & demanda==2
replace demanda_cuid= 6 if nna_h==1 & mayor_h==1 & demanda==2
replace demanda_cuid= 7 if nna_h==1 & mayor_h==1 & discap_h==1 & demanda==3
label def demanda_cuid 	0"Sin demandantes" 1"NNA" 2"Adulto mayor" 3"Discapacitado" 4"Adulto mayor y discapacitado" ///
						5"NNA y discapacitado" 6"NNA y adulto mayor" 7"NNA, adulto mayor y discapacitado", modify
label val demanda_cuid demanda_cuid

* Demandantes de cuidados en el hogar - Otra forma
cap drop demanda2
egen demanda2 = rowtotal(infante_h mayor_h discap_h)
cap drop demanda_cuid2
gen demanda_cuid2=.
replace demanda_cuid2= 0 if demanda2==0
replace demanda_cuid2= 1 if infante_h==1 & demanda2==1
replace demanda_cuid2= 2 if (mayor_h==1 | discap_h==1) & inlist(demanda2, 1,2,3)
label def demanda_cuid2 	0"Sin demandantes" 1"Infante" 2"Otros demandantes", modify
label val demanda_cuid2 demanda_cuid2


* Estructura familiar
cap drop familias
gen familias = 1 if inlist(estado_civil,3,4,5,6) & infante_h==0 //sin pareja sin hijos - vive solo
replace familias = 2 if inlist(estado_civil,1,2) & infante_h==0 //en pareja sin hijos
replace familias = 3 if inlist(estado_civil,1,2) & infante_h==1 & mayor_h==0 //en pareja con hijos
replace familias = 4 if inlist(estado_civil,1,2) & infante_h==1 & mayor_h==1 //en pareja con hijos y adulto mayor
label def familias 1"Sin pareja sin hijos" 2"Con pareja sin hijos" 3"Con pareja e hijos" ///
					4"Con pareja, hijos y adulto mayor"
label val familias familias

cap drop familias2
gen familias2 = 1 if inlist(estado_civil,3,4,5,6) & infante_h==0 & mayor_h==0 & discap_h==0 //sin pareja y ningun demandante de cuidado (hijos, adulto mayor, discapacitado)
replace familias2 = 2 if inlist(estado_civil,3,4,5,6) & infante_h==1 & mayor_h==0 & discap_h==0 //sin pareja y con hijos
replace familias2 = 3 if inlist(estado_civil,3,4,5,6) & infante_h==0 & mayor_h==1 & discap_h==0 //sin pareja y con adulto mayor
replace familias2 = 4 if inlist(estado_civil,3,4,5,6) & infante_h==0 & mayor_h==0 & discap_h==1 //sin pareja y con discapacitado
replace familias2 = 5 if inlist(estado_civil,3,4,5,6) & inlist(demanda2,2,3) //sin pareja y más de 1 demandante
replace familias2 = 6 if inlist(estado_civil,1,2) & infante_h==0 & mayor_h==0 & discap_h==0 //en pareja y ningun demandante de cuidado
replace familias2 = 7 if inlist(estado_civil,1,2) & infante_h==1 & mayor_h==0 & discap_h==0 //en pareja con hijos
replace familias2 = 8 if inlist(estado_civil,1,2) & infante_h==0 & mayor_h==1 & discap_h==0 //en pareja con adulto mayor
replace familias2 = 9 if inlist(estado_civil,1,2) & infante_h==0 & mayor_h==0 & discap_h==1 //en pareja con discapacitado
replace familias2 = 10 if inlist(estado_civil,1,2) & inlist(demanda2,2,3) //en pareja y más de 1 demandante
label def familias2 1"Sin pareja ni demandantes" 2"Sin pareja y con hijos" 3"Sin pareja y con adulto mayor" 4"Sin pareja y familiar con dificultades" 5"Sin pareja con 2 o más demandantes" ///
					6"Con pareja ni demandantes" 7"Con pareja y con hijos" 8"Con pareja y con adulto mayor" 9"Con pareja y familiar con dificultades" 10"Con pareja y con 2 o más demandantes"
label val familias2 familias2

** Pareja/no pareja
gen 	pareja = 1 		if inlist(estado_civil, 1,2 )
replace pareja = 0	 	if inlist(estado_civil, 3,4,5,6)
replace pareja = . 		if estado_civil == .
label define pareja_lab 1"Tiene pareja" 0"No tiene pareja" 
label var pareja "Tiene/No tiene pareja" 
label values pareja pareja_lab

* Tipo de Trabajador
cap drop tipo_trab
recode p507 (1=1 "Empleador") (2=2 "Independiente") (3 4 =3 "Empleado") ///
			(5=4 "TFNR") (6 7=5 "TH") if pob==1, gen(tipo_trab)

* Sector de trabajo
cap drop sector
gen sector=.
replace sector=1 if tipo_trab==2 //independiente
replace sector=2 if inlist(p510,1,2,3) // sector público
replace sector=3 if tipo_trab==1 | inlist(p510,5,6,7) //sector privado
replace sector=4 if inlist(tipo_trab,4,5) //en hogares
label def sector 1"Independiente" 2"Público" 3"Privado" 4"Hogares", modify
label val sector sector

* Remuneración de ocupación principal
egen rem_m   = rowtotal(i524a1 i530a d544t), m //remuneracion por conceptos monetarios
egen rem_nom    = rowtotal(d529t d536), m //remuneracion por conceptos no monetarios
gen m_rem_m = rem_m/12 //remuneracion monetaria mensual
gen m_rem_nom = rem_nom/12 //remuneracion no monetaria mensual

egen ingm_empleo     = rowtotal(m_rem_m m_rem_nom),m
recode rem_m rem_nom (.=0) if ingm_empleo!=.
recode ingm_empleo (.=0) if p507==5 // se corrobora que los TFNR no reciben pago alguno
recode ingm_empleo (.=0) if pet==1 	// se asume que no reciben pago los missings
label var ingm_empleo "Ingreso laboral mensual"

cap drop remunerado
gen remunerado=ingm_empleo>0 if ingm_empleo!=.
label def remunerado 0"No remunerado" 1"Remunerado", modify
label val remunerado remunerado

** Deflactores a precios 2021 Lima Metro - SALARIOS
****************************************************
cap drop aniorec
gen aniorec=2021
merge m:1 aniorec ubigeo conglome vivienda hogar using "$b/sumaria2011_2021deflact", nogen keep(1 3) keepus(ipcr_1 ld i00 factornd07)
gen ingm_empleo_r = ingm_empleo/ld*i00

* Log de ingresos laborales reales de ocupación principal
gen lingm_empleo_r = ln(ingm_empleo_r)

** Subempleo (por horas y por ingresos)
*****************************************
gen percep_ocup=1 if (p204==1 & p203!=8 & p203!=9) & pea_ocup==1 & (ingm_empleo>0 & ingm_empleo<35000)
preserve
collapse (sum) percep_ocup, by(ubigeo conglome vivienda hogar)
label var percep_ocup "Perceptor de ingreso laboral en el hogar"
tempfile percep_ocup
save `percep_ocup', replace
restore
merge m:1 ubigeo conglome vivienda hogar using `percep_ocup', nogen

*Segundo se calcula el ingreso medio según dominio territorial
gen ing_medio=linea*mieperho/percep_ocup
preserve
collapse (mean) ing_mediod=ing_medio, by(dominio)
label var ing_mediod "Ingreso medio según dominio territorial"
tempfile ingreso_medio
save `ingreso_medio', replace
restore
merge m:1 dominio using `ingreso_medio', nogen

* Tercero calculamos las horas
gen tothrs = .
replace tothrs = (p513t) if (ocu500 ==1 & p519==1)
label var tothrs "Horas de trabajo semanal"

mean tothrs //horas de trabajo semanal promedio
mat def H=r(table)
replace tothrs = H[1,1] if tothrs==0 & ingm_empleo>0 //ajustes

*Cuarto, se calcula Subempleo
cap drop subempleo
gen subempleo = .
replace subempleo = 1 if pea_ocupada==1 & tothrs<35  &  p521==1 //trabaja menos de 35h pero quiere trabajar más
replace subempleo = 2 if pea_ocupada==1 & tothrs>=35 & (ingm_empleo<=ing_mediod) & subempleo==. //trabaja mas de 35h pero su ingreso es menor al ingreso medio del dominio
replace subempleo = 2 if pea_ocupada==1 & tothrs<35  & (ingm_empleo<=ing_mediod) & subempleo==. //trabaja menos de 35h y su ingreso por debajo de ing medio
replace subempleo = 3 if pea_ocupada==1 & tothrs<35  & p521==2 & subempleo==. //trabaja menos de 35h pero no queria trabajar mas horas
replace subempleo = 3 if pea_ocupada==1 & tothrs>=35 & (ingm_empleo>ing_mediod) & subempleo==. //trabaja mas de 35h y su ingreso es mayor que ing medio
label def subempleo 1 "Subempleo horas" 2 "Subempleo ingreso" 3 "Empleo adecuado", modify
label val subempleo subempleo

** Tamaño de la firma (solo para dependientes)
************************************************
cap drop tamaño
gen tamaño=1 if p512b>0 & p512b<11 & p512b!=.
replace tamaño=2 if p512b>=11 & p512b<50 & p512b!=.
replace tamaño=3 if p512b>=50 & p512b<=250 & p512b!=.
replace tamaño=4 if p512b>250 & p512b!=.
replace tamaño=1 if tamaño==. & p512a==1
replace tamaño=2 if tamaño==. & p512a==2
replace tamaño=3 if tamaño==. & p512a==3
replace tamaño=4 if tamaño==. & (p512a==4 | p512a==5)
replace tamaño=. if inlist(tipo_trab,1,2,4,5,.)  //excluimos del analisis a los trabajadores independientes ya que laboran solos. Los TFNR no suelen trabajar en empresas sino en hogares
label def tamaño 1"Micro" 2"Pequeña" 3"Mediana" 4"Grande"
label val tamaño tamaño

** Tipo de remuneracion
*************************
cap drop tipo_rem
gen tipo_rem = .
replace tipo_rem = 1 if p5111==1 | p5112==1
replace tipo_rem = 2 if p5113==1 | p5114==1 | p5115==1 | p5116==1 | p5117==1 | p5118==1
replace tipo_rem = 3 if p5119==1 | p51110==1 | p51111==1
replace tipo_rem = 4 if p51112==1
label def tipo_rem 1"Sueldo" 2"Ingreso por servicio" 3"Propina, en especie" 4"No recibe"
label val tipo_rem tipo_rem


** Tipo de contrato
*********************
cap drop contrato
recode p511a (7=0 "Sin contrato") (2/6 8 = 1 "Plazo definido") (1=2 "Plazo indefinido") if pob==1, gen(contrato)

** Gratificaciones
*********************
cap drop grati
gen grati = (p5441a==1 | p5442a==1)

** Informalidad del empleo (según metodo INEI)
***********************************************

*Registro en SUNAT de trabajador independiente
gen registrado = e1
recode registrado (1/2=1) (3=2)

*Descuento de ley a remuneracion (AFP, ONP, pensiones)
recode p524b1 (1/100000000000=1), gen (dscto) //descuento de ley

*Identificamos los pagos de seguro de salud por parte del empleador
egen paga_seguro=anymatch(p419a1-p419a5), val(1)

*Identificación de PEA Ocupada según Sector Institucional de Hogares Productores
gen 	inst=1 	if 	(p507==3 | p507==4) & p510>=1 & p510<=5 & p510!=. 		//Trab dependiente de FFAA, Sector publico, SERVICE
replace inst=1 	if 	(p507==3 | p507==4) & (p510==6 | p510==7) & p510a1==1 	//Trab dependiente en Negocio jurídico
replace inst=1 	if	(p507==3 | p507==4) & (p510==6 | p510==7) & ///
					(p510a1==2 | p510a1==3) & ///
					(p506r4>322 & p506r4!=.) & ///
					((p512b>30 & p512b!=.) | (p512a>1 & p512a!=.)) 			//Trab dependiente en Negocio natural o sin RUC con mas de 30 trabajadores que no pertenece a la act agropecuaria
replace inst=1 	if 	(p507==1 | p507==2) & p510a1==1			 				//Negocio jurídico
replace inst=1 	if 	(p507==1 | p507==2) & (p510a1==2 | p510a1==3) & ///
					(p506r4>322 & p506r4!=.) & ///
					((p512b>30 & p512b!=.) | (p512a>1 & p512a!=.)) 			//Negocio natural o sin RUC con mas de 30 trabajadores que no pertenece a la act agropecuaria
replace inst=2 	if 	p507==5 | p507==7										//Trab familiar no remunerado y otro tipo de trabajador
replace inst=2 	if 	(p507==3 | p507==4) & (p510==6 | p510==7) & ///
					(p510a1==2 | p510a1==3) & ///
					(p506r4>=111 & p506r4<=322 & p506r4!=.)					//Trab dependiente en Negocio natural o sin RUC del sector agropecuario
replace inst=2 	if 	(p507==3 | p507==4) & (p510==6 | p510==7) & ///
					(p510a1==2 | p510a1==3) & ///
					(p506r4>322 & p506r4!=.) & ///
					((p512b<=30 & p512b!=.) | p512a==1) 					//Trab dependiente en Negocio natural o sin RUC con menos de 30 trabajadores que no pertenece a la act agropecuaria
replace inst=2 	if 	(p507==1 | p507==2) & (p510a1==2 | p510a1==3) & ///
					(p506r4>=111 & p506r4<=322 & p506r4!=.)					//Trab independiente en Negocio natural o sin RUC del sector agropecuario
replace inst=2 	if 	(p507==1 | p507==2) & (p510a1==2 | p510a1==3) & ///
					(p506r4>322 & p506r4!=.) & ///
					((p512b<=30 & p512b!=.) | p512a==1)						//Trab independiente en Negocio natural o sin RUC con menos de 30 trabajadores que no pertenece a la act agropecuaria
replace inst=3 	if 	p507==6 												//Trabajadores del hogar												
replace inst=. 	if 	ocu500!=1												//Solo acotamos a la PEA Ocupada
replace inst=2 	if 	ocu500==1 & inst==.										//Los que no se puede diferenciar se van a Hogares de mercado
label def inst 1"Sociedad" 2"Hogares de mercado" 3"Hogares autoconsumo"
label val inst inst

*Identificación de PEA Ocupada según Sector Formal e Informal
gen sector_f=1 		if 	inst==1												//Los trabajadores de las Sociedades pertenecen al sector formal
replace sector_f=1 	if 	inst==2 & p506r4>990 & p506r4!=. & ///
						p507!=. & (p510a1==1 | p510a1==2)					//Personas trabajando en Negocio con RUC no dedicados a actividades extractivas son sector formal
replace sector_f=2 	if 	inst==2 & p506r4>=111 & p506r4<=990 & p506r4!=.		//Personas trabajando en Negocio dedicado a actividades extractivas son sector informal
replace sector_f=2 	if 	inst==2 & p506r4>990 & p506r4!=. & p507!=. & p510a1==3 //Personas trabajando en Negocio sin RUC no dedicado a actividades extractivas son sector informal
replace sector_f=3 	if 	inst==3												//Trabajadores del hogar
label def sector_f 1"Sector formal" 2"Sector informal" 3"Trabajador del hogar"
label val sector_f sector_f

*Identificación de PEA Ocupada que se desempeña en Empleo Formal e Informal
gen empleo_f=1 if sector_f==2												//Toda la gente que labora en el sector informal es empleo informal
replace empleo_f=1 if sector_f==1 & (p507==5 | p507==7)						//Trabajador del hogar y otros del sector formal son empleo informal
replace empleo_f=2 if sector_f==1 & (p507==1 | p507==2)						//Trabajadores independientes del sector formal son empleo formal
replace empleo_f=1 if sector_f==1 & (p507==3 | p507==4) & paga_seguro!=1	//Trabajador dependiente del sector formal que no le pagan su seguro de salud es empleo informal
replace empleo_f=1 if sector_f==3 & (p507==6) & paga_seguro!=1				//Trabajador del hogar sin pago de seguro es empleo informal
replace empleo_f=2 if sector_f==1 & (p507==3 | p507==4) & paga_seguro==1	//Trabajadores dependientes del sector formal con pago de seguro de salud son empleo formal
replace empleo_f=2 if sector_f==3 & (p507==6) & paga_seguro==1				//Trabajador del hogar con pago de seguro es empleo formal
replace empleo_f=ocupinf if empleo_f==. & inst!=.								//completamos la informacion faltante con la variable generada por inei de empleo formal/informal
label def empleo_f 1"Informal" 2 "Formal"
label val empleo_f empleo_f



** RMV 2021
************
global rmv 930
gen bajo_rmv= ingm_empleo<=$rmv if ingm_empleo!=.
label def bajo_rmv 0"Ingreso supera RMV" 1"Ingreso menor a RMV"
label var bajo_rmv "PEA ocupada con ingresos por debajo de RMV 2021"

* Razones de Inactividad
**************************
cap drop razones_pei
recode p546 (1 2 3 = 1 "Preparativos para trabajo") (4=2 "Estudiando") ///
			(5=3 "Quehaceres del hogar") (6 =4 "Otras rentas") ///
			(7 8=5 "Enfermo o incapacitado"), g(razones_pei)

		
*-------------------------------------------------------------------------------
* DEFINICIÓN DE TRABAJADORES DEL CUIDADO
*-------------------------------------------------------------------------------

** Primero restringimos la muestra a poblacion y peruanos
***********************************************************
keep if pob==1
drop if extranjero==1 //eliminamos a extranjeros porque los nacionales serán sumados con ENPOVE

** GRUPO A - Cuidadores (No remunerados)
**********************************************************

* Población inactiva que realiza tareas domésticas
cap drop grupoA
gen grupoA= p546==5 //para los de 14 a más (modulo empleo)
replace grupoA = 1 if (p211a==2 | p211a==8) //para los de 5 a 13 años (modulo miembros de hogar)  
replace grupoA = . if p208a<5
label def grupoA 0"No" 1"Cuidadores"
label val grupoA grupoA
label var grupoA "Cuidadores no remunerados"


** Empleos del cuidado
************************

* Primero uniformizamos variables de ocupaciones y de actividades economicas
rename	(p505r4 p506r4) (codigo_CNO codigo_CIIU)
merge	 m:1 codigo_CNO using "$c/clasificacion_CIUO" , nogen keep(1 3) keepus(codigo_CIUO des_CIUO care_work)

* Segundo generamos sectores de industrias de 2 dígitos
gen div_CIIU = . 
replace div_CIIU = real(substr(strofreal(codigo_CIIU),1,2)) if strlen(strofreal(codigo_CIIU)) == 4
replace div_CIIU = real(substr(strofreal(codigo_CIIU),1,1)) if strlen(strofreal(codigo_CIIU)) == 3

* Tercero clasificamos los 4 tipos de empleos de cuidados
cap drop empleos_cuidados
gen empleos_cuidados=.

* 1. Care workers employed in care sectors
replace empleos_cuidados = 1 if 	pob==1 & inlist(div_CIIU, 85, 86, 87, 88) & ///
						inlist(codigo_CIUO, 1341, 1342, 1343, 1344, 1345, 2211, 2212, 2221, 2222, 2230, 2240, 2261, 2262, 2263, 2264, 2265, 2266, 2267, 2269, 2310, 2320, 2330, 2341, 2342, 2351, 2352, 2353, 2354, 2355, 2356, 2356, 2359, 2634, 2635, 3211, 3212, 3213, 3214, 3215, 3221, 3222, 3230, 3251, 3252, 3253, 3254, 3255, 3256, 3257, 3258, 3259, 3412, 3422, 3423, 3435, 5311, 5312, 5321, 5322, 5329)

* 2. Domestic workers (employed by households)
replace empleos_cuidados = 2 if 	pob==1 & inlist(div_CIIU, 97) 

* 3. Care workers employed in non-care sectors
replace empleos_cuidados = 3 if	pob==1 & !inlist(div_CIIU, 85, 86, 87, 88, 97) & ///
						 inlist(codigo_CIUO, 2211, 2212, 2221, 2222, 2230, 3258, 2261, 2262, 2263, 2264, 2265, 2266, 2267, 2269, 2310, 2320, 2330, 2341, 2342, 2351, 2352, 2353, 2354, 2355, 2356, 2356, 2359, 3211, 3212, 3213, 3214, 3215, 3221, 3222, 3230, 3251, 3252, 3253, 3254, 3255, 3256, 3257, 3259, 5311, 5312, 5321, 5322, 5329)


* 4. Non-care workers employed in care sectors
replace empleos_cuidados = 4 if 	 pob==1 & inlist(div_CIIU, 85, 86, 87, 88) & ///
						!inlist(real(substr(strofreal(codigo_CIUO),1,2)), 13, 22, 23, 26, 32, 34, 53)

label def empleos_cuidados 	1"TC empleados en sectores del cuidado" ///
					2"TC empleados por hogares" ///
					3"TC no empleados en sectores de cuidado"  ///
					4"Otros profesionales empleados en sectores de cuidado", replace
label val empleos_cuidados empleos_cuidados
label var empleos_cuidados "Empleos de cuidados" 

recode empleos_cuidados (2 = 1 "Trabajadora del hogar") (1 3 4 = 2 "Resto TC") , gen(empleos_cuidados2)


* Sector del cuidado
cap drop sec_cuid
gen sec_cuid=. 
replace sec_cuid=1 if inlist(div_CIIU, 85)
replace sec_cuid=2 if inlist(div_CIIU,86)
replace sec_cuid=3 if inlist(div_CIIU,87,88)
replace sec_cuid=4 if inlist(div_CIIU,95,97)
replace sec_cuid=5 if empleos_cuidados==3 & sec_cuid==.
label def sec_cuid 1"Educación" 2"Salud" 3"Trabajo social y del cuidado directo" 4"Hogares" 5"Otros sectores", modify
label val sec_cuid sec_cuid

** Tipo de Ocupaciones
************************
cap drop tipo_ocup
gen tipo_ocup = .
* PROF/TECNICOS SALUD
replace tipo_ocup = 1 if inlist(codigo_CNO, 2211,2212,2251,2254,2255,2257,2259) //medicos, dentista
replace tipo_ocup = 2 if inlist(codigo_CNO, 2221,2222,2252) //enfermeria
replace tipo_ocup = 3 if inlist(codigo_CNO, 2634) //psicologos
replace tipo_ocup = 4 if inlist(codigo_CNO, 3211,3212,3213,3215,3230,3251,3253,3254,3255,3256,3257,3259) //tecnicos de la salud
replace tipo_ocup = 5 if inlist(codigo_CNO, 3221) //tecnicos en enfermeria
replace tipo_ocup = 6 if inlist(codigo_CNO, 5329) //trabajadores de cuidado de personas
replace tipo_ocup = 7 if inlist(codigo_CNO , 3314,4110,4120,4132,4221,4222,4224,4225,4311,4313,4321,4411,4415,4416,4417,4419) & sec_cuid ==2 //personal administrativo
replace tipo_ocup = 8 if inlist(codigo_CNO,111, 1114, 1163, 1166, 1345, 2131, 2142, 2144, 2166, 2240, 2411,2412,2421,2432,2511,2512,2611,2622,2641,2642,2643,2652,3113,3114,3115,3124,3149,3151,3313,3322,3422,3432,3511,3512,3513,3521,5120,5230,5414,7127,7322,7411,7421,8322,8331,8332,9112,9121,9313,9412,9622,9629) & sec_cuid ==2 //otros profesionales que no son de la salud, pero laboran en el sector salud

* PROF/TECNICOS EDUCACION
replace tipo_ocup = 9 if inlist(codigo_CNO, 2342) //docentes de aula - inicial
replace tipo_ocup = 10 if inlist(codigo_CNO, 2341) //docentes de aula - primaria
replace tipo_ocup = 11 if inlist(codigo_CNO, 2330) //docentes de aula - secundaria
replace tipo_ocup = 12 if inlist(codigo_CNO, 2311,2312) //docentes de aula - superior/tecnico
replace tipo_ocup = 13 if inlist(codigo_CNO, 2351,2352,2353,2359) //especialistas y otros
replace tipo_ocup = 14 if inlist(codigo_CNO, 5312) //auxiliares
replace tipo_ocup = 15 if inlist(codigo_CNO , 3314,4110,4120,4132,4221,4222,4224,4225,4311,4313,4321,4411,4415,4416,4417,4419) & sec_cuid ==1 //personal administrativo
replace tipo_ocup = 16 if inlist(codigo_CNO,111, 1114, 1163, 1166, 1345, 2131, 2142, 2144, 2166, 2240, 2411,2412,2421,2432,2511,2512,2611,2622,2641,2642,2643,2652,3113,3114,3115,3124,3149,3151,3313,3322,3422,3432,3511,3512,3513,3521,5120,5230,5414,7127,7322,7411,7421,8322,8331,8332,9112,9121,9313,9412,9622,9629) & sec_cuid ==1 //otros profesionales que no son educadores, pero laboran en el sector educacion

* PROF/TECNICOS TRABAJO SOCIAL
replace tipo_ocup = 17 if inlist(codigo_CNO, 2635,3412) //trabajador social
replace tipo_ocup = 18 if inlist(codigo_CNO, 5311,5321,5322) //trabajador del cuidado
replace tipo_ocup = 19 if inlist(codigo_CNO , 3314,4110,4120,4132,4221,4222,4224,4225,4311,4313,4321,4411,4415,4416,4417,4419) & sec_cuid ==3 //personal administrativo
replace tipo_ocup = 20 if inlist(codigo_CNO,111, 1114, 1163, 1166, 1345, 2131, 2142, 2144, 2166, 2240, 2411,2412,2421,2432,2511,2512,2611,2622,2641,2642,2643,2652,3113,3114,3115,3124,3149,3151,3313,3322,3422,3432,3511,3512,3513,3521,5120,5230,5414,7127,7322,7411,7421,8322,8331,8332,9112,9121,9313,9412,9622,9629) & sec_cuid ==3 //otros profesionales que no trabajdores sociales, pero laboran en el sector social

replace tipo_ocup=. if empleos_cuidados2!=2
label def tipo_ocup 1"Médicos" 2"Enfermeros/as" 3"Psicólogos" 4"Técnicos de la salud" 5"Técnicos en enfermería" ///
					6"Trabajador de cuidado de personas" 7"Personal administrativo" ///
					8"Otro tipo de profesional que labora en sector salud" ///
					9"Docentes de aula - Inicial" 10"Docentes de aula - Primaria" ///
					11"Docentes de aula - Secundaria" 12"Docentes de aula - Superior" ///
					13"Especialistas y otros docentes" 14"Auxiliares de educación" 15"Personal administrativo" ///
					16"Otro tipo de profesional que labora en sector educación" ///
					17"Trabajador social" 18"Trabajador del cuidado de personas" ///
					19"Personal administrativo" 20"Otro tipo de profesional que labora en sector social", modify
label val tipo_ocup tipo_ocup

** GRUPO B - Trabajadores del hogar
**************************************
cap drop grupoB
gen grupoB = empleos_cuidados2 ==1

** GRUPO C - Trabajadores del sector salud
*******************************************************************
cap drop grupoC
gen grupoC = inlist(tipo_ocup,1,2,3,4,5,6,7,8)

** GRUPO D - Trabajadores del sector educación
*******************************************************************
cap drop grupoD
gen grupoD = empleos_cuidados2==2 & inlist(tipo_ocup,9,10,11,12,13,14,15,16)


** Resto de Trabajadores de cuidados (Resto de empleados de cuidados y TC en formación no remunerados)
*******************************************************************************************************
cap drop resto_TC
gen resto_TC=.
replace resto_TC = 1 if pob==1 & empleos_cuidados2 == 2 & (grupoC == 0 & grupoD==0) //resto de empleados de cuidados
replace resto_TC = 1 if pob==1 & inlist(codigo_CIUO,3256) & ingm_empleo==0 // los practicantes
replace resto_TC= 1 if pob==1 & empleos_cuidados!=. & remunerado==0 // los TC que no son remunerados 
replace resto_TC = 1 if pob==1 & empleos_cuidados!=. & contrato==4 //Que estén con Convenio de Formación Laboral Juvenil o Practicas Pre-profesionales
replace empleos_cuidados = . if resto_TC==1
replace grupoB = . if resto_TC==1
replace grupoC = . if resto_TC==1
replace grupoD = . if resto_TC==1

** Consolidado de Trabajadores de cuidados 
***********************************************
cap drop trab_cuid2
gen trab_cuid2 =.
replace trab_cuid2 = 1 if grupoA==1
replace trab_cuid2 = 2 if grupoB==1
replace trab_cuid2 = 3 if grupoC==1
replace trab_cuid2 = 4 if grupoD==1
replace trab_cuid2 = 5 if resto_TC==1
label def trab_cuid2 1"Cuidador no remunerado" 2"Trabajador del hogar" 3"Trabajador salud" 4"Trabajador educación" 5"Resto TC"
label val trab_cuid2 trab_cuid2 
label var trab_cuid2 "Trabajadores del cuidado"
gen TC = trab_cuid2!=.

** Identificamos Trabajo Infantil según definición de MTPE
************************************************************
cap drop trab_infantil
gen trab_infantil = 1 if p208a<12 & p211d>0 & trab_cuid2!=. //menores de 5 a 11 años que realicen cuidados al menos 1h sin importar remuneración se considera TI
replace trab_infantil = 1 if inlist(p208a,12,13,14,15,16,17) & remunerado==1 & trab_cuid2!=. //menores de 12 a 17 años que reciban una remuneración se considera TI

* Consolidamos el factor de expansión
cap drop facoit
gen facoit = facpob07
replace facoit = fac500a if fac500a!=.

save "$b\Cuidadores_ENAHO21", replace

*-------------------------------------------------------------------------------
* EXPORTAMOS LOS DATOS - ESTRUCTURA DE TRABAJADORES - DIMENSIONAMIENTO
*-------------------------------------------------------------------------------
use "$b\Cuidadores_ENAHO21", clear

**********************************************
** 			DIMENSIONAMIENTO TOTAL 			**
**********************************************
putexcel set "$d\ENAHO.xlsx", modify sheet("DIMENSIONAMIENTO TOTAL")
putexcel B1="Dimensionamiento personas que realiza labores de cuidado DE 5 A MÁS AÑOS"

** POBLACIÓN TOTAL según ambito, sexo y grupo de edades
********************************************************

* NOTA: Aquí consideramos a todas las personas que se vinculen con labores de cuidado 
preserve
table ambito g_etario sexo if trab_cuid2!=. & g_etario!=. [iw=facoit], c(freq) center col row format(%18.0fc) replace 
label def g_etario 99 "Total", add
label def ambito 0 "Total", add
recode ambito (.=0)
recode g_etario ambito (.=99)
order ambito sexo g_etario
sort ambito sexo g_etario
export excel using "$d\ENAHO.xlsx", sheet("Dimensión total", modify) firstrow(var) cell(C3)
restore


******************************************************
** 			DIMENSIONAMIENTO DE 18 A MÁS 			**
******************************************************
putexcel set "$d\ENAHO.xlsx", modify sheet("DIMENSIONAMIENTO 18 A MAS")
putexcel B1="Dimensionamiento personas dedicadas al cuidado DE 18 A MÁS AÑOS"

** Total Cuidadores segun sexo
****************************
preserve
table trab_cuid2 sexo if trab_cuid2!=. & inlist(g_etario,3,4,5) [iw=facoit], c(freq) center col row format(%18.0fc) replace 
label def trab_cuid2 99 "Total", add
label def sexo 99 "Total", add
recode sexo trab_cuid2 (.=99)
reshape wide table1, i(sexo) j(trab_cuid2)
rename (table11 table12 table13 table14 table15 table199) (Cuidador TH Salud Educacion Resto Total)
export excel using "$d\ENAHO.xlsx", sheet("Mayores18 - Total TC", modify) firstrow(var) cell(C3)
restore

** Tipo de ocupación y sector del Resto de TC
***********************************************
preserve
table tipo_ocup sexo if inlist(trab_cuid2,3,4,5) & inlist(g_etario,3,4,5) [iw=facoit], c(freq) center col row format(%18.0fc) replace 
label def sexo 99 "Total", add
label def tipo_ocup 99 "Total", add
recode sexo tipo_ocup (.=99)
reshape wide table1, i(tipo_ocup) j(sexo)
rename (table11 table12 table199) (Hombre Mujer Total)
export excel using "$d\ENAHO.xlsx", sheet("Desagregado Resto TC", modify) firstrow(var) cell(C3)
restore

* NOTA: Aquí retiramos del análisis al grupo del resto de TC
drop if trab_cuid2==5

** Tipo de ocupación del sector salud
***********************************************
preserve
table tipo_ocup sexo if inlist(trab_cuid2,3) & inlist(g_etario,3,4,5) [iw=facoit], c(freq) center col row format(%18.0fc) replace 
label def sexo 99 "Total", add
label def tipo_ocup 99 "Total", add
recode sexo tipo_ocup (.=99)
reshape wide table1, i(tipo_ocup) j(sexo)
rename (table11 table12 table199) (Hombre Mujer Total)
export excel using "$d\ENAHO.xlsx", sheet("Ocupaciones salud", modify) firstrow(var) cell(C3)
restore

** Tipo de ocupación del sector educación
***********************************************
preserve
table tipo_ocup sexo if inlist(trab_cuid2,4) & inlist(g_etario,3,4,5) [iw=facoit], c(freq) center col row format(%18.0fc) replace 
label def sexo 99 "Total", add
label def tipo_ocup 99 "Total", add
recode sexo tipo_ocup (.=99)
reshape wide table1, i(tipo_ocup) j(sexo)
rename (table11 table12 table199) (Hombre Mujer Total)
export excel using "$d\ENAHO.xlsx", sheet("Ocupaciones educacion", modify) firstrow(var) cell(C3)
restore

** Cuidadores segun Edad y sexo - URBANO
******************************************
preserve
table trab_cuid2 g_etario sexo if trab_cuid2!=. & ambito==1 & inlist(g_etario,3,4,5) [iw=facoit], c(freq) center col row format(%18.0fc) replace 
label def g_etario 99 "Total", add
label def trab_cuid2 99 "Total", add
recode g_etario trab_cuid2 (.=99)
reshape wide table1, i(sexo g_etario) j(trab_cuid2)
rename (table11 table12 table13 table14 table199) (Cuidador TH Salud Educacion Total)
export excel using "$d\ENAHO.xlsx", sheet("TC total urbano", modify) firstrow(var) cell(C3)
restore

** Cuidadores segun Edad y sexo - RURAL
******************************************
preserve
table trab_cuid2 g_etario sexo if trab_cuid2!=. & ambito==2 & inlist(g_etario,3,4,5) [iw=facoit], c(freq) center col row format(%18.0fc) replace 
label def g_etario 99 "Total", add
label def trab_cuid2 99 "Total", add
recode g_etario trab_cuid2 (.=99)
reshape wide table1, i(sexo g_etario) j(trab_cuid2)
rename (table11 table12 table13 table14 table199) (Cuidador TH Salud Educacion Total)
export excel using "$d\ENAHO.xlsx", sheet("TC total rural", modify) firstrow(var) cell(C3)
restore


** Representacion  - Cuidadores segun sexo / ambito
****************************************************
preserve
table trab_cuid2 sexo ambito if trab_cuid2!=. & inlist(g_etario,3,4,5) [iw=facoit], c(freq) center col row format(%18.0fc) replace 
label def sexo 99 "Total", add
label def trab_cuid2 99 "Total", add
recode sexo trab_cuid2 (.=99)
reshape wide table1, i(ambito sexo) j(trab_cuid2)
rename (table11 table12 table13 table14 table199) (Cuidador TH Salud Educacion Total)
export excel using "$d\ENAHO.xlsx", sheet("Representación TC ambito sexo", modify) firstrow(var) cell(C3)
restore

** Representacion  - NO Cuidadores segun sexo / ambito
********************************************************
gen no_cuid = (trab_cuid2 == .) 
replace no_cuid = . if no_cuid == 0 

preserve
table no_cuid sexo ambito if no_cuid!=. & inlist(g_etario,3,4,5) [iw=facoit], c(freq) center col row format(%18.0fc) replace 
label def sexo 99 "Total", add
label def no_cuid 99 "Total", add
recode sexo no_cuid (.=99)
reshape wide table1, i(ambito sexo) j(no_cuid)
rename (table11 table199) (No_cuidador Total)
export excel using "$d\ENAHO.xlsx", sheet("Representación NoTC ambito sexo", modify) firstrow(var) cell(C3)
restore

bysort sexo: table no_cuid if no_cuid!=. & g_etario != . [iw=facoit], c(freq) center col row format(%18.0fc)


** Representacion  - Cuidadores segun edad / ambito
****************************************************
preserve
table trab_cuid2 g_etario ambito if trab_cuid2!=. & inlist(g_etario,3,4,5) [iw=facoit], c(freq) center col row format(%18.0fc) replace 
label def g_etario 99 "Total", add
label def trab_cuid2 99 "Total", add
recode g_etario trab_cuid2 (.=99)
reshape wide table1, i(ambito g_etario) j(trab_cuid2)
rename (table11 table12 table13 table14 table199) (Cuidador TH Salud Educacion Total)
export excel using "$d\ENAHO.xlsx", sheet("Representación TC ambito edad", modify) firstrow(var) cell(C3)
restore


** Representacion  - NO Cuidadores segun edad / ambito
*******************************************************
preserve
table no_cuid g_etario ambito if no_cuid!=. & inlist(g_etario,3,4,5) [iw=facoit], c(freq) center col row format(%18.0fc) replace 
label def g_etario 99 "Total", add
label def no_cuid 99 "Total", add
recode g_etario no_cuid (.=99)
reshape wide table1, i(ambito g_etario) j(no_cuid)
drop table199
rename (table11) (No_cuidadores)
export excel using "$d\ENAHO.xlsx", sheet("Representación NoTC ambito edad", modify) firstrow(var) cell(C3)
restore

********************************
** Estructura de trabajadores **
********************************

mat def M = J(28,3,.)

forval p = 0/2{

preserve
drop if sexo==`p'

* Poblacion
tab pob [iw=facoit], matcell(A1)
mat def A=A1[1,1]

* Urbano/rural
tab ambito [iw=facoit], matcell(A1)
mat def A=A\A1

* Grupos etarios
tab g_etario [iw=facoit], matcell(A1)
mat def A=A\A1

* PEA
tab pea [iw=facoit] if inlist(g_etario,3,4,5), matcell(A1)
mat def A=A\A1

* PEA ocupada
tab pea_ocupada [iw=facoit] if inlist(g_etario,3,4,5), matcell(A1)
mat def A=A\A1

* Trabajadores del cuidado
tab trab_cuid2 [iw=facoit] if inlist(g_etario,3,4,5) & trab_cuid2!=5, matcell(A1)
mat def A=A\A1

* Poblacion de 5 a 17 años dedica a labores del hogar
tab TC g_etario if inlist(g_etario,1,2) [iw=facoit], matcell(A1)
mat def A=A\A1[1...,1]\A1[1...,2]

* Poblacion cuidadora de 5 a 13 años que estudia
tab TC estudia if inlist(g_etario,1) [iw=facoit], matcell(A1)
mat def A=A\A1[1...,1]\A1[1...,2]

* Poblacion cuidadora de 14 a 17 años que estudia
tab TC estudia if inlist(g_etario,2) [iw=facoit], matcell(A1)
mat def A=A\A1[1...,1]\A1[1...,2]

local q = `p'+1
mat def M[1.,`q']=A[1...,1]
restore
}

* Exportamos
putexcel set "$d\ENAHO.xlsx", modify sheet("Estructura TC")
mat rownames M = 	pob urbano rural 5a13 14a17 18a29 30a64 65mas pea18 pei18 peao18 pea_desoc18 ///
					Cuidador18 TH18 Salud18 Educación18 NoTC_5a13 TC_5a13 NoTC_14a17 TC_14a17 ///
					NoTC_5a13_NoEst TC_5a13_NoEst NoTC_5a13_Est TC_5a13_Est ///
					NoTC_14a17_NoEst TC_14a17_NoEst NoTC_14a17_Est TC_14a17_Est
mat colnames M =	Total Mujer Hombre
putexcel B2=matrix(M),  names nformat(number_sep_d2)
putexcel B1="Input stata", font(Arial, 10 [color(red)])


*-------------------------------------------------------------------------------
* EXPORTAMOS LOS DATOS - EFECTOS DE LABORES DE CUIDADO EN VARIABLES LABORALES
*-------------------------------------------------------------------------------
use "$b\Cuidadores_ENAHO21", clear

putexcel set "$d\ENAHO.xlsx", modify sheet("EFECTOS LABORAL")
putexcel B1="Efectos de labores de cuidado en variables laborales"


** Estructura PET - Alta Inactividad de mujeres
*************************************************
tab sexo pea_ocupada if pet==1 & inlist(g_etario,3,4,5) [iw=facoit], m row matcell(A)

* Exportamos
putexcel set "$d\ENAHO.xlsx", modify sheet("Inactividad Mujeres")
mat rownames A = 	Hombre Mujer
mat colnames A =	PEA_ocupada PEA_desocupada PEI
putexcel B2=matrix(A),  names nformat(number_sep_d2)
putexcel B1="Input stata", font(Arial, 10 [color(red)])


**Razones de inactividad
**************************
preserve
table razones_pei sexo if inlist(g_etario,3,4,5) [iw=facoit], c(freq) center col row format(%18.0fc) replace 
label def sexo 99 "Total", add
label def razones_pei 99 "Total", add
recode sexo razones_pei (.=99)
reshape wide table1, i(razones_pei) j(sexo)
rename (table11 table12 table199) (Hombre Mujer Total)
export excel using "$d\ENAHO.xlsx", sheet("Razones PEI", modify) firstrow(var) cell(C3)
restore

******************************************
** Participación en fuerza de trabajo	**
******************************************

* Proporción de trabajar - Segun demandantes de cuidado
preserve
table demanda_cuid2 trabaja sexo [iw=facoit] if inlist(p203,1,2) & inlist(g_etario,3,4,5), c(freq) center col row format(%18.0fc) replace 
label def demanda_cuid2 99 "Total", add
label def trabaja 99 "Total", add
recode demanda_cuid2 trabaja (.=99)
reshape wide table1, i(demanda_cuid2 sexo) j(trabaja)
sort sexo demanda_cuid2
rename (table10 table11 table199) (No_trabaja Trabaja Total)
export excel using "$d\ENAHO.xlsx", sheet("Empleo cuidados", modify) firstrow(var) cell(C3)
restore

* Horas laborales - Segun demandantes de cuidado
preserve
table demanda_cuid2 sexo [iw=facoit] if inlist(p203,1,2) & inlist(g_etario,3,4,5), c(mean tothrs) center col row format(%18.1fc) replace 
label def demanda_cuid2 99 "Total", add
label def sexo 99 "Total", add
recode demanda_cuid2 sexo (.=99)
reshape wide table1, i(demanda_cuid2) j(sexo)
rename (table11 table12 table199) (Hombre Mujer Total)
export excel using "$d\ENAHO.xlsx", sheet("Horas cuidados", modify) firstrow(var) cell(C3)
restore

* Tasa de informalidad - Segun demandantes de cuidado
preserve
table demanda_cuid2 empleo_f sexo [iw=facoit] if inlist(p203,1,2) & inlist(g_etario,3,4,5), c(freq) center col row format(%18.0fc) replace 
label def demanda_cuid2 99 "Total", add
label def empleo_f 99 "Total", add
recode demanda_cuid2 empleo_f (.=99)
reshape wide table1, i(demanda_cuid2 sexo) j(empleo_f)
sort sexo demanda_cuid2
rename (table11 table12 table199) (Informal Formal Total)
export excel using "$d\ENAHO.xlsx", sheet("Informal cuidados", modify) firstrow(var) cell(C3)
restore

* Salarios - Segun demandantes de cuidado
preserve
table demanda_cuid2 sexo [iw=facoit] if inlist(p203,1,2) & inlist(g_etario,3,4,5) & ingm_empleo_r>0, c(mean ingm_empleo_r) center col row format(%18.1fc) replace 
label def demanda_cuid2 99 "Total", add
label def sexo 99 "Total", add
recode demanda_cuid2 sexo (.=99)
reshape wide table1, i(demanda_cuid2) j(sexo)
rename (table11 table12 table199) (Hombre Mujer Total)
export excel using "$d\ENAHO.xlsx", sheet("Salarios cuidados", modify) firstrow(var) cell(C3)
restore

* Proporción de trabajar - Segun estructura familiar
preserve
table familias trabaja sexo [iw=facoit] if inlist(p203,1,2) & inlist(g_etario,3,4,5), c(freq) center col row format(%18.0fc) replace 
label def familias 99 "Total", add
label def trabaja 99 "Total", add
recode familias trabaja (.=99)
reshape wide table1, i(familias sexo) j(trabaja)
sort sexo familias
rename (table10 table11 table199) (No_trabaja Trabaja Total)
export excel using "$d\ENAHO.xlsx", sheet("Empleo familias", modify) firstrow(var) cell(C3)
restore

* Horas laborales - Segun estructura familiar
preserve
table familias sexo [iw=facoit] if inlist(p203,1,2) & inlist(g_etario,3,4,5), c(mean tothrs) center col row format(%18.1fc) replace 
label def familias 99 "Total", add
label def sexo 99 "Total", add
recode familias sexo (.=99)
reshape wide table1, i(familias) j(sexo)
rename (table11 table12 table199) (Hombre Mujer Total)
export excel using "$d\ENAHO.xlsx", sheet("Horas familias", modify) firstrow(var) cell(C3)
restore

* Tasa de informalidad - Segun estructura familiar
preserve
table familias empleo_f sexo [iw=facoit] if inlist(p203,1,2) & inlist(g_etario,3,4,5), c(freq) center col row format(%18.0fc) replace 
label def familias 99 "Total", add
label def empleo_f 99 "Total", add
recode familias empleo_f (.=99)
reshape wide table1, i(familias sexo) j(empleo_f)
sort sexo familias
rename (table11 table12 table199) (Informal Formal Total)
export excel using "$d\ENAHO.xlsx", sheet("Informal familias", modify) firstrow(var) cell(C3)
restore

* Salarios - Segun estructura familiar
preserve
table familias sexo [iw=facoit] if inlist(p203,1,2) & inlist(g_etario,3,4,5) & ingm_empleo_r>0, c(mean ingm_empleo_r) center col row format(%18.1fc) replace 
label def familias 99 "Total", add
label def sexo 99 "Total", add
recode familias sexo (.=99)
reshape wide table1, i(familias) j(sexo)
rename (table11 table12 table199) (Hombre Mujer Total)
export excel using "$d\ENAHO.xlsx", sheet("Salarios familias", modify) firstrow(var) cell(C3)
restore

*-------------------------------------------------------------------------------
* Ilustraciones - Caracterización del Grupo A. 
*-------------------------------------------------------------------------------
use "$b\Cuidadores_ENAHO21", clear

putexcel set "$d\ENAHO.xlsx", modify sheet("CARACTERIZACIÓN GRUPO A")
putexcel B1="Caracterización socioeconomica - Grupo A"

keep if inlist(g_etario, 3,4,5)
tab trab_cuid2, gen(TC_)

gen TC_m_1 				= TC_1==1 & sexo==2
gen TC_h_1 				= TC_1==1 & sexo==1
gen TC_urb_1 			= TC_1==1 & ambito==1
gen TC_rur_1 			= TC_1==1 & ambito==2
gen TC_joven_1 			= TC_1==1 & inlist(g_etario,3)
gen TC_adulto_1 		= TC_1==1 & inlist(g_etario,4)
gen TC_adultom_1 		= TC_1==1 & inlist(g_etario,5)
	
gen pop_m_1			 	= sexo==2
gen pop_h_1 			= sexo==1
gen pop_urb_1 			= ambito==1
gen pop_rur_1 			= ambito==2
gen pop_joven_1 		= inlist(g_etario,3)
gen pop_adulto_1 		= inlist(g_etario,4)
gen pop_adultom_1		= inlist(g_etario,5)

global var pob TC_1 TC_rur_1 pop_rur_1 TC_urb_1 pop_urb_1 TC_m_1 pop_m_1 TC_h_1 pop_h_1 TC_joven_1 pop_joven_1 TC_adulto_1 pop_adulto_1 TC_adultom_1 pop_adultom_1
global var2 TC_1 TC_rur_1 pop_rur_1 TC_urb_1 pop_urb_1 TC_m_1 pop_m_1 TC_h_1 pop_h_1 TC_joven_1 pop_joven_1 TC_adulto_1 pop_adulto_1 TC_adultom_1 pop_adultom_1


* Ilustracion: Etnia
foreach x of global var{
preserve
table etnia if `x'==1 [iw=facoit], c(freq) center row format(%18.0fc) replace 
label def etnia 99 "Total", modify
recode etnia (.=99)
rename (table1) (`x')
tempfile cuid`x'
save `cuid`x'', replace
restore
}

preserve
use `cuidpob', clear
foreach x of global var2 {
merge 1:1 etnia using `cuid`x'', nogen
}

order etnia, first
export excel using "$d\ENAHO.xlsx", sheet("Etnia - GrupoA", modify) firstrow(var) cell(C3)
restore

* Ilustracion: Condición migratoria de la población cuidadora
foreach x of global var{
preserve
table migrante_prov if `x'==1 [iw=facoit], c(freq) center row format(%18.0fc) replace 
label def migrante_prov 99 "Total", modify
recode migrante_prov (.=99)
rename (table1) (`x')
tempfile cuid`x'
save `cuid`x'', replace
restore
}

preserve
use `cuidpob', clear
foreach x of global var2 {
merge 1:1 migrante_prov using `cuid`x'', nogen
}

order migrante_prov, first
export excel using "$d\ENAHO.xlsx", sheet("Migracion - GrupoA", modify) firstrow(var) cell(C3)
restore

* Ilustracion: Pobreza monetaria de la población cuidadora 
foreach x of global var{
preserve
table pobreza_m if `x'==1 [iw=facoit], c(freq) center row format(%18.0fc) replace 
label def pobreza_m 99 "Total", modify
recode pobreza_m (.=99)
rename (table1) (`x')
tempfile cuid`x'
save `cuid`x'', replace
restore
}

preserve
use `cuidpob', clear
foreach x of global var2 {
merge 1:1 pobreza_m using `cuid`x'', nogen
}

order pobreza_m, first
export excel using "$d\ENAHO.xlsx", sheet("Pobreza monetaria - GrupoA", modify) firstrow(var) cell(C3)
restore

* Ilustracion: Pobreza no monetaria de la población cuidadora 
foreach x of global var{
preserve
table pobreza_nm if `x'==1 [iw=facoit], c(freq) center row format(%18.0fc) replace 
label def pobreza_nm 99 "Total", modify
recode pobreza_nm (.=99)
rename (table1) (`x')
tempfile cuid`x'
save `cuid`x'', replace
restore
}

preserve
use `cuidpob', clear
foreach x of global var2 {
merge 1:1 pobreza_nm using `cuid`x'', nogen
}

order pobreza_nm, first
export excel using "$d\ENAHO.xlsx", sheet("Pobreza No monetaria - GrupoA", modify) firstrow(var) cell(C3)
restore
	   
* Ilustracion: Nivel educativo de la población cuidadora
foreach x of global var{
preserve
table nivel_edu if `x'==1 [iw=facoit], c(freq) center row format(%18.0fc) replace 
label def nivel_edu 99 "Total", modify
recode nivel_edu (.=99)
rename (table1) (`x')
tempfile cuid`x'
save `cuid`x'', replace
restore
}

preserve
use `cuidpob', clear
foreach x of global var2 {
merge 1:1 nivel_edu using `cuid`x'', nogen
}
order nivel_edu, first
export excel using "$d\ENAHO.xlsx", sheet("Nivel educativo - GrupoA", modify) firstrow(var) cell(C3)
restore
  

***********************************
** 		Estructura Familiar		 **
***********************************
putexcel set "$d\ENAHO.xlsx", modify sheet("ESTRUCTURA FAMILIAR GRUPO A")
putexcel B1="Estructura familiar de Cuidadorea - Grupo A"

** Estructura familiar según sexo, grupo etario - GRUPO A - AMBITO URBANO
preserve
table familias2 sexo if trab_cuid2==1 & inlist(g_etario, 3,4,5) [iw=facoit], c(freq) center col row format(%18.0fc) replace 
label def familias2 99 "Total", add
label def sexo 99 "Total", add
recode familias2 sexo (.=99)
reshape wide table1, i(familias2) j(sexo)
sort familias2
rename (table11 table12 table199) (Hombre Mujer Total)
export excel using "$d\ENAHO.xlsx", sheet("GrupA - Comp familiar", modify) firstrow(var) cell(C3)
restore

*-------------------------------------------------------------------------------
* Ilustraciones - Caracterización de Trabajadores del hogar
*-------------------------------------------------------------------------------

use "$b\Cuidadores_ENAHO21", clear

putexcel set "$d\ENAHO.xlsx", modify sheet("CARACTERIZACIÓN GRUPO B")
putexcel B1="Caracterización socioeconomica y laboral - Grupo B"

keep if inlist(g_etario, 3,4,5) //solo mayores de 18 años
keep if pea_ocupada == 1 //comparar con PEA Ocupada
drop if trab_cuid==5

tab trab_cuid2, gen(TC_)
rename (TC_1 TC_2 TC_3) (TC_2 TC_3 TC_4)

gen TC_m_2 = TC_2==1 & sexo==2
gen TC_h_2 = TC_2==1 & sexo==1
gen TC_urb_2 = TC_2==1 & ambito==1
gen TC_rur_2 = TC_2==1 & ambito==2
gen TC_joven_2 = TC_2==1 & inlist(g_etario,3)
gen TC_adulto_2 = TC_2==1 & inlist(g_etario,4)
gen TC_adultom_2 = TC_2==1 & inlist(g_etario,5)

gen pop_m_2 = sexo==2
gen pop_h_2 = sexo==1
gen pop_urb_2 = ambito==1
gen pop_rur_2 = ambito==2
gen pop_joven_2 = inlist(g_etario,3)
gen pop_adulto_2 = inlist(g_etario,4)
gen pop_adultom_2= inlist(g_etario,5)


global var pob TC_2 TC_rur_2 pop_rur_2 TC_urb_2 pop_urb_2 TC_m_2 pop_m_2 TC_h_2 pop_h_2 TC_joven_2 pop_joven_2 TC_adulto_2 pop_adulto_2 TC_adultom_2 pop_adultom_2
global var2 TC_2 TC_rur_2 pop_rur_2 TC_urb_2 pop_urb_2 TC_m_2 pop_m_2 TC_h_2 pop_h_2 TC_joven_2 pop_joven_2 TC_adulto_2 pop_adulto_2 TC_adultom_2 pop_adultom_2

global tipo "GrupoB" 

do "$a\1a. Tablas Caracterización.do"

*-------------------------------------------------------------------------------
* Ilustraciones Caracterización de trabajadores SALUD
*-------------------------------------------------------------------------------

use "$b\Cuidadores_ENAHO21", clear

putexcel set "$d\ENAHO.xlsx", modify sheet("CARACTERIZACIÓN GRUPO C")
putexcel B1="Caracterizacion socioeconomica y laboral - Grupo C"

keep if inlist(g_etario, 3,4,5) //solo mayores de 18 años
keep if pea_ocupada == 1 //comparar con PEA Ocupada
drop if trab_cuid==5


tab trab_cuid2, gen(TC_)
rename (TC_1 TC_2 TC_3) (TC_2 TC_3 TC_4) 

gen TC_m_3 = TC_3==1 & sexo==2
gen TC_h_3 = TC_3==1 & sexo==1
gen TC_urb_3 = TC_3==1 & ambito==1
gen TC_rur_3 = TC_3==1 & ambito==2
gen TC_joven_3 = TC_3==1 & inlist(g_etario,3)
gen TC_adulto_3 = TC_3==1 & inlist(g_etario,4)
gen TC_adultom_3 = TC_3==1 & inlist(g_etario,5)

gen pop_m_3 = sexo==2
gen pop_h_3 = sexo==1
gen pop_urb_3 = ambito==1
gen pop_rur_3 = ambito==2
gen pop_joven_3 = inlist(g_etario,3)
gen pop_adulto_3 = inlist(g_etario,4)
gen pop_adultom_3= inlist(g_etario,5)


global var pob TC_3 TC_rur_3 pop_rur_3 TC_urb_3 pop_urb_3 TC_m_3 pop_m_3 TC_h_3 pop_h_3 TC_joven_3 pop_joven_3 TC_adulto_3 pop_adulto_3 TC_adultom_3 pop_adultom_3
global var2 TC_3 TC_rur_3 pop_rur_3 TC_urb_3 pop_urb_3 TC_m_3 pop_m_3 TC_h_3 pop_h_3 TC_joven_3 pop_joven_3 TC_adulto_3 pop_adulto_3 TC_adultom_3 pop_adultom_3

global tipo "GrupoC" 

do "$a\1a. Tablas Caracterización.do"

* Salarios - Segun ocupacion
preserve
table tipo_ocup sexo [iw=facoit] if TC_3==1, c(mean ingm_empleo) center col row format(%18.1fc) replace 
label def tipo_ocup 99 "Total", add
label def sexo 99 "Total", add
recode tipo_ocup sexo (.=99)
reshape wide table1, i(tipo_ocup) j(sexo)
rename (table11 table12 table199) (Hombre Mujer Total)
export excel using "$d\ENAHO.xlsx", sheet("Ingprom - OcupacionGrupoC", modify) firstrow(var) cell(C3)
restore

*-------------------------------------------------------------------------------
* Ilustraciones Caracterización de trabajadores EDUCACIÓN
*-------------------------------------------------------------------------------

use "$b\Cuidadores_ENAHO21", clear

putexcel set "$d\ENAHO.xlsx", modify sheet("CARACTERIZACIÓN GRUPO D")
putexcel B1="Caracterizacion socioeconomica y laboral - Grupo D"

keep if inlist(g_etario, 3,4,5) //solo mayores de 18 años
keep if pea_ocupada == 1 //comparar con PEA Ocupada
drop if trab_cuid==5


tab trab_cuid2, gen(TC_)
rename (TC_1 TC_2 TC_3) (TC_2 TC_3 TC_4) 

gen TC_m_4 = TC_4==1 & sexo==2
gen TC_h_4 = TC_4==1 & sexo==1
gen TC_urb_4 = TC_4==1 & ambito==1
gen TC_rur_4 = TC_4==1 & ambito==2
gen TC_joven_4 = TC_4==1 & inlist(g_etario,3)
gen TC_adulto_4 = TC_4==1 & inlist(g_etario,4)
gen TC_adultom_4 = TC_4==1 & inlist(g_etario,5)

gen pop_m_4 = sexo==2
gen pop_h_4 = sexo==1
gen pop_urb_4 = ambito==1
gen pop_rur_4 = ambito==2
gen pop_joven_4 = inlist(g_etario,3)
gen pop_adulto_4 = inlist(g_etario,4)
gen pop_adultom_4= inlist(g_etario,5)


global var pob TC_4 TC_rur_4 pop_rur_4 TC_urb_4 pop_urb_4 TC_m_4 pop_m_4 TC_h_4 pop_h_4 TC_joven_4 pop_joven_4 TC_adulto_4 pop_adulto_4 TC_adultom_4 pop_adultom_4
global var2 TC_4 TC_rur_4 pop_rur_4 TC_urb_4 pop_urb_4 TC_m_4 pop_m_4 TC_h_4 pop_h_4 TC_joven_4 pop_joven_4 TC_adulto_4 pop_adulto_4 TC_adultom_4 pop_adultom_4

global tipo "GrupoD" 

do "$a\1a. Tablas Caracterización.do"

* Salarios - Segun ocupacion
preserve
table tipo_ocup sexo [iw=facoit] if TC_4==1, c(mean ingm_empleo) center col row format(%18.1fc) replace 
label def tipo_ocup 99 "Total", add
label def sexo 99 "Total", add
recode tipo_ocup sexo (.=99)
reshape wide table1, i(tipo_ocup) j(sexo)
rename (table11 table12 table199) (Hombre Mujer Total)
export excel using "$d\ENAHO.xlsx", sheet("Ingprom - OcupacionGrupoD", modify) firstrow(var) cell(C3)
restore

*-------------------------------------------------------------------------------
* EXPORTAMOS LOS DATOS - DIMENSIONAMIENTO MENORES DE 18 AÑOS
*-------------------------------------------------------------------------------
use "$b\Cuidadores_ENAHO21", clear

putexcel set "$d\ENAHO.xlsx", modify sheet("DIMENSIONAMIENTO MENOR 18 AÑOS")
putexcel B1="Dimensionamiento personas que realiza cuidados menor DE 18 AÑOS"

* Generamos variable que define al menor de 18 años que realiza cuidados
recode trab_cuid2 (1 = 1 "Realiza labores de cuidado") (2 3 4 5 = 2 "Cuidador remunerado en situación de trabajo"), gen(trab_cuid_nna)

** Total Cuidadores segun sexo
********************************
preserve
table trab_cuid_nna sexo g_etario if trab_cuid_nna!=. & inlist(g_etario,1,2) [iw=facoit], c(freq) center col row format(%18.0fc) replace 
label def trab_cuid_nna 99 "Total", add
label def sexo 99 "Total", add
recode sexo trab_cuid_nna (.=99)
reshape wide table1, i(g_etario sexo) j(trab_cuid_nna)
rename (table11 table12 table199) (Cuidador_NRem Cuidador_Rem Total)
export excel using "$d\ENAHO.xlsx", sheet("Menor 18 - Total TC", modify) firstrow(var) cell(C3)
restore

** Representación - Menores de 18 años según sexo /edad / ambito
*****************************************************************

* NACIONAL
preserve
table trab_cuid_nna sexo g_etario if trab_cuid_nna!=. & inlist(g_etario,1,2) [iw=facoit], c(freq) center col row format(%18.0fc) replace 
label def sexo 99 "Total", add
label def trab_cuid_nna 99 "Total", add
recode sexo trab_cuid_nna (.=99)
reshape wide table1, i(g_etario sexo) j(trab_cuid_nna)
rename (table11 table12 table199) (Cuidador_NRem Cuidador_Rem Total)
tempfile temp_nac
save `temp_nac', replace
restore

* URBANO
preserve
table trab_cuid_nna sexo g_etario if ambito==1 & trab_cuid_nna!=. & inlist(g_etario,1,2) [iw=facoit], c(freq) center col row format(%18.0fc) replace 
label def sexo 99 "Total", add
label def trab_cuid_nna 99 "Total", add
recode sexo trab_cuid_nna (.=99)
reshape wide table1, i(g_etario sexo) j(trab_cuid_nna)
rename (table11 table12 table199) (Cuidador_NRem Cuidador_Rem Total)
tempfile temp_urb
save `temp_urb', replace
restore

* RURAL
preserve
table trab_cuid_nna sexo g_etario if ambito==2 & trab_cuid_nna!=. & inlist(g_etario,1,2) [iw=facoit], c(freq) center col row format(%18.0fc) replace 
label def sexo 99 "Total", add
label def trab_cuid_nna 99 "Total", add
recode sexo trab_cuid_nna (.=99)
reshape wide table1, i(g_etario sexo) j(trab_cuid_nna)
rename (table11 table12 table199) (Cuidador_NRem Cuidador_Rem Total)
tempfile temp_rur
save `temp_rur', replace
restore

preserve
use `temp_nac', clear
gen ambito = "Nacional"
append using `temp_urb'
replace ambito = "Urbano" if ambito==""
append using `temp_rur'
replace ambito = "Rural" if ambito==""

order ambito
export excel using "$d\ENAHO.xlsx", sheet("Representa Menor 18", modify) firstrow(var) cell(C3)
restore

** Representación - Menores de 18 años según sexo /edad / ambito - NO CUIDADORES
*********************************************************************************
gen no_cuid = (trab_cuid_nna == .) 
replace no_cuid = . if no_cuid == 0 

* NACIONAL
preserve
table no_cuid sexo g_etario if no_cuid!=. & inlist(g_etario,1,2) [iw=facoit], c(freq) center col row format(%18.0fc) replace 
label def sexo 99 "Total", add
label def no_cuid 99 "Total", add
recode sexo no_cuid (.=99)
reshape wide table1, i(g_etario sexo) j(no_cuid)
drop table199
rename (table11) (No_cuidadores)
tempfile temp_nac
save `temp_nac', replace
restore

* URBANO
preserve
table no_cuid sexo g_etario if ambito==1 & no_cuid!=. & inlist(g_etario,1,2) [iw=facoit], c(freq) center col row format(%18.0fc) replace 
label def sexo 99 "Total", add
label def no_cuid 99 "Total", add
recode sexo no_cuid (.=99)
reshape wide table1, i(g_etario sexo) j(no_cuid)
drop table199
rename (table11) (No_cuidadores)
tempfile temp_urb
save `temp_urb', replace
restore

* RURAL
preserve
table no_cuid sexo g_etario if ambito==2 & no_cuid!=. & inlist(g_etario,1,2) [iw=facoit], c(freq) center col row format(%18.0fc) replace 
label def sexo 99 "Total", add
label def no_cuid 99 "Total", add
recode sexo no_cuid (.=99)
reshape wide table1, i(g_etario sexo) j(no_cuid)
drop table199
rename (table11) (No_cuidadores)
tempfile temp_rur
save `temp_rur', replace
restore

preserve
use `temp_nac', clear
gen ambito = "Nacional"
append using `temp_urb'
replace ambito = "Urbano" if ambito==""
append using `temp_rur'
replace ambito = "Rural" if ambito==""

order ambito
export excel using "$d\ENAHO.xlsx", sheet("No_cuid Menor 18", modify) firstrow(var) cell(C3)
restore

*-------------------------------------------------------------------------------
* CARACTERIZACIÓN MENORES DE 18 AÑOS
*-------------------------------------------------------------------------------
putexcel set "$d\ENAHO.xlsx", modify sheet("CARACTERIZACION NNA")
putexcel B1="Caracterización Menores de 18 años"

use "$b\Cuidadores_ENAHO21", clear

keep if inlist(g_etario, 1 , 2 )
tab trab_cuid2, gen(TC_)

gen TC_m 			= TC==1 & sexo==2
gen TC_h 			= TC==1 & sexo==1
gen TC_urb 			= TC==1 & ambito==1
gen TC_rur 			= TC==1 & ambito==2
gen TC_nin	 		= TC==1 & inlist(g_etario,1)
gen TC_ado			= TC==1 & inlist(g_etario,2)

gen pop_m			= sexo==2
gen pop_h 			= sexo==1
gen pop_urb 		= ambito==1
gen pop_rur 		= ambito==2
gen pop_nin 		= inlist(g_etario,1)
gen pop_ado	 		= inlist(g_etario,2)

global var pob TC TC_rur pop_rur TC_urb pop_urb TC_m pop_m TC_h pop_h TC_nin pop_nin TC_ado pop_ado 
global var2 TC TC_rur pop_rur TC_urb pop_urb TC_m pop_m TC_h pop_h TC_nin pop_nin TC_ado pop_ado


** Nivel educativo
**********************
foreach x of global var{
preserve
table nivel_edu if `x'==1 [iw=facoit], c(freq) center row format(%18.0fc) replace 
label def nivel_edu 99 "Total", modify
recode nivel_edu (.=99)
rename (table1) (`x')
tempfile cuid`x'
save `cuid`x'', replace
restore
}

preserve
use `cuidpob', clear
foreach x of global var2 {
merge 1:1 nivel_edu using `cuid`x'', nogen
}
order nivel_edu, first
export excel using "$d\ENAHO.xlsx", sheet("Nivel educativo - NNA", modify) firstrow(var) cell(C3)
restore

** Tasa de matricula 
**********************
foreach x of global var {
preserve
table `x' if `x'==1 & inlist(g_etario,1,2) [iw=facoit], c(sum matricula_prim sum pers_prim sum matricula_sec sum pers_sec) center format(%18.0fc) replace 
drop `x'
rename (table1 table2 table3 table4) (Prim_matr Prim_tot Sec_matr Sec_tot)
tempfile cuid`x'
save `cuid`x'', replace
restore
}

preserve
use `cuidpob', clear
foreach x of global var2 {
append using `cuid`x''
}
gen grupo=_n
recode grupo (1=1 "pob")   (2=2 "TC")   (3=3 "TC_rur")   (4=4 "pop_rur")   (5=5 "TC_urb")   (6=6 "pop_urb")   (7=7 "TC_m")   (8=8 "pop_m")   (9=9 "TC_h")   (10=10 "pop_h")   (11=11 "TC_nin")   (12=12 "pop_nin")   (13=13 "TC_ado")   (14=14 "pop_ado")   , gen(grupo_r)
drop grupo
order grupo, first
export excel using "$d\ENAHO.xlsx", sheet("Tasa matricula - NNA", modify) firstrow(var) cell(C3)
restore

** Tasa total de asistencia
***************************
foreach x of global var {
preserve
table `x' if `x'==1 & inlist(g_etario,1,2) [iw=facoit], c(sum asist_prim sum pers_prim sum asist_sec sum pers_sec) center format(%18.0fc) replace 
drop `x'
rename (table1 table2 table3 table4) (Prim_asist Prim_tot Sec_asist Sec_tot)
tempfile cuid`x'
save `cuid`x'', replace
restore
}

preserve
use `cuidpob', clear
foreach x of global var2 {
append using `cuid`x''
}
gen grupo=_n
recode grupo (1=1 "pob")   (2=2 "TC")   (3=3 "TC_rur")   (4=4 "pop_rur")   (5=5 "TC_urb")   (6=6 "pop_urb")   (7=7 "TC_m")   (8=8 "pop_m")   (9=9 "TC_h")   (10=10 "pop_h")   (11=11 "TC_nin")   (12=12 "pop_nin")   (13=13 "TC_ado")   (14=14 "pop_ado")   , gen(grupo_r)
drop grupo
order grupo, first
export excel using "$d\ENAHO.xlsx", sheet("Tasa asistencia - NNA", modify) firstrow(var) cell(C3)
restore

** Tasa desercion escolar
***************************
foreach x  of global var {
preserve
table `x' if `x'==1 & inlist(g_etario,1,2) [iw=facoit], c(sum prim_nomatr sum prim_incomp sum sec_nomatr sum sec_incomp) center format(%18.0fc) replace 
drop `x'
rename (table1 table2 table3 table4) (Prim_nomatr Prim_incomp Sec_nomatr Sec_incomp)
tempfile cuid`x'
save `cuid`x'', replace
restore
}

preserve
use `cuidpob', clear
foreach x of global var2 {
append using `cuid`x''
}
gen grupo=_n
recode grupo (1=1 "pob")   (2=2 "TC")   (3=3 "TC_rur")   (4=4 "pop_rur")   (5=5 "TC_urb")   (6=6 "pop_urb")   (7=7 "TC_m")   (8=8 "pop_m")   (9=9 "TC_h")   (10=10 "pop_h")   (11=11 "TC_nin")   (12=12 "pop_nin")   (13=13 "TC_ado")   (14=14 "pop_ado")   , gen(grupo_r)
drop grupo
order grupo, first
export excel using "$d\ENAHO.xlsx", sheet("Tasa desercion - NNA", modify) firstrow(var) cell(C3)
restore

** Tasa de atraso escolar
***************************
foreach x of global var {
preserve
table `x' if `x'==1 & inlist(g_etario,1,2) [iw=facoit], c(sum atraso_prim sum matricula_prim sum atraso_sec sum matricula_sec) center format(%18.0fc) replace 
drop `x'
rename (table1 table2 table3 table4) (Prim_atraso Prim_matr Sec_atraso Sec_matr)
tempfile cuid`x'
save `cuid`x'', replace
restore
}

preserve
use `cuidpob', clear
foreach x of global var2 {
append using `cuid`x''
}
gen grupo=_n
recode grupo (1=1 "pob")   (2=2 "TC")   (3=3 "TC_rur")   (4=4 "pop_rur")   (5=5 "TC_urb")   (6=6 "pop_urb")   (7=7 "TC_m")   (8=8 "pop_m")   (9=9 "TC_h")   (10=10 "pop_h")   (11=11 "TC_nin")   (12=12 "pop_nin")   (13=13 "TC_ado")   (14=14 "pop_ado")   , gen(grupo_r)
drop grupo
order grupo, first
export excel using "$d\ENAHO.xlsx", sheet("Tasa atraso escolar - NNA", modify) firstrow(var) cell(C3)
restore

** Tasa de repitencia escolar
***************************
foreach x of global var {
preserve
table `x' if `x'==1 & inlist(g_etario,1,2) [iw=facoit], c(sum repite_prim sum matricula_prim sum repite_sec sum matricula_sec) center format(%18.0fc) replace 
drop `x'
rename (table1 table2 table3 table4) (Prim_repite Prim_matr Sec_repite Sec_matr)
tempfile cuid`x'
save `cuid`x'', replace
restore
}

preserve
use `cuidpob', clear
foreach x of global var2 {
append using `cuid`x''
}
gen grupo=_n
recode grupo (1=1 "pob")   (2=2 "TC")   (3=3 "TC_rur")   (4=4 "pop_rur")   (5=5 "TC_urb")   (6=6 "pop_urb")   (7=7 "TC_m")   (8=8 "pop_m")   (9=9 "TC_h")   (10=10 "pop_h")   (11=11 "TC_nin")   (12=12 "pop_nin")   (13=13 "TC_ado")   (14=14 "pop_ado")   , gen(grupo_r)
drop grupo
order grupo, first
export excel using "$d\ENAHO.xlsx", sheet("Tasa repitencia escolar - NNA", modify) firstrow(var) cell(C3)
restore


*-------------------------------------------------------------------------------
* APORTE ECONOMICO DE CUIDADORES NO REMUNERADOS
*-------------------------------------------------------------------------------

use "$b\Cuidadores_ENAHO21", clear

**********************************
** 		APORTE ECONOMICO  		**
**********************************
putexcel set "$d\ENAHO.xlsx", modify sheet("APORTE ECONOMICO")
putexcel B1="Estimación de aporte económico"


*=========================================
* PASO 1: SALARIO DE TRABAJADOR DEL HOGAR
*=========================================
cap drop ingsem_empleo
gen ingsem_empleo = ingm_empleo/4

preserve
table sexo [iw=facoit] if trab_cuid2==2, c(mean ingsem_empleo mean tothrs) center row format(%18.0fc) replace 
rename (table1 table2) (ingreso_semanal hr_semanal)
label def sexo 99 "Total", modify
recode sexo (.=99)
order sexo
export excel using "$d\ENAHO.xlsx", sheet("Aporte Salario_TH", modify) firstrow(var) cell(C3)
restore


*=======================================================================
* PASO 2: SALARIO DE HOMBRE/MUJER SEGÚN CARACTERISTICAS SOCIOECONOMICAS
*=======================================================================

** Contribucion de Cuidadores - GrupoA
*****************************************
global XX ambito sexo c.p208a##c.p208a i.estado_civil i.educ familias estudia enfermo seguro_salud i.dominio

* Horas
reg tothrs $XX [iw=facoit] , vce(robust)
cap drop hora_est
predict hora_est, xb //valores estimados

cap drop temp_hora
bys dominio ambito sexo p208a estado_civil educ familias estudia enfermo seguro_salud: egen temp_hora = mean(hora_est) if pob==1

replace tothrs = temp_hora if mi(tothrs) & pob==1 
replace tothrs = temp_hora if pob==1 & tothrs<6 & tothrs!=.


* Salario por hora
cap drop valor_hora_r
gen valor_hora_r = ingm_empleo_r/(tothrs*4)

recode ingm_empleo ingm_empleo_r lingm_empleo_r remunerado (0=.) if empleos_cuidados!=. & remunerado==0 //29 empleados de cuidados con missing en salarios
reg valor_hora_r $XX [iw=facoit] , vce(robust)
cap drop salario_est
predict salario_est, xb

cap drop temp_sal
bys dominio ambito sexo p208a estado_civil educ familias estudia enfermo seguro_salud: egen temp_sal = mean(salario_est) if pob==1 & trab_cuid!=. & remunerado==0
replace valor_hora_r = temp_sal if remunerado==0


*Tabla
preserve
table trab_cuid2 sexo  if trab_cuid2==1 & inlist(g_etario,3,4,5) [iw=facoit], c(freq mean tothrs mean valor_hora_r) col center format(%18.0fc) replace
label def trab_cuid 99 "Total", add
label def sexo 99 "Total", add
recode trab_cuid sexo (.=99)
order trab_cuid sexo
sort trab_cuid sexo
rename (table1 table2 table3) (TC Horas Valor_hora)
export excel using "$d\ENAHO.xlsx", sheet("TC aporte salario", modify) firstrow(var) cell(C3)
restore



*-------------------------------------------------------------------------------
* VARIABLE DE SINDICALIZACIÓN
*-------------------------------------------------------------------------------
global id ubigeo nconglome conglome vivienda hogar codperso 

* Identificamos quien forma parte de una asociación/sindicato
use "$b\enaho01-2021-800b", clear
*keep if inlist(p803,1,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18)
keep if p803==8
collapse (count) p803, by($id)
recode p803 (1/5=1)
rename p803 sindicalizado
save "$b\sindicalización pob", replace


* Se anexa a base central
use "$b\Cuidadores_ENAHO21", clear
merge 1:1 ubigeo nconglome conglome vivienda hogar codperso using "$b\sindicalización pob", nogen keep(1 3)
recode sindicalizado (.=0)
keep if inlist(g_etario, 3,4,5)

tab trab_cuid2 sindicalizado  [iw=facoit] if trab_cuid2!=5 , nofreq row
tab sindicalizado  [iw=facoit] if inlist(g_etario, 3,4,5) & pea_ocup==1

putexcel set "$d\ENAHO.xlsx", modify sheet("CARACTERIZACIÓN GRUPO A")
putexcel B1="Caracterización socioeconomica - Grupo A"

