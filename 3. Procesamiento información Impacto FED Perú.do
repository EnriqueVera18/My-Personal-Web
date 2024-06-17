
clear all
set more off
set excelxlsxlargefile on

**Definimos directorio (solo modificar global path)
**==================================================
global path "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\Evaluación de Impacto FED UE\Estimacion" 
global a "$path\\a_Do"
global b "$path\\b_BD"
global c "$path\\c_Temp"
global d "$path\\d_Tabla"
global midis "$path\\Información MIDIS"
global bd "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\BBDD"
global m "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\MAPAS"

********************************************************************************
****			CONVERSIÓN DE BASES DE DATOS PERIODO 2014-2016				****
********************************************************************************

global periodos 2014_2016
global fases FASE1 FASE2 FASE3
input str42 (niveles)
"NIVEL 0" 
"NIVEL 1" 
"NIVEL 2" 
"NIVEL 3"
end
global subniveles VERIFICACION SUBSANACION 

************************************
****	INDICADORES DE SALUD	****
************************************

*** Se borra cualquier data en carpetas de trabajo 
*** -----------------------------------------------
forval cg=1/67{
local ff: dir "$midis//2014_2016//CG`cg'" files "*.dta"
	foreach file of local ff {	
	cap	erase "$midis//2014_2016//CG`cg'//`file'"
	}
}



*** Primera estructura de BBDD sobre Indicadores de Salud
*** ------------------------------------------------------
levelsof niveles, local(niveles)
foreach cg in 1 2 6 7 9 12 19 20 21 28 29 31 {
local r=10

foreach fase of global fases {

foreach nivel of local niveles {

	if `"`nivel'"' == `"NIVEL 0"' { //PARA NIVEL 0

	confirmdir "$midis//2014_2016//CG`cg'//`fase'//`nivel'//BASES DE DATOS"
	
		if `r(confirmdir)'==0 { //En caso exista el directorio

		*** Importamos la base
		*** -------------------
		cd "$midis//2014_2016//CG`cg'//`fase'//`nivel'//BASES DE DATOS"
		local f: dir "$cd" files "*.xlsx"
		clear

		foreach file of local f {
		import excel using `"`file'"', clear firstrow allstring
		drop in 1/6

		*** Se corrige nombres de variables
		*** --------------------------------
		foreach x of varlist _all{
		replace `x'=subinstr(`x',"#","",.) in 1
		replace `x'=subinstr(`x',"<","",.) in 1
		replace `x'=subinstr(`x',">","",.) in 1
		replace `x'=subinstr(`x',"(","",.) in 1
		replace `x'=subinstr(`x',")","",.) in 1
		replace `x'=subinstr(`x',"disponibilidad","disp",.) in 1
		replace `x'=subinstr(`x',"identificación","identifica",.) in 1
		replace `x'=subinstr(`x',"%","Porc",.) in 1
		replace `x'=subinstr(`x',"Porcentaje","Porc",.) in 1
		replace `x'=subinstr(`x',"TRANSPORTE","TRANSP",.) in 1
		replace `x'=subinstr(`x',"COMPROMISO_ANUAL","COMP_ANUAL",.) in 1
		replace `x'=subinstr(`x',"pero","",.) in 1
		replace `x'=subinstr(`x',"Consumo","Cons",.) in 1
		replace `x'=strtrim(`x') in 1
		replace `x'=stritrim(`x') in 1
		replace `x'=ustrtoname(`x') in 1
		replace `x'="" if `x'=="n/d"
		}

		replace Rep="gore" in 1
		replace B="red_salud" in 1
		replace C="eess" in 1
		replace D="quintil" in 1 if real(D[_n+1])==.

		renvars , map(`=word("@", 1)')
		drop in 1


		*** Se completa la base
		*** ---------------------

		**GOREs
		count
		forval x=2/`r(N)' { 
		replace gore=gore[_n-1] if gore=="" in `x'
		}

		**Red de salud
		count
		forval x=2/`r(N)' { 
		replace red_salud=red_salud[_n-1] if red_salud=="" & !strpos(gore,"99") in `x'
		}
		replace red_salud="TOTAL" if strpos(gore,"99")

		**Borramos los subtotales
		drop if red_salud==eess | eess==""

		**Generamos codigo de eess
		gen cod_eess=substr(eess,1,7)
		tostring cod_eess, replace
		cap drop eess
		
		*** Guardamos la base
		*** ---------------------
		dis `"`file'"'
		dis `"2014_2016//CG`cg'//`fase'//`nivel'"'
		gen  ruta`r'= `"2014_2016//CG`cg'//`fase'//`nivel'"' in 1
		save "$midis//2014_2016//CG`cg'//file`r'.dta",replace
		local r= `r' + 1
		
		}

	}
	}


	else { //Para los NIVELES 1 2 3

	foreach subnivel of global subniveles {

	confirmdir "$midis//2014_2016//CG`cg'//`fase'//`nivel'//`subnivel'//BASES DE DATOS"


		if `r(confirmdir)'==0 { //En caso exista el directorio

		*** Importamos la base
		*** -------------------
		cd "$midis//2014_2016//CG`cg'//`fase'//`nivel'//`subnivel'//BASES DE DATOS"
		local f: dir "$cd" files "*.xlsx"
		clear

		foreach file of local f {
		import excel using `"`file'"', clear firstrow allstring
		drop in 1/6

		*** Se corrige nombres de variables
		*** --------------------------------
		foreach x of varlist _all{
		replace `x'=subinstr(`x',"#","",.) in 1
		replace `x'=subinstr(`x',"<","",.) in 1
		replace `x'=subinstr(`x',">","",.) in 1
		replace `x'=subinstr(`x',"(","",.) in 1
		replace `x'=subinstr(`x',")","",.) in 1
		replace `x'=subinstr(`x',"__","_",.) in 1
		replace `x'=subinstr(`x',"disponibilidad","disp",.) in 1
		replace `x'=subinstr(`x',"identificación","identifica",.) in 1
		replace `x'=subinstr(`x',"TRANSPORTE","TRANSP",.) in 1
		replace `x'=subinstr(`x',"COMPROMISO_ANUAL","COMP_ANUAL",.) in 1
		replace `x'=subinstr(`x',"%","Porc",.) in 1
		replace `x'=subinstr(`x',"Porcentaje","Porc",.) in 1
		replace `x'=subinstr(`x',"pero","",.) in 1
		replace `x'=subinstr(`x',"Consumo","Cons",.) in 1
		replace `x'=strtrim(`x') in 1
		replace `x'=stritrim(`x') in 1
		replace `x'=ustrtoname(`x') in 1
		replace `x'="" if `x'=="n/d"
		}

		replace Rep="gore" in 1
		replace B="red_salud" in 1
		replace C="eess" in 1
		replace D="quintil" in 1 if real(D[_n+1])==. & D[_n]==""

		renvars , map(`=word("@", 1)')
		drop in 1


		*** Se completa la base
		*** ---------------------

		**GOREs
		count
		forval x=2/`r(N)' { 
		replace gore=gore[_n-1] if gore=="" in `x'
		}

		**Red de salud
		count
		forval x=2/`r(N)' { 
		replace red_salud=red_salud[_n-1] if red_salud=="" & !strpos(gore,"99") in `x'
		}
		replace red_salud="TOTAL" if strpos(gore,"99")

		**Borramos los subtotales
		if `cg'==9 | `cg'==29 | `cg'==31 {
		count
		forval x=2/`r(N)' { 
		replace eess=eess[_n-1] if eess=="" in `x'
		}
		drop if red_salud==eess 

		}
		
		else{
		drop if red_salud==eess | eess==""
		}

		**Generamos codigo de eess
		gen cod_eess=substr(eess,1,7)
		tostring cod_eess, replace
		*cap drop eess

		*** Guardamos la base
		*** ---------------------
		dis `"`file'"'
		dis `"2014_2016//CG`cg'//`fase'//`nivel'//`subnivel'"'
		gen  ruta`r'= `"2014_2016//CG`cg'//`fase'//`nivel'//`subnivel'"' in 1
		save "$midis//2014_2016//CG`cg'//file`r'.dta",replace
		local r= `r' + 1
		
		}
		}
	}
	}

}
}
}

*** Unificamos las BBDD por cada indicador CG
*** ------------------------------------------------------

**Indicador CG1
local tempos "201406 201411 201504"
forval cg=1/1{
cap	erase "$midis//2014_2016//CG`cg'\BBDD_CG`cg'"
local ff: dir "$midis//2014_2016//CG`cg'" files "*.dta"
clear
local q=1
local r=1
local t=1
	foreach file of local ff {	
	use "$midis//2014_2016//CG`cg'//`file'",clear
	rename _all, low
	cap drop _00_total
	cap drop _*_porc_*
	cap rename _01*disp_* disp_mmn_201404
	cap rename _02*disp_* disp_mmn_201405
	cap rename _03*disp_* disp_mmn_201406
	cap rename _04*disp_* disp_mmn_201407
	cap rename _05*disp_* disp_mmn_201408
	cap rename _06*disp_* disp_mmn_201409
	cap rename _07*disp_* disp_mmn_201410
	cap rename _08*disp_* disp_mmn_201411
	cap rename _09*disp_* disp_mmn_201412
	cap rename _10*disp_* disp_mmn_201501
	cap rename _11*disp_* disp_mmn_201502
	cap rename _12*disp_* disp_mmn_201503
	cap rename _13*disp_* disp_mmn_201504
	cap rename _14*disp_* disp_mmn_201505
	cap rename _09a_*stock_* sin_cons_mmn_201404
	cap rename _09b_*stock_* sin_cons_mmn_201405
	cap rename _09c_*stock_* sin_cons_mmn_201406
	cap rename _09d_*stock_* sin_cons_mmn_201407
	cap rename _09e_*stock_* sin_cons_mmn_201408
	cap rename _09f_*stock_* sin_cons_mmn_201409
	cap rename _09g_*stock_* sin_cons_mmn_201410
	cap rename _09h_*stock_* sin_cons_mmn_201411
	cap rename _09i_*stock_* sin_cons_mmn_201412
	cap rename _09j_*stock_* sin_cons_mmn_201501
	cap rename _09k_*stock_* sin_cons_mmn_201502
	cap rename _09l_*stock_* sin_cons_mmn_201503
	if `r'==1 | `r'==3 | `r'==5 {
	local tempo=word("`tempos'" , `t')
	cap rename _99_*increm* increm_cons_mmn_`tempo'
	cap rename _99_*bajaron_* bajaron_cons_mmn_`tempo'
	local t = `t'+1
	}
	local r = `r'+1
	cap drop ruta
	cap drop gore
	cap drop red_salud
	cap drop quintil
	duplicates drop cod_eess, force
	save "$midis//2014_2016//CG`cg'//`file'", replace
	}

	foreach file of local ff {
	
	if `q' ==1 {
	use "$midis//2014_2016//CG`cg'//`file'",clear
	}
	
	else {
	merge 1:1 cod_eess using "$midis//2014_2016//CG`cg'//`file'", nogen update
	}
	local q= `q' +1
	
	erase "$midis//2014_2016//CG`cg'//`file'"
	}
	order cod_eess disp_* sin_cons_* 
	reshape long disp_mmn_ sin_cons_mmn_ increm_cons_mmn_ bajaron_cons_mmn_, i(cod_eess) j(periodo)
	destring disp_mmn_ sin_cons_mmn_ increm_cons_mmn_ bajaron_cons_mmn_, replace
	label var disp_mmn_ "Disponibilidad de multimicronutrientes para 2 meses"
	label var sin_cons_mmn_ "Cuenta con stock de multimicronutrientes, pero sin consumo"
	label var increm_cons_mmn_ "Incrementaron consumo de multimicronutrientes"
	label var bajaron_cons_mmn_ "Bajaron consumo de multimicronutrientes"
	
	foreach x of varlist disp_mmn_ sin_cons_mmn_ increm_cons_mmn_ bajaron_cons_mmn_ {
	rename `x' cg1_`x'
	}
	forval q=1/8{
	replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
	}

	save "$midis//2014_2016//CG`cg'//BBDD_CG`cg'", replace
}


**Indicador CG2 - AGREGADO
local tempos "201408 201408 201411 201411 201507 201507 201503 201503 201507 201507 201510 201510"
forval cg=2/2{
local ff: dir "$midis//2014_2016//CG`cg'" files "*.dta"
clear
local q=1
local r=1
	foreach file of local ff {
	local tempo=word("`tempos'" , `r')
	use "$midis//2014_2016//CG`cg'//`file'",clear
	rename _all, low
	cap drop gore
	cap drop red_salud
	cap drop eess
	cap drop no
	cap drop ruta
	cap drop cumple_*
	cap drop registro
	cap rename si prog_ppto75_`tempo'
	local r = `r'+1
	duplicates drop cod_eess, force
	save "$midis//2014_2016//CG`cg'//`file'", replace
	}
	foreach file of local ff {	
	if `q' ==1 {
	use "$midis//2014_2016//CG`cg'//`file'",clear
	}
	
	else {
	merge 1:1 cod_eess using "$midis//2014_2016//CG`cg'//`file'", nogen 
	}
	local q= `q' +1
	
	erase "$midis//2014_2016//CG`cg'//`file'"
	}
	reshape long prog_ppto75_ , i(cod_eess) j(periodo)
	order cod_eess periodo prog_ppto75_*
	label var prog_ppto75_ "Programación presupuestal de equipos al 75%"
	rename prog_ppto75_ cg2_prog_ppto75_
	destring cg2_*, replace
	forval q=1/8{
	replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
	}
	
	save "$midis//2014_2016//CG`cg'//BBDD_CG`cg'", replace
}

**Indicador CG2 - DESAGREGADO GESTANTES Y NIÑOS
global parcial "$midis//2014_2016//CG2//Data Cubos//"
local f: dir "$parcial" files "*.xlsx"
clear
local t = 1
foreach file of local f {
import excel using "$parcial//`file'", clear allstring
dis `"`file'"'
drop in 1/7
cap drop A
cap drop PPlay
cap drop B
replace C="eess" in 1
foreach x of varlist D-V{
replace `x'=strtoname(`x') in 1
}
renvars , map(`=word("@", 1)')
drop in 1
drop CUMPL
drop if eess==""
destring _all, replace

**Generamos Ind Cumplimiento de Equipos Infantes y Gestantes
egen cg2_infante=rsum(_1_REFRIGERACION - _6_MESA_EXAM_PEDIATR)
egen cg2_gestante=rsum(_1_LAMPARA_ELECTRICA - _9_CENTRIFUGA)
replace cg2_infante=cg2_infante/10
replace cg2_gestante=cg2_gestante/9
keep eess cg2_infante cg2_gestante
gen periodo=substr(`"`file'"', 10,7)
tempfile temp`t'
save `temp`t'', replace
local t = `t'+1
}

use `temp1', clear

forval t=2/5 {
append using `temp`t''
}
replace periodo=substr(periodo,4,4)+substr(periodo,1,2)
gen cod_eess=substr(eess,1,7)
drop if real(cod_eess)==.
keep cod_eess periodo cg2*
order cod_eess periodo cg2*
destring periodo, replace
duplicates drop cod_eess periodo, force
replace cod_eess="0"+cod_eess
save "$midis//2014_2016//CG2//BBDD_CG2desg", replace

**Indicador CG5
qui{
import excel using "$midis//2014_2016//CG5//FASE1//NIVEL 1//VERIFICACION//SO4_CONCILIACION_EESS_REGIONES REV.xlsx", clear firstrow sheet("CONTRASTES_FINAL")
rename _all, low
cap rename códigoÚ cod_eess
duplicates drop cod_eess, force
keep cod_eess renaes-siga
forval q=1/8{
replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
}

foreach p in renaes sismed siga{
cap rename `p' cg5_`p'_201308
cap rename `p'_ cg5_`p'_201308
}
cap rename sis2013 cg5_sis_201308
cap rename his2013 cg5_his_201308
tempfile file1
save `file1', replace

import excel using "$midis//2014_2016//CG5//FASE1//NIVEL 1//SUBSANACION//SO4_Conciliacion_EESS_NOV.xlsx", clear firstrow sheet("CONTRASTES_FINAL")
rename _all, low
cap rename códigoÚ cod_eess
duplicates drop cod_eess, force
keep cod_eess renaes-siga
forval q=1/8{
replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
}

foreach p in renaes sis his sismed siga{
cap rename `p' cg5_`p'_201311
cap rename `p'_ cg5_`p'_201311
}
tempfile file2
save `file2', replace

import excel using "$midis//2014_2016//CG5//FASE1//NIVEL 2//VERIFICACION//Conciliación EESS - SIN LABORATORIOS NI MOVILES - VERIFICADO.xlsx", clear firstrow sheet("CONTRASTES_FINAL")
rename _all, low
cap rename llave cod_eess
duplicates drop cod_eess, force
keep cod_eess renaes-siga
forval q=1/8{
replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
}

foreach p in renaes sis his siga{
cap rename `p' cg5_`p'_201508
cap rename `p'_ cg5_`p'_201508
}
cap rename tablasismed cg5_sismed_201508
tempfile file3
save `file3', replace

import excel using "$midis//2014_2016//CG5//FASE2//NIVEL 2//VERIFICACION//conciliacion EESS - FASE abril 2016 (3).xlsx", clear firstrow sheet("CONTRASTE FINAL")
rename _all, low
cap rename llave cod_eess
duplicates drop cod_eess, force
keep cod_eess renaes-siga
forval q=1/8{
replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
}

foreach p in renaes sis his sismed siga{
cap rename `p' cg5_`p'_201604
cap rename `p'_ cg5_`p'_201604
}
tempfile file4
save `file4', replace

import excel using "$midis//2014_2016//CG5//FASE2//NIVEL 2//SUBSANACION//Rreporte conciliación EESS a Julio 2016.xlsx", clear firstrow sheet("CONTRASTE FINAL")
rename _all, low
cap rename llave cod_eess
duplicates drop cod_eess, force
keep cod_eess renaes-siga
forval q=1/8{
replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
}

foreach p in renaes sis his sismed siga{
cap rename `p' cg5_`p'_201607
cap rename `p'_ cg5_`p'_201607
}
destring cg5_siga_, replace
tempfile file5
save `file5', replace

import excel using "$midis//2014_2016//CG5//FASE2//NIVEL 3//VERIFICACION//conciliacion EESS - FASE Mayo 2017.xlsx", clear firstrow sheet("CONTRASTE FINAL")
rename _all, low
cap rename llave cod_eess
duplicates drop cod_eess, force
keep cod_eess renaes-siga
forval q=1/8{
replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
}

foreach p in renaes sis his sismed siga{
cap rename `p' cg5_`p'_201705
cap rename `p'_ cg5_`p'_201505
}
tempfile file6
save `file6', replace

import excel using "$midis//2014_2016//CG5//FASE2//NIVEL 3//SUBSANACION//Conciliacion EESS - FASE Junio 2017.xlsx", clear firstrow sheet("CONTRASTE FINAL")
rename _all, low
cap rename llave cod_eess
duplicates drop cod_eess, force
keep cod_eess renaes-siga
tostring cod_eess, replace

forval q=1/8{
replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
}
duplicates drop cod_eess, force

foreach p in renaes sis his sismed siga{
cap rename `p' cg5_`p'_201706
cap rename `p'_ cg5_`p'_201706
}
tempfile file7
save `file7', replace

import excel using "$midis//2014_2016//CG5//FASE3//NIVEL 2//VERIFICACION//Conciliación EESS - FASE Junio 2016v1.xlsx", clear firstrow sheet("CONTRASTE FINAL")
rename _all, low
cap rename llave cod_eess
duplicates drop cod_eess, force
keep cod_eess renaes-siga
forval q=1/8{
replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
}

foreach p in renaes sis his sismed siga{
cap rename `p' cg5_`p'_201606
cap rename `p'_ cg5_`p'_201606
}
tempfile file8
save `file8', replace

import excel using "$midis//2014_2016//CG5//FASE3//NIVEL 2//SUBSANACION//conciliacion EESS - Sub FASE 1 y 3 set 2016_verif04_04Oct2016.xlsx", clear firstrow sheet("CONTRASTE FINAL")
rename _all, low
cap rename llave cod_eess
duplicates drop cod_eess, force
keep cod_eess renaes-siga
forval q=1/8{
replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
}

foreach p in renaes sis his sismed siga{
cap rename `p' cg5_`p'_201610
cap rename `p'_ cg5_`p'_201610
}
tempfile file9
save `file9', replace

use `file1', clear

forval w=2/9{
merge 1:1 cod_eess using `file`w'', nogen force
}
reshape long cg5_renaes_ cg5_sis_ cg5_his_ cg5_sismed_ cg5_siga_ , i(cod_eess) j(periodo)
gen cg5_cumple=(cg5_renaes_==1 & cg5_sis_==1 & cg5_his_==1 & cg5_sismed_==1 & cg5_siga_==1)
cap drop miss
egen miss=rowmiss(cg5_renaes_ - cg5_siga_)
replace cg5_cumple=. if miss==5
cap drop miss
save "$midis//2014_2016//CG5//BBDD_CG5", replace
}


**Indicador CG6
local tempos "201411 201411 201507 201510 201503 201506 201507 201510"
forval cg=6/6{
local ff: dir "$midis//2014_2016//CG`cg'" files "*.dta"
clear
local q=1
local r=1	
	foreach file of local ff {	
	local tempo=word("`tempos'" , `r')
	use "$midis//2014_2016//CG`cg'//`file'",clear
	cap drop EESS
	rename _all, low
	keep cod_eess porc*
	cap rename porc* cg6_cumple_`tempo'
	duplicates drop cod_eess, force
	local r = `r'+1
	save "$midis//2014_2016//CG`cg'//`file'", replace
	}
	
	foreach file of local ff {	
	if `q' ==1 {
	use "$midis//2014_2016//CG`cg'//`file'",clear
	}
	
	else {
	merge 1:1 cod_eess using "$midis//2014_2016//CG`cg'//`file'", nogen 
	}
	local q= `q' +1
	
	erase "$midis//2014_2016//CG`cg'//`file'"
	}
	order cod_eess cg6_cumple_* 
	reshape long cg6_cumple_, i(cod_eess) j(periodo)
	destring cg6_cumple_, replace
	forval q=1/8{
	replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
	}

	save "$midis//2014_2016//CG`cg'//BBDD_CG`cg'", replace
}


**Indicador CG7
local tempos "201410 201510"
forval cg=7/7{
local ff: dir "$midis//2014_2016//CG`cg'" files "*.dta"
clear
local q=1
local r=1	
	foreach file of local ff {	
	local tempo=word("`tempos'" , `r')
	use "$midis//2014_2016//CG`cg'//`file'",clear
	rename _all, low
	keep cod_eess nro_ninno
	cap rename nro_ninno cg7_nro_niño_`tempo'
	destring cg7_nro_niño_`tempo', replace
	duplicates drop cod_eess, force
	local r = `r'+1
	save "$midis//2014_2016//CG`cg'//`file'", replace
	}
	foreach file of local ff {	
	if `q' ==1 {
	use "$midis//2014_2016//CG`cg'//`file'",clear
	}
	
	else {
	merge 1:1 cod_eess using "$midis//2014_2016//CG`cg'//`file'", nogen 
	}
	local q= `q' +1
	
	erase "$midis//2014_2016//CG`cg'//`file'"
	}
	order cod_eess cg7_*
	reshape long cg7_nro_niño_ , i(cod_eess) j(periodo)
	forval q=1/8{
	replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
	}

	label var cg7_nro_niño_ "Cantidad de niños(as) inscritas en el CNVe"
	save "$midis//2014_2016//CG`cg'//BBDD_CG`cg'", replace
}


**Indicador CG9
local tempos "201507 201507 201510 201510"
forval cg=9/9{
local ff: dir "$midis//2014_2016//CG`cg'" files "*.dta"
clear
local q=1
local r=1
	foreach file of local ff {	
	local tempo=word("`tempos'" , `r') 
	use "$midis//2014_2016//CG`cg'//`file'",clear
	rename _all, low
	cap drop gore red_salud eess
	cap drop ruta
	cap drop _0 _1
	cap drop _5a
	cap drop niÑos_padron* cc_ccpp* porc_niños_con_identifica_ccpp
	rename cod_eess ubigeo
	cap rename porc_niños_con_identifica_ccpp cg9_cumple_5a_`tempo'
	cap rename porc0__1 cg9_cumple_12m_`tempo'
	duplicates drop ubigeo, force

	local r = `r'+1
	save "$midis//2014_2016//CG`cg'//`file'", replace
	}
	foreach file of local ff {	
	if `q' ==1 {
	use "$midis//2014_2016//CG`cg'//`file'",clear
	}
	
	else {
	merge 1:1 ubigeo using "$midis//2014_2016//CG`cg'//`file'", nogen 
	}
	local q= `q' +1
	
	erase "$midis//2014_2016//CG`cg'//`file'"
	}
	order ubigeo cg9_cumple*
	replace cg9_cumple_5a_201510=subinstr(cg9_cumple_5a_201510,"/","",.)
	replace cg9_cumple_12m_201510=subinstr(cg9_cumple_12m_201510,"/","",.)
	destring cg9_cumple_*,replace
	drop if real(ubigeo)==.
	replace ubigeo=ustrtrim(ubigeo)
	reshape long cg9_cumple_5a_ cg9_cumple_12m_, i(ubigeo) j(periodo)
	label var cg9_cumple_5a "% Niños menores a 5 años registrados en padrón nominal"
	label var cg9_cumple_12m "Ratio entre niños menores a 12m registrados y niños 1 año registrados en padrón nominal"

	save "$midis//2014_2016//CG`cg'//BBDD_CG`cg'", replace
}


**Indicador CG10
qui{
import excel using "$midis//2014_2016//CG10//FASE1//NIVEL 2//SUBSANACION//REPORTE//SII-08_cnv_ora_dni5dias_06nov15 (2).xlsx", clear firstrow sheet("datos_eess")
rename _all, low
destring mes, replace
cap rename (mes totaldecnveemitifdosporeess totaldednitramitado totaldecnveconactadenacy totaldednihastalos5díasde dnihastalos5díasdelrecie) (periodo cg10_tot_cnv_ cg10_tot_dni_tramitado_ cg10_tot_cnv_acta_y_dni_ cg10_tot_dni_hasta5d_ cg10_cumple_)
duplicates drop cod_eess periodo, force
keep cod_eess periodo cg10_tot_cnv_ - cg10_cumple_
replace cod_eess="0"+cod_eess if strlen(cod_eess)==6
replace cod_eess=substr(cod_eess,2,7) if strlen(cod_eess)==8
label var cg10_cumple_ "% DNI Hasta los 5 días del Recien Nacido"
forval q=1/8{
replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
}
save "$midis//2014_2016//CG10//BBDD_CG10", replace
}

**Indicador CG11
qui{
import excel using "$midis//2014_2016//CG11//FASE1//NIVEL 1//VERIFICACION//REPORTE//SO8_DISPONBILIDAD_RRHH_ HIS.xlsx", clear firstrow sheet("reporte_válido_HIS_S081")
rename _all, low
keep codigoeess cumple_disp_niño_3m_a- cumple_disp_gest_3m_b
rename codigoeess cod_eess
replace cod_eess="0"+cod_eess if strlen(cod_eess)==6
replace cod_eess=substr(cod_eess,2,7) if strlen(cod_eess)==8
rename (cumple_disp_niño_3m_a cumple_disp_niño_3m_b cumple_disp_gest_3m_a cumple_disp_gest_3m_b) (cg11_infante_201407 cg11_infante_201408 cg11_gestante_201407 cg11_gestante_201408)
duplicates drop cod_eess, force
tempfile cg11_file1
save `cg11_file1', replace

import excel using "$midis//2014_2016//CG11//FASE1//NIVEL 1//SUBSANACION//REPORTE//SO1_SO3_SO5_SO8_SUBSANAC_NOV.xlsx", clear firstrow sheet("SO8_DISP_PERSONAL_DETALLE")
rename _all, low
keep codigoeess cumple_disp_niño_3m_a- cumple_disp_gest_3m_b
rename codigoeess cod_eess
replace cod_eess="0"+cod_eess if strlen(cod_eess)==6
replace cod_eess=substr(cod_eess,2,7) if strlen(cod_eess)==8
rename (cumple_disp_niño_3m_a cumple_disp_niño_3m_b cumple_disp_gest_3m_a cumple_disp_gest_3m_b) (cg11_infante_201409 cg11_infante_201410 cg11_gestante_201409 cg11_gestante_201410)
duplicates drop cod_eess, force
tempfile cg11_file2
save `cg11_file2', replace

import excel using "$midis//2014_2016//CG11//FASE1//NIVEL 2//VERIFICACION//REPORTE//REPORTE MODEL_8 sally recarg.xlsx", clear firstrow sheet("REPORTE_MODEL_21")
keep CODRENAES cumple_disp_niño_3m_a- cumple_disp_gest_3m_b
rename _all, low
rename codrenaes cod_eess
replace cod_eess="0"+cod_eess if strlen(cod_eess)==6
replace cod_eess=substr(cod_eess,2,7) if strlen(cod_eess)==8
rename (cumple_disp_niño_3m_a cumple_disp_niño_3m_b cumple_disp_gest_3m_a cumple_disp_gest_3m_b) (cg11_infante_201506 cg11_infante_201507 cg11_gestante_201506 cg11_gestante_201507)
duplicates drop cod_eess, force
tempfile cg11_file3
save `cg11_file3', replace

import excel using "$midis//2014_2016//CG11//FASE1//NIVEL 2//SUBSANACION//SII-09 fed subsanacion fase i y iii nov 2015 (1).xlsx", clear firstrow sheet(" base 1")
keep cod_eess cumple_disp_niño_3m_a- cumple_disp_gest_3m_b
rename _all, low
rename (cumple_disp_niño_3m_a cumple_disp_niño_3m_b cumple_disp_gest_3m_a cumple_disp_gest_3m_b) (cg11_infante_201509 cg11_infante_201510 cg11_gestante_201509 cg11_gestante_201510)
duplicates drop cod_eess, force
tempfile cg11_file4
save `cg11_file4', replace

import excel using "$midis//2014_2016//CG11//FASE2//NIVEL 1//VERIFICACION//REPORTE//Reporte actualizado HIS ABRIL 2015 fase II.xlsx", clear firstrow sheet("Reporte_actualizado_HIS_ABR1")
rename _all, low
rename codigoeess cod_eess
keep cod_eess cumple_disp_niño_3m_a- cumple_disp_gest_3m_b
rename (cumple_disp_niño_3m_a cumple_disp_niño_3m_b cumple_disp_gest_3m_a cumple_disp_gest_3m_b) (cg11_infante_201502 cg11_infante_201503 cg11_gestante_201502 cg11_gestante_201503)
duplicates drop cod_eess, force
tempfile cg11_file5
save `cg11_file5', replace

import excel using "$midis//2014_2016//CG11//FASE2//NIVEL 1//SUBSANACION//REPORTE//Reporte final S08 Subsana Fase II Nivel 1 06082915.xlsx", clear firstrow sheet("base")
rename _all, low
rename codrenaes cod_eess
keep cod_eess cumple_disp_niño_3m_a- cumple_disp_gest_3m_b
rename (cumple_disp_niño_3m_a cumple_disp_niño_3m_b cumple_disp_gest_3m_a cumple_disp_gest_3m_b) (cg11_infante_201505 cg11_infante_201506 cg11_gestante_201505 cg11_gestante_201506)
duplicates drop cod_eess, force
tempfile cg11_file6
save `cg11_file6', replace

import excel using "$midis//2014_2016//CG11//FASE3//NIVEL 1//VERIFICACION//REPORTE//REPORTE MODEL_8 sally recarg.xlsx", clear firstrow sheet("REPORTE_MODEL_21") cellrange(A9:BN2910)
keep CODRENAES cumple_disp_niño_3m_a- cumple_disp_gest_3m_b
rename _all, low
rename codrenaes cod_eess
rename (cumple_disp_niño_3m_a cumple_disp_niño_3m_b cumple_disp_gest_3m_a cumple_disp_gest_3m_b) (cg11_infante_201506 cg11_infante_201507 cg11_gestante_201506 cg11_gestante_201507)
duplicates drop cod_eess, force
tempfile cg11_file7
save `cg11_file7', replace

import excel using "$midis//2014_2016//CG11//FASE3//NIVEL 1//SUBSANACION//SII-09 fed subsanacion fase i y iii nov 2015 (1).xlsx", clear firstrow sheet(" base 1")
keep D cumple_disp_niño_3m_a- cumple_disp_gest_3m_b
rename _all, low
rename d cod_eess
rename (cumple_disp_niño_3m_a cumple_disp_niño_3m_b cumple_disp_gest_3m_a cumple_disp_gest_3m_b) (cg11_infante_201509 cg11_infante_201510 cg11_gestante_201509 cg11_gestante_201510)
duplicates drop cod_eess, force
tempfile cg11_file8
save `cg11_file8', replace

use `cg11_file1', clear
forval y=2/8{
merge 1:1 cod_eess using `cg11_file`y'', nogen 
}
drop if cod_eess==""
reshape long cg11_infante_ cg11_gestante_ , i(cod_eess) j(periodo) 
forval q=1/8{
replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
}

save "$midis//2014_2016//CG11//BBDD_CG11", replace
}


**Indicador CG12
local tempos "201509 201502 201505 201509"
forval cg=12/12{
local ff: dir "$midis//2014_2016//CG`cg'" files "*.dta"
clear
local q=1
local r=1
local t=1
	foreach file of local ff {	
	use "$midis//2014_2016//CG`cg'//`file'",clear
	rename _all, low
	cap drop _00_tot*
	cap drop _*_porc_*
	cap drop c20*
	cap drop _*6m*
	cap drop _*meses_c*
	cap drop _*promedio*
	cap drop _*stock*
	cap drop _*distribucion*
	cap drop _07*disponibilidad*
	cap drop _08b_cumple_2m_15_jul
	cap rename _09*disp* cg12_disp_mmn_201412
	cap rename _10*disp* cg12_disp_mmn_201501
	cap rename _11*disp* cg12_disp_mmn_201502
	cap rename _12*disp* cg12_disp_mmn_201503
	cap rename _13*disp* cg12_disp_mmn_201504
	cap rename _14*disp* cg12_disp_mmn_201505
	cap rename _15*disp* cg12_disp_mmn_201506
	cap rename _16*disp* cg12_disp_mmn_201507
	cap rename _17*disp* cg12_disp_mmn_201508
	cap rename _18*disp* cg12_disp_mmn_201509
	cap rename _19*disp* cg12_disp_mmn_201510
	cap rename _20*disp* cg12_disp_mmn_201511
	cap rename _09f_*stock_* cg12_sin_cons_mmn_201409
	cap rename _09g_*stock_* cg12_sin_cons_mmn_201410
	cap rename _09h_*stock_* cg12_sin_cons_mmn_201411
	cap rename _09i_*stock_* cg12_sin_cons_mmn_201412
	cap rename _09j_*stock_* cg12_sin_cons_mmn_201501
	cap rename _09k_*stock_* cg12_sin_cons_mmn_201502
	cap rename _09l_*stock_* cg12_sin_cons_mmn_201503
	cap rename _09m_*stock_* cg12_sin_cons_mmn_201504
	cap rename _09n_*stock_* cg12_sin_cons_mmn_201505
	cap rename _09o_*stock_* cg12_sin_cons_mmn_201506
	cap rename _09p_*stock_* cg12_sin_cons_mmn_201507
	cap rename _09q_*stock_* cg12_sin_cons_mmn_201508
	cap rename _09r_*stock_* cg12_sin_cons_mmn_201509
	cap rename _08q_*cumple* cg12_cumple_201501
	cap rename _08s_*cumple* cg12_cumple_201502
	cap rename _08u_*cumple* cg12_cumple_201503
	cap rename _08w_*cumple* cg12_cumple_201504
	cap rename _08y_*cumple* cg12_cumple_201505
	cap rename _08a_*cumple* cg12_cumple_201506
	cap rename _08c_*cumple* cg12_cumple_201507
	if `r'==2 | `r'==4 | `r'==6 | `r'==9 {
	local tempo=word("`tempos'" , `t')
	cap rename _99_*increm* cg12_increm_cons_mmn_`tempo'
	cap rename _99_*bajaron_* cg12_bajaron_cons_mmn_`tempo'
	local t = `t'+1
	}
	local r = `r'+1
	cap drop ruta*
	cap drop gore
	cap drop red_salud
	cap drop quintil
	cap drop eess
	duplicates drop cod_eess, force
	save "$midis//2014_2016//CG`cg'//`file'", replace
	}
	foreach file of local ff {	
	if `q' ==1 {
	use "$midis//2014_2016//CG`cg'//`file'",clear
	}
	
	else {
	merge 1:1 cod_eess using "$midis//2014_2016//CG`cg'//`file'", nogen 
	}
	local q= `q' +1
	
	erase "$midis//2014_2016//CG`cg'//`file'"
	}
	order cod_eess cg12_*
	foreach l of varlist cg12_* {
	destring `l', replace
	}
	reshape long cg12_disp_mmn_ cg12_sin_cons_mmn_ cg12_increm_cons_mmn_ cg12_bajaron_cons_mmn_ cg12_cumple_, i(cod_eess) j(periodo)
	forval q=1/8{
	replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
	}
	save "$midis//2014_2016//CG`cg'//BBDD_CG`cg'", replace
}


**Indicador CG13
qui{
import excel using "$midis//2014_2016//CG13//FASE1//NIVEL 2//VERIFICACION//S2-11_EESS.xlsx", clear firstrow sheet("DATOSxEESS")
rename _all, low
keep cod_renaes abr_15dias-junio
rename (abr_15 abr_5 may_15 may_5 jun_15 jun_5 abril mayo junio) (his_15d_201504 his_5d_201504 his_15d_201505 his_5d_201505 his_15d_201506 his_5d_201506 cumple_201504 cumple_201505 cumple_201506)
forval q=1/8{
replace cod_renaes="0"+cod_renaes if strlen(cod_renaes)<`q'
}
replace cod_renaes=substr(cod_renaes,2,8) if strlen(cod_renaes)==9
duplicates drop cod_renaes, force
tempfile cg13_file1
save `cg13_file1', replace

*tab departamento if fase_fed ==1 & eess_fed==1 // cantidad de EESS por departamento
*tab departamento if fase_fed ==1 & eess_fed==1 & his_15d_201504 !=. // cantidad de EESS con info HIS a 15dias por departamento
*tab departamento if fase_fed ==1 & eess_fed==1 & his_5d_201504 !=. // cantidad de EESS con info HIS a 5dias por departamento

import excel using "$midis//2014_2016//CG13//FASE1//NIVEL 2//SUBSANACION//SII-11_EESS 5 días y 15 días.xlsx", clear firstrow sheet("S2_11_EESS")
rename _all, low
keep cod_renaes jul_15d-setiembre
rename (jul_15 jul_5 ago_15 ago_5 set_15 set_5 julio agosto setiembre) (his_15d_201507 his_5d_201507 his_15d_201508 his_5d_201508 his_15d_201509 his_5d_201509 cumple_201507 cumple_201508 cumple_201509)
forval q=1/8{
replace cod_renaes="0"+cod_renaes if strlen(cod_renaes)<`q'
}
replace cod_renaes=substr(cod_renaes,2,8) if strlen(cod_renaes)==9
duplicates drop cod_renaes, force
tempfile cg13_file2
save `cg13_file2', replace

import excel using "$midis//2014_2016//CG13//FASE2//NIVEL 2//VERIFICACION//F2N2 1-V SII-12 S2_12_F2N2.xlsx", clear firstrow sheet("S2_12_F2N2")
rename _all, low
rename eess_renaes2 cod_renaes
keep cod_renaes nov_15d-febrero
rename (nov_15 nov_5 dic_15 dic_5 ene_15 ene_5 feb_15 feb_5 noviembre diciembre enero febrero) (his_15d_201511 his_5d_201511 his_15d_201512 his_5d_201512 his_15d_201601 his_5d_201601 his_15d_201602 his_5d_201602 cumple_201511 cumple_201512 cumple_201601 cumple_201602)
forval q=1/8{
replace cod_renaes="0"+cod_renaes if strlen(cod_renaes)<`q'
}
replace cod_renaes=substr(cod_renaes,2,8) if strlen(cod_renaes)==9
duplicates drop cod_renaes, force
tempfile cg13_file3
save `cg13_file3', replace

import excel using "$midis//2014_2016//CG13//FASE2//NIVEL 2//SUBSANACION//S2_12_F2N2_jul.xlsx", clear firstrow sheet("datos_EESS")
rename _all, low
rename eess_renaes2 cod_renaes
keep cod_renaes mar_15d-may
rename (mar_15 mar_5 abr_15 abr_5 may_15 may_5 mar abr may) (his_15d_201603 his_5d_201603 his_15d_201604 his_5d_201604 his_15d_201605 his_5d_201605 cumple_201603 cumple_201604 cumple_201605)
forval q=1/8{
replace cod_renaes="0"+cod_renaes if strlen(cod_renaes)<`q'
}
replace cod_renaes=substr(cod_renaes,2,8) if strlen(cod_renaes)==9
duplicates drop cod_renaes, force
tempfile cg13_file4
save `cg13_file4', replace

use `cg13_file1', clear
merge 1:1 cod_renaes using `cg13_file2', nogen update
merge 1:1 cod_renaes using `cg13_file3', nogen update
merge 1:1 cod_renaes using `cg13_file4', nogen update
rename cod_renaes cod_eess
duplicates drop cod_eess, force
reshape long his_5d_ his_15d_ cumple_, i(cod_eess) j(periodo)

foreach x of varlist his_* cumple_{
rename `x' cg13_`x'
}
forval q=1/8{
replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
}
replace cod_eess=substr(cod_eess,2,8) if strlen(cod_eess)==9

save "$midis//2014_2016//CG13//BBDD_CG13", replace
}


**Indicador CG14
qui{
import excel using "$midis//2014_2016//CG14//FASE1//NIVEL 2//SUBSANACION//SII-12reporte_hisminsa_verifica.xlsx", clear firstrow sheet("reporte_hisminsa_verifica")
rename _all, low
rename (eess_renaes atencion_sum) (cod_eess cg14_atenciones)
keep cod_eess cg14_*
gen periodo=201510
forval q=1/8{
replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
}

save "$midis//2014_2016//CG14//BBDD_CG14", replace
}

**Indicador CG19
local tempos "201605 201605 201608 201608 201603 201603 201606 201606 201703 201703 201605 201605 201608 201608"
forval cg=19/19{
local ff: dir "$midis//2014_2016//CG`cg'" files "*.dta"
clear
local q=1
local r=1	
	foreach file of local ff {	
	local tempo=word("`tempos'" , `r')
	use "$midis//2014_2016//CG`cg'//`file'",clear
	cap drop EESS
	rename _all, low
	cap rename cum_sismed_patri_85f cg19_cumple_`tempo'
	duplicates drop cod_eess, force
	local r = `r'+1
	save "$midis//2014_2016//CG`cg'//`file'", replace
	}
	foreach file of local ff {	
	if `q' ==1 {
	use "$midis//2014_2016//CG`cg'//`file'",clear
	}
	
	else {
	merge 1:1 cod_eess using "$midis//2014_2016//CG`cg'//`file'", nogen 
	}
	local q= `q' +1
	
	erase "$midis//2014_2016//CG`cg'//`file'"
	}
	keep cod_eess cg19_cumple_*
	reshape long cg19_cumple_, i(cod_eess) j(periodo)
	destring cg19_cumple_, replace
	forval q=1/8{
	replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
	}
	save "$midis//2014_2016//CG`cg'//BBDD_CG`cg'", replace
}


**Indicador CG20
local tempos "201604 201602 201603 201605 201611 201612 201701 201702 201703 201704 201705 201602 201602 201603 201605"
forval cg=20/20{
local ff: dir "$midis//2014_2016//CG`cg'" files "*.dta"
clear
local q=1
local r=1
local w=1
	foreach file of local ff {
	
		if `w' <5 {
		use "$midis//2014_2016//CG`cg'//`file'",clear
		rename _all, low
		cap drop _00_total
		cap drop *porc*
		cap drop _23*
		cap drop ruta*
		cap drop gore red_salud eess
		cap rename _*disp*ago cg20_disp_mmn_201508
		cap rename _*disp*set cg20_disp_mmn_201509
		cap rename _*disp*oct cg20_disp_mmn_201510
		cap rename _*disp*nov cg20_disp_mmn_201511
		cap rename _*disp*dic cg20_disp_mmn_201512
		cap rename _*disp*ene cg20_disp_mmn_201601
		cap rename _*disp*feb cg20_disp_mmn_201602
		cap rename _*stock*ago cg20_sin_cons_mmn_201508
		cap rename _*stock*set cg20_sin_cons_mmn_201509
		cap rename _*stock*oct cg20_sin_cons_mmn_201510
		cap rename _*stock*nov cg20_sin_cons_mmn_201511
		cap rename _*stock*dic cg20_sin_cons_mmn_201512
		cap rename _*stock*ene cg20_sin_cons_mmn_201601
		cap rename _*stock*feb cg20_sin_cons_mmn_201602
		local tempo=word("`tempos'" , `r')
		cap rename _99_*increm* cg20_increm_cons_mmn_`tempo'
		cap rename _99_*bajaron_* cg20_bajaron_cons_mmn_`tempo'
		local r = `r'+1
		duplicates drop cod_eess, force
		save "$midis//2014_2016//CG`cg'//`file'", replace
		local w = `w'+1
		}
		
		if `w' >4 & `w'<10 {
		local tempo=word("`tempos'" , `r')
		rename _all, low
		cap drop _*activos*
		cap drop _*porc*
		cap rename _*disp_* cg20_disp_mmn_`tempo'
		cap drop ruta*
		local r = `r'+1
		local w = `w'+1
		duplicates drop cod_eess, force
		save "$midis//2014_2016//CG`cg'//`file'", replace
		}

		if `w' >9 & `w'<12 {
		local tempo=word("`tempos'" , `r')
		rename _all, low
		cap drop quintil
		cap rename _201704 cg20_disp_mmn_`tempo'
		cap rename _201705 cg20_disp_mmn_`tempo'
		cap drop ruta*
		local r = `r'+1
		local w = `w'+1
		duplicates drop cod_eess, force
		save "$midis//2014_2016//CG`cg'//`file'", replace
		}

		if `w' >11 {
		local tempo=word("`tempos'" , `r')
		rename _all, low
		cap drop _00_total
		cap drop *porc*
		cap drop *dis* cg20_disp_mmn_`tempo'
		cap drop ruta*
		duplicates drop cod_eess, force
		local r = `r'+1
		local w = `w'+1
		save "$midis//2014_2016//CG`cg'//`file'", replace
		}
		
	}

	
	foreach file of local ff {
	if `q' ==1 {
	use "$midis//2014_2016//CG`cg'//`file'",clear
	}
	
	else {
	merge 1:1 cod_eess using "$midis//2014_2016//CG`cg'//`file'", nogen 
	}
	local q= `q' +1
	
	erase "$midis//2014_2016//CG`cg'//`file'"
	}
	order cod_eess cg20_*
	duplicates drop cod_eess, force
	reshape long cg20_disp_mmn_ cg20_sin_cons_mmn_ cg20_bajaron_cons_mmn_ cg20_increm_cons_mmn_, i(cod_eess) j(periodo)
	keep cod_eess periodo cg20_* 
	destring cg20_*, replace
	forval q=1/8{
	replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
	}

	save "$midis//2014_2016//CG`cg'//BBDD_CG`cg'", replace
}


**Indicador CG21
forval cg=21/21{
local ff: dir "$midis//2014_2016//CG`cg'" files "*.dta"
clear
local q=1
	foreach file of local ff {	
	use "$midis//2014_2016//CG`cg'//`file'",clear
	rename _all, low
	cap drop eess 
	cap drop _*porc*
	cap drop periodo_*
	cap drop _2*_eess
	cap drop ruta*
	cap drop gore red_salud
	duplicates drop cod_eess, force
	save "$midis//2014_2016//CG`cg'//`file'", replace
	}

	foreach file of local ff {	
	if `q' ==1 {
	use "$midis//2014_2016//CG`cg'//`file'",clear
	}
	
	else {
	merge 1:1 cod_eess using "$midis//2014_2016//CG`cg'//`file'", nogen 
	}
	local q= `q' +1
	
	erase "$midis//2014_2016//CG`cg'//`file'"
	}
	order cod_eess
	forval p=1/6{
	cap rename _20170`p'_eess_cumplen cg21_cumple_20170`p'
	}
	reshape long cg21_cumple_, i(cod_eess) j(periodo)
	destring cg21_cumple_, replace
	forval q=1/8{
	replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
	}
	label var cg21_cumple_ "Cumple con disponibilidad de suplemento"
	save "$midis//2014_2016//CG`cg'//BBDD_CG`cg'", replace
}

**Indicador CG24
qui{
import excel using "$midis//2014_2016//CG24//FASE1//NIVEL 3//VERIFICACION//REPORTE//Reporte HISjun2016 final.xlsx", clear firstrow sheet("base")
rename _all, low
keep d bk-bn
rename (d bk bl bm bn) (cod_eess cg24_infante_201603 cg24_infante_201604 cg24_gestante_201603 cg24_gestante_201604)
drop if cod_eess==""
forval p=1/8{
replace cod_eess="0"+cod_eess if length(cod_eess)<`p'
}
duplicates drop cod_eess, force
tempfile file1
save `file1', replace

import excel using "$midis//2014_2016//CG24//FASE1//NIVEL 3//SUBSANACION//REPORTE//Reporte_disponib_RRHH agost16_sub.xlsx", clear firstrow sheet("BASE 2")
rename _all, low
keep d bk-bn
rename (d bk bl bm bn) (cod_eess cg24_infante_201607 cg24_infante_201608 cg24_gestante_201607 cg24_gestante_201608)
drop if cod_eess==""
forval p=1/8{
replace cod_eess="0"+cod_eess if length(cod_eess)<`p'
}
duplicates drop cod_eess, force
tempfile file2
save `file2', replace

import excel using "$midis//2014_2016//CG24//FASE2//NIVEL 2//VERIFICACION//REPORTE//rep dispo a febrero 2016 revisado_mef.xlsx", clear firstrow sheet("BASEDATOS")
keep CODRENAES cumple_disp_niño_3m_a- cumple_disp_gest_3m_b
rename (CODRENAES cumple_disp_niño_3m_a cumple_disp_niño_3m_b cumple_disp_gest_3m_a cumple_disp_gest_3m_b) (cod_eess cg24_infante_201601 cg24_infante_201602 cg24_gestante_201601 cg24_gestante_201602)
drop if cod_eess==""
forval p=1/8{
replace cod_eess="0"+cod_eess if length(cod_eess)<`p'
}
duplicates drop cod_eess, force
tempfile file3
save `file3', replace

import excel using "$midis//2014_2016//CG24//FASE2//NIVEL 2//SUBSANACION//REPORTE//Reporte sub F2_RRHH_IPRESS_jun16.xlsx", clear firstrow sheet("BASES")
rename _all, low
keep d bh-bk
rename (d bh bi bj bk) (cod_eess cg24_infante_201605 cg24_infante_201606 cg24_gestante_201605 cg24_gestante_201606)
drop if cod_eess==""
forval p=1/8{
replace cod_eess="0"+cod_eess if length(cod_eess)<`p'
}
duplicates drop cod_eess, force
tempfile file4
save `file4', replace

import excel using "$midis//2014_2016//CG24//FASE2//NIVEL 3//VERIFICACION//REPORTE//Reporte RRHH marzo 17 V2.xlsx", clear firstrow sheet("BBDD")
rename _all, low
keep codipress cumple_disp_niño_3m_a- cumple_disp_gest_3m_b
rename (codipress cumple_disp_niño_3m_a cumple_disp_niño_3m_b cumple_disp_gest_3m_a cumple_disp_gest_3m_b) (cod_eess cg24_infante_201702 cg24_infante_201703 cg24_gestante_201702 cg24_gestante_201703)
tostring cod_eess, replace
drop if cod_eess==""
forval p=1/8{
replace cod_eess="0"+cod_eess if length(cod_eess)<`p'
}
duplicates drop cod_eess, force
drop if real(cod_eess)==0 | real(cod_eess)==.
tempfile file5
save `file5', replace

import excel using "$midis//2014_2016//CG24//FASE2//NIVEL 3//SUBSANACION//REPORTE//Reporte RRHH_Junio17 010817 v3.xlsx", clear firstrow sheet("BBDD")
rename _all, low
keep codipress cumple_disp_niño_3m_a- cumple_disp_gest_3m_b
rename (codipress cumple_disp_niño_3m_a cumple_disp_niño_3m_b cumple_disp_gest_3m_a cumple_disp_gest_3m_b) (cod_eess cg24_infante_201705 cg24_infante_201706 cg24_gestante_201705 cg24_gestante_201706)
tostring cod_eess, replace
drop if cod_eess==""
forval p=1/8{
replace cod_eess="0"+cod_eess if length(cod_eess)<`p'
}
duplicates drop cod_eess, force
drop if real(cod_eess)==0 | real(cod_eess)==.
tempfile file6
save `file6', replace

import excel using "$midis//2014_2016//CG24//FASE3//NIVEL 2//VERIFICACION//REPORTE//Reporte HISjun2016 final.xlsx", clear firstrow sheet("base") cellrange(A9:BN2920)
rename _all, low
keep d bk-bn
rename (d bk bl bm bn) (cod_eess cg24_infante_201603 cg24_infante_201604 cg24_gestante_201603 cg24_gestante_201604)
duplicates drop cod_eess, force
tempfile file7
save `file7', replace

import excel using "$midis//2014_2016//CG24//FASE3//NIVEL 2//SUBSANACION//REPORTE//Reporte_disponib_RRHH agost16_sub.xlsx", clear firstrow sheet("BASE") cellrange(A6:BN4228)
rename _all, low
keep d bk-bn
rename (d bk bl bm bn) (cod_eess cg24_infante_201607 cg24_infante_201608 cg24_gestante_201607 cg24_gestante_201608)
duplicates drop cod_eess, force
tempfile file8
save `file8', replace


use `file1', clear
forval t=2/8{
merge 1:1 cod_eess using `file`t'', nogen update 
}
reshape long cg24_infante_ cg24_gestante_, i(cod_eess) j(periodo)
forval q=1/8{
replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
}
collapse (mean) cg24_*, by(cod_eess periodo)
save "$midis//2014_2016//CG24//BBDD_CG24.dta", replace
}

**Indicador CG25
qui{
import excel using "$midis//2014_2016//CG25//FASE1//NIVEL 3//VERIFICACION//SII-09_EgresosHospitalarios_Mar_Abr_May2016.xlsx", clear firstrow sheet("BD")
rename _all, low
keep mes ipress cumplimientodecg 
rename (mes ipress cumpli) (periodo cod_eess cg25_cumple_)
tostring periodo, replace
replace periodo="201603" if periodo=="20514"
replace periodo="201604" if periodo=="20545"
replace periodo="201605" if periodo=="20575"
tempfile file1
save `file1', replace

import excel using "$midis//2014_2016//CG25//FASE1//NIVEL 3//SUBSANACION//Cumplimiento de verificacón junio julio agosto 05.10.16.xlsx", clear firstrow sheet("IPRESS CON CG-verificación")
rename _all, low
keep cod_renaes cumpli*
cap drop cumplimientodecgsubsanación
rename (cod_renaes cumplimientodecgjunio cumplimientodecgjulio cumplimientodecgagosto) (cod_eess cg25_cumple_201606 cg25_cumple_201607 cg25_cumple_201608)
reshape long cg25_cumple_, i(cod_eess) j(periodo) string
append using `file1', force

replace cg25_cumple_=subinstr(cg25_cumple_, "NO","0",.)
replace cg25_cumple_=subinstr(cg25_cumple_, "SI","1",.)
tostring cod_eess, replace
destring cg25_ periodo, replace
forval p=1/8{
replace cod_eess="0"+cod_eess if length(cod_eess)<`p'
}

save "$midis//2014_2016//CG25//BBDD_CG25.dta", replace
}


**Indicador CG26
qui{
import excel using "$midis//2014_2016//CG26//FASE1//NIVEL 3//VERIFICACION//F1N3 1-V SIII-09 Indicador_hisminsa_may2016_v4.1.xlsx", clear firstrow sheet("Datos_Mayo2016")
rename _all, low
keep renaes compara_prom2 mes
rename compara_prom2 cg26_cumple_ 
tostring renaes, replace
replace mes="201605"
tempfile file1
save `file1', replace

import excel using "$midis//2014_2016//CG26//FASE1//NIVEL 3//SUBSANACION//indicador_hisminsa_ago2016r.xlsx", clear firstrow sheet("AGOSTO")
rename _all, low
keep renaes cumple
rename cumple cg26_cumple_
gen mes="201608"
tempfile file2
save `file2', replace

import excel using "$midis//2014_2016//CG26//FASE2//NIVEL 2//VERIFICACION//F2N2 1-V SII-08 EESS_hisminsa_abr16.xlsx", clear firstrow sheet("EESS_hisminsa_abr16")
rename _all, low
keep renaes his2meses_ok
rename his2meses_ok cg26_cumple_
tostring renaes, replace
gen mes="201603"
tempfile file3
save `file3', replace

import excel using "$midis//2014_2016//CG26//FASE2//NIVEL 2//SUBSANACION//EESS_hisminsa_jun16.xlsx", clear firstrow sheet("EESS_hisminsa_jun16")
rename _all, low
keep renaes his2meses_ok
rename his2meses_ok cg26_cumple_
tostring renaes, replace
gen mes="201606"
tempfile file4
save `file4', replace

use `file1', clear
append using `file2', force
append using `file3', force
append using `file4', force
duplicates drop mes renaes, force
rename renaes cod_eess
forval p=1/7{
replace cod_eess="0"+cod_eess if length(cod_eess)<`p'
}

order cod_eess mes cg26_
rename mes periodo
destring periodo, replace
forval q=1/8{
replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
}
save "$midis//2014_2016//CG26//BBDD_CG26.dta", replace
}


**Indicador CG27
qui{
import excel using "$midis//2014_2016//CG27//FASE1//NIVEL 3//VERIFICACION//F1N3 1-V SIII-10 PartosSIS_CNV_jul16.xlsx", clear firstrow sheet("Datos")
rename _all, low
keep eess_renaes anhomes casos concnv2
rename (eess_renaes anhomes casos concnv2) (cod_eess periodo cg27_partos_atendidos cg27_parto_registro_cnv)
destring cg27_* periodo, replace
collapse (sum) cg27_*, by(periodo cod_eess)
gen cg27_cumple_=cg27_parto_registro_cnv/cg27_partos_atendidos
forval q=1/8{
replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
}
duplicates drop cod_eess periodo, force
save "$midis//2014_2016//CG27//BBDD_CG27.dta", replace
}


**Indicador CG28
local tempos "201605 201608 201703 201706 201605 201608"
forval cg=28/28{
local ff: dir "$midis//2014_2016//CG`cg'" files "*.dta"
clear
local q=1
local r=1	
	foreach file of local ff {	
	local tempo=word("`tempos'" , `r')
	use "$midis//2014_2016//CG`cg'//`file'",clear
	rename _all, low
	cap drop gore red_salud eess cod_eess ruta
	cap drop porcnac*
	cap rename quintil distrito
	destring nac*, replace
	gen cg28_porc_nac_dni5d_`tempo'=nacimientos_c_iniciodni5d/ nacimientos_c_cnv
	cap drop nac*
	cap gen ubigeo=substr(distrito,1,6)
	cap drop distrito
	duplicates drop ubigeo, force
	drop if real(ubigeo)==.
	save "$midis//2014_2016//CG`cg'//`file'", replace
	local r = `r'+1
	}

	foreach file of local ff {	
	if `q' ==1 {
	use "$midis//2014_2016//CG`cg'//`file'",clear
	}
	
	else {
	merge 1:1 ubigeo using "$midis//2014_2016//CG`cg'//`file'", nogen update
	}
	local q= `q' +1
	
	erase "$midis//2014_2016//CG`cg'//`file'"
	}
	cap order ubigeo, first
	reshape long cg28_porc_nac_dni5d_, i(ubigeo) j(periodo)
	save "$midis//2014_2016//CG`cg'//BBDD_CG`cg'", replace
}


**Indicador CG29
local tempos "201605 201605 201606 201606 201703 201703 201706 201706 201605 201605 201608 201608"
forval cg=29/29{
local ff: dir "$midis//2014_2016//CG`cg'" files "*.dta"
clear
local q=1
local r=1
	foreach file of local ff {	
	local tempo=word("`tempos'" , `r')
	use "$midis//2014_2016//CG`cg'//`file'",clear
	rename _all, low
	cap drop gore 
	cap drop red_salud 
	cap drop eess 
	cap drop quintil 
	cap drop ruta
	cap drop si
	cap drop _0
	cap drop _1
	cap rename porc* cg29_ratio_registro_`tempo'
	cap drop no 
	cap drop c_ccpp
	cap drop _5a
	cap drop if strpos(ccpp,"Blank")
	replace cod_eess=ustrtrim(cod_eess)
	duplicates drop cod_eess, force
	drop if real(cod_eess)==.
	rename cod_eess ubigeo
	save "$midis//2014_2016//CG`cg'//`file'", replace
	local r = `r'+1
	}

	foreach file of local ff {	
	if `q' ==1 {
	use "$midis//2014_2016//CG`cg'//`file'",clear
	}
	
	else {
	merge 1:1 ubigeo using "$midis//2014_2016//CG`cg'//`file'", nogen 
	}
	local q= `q' +1
	
	erase "$midis//2014_2016//CG`cg'//`file'"
	}
	reshape long cg29_ratio_registro_, i(ubigeo) j(periodo)
	replace cg29_ratio_registro_="" if strpos(cg29_ratio_registro_,"/")
	destring cg29_ratio_registro_, replace
	gen cg29_cumple_=cg29_ratio_registro_>.8 & cg29_ratio_registro_<.
	label var cg29_ratio_registro_ "Ratio de menores de 12 meses registrados en relacion al promedio de Niños de 2 a 4 años"
	forval q=1/6{
	replace ubigeo="0"+ubigeo if strlen(ubigeo)<`q'
	}
	save "$midis//2014_2016//CG`cg'//BBDD_CG`cg'", replace
}


**Indicador CG31
local tempos "201606 201705 201608 201703 201705 201605 201608"
forval cg=31/31{
local ff: dir "$midis//2014_2016//CG`cg'" files "*.dta"
clear
local q=1
local r=1	
	foreach file of local ff {	
	local tempo=word("`tempos'" , `r')
	use "$midis//2014_2016//CG`cg'//`file'",clear
	rename _all, low
	cap drop gore red_salud eess
	cap rename _10 cg31_fuas_10d_`tempo'
	cap drop _*
	cap drop intervalo
	cap drop ruta*
	cap drop cod_eess
	gen ubigeo=substr(quintil,1,6)
	drop if real(ubigeo)==.
	destring cg31_fuas*, replace
	cap drop quintil
	local r = `r'+1
	duplicates drop ubigeo, force
	drop if real(ubigeo)==.
	save "$midis//2014_2016//CG`cg'//`file'", replace
	}
	foreach file of local ff {	
	if `q' ==1 {
	use "$midis//2014_2016//CG`cg'//`file'",clear
	}
	
	else {
	merge 1:1 ubigeo using "$midis//2014_2016//CG`cg'//`file'", nogen 
	}
	local q= `q' +1
	
	erase "$midis//2014_2016//CG`cg'//`file'"
	}
	reshape long cg31_fuas_10d_, i(ubigeo) j(periodo)
	save "$midis//2014_2016//CG`cg'//BBDD_CG`cg'", replace
}


**Indicador CG32
qui{
import excel using "$midis//2014_2016//CG32//FASE2//NIVEL 3//VERIFICACION//REPORTE//BBDD_cg32_verif.xlsx", clear firstrow sheet("Hoja1")
rename _all, low
duplicates drop extra, force
keep extra cumple*
forval p=1/3{
cap rename cumplepaso`p' cg32_cumple_paso`p'_201703
}
rename extra cod_eess
tempfile file1
save `file1', replace

import excel using "$midis//2014_2016//CG32//FASE2//NIVEL 3//SUBSANACION//REPORTE//SIII-16 JUNIO 2017 F2N3.xlsx", clear firstrow sheet("tabla pasos 1,2,3")
rename _all, low
duplicates drop ipress, force
keep ipress cumple*
forval p=1/3{
cap rename cumplepaso`p' cg32_cumple_paso`p'_201706
}
rename ipress cod_eess
tempfile file2
save `file2', replace

merge 1:1 cod_eess using `file1', nogen 
reshape long cg32_cumple_paso1_ cg32_cumple_paso2_ cg32_cumple_paso3_, i(cod_eess) j(periodo)
forval q=1/8{
replace cod_eess="0"+cod_eess if strlen(cod_eess)<`q'
}
save "$midis//2014_2016//CG32//BBDD_CG32", replace
}



****************************************
*******	INDICADORES DE AGUA	************
****************************************

global fases FASE1 FASE2 FASE3
input str42 (niveles)
"NIVEL 0" 
"NIVEL 1" 
"NIVEL 2" 
"NIVEL 3"
end
global subniveles VERIFICACION

*** Se borra cualquier data en carpetas de trabajo 
*** -----------------------------------------------
forval cg=33/35{
local ff: dir "$midis//2014_2016//CG`cg'" files "*.dta"
	foreach file of local ff {	
	cap	erase "$midis//2014_2016//CG`cg'//`file'"
	}
}

*** Primera estructura de BBDD sobre Indicadores de Agua
*** ------------------------------------------------------
levelsof niveles, local(niveles)
foreach cg in 33 34  {
local r=10

foreach fase of global fases {

foreach nivel of local niveles {

foreach subnivel of global subniveles {

	confirmdir "$midis//2014_2016//CG`cg'//`fase'//`nivel'//VERIFICACION"
	if `r(confirmdir)'==0 { //En caso exista el directorio

	*** Importamos la base
	*** -------------------
	cd "$midis//2014_2016//CG`cg'//`fase'//`nivel'//VERIFICACION"
	local f: dir "$cd" files "*.xlsx"
	clear

	foreach file of local f {
	import excel using `"`file'"', clear firstrow allstring

	gen  ruta`r'= `"2014_2016//CG`cg'//`fase'//`nivel'//VERIFICACION"' in 1
	save "$midis//2014_2016//CG`cg'//file`r'.dta",replace
	local r= `r' + 1
	}
}
}
}
}
}

	foreach c in 21 22 23 24 25 {
	erase "$midis//2014_2016//CG33//file`c'.dta"
	}

**Indicador CG33
forval cg=33/33{
local ff: dir "$midis//2014_2016//CG`cg'" files "*.dta"
clear
local r=10
	foreach file of local ff {	
	
	if `r'>=10 & `r'<19 {
	use "$midis//2014_2016//CG`cg'//`file'",clear
	rename _all, low
	keep ubigeoccpp centropobla*
	rename ubigeoccpp ubigeoccpp
	drop if ubigeo==""
	duplicates drop ubigeo, force
	save "$midis//2014_2016//CG`cg'//`file'", replace
	}
	
	if `r'>=19 & `r'<21 {
	use "$midis//2014_2016//CG`cg'//`file'",clear
	rename _all, low
	keep ubigeo cuenta_* 
	rename ubigeo ubigeoccpp
	drop if ubigeo==""
	duplicates drop ubigeo, force
	save "$midis//2014_2016//CG`cg'//`file'", replace
	}	

	if `r'>=21 & `r'<30 {
	use "$midis//2014_2016//CG`cg'//`file'",clear
	rename _all, low
	keep ubigeo centropobla*
	drop if ubigeo==""
	duplicates drop ubigeo, force
	save "$midis//2014_2016//CG`cg'//`file'", replace
	}	
	local r = `r'+1
	}
	
	local q=1
	
	foreach file of local ff {
	
	if `q' ==1 {
	use "$midis//2014_2016//CG33//`file'",clear
	}
	
	else {
	merge 1:1 ubigeoccpp using "$midis//2014_2016//CG33//`file'", nogen update
	}
	local q= `q' +1
	
	erase "$midis//2014_2016//CG33//`file'"
	}
	gen ubigeo = substr(ubigeoccpp,1,6)
	gen cg33_sistema_agua=centropobladocuentasistemad=="Si"
	gen cg33_sistema_excretas=centropobladocuentasistemae=="Si"
	replace cg33_sistema_agua=. if centropobladocuentasistemad==""
	replace cg33_sistema_excretas=. if centropobladocuentasistemae==""
	replace cg33_sistema_agua=1 if cuenta_con_sistema=="Si"
	replace cg33_sistema_agua=0 if cuenta_con_sistema=="No"
	drop centropob* cuenta_*
	gen x=1
	collapse (sum) cg33_* (count) tot_ccpp=x, by(ubigeo)
	save "$midis//2014_2016//CG`cg'//BBDD_CG`cg'", replace
}

**Indicador CG34
forval cg=34/34{
local ff: dir "$midis//2014_2016//CG`cg'" files "*.dta"
clear
local r=10
	foreach file of local ff {	
	use "$midis//2014_2016//CG`cg'//`file'",clear
	rename _all, low
	keep ubigeo diagnosticado
	cap rename ubigeo ubigeoccpp
	drop if ubigeo==""
	duplicates drop ubigeo, force
	save "$midis//2014_2016//CG`cg'//`file'", replace
	}
	
	local q=1
	foreach file of local ff {
	
	if `q' ==1 {
	use "$midis//2014_2016//CG34//`file'",clear
	}
	
	else {
	merge 1:1 ubigeoccpp using "$midis//2014_2016//CG34//`file'", nogen update
	}
	local q= `q' +1
	
	erase "$midis//2014_2016//CG34//`file'"
	}
	drop if real(ubigeo)==.
	gen cg34_cumple_= diagnosticado=="true"
	cap drop diagnosticado
	gen ubigeo = substr(ubigeoccpp,1,6)
	gen x=1
	collapse (sum) cg34_* (count) cg34_tot_ccpp=x, by(ubigeo)	
	save "$midis//2014_2016//CG`cg'//BBDD_CG`cg'", replace
}

****************************************
****	INDICADORES DE EDUCACION	****
****************************************
**CG36- CG67
clear
global midis "C:\Users\evera\OneDrive - Macroconsult S.A\MACROCONSULT\Evaluación de Impacto FED UE\Información MIDIS"
global periodos 2014_2016
global subniveles VERIFICACION SUBSANACION 

*** Importamos BBDD 
*** ----------------
*levelsof fases_edu, local(fases_edu)
*levelsof niveles_edu, local(niveles_edu)

forval cg=36/67{
local r=10

if `cg'!=53 & `cg'!=55 & `cg'!=56 & `cg'!=59 & `cg'!=61 & `cg'!=62 { //SON INDICADORES A NIVEL DEPARTAMENTAL
foreach fase in "FASE 1" "FASE 2" "FASE 3" {

foreach nivel in "NIVEL 1" "NIVEL 2" "NIVEL 3" {

foreach subnivel of global subniveles {

	confirmdir "$midis//2014_2016//CG`cg'//`fase'//`nivel'//`subnivel'"
	clear

		if `r(confirmdir)'==0 { //En caso exista el directorio

		*** Importamos la base
		*** -------------------
		cd "$midis//2014_2016//CG`cg'//`fase'//`nivel'//`subnivel'"
		clear
		local f: dir "$cd" files "*.xlsx"

		foreach file of local f {
		import excel using `"`file'"', clear firstrow allstring sheet("Indicador")
		rename _all, low

		*** Guardamos la base
		*** ---------------------
		dis `"`file'"'
		dis `"2014_2016//CG`cg'//`fase'//`nivel'//`subnivel'"'
		gen  ruta= `"2014_2016//CG`cg'//`fase'//`nivel'//`subnivel'"' in 1
		save "$midis//2014_2016//CG`cg'//file`r'.dta",replace
		local r= `r' + 1
		
		}
		}
}
}
}
}
}

*** Primera estructura de BBDD sobre Indicadores de Educación
*** ----------------------------------------------------------

forval cg=36/67{
cap	erase "$midis//2014_2016//CG`cg'//BBDD_CG`cg'"
local ff: dir "$midis//2014_2016//CG`cg'" files "*.dta"
clear
local q=1

	if `"`ff'"' !=""{
	
	foreach file of local ff {	
	if `q' ==1 {
	use "$midis//2014_2016//CG`cg'//`file'",clear
	}
	
	else {
	append using "$midis//2014_2016//CG`cg'//`file'" 
	}
	local q= `q' +1
	
	erase "$midis//2014_2016//CG`cg'//`file'"
	}
	order ubigeo departamento provincia distrito distritosfed corte_medición indicador tipo num denom cumplim ruta*
	cap order quintil, a(cod_eess)
	save "$midis//2014_2016//CG`cg'//BBDD_CG`cg'", replace
	}
}

