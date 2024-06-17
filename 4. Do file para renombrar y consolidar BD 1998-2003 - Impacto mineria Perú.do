
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

* Parametros
*==============
global año_ini 1998 //modifica el año de inicio de tu análisis
global año_fin 2003 //modifica el año de fin de tu análisis


*-------------------------------------------------------------------------------
* CODIGO PARA RENOMBRAR ARCHIVOS DE TUS CARPETAS
*-------------------------------------------------------------------------------

forval y=$año_ini / $año_fin {
global año `y'
cd "$bd/${año}" //directorio

* Bases
foreach t in 100 200 605 612 {
local ff: dir "$cd" files "*`t'.dta"
clear
dis `"`ff'"'
shell ren "`ff'" "enaho01-${año}-`t'.dta" //se renombra
}

* Bases
foreach t in 300 400 500 {
local ff: dir "$cd" files "*`t'.dta"
clear
dis `"`ff'"'
shell ren "`ff'" "enaho01a-${año}-`t'.dta" //se renombra
}

* Base con numero
local ff: dir "$cd" files "sumaria*.dta"
clear
dis `"`ff'"'
shell ren "`ff'" "sumaria-${año}.dta" //se renombra

}


*-------------------------------------------------------------------------------
* CODIGO PARA CONSOLIDAR BBDD DE 1998-2003 MODULO 612 - EQUIPAMIENTO DEL HOGAR
*-------------------------------------------------------------------------------

forval y=$año_ini / $año_fin {
	global año `y'

if $año < 2001 { // No se puede hacer match del sumaria porque la BD no tiene ubigeo
	use "$bd/${año}/enaho01-${año}-612", clear

	keep ubigeo conglome vivienda hogar p612_03 p612_04 p612_08 p612_16 
	rename (p612_03 p612_04 p612_08 p612_16 ) (tv refri lavadora compu)
	recode tv refri lavadora compu (2=0)
	gen aniorec = $año
	tempfile temp`y'
	save `temp`y'', replace
	
	}
	
if $año > 2000{
	use "$bd/${año}/enaho01-${año}-612", clear

	keep ubigeo conglome vivienda hogar p612n p612 fac*
	keep if inlist(p612n,3,4,8,10,11,12,13,20)
	reshape wide p612, i(ubigeo conglome vivienda hogar fac*) j(p612n)
	rename (p6123 p6124 p6128 p61210 p61211 p61212 p61213 p61220) (tv refri lavadora cocina_gas cocina_kero microondas licuadora compu)
	gen aniorec = $año
	tempfile temp`y'
	save `temp`y'', replace


}

}

use `temp1998', clear
forval r = 1999/2003{
append using `temp`r''
}

order aniorec ubigeo conglome viv hog tv refri lavadora cocina_gas cocina_kero microondas licuadora compu fac*

save "$bd/ENAHO_modulo612_1998-2003", replace
save "$b/ENAHO/ENAHO_modulo612_1998-2003", replace

*-------------------------------------------------------------------------------
* CODIGO PARA CONSOLIDAR BBDD DE 2000-2003 MODULO PERCEPCION
*-------------------------------------------------------------------------------

* Convertir Base DBF a DTA
*===========================
forval y=$año_ini / $año_fin {
global año `y'
confirmdir "$bd/${año}"

	if `r(confirmdir)'==0 { 
	cd "$bd/${año}" //directorio
	local ff: dir "$cd" files "*.dbf"
	clear
		foreach file of local ff { 
		dis "`file'"
		import dbase using "`file'", clear
		rename _all, low
		
		local otherfile = subinstr("`file'",".dbf",".dta",.) //se cambia un caracter del nombre
		local otherfile = subinstr("`otherfile'","iv","",.) //se cambia un caracter del nombre
		local otherfile = subinstr("`otherfile'","-opinión","",.) //se cambia un caracter del nombre
	save "`otherfile'", replace

		}
	}
	
	else{
	}
}


*-------------------------------------------------------------------------------
* CODIGO PARA CONSOLIDAR BBDD DE 1998-2003 MODULOS 100-200-300-400-500-SUMARIA
*-------------------------------------------------------------------------------

* Correccion de imperfecciones
forval y=$año_ini / $año_fin {
global año `y'
cd "$bd/${año}" //directorio
local ff: dir "$cd" files "*.dta"
clear
	foreach file of local ff { 
	dis "`file'"
	use "`file'", clear
	
	foreach t in ubigeo{
	capture confirm variable `t'
	if _rc{
	gen `t' = "0"
	}
	
	}

	foreach x in conglome vivienda hogar codperso{
	cap destring `x', replace
	cap tostring `x', replace
	cap replace `x' = subinstr(`x', " ", "",.)
	}
	
	forval q = 1/6{
	cap replace ubigeo = "0"+ubigeo if length(ubigeo)<`q'
	cap replace conglome = "0"+conglome if length(conglome)<`q'
	}

	forval q = 1/3{	
	cap replace vivienda = "0"+vivienda if length(vivienda)<`q'
	}

	forval q = 1/2{
	cap replace hogar = "0"+hogar if length(hogar)<`q'
	}
	
	save "`file'", replace
	}

}

global id_viv conglome vivienda hogar

forval y=$año_ini / $año_fin {
	global año `y'

	use "$bd/${año}/enaho01-${año}-100", clear


	merge 1:1 $id_viv using "$bd/${año}/sumaria-${año}", nogen keep(1 3) force
	
	merge 1:m $id_viv using "$bd/${año}/enaho01-${año}-200", nogen force

	merge 1:1 $id_viv codperso using "$bd/${año}/enaho01a-${año}-300", nogen force

	merge 1:1 $id_viv codperso using "$bd/${año}/enaho01a-${año}-400", nogen force

	merge 1:1 $id_viv codperso using "$bd/${año}/enaho01a-${año}-500", nogen force

	save "$bd/ENAHO_consolidado_${año}", replace
	save "$b/ENAHO/ENAHO_consolidado_${año}", replace

}



