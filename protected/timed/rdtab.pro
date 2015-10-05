pro rdtab

;to run:  idl <ret>, .run rdtab <ret>, rdtab <ret>,
; exit <ret>

; ***************************************************************************
;  02/02:  rdtab.f
;  Program to read the TAB data from the CEDAR DB DODS web system
;   File names are usually of the type:  namyrmodaa(or b or c).cbf.tab
;   This works only if ALL the parameters are taken.
;   The code abruptly halts at the end of reading all the records

char6 = strarr(1)
line = strarr(1)
ipprol = intarr(13)

ird = 11
openr,ird,'namyrmodaa.cbf.tab'


nrecrd = 0
; Read first 1000 records
while (nrecrd lt 1000) do begin
; Read partial Prologue
; Skip over: KINST   KINDAT  IBYRT   IBDTT   IBHMT   IBCST   IEYRT   IEDTT   IEHMT   IECST   JPAR    MPAR    NROWS
readf,ird,line
nrecrd = nrecrd + 1
print,'nrecrd to read =',nrecrd
readf,ird,ipprol

;  Read JPAR 1-D parameters, and NROWS of MPAR 2-D parameters from instrument KINST
;   between begin date IBYRT,IBDTT,IBHMT,IBCST and end date IEYRT,IEDTT,IEHMT,IECST
;   (year, monthday, UThourmin, centisecond)
print,'kinst kindat begin_time end_time 1-D 2-D rows=',ipprol
jpar = ipprol(10)
mpar = ipprol(11)
nrows = ipprol(12)

icod1d = intarr(jpar)
ipar1d = intarr(jpar)
icod2d = intarr(mpar)
itmp2d = intarr(mpar)
ipar2d = intarr(mpar,nrows)

; Are there any JPAR (single valued parameters)?
if (jpar gt 0) then begin
;  Read 1-D parameters
;  Skip over 1-D mneumonic names
readf,ird,line
;  Read 1-D parameter codes
readf,ird,icod1d
print,'1D codes =',icod1d
;  Read 1-D parameter values
readf,ird,ipar1d
endif

; Are there any MPAR (multiple valued parameters)?
if (mpar gt 0) then begin
;  Read 2-D parameters
;  Skip over 2-D mneumonic names
readf,ird,line
;  Read 2-D parameter codes
readf,ird,icod2d
print,'2D codes =',icod2d
;  Read 2-D parameter values
for j=0,nrows-1 do begin
 readf,ird,itmp2d
 ipar2d(*,j) = itmp2d(*)
endfor
endif

; Read 1 blank line inbetween each record
readf,ird,line

end

end
