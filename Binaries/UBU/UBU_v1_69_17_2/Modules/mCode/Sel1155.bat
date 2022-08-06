:mn
set ec=
echo.
echo		Select Microcode for CPU IvyBridge (LGA1155)
echo.
echo 	 7 Version  7 Date 21-11-2011
echo 	 8 Version  8 Date 07-12-2011
echo 	0A Version 0A Date 06-01-2012
echo 	0C Version 0C Date 13-01-2012
echo 	0D Version 0D Date 06-02-2012
echo 	10 Version 10 Date 20-02-2012
echo 	12 Version 12 Date 12-04-2012
echo 	13 Version 13 Date 16-07-2012
echo 	15 Version 15 Date 07-08-2012
echo 	16 Version 16 Date 30-10-2012
echo 	17 Version 17 Date 09-01-2013
echo 	19 Version 19 Date 13-06-2013 - Best overclocking
echo 	1A Version 1A Date 06-12-2013
echo 	1B Version 1B Date 29-05-2014
echo 	1C Version 1C Date 26-02-2015
echo 	1F Version 1F Date 07-02-2018
echo 	0  Skip
echo.
:mn1
set /p ec=Enter Microcode:
if not defined ec goto mn1

if /I %ec%==7 (set mc1=1155\cpu000306A9_plat12_ver00000007_date21-11-2011.bin) && goto mn_snb
if /I %ec%==8 (set mc1=1155\cpu000306A9_plat12_ver00000008_date07-12-2011.bin) && goto mn_snb
if /I %ec%==0A (set mc1=1155\cpu000306A9_plat12_ver0000000A_date06-01-2012.bin) && goto mn_snb
if /I %ec%==0C (set mc1=1155\cpu000306A9_plat12_ver0000000C_date13-01-2012.bin) && goto mn_snb
if /I %ec%==0D (set mc1=1155\cpu000306A9_plat12_ver0000000D_date06-02-2012.bin) && goto mn_snb
if /I %ec%==10 (set mc1=1155\cpu000306A9_plat12_ver00000010_date20-02-2012.bin) && goto mn_snb
if /I %ec%==12 (set mc1=1155\cpu000306A9_plat12_ver00000012_date12-04-2012.bin) && goto mn_snb
if /I %ec%==13 (set mc1=1155\cpu000306A9_plat12_ver00000013_date16-07-2012.bin) && goto mn_snb
if /I %ec%==15 (set mc1=1155\cpu000306A9_plat12_ver00000015_date07-08-2012.bin) && goto mn_snb
if /I %ec%==16 (set mc1=1155\cpu000306A9_plat12_ver00000016_date30-10-2012.bin) && goto mn_snb
if /I %ec%==17 (set mc1=1155\cpu000306A9_plat12_ver00000017_date09-01-2013.bin) && goto mn_snb
if /I %ec%==19 (set mc1=1155\cpu000306A9_plat12_ver00000019_date13-06-2013.bin) && goto mn_snb
if /I %ec%==1A (set mc1=1155\cpu000306A9_plat12_ver0000001A_date06-12-2013.bin) && goto mn_snb
if /I %ec%==1B (set mc1=1155\cpu000306A9_plat12_ver0000001B_date29-05-2014.bin) && goto mn_snb
if /I %ec%==1C (set mc1=1155\cpu000306a9_plat12_ver0000001C_date26-02-2015.bin) && goto mn_snb
if /I %ec%==1F (set mc1=1155\cpu306A9_plat12_ver0000001F_2018-02-07_PRD_3023E347.bin) && goto mn_snb
if /I %ec%==0 goto mn_snb
goto mn1

:mn_snb
set ec=
echo.
echo		Select Microcode for CPU SandyBridge (LGA1155)
echo.
echo 	 5 Version  5 Date 08-09-2010
echo 	 6 Version  6 Date 15-09-2010
echo 	 9 Version  9 Date 28-10-2010
echo 	0C Version 0C Date 17-11-2010
echo 	0D Version 0D Date 81-11-2010
echo 	12 Version 12 Date 28-12-2010
echo 	14 Version 14 Date 06-01-2011
echo 	15 Version 15 Date 23-02-2011
echo 	17 Version 17 Date 07-04-2011
echo 	18 Version 18 Date 18-05-2011
echo 	1A Version 1A Date 21-06-2011
echo 	1B Version 1B Date 14-07-2011
echo 	23 Version 23 Date 28-08-2011
echo 	25 Version 25 Date 11-10-2011
echo 	26 Version 26 Date 25-01-2012
echo 	28 Version 28 Date 24-04-2012 - Best overclocking
echo 	29 Version 29 Date 12-06-2013
echo 	2D Version 2D Date 07-02-2018
echo 	0  Skip
:mn2
set /p ec=Enter Microcode:
if not defined ec goto mn2

if /I %ec%==5 (set mc2=1155\cpu000206A7_plat12_ver00000005_date08-09-2010.bin) && exit /b
if /I %ec%==6 (set mc2=1155\cpu000206A7_plat12_ver00000006_date15-09-2010.bin) && exit /b
if /I %ec%==9 (set mc2=1155\cpu000206A7_plat12_ver00000009_date28-10-2010.bin) && exit /b
if /I %ec%==0C (set mc2=1155\cpu000206A7_plat12_ver0000000C_date17-11-2010.bin) && exit /b
if /I %ec%==0D (set mc2=1155\cpu000206A7_plat12_ver0000000D_date18-11-2010.bin) && exit /b
if /I %ec%==12 (set mc2=1155\cpu000206A7_plat12_ver00000012_date28-12-2010.bin) && exit /b
if /I %ec%==14 (set mc2=1155\cpu000206A7_plat12_ver00000014_date06-01-2011.bin) && exit /b
if /I %ec%==15 (set mc2=1155\cpu000206A7_plat12_ver00000015_date23-02-2011.bin) && exit /b
if /I %ec%==17 (set mc2=1155\cpu000206A7_plat12_ver00000017_date07-04-2011.bin) && exit /b
if /I %ec%==18 (set mc2=1155\cpu000206A7_plat12_ver00000018_date18-05-2011.bin) && exit /b
if /I %ec%==1A (set mc2=1155\cpu000206A7_plat12_ver0000001A_date21-06-2011.bin) && exit /b
if /I %ec%==1B (set mc2=1155\cpu000206A7_plat12_ver0000001B_date14-07-2011.bin) && exit /b
if /I %ec%==23 (set mc2=1155\cpu000206A7_plat12_ver00000023_date28-08-2011.bin) && exit /b
if /I %ec%==25 (set mc2=1155\cpu000206A7_plat12_ver00000025_date11-10-2011.bin) && exit /b
if /I %ec%==26 (set mc2=1155\cpu000206A7_plat12_ver00000026_date25-01-2012.bin) && exit /b
if /I %ec%==28 (set mc2=1155\cpu000206A7_plat12_ver00000028_date24-04-2012.bin) && exit /b
if /I %ec%==29 (set mc2=1155\cpu000206A7_plat12_ver00000029_date12-06-2013.bin) && exit /b
if /I %ec%==2D (set mc2=1155\cpu206A7_plat12_ver0000002D_2018-02-07_PRD_1BDB79EA.bin) && exit /b
if /I %ec%==0 exit /b
goto mn2
exit /b