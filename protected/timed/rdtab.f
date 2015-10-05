	program rdtab

C  02/02:  rdtab.f
C  Program to read the TAB data from the CEDAR DB DODS web system
C   File names are usually of the type:  namyrmodaa(or b or c).cbf.tab
C   This works only if ALL the parameters are taken.
C   Must remove tabs in fortran before interpreting each line
C
	character*6 char6
	character*200 line
	dimension ipprol(13),icod1d(100),ipar1d(100),icod2d(100),
     |    ipar2d(100,900),lbs(100),les(100)

	ird = 11
	open (ird,file='namyrmodaa.cbf.tab',status='old')

	rewind ird

	nrecrd = 0
1000    continue
	write (6,"(1x,'Read nrecrd =',i6)") nrecrd
C Read partial Prologue
C Skip over: KINST   KINDAT  IBYRT   IBDTT   IBHMT   IBCST   IEYRT   IEDTT   IEHMT   IECST   JPAR    MPAR    NROWS
	read (ird,"(a)",end=2000) line
	nrecrd = nrecrd + 1
	read (ird,"(a)") line
	call detab (line,nbi,ist)
	if (ist .eq. 1) then
	 write (6,"(1x,'line too short -- stop')")
	 stop
	endif
	call parsbs (line,100,nstr,lbs,les,ist)
	do 1100 n=1,13
	char6 = line(lbs(n):les(n))
	read (char6,"(i6)") ipprol(n)
1100    continue

C  Read JPAR 1-D parameters, and NROWS of MPAR 2-D parameters from instrument KINST
C   between begin date IBYRT,IBDTT,IBHMT,IBCST and end date IEYRT,IEDTT,IEHMT,IECST
C   (year, monthday, UThourmin, centisecond)
       write (6,"(1x,'kinst kindat begin_time end_time 1-D 2-D rows=',
     |   13i6)") ipprol
	jpar = ipprol(11)
	mpar = ipprol(12)
	nrows = ipprol(13)
	if (jpar .gt. 100 .or. mpar .gt. 100 .or. nrows .gt. 900) stop

C Are there any JPAR (single valued parameters)?
       if (jpar .gt. 0) then
C  Read 1-D parameters
C  Skip over 1-D mneumonic names
	read (ird,"(a)") line
C  Read 1-D parameter codes
	read (ird,"(a)") line
	call detab (line,nbi,ist)
	if (ist .eq. 1) then
	 write (6,"(1x,'line too short -- stop')")
	 stop
	endif
	call parsbs (line,100,nstr,lbs,les,ist)
	do 1200 n=1,jpar
	char6 = line(lbs(n):les(n))
	read (char6,"(i6)") icod1d(n)
1200    continue
       write (6,"(1x,'1D codes =',100i6)") (icod1d(n),n=1,jpar)
C  Read 1-D parameter values
	read (ird,"(a)") line
	call detab (line,nbi,ist)
	if (ist .eq. 1) then
	 write (6,"(1x,'line too short -- stop')")
	 stop
	endif
	call parsbs (line,100,nstr,lbs,les,ist)
	do 1300 n=1,jpar
	char6 = line(lbs(n):les(n))
	read (char6,"(i6)") ipar1d(n)
1300    continue
       endif

C Are there any MPAR (multiple valued parameters)?
	if (mpar .gt. 0) then
C  Read 2-D parameters
C  Skip over 2-D mneumonic names
	read (ird,"(a)") line
C  Read 2-D parameter codes
	read (ird,"(a)") line
	call detab (line,nbi,ist)
	if (ist .eq. 1) then
	 write (6,"(1x,'line too short -- stop')")
	 stop
	endif
	call parsbs (line,100,nstr,lbs,les,ist)
	do 1400 n=1,mpar
	char6 = line(lbs(n):les(n))
	read (char6,"(i6)") icod2d(n)
1400    continue
       write (6,"(1x,'2D codes =',100i6)") (icod2d(n),n=1,mpar)
C  Read 2-D parameter values
	 do 1600 j=1,nrows
	read (ird,"(a)") line
C       write (6,"(1x,a)") line
	call detab (line,nbi,ist)
	if (ist .eq. 1) then
	 write (6,"(1x,'line too short -- stop')")
	 stop
	endif
	call parsbs (line,100,nstr,lbs,les,ist)
	do 1500 n=1,jpar
	char6 = line(lbs(n):les(n))
	read (char6,"(i6)") ipar2d(n,j)
1500    continue
1600    continue
	endif

C Read 1 blank line inbetween each record
	read (ird,"(a)") line

	go to 1000

2000    continue
	write (6,"(1x,'Stop after reading ',i6,' records')") nrecrd

	stop
	end
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      SUBROUTINE PARSBS (STR,MXNS,NS,LBS,LES,IST)
C          This is the plural of PARSB.  It finds the locations of all blank
C          delimited substrings in an input string.
C          INPUTS:
C            STR  = Character string to be parsed.
C            MXNS = Dimension of LBS and LES arrays.
C          RETURNS:
C            NS  = Number of blank delimited strings found.
C            LBS = Positions of the first non-blank characters in each
C                  substring; NS values are assigned
C            LES = Positions of the last non-blank characters in each
C                  substring; NS values are assigned
C            IST = Status where:  0 => okay ; 1 => MXNS is too small and
C                  only the first MXNS string positions were assigned.
C          Formal argument declarations:
      CHARACTER*(*) STR
      DIMENSION LBS(*) , LES(*)
                                                                                
      NS  = 0
      IST = 0

      IBS = 1
      IES = LEN(STR)
  100 DO 200 I=IBS,IES
      IF (STR(I:I) .NE. ' ') GO TO 210
  200 CONTINUE
      RETURN

  210 NS = NS + 1
      IF (NS .GT. MXNS) THEN
	NS = MXNS
	IST = 1
	RETURN
      ENDIF
      LBS(NS) = I

      DO 300 J=I,IES
      IF (STR(J:J) .EQ. ' ') GO TO 310
  300 LES(NS) = J
  310 CONTINUE

      IBS = LES(NS) + 1
      IF (LES(NS) .LT. IES) GO TO 100
                                                                                
      RETURN                                                                    
      END                                                                       
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      SUBROUTINE DETAB (STR,NBI,IST)
C          Replace tabs in a string.  Tab stops are at 1,9,17...
C            INPUTS:
C              STR = string
C            RETURNS:
C              STR = string with each tab replaced by one or more blanks
C              NBI = No. blanks added; when NBI > 0, the rightmost characters
C                    in input STR are lost
C              IST = status: (0) okay, (1) failed because non-blanks would be
C                    lost (STR remains unchanged)

c     PARAMETER (MXNC=2000)
      PARAMETER (MXNC=4000)
      CHARACTER STR*(*), C(MXNC)*1
      NBI = 0
      IST = 0

C          Look for tabs while assigning one char at a time to temp array
      LSTR = LEN (STR)
      I = 0
      J = 0
   10 I = I + 1
      J = J + 1
   20 IF (J .GT. MXNC) STOP 'mxnc'
      IF (I .GT. LSTR) GO TO 40
      C(J) = STR(I:I)
      IF (C(J) .NE. '\t') GO TO 10

C          Found a tab:  put blanks in temp array (C) until next tab stop (K)
      K    = 8*((J+7)/8)
   30 C(J) = ' '
      NBI  = NBI + 1
      J = J + 1
      IF (J .LE. K) GO TO 30
      I = I + 1
      GO TO 20

   40 IF (NBI .EQ. 0) GO TO 100

      DO 50 I=LSTR+1,J-1
      IF (C(I) .EQ. ' ') GO TO 50
      NBI = 0
      IST = 1
      GO TO 100
   50 CONTINUE
      IST = 0
      DO 60 I=1,LSTR
   60 STR(I:I) = C(I)

  100 RETURN
      END
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
