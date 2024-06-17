
clear all
set more off
set excelxlsxlargefile on 

**Definimos directorio (solo modificar global SP)
**==================================================
global SP evera
global path "C:\Users/${SP}\Macroconsult S.A\Impacto de la minería PERUMIN - General\4. Estimación"
global a "$path\\a_Do"
global b "$path\\b_BD"
global c "$path\\c_Temp"
global d "$path\\d_Output"
global bd "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\BBDD\Enaho Metodología anterior"
global m "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\MAPAS"


*-------------------------------------------------------------------------------
* A) GENERACIÓN DE VARIABLES
*-------------------------------------------------------------------------------
global id_viv conglome vivienda hogar

forval p=1998/2003{
global año `p'

use "$b/ENAHO/ENAHO_consolidado_$año", clear

* MODULO 100: Vivienda
*========================

* Pared
cap drop pared
cap nois gen pared = p102
recode pared (4=5) (5=6) (7=8) (8=9) // para alinearse a categorias actuales

* Pared con material adecuado
cap drop pared_ad
cap nois gen pared_ad = inlist(pared,1,2) if !mi(pared)

* Piso
cap drop piso
cap nois gen piso = p103

* Piso con material adecuado
cap drop piso_ad
cap nois gen piso_ad = inlist(piso,1,2,3,5) if !mi(piso)

* Techo
cap drop techo
cap nois gen techo = p103a

* Techo con material adecuado
cap drop techo_ad
cap nois gen techo_ad = inlist(techo,1,2,3,4) if !mi(techo)

* Nro de habitaciones
cap drop nro_hab
cap nois gen nro_hab = p104

* Vivienda alquilada
cap drop alquila_viv
cap nois gen alquila_viv = p105a ==1 if p105a!=.

* Precio alquiler
cap drop malq_viv
cap nois gen malq_viv = p105b if alquila_viv==1

* Precio alquiler subjetivo
cap drop malq_viv2
cap nois gen malq_viv2 = p106

* Servicio agua
cap drop serv_agua
cap nois gen serv_agua = p110

* Agua por red publica
cap drop agua_redp
cap nois gen agua_redp = inlist(serv_agua,1,2) if !mi(serv_agua)

* Servicio desague
cap drop serv_desague
cap nois gen serv_desague = p111
recode serv_desague (3=4) (4=5) (5=6) (6=8) // para alinearse a categorias actuales

* Desague por red publica
cap drop desague_redp
cap nois gen desague_redp = inlist(serv_desague,1,2) if !mi(serv_desague)

* Servicio alumbrado
cap drop serv_luz
cap nois gen serv_luz = p1121==1 if p1121!=.

* Servicio combustible cocina electrica
cap drop cocina_electrica
cap nois gen cocina_electrica = p1131==1 if p1131!=.

* Servicio combustible cocina glp
cap drop cocina_glp
cap nois gen cocina_glp = p1132==1 if p1132!=.

* Servicio combustible cocina carbon/leña
cap drop cocina_carbon_leña
cap nois gen cocina_carbon_leña = (p1134==1 | p1135==1) if p1134!=. & p1135!=.

* Telefono celular
cap drop celular
cap nois gen celular = p1142 == 1 if p1142!=.

* Internet
cap drop internet
cap nois gen internet = p1144 == 1 if p1144!=.


* MODULO 200: Miembros de HOGAR
*===============================

* Relacion de parentesco
cap drop parentesco
recode p203 (1=1 "Jefe hogar") (2=2 "Conyuge") (3=3 "Hijo") (4/11 = 4 "Otro miembro"), gen(parentesco)

* Edad y sexo de Jefe Hogar
rename p207 sexo
rename p208a edad
cap drop sexo_jh
cap nois gen sexo_jh = sexo if parentesco ==1

cap drop edad_jh
cap nois gen edad_jh = edad if parentesco ==1

* Migracion
if `p' > 2000 {
cap nois gen nac_ubi = p208a2
tostring nac_ubi, replace
replace nac_ubi = "77" + nac_ubi if length(nac_ubi)==4 //extranjeros
replace nac_ubi = "0" + nac_ubi if length(nac_ubi)==5
cap drop prov_nac
cap nois gen prov_nac = substr(nac_ubi,1,4)
cap drop prov_viv
cap nois gen prov_viv = substr(ubigeo,1,4)

cap drop migracion
cap nois gen migracion = .
replace migracion = 0 if p208a1 == 1
replace migracion = 1 if prov_viv!=prov_nac & p208a1!=.
}

* JH migrante
cap drop migrante_jh
cap nois gen migrante_jh = migracion if parentesco == 1

* MODULO 300: Educacion
*===============================

* Nivel educativo
cap drop nivel_edu
gen nivel_edu = 1 if inlist(p301a,1,2,3,4,5)
replace nivel_edu = 2 if inlist(p301a,6,7,9)
replace nivel_edu = 3 if inlist(p301a,8,10)
label define nivel_edu 1 "primaria" 2 "secundaria" 3 "superior"
label values nivel_edu nivel_edu

* Dicotomicas Nivel educativo
cap drop nivel_edu_*
tab nivel_edu, gen(nivel_edu_)
cap gen nivel_edu_secsup = inlist(nivel_edu,2,3) if !mi(nivel_edu)
cap nois rename nivel_edu_1 nivel_edu_prim
cap nois rename nivel_edu_2 nivel_edu_sec
cap nois rename nivel_edu_3 nivel_edu_sup

foreach x of varlist nivel_edu_* {
replace `x' = . if edad >=18 & !mi(edad)
}

* Años de educación
destring p301b p301c, replace
replace p301b =6 if p301a ==4
replace p301c =6 if p301a ==4
gen anios_educ=.
replace anios_educ=0 if p301a<=2
replace anios_educ=p301b if p301a==3 & !inlist(p301b,99,.)
replace anios_educ=p301c if p301a==3 & !inlist(p301c,99,.)
replace anios_educ =p301b if p301a==4 & !inlist(p301b,99,.)
replace anios_educ =p301c if p301a==4 & !inlist(p301c,99,.)
replace anios_educ = 6 + p301b if p301a==5
replace anios_educ = 6 + p301b if p301a==6
replace anios_educ = 11 + p301b if inlist(p301a, 7, 8, 9, 10)
replace anios_educ = 16 + p301b if p301a==11
replace anios_educ = . if edad >=18 & !mi(edad)

gen anios_educ2 = anios_educ*anios_educ

* Analfabetismo
cap drop analfabeta
cap nois gen analfabeta = p302 == 1 if !inlist(p302,.)

cap drop analf_mujer
cap nois gen analf_mujer = analfabeta == 1 & sexo==2

* Esta matriculado
if `p' > 2001 {
cap drop matricula
cap nois gen matricula = p306 == 1 if !mi(p306)
}

* Asiste a IE
if `p' > 2001 {
cap drop asisteIE
cap nois gen asisteIE = p307 == 1 if !mi(p307)
}

else{
cap drop asisteIE
cap nois gen asisteIE = p303 == 1 if !mi(p303)
}

* Atraso escolar
if `p' > 2001 {
cap drop atraso_escolar
cap nois gen atraso_escolar = 	edad>=8 & p308a==2 & (p308b==1 | p308c==1) /// 1° prim con 6 años
								edad>=9 & p308a==2 & (p308b==2 | p308c==2) ///
								edad>=10 & p308a==2 & (p308b==3 | p308c==3) ///
								edad>=11 & p308a==2 & (p308b==4 | p308c==4) ///
								edad>=12 & p308a==2 & (p308b==5 | p308c==5) ///
								edad>=13 & p308a==2 & (p308b==6 | p308c==6) ///
								edad>=14 & p308a==3 & p308b==1 | /// 1° sec con 11 años
								edad>=15 & p308a==3 & p308b==2 | ///
								edad>=16 & p308a==3 & p308b==3 | ///
								edad>=17 & p308a==3 & p308b==4 | ///
								edad>=18 & p308a==3 & p308b==5 if asisteIE==1

}

else{
cap drop atraso_escolar
cap nois gen atraso_escolar = 	edad>=8 & p304a==2 & (p304b==1 | p304c==1) /// 1° prim con 6 años
								edad>=9 & p304a==2 & (p304b==2 | p304c==2) ///
								edad>=10 & p304a==2 & (p304b==3 | p304c==3) ///
								edad>=11 & p304a==2 & (p304b==4 | p304c==4) ///
								edad>=12 & p304a==2 & (p304b==5 | p304c==5) ///
								edad>=13 & p304a==2 & (p304b==6 | p304c==6) ///
								edad>=14 & p304a==3 & p304b==1 | /// 1° sec con 11 años
								edad>=15 & p304a==3 & p304b==2 | ///
								edad>=16 & p304a==3 & p304b==3 | ///
								edad>=17 & p304a==3 & p304b==4 | ///
								edad>=18 & p304a==3 & p304b==5 if asisteIE==1
}

*Desercion escolar
cap drop desercion
cap nois gen desercion = asisteIE==0 & nivel_edu==1 & (p301b<5 | p301c<6)  & edad<=14 | /// primaria
						asisteIE==0 & nivel_edu==2 & p301b<5  & edad<=19 //secundaria
replace desercion = . if edad>19

* MODULO 400: Salud
*========================

* Padece enfermedad
cap drop enfermedad
cap nois gen enfermedad = p401 == 1 if p401!=.

* En ultimas 4 semanas, presentó 
if `p' > 2001 {
cap drop malestar_4s
cap nois gen malestar_4s = p4021==1 if p4021!=.

cap drop enfermedad_4s
cap nois gen enfermedad_4s = p4022==1 if p4022!=.

cap drop enfcronica_4s
cap nois gen enfcronica_4s = p4023==1 if p4023!=.

cap drop accidente_4s
cap nois gen accidente_4s = p4024==1 if p4024!=.
}
//Nota: la pregunta de presentar malestar, enfermedad en las ultimas 4 sem aparece desde 2002

* Atendido por medico
if `p' < 2002 {
cap drop atencion_medico
cap nois gen atencion_medico = p4051==1 if p4051!=.
}

else{
cap drop atencion_medico
cap nois gen atencion_medico = p4041==1 if p4041!=.
}
//Nota: En 2002 se cambio la numeración de la atencion medica


* Seguro salud
if `p' == 2000 | `p' == 2001 {
cap drop seguro_salud
cap nois gen seguro_salud = p4128 ==0

cap drop essalud
cap nois gen essalud = p4121 ==1
}


if `p' > 2001 {
cap drop seguro_salud
cap nois gen seguro_salud = p4199 ==0

cap drop essalud
cap nois gen essalud = p4191 ==1

cap drop sis
cap nois gen sis = p4196 ==1
}
//Nota: En 2002 se agregó la opción de EPS, SIS y cambio de numeracion


* MODULO 500: Empleo
*========================

*PEA
cap nois rename ocupa ocu500
gen pea=(ocu500==1|ocu500==2)==1
recode pea (0=2)
label define pea 1 "PEA" 2 "PEI"
label values pea pea

*PEA ocupada
gen pea_ocupada=(ocu500==1)==1 if pea==1
recode pea_ocupada (0=2)
label define pea_ocupada 1 "pea ocupada" 2 "pea desocupada"
label values pea_ocupada pea_ocupada

* Actividad economica //Rev 3
cap drop act_econ3
cap nois gen  act_econ3=1  if p506>=0 & p506<=200
replace act_econ3=2  if p506==500
replace act_econ3=3  if p506>=1000 & p506<=1429
replace act_econ3=4  if p506>=1500 & p506<=3720
replace act_econ3=5  if p506>=4000 & p506<=4100
replace act_econ3=6  if p506>=4500 & p506<=4550
replace act_econ3=7  if p506>=5000 & p506<=5270
replace act_econ3=8  if p506>=5510 & p506<=5520
replace act_econ3=9  if p506>=6000 & p506<=6420
replace act_econ3=10 if p506>=6500 & p506<=6720
replace act_econ3=11 if p506>=7000 & p506<=7499
replace act_econ3=12 if p506>=7500 & p506<=7530
replace act_econ3=13 if p506>=8000 & p506<=8090
replace act_econ3=14 if p506>=8500 & p506<=8532
replace act_econ3=15 if p506>=9000 & p506<=9309
replace act_econ3=16 if p506==9500
replace act_econ3=17 if p506>=9900 & p506<=9999
label define act_econ3 1  "Agricultura, Ganaderia, Silvicultura" ///
2  "Pesca" ///
3  "Explotacion de minas y canteras" ///
4  "Industrias manufactureras" ///
5  "Suministro de electricidad, gas y agua" ///
6  "Construccion" ///
7  "Comercio" ///
8  "Hoteles y restaurantes" ///
9  "Transporte, almacenamiento y comunicaciones" ///
10 "Intermediacion financiera" ///
11 "Actividades inmobiliarias, empresariales y de alquiler" ///
12 "Administracion publica y defensa" ///
13 "Enseñanza privada" ///
14 "Actividades de servicios sociales y de salud privada" ///
15 "Otras actividades de servicios comunitarios, sociales y personales" ///
16 "Hogares privados con servicio domestico" ///
17 "Organizaciones y organismos extraterritoriales" 
label values act_econ3 act_econ3
recode act_econ3 (1 2=1 "Agricultura y pesca") (3=2 "Mineria")  (4=3 "Manufactura") (5=4 "Electricidad y agua") (6=5 "Construccion") (7=6 "Comercio") (8/17=7 "Servicios"), g(act_econ)

*Condicion de trabajo
cap drop condicion
gen condicion = 1 if pea_ocupada==1 & (p507==1 | p507==2)
replace condicion = 2 if pea_ocupada==1 & (p507==3 | p507==4 | p507==6 ) //incluye a trabajador del hogar
replace condicion = 3 if pea_ocupada==1 & (p507==5 | p507==7)
label define condicion 1 "Independientes" 2 "Dependientes" 3"TFNR"
label values condicion condicion

* Horas laborales
cap drop tothrs
cap nois gen tothrs = .
replace tothrs = (p513t + p518) if (ocu500 ==1 & p518>=0 & p519==1)
replace tothrs = (p513t) if (ocu500 ==1 & p518==. & p519==1) & mi(tothrs)
replace tothrs = (p520) if (ocu500 ==1 & p519==2) & mi(tothrs)

* Ingresos laborales
egen rem_m   = rowtotal(i524a1 i530a i538a1 i541a d544t), m //remuneracion por conceptos monetarios
egen rem_nom    = rowtotal(d529t d536 d540t d543), m //remuneracion por conceptos no monetarios

cap drop ingm_lab
egen ingm_lab = rowtotal(rem_m rem_nom) if pea_ocupada==1,m
recode rem_m rem_nom (.=0) if ingm_lab!=.
recode ingm_lab (.=0) if condicion==3 // se corrobora que los TFNR no reciben pago alguno

* Ingresos no laborales
egen ing_nolab = rowtotal(d556t1 d556t2 d557t d558t), m // transferencias, remesas y otros ingresos
cap drop ingm_nolab 
cap nois gen ingm_nolab = ing_nolab
cap drop ing_nolab

* Mensualizamos Ingresos laborales y no laborales
if `p'!=2003{ //Nota: desde 2003 los datos ya son anualizados, antes eran trimestrales
replace ingm_lab = ingm_lab/3 
replace ingm_nolab = ingm_nolab/3 
}

else{
replace ingm_lab = ingm_lab/12 
replace ingm_nolab = ingm_nolab/12
}

* Ingreso total a nivel hogar
cap drop x_inghog
cap nois egen x_inghog = rowtotal(ingm_lab ingm_nolab), m

cap drop inghog
bys conglome vivienda hogar: egen inghog = sum (x_inghog)
cap drop x_inghog

* Ingreso per capita
cap drop ingpercap
cap gen ingpercap = inghog/totmieho

* Perceptores de ingreso en hogar
gen percep_ocup=1 if (p204==1 & p203!=8 & p203!=9) & pea_ocup==1 & (ingm_lab>0 & ingm_lab<35000)
preserve
collapse (sum) percep_ocup, by(ubigeo conglome vivienda hogar)
tempfile percep_ocup
save `percep_ocup', replace
restore
merge m:1 $id_viv using `percep_ocup', nogen

* Ingreso medio según dominio territorial
gen ing_medio=linea*mieperho/percep_ocup
preserve
collapse (mean) ing_mediod=ing_medio, by(dominio)
label var ing_mediod "Ingreso medio según dominio territorial"
tempfile ingreso_medio
save `ingreso_medio', replace
restore
merge m:1 dominio using `ingreso_medio', nogen

* Subempleo
cap drop subempleo
gen subempleo = .
replace subempleo = 1 if pea_ocupada==1 & tothrs<35  &  p521==1 //trabaja menos de 35h pero quiere trabajar más
replace subempleo = 2 if pea_ocupada==1 & tothrs>=35 & (ingm_lab<=ing_mediod) & subempleo==. //trabaja mas de 35h pero su ingreso es menor al ingreso medio del dominio
replace subempleo = 2 if pea_ocupada==1 & tothrs<35  & (ingm_lab<=ing_mediod) & subempleo==. //trabaja menos de 35h y su ingreso por debajo de ing medio
replace subempleo = 3 if pea_ocupada==1 & tothrs<35  & p521==2 & subempleo==. //trabaja menos de 35h pero no queria trabajar mas horas
replace subempleo = 3 if pea_ocupada==1 & tothrs>=35 & (ingm_lab>ing_mediod) & subempleo==. //trabaja mas de 35h y su ingreso es mayor que ing medio
label def subempleo 1 "Subempleo horas" 2 "Subempleo ingreso" 3 "Empleo adecuado", modify
label val subempleo subempleo


* Descuento de ley a remuneracion (AFP, ONP, pensiones)
recode p524b1 (1/100000000000=1), gen (dscto) //descuento de ley

* Nota: no se puede calcular la informalidad porque previo a 2002 no se preguntaba por RUC
* Sector Institucional de Hogares Productores 
if `p' > 2001 { 
gen 	inst=1 	if 	inlist(p507,3,4) & inlist(p510,1,2,3,4,5) 					// Trab dependiente de FFAA, Sector publico, SERVICE
replace inst=1 	if 	inlist(p507,3,4) & inlist(p510,6,7) & p510a==1 				// Trab dependiente en Negocio jurídico
replace inst=1 	if	inlist(p507,3,4) & inlist(p510,6,7) & p510a==2 & 	///
					!inlist(act_econ,1,.) &   							///
					((p512b>30 & p512b!=.) | (p512a>1 & p512a!=.)) 				// Trab dependiente en Negocio natural o sin RUC con mas de 30 trabajadores que no pertenece a la act agropecuaria
replace inst=1 	if 	inlist(p507,1,2) & p510a==1			 						// Trab independiente con Negocio jurídico
replace inst=1 	if 	inlist(p507,1,2) & p510a==2  & 						///
					!inlist(act_econ,1,.) & 							///
					((p512b>30 & p512b!=.) | (p512a>1 & p512a!=.)) 				// Trab independiente con Negocio natural o sin RUC con mas de 30 trabajadores que no pertenece a la act agropecuaria
replace inst=2 	if 	inlist(p507,5,7) 											//Trab familiar no remunerado y otro tipo de trabajador
replace inst=2 	if 	inlist(p507,3,4) & inlist(p510,6,7) & 				///
					p510a==2 &	inlist(act_econ,1)								//Trab dependiente en Negocio natural o sin RUC del sector agropecuario
replace inst=2 	if 	inlist(p507,3,4) & inlist(p510,6,7) & 				///
					p510a==2 & !inlist(act_econ,1,.)  & 				///
					((p512b<=30 & p512b!=.) | p512a==1) 						//Trab dependiente en Negocio natural o sin RUC con menos de 30 trabajadores que no pertenece a la act agropecuaria
replace inst=2 	if 	inlist(p507,1,2) & p510a==2  & 						///
					inlist(act_econ,1)											//Trab independiente en Negocio natural o sin RUC del sector agropecuario
replace inst=2 	if 	inlist(p507,1,2) & p510a==2  & 						///
					!inlist(act_econ,1,.) & 							///
					((p512b<=30 & p512b!=.) | p512a==1)							//Trab independiente en Negocio natural o sin RUC con menos de 30 trabajadores que no pertenece a la act agropecuaria

replace inst=3 	if 	p507==6 													//Trabajadores del hogar												
replace inst=. 	if 	ocu500!=1													//Solo acotamos a la PEA Ocupada
replace inst=2 	if 	ocu500==1 & inst==.											//Los que no se puede diferenciar se van a Hogares de mercado
label def inst 1"Sociedad" 2"Hogares de mercado" 3"Hogares autoconsumo"
label val inst inst

* PEA Ocupada según Sector Formal e Informal

gen sector_f=1 		if 	inst==1													//Los trabajadores de las Sociedades pertenecen al sector formal
replace sector_f=1 	if 	inst==2 & !inlist(act_econ,1,.) & 				///
						inlist(p507,3,4) & p510b==1	& sector_f==.				//Personas trabajando en Negocio con sistemas de conta no dedicados a actividades agropecuarias son sector formal
replace sector_f=1 	if 	inst==2 & !inlist(act_econ,1,.) & 				///
						inlist(p507,1,2) & 								///
						(p510a==1 | p510b==1) & sector_f==.					//Personas trabajando en Negocio sin RUC no dedicado a actividades extractivas son sector formal
replace sector_f=2 	if 	inst==2 & !inlist(act_econ,1,.) & 				///
						inlist(p507,3,4) & p510b==2 & 					///
						((p512b<=5 & p512b!=.) | p512a==1) & sector_f==.		//Personas trabajando en Negocio con sistemas de conta no dedicados a actividades agropecuarias son sector informal
replace sector_f=2 	if 	inst==2 & sector_f==. & inlist(act_econ,1)				//Personas trabajando en Negocio dedicado a actividades extractivas son sector informal
replace sector_f=2 	if 	inst==2 & !inlist(act_econ,1,.) & 				///
						inlist(p507,5,7) & 								///
						((p512b<=5 & p512b!=.) | p512a==1) & sector_f==.		//Personas trabajando en Negocio sin RUC no dedicado a actividades extractivas son sector informal
replace sector_f=2 	if 	inst==2 & !inlist(act_econ,1,.) & 				///
						inlist(p507,1,2) & 	p510a==2	& sector_f==.			//Personas trabajando en Negocio sin RUC no dedicado a actividades extractivas son sector informal

replace sector_f=3 	if 	inst==3													//Trabajadores del hogar
label def sector_f 1"Sector formal" 2"Sector informal" 3"Trabajador del hogar"
label val sector_f sector_f

* PEA Ocupada que se desempeña en empleo_f Formal e Informal
gen empleo_f=0 if sector_f==2												//Toda la gente que labora en el sector informal es empleo informal
replace empleo_f=0 if sector_f==1 & (p507==5 | p507==7)						//Trabajador del hogar y otros del sector formal son empleo informal
replace empleo_f=0 if sector_f==1 & (p507==3 | p507==4) & dscto==0			//Trabajador dependiente del sector formal que no le pagan su seguro de salud es empleo informal
replace empleo_f=0 if sector_f==3 & (p507==6) & dscto==0					//Trabajador del hogar sin pago de seguro es empleo informal
replace empleo_f=1 if sector_f==1 & (p507==1 | p507==2)						//Trabajadores independientes del sector formal son empleo_f formal
replace empleo_f=1 if sector_f==1 & (p507==3 | p507==4) & dscto==1			//Trabajadores dependientes del sector formal con pago de seguro de salud son empleo formal
replace empleo_f=1 if sector_f==3 & (p507==6) & dscto==1					//Trabajador del hogar con pago de seguro es empleo formal
cap nois replace empleo_f=ocupinf if empleo_f==. & inst!=.				//completamos la informacion faltante con la variable generada por inei de empleo formal/informal

label def empleo_f 0"Informal" 1"Formal"
label val empleo_f empleo_f
}


* MODULO SUMARIA
*========================

* Pobreza (no se recoge porque era medido con otra metodología hasta antes del 2003)


* NBI (desde 2000)
if `p' > 1999 { 
cap drop nbis
egen nbis = rowtotal(nbi1 nbi2 nbi3 nbi4 nbi5), m
order nbi*, last
}

* Gasto
if `p'==2003 { 
replace gashog1d = gashog1d/12
replace gashog2d = gashog2d/12

}

else{
cap nois replace gashog1d = gashog1d/3
cap nois replace gashog2d = gashog2d/3
}

cap nois gen gaspercap = gashog2d/totmieho // per capita mensual
cap nois order gashog1d gashog2d gaspercap, last

**Variables de interes
**=============================
cap nois order edad sexo, last
cap nois order latitud longitud, last
cap nois order ccpp, last
cap nois order codccpp, last
cap nois order altitud, last
cap nois order mieperho, last
cap nois order totmieho, last
cap nois order ubigeo conglome vivienda hogar codperso estrato dominio fac* period01
cap nois order ubigeo conglome vivienda hogar codperso estrato dominio fac* periodo
cap drop period01-ocu500
cap drop periodo-ocu500


gen aniorec =  `p'
cap tostring codperso, replace



save "$c/ENAHO/variables_$año", replace
}


*-------------------------------------------------------------------------------
* B) GENERACION VARIABLES MODULO PERCEPCION
*-------------------------------------------------------------------------------

* Base 2000
*===========
use "$bd/2000/enaho01b-2000", clear

* Lengua materna
cap drop lengua
recode q24 	(2=1 "Quechua") (3	 =2 "Aymara") (1=3 "Castellano") (5 6 7 = 4 "Extranjera") ///
				(8 = 5 "Sordo mudo/señas") (4=6 "Lengua indigena") (9=.), gen(lengua)


* Afectacion del problema
cap drop prob_afecta
recode q20 (1 2 3 = 1 "Afectado") (4= 0 "No afectado"), gen(prob_afecta)

* Recuperacion ante problemas	
cap drop resiliencia
recode q22 (1 3 = 1 "Superó adversidad") (2= 0 "No supera"), gen(resiliencia)

tempfile temp
save `temp', replace

use "$c/ENAHO/variables_2000"
merge m:1 conglome vivienda hogar using `temp', nogen keepus(lengua prob_afecta resiliencia)
save "$c/ENAHO/variables_2000", replace

* Base 2001
*===========
use "$bd/2001/enaho01b-2001", clear

* Lengua materna
cap drop lengua
recode q21 	(2=1 "Quechua") (3	 =2 "Aymara") (1=3 "Castellano") (5 6 7 = 4 "Extranjera") ///
				(8 = 5 "Sordo mudo/señas") (4=6 "Lengua indigena") (9=.), gen(lengua)


* Nivel vida con ingresos actuales
cap drop sit_ing
recode q1 (3 = 0 "Mal") (1 2 = 1 "Bien"), gen(sit_ing)

* Situacion economica actual
cap drop sit_hogar
recode q3 (1=1 "Logra ahorrar") (2=2 "Equilibra recursos") (3 4 = 3 "Gasta ahorros o se endeuda"), gen(sit_hogar)

* Nivel vida hogar
cap drop nivida_hog
cap nois gen nivida_hog = q41
label def nivida_hog 1"Mejoró" 2"Está igual" 3"Empeoró", modify
label val nivida_hog nivida_hog

* Nivel vida localidad
cap drop nivida_loc
cap nois gen nivida_loc = q42
label def nivida_loc 1"Mejoró" 2"Está igual" 3"Empeoró", modify
label val nivida_loc nivida_loc

* Afectacion del problema
cap drop prob_afecta
recode q6 (1 2 3 = 1 "Afectado") (4= 0 "No afectado"), gen(prob_afecta)

* Recuperacion ante problemas	
cap drop resiliencia
recode q8 (1 3 = 1 "Superó adversidad") (2= 0 "No supera"), gen(resiliencia)

tempfile temp
save `temp', replace

use "$c/ENAHO/variables_2001"
merge m:1 conglome vivienda hogar using `temp', nogen keepus(lengua-resiliencia)
save "$c/ENAHO/variables_2001", replace


* Base 2002
*===========
use "$bd/2002/enaho01b-2002-1", clear

* Situacion economica actual
cap drop sit_hogar
recode p30 (1=1 "Logra ahorrar") (2=2 "Equilibra recursos") (3 4 = 3 "Gasta ahorros o se endeuda"), gen(sit_hogar)

* Nivel vida hogar
cap drop nivida_hog
cap nois gen nivida_hog = p31_1
label def nivida_hog 1"Mejoró" 2"Está igual" 3"Empeoró", modify
label val nivida_hog nivida_hog

* Nivel vida localidad
cap drop nivida_loc
cap nois gen nivida_loc = p31_2
label def nivida_loc 1"Mejoró" 2"Está igual" 3"Empeoró", modify
label val nivida_loc nivida_loc

* Razon de mejora
cap drop razon_mejora
recode p32 (1 2 3 = 1 "Encontró empleo o mejora laboral") (4 = 2 "Inició negocio") ///
			(5 6 7 = 3 "Recibió recursos") , gen(razon_mejora)

* Nivel vida con ingresos actuales
cap drop sit_ing
recode p35 (3 4 = 0 "Mal") (1 2 = 1 "Bien"), gen(sit_ing)

* Afectacion del problema
cap drop prob_afecta
recode p39 (1 2 3 = 1 "Afectado") (4= 0 "No afectado"), gen(prob_afecta)

* Recuperacion ante problemas	
cap drop resiliencia
recode p41 (1 3 = 1 "Superó adversidad") (2= 0 "No supera"), gen(resiliencia)

tempfile temp
save `temp', replace

use "$c/ENAHO/variables_2002"
merge m:1 conglome vivienda hogar using `temp', nogen keepus(sit_hogar-resiliencia)
save "$c/ENAHO/variables_2002", replace

* Base 2003
*===========
use "$bd/2003/enaho01b-2003-1", clear

* Corrupcion
cap drop corrupcion
recode p23 (2 3 = 0 "No") (1 = 1 "Si") (9 = .), gen(corrupcion)

tempfile temp1
save `temp1', replace


use "$bd/2003/enaho01b-2003-3", clear

* Situacion economica actual
cap drop sit_hogar
recode p32 (1=1 "Logra ahorrar") (2=2 "Equilibra recursos") (3 4 = 3 "Gasta ahorros o se endeuda"), gen(sit_hogar)

* Nivel vida hogar
cap drop nivida_hog
cap nois gen nivida_hog = p33_2
label def nivida_hog 1"Mejoró" 2"Está igual" 3"Empeoró", modify
label val nivida_hog nivida_hog

* Nivel vida localidad
cap drop nivida_loc
cap nois gen nivida_loc = p33_1
label def nivida_loc 1"Mejoró" 2"Está igual" 3"Empeoró", modify
label val nivida_loc nivida_loc

* Razon de mejora
cap drop razon_mejora
recode p34 (1 2 3 = 1 "Encontró empleo o mejora laboral") (4 = 2 "Inició negocio") ///
			(5 8 = 3 "Recibió recursos") (6 7 = 4 "Aumento ingresos laborales"), gen(razon_mejora)

* Nivel vida con ingresos actuales
cap drop sit_ing
recode p37 (3 4 = 0 "Mal") (1 2 = 1 "Bien"), gen(sit_ing)

* Afectacion del problema
cap drop prob_afecta
recode p41 (1 2 3 = 1 "Afectado") (4= 0 "No afectado"), gen(prob_afecta)

* Recuperacion ante problemas	
cap drop resiliencia
recode p43 (1 3 = 1 "Superó adversidad") (2= 0 "No supera"), gen(resiliencia)

tempfile temp2
save `temp2', replace

use "$c/ENAHO/variables_2003"
merge m:1 conglome vivienda hogar using `temp1', nogen keepus(corrupcion)
merge m:1 conglome vivienda hogar using `temp2', nogen keepus(sit_hogar-resiliencia)
save "$c/ENAHO/variables_2003", replace
