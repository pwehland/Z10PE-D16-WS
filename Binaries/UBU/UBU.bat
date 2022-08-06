@echo off
pushd %~dp0
set ubuvers=1.69.17
set ubuup=169

set sds=Modules\sata
set sdv=Modules\vga
set sdl=Modules\lan
set sda=Modules\amd
set udk=Modules\udk2014
set mmt=start /b /min /wait mmtool bios.bin
set mmtt=start /b /min /wait mmtool tmp\bios.tmp

if exist Modules\CPUI rd /s /q Modules\CPUI
if exist ubu%ubuup%_upd*.exe (
	for /f %%f in ('dir ubu%ubuup%_upd*.exe /b') do (
		start /wait %%f -y
		del /f /q %%f
	)
)

for %%i in (MMTool.exe UEFIFind.exe UEFIExtract.exe DrvVer.exe FindVer.exe HexFind.exe mcodefit.exe SetDevID.exe) do (
	if not exist %%i (
		echo ! %%i not found !
		pause
		exit
	)
)

for /f "tokens=*" %%i in ('dir /a-d *.CAP *.ROM *.F?? *.BS? *.0?? *.1?? *.2?? *.3?? *.4?? *.5?? *.6?? *.7?? *.8?? *.9?? *.??0 *.??1 *.??2 *.??3 *.??4 bios.bin /b') do (
 	echo %%i
	set biosname=%%i
	if /I %%i==bios.bin goto rises
 	if /I exist bios.bin del /f /q bios.bin && ren "%%i" bios.bin && goto rises
	if /I not exist bios.bin ren "%%i" bios.bin && goto rises
)

cls
setlocal
for /f "usebackq delims=" %%i in (
	`@"%systemroot%\system32\mshta.exe" "about:<FORM><INPUT type='file' name='qq'></FORM><script>document.forms[0].elements[0].click();var F=document.forms[0].elements[0].value;try {new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).Write(F)};catch (e){};close();</script>" ^
	1^|more`
) do copy "%%i" "%~dp0\bios.bin">nul && set biosname=%%~nxi
if not exist bios.bin goto err
endlocal && set biosname=%biosname%

:rises
title UEFI BIOS Updater v%ubuvers% - %biosname%
set capdel=
uefifind header count 8BA63C4A2377FB48803D578CC1FEC44D bios.bin>nul && UEFIExtract bios.bin 4A3CA68B-7723-48FB-803D-578CC1FEC44D>nul && echo Remove Capsule Header
if exist bios.bin.dump copy /y bios.bin.dump\body.bin "%~dp0\bios.bin">nul

:rise
set veroasm=findver "     OROM Asmedia 106X          - " 41736D65646961203130365820534154412F5041544120436F6E74726F6C6C6572 38 00 6 1 csmcore
set verojmb=findver "     OROM JMicron JMB36x        - " 504349204578707265737320746F2053415441494920484F535420436F6E74726F6C6C657220524F4D 43 00 8 1 csmcore

:mn
cls
if exist tmp (del /f /q tmp\*.*) else (md tmp)
if exist _OROM_in_FFS.txt del /f /q _OROM_in_FFS.txt
set lanir=0
set lanir10=0
set lanie=0
set lanrr=0
set lanre=0
set lanar=0
set lanae=0
set lanbr=0
set lanbe=0
set m1=0
set m2=0
set m3=0
set m4=0
set m5=0
set m6=0
set m7=0
set m8=0
set s=0
set sa=0
set se=0
set arom=0
set aefi=0
set axpt=0
set vi=0
set vas=0
set vam=0
set me=0
set s1150=0
set s1151=0
set s1155=0
set s2011=0
set s2011v3=0
set e7=0
set csm=0
set nvme=0
set asus=0
set caphdr=0
set aa=0
set fit=0
set nmmt=0
echo Scanning BIOS... Please wait...
<nul set /p TmpStr=Define BIOS platform - 
uefifind body count 244649440.......................................................3034 bios.bin>nul && echo AMI Aptio 4 && set aa=4 && goto next
uefifind body count 244649440.......................................................3035 bios.bin>nul && echo AMI Aptio V && set aa=5 && goto next
(uefifind body count 49006E00740065006C00AE004400650073006B0074006F007000200042006F00610072006400 bios.bin>nul ||uefifind body count 49006E00740065006C00........4400650073006B0074006F007000200042006F00610072006400 bios.bin>nul) && echo Intel Desktop Board. Not supported. && goto exit1
uefifind body count 494E5359444548324F>nul bios.bin && echo InsydeH2O. Not supported. && pause && goto exit1
uefifind body count 50686F656E697820534354>nul bios.bin && echo PhoenixSCT. Not supported. && pause && goto exit1
if %aa%==0 echo Unknown && pause && goto exit1
if %aa%==5 hexfind 560065007200730069006F006E00200035 mmtool.exe || echo ! Requires MMTool version 5 ! && pause && exit

:next
uefifind body count 4153555342....24 bios.bin>nul && set asus=1
uefifind header count 89BFF4DA71CE1749B522C89D32FBC59F bios.bin>nul && %mmt% /e DAF4BF89-CE71-4917-B522-C89D32FBC59F tmp\brand.tmp
if exist tmp\brand.tmp findver "Brand " 0000020F02000102030405 17 00 34 1 tmp\brand.tmp
findver "Model " 24424F4F5445464924 14 00 30 1 bios.bin

set brend=Remove ASRock new protection...
if %aa%==5 hexfind 4153526F636B tmp\brand.tmp>nul && for /f %%a in ('uefifind header list AD944D418D99D247BFCD4E882241DE32 bios.bin') do %mmt% /e %%a tmp\asr_prot.tmp && set guid=%%a
if exist tmp\asr_prot.tmp hexfind 1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF tmp\asr_prot.tmp>nul || for %%s in (tmp\asr_prot.tmp) do (
	echo Remove ASRock Protection
	if %%~zs==2092 echo %brend% && %mmt% /r %guid% modules\asrocka5/x99.ffs
	if %%~zs==4140 echo %brend% && %mmt% /r %guid% modules\asrocka5/x100.ffs
)

rem CPU
uefifind header count 728508177F37EF448F4EB09FFF46A070 bios.bin>nul && copy /y bios.bin tmp\bios.tmp>nul
if exist  tmp\bios.tmp (
	:d5cpu
	%mmtt% /e 17088572-377F-44EF-8F4E-B09FFF46A070 tmp\cpuffs.tmp
	hexfind 00F8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF tmp\cpuffs.tmp>nul && %mmtt% /d 17088572-377F-44EF-8F4E-B09FFF46A070 && goto d5cpu
)
if exist tmp\cpuffs.tmp (
	set m7=7
	set scguid=728508177F37EF448F4EB09FFF46A070
	set cguid=17088572-377F-44EF-8F4E-B09FFF46A070
	hexfind 01000000C30603000000000000000000 tmp\cpuffs.tmp>nul && set s1150=1 && goto cpu_pk
	hexfind 01000000510604000000000000000000 tmp\cpuffs.tmp>nul && set s1150=1 && goto cpu_pk
	hexfind 01000000710604000000000000000000 tmp\cpuffs.tmp>nul && set s1150=1 && goto cpu_pk
	hexfind 01000000A90603000000000000000000 tmp\cpuffs.tmp>nul && set s1155=1 && goto cpu_pk
	hexfind 01000000A70602000000000000000000 tmp\cpuffs.tmp>nul && set s1155=1 && goto cpu_pk
	hexfind 01000000E70603000000000000000000 tmp\cpuffs.tmp>nul && set s2011=1 && set e7=1 && goto cpu_pk
	hexfind 01000000D70602000000000000000000 tmp\cpuffs.tmp>nul && set s2011=1 && goto cpu_pk
	hexfind 01000000D30602000000000000000000 tmp\cpuffs.tmp>nul && set s2011=1 && goto cpu_pk
rem New CPU
	hexfind 01000000F20603000000000000000000 tmp\cpuffs.tmp>nul && set s2011v3=1 && goto cpu_pk
	hexfind 01000000E30605000000000000000000 tmp\cpuffs.tmp>nul && set s1151=1 && goto cpu_pk
	goto cpu_pk
)	
uefifind header count 36B27D1956F8244990F8CDF12FB875F3 bios.bin>nul && %mmt% /e 197DB236-F856-4924-90F8-CDF12FB875F3 tmp\cpuffs.tmp
if exist tmp\cpuffs.tmp (
	set m7=7
	set scguid=36B27D1956F8244990F8CDF12FB875F3
	set cguid=197DB236-F856-4924-90F8-CDF12FB875F3
	goto cpu_pk
)

uefifind body count 4147455341 bios.bin>nul || set m7=1

:cpu_pk

uefifind body count 5F4649545F202020..0000000001 bios.bin>nul && set fit=1

for /f "tokens=*" %%a in ('uefifind body list ..2456425420 bios.bin') do if %%a==00000000-0000-0000-0000-000000000000 (echo Found Option ROM VBIOS in PADDING) else (echo Found Option ROM VBIOS in GUID %%a)
for /f "tokens=1" %%a in ('uefifind body list ..2456425420 bios.bin') do (
	if %%a neq 00000000-0000-0000-0000-000000000000 if not exist tmp\OROM_GUID_%%a %mmt% /e %%a tmp\OROM_GUID_%%a
)
for /f "tokens=*" %%a in ('uefifind body list 24506E500102 bios.bin') do if %%a==00000000-0000-0000-0000-000000000000 (echo Found Option ROM in PADDING) else (echo Found Option ROM in GUID %%a)
for /f "tokens=1" %%a in ('uefifind body list 24506E500102 bios.bin') do (
	if %%a neq 00000000-0000-0000-0000-000000000000 if not exist tmp\OROM_GUID_%%a %mmt% /e %%a tmp\OROM_GUID_%%a
)
if %aa%==4 if exist tmp\OROM_GUID_A062CF1F-8473-4AA3-8793-600BC4FFE9A8 del /f /q tmp\OROM_GUID_A062CF1F-8473-4AA3-8793-600BC4FFE9A8 && set mmt1=%mmt% /e A062CF1F-8473-4AA3-8793-600BC4FFE9A8 csmcore
if %aa%==4 if exist tmp\OROM_GUID_365C62BA-05EF-4B2E-A7F7-92C1781AF4F9 del /f /q tmp\OROM_GUID_365C62BA-05EF-4B2E-A7F7-92C1781AF4F9 && set mmt1=%mmt% /e 365C62BA-05EF-4B2E-A7F7-92C1781AF4F9 csmcore
if %aa%==4 if exist tmp\OROM_GUID_9F3A0016-AE55-4288-829D-D22FD344C347 del /f /q tmp\OROM_GUID_9F3A0016-AE55-4288-829D-D22FD344C347 && set mmt1=%mmt% /e 9F3A0016-AE55-4288-829D-D22FD344C347 csmcore
if %aa%==5 if exist tmp\OROM_GUID_A0327FE0-1FDA-4E5B-905D-B510C45A61D0 del /f /q tmp\OROM_GUID_A0327FE0-1FDA-4E5B-905D-B510C45A61D0 && set mmt1=%mmt% /e A0327FE0-1FDA-4E5B-905D-B510C45A61D0 csmcore
%mmt1%
if %errorlevel%==1 echo CSMCORE not present or file BIOS is damaged!
rem && pause && goto exit1
hexfind BA625C36EF052E4BA7F792C1781AF4F9 csmcore>nul && copy /y csmcore csmcore0>nul && goto cpu_pk
if not exist csmcore echo CSMCORE mot foumd>csmcore

if %m7%==7 goto mi
if %m7%==1 goto mi

rem Find
set amdahci=0
echo Extract OROM
hexfind  000210AA5500 csmcore>nul && %mmt% /e /l tmp\55aa.tmp 1002 55aa && hexfind 5043495202109143 tmp\55aa.tmp>nul && set amdahci=4391 && set arom=1
hexfind  000210914300 csmcore>nul && %mmt% /e /l tmp\4391.tmp 1002 4391 && hexfind 5043495202109143 tmp\4391.tmp>nul && set amdahci=4391 && set arom=1
hexfind  000210924300 csmcore>nul && %mmt% /e /l tmp\4392.tmp 1002 4392 && set arom=1
hexfind  000210934300 csmcore>nul && %mmt% /e /l tmp\4393.tmp 1002 4393 && set arom=1
hexfind  002210AA5500 csmcore>nul && %mmt% /e /l tmp\55aa.tmp 1022 55aa && hexfind 5043495222100178 tmp\55aa.tmp>nul && set amdahci=7801 && set arom=1
hexfind  002210017800 csmcore>nul && %mmt% /e /l tmp\7801.tmp 1022 7801 && hexfind 5043495222100178 tmp\7801.tmp>nul && set amdahci=7801 && set arom=1
hexfind  002210027800 csmcore>nul && %mmt% /e /l tmp\7802.tmp 1022 7802 && set arom=1
hexfind  002210037800 csmcore>nul && %mmt% /e /l tmp\7803.tmp 1022 7803 && set arom=1
hexfind  002210038800 csmcore>nul && %mmt% /e /l tmp\RAIDxpt2f10o.tmp 1022 8803 && set axpt=1
hexfind  002210048800 csmcore>nul && %mmt% /e /l tmp\RAIDxpt2f50o.tmp 1022 8804 && set axpt=1
if %arom%==1 set s=2
if %axpt%==1 set s=2

rem AMD AGESA
If %aa%==4 (
	set patt=2455434F44455653
) else (
	set patt=15414745534121
)
for /f "tokens=1" %%b in ('uefifind body list %patt% bios.bin') do (
	if %aa%==4 echo Found EFI AMD Microcode GUID %%b
	%mmt% /e %%b tmp\Agesa.tmp
)
if %aa%==4 for /f "tokens=*" %%v in ('findver "" 21214147455341 7 00 25 1 tmp\Agesa.tmp') do set agesa=%%v
if %aa% neq 4 for /f "tokens=*" %%v in ('findver "" 154147455341 10 00 25 1 tmp\Agesa.tmp') do set agesa=%%v

rem AMD GOP / VBIOS
for /f "tokens=1" %%b in ('uefifind body list 000041004D004400200047004F0050002000..00..00..002000 bios.bin') do (
	echo Found EFI AMD GOP Driver GUID %%b
	%mmt% /e %%b tmp\amdgop_%%b.tmp
	set vam=1
)
for /f "tokens=1" %%b in ('uefifind header list DEE0FF..ECDCBF49910D1B476A851EAF bios.bin') do (
	echo Found OROM-in-EFI AMD VBIOS GUID %%b
	%mmt% /e %%b tmp\vbios_%%b.tmp
	if exist tmp\vbios_%%b.tmp (
		hexfind DEE0FF74ECDCBF49910D1B476A851EAF tmp\vbios_%%b.tmp>nul && hexfind 41544F4D42494F53424B tmp\vbios.tmp>nul && ren tmp\vbios_%%b.tmp vbios74.tmp
		hexfind DEE0FF84ECDCBF49910D1B476A851EAF tmp\vbios_%%b.tmp>nul && hexfind 41544F4D42494F53424B tmp\vbios.tmp>nul && ren tmp\vbios_%%b.tmp vbios84.tmp
	)
)

rem AMD SATA
for /f "tokens=1" %%b in ('uefifind header list 82B368C450450949AD572496141B3F4A bios.bin') do (
	echo Found EFI AMD RAIDx64 GUID %%b
	%mmt% /e %%b tmp\raidx64.tmp
	set s=2 && set sa=1 && set aefi=1
)
for /f "tokens=1" %%b in ('uefifind header list 22E316094037CE31AD62BD172CECCA36 bios.bin') do (
	echo Found EFI AMD RAID Utility GUID %%b
	%mmt% /e %%b tmp\raidutil.tmp
	set s=2 && set sa=1 && set aefi=1
)
for /f "tokens=1" %%b in ('uefifind header list C4CC6701F7D0214FA3EF9E64B7CDCE8B bios.bin') do (
	echo Found EFI AMD SCSI Bus GUID %%b
	%mmt% /e %%b tmp\ScsiBus.tmp
	set s=2 && set sa=1 && set aefi=1
)
for /f "tokens=1" %%b in ('uefifind header list 22E3660A4037CE4CAD62BD172CECCA35 bios.bin') do (
	echo Found EFI AMD SCSI Disk GUID %%b
	%mmt% /e %%b tmp\ScsiDisk.tmp
	set s=2 && set sa=1 && set aefi=1
)
for /f "tokens=1" %%b in ('uefifind header list 22E316094037CE4CAD62BD172CECCA35 bios.bin') do (
	echo Found EFI AMD Hii Database GUID %%b
	%mmt% /e %%b tmp\HiiDatabase.tmp
	set s=2 && set sa=1 && set aefi=1
)
for /f "tokens=1" %%b in ('uefifind body list 41004D0044002D0052004100490044002000530041005300 bios.bin') do (
	echo Found EFI AMD RAIDXpert2 GUID %%b
	%mmt% /e %%b tmp\RAIDxpt2_%%b.tmp
	if exist tmp\RAIDxpt2_%%b.tmp (
		hexfind 632E00004000 tmp\RAIDxpt2_%%b.tmp>nul && ren tmp\RAIDxpt2_%%b.tmp RAIDxpt2f10e.tmp
		hexfind 632E00006300 tmp\RAIDxpt2_%%b.tmp>nul && ren tmp\RAIDxpt2_%%b.tmp RAIDxpt2f50e.tmp
	)
	if exist tmp\RAIDxpt2_%%b.tmp ren tmp\RAIDxpt2_%%b.tmp RAIDxpt2fxxe.tmp
	set s=2
	set sa=1
)

goto ma

:mi
set g2=0
rem Intel GOP
for /f "tokens=1,2" %%b in ('uefifind body list 49006E00740065006C00280052002900200047004F0050002000440072006900760065007200000000 bios.bin') do (
 	if %%b==A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
		%mmt% /e /l "tmp\igop_%%b %%c.tmp" %%b %%c
	) else (
		if %s1150%==0 %mmt% /e %%b tmp\igop_%%b.tmp
		if %s1150%==1 if not exist tmp\igop_*.tmp (%mmt% /e %%b tmp\igop_%%b.tmp) else (%mmt% /e %%b tmp\igop2_%%b.tmp)
	)
	echo Found EFI Intel GOP Driver GUID %%b %%c
	set /a g2+=1
	set vi=1
)


rem GOP ASPEED
for /f "tokens=1,2" %%b in ('uefifind body list 4100530050004500450044002000470072006100700068006900630073002000440072006900760065007200 bios.bin') do (
 	if %%b==A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
		%mmt% /e /l "tmp\astgop_%%b %%c.tmp" %%b %%c
	) else (
		%mmt% /e %%b tmp\astgop_%%b.tmp
	)
	echo Found EFI ASPEED GOP Driver GUID %%b %%c
	set vas=1
)
hexfind 2000031AFF2F csmcore>nul && %mmt% /e /l tmp\gopromast.tmp 1A03 2FFF

rem Intel Sata Driver
set irst=0
for /f "tokens=1,2" %%b in ('uefifind body list 49006E00740065006C00280052002900200052005300540020003100 bios.bin') do (
 	if %%b==A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
		%mmt% /e /l "tmp\irst_%%b %%c.tmp" %%b %%c
	) else (
		%mmt% /e %%b tmp\irst_%%b.tmp
	)
	echo Found EFI Intel Raid Controller GUID %%b %%c
	set s=1
	set se=1
	set irst=1
)
(hexfind 52617069642053746F7261676520546563686E6F6C6F6779202D csmcore>nul || hexfind 4D61747269782053746F72616765204D616E61676572206F csmcore>nul) && set irst=1

rem IRSTe
set irste=0
for /f "tokens=1,2" %%b in ('uefifind body list 49006E00740065006C00200052005300540065002000 bios.bin') do (
 	if %%b==A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
		%mmt% /e /l "tmp\irst_%%b %%c.tmp" %%b %%c
	) else (
		%mmt% /e %%b tmp\irst_%%b.tmp
	)
	echo Found EFI Intel Ent Raid Controller GUID %%b %%c
	set s=1
	set se=1
	set irste=1
)
hexfind 496E74656C2852292052414944 csmcore>nul && set s=1
hexfind 52617069642053746F7261676520546563686E6F6C6F67792065 csmcore>nul && set irste=1
hexfind  008680AA55 csmcore>nul && %mmt% /e /l tmp\55aa.tmp 8086 55aa

rem iNVMe
for /f "tokens=1,2" %%b in ('uefifind body list 20004E0056004D006500200055004500460049002000440072006900760065007200 bios.bin') do (
 	if %%b==A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
		%mmt% /e /l "tmp\nvme_%%b %%c.tmp" %%b %%c
	) else (
		%mmt% /e %%b tmp\nvme_%%b.tmp
	)
	echo Found EFI Intel RST NVMe Driver GUID %%b %%c
	set s=1
	set nvme=1
)
rem aNVMe
for /f %%b in ('uefifind body list 41004D00490020004E0056004D00650020004200550053002000440072006900760065007200 bios.bin') do (
	set nvme=2
	echo Found EFI AMI NVMe Driver GUID %%b
)
rem ctNVMe
for /f %%b in ('uefifind body list 4E0056004D0020004500780070007200650073007300200044007200690076006500720000004E0056004D0020004500780070007200650073007300200043006F006E00740072006F006C006C00650072000000 bios.bin') do (
	set nvme=3
	echo Found EFI Clover Team NVMe Driver GUID %%b
)

:ma
rem OROM Intel
set bacl=0
set bage=0
for /f "eol=; tokens=1" %%f in (%sdl%\DevID_List_iCL.txt) do (
	if %aa%==4 hexfind 008680%%f00 csmcore>nul && set bacl=1 && set m3=3
	if %aa%==5 hexfind 504349528680%%f csmcore>nul && set bacl=1 && set m3=3
)
for /f "eol=; tokens=1" %%f in (%sdl%\DevID_List_iGE.txt) do (
	if %aa%==4 hexfind 008680%%f00 csmcore>nul && set bage=1 && set m3=3
	if %aa%==5 hexfind 504349528680%%f csmcore>nul && set bage=1 && set m3=3
)

rem LAN Intel PRO/1000
set lani1Gp6=0
for /f "tokens=1,2" %%b in ('uefifind body list 49006E00740065006C0028005200290020003100470062004500200044004500560020002500 bios.bin') do (
 	if %%b==A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
		%mmt% /e /l "tmp\lani_%%b %%c.tmp" %%b %%c
	) else (
		%mmt% /e %%b tmp\lani_%%b.tmp
	)
	echo Found EFI Intel LAN PRO/1000 Undi GUID %%b %%c
	set lanie=1
	set lani1Gp6=1
	set m3=3
)
set lani1Gp=0
for /f "tokens=1,2" %%b in ('uefifind body list 49006E00740065006C002800520029002000500052004F002F00310030003000300020002500 bios.bin') do (
 	if %%b==A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
		%mmt% /e /l "tmp\lani_%%b %%c.tmp" %%b %%c
	) else (
		%mmt% /e %%b tmp\lani_%%b.tmp
	)
	echo Found EFI Intel LAN PRO/1000 Undi GUID %%b %%c
	set lanie=1
	set lani1Gp=1
	set m3=3
)

rem LAN Intel PRO/1000 old
set lani1Gpo=0
if %lani1Gp%==0 for /f "tokens=1,2" %%b in ('uefifind body list 0020005000430049002D00450020002000000000000000000049006E00740065006C002800520029002000..00..00..00..00..00..00..00..002000 bios.bin') do (
 	if %%b==A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
		%mmt% /e /l "tmp\lani_%%b %%c.tmp" %%b %%c
	) else (
		%mmt% /e %%b tmp\lani_%%b.tmp
	)
	echo Found EFI Intel LAN PRO/1000 Undi GUID %%b %%c
	set lanie=1
	set lani1Gpo=1
	set m3=3
)
rem LAN Intel Gigabit
set lani1Gg=0
for /f "tokens=1,2" %%b in ('uefifind body list 49006E00740065006C002800520029002000470069006700610062006900740020002500 bios.bin') do (
 	if %%b==A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
		%mmt% /e /l "tmp\lani_%%b %%c.tmp" %%b %%c
	) else (
		%mmt% /e %%b tmp\lani_%%b.tmp
	)
	echo Found EFI Intel LAN Gigabit Undi GUID %%b %%c
	set lanie=1
	set lani1Gg=1
	set m3=3
)
rem LAN Intel 10Gb
set lani10G=0
for /f "tokens=1,2" %%b in ('uefifind body list 49006E00740065006C00280052002900200031003000470062004500200044007200690076006500720020002500 bios.bin') do (
 	if %%b==A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
		%mmt% /e /l "tmp\lani_%%b %%c.tmp" %%b %%c
	) else (
		%mmt% /e %%b tmp\lani_%%b.tmp
	)
	echo Found EFI Intel LAN 10Gb Undi GUID %%b %%c
	set lanie=1
	set lani10G=1
	set m3=3
)

rem LAN Realtek
for /f "tokens=1,2" %%b in ('uefifind body list 00005200650061006C00740065006B0020005500450046004900200055004E004400490020004400720069007600650072000000 bios.bin') do (
 	if %%b==A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
		%mmt% /e /l "tmp\lanr_%%b %%c.tmp" %%b %%c
	) else (
		%mmt% /e %%b tmp\lanr_%%b.tmp
	)
	echo Found EFI Realtek LAN Undi GUID %%b %%c
	set lanre=1
	set m3=3
)
set lanro=0 & uefifind body count 50434952EC106881 bios.bin>nul && set lanro=1

rem LAN Broadcom
for /f "tokens=1,2" %%b in ('uefifind body list 0000420072006F006100640063006F006D0020004E006500740058007400720065006D006500200047006900670061006200690074002000450074006800650072006E00650074002000 bios.bin') do (
 	if %%b==A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
		%mmt% /e /l "tmp\lanb_%%b %%c.tmp" %%b %%c
	) else (
		%mmt% /e %%b tmp\lanb_%%b.tmp
	)
	echo Found EFI Broadcomm LAN Undi GUID %%b %%c
	set lanbe=1
	set m3=3
)

rem MaRV_SCSI
for /f "tokens=1,2" %%b in ('uefifind body list 00004D0061007200760065006C006C00200053004300530049002000440072006900760065007200 bios.bin') do (
 	if %%b==A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
		%mmt% /e /l "tmp\mrvs_%%b %%c.tmp" %%b %%c
	) else (
		%mmt% /e %%b tmp\mrvs_%%b.tmp
	)
	echo Found EFI Marvell AHCI Comtroller GUID %%b %%c
	set me=1
)
rem MaRV_RAID
for /f "tokens=1,2" %%b in ('uefifind body list 00004D0061007200760065006C006C00200052004100490044002000440072006900760065007200 bios.bin') do (
 	if %%b==A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
		%mmt% /e /l "tmp\mrvr_%%b %%c.tmp" %%b %%c
	) else (
		%mmt% /e %%b tmp\mrvr_%%b.tmp
	)
	echo Found EFI Marvell RAID Comtroller GUID %%b %%c
	set me=1
)

hexfind 560065007200730069006F006E00200035002E00300032002E0030003000320034 mmtool.exe>nul && set nmmt=1

if %aa%==5 (
	echo;
	echo  This BIOS on Aptio V platform, known issues:
	if %nmmt% neq 1 echo   - It is not supported by the update files in the GUID A0327FE0-1FDA-4E5B-905D-B510C45A61D0
	echo   - There may be problems with updating the CPU microcode
	echo;
)
pause

:mn1
set fefi=
cls
set enter=
echo;
echo;
echo		Select option for update
echo;
if %s%==1 (
	set m1=11
	echo 1 - Intel RST(e^) OROM and EFI SataDriver
	call :irstd
	if %aa%==4 if %se%==0 echo      EFI IRST RAID 	        - Not present
	if %nvme%==2 echo      EFI AMI NVME Driver present
	if %nvme%==3 echo      EFI Clover Team NVME Driver present
)

if %s%==2 (
 	set m1=12
	echo 1 - AMD OROM and EFI Nodules
	call :amdd
	if %sa%==0 echo      EFI AMD RAID 	        - Not present
)

if %vi%==1 goto vb1
hexfind 2456425420 csmcore>nul
if not errorlevel 1 (
	:vb1
	set m2=21
	echo 2 - Intel OROM VBIOS and EFI GOP Driver
	call :videod
	if %vi%==0 echo      EFI GOP Driver		- Not present
)

if %vas%==1 goto vb2
hexfind 41535045454420546563686E6F6C6F6779 csmcore>nul
if not errorlevel 1 (
	:vb2
	echo   ASPEED OROM VBIOS and EFI GOP Driver
	findver "     OROM VBIOS ASPEED          - " 004153542047505500 9 00 7 2 csmcore
	if exist tmp\ASTGop*.tmp for /f "tokens=*" %%b in ('dir tmp\ASTGop*.tmp /b') do drvver "tmp\%%b"
)

if %m7%==0 if %vam%==1 set m2=22 && goto vb3
hexfind 41544F4D42494F53424B csmcore>nul
if not errorlevel 1 if %m7%==0 (
	:vb3
	echo 2 - AMD OROM VBIOS and EFI GOP Driver
	call :avideod
)

if %m3%==3 goto mlan
hexfind 426F6F74204167656E74 csmcore>nul || hexfind 496E74656C20554E4449 csmcore>nul
if not errorlevel 1 (
	:mlan
	echo 3 - LAN OROM PXE and EFI UNDI - Intel, RTK, BCM, QCA
	call :inlver
	call :rtkver
	call :qcaver
	call :bcmver
)

hexfind 41736D656469612031303658 csmcore>nul
if not errorlevel 1 (
	set m4=4
	echo 4 - AsMedia SATA Option ROM
	%veroasm%
)
if %me%==1 goto mm1
hexfind 4D617276656C6C2038385345 csmcore>nul
if not errorlevel 1 (
	:mm1
	set m5=5
	echo 5 - Marvell SATA Option ROM and EFI
	call :mrvlver
)

hexfind 4A4D6963726F6E csmcore>nul
if not errorlevel 1 (
	set m6=6
	echo 6 - JMicron SATA Option ROM
	%verojmb%
)

echo 7 - CPU MicroCode
if exist tmp\cpuffs.tmp (
	echo      View/Extract/Search/Update
)else (
	echo      View/Extract/Search
)

if exist "tmp\OROM_GUID_*" (
	set m8=8
	echo 8 - Other Option ROM in FFS
)
)
echo i - Versions, HomePages, Donate
echo 0 - Exit
echo Press ENTER - Re-Scanning ALL EFI modules.
echo;
set /p enter=Enter number:
if not defined enter goto mn
if /I %enter%==i (start Modules\Info.mht) && goto mn1
if %enter%==1 if %m1%==11 goto isata
if %aa%==4 if %enter%==1 if %m1%==12 goto asata
if %enter%==2 if %m2%==21 goto video
if %aa%==4 if %enter%==2 if %m2%==22 goto videa
if %enter%==3 goto lan
if %aa%==4 if %enter%==4 if %m4%==4 goto asm
if %enter%==5 if %m5%==5 goto marv
if %aa%==4 if %enter%==6 if %m6%==6 goto jmb
if %enter%==7 goto cpu
if %enter%==8 if %m8%==8 goto rg
if %enter%==0 goto exit
goto mn1

:isata
set uirst=0
set urd=
set uro=
set uey=0
set ury=0
set userefi=Modules\irst\User\RaidDriver.efi
set userrom=Modules\irst\User\SataOrom.bin
if exist %userefi% hexfind 49006E00740065006C00280052002900200052005300540020003100 %userefi%>nul && set uey=1 && set uirst=1 && for /f "tokens=7" %%l in ('drvver %userefi%') do set urd=EFI v%%l
if exist %userrom% hexfind 5043495286802228 %userrom%>nul && set ury=1 && set uirst=1 && for /f "tokens=1" %%l in ('findver "" 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F6779202D204F7074696F6E20524F4D 49 0A 12 2 %userrom%') do set uro=OROM v%%l

:rst
set ec=
if %irst%==0 goto rste

echo;
echo 	Intel RST OROM and EFI SataDriver
echo;
echo 1 - Update to v11.2.0.1527 only OROM
echo 2 - Update to v11.6.0.1702
echo 3 - Update to v12.9.0.2006
echo 4 - Update to v13.1.0.2126
echo 5 - Update to v13.2.2.2224/13.2.0.2134
echo 6 - Update to v13.5.0.2164
echo 7 - Update to v14.8.2.2397
echo 8 - Update to v15.1.0.2545
if %s1151%==1 echo 9 - Update to v16.3.0.3377
if %uirst%==1 echo U - Update to %urd%%uro%
if %irste%==1 echo E - Goto Update IRSTe/SCU
if %s1155%==1 echo T - IRST TRIM-in-RAID0 Addon for Intel 6-Series motherboards
if %s2011%==1 echo T - IRST TRIM-in-RAID0 Addon for Intel X79s motherboards
echo 0 - Exit to Main Menu
echo;
:rst1
set /p ec=Enter number:
if not defined ec goto rst1
if %ec%==1 (set v=Modules\irst\11_2) && goto oprom
if %ec%==2 (set v=Modules\irst\11_6) && goto prcs
if %ec%==3 (set v=Modules\irst\12_9) && goto prcs
if %ec%==4 (set v=Modules\irst\13_1) && goto prcs
if %ec%==5 (set v=Modules\irst\13_2) && goto prcs
if %ec%==6 (set v=Modules\irst\13_5) && goto prcs
if %ec%==7 (set v=Modules\irst\14_8) && goto prcs
if %ec%==8 (set v=Modules\irst\15_1) && goto prcs
if %s1151%==1 if %ec%==9 (set v=Modules\irst\16_x) && goto prcs
if %uirst%==1 if /I %ec%==u (set v=Modules\irst\User) && goto prcsu
if %s1155%==1 if /I %ec%==t goto sata_trim
if %s2011%==1 if /I %ec%==t goto sata_trim
if %s2011%==1 if /I  %ec%==e goto rste
if %ec%==0 goto mn1
goto rst1

:sata_trim
set ec=
echo;
echo 	Intel RST OROM and EFI SataDriver
echo 	TRIM-in-RAID0 For Intel 6-Series and X79 motherboards
echo;
echo 1 - Update to v11.2.0.1527 TRIM-in-RAID0 (OROM only)
echo 2 - Update to v11.6.0.1702 TRIM-in-RAID0
echo 3 - Update to v12.7.5.1988 TRIM-in-RAID0
echo 4 - Update to v12.9.0.2006 TRIM-in-RAID0
echo 0 - Exit to Main Menu
echo;
:rstt
set /p ec=Enter number:
if not defined ec goto rstt
if %ec%==1 (set v=Modules\irst\TRIM6\11_2) && goto oprom
if %ec%==2 (set v=Modules\irst\TRIM6\11_6) && goto prcs
if %ec%==3 (set v=Modules\irst\TRIM6\12_7) && goto prcs
if %ec%==4 (set v=Modules\irst\TRIM6\12_9) && goto prcs
if %ec%==0 goto mn1
goto rstt

:prcsu
if %uey%==0 goto opromu
:prcs
set brend=Intel SataDriver
set fefi=%v%\raiddriver.efi
set depx=0
for /f "tokens=1" %%a in ('uefifind body list 49006E00740065006C00280052002900200052005300540020003100 bios.bin') do (
if %%a neq A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
	hexfind 16000013027C75D59906D9E0118D788DE44824019B08 tmp\irst_%%a.tmp>nul && set depx=Modules\irst\depex.sct
	hexfind 16000013028047E2AE1145234FA028EB8204D4829C08 tmp\irst_%%a.tmp>nul && set depx=Modules\irst\depex1.sct
	set vers=Modules\irst\version.sct
	set brend=Intel RAID Driver
	set ui=RaidDriver
	set eguid=%%a
	set guid=%%a
	set ftmp=tmp\irst_%%a.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
) else (
	echo Sorry. GUID %%a not supported.
)
)
if %aa%==5 goto irstwa5

:opromu
if /I %ec%==u if %ury%==0 goto irstwa5
:oprom
set brend=Intel RST
(hexfind 0086802228 csmcore>nul || hexfind A086802228 csmcore>nul) && set did=2822 && set romf=%v%\sataorom.bin 8086 2822 && call :romu
(hexfind 0086802a28 csmcore>nul || hexfind A086802a28 csmcore>nul) && set did=282a && set romf=%v%\sataorom.bin 8086 282a && call :romu
if exist tmp\55aa.tmp hexfind 5043495286802228 tmp\55aa.tmp>nul && set did=55aa && set romf=%v%\sataorom.bin 8086 55aa && call :romu

:irstwa5
if %aa%==5 if %nmmt%==1 for /f "tokens=1,2" %%a in ('uefifind body list 5043495286802228 bios.bin') do (
	set subguid=%%b
	if defined subguid (
		set fefi=%v%\sataorom.bin
		set oguid=%%a %%b
		set brend=OROM Intel RST
		call :romu5e
	)
)

(hexfind 656E7465727072697365202D2053415441 csmcore>nul && goto rste) || goto sataend

:rste
set ec=
echo;
echo 	Intel RSTe OROM and EFI SataDriver
echo;
echo   Optimal for X79
echo 1 - Update to v3.8.0.1029 SATA and SCU
echo   Optimal for X99
echo 2 - Update to v4.6.0.1018 SATA 4.5.0.1018 sSATA/v4.3.0.1018 SCU
echo   Optimal for X299
echo 3 - Update to v5.0.0.1139/5.1.0.1007 SATA/5.0.0.1075/5.0.0.1217 sSATA
echo 0 - Skip
echo;
:rste1
set /p ec=Enter number:
if not defined ec goto rste1
if %ec%==1 (set v=Modules\irst\3_8) && goto prcse
if %ec%==2 (set v=Modules\irst\4_x) && goto prcse
if %ec%==3 (set v=Modules\irst\5_x) && goto prcse
if %ec%==0 goto sataend
goto rste1

:prcse
set fefi=%v%\raiddriver.efi
set depx=0
for /f "tokens=1" %%a in ('uefifind body list 49006E00740065006C00200052005300540065002000..002E00..002E00..002E00..00..00..00..00200053004100 bios.bin') do (
if %%a neq A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
	hexfind 16000013027C75D59906D9E0118D788DE44824019B08 tmp\irst_%%a.tmp>nul && set depx=Modules\irst\depex.sct
	hexfind 16000013028047E2AE1145234FA028EB8204D4829C08 tmp\irst_%%a.tmp>nul && set depx=Modules\irst\depex1.sct
	set vers=Modules\irst\version.sct
	set brend=Intel Ent RAID Driver
	set ui=RaidEntDriver
	set eguid=%%a
	set guid=%%a
	set ftmp=tmp\irst_%%a.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
) else (
	echo Sorry. GUID %%a not supported.
)
)
set fefi=%v%\scudriver.efi
set depx=0
for /f "tokens=1" %%a in ('uefifind body list 49006E00740065006C00200052005300540065002000..002E00..002E00..002E00..00..00..00..00200053004300 bios.bin') do (
if %%a neq A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
	hexfind 16000013027C75D59906D9E0118D788DE44824019B08 tmp\irst_%%a.tmp>nul && set depx=Modules\irst\depex.sct
	hexfind 16000013028047E2AE1145234FA028EB8204D4829C08 tmp\irst_%%a.tmp>nul && set depx=Modules\irst\depex1.sct
	set vers=Modules\irst\version.sct
	set brend=Intel SCU Driver
	set ui=SCUDriver
	set eguid=%%a
	set guid=%%a
	set ftmp=tmp\irst_%%a.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
) else (
	echo Sorry. GUID %%a not supported.
)
)
set fefi=%v%\ssatadriver.efi
set depx=0
for /f "tokens=1" %%a in ('uefifind body list 49006E00740065006C00200052005300540065002000..002E00..002E00..002E00..00..00..00..00200073005300 bios.bin') do (
if %%a neq A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
	hexfind 16000013027C75D59906D9E0118D788DE44824019B08 tmp\irst_%%a.tmp>nul && set depx=Modules\irst\depex.sct
	hexfind 16000013028047E2AE1145234FA028EB8204D4829C08 tmp\irst_%%a.tmp>nul && set depx=Modules\irst\depex1.sct
	set vers=Modules\irst\version.sct
	set brend=Intel sSATA Driver
	set ui=sSATADriver
	set eguid=%%a
	set guid=%%a
	set ftmp=tmp\irst_%%a.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
) else (
	echo Sorry. GUID %%a not supported.
)
)
if %aa%==5 goto sataend

set brend=Intel RSTe
(hexfind 0086802628 csmcore>nul || hexfind A086802628 csmcore>nul) && set did=2826 && set romf=%v%\sataorom.bin 8086 2826 && call :romu
set brend=Intel RSTe SCU
(hexfind 008680681D csmcore>nul || hexfind A08680681D csmcore>nul) && set did=1d68 && set romf=%v%\scuorom.bin 8086 1d68 && call :romu
(hexfind 008680691D csmcore>nul || hexfind A08680691D csmcore>nul) && set did=1d69 && set romf=%v%\scuorom.bin 8086 1d69 && call :romu

:sataend
echo;
%mmt1%
call :irstd
pause
goto mn1

:asata
for /f "tokens=1" %%l in ('findver "" 414D442041484349 22 00 10 1 %sda%\439x\4391a.bin') do set amda4=%%l
for /f "tokens=1" %%l in ('findver "" 414D442041484349 22 00 10 1 %sda%\780x\7801a.bin') do set amda7=%%l
for /f "tokens=1" %%l in ('findver "" 55AA 10 00 12 1 %sda%\439x\4392r.bin') do set amdr4392=%%l
for /f "tokens=1" %%l in ('findver "" 55AA 10 00 12 1 %sda%\439x\4393r.bin') do set amdr4393=%%l
for /f "tokens=1" %%l in ('findver "" 55AA 10 00 12 1 %sda%\780x\7802r.bin') do set amdr7802=%%l
for /f "tokens=1" %%l in ('findver "" 55AA 10 00 12 1 %sda%\780x\7803r.bin') do set amdr7803=%%l
for /f "tokens=1" %%l in ('findver "" 5243424E42474E 8 00 12 1 %sda%\Xpert_6\RAID_F10.bin') do set amdxpt2o_6=%%l
for /f "tokens=1" %%l in ('findver "" 5243424E42474E 8 00 12 1 %sda%\Xpert_7\RAID_F10.bin') do set amdxpt2o_7=%%l

set amdru=1.0.0.49
set amdxpt2e_6=6.1.4-00059
set amdxpt2e_7=7.2.0-00043

:as
set ec=
echo;
echo 	AMD OROM and EFI Nodules
echo;

if %arom%==1 if %amdahci%==0 if exist tmp\7802.tmp (
	echo 1 - Update 7802 to v%amdr7802% / 7803 to v%amdr7803% RAID OROM
) else (
	echo 1 - Update 4392 to v%amdr4392% / 4393 to v%amdr4393% RAID OROM
)
if %arom%==1 if %amdahci%==4391 echo 1 - Update to v%amda4% AHCI / v%amdr4392% RAID OROM
if %arom%==1 if %amdahci%==7801 echo 1 - Update to v%amda7% AHCI / v%amdr7802%/v%amdr7803% RAID OROM

if %aefi%==1 echo 2 - Update to v%amdru% RAID and Utilites EFI

if %axpt%==1 echo 3 - Update to v%amdxpt2o_6% RAIDXpert2 F10/F50 OROM
if %axpt%==1 echo 4 - Update to v%amdxpt2e_6% RAIDXpert2 F10/F50 EFI

if %axpt%==1 echo 5 - Update to v%amdxpt2o_7% RAIDXpert2 F10/F50 OROM
if %axpt%==1 echo 6 - Update to v%amdxpt2e_7% RAIDXpert2 F10/F50 EFI

echo 7 - Update all modules
echo 0 - Exit Main Menu
echo;
:as1
set /p ec=Enter number:
if not defined ec goto as1
if %arom%==1 if %ec%==1 goto samd1
if %aefi%==1 if %ec%==2 goto samde
if %axpt%==1 if %ec%==3 goto samdxo_6
if %axpt%==1 if %ec%==4 goto samdxe_6
if %axpt%==1 if %ec%==5 goto samdxo_7
if %axpt%==1 if %ec%==6 goto samdxe_7
if %axpt%==0 if %ec%==7 goto samd1
if %axpt%==1 if %ec%==7 goto samd
if %ec%==0 goto mn1
goto as1

:samd
set cxprt=0
set ec2=
echo;
echo 1 - Update RAIDXpert2 to version 6
echo 2 - Update RAIDXpert2 to version 7
echo 0 - No update
echo;
:acx2
set /p ec2=Enter number:
if not defined ec2 goto acx2

if %ec2%==1 (set cxprt=6) && goto samd1
if %ec2%==2 (set cxprt=7) && goto samd1
if %ec2%==0 goto samd1
goto acx2

:samd1
set M4392=0
set M4393=0
set M7802=0
set M7803=0

set brend=AND AHCI
if exist tmp\55aa.tmp hexfind 5043495202109143 tmp\55aa.tmp>nul && set did=4391 && set romf=%sda%\439x\4391a.bin 1002 55AA && call :romu && %mmt% /e /l tmp\55aa.tmp 1002 55AA
if exist tmp\4391.tmp hexfind 5043495202109143 tmp\4391.tmp>nul && set did=4391 && set romf=%sda%\439x\4391a.bin 1002 4391 && call :romu && %mmt% /e /l tmp\4391.tmp 1002 4391
if exist tmp\55aa.tmp hexfind 5043495222100178 tmp\55aa.tmp>nul && set did=7801 && set romf=%sda%\780x\7801a.bin 1022 55AA && call :romu && %mmt% /e /l tmp\55aa.tmp 1022 55AA
if exist tmp\7801.tmp hexfind 5043495222100178 tmp\7801.tmp>nul && set did=7801 && set romf=%sda%\780x\7801a.bin 1022 7801 && call :romu && %mmt% /e /l tmp\7801.tmp 1022 7801

set brend=AND RAID
if exist tmp\4392.tmp hexfind 5043495202109243 tmp\4392.tmp>nul && set M4392=1 && set did=4392 && set romf=%sda%\439x\4392r.bin 1002 4392 && call :romu && %mmt% /e /l tmp\4392.tmp 1002 4392
if %asus%==1 (set guid=9BD5C81D-096C-4625-A08B-405F78FE0CFD) else (set guid=9BD5C81D-096C-4625-A08B-405F78FE0CFC)
if exist tmp\ffs*.tmp>nul del /f /q tmp\ffs*.tmp
set brend=AMD MISC 4392
if %M4392%==1 (
	set eguid=%guid%
	<nul set /p TmpStr=* Generate FFS %brend% GUID %guid% ...
	%udk%\GenSec -s EFI_SECTION_RAW %sda%\439x\4392m.bin -o tmp\ffsraw.tmp
	(%udk%\GenFFS -s -t EFI_FV_FILETYPE_FREEFORM -g %guid% -i tmp\ffsraw.tmp -o tmp\ffsfile.tmp && echo Ok!) || echo Error!
	set ftmp=0
	set ffs=tmp\ffsfile.tmp
	call :ffsu
)
set brend=AND RAID
if exist tmp\4393.tmp hexfind 5043495202109343 tmp\4393.tmp>nul && set M4393=1 && set did=4393 && set romf=%sda%\439x\4393r.bin 1002 4393 && call :romu && %mmt% /e /l tmp\4393.tmp 1002 4393
if %asus%==1 (set guid=9BD5C81D-096C-4625-A08B-405F78FE0CFC) else (set guid=9BD5C81D-096C-4625-A08B-405F78FE0CFD)
if exist tmp\ffs*.tmp>nul del /f /q tmp\ffs*.tmp
set brend=AMD MISC 4393
if %M4393%==1 (
	set eguid=%guid%
	<nul set /p TmpStr=* Generate FFS %brend% GUID %guid% ...
	%udk%\GenSec -s EFI_SECTION_RAW %sda%\439x\4393m.bin -o tmp\ffsraw.tmp
	(%udk%\GenFFS -s -t EFI_FV_FILETYPE_FREEFORM -g %guid% -i tmp\ffsraw.tmp -o tmp\ffsfile.tmp && echo Ok!) || echo Error!
	set ftmp=0
	set ffs=tmp\ffsfile.tmp
	call :ffsu
)
set brend=AND RAID
if exist tmp\7802.tmp hexfind 5043495222100278 tmp\7802.tmp>nul && set M7802=1 && set did=7802 && set romf=%sda%\780x\7802r.bin 1022 7802 && call :romu && %mmt% /e /l tmp\7802.tmp 1022 7802
set guid=9BD5C81D-096C-4625-A08B-405F78FE0CFC
if exist tmp\ffs*.tmp>nul del /f /q tmp\ffs*.tmp
set brend=AMD MISC 7802
if %M7802%==1 (
	set eguid=%guid%
	<nul set /p TmpStr=* Generate FFS %brend% GUID %guid% ...
	%udk%\GenSec -s EFI_SECTION_RAW %sda%\780x\7802m.bin -o tmp\ffsraw.tmp
	(%udk%\GenFFS -s -t EFI_FV_FILETYPE_FREEFORM -g %guid% -i tmp\ffsraw.tmp -o tmp\ffsfile.tmp && echo Ok!) || echo Error!
	set ftmp=0
	set ffs=tmp\ffsfile.tmp
	call :ffsu
)
set brend=AND RAID
if exist tmp\7803.tmp hexfind 5043495222100378 tmp\7803.tmp>nul && set M7803=1 && set did=7803 && set romf=%sda%\780x\7803r.bin 1022 7803 && call :romu && %mmt% /e /l tmp\7803.tmp 1022 7803
set guid=9BD5C81D-096C-4625-A08B-405F78FE0CFD
if exist tmp\ffs*.tmp>nul del /f /q tmp\ffs*.tmp
set brend=AMD MISC 7803
if %M7803%==1 (
	set eguid=%guid%
	<nul set /p TmpStr=* Generate FFS %brend% GUID %guid% ...
	%udk%\GenSec -s EFI_SECTION_RAW %sda%\780x\7803m.bin -o tmp\ffsraw.tmp
	(%udk%\GenFFS -s -t EFI_FV_FILETYPE_FREEFORM -g %guid% -i tmp\ffsraw.tmp -o tmp\ffsfile.tmp && echo Ok!) || echo Error!
	set ftmp=0
	set ffs=tmp\ffsfile.tmp
	call :ffsu
)
if %ec%==1 goto samdend

:samde
if exist tmp\ffs*.tmp>nul del /f /q tmp\ffs*.tmp
set brend=AMD RaidDriver
set guid=C468B382-4550-4909-AD57-2496141B3F4A
set fefi=%sda%\efi\RaidDriver.efi
if exist tmp\raidx64.tmp (
	set eguid=%guid%
	set depx=%sda%\efi\depex.sct
	set ui=AMDRaidDriver
	set ftmp=tmp\raidx64.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
)
if exist tmp\ffs*.tmp>nul del /f /q tmp\ffs*.tmp
set brend=AMD RAID Utility
set guid=0916E322-3740-31CE-AD62-BD172CECCA36
set fefi=%sda%\efi\RaidUtility.efi
if exist tmp\raidutil.tmp (
	set eguid=%guid%
	set depx=%sda%\efi\depex1.sct
	set ui=AMDRaidUtility
	set ftmp=tmp\raidutil.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
)
if exist tmp\ffs*.tmp>nul del /f /q tmp\ffs*.tmp
set brend=AMD SCSI Bus
set guid=0167CCC4-D0F7-4F21-A3EF-9E64B7CDCE8B
set fefi=%sda%\efi\ScsiBus.efi
if exist tmp\ScsiBus.tmp (
	set eguid=%guid%
	set depx=%sda%\efi\depex.sct
	set ui=AMDScsiBus
	set ftmp=tmp\ScsiBus.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
)
if exist tmp\ffs*.tmp>nul del /f /q tmp\ffs*.tmp
set brend=AMD SCSI Disk
set guid=0A66E322-3740-4CCE-AD62-BD172CECCA35
set fefi=%sda%\efi\ScsiDisk.efi
if exist tmp\ScsiDisk.tmp (
	set eguid=%guid%
	set depx=%sda%\efi\depex.sct
	set ui=AMDScsiDisk
	set ftmp=tmp\ScsiDisk.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
)
if exist tmp\ffs*.tmp>nul del /f /q tmp\ffs*.tmp
set brend=AMD Hii Database
set guid=0916E322-3740-4CCE-AD62-BD172CECCA35
set fefi=%sda%\efi\HiiDB.efi
if exist tmp\HiiDatabase.tmp (
	set eguid=%guid%
	set depx=%sda%\efi\depex.sct
	set ui=AMDHiiDataBase
	set ftmp=tmp\HiiDatabase.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
)
if %ec%==2 goto samdend
if %axpt%==0 goto samdend
if %cxprt%==0 goto samdend
if %cxprt%==7 goto samdxo_7

:samdxo_6
set brend=AMD RAIDXpert2 10
if exist tmp\RAIDxpt2f10o.tmp set did=8803 && set romf=%sda%\Xpert_6\raid_f10.bin 1022 8803 && call :romu && %mmt% /e /l tmp\RAIDxpt2f10o.tmp 1022 8803
set brend=AMD RAIDXpert2 F50
if exist tmp\RAIDxpt2f50o.tmp set did=8804 && set romf=%sda%\Xpert_6\raid_f50.bin 1022 8804 && call :romu && %mmt% /e /l tmp\RAIDxpt2f50o.tmp 1022 8804
if %ec%==3 goto samdend

:samdxe_6
if exist tmp\ffs*.tmp>nul del /f /q tmp\ffs*.tmp
set brend=AMD RAIDXpert2 F10
set guid=50965C18-2F65-41A9-9961-BA889EA978D9
set fefi=%sda%\Xpert_6\raid_f10.efi
if exist tmp\RAIDxpt2f10e.tmp (
	set eguid=%guid%
	set depx=%sda%\Xpert_6\dxe10.sct
	set ui=AMDRAIDXpert2F10
	set ftmp=tmp\RAIDxpt2f10e.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
)
if exist tmp\ffs*.tmp>nul del /f /q tmp\ffs*.tmp
set brend=AMD RAIDXpert2 F50
set guid=5CF6CEDE-0DED-4013-9196-F429DE361937
set fefi=%sda%\Xpert_6\raid_f50.efi
if exist tmp\RAIDxpt2f50e.tmp (
	set eguid=%guid%
	set depx=%sda%\Xpert_6\dxe50.sct
	set ui=AMDRAIDXpert2F50
	set ftmp=tmp\RAIDxpt2f50e.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
)
if %ec%==4 goto samdend
if %cxprt%==6 goto samdend

:samdxo_7
set brend=AMD RAIDXpert2 10
if exist tmp\RAIDxpt2f10o.tmp set did=8803 && set romf=%sda%\Xpert_7\raid_f10.bin 1022 8803 && call :romu && %mmt% /e /l tmp\RAIDxpt2f10o.tmp 1022 8803
set brend=AMD RAIDXpert2 F50
if exist tmp\RAIDxpt2f50o.tmp set did=8804 && set romf=%sda%\Xpert_7\raid_f50.bin 1022 8804 && call :romu && %mmt% /e /l tmp\RAIDxpt2f50o.tmp 1022 8804
if %ec%==5 goto samdend

:samdxe_7
if exist tmp\ffs*.tmp>nul del /f /q tmp\ffs*.tmp
set brend=AMD RAIDXpert2 F10
set guid=50965C18-2F65-41A9-9961-BA889EA978D9
set fefi=%sda%\Xpert_7\raid_f10.efi
if exist tmp\RAIDxpt2f10e.tmp (
	set eguid=%guid%
	set depx=%sda%\Xpert_7\dxe10.sct
	set ui=AMDRAIDXpert2F10
	set ftmp=tmp\RAIDxpt2f10e.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
)
if exist tmp\ffs*.tmp>nul del /f /q tmp\ffs*.tmp
set brend=AMD RAIDXpert2 F50
set guid=5CF6CEDE-0DED-4013-9196-F429DE361937
set fefi=%sda%\Xpert_7\raid_f50.efi
if exist tmp\RAIDxpt2f50e.tmp (
	set eguid=%guid%
	set depx=%sda%\Xpert_7\dxe50.sct
	set ui=AMDRAIDXpert2F50
	set ftmp=tmp\RAIDxpt2f50e.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
)

:samdend
echo;
call :amdd
pause
goto mn1

:video
for /f "tokens=6" %%l in ('drvver %sdv%\gop\ihswbdw\IntelGopDriver.efi') do set hswbdwgop=%%l
for /f "tokens=6" %%l in ('drvver %sdv%\gop\iskl\IntelGopDriver.efi') do set sklgop=%%l
if exist %sdv%\vbiossib.dat for /f "tokens=*" %%a in ('findver "v" 245642542053 79 FF 4 1 %sdv%\vbiossib.dat') do set vbiossib=%%a
if exist %sdv%\vbioshsw.dat for /f "tokens=*" %%a in ('findver "v" 245642542048 79 FF 4 1 %sdv%\vbioshsw.dat') do set vbioshsw=%%a
if %s1155%==1 if %vi%==1 set outve=and v2.0.1024/v3.0.1030 EFI GOP Drivers
:is
set ec=
echo;
echo 	Intel OROM VBIOS and EFI GOP Driver
echo;
if %s1155%==1 (
	if %vi%==1 echo 1 - Update to v2.0.1024/v3.0.1030 EFI GOP Drivers ONLY
	if exist %sdv%\vbiossib.dat echo 2 - Update to %vbiossib% OROM %outve%
	if %vi%==0 if not exist %sdv%\vbiossib.dat echo  - No files for updating. && echo;
)
if %s1150%==1 (
	echo 1 - Update to v%hswbdwgop% EFI GOP Driver ONLY
	if exist %sdv%\vbioshsw.dat echo 2 - Update to %vbioshsw% OROM and v%hswbdwgop% EFI GOP Driver
)
if %s1151%==1 (
	echo 1 - Update to v%sklgop% EFI GOP Driver ONLY

rem	if exist %sdv%\vbiosskl.dat echo 2 - Update to %vbiosskl% OROM and v%kslgop% EFI GOP Driver
)

echo 0 - Exit Main Menu
echo;
:is1
set /p ec=Enter number:
if not defined ec goto is1

if %s1155%==1 if %ec%==1 if %vi%==1 goto gop
if %s1155%==1 if %ec%==2 if exist %sdv%\vbiossib.dat (set vb=%sdv%\vbiossib.dat) && goto v1
if %s1150%==1 if %ec%==1 if %vi%==1 goto gop
if %s1150%==1 if %ec%==2 if exist %sdv%\vbioshsw.dat (set vb=%sdv%\vbioshsw.dat) && goto v1
if %s1151%==1 if %ec%==1 if %vi%==1 goto gop
if %ec%==0 goto mn1
goto is1

:v1
if %s1155%==1 (
	set brend=Intel VGA BIOS SandyBridge/IvyBridge
	hexfind 0086800201 csmcore>nul && set did=102 && set romf=%vb% 8086 102 && call :romu
	hexfind 0086806201 csmcore>nul && set did=162 && set romf=%vb% 8086 162 && call :romu
)
if %s1150%==1 (
	set brend=Intel VGA BIOS Haswell/Broadwell
	hexfind 0086800204 csmcore>nul && set did=402 && set romf=%vb% 8086 402 && call :romu
	hexfind 0086801204 csmcore>nul && set did=412 && set romf=%vb% 8086 412 && call :romu
	hexfind 008680020c csmcore>nul && set did=c02 && set romf=%vb% 8086 c02 && call :romu
	hexfind 008680120c csmcore>nul && set did=c12 && set romf=%vb% 8086 c12 && call :romu
)

:gop
rem SANDY/IVY
set fefi=%sdv%\gop\isnb\IntelGopDriver.efi
if %s1155%==1 for /f "tokens=1" %%a in ('uefifind body list 49006E00740065006C002800520029002000530061006E00640079002000420072006900640067006500200047007200610070006800690063007300200043006F006E00740072006F006C006C0065007200 bios.bin') do (
	set depx=0
	set brend=Intel SNB GOP Driver
	set ui=IntelSnbGopDriver
	set eguid=%%a
	set guid=%%a
	set ftmp=tmp\igop_%%a.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
)
set fefi=%sdv%\gop\iivb\IntelGopDriver.efi
if %s1155%==1 for /f "tokens=1" %%a in ('uefifind body list 49006E00740065006C0028005200290020004900760079002000420072006900640067006500200047007200610070006800690063007300200043006F006E00740072006F006C006C0065007200 bios.bin') do (
	set depx=0
	set brend=Intel IVB GOP Driver
	set ui=IntelIvbGopDriver
	set eguid=%%a
	set guid=%%a
	set ftmp=tmp\igop_%%a.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
)

rem HASWELL
set ag=0
if %s1150%==1 if %g2%==2 for /f "tokens=1" %%a in ('uefifind body list 49006E00740065006C00280052002900200047004F0050002000440072006900760065007200000000 bios.bin') do set ag=%%a
if %s1150%==1 if %g2%==2 if %ag% neq 0 %mmt% /r %ag% Modules\mCode\Zero\Z_CPU0.ffs
set fefi=%sdv%\gop\ihswbdw\IntelGopDriver.efi
if %s1150%==1 for /f "tokens=1" %%a in ('uefifind body list 49006E00740065006C00280052002900200047004F0050002000440072006900760065007200000000 bios.bin') do (
	set depx=0
	set brend=Intel HSW/BDW GOP Driver
	set ui=IntelGopDriver
	set eguid=%%a
	set guid=%%a
	set ftmp=tmp\igop_%%a.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
)
if %s1150%==1 if %g2%==2 if %ag% neq 0 (
	%mmt% /r 17088572-0000-0000-0000-000000000001 tmp\ffsfile.tmp
	<nul set /p TmpStr=* Update EFI %brend% GUID %eguid% ...
	%mmt% /e %guid% tmp\igop2_%guid%.tmp
	if %errorlevel%==0 (echo Ok!) else (echo Error!)
)
rem SKYLAKE
set fefi=%sdv%\gop\iskl\IntelGopDriver.efi
if %s1151%==1 for /f "tokens=1,2" %%a in ('uefifind body list 49006E00740065006C00280052002900200047004F0050002000440072006900760065007200000000 bios.bin') do (
if %%a neq A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
	set depx=0
	set brend=Intel Skylake/Kabylake GOP Driver
	set ui=IntelGopDriver
	set eguid=%%a
	set guid=%%a
	set ftmp=tmp\igop_%%a.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
) else (
	del "tmp\igop_%%a %%b.tmp"
	set oguid=%%a %%b
	set brend=Intel Skylake/Kabylake GOP Driver
	call :romu5e
	)
)

set brend=Intel VBT HSW/BDW
set fefi=%sdv%\vbthsw.bin
if %s1150%==1 if exist %sdv%\vbthsw.bin for /f "tokens=1" %%a in ('uefifind all list 00F8245642542048415357454C4C bios.bin') do (
	set eguid=%%a
	set guid=%%a
	<nul set /p TmpStr=* Generate FFS %brend% GUID %%a ...
	(%udk%\GenFFS -s -t EFI_FV_FILETYPE_RAW -g %%a -i %fefi% -o tmp\vbt.tmp && echo Ok!) || echo Error!
	set ftmp=0
	set ffs=tmp\vbt.tmp
	call :ffsu
)

echo;
%mmt1%
call :videod
pause
goto mn1

:videa
for /f "tokens=6" %%l in ('drvver %sdv%\gop\amd\AMDGopDriver.efi') do set amdgop=%%l
set amd74=0
set amd84=0
set ec=
echo;
echo 	AND EFI OROM and GOP Driver
echo;
echo 1 - Update to v%amdgop% EFI GOP Driver
if exist tmp\vbios_74FFE0DE-DCEC-49BF-910D-1B476A851EAF.tmp set amd74=1 && echo     Update AMD Spectre v015.041.000.002.000000 OROM-in-FFS
if exist tmp\vbios_84FFE0DE-DCEC-49BF-910D-1B476A851EAF.tmp (
	hexfind 5472696E697479 tmp\vbios_84FFE0DE-DCEC-49BF-910D-1B476A851EAF.tmp>nul && set amd84=1 && echo     Update AMD Trinity v015.035.000.000.000000 OROM-in-FFS
) else (
	hexfind 4B6162696E6947656E657269 tmp\vbios_84FFE0DE-DCEC-49BF-910D-1B476A851EAF.tmp>nul && set amd84=2 && echo     Update AMD Kalindi v015.033.000.002.000000 OROM-in-FFS
)
echo 0 - Exit to Main Menu
echo;
:amdgop1
set /p ec=Enter number:
if not defined ec goto amdgop1
if %ec%==1 goto gop4
if %ec%==0 goto mn1
goto amdgop1

:gop4
set fefi=%sdv%\gop\AMD\AMDGopDriver.efi
for /f "tokens=1" %%a in ('uefifind body list 000041004D004400200047004F0050002000..00..00..002000 bios.bin') do (
	set depx=%sdv%\gop\AMD\depex.sct
	set brend=AND GOP Driver
	set ui=AMD_GOP
	set eguid=%%a
	set guid=%%a
	set ftmp=tmp\amdgop_%%a.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
)

set brend=AMD OROM-in-FFS
if %amd74%==1 set ftmp=tmp\vbios_74FFE0DE-DCEC-49BF-910D-1B476A851EAF.tmp && set eguid=74FFE0DE- && set guid=74FFE0DE-DCEC-49BF-910D-1B476A851EAF && set ffs=%sdv%\ffs\AMDSpect.ffs && call :ffsu
if %amd84%==1 set ftmp=tmp\vbios_84FFE0DE-DCEC-49BF-910D-1B476A851EAF.tmp && set eguid=84FFE0DE- && set guid=84FFE0DE-DCEC-49BF-910D-1B476A851EAF && set ffs=%sdv%\ffs\AMDTrin.ffs && call :ffsu
if %amd84%==2 set ftmp=tmp\vbios_84FFE0DE-DCEC-49BF-910D-1B476A851EAF.tmp && set eguid=84FFE0DE- && set guid=84FFE0DE-DCEC-49BF-910D-1B476A851EAF && set ffs=%sdv%\ffs\AMDKali.ffs && call :ffsu

echo;
call :avideod
pause
goto mn1

:lan
for /f %%l in ('findver "" 496E74656C28522920426F6F74204167656E74204745 24 00 7 1 %sdl%\IntlOromGE.LOM') do set iloge=%%l
for /f %%l in ('findver "" 496E74656C28522920426F6F74204167656E7420434C 24 00 7 1 %sdl%\IntlOromCL.LOM') do set ilocl=%%l
for /f %%l in ('findver "" 496E74656C28522920426F6F74204167656E74205845 24 00 7 1 %sdl%\IntlOromXE.LOM') do set iloxe=%%l
for /f %%l in ('findver "" 5265616C74656B2050434965204742452046616D696C7920436F6E74726F6C6C657220536572696573 43 20 4 1 %sdl%\rtegpxe.lom') do set rlo=OROM %%l
for /f %%l in ('findver "" 4252434D204D424100536C6F742030303030 20 00 7 1 %sdl%\q57pxee.lom') do set blo=OROM %%l
for /f "tokens=6" %%l in ('drvver %sdl%\efi\IntlGbEUndiX7.efi') do set ilx7e=%%l
for /f "tokens=6" %%l in ('drvver %sdl%\efi\IntlGbEUndiX3.efi') do set ilx3e=%%l
for /f "tokens=6" %%l in ('drvver %sdl%\efi\Intl10GbEUndiX4.efi') do set ilx4e=%%l
for /f "tokens=5" %%l in ('drvver %sdl%\efi\RtkUndiDxe.efi') do set rle=EFI %%l
for /f "tokens=5" %%l in ('drvver %sdl%\efi\b57undix64.efi') do set ble=EFI %%l

:lm
set ec=
echo;
echo 	LAN OROM PXE and EFI UNDI  Intel, Realtek, BCM, QCA
echo;

echo 1 - Update Automatic Mode
if %aa%==4 (
	if %lanir%==1 if %bacl%==1 echo     - OROM LAN Intel BootAgent CL %ilocl%
	if %lanir%==1 if %bage%==1 echo     - OROM LAN Intel BootAgent GE %iloge%
)
if %lanie%==1 (
	if %bacl%==1 if %bage%==0 echo     - EFI LAN Intel Gigabit UNDI v%ilx7e%
	if %bacl%==0 if %bage%==1 echo     - EFI LAN Intel PRO/1000 UNDI v%ilx3e%
	if %aa%==4 if %bacl%==1 if %bage%==1 echo     - EFI LAN Intel PRO/1000 UNDI v6.6.04
	if %aa%==5 if %bacl%==1 if %bage%==1 if %lani1Gg%==1 echo     - EFI LAN Intel Gigabit UNDI v%ilx7e%
	if %aa%==5 if %lani1Gp%==1 echo     - EFI LAN Intel PRO/1000 UNDI v%ilx3e%
)
if %aa%==4 if %lanir10%==1 echo     - OROM LAN Intel 10 GbE v%iloxe%
if %lani10G%==1 echo     - EFI LAN Intel 10 GbE v%ilx4e%
if %lanre%==1 echo     - EFI LAN Realtek UNDI %rle%
if %lanrr%==1 echo     - OROM LAN Realtek %rlo%
if %aa%==4 if %lanar%==1 echo     - OROM LAN QCM-Atheros 2.0.6.6/2.1.1.5
if %aa%==4 if %lanbr%==1 echo     - OROM LAN Broadcom %blo%
if %lanbe%==1 echo     - EFI LAN Broadcom UNDI %ble%

if %lanir%==1 if %aa%==4 (
	echo 2 -  Update Force Mode for Intel
	echo     - OROM LAN Intel BootAgent GE v1.5.62
	if %lanie%==1 echo     - EFI LAN Intel PRO/1000 UNDI v6.6.04
)
if %s2011v3%==1 (
	echo   Update Force Mode for Intel
	echo 2 - For 1 Intel NIC 210/211/350
	echo     - EFI LAN Intel PRO/1000 UNDI v%ilx3e%
	echo 3 - For 2 Intel NIC 82579/217/218+210/211/350
	echo     - EFI LAN Intel PRO/1000 UNDI v6.6.04
)
if %aa%==5 if %lanir%==1 (
	echo C - Create file with Device ID
	if %bacl%==1 echo     - OROM LAN Intel BootAgent CL %ilocl%
	if %lani1Gp%==1 echo     - OROM LAN Intel BootAgent GE 1.5.62/%iloge%
)
if %lanro%==0 if %lanre%==1 echo R - Remove EFI Realtek UNDI
echo 0 - Exit Main Menu
echo;
:lm1
set /p ec=Enter number:
if not defined ec goto lm1
if %lanir%==0 if %lanie%==0 if %ec%==1 goto rtk
if %lanie%==1 if %ec%==1 goto lans
if %lanir%==1 if %ec%==1 goto lans
if %aa%==4 if %ec%==2 goto lanrise2
if %s2011v3%==1 if %ec%==2 (set fefi=%sdl%\efi\IntlGbEUndiX3.efi) && goto x99
if %s2011v3%==1 if %ec%==3 (set fefi=%sdl%\efi\E6604X3.efi) && goto x99
if %aa%==5 if %lanir%==1 if /I %ec%==c goto cba
if %lanro%==0 if %lanre%==1 if /I %ec%==r goto rtkdel
if %ec%==0 goto mn1
goto lm1

:lans
set depx=0
set fefi=%sdl%\efi\IntlGbEUndiX7.efi
if %aa%==5 if %lani1Gg%==1 for /f "tokens=1" %%a in ('uefifind body list 49006E00740065006C002800520029002000470069006700610062006900740020002500 bios.bin') do (
if %%a neq A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
	hexfind 16000013025A45832CA0880B46B1E1BFB9E703C39708 tmp\lani_%%a.tmp>nul && set depx=Modules\lan\efi\depex.sct
	hexfind 160000130294B261B470DAB74CBF943EFFA3BAF1F208 tmp\lani_%%a.tmp>nul && set depx=Modules\lan\efi\depex1.sct
	hexfind 160000130257D9BCB8AEFEBC4EAB35667A56959E7E08 tmp\lani_%%a.tmp>nul && set depx=Modules\lan\efi\depex2.sct
	set vers=Modules\lan\efi\version.sct
	set brend=Intel LAN Gigabit UNDI
	set ui=IntelGigabitUndi
	set eguid=%%a
	set guid=%%a
	set ftmp=tmp\lani_%%a.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
) else (
	echo Sorry. GUID %%a not supported.
)
)


set fefi=%sdl%\efi\IntlGbEUndiX3.efi
if %s2011v3%==1 if %bacl%==1 if %bage%==0 set fefi=%sdl%\efi\IntlGbEUndiX7.efi
if %s2011v3%==1 if %bacl%==0 if %bage%==1 set fefi=%sdl%\efi\IntlGbEUndiX3.efi

if %s2011v3%==1 if %bacl%==1 if %bage%==1 set fefi=%sdl%\efi\IntlGbEUndiX3.efi
rem if %s2011v3%==1 if %bacl%==1 if %bage%==1 set fefi=%sdl%\efi\E6604X3.efi

:x99
set depx=0
if %aa%==5 if %lani1Gp%==1 for /f "tokens=1" %%a in ('uefifind body list 49006E00740065006C002800520029002000500052004F002F00310030003000300020002500 bios.bin') do (
if %%a neq A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
	hexfind 16000013025A45832CA0880B46B1E1BFB9E703C39708 tmp\lani_%%a.tmp>nul && set depx=Modules\lan\efi\depex.sct
	hexfind 160000130294B261B470DAB74CBF943EFFA3BAF1F208 tmp\lani_%%a.tmp>nul && set depx=Modules\lan\efi\depex1.sct
	hexfind 160000130257D9BCB8AEFEBC4EAB35667A56959E7E08 tmp\lani_%%a.tmp>nul && set depx=Modules\lan\efi\depex2.sct
	set vers=Modules\lan\efi\version.sct
	set brend=Intel LAN PRO/1000 UNDI
	set ui=IntelGigabitUndi
	set eguid=%%a
	set guid=%%a
	set ftmp=tmp\lani_%%a.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
) else (
	echo Sorry. GUID %%a not supported.
)
)
set depx=0
if %aa%==5 if %lani1Gpo%==1 for /f "tokens=1" %%a in ('uefifind body list 49006E00740065006C00280052002900200031004700620045002000440045005600 bios.bin') do (
if %%a neq A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
	hexfind 16000013025A45832CA0880B46B1E1BFB9E703C39708 tmp\lani_%%a.tmp>nul && set depx=Modules\lan\efi\depex.sct
	hexfind 160000130294B261B470DAB74CBF943EFFA3BAF1F208 tmp\lani_%%a.tmp>nul && set depx=Modules\lan\efi\depex1.sct
	hexfind 160000130257D9BCB8AEFEBC4EAB35667A56959E7E08 tmp\lani_%%a.tmp>nul && set depx=Modules\lan\efi\depex2.sct
	set vers=Modules\lan\efi\version.sct
	set brend=Intel LAN PRO/1000 UNDI
	set ui=IntelGigabitUndi
	set eguid=%%a
	set guid=%%a
	set ftmp=tmp\lani_%%a.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
) else (
	echo Sorry. GUID %%a not supported.
)
)
set depx=0
set fefi=%sdl%\efi\Intl10GbEUndiX4.efi
if %aa%==5 if %lani10G%==1 for /f "tokens=1" %%a in ('uefifind body list 49006E00740065006C00280052002900200031003000470062004500200044007200690076006500720020002500 bios.bin') do (
if %%a neq A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
	hexfind 16000013025A45832CA0880B46B1E1BFB9E703C39708 tmp\lani_%%a.tmp>nul && set depx=Modules\lan\efi\depex.sct
	hexfind 160000130294B261B470DAB74CBF943EFFA3BAF1F208 tmp\lani_%%a.tmp>nul && set depx=Modules\lan\efi\depex1.sct
	hexfind 160000130257D9BCB8AEFEBC4EAB35667A56959E7E08 tmp\lani_%%a.tmp>nul && set depx=Modules\lan\efi\depex2.sct
	set vers=Modules\lan\efi\version.sct
	set brend=Intel LAN 10 GbE UNDI
	set ui=Intel10GigabitUndi
	set eguid=%%a
	set guid=%%a
	set ftmp=tmp\lani_%%a.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
) else (
	echo Sorry. GUID %%a not supported.
)
)
if %aa%==5 goto rtk

:lanrise2
set vid=8086
set brend=Intel LAN PXE CL
if %ec%==1 (set lanrom=%sdl%\IntlOromCL.LOM) else (set lanrom=%sdl%\E1562X3.LOM)
for /f "eol=; tokens=1-2" %%f in (%sdl%\DevID_List_iCL.txt) do hexfind 008680%%f00 csmcore>nul && set did=%%g && call :romg

set brend=Intel LAN PXE GE
if %ec%==1 (set lanrom=%sdl%\IntlOromGE.LOM) else (set lanrom=%sdl%\E1562X3.LOM)
for /f "eol=; tokens=1-2" %%f in (%sdl%\DevID_List_iGE.txt) do hexfind 008680%%f00 csmcore>nul && set did=%%g && call :romg

set brend=Intel LAN PXE XE
set lanrom=%sdl%\IntlOromXE.LOM
for /f "eol=; tokens=1-2" %%f in (%sdl%\DevID_List_iXE.txt) do hexfind 008680%%f00 csmcore>nul && set did=%%g && call :romg

set depx=0
set lpat=0
if %bacl%==1 if %bage%==0 set fefi=%sdl%\efi\IntlGbEUndiX7.efi
if %bacl%==0 if %bage%==1 set fefi=%sdl%\efi\IntlGbEUndiX3.efi
if %bacl%==1 if %bage%==1 set fefi=%sdl%\efi\E6604X3.efi
if %aa%==4 if %ec%==2 set fefi=%sdl%\efi\E6604X3.efi

for %%t in (49006E00740065006C0028005200290020003100470062004500200044004500560020002500
49006E00740065006C002800520029002000500052004F002F00310030003000300020002500
0020005000430049002D00450020002000000000000000000049006E00740065006C002800520029002000..00..00..00..00..00..00..00..002000
49006E00740065006C002800520029002000470069006700610062006900740020002500) do uefifind body list %%t bios.bin>nul && set lpat=%%t

if %lpat% neq 0 for /f "tokens=1" %%a in ('uefifind body list %lpat% bios.bin') do (
	hexfind 16000013025A45832CA0880B46B1E1BFB9E703C39708 tmp\lani_%%a.tmp>nul && set depx=Modules\lan\efi\depex.sct
	hexfind 160000130294B261B470DAB74CBF943EFFA3BAF1F208 tmp\lani_%%a.tmp>nul && set depx=Modules\lan\efi\depex1.sct
	hexfind 160000130257D9BCB8AEFEBC4EAB35667A56959E7E08 tmp\lani_%%a.tmp>nul && set depx=Modules\lan\efi\depex2.sct
	set brend=Intel LAN 1 GbE UNDI
	set ui=IntelGigabitUndi
	set eguid=%%a
	set guid=%%a
	set ftmp=tmp\lani_%%a.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
)
set depx=0
set fefi=%sdl%\efi\Intl10GbEUndiX4.efi
if %lani10G%==1 for /f "tokens=1" %%a in ('uefifind body list 49006E00740065006C00280052002900200031003000470062004500200044007200690076006500720020002500 bios.bin') do (
	hexfind 16000013025A45832CA0880B46B1E1BFB9E703C39708 tmp\lani_%%a.tmp>nul && set depx=Modules\lan\efi\depex.sct
	hexfind 160000130294B261B470DAB74CBF943EFFA3BAF1F208 tmp\lani_%%a.tmp>nul && set depx=Modules\lan\efi\depex1.sct
	hexfind 160000130257D9BCB8AEFEBC4EAB35667A56959E7E08 tmp\lani_%%a.tmp>nul && set depx=Modules\lan\efi\depex2.sct
	set brend=Intel LAN 10 GbE UNDI
	set ui=Intel10GigabitUndi
	set eguid=%%a
	set guid=%%a
	set ftmp=tmp\lani_%%a.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
)

:rtk
set depx=0
set fefi=%sdl%\efi\RtkUndiDxe.efi
for /f "tokens=1" %%a in ('uefifind body list 00005200650061006C00740065006B0020005500450046004900200055004E004400490020004400720069007600650072000000 bios.bin') do (
if %%a neq A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
	hexfind 16000013025A45832CA0880B46B1E1BFB9E703C39708 tmp\lanr_%%a.tmp>nul && set depx=%sdl%\efi\depex.sct
	hexfind 160000130294B261B470DAB74CBF943EFFA3BAF1F208 tmp\lanr_%%a.tmp>nul && set depx=%sdl%\efi\depex1.sct
	set vers=Modules\lan\efi\version.sct
	set brend=Realtek LAN UNDI
	set eguid=%%a
	set ui=RealtekUndi
	set guid=%%a
	set ftmp=tmp\lanr_%%a.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
) else (
	echo Sorry. GUID %%a not supported.
)
)
if %aa%==5 goto rtk5

set vid=10ec
set brend=Realtek LAN PXE
set lanrom=%sdl%\rtegpxe.lom
hexfind 00EC10AA55 csmcore>nul && set did=55AA && set romf=%sdl%\rtegpxe.lom 10ec 55aa && call :romu
hexfind 00ec106881 csmcore>nul || hexfind a0ec106881 csmcore>nul
if not errorlevel 1 (set did=8168) && set romf=%sdl%\rtegpxe.lom 10ec 8168 && call :romu
hexfind 00ec106981 csmcore>nul || hexfind a0ec106981 csmcore>nul
if not errorlevel 1 (set did=8169) && set romf=%sdl%\rtegpxe.lom 10ec 8169 && call :romu

:rtk5
if %aa%==5 if %nmmt%==1 for /f "tokens=1,2" %%a in ('uefifind body list 50434952EC106881 bios.bin') do (
	set subguid=%%b
	if defined subguid (
		set fefi=%sdl%\rtegpxe.lom
		set oguid=%%a %%b
		set brend=OROM Realtek LAN PXE
		call :romu5e
	)
)

if %aa%==5 goto bcm

:qcmath
set vid=1969
set brend=Atheros LAN PXE
set lanrom=%sdl%\athpxe.lom
for /f "eol=; tokens=1-2" %%f in (%sdl%\DevID_List_ATH.txt) do hexfind 006919%%f00 csmcore>nul && set did=%%g && call :romg

set brend=QCM-Atheros LAN PXE
set lanrom=%sdl%\qcmpxe.lom
for /f "eol=; tokens=1-2" %%f in (%sdl%\DevID_List_QCM.txt) do hexfind 006919%%f00 csmcore>nul && set did=%%g && call :romg

:bcm
set depx=0
set fefi=%sdl%\efi\b57undix64.efi
for /f "tokens=1" %%a in ('uefifind body list 0000420072006F006100640063006F006D0020004E006500740058007400720065006D006500200047006900670061006200690074002000450074006800650072006E00650074002000 bios.bin') do (
if %%a neq A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
	hexfind 16000013025A45832CA0880B46B1E1BFB9E703C39708 tmp\lanb_%%a.tmp>nul && set depx=Modules\lan\efi\depex.sct
	hexfind 160000130294B261B470DAB74CBF943EFFA3BAF1F208 tmp\lanb_%%a.tmp>nul && set depx=Modules\lan\efi\depex1.sct
	set vers=Modules\lan\efi\version.sct
	set brend=Broadcom NetXtreme UNDI
	set ui=VroadcommUndi
	set eguid=%%a
	set guid=%%a
	set ftmp=tmp\lanb_%%a.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
) else (
	echo Sorry. GUID %%a not supported.
)
)
if %aa%==5 goto :lanexit

set vid=14e4
set brend=Broadcom NetXtreme LAN PXE
set lanrom=%sdl%\q57pxee.lom
for /f "eol=; tokens=1-2" %%f in (%sdl%\DevID_List_BCM.txt) do hexfind 00e414%%f00 csmcore>nul && set did=%%g && call :romg

:lanexit
echo;
%mmt1%
call :inlver
call :rtkver
call :qcaver
call :bcmver

pause
goto mn1

:asm
set ec=
echo;
echo 	AsMedia SATA Option ROM
echo;
echo 1 - Update to v0.951
echo 2 * Update to v0.97 *
echo 3 * Update to v3.80 *
echo 0 - Exit to Main Menu
echo;
echo * - Warning! These modules may not work on your motherboard.
echo;
:asm1
set /p ec=Enter number:
if not defined ec goto asm1
if %ec%==1 (set asmbin=asmed0951.bin) && goto asms
if %ec%==2 (set asmbin=asmed097.bin) && goto asms
if %ec%==3 (set asmbin=asmed380.bin) && goto asms
if %ec%==0 goto mn1
goto asm1
:asms
set brend=ASMedia 106x SATA/PATA
(hexfind 00211b1106 csmcore>nul || hexfind A0211b1106 csmcore>nul) && set did=611 && set romf=%sds%\%asmbin% 1b21 611 && call :romu
(hexfind 00211b1206 csmcore>nul || hexfind A0211b1206 csmcore>nul) && set did=612 && set romf=%sds%\%asmbin% 1b21 612 && call :romu
(hexfind 00211b1306 csmcore>nul || hexfind A0211b1306 csmcore>nul) && set did=613 && set romf=%sds%\%asmbin% 1b21 613 && call :romu

echo;
%mmt1%
%veroasm%
pause
goto mn1

:marv
set mrv1=1.1.0.1002
set mrv2=1.0.0.0034
set mrv3=1.0.0.0034
set mrv4=1.0.0.1024
for /f "tokens=6" %%l in ('drvver %sds%\efi\mrvahci.efi') do set mrva=%%l
for /f "tokens=6" %%l in ('drvver %sds%\efi\mrvraid.efi') do set mrvr=%%l
set ec=
set mvv=
echo;
if %me%==1 (echo 	Marvell SATA Option ROM and EFI) else (echo 	Marvell SATA Option ROM)
echo;
echo 1 - Update OROM Marvell
hexfind 504349524b1b2091 csmcore>nul && echo     OROM Marvell 88SE9120 - %mrv1%
hexfind 504349524b1ba091 csmcore>nul && echo     OROM Marvell 88SE91a0 - %mrv1%
hexfind 504349524b1b2391 csmcore>nul && echo     OROM Marvell 88SE9123 - %mrv1%
hexfind 504349524b1ba391 csmcore>nul && echo     OROM Marvell 88SE91a3 - %mrv1%
hexfind 504349524b1b7291 csmcore>nul && echo     OROM Marvell 88SE9172 - %mrv2%
hexfind 504349524b1b7a91 csmcore>nul && echo     OROM Marvell 88SE917a - %mrv2%
hexfind 504349524b1b8291 csmcore>nul && echo     OROM Marvell 88SE9182 - %mrv2%
hexfind 504349524b1b8a91 csmcore>nul && echo     OROM Marvell 88SE918a - %mrv2%
hexfind 504349524b1b2891 csmcore>nul && echo     OROM Marvell 88SE9128 - %mrv1%
hexfind 504349524b1b9291 csmcore>nul && echo     OROM Marvell 88SE9192 - %mrv3%
hexfind 504349524b1ba291 csmcore>nul && echo     OROM Marvell 88SE91a2 - %mrv3%
hexfind 504349524b1b3091 csmcore>nul && echo     OROM Marvell 88SE9130 - %mrv1%
hexfind 004b1b309200 csmcore>nul && hexfind 504349524b1b3092 csmcore>nul && echo     OROM Marvell 88SE9230 - %mrv4%
if exist tmp\mrv*.tmp for /f "tokens=*" %%b in ('dir tmp\mrv*.tmp /b') do hexfind 4D415256454C4C2052616964 tmp\%%b>nul && (echo     EFI Marvell SATA RAID - %mrvr%) || (echo     EFI Marvell SATA AHCI - %mrva%)

echo 0 - Exit Main Menu
echo;
:marv1
set /p ec=Enter number:
if not defined ec goto marv1
if %ec%==0 goto mn1
if %ec%==1 goto marvs
goto marv1

:marvs
set depx=0
set fefi=%sds%\efi\mrvahci.efi
for /f "tokens=1" %%a in ('uefifind body list 00004D0061007200760065006C006C00200053004300530049002000440072006900760065007200 bios.bin') do (
if %%a neq A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
	hexfind 1600001302FBC28B12E10C3B42844E98E62591283508 tmp\mrvs_%%a.tmp>nul && set depx=%sds%\efi\depex1.sct
	hexfind 1600001302A6458FC11BBE8C4AAE89A5C57CBC828F08 tmp\mrvs_%%a.tmp>nul && set depx=%sds%\efi\depex2.sct
	hexfind 160000130214F746C22EB0764DA56D6CE4576AB40908 tmp\mrvs_%%a.tmp>nul && set depx=%sds%\efi\depex3.sct
	set vers=%sds%\efi\version.sct
	set brend=Marvell AHCI
	set ui=Marvell_AHCI
	set eguid=%%a
	set guid=%%a
	set ftmp=tmp\mrvs_%%a.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
) else (
	echo Sorry. GUID %%a not supported.
)
)
set depx=0
set fefi=%sds%\efi\mrvraid.efi
for /f "tokens=1" %%a in ('uefifind body list 00004D0061007200760065006C006C00200052004100490044002000440072006900760065007200 bios.bin') do (
if %%a neq A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
	hexfind 1600001302FBC28B12E10C3B42844E98E62591283508 tmp\mrvr_%%a.tmp>nul && set depx=%sds%\efi\depex1.sct
	hexfind 1600001302A6458FC11BBE8C4AAE89A5C57CBC828F08 tmp\mrvr_%%a.tmp>nul && set depx=%sds%\efi\depex2.sct
	hexfind 160000130214F746C22EB0764DA56D6CE4576AB40908 tmp\mrvr_%%a.tmp>nul && set depx=%sds%\efi\depex3.sct
	set vers=Modules\sata\efi\version.sct
	set brend=Marvell RAID
	set ui=Marvell_RAID
	set eguid=%%a
	set guid=%%a
	set ftmp=tmp\mrvr_%%a.tmp
	set ffs=tmp\ffsfile.tmp
	call :ffsg
) else (
	echo Sorry. GUID %%a not supported.
)
)
if %aa%==5 goto marvend

set brend=Marvell SATA
for /f "eol=; tokens=1-2" %%f in (%sds%\DevID_list_Marvell.txt) do hexfind 004b1b%%f csmcore>nul && set did=%%g && set romf=%sds%\Mrvll%%g.bin 1b4b %%g && call :romu
hexfind 004b1b3091 csmcore>nul && hexfind 504349524b1b3091 csmcore>nul && set did=9130 && set romf=%sds%\Mrvll9130.bin 1b4b 9130 && call :romu
hexfind 004b1b3091 csmcore>nul && hexfind 504349524b1b2891 csmcore>nul && set did=9128 && set romf=%sds%\Mrvll9128.bin 1b4b 9130 && call :romu
hexfind 004b1b309200 csmcore>nul && set did=9230 && set romf=%sds%\Mrvll9230.bin 1b4b 9230 && call :romu

:marvend
echo;
%mmt1%
call :mrvlver

pause
goto mn1

:jmb
set ec=
set jmb2363=0
echo;
echo 	JMicron SATA Option ROM
echo;
echo 1 - Update to v1.07.28
hexfind 007b196323 csmcore>nul && set jmb2363=1 && echo 2 - Update to v1.08.01
echo 0 - Exit to Main Menu
echo;
:jmb1
set /p ec=Enter number:
if not defined ec goto jmb1
if %ec%==0 goto mn1
if %ec%==1 (set jmb362=%sds%\jmb362_7.bin) && (set jmb363=%sds%\jmb363_7.bin) && goto jmbs
if %jmb2363%==1 if %ec%==2 (set jmb362=%sds%\jmb362_7.bin) && (set jmb363=%sds%\jmb363_8.bin) && goto jmbs
goto jmb1
:jmbs
set brend=JMicron SATA
hexfind 007b196223 csmcore>nul && set did=2362 && set romf=%jmb362% 197b 2362 && call :romu
hexfind 007b196323 csmcore>nul && set did=2363 && set romf=%jmb363% 197b 2363 && call :romu
echo;
%mmt1%
%verojmb%
pause
goto mn1

:romg
<nul set /p TmpStr=* Generate %brend% OROM Device ID %did% ...
(setdevid %did% %lanrom% tmp\lanrom.tmp>nul && echo Ok!) || echo Error!
set romf=tmp\lanrom.tmp %vid% %did%

:romu
<nul set /p TmpStr=* Update OROM %brend% Device ID %did% ...
%mmt% /r /l %romf%
if %errorlevel%==0 (echo Ok!) else (echo Error!)
exit /b

:romu5e
<nul set /p TmpStr=* Update %brend% GUID %oguid% ...
%mmt% /r /l %fefi% %oguid%
if %errorlevel%==0 (echo Ok!) else (echo Error!)
%mmt% /e /l "tmp\igop_%oguid%.tmp" %oguid%
exit /b

:ffsg
if exist tmp\ffs*.tmp>nul del /f /q tmp\ffsfile.tmp
<nul set /p TmpStr=* Generate FFS %brend% GUID %guid% ...
%udk%\GenSec -s EFI_SECTION_USER_INTERFACE -n %ui% -o tmp\ffsui.tmp
%udk%\GenSec -s EFI_SECTION_PE32 %fefi% -o tmp\ffspe32.tmp

rem  if %aa%==4 (
	%udk%\GenSec tmp\ffspe32.tmp tmp\ffsui.tmp -o tmp\ffspe32ui.tmp
	%udk%\GenSec -s EFI_SECTION_COMPRESSION tmp\ffspe32ui.tmp -o tmp\ffscomp.tmp
rem )
rem if %aa%==5 (
rem 	%udk%\GenSec tmp\ffspe32.tmp tmp\ffsui.tmp %vers% -o tmp\ffspe32ui.tmp
rem 	%udk%\LzmaCompress -e -q tmp\ffspe32ui.tmp -o tmp\ffslzmape32ui.tmp
rem 	%udk%\GenSec -s EFI_SECTION_GUID_DEFINED -g EE4E5898-3914-4259-9D6E-DC7BD79403CF -r PROCESSING_REQUIRED tmp\ffslzmape32ui.tmp -o tmp\ffscomp.tmp
rem )
if %depx%==0 (
	if %aa%==4 %udk%\GenFFS -s -t EFI_FV_FILETYPE_DRIVER -g %guid% -i tmp\ffscomp.tmp -o tmp\ffsfile.tmp
	if %aa%==5 %udk%\GenFFS -t EFI_FV_FILETYPE_DRIVER -g %guid% -i tmp\ffscomp.tmp -o tmp\ffsfile.tmp
) else (
	if %aa%==4 %udk%\GenFFS -s -t EFI_FV_FILETYPE_DRIVER -g %guid% -i %depx% -i tmp\ffscomp.tmp -o tmp\ffsfile.tmp
	if %aa%==5 %udk%\GenFFS -t EFI_FV_FILETYPE_DRIVER -g %guid% -i %depx% -i tmp\ffscomp.tmp -o tmp\ffsfile.tmp
)
if %errorlevel%==0 (echo Ok!) else (echo Error!)

:ffsu
<nul set /p TmpStr=* Update EFI %brend% GUID %eguid% ...
%mmt% /r %guid% %ffs%
if %errorlevel%==0 (echo Ok!) else (echo Error!)
if %ftmp% neq 0 %mmt% /e %guid% %ftmp%
exit /b

:cpu
cls

if not exist Modules\mCode\mpdt (echo Error!Folder Modules\mCode\MPDT not found) && pause && goto mn1
if not exist Modules\mCode\Zero\Z_CPU0.ffs echo !Modules\mCode\Zero\Z_CPU0.ffs not found !&& pause && goto mn1
if not exist Modules\mCode\Zero\Z_CPU1.ffs echo !Modules\mCode\Zero\Z_CPU1.ffs not found !&& pause && goto mn1

set mc1=
set mc2=
set mpdt=
set str1=
set str2=
hexfind 4D5044540001000010000000000010 tmp\cpuffs.tmp>nul && set mpdt=-i Modules\mCode\mpdt\MPDT_BOOT_YES.bin
hexfind 4D5044540000000010000000000010 tmp\cpuffs.tmp>nul && set mpdt=-i Modules\mCode\mpdt\MPDT_BOOT_NO.bin

mce bios.bin  -skip -ubutest -exit

if not exist tmp\cpuffs.tmp goto :cpugm

echo     Current versions in GUID %cguid%

if exist tmp\lmcode.ffs del /F /Q tmp\mcode.ffs
rem if %e7%==1 echo This BIOS supprt E7 processors. Please contact me. && pause && goto mn1

set bdw=0
set bdwe=0
set kbl=0

set cpu2011v=6E4-42A, 6E2-20D, 6D7-710, 6D6-61A, 6D5-513
set cpu2011esv=6E3-308, 6E0-008, 6D3-304, 6D2-20C, 6D1-106

set cvcpu="Current Version. Press ESC to close this window and continue."
if %s1150%==1 hexfind 01000000710604000000000000000000 tmp\cpuffs.tmp>nul && set bdw=1
if %s1151%==1 hexfind 01000000E90609000000000000000000 tmp\cpuffs.tmp>nul && set kbl=1
if %s2011v3%==1 hexfind 01000000F10604000000000000000000 tmp\cpuffs.tmp>nul && set bdwe=1

for  /f "tokens=*" %%c in ('uefifind header count %scguid% bios.bin') do set c=%%c
rem if %c%==4 echo Strange number of modules. Let me know! && pause && goto mn1
rem if %c%==6 echo Strange number of modules. Let me know! && pause && goto mn1

:cpugm
set ec=
echo;
if exist tmp\cpuffs.tmp ( 
echo 	Update Intel CPU MicroCode
echo;
if %s1155%==1 echo 1 - Update CPU MicroCode IvyBridge and/or SandyBridge
if %s1150%==1 echo 1 - Update CPU MicroCode Haswell and/or Broadwell
if %s1151%==1 echo 1 - Update CPU MicroCode Skylake
if %s2011v3%==1 echo 1 - Update CPU MicroCode Haswell-E and/or Broadwell-E

if %s2011%==1 (
	echo 1 - Update CPU MicroCode IvyBridge-E and SandyBridge-E
	echo     6E4-42A, 6E2-20D, 6D7-710, 6D6-619, 6D5-513
	echo 2 - Update CPU MicroCode %cpum% Engineering Sample
	echo     6E3-308, 6E0-008, 6D3-304, 6D2-20C, 6D1-106
)

echo 3 - View CPU Microcode Patch list
echo m - User Select Microcode File
)

echo e - Extract all CPU Microcodes
echo s - Search for available microcode in DB.

echo 0 - Exit to Main Menu
echo;
:cpu1
set /p ec=Enter number:
if not defined ec goto cpu1
if %ec%==0 goto mn1

if exist tmp\cpuffs.tmp (
if %s2011%==1 if %ec%==1 (
	hexfind 4D5044540001000010000000000010 tmp\cpuffs.tmp>nul && set modcpu=Modules\mCode\2011\lga2011_boot_yes.ffs&& goto cpus
	hexfind 4D5044540000000010000000000010 tmp\cpuffs.tmp>nul && set modcpu=Modules\mCode\2011\lga2011_boot_no.ffs&& goto cpus
	set modcpu=Modules\mCode\2011\lga2011.ffs
	goto cpus
)
if %s2011%==1 if %ec%==2 (
	hexfind 4D5044540001000010000000000010 tmp\cpuffs.tmp>nul && set modcpu=Modules\mCode\2011\lga2011es_boot_yes.ffs&& goto cpus
	hexfind 4D5044540000000010000000000010 tmp\cpuffs.tmp>nul && set modcpu=Modules\mCode\2011\lga2011es_boot_no.ffs&& goto cpus
	set modcpu=Modules\mCode\2011\lga2011es.ffs
	goto cpus
)

if %s1155%==1 if %ec%==1 (
	if not exist Modules\mCode\1155 (echo Error! Folder Modules\mCode\1155 not found) && pause && exit
	call Modules\mCode\Sel1155.bat
	goto mcgenffs
)

if %s1150%==1 if %ec%==1 (
	if not exist Modules\mCode\1150 (echo Error!Folder Modules\mCode\1150 not found) && pause && exit
	call Modules\mCode\Sel1150.bat
	goto mcgenffs
)

if %s2011v3%==1 if %ec%==1 (
	if not exist Modules\mCode\2011v3 (echo Error!Folder Modules\mCode\2011v3 not found) && pause && exit
	call Modules\mCode\Sel2011v3.bat
	goto mcgenffs
)

if %s1151%==1 if %ec%==1 (
	if not exist Modules\mCode\1151 (echo Error!Folder Modules\mCode\1151 not found) && pause && exit
		call Modules\mCode\Sel1151.bat
		goto mcgenffs
)
if /I %ec%==m goto mcg
if %ec%==3 start %cvcpu% mmtool bios.bin /p && goto cpu1
)

if /I %ec%==e echo Extracting... && mce bios.bin -skip>nul && goto cpu
if /I %ec%==s goto sdb

goto cpu1

:sdb
set /p str1=Enter CPUID, example 000306C3 :^>
if not defined str1 goto cpu
rem set /p str2=Enter Platform ID, example 32 :^>
rem if not defined str2 goto cpu
rem set fstr=%str1%

mce -search  %str1%
rem pause
goto cpu

:mcg
set fmc=
setlocal
for /f "usebackq delims=" %%m in (
	`@"%systemroot%\system32\mshta.exe" "about:<FORM><INPUT type='file' name='qq'></FORM><script>document.forms[0].elements[0].click();var F=document.forms[0].elements[0].value;try {new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).Write(F)};catch (e){};close();</script>" ^
	1^|more`
) do  set fmc=%%m
endlocal && set fmc=%fmc%
if not defined fmc goto cpu1
echo %fmc%
mce %fmc% -skip -ubutest -exit
mcodefit -check %fmc% || pause && goto cpu

:umc
set ec=
echo;
echo 1 - Re-Select Microcode File
echo Y - Update User Select
echo 0 - Exit
:umc1
set /p ec=Enter number:
if not defined ec goto umc1
if %ec%==1 goto mcg
if /I %ec%==y (
	echo Generate FFS files Microcode
	uefifind all count %scguid%^..AA..........F80100 bios.bin>nul && %udk%\GenFFS -t EFI_FV_FILETYPE_RAW -g %cguid% -i %fmc% %mpdt% -o tmp\usermc.ffs || %udk%\GenFFS -s -t EFI_FV_FILETYPE_RAW -g %cguid% -i %fmc% %mpdt% -o tmp\usermc.ffs
	set modcpu=tmp\usermc.ffs
	goto cpus
)
if %ec%==0 goto mn1
goto umc1

:mcgenffs
if not defined mc1  if not defined mc2 goto cpu
if defined mc1 (mcodefit -check Modules\mCode\%mc1% || pause && goto cpu) && (set mc1=-i Modules\mCode\%mc1%)
if defined mc2 (mcodefit -check Modules\mCode\%mc2% || pause && goto cpu) && (set mc2=-i Modules\mCode\%mc2%)
echo Generate FFS Microcode
uefifind all count %scguid%^..AA..........F80100 bios.bin>nul && %udk%\GenFFS -t EFI_FV_FILETYPE_RAW -g %cguid% %mc1% %mc2% %mpdt% -o tmp\mCode.ffs || %udk%\GenFFS -s -t EFI_FV_FILETYPE_RAW -g %cguid% %mc1% %mc2% %mpdt% -o tmp\mCode.ffs
set modcpu=tmp\mCode.ffs

:cpus
echo Preparing for replacement
if %fit%==1 mcodefit -rdfit bios.bin

for /f "tokens=1" %%m in ('uefifind header list %scguid% bios.bin') do (
	%mmt% /e %%m tmp\cpu_ffs.tmp
	hexfind 00F8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF tmp\cpu_ffs.tmp>nul
	if not errorlevel 1 (
		%mmt% /r %%m Modules\mCode\Zero\Z_CPU0.ffs
		copy /y tmp\cpu_ffs.tmp tmp\cpu_zero.tmp>nul
	) else (
		%mmt% /r %%m Modules\mCode\Zero\Z_CPU1.ffs
	)
)
for /f "tokens=1" %%m in ('uefifind header list 72850817000000000000000000000002 bios.bin') do (
	<nul set /p TmpStr=Update Microcode Patch...
	%mmt% /r %%m %modcpu%
	if %errorlevel%==0 (echo Ok!) else (echo Error!)
)
for /f "tokens=1" %%m in ('uefifind header list 72850817000000000000000000000001 bios.bin') do %mmt% /r %%m tmp\cpu_zero.tmp

if exist fit.dump mcodefit -wdfit bios.bin && del /f /q fit.dump
mce bios.bin -skip -ubutest -exit
if %fit%==1 mcodefit -fixfit bios.bin

pause
goto cpu

:rg
echo;
echo 	Other Option ROM in FFS
echo;
call :oromguid
echo;
pause
goto mn1

:err
echo !!! File BIOS not found !!!
pause>nul
exit

:exit
set ec=
echo;
if %asus%==1 echo 1 - Rename to ASUS USB BIOS Flashback
if %asus%==0 echo 1 - Rename to mod_%biosname%
echo 0 - As Is BIOS.BIN
echo;
:ubf
set /p ec=Rename? :
if not defined ec goto ubf
if %ec%==1 if %asus%==1 goto resubf
if %ec%==1 if %asus%==0 (
	ren bios.bin mod_%biosname%
	echo bios.bin ===^> mod_%biosname%
	goto exit1
)
if %ec%==0 goto exit1
goto ubf

:resubf
if exist bios.bin.dump for /f %%u in ('findver "" 24424F4F5445464924 145 00 12 1 bios.bin') do (
if exist bios.bin.dump (
	echo Restore Capsule Header
	copy /b /y bios.bin.dump\header.bin+bios.bin %%u>nul
	echo bios.bin ===^> %%u
	del bios.bin
) else (
	ren bios.bin %%u
	echo bios.bin ===^> %%u
))
if exist bios.bin ren bios.bin mod_%biosname% && echo bios.bin ===^> mod_%biosname%

:exit1
echo;
echo *******************************************************************************
echo * Many thanks to CodeRush for utilites HexFind, DrvVer, FindVer and UEFIFind. *
echo *******************************************************************************
pause>nul

:exit2
if exist bios.bin.dump rd /s /q bios.bin.dump
if exist *.tmp del /f /q *.tmp
if exist csmcore del /f /q csmcor*
if exist tmp rd /s /q tmp

EXIT

REM display version
:videod
if %s1155%==1 for /f "tokens=*" %%b in ('findver "" 245642542053 79 FF 4 2 csmcore') do (
	if %%b LSS 2117 (echo      OROM VBIOS SandyBridge     - %%b) else (echo      OROM VBIOS SNB-IVB         - %%b))
if %s1150%==1 for /f "tokens=*" %%b in ('findver "" 24564254204841 79 FF 4 2 csmcore') do (
	if %%b LSS 2000 (echo      OROM VBIOS HSW-BDW         - %%b) else (echo      OROM VBIOS Haswell         - %%b))
if %s1151%==1 for /f "tokens=*" %%b in ('findver "" 2456425420534B 79 FF 4 2 csmcore') do (
	if %%b LSS 1034 (echo      OROM VBIOS SkyLake         - %%b) else (echo      OROM VBIOS SKL-KBL         - %%b))
if %s1150%==0 if %s1155%==0 findver "     OROM VBIOS ValleyView      - " 24564254205641 79 FF 4 2 csmcore
if %s1150%==0 if %s1155%==0 findver "     OROM VBIOS CherryView      - " 24564254204348 79 FF 4 2 csmcore
if %s1150%==0 if %s1155%==0 findver "     OROM VBIOS Broxton         - " 24564254204252 79 FF 4 2 csmcore
if %s1150%==0 if %s1151%==0 if %s1155%==0 findver "     OROM VBIOS Ironlake        - " 24564254204952 79 FF 4 2 csmcore
if %s1150%==0 if %s1151%==0 if %s1155%==0 findver "     OROM VBIOS Eaglelake       - " 24564254204541 79 FF 4 2 csmcore
if exist tmp\iGop*.tmp for /f "tokens=*" %%b in ('dir tmp\iGop*.tmp /b') do drvver "tmp\%%b"
exit /b

:avideod
if exist tmp\vbios*.tmp for /f "tokens=*" %%b in ('dir tmp\vbios*.tmp /b') do (
	(hexfind 53706563747265 tmp\%%b>nul && findver "     OROM-in-FFS VBIOS Spectre  - " 41544F4D42494F53424B 18 00 22 1 tmp\%%b) || 	(hexfind 4B616C696E6469 tmp\%%b>nul && findver "     OROM-in-FFS VBIOS Kalindi  - " 41544F4D42494F53424B 18 00 22 1 tmp\%%b) || 	(hexfind 5472696E697479 tmp\%%b>nul && findver "     OROM-in-FFS VBIOS Trinity  - " 41544F4D42494F53424B 18 00 22 1 tmp\%%b) || 	(hexfind 4D756C6C696E73 tmp\%%b>nul && findver "     OROM-in-FFS VBIOS Mullins  - " 41544F4D42494F53424B 18 00 22 1 tmp\%%b) || findver "     OROM-in-FFS VBIOS Unknow   - " 41544F4D42494F53424B 18 00 22 1 tmp\%%b
)
findver "     OROM AMD VBIOS             - " 41544F4D42494F53424B 18 00 22 2 csmcore
if exist tmp\amdgop_*.tmp for /f "tokens=*" %%b in ('dir "tmp\amdgop_*.tmp" /b') do drvver "tmp\%%b"
exit /b

:irstd
findver "     OROM IMSM RAID for SATA    - " 496E74656C285229204D61747269782053746F72616765204D616E61676572206F7074696F6E20524F4D 44 20 12 2 csmcore
findver "     OROM IRST RAID for SATA    - " 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F6779202D204F7074696F6E20524F4D 49 0A 12 2 csmcore
findver "     OROM IRSTe RAID for SATA   - " 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F677920656E7465727072697365202D2053415441204F7074696F6E20524F4D 65 0A 12 2 csmcore
findver "     OROM IRSTe RAID for sSATA  - " 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F677920656E7465727072697365202D207353415441204F7074696F6E20524F4D 66 0A 12 2 csmcore
findver "     OROM IRSTe RAID for SCU    - " 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F677920656E7465727072697365202D20534355204F7074696F6E20524F4D 64 0A 12 2 csmcore
if exist tmp\irst_*.tmp for /f "tokens=*" %%b in ('dir "tmp\irst_*.tmp" /b') do drvver "tmp\%%b"
if exist tmp\nvme_*.tmp for /f "tokens=*" %%b in ('dir "tmp\nvme_*.tmp" /b') do drvver "tmp\%%b"
exit /b

:amdd
if exist tmp\4391.tmp findver "     OROM AMD AHCI 4391         - " 414D442041484349 22 00 10 1 tmp\4391.tmp
if exist tmp\7801.tmp findver "     OROM AMD AHCI 7801         - " 414D442041484349 22 00 10 1 tmp\7801.tmp
if exist tmp\55aa.tmp if %amdahci%==4391 findver "     OROM AMD AHCI 4391         - " 414D442041484349 22 00 10 1 tmp\55aa.tmp
if exist tmp\55aa.tmp if %amdahci%==7801 findver "     OROM AMD AHCI 7801         - " 414D442041484349 22 00 10 1 tmp\55aa.tmp
if exist tmp\4392.tmp findver "     OROM AMD RAID MISC 4392    - " 55AA 10 00 12 1 tmp\4392.tmp
if exist tmp\4393.tmp findver "     OROM AMD RAID MISC 4393    - " 55AA 10 00 12 1 tmp\4393.tmp
if exist tmp\7802.tmp findver "     OROM AMD RAID MISC 7802    - " 55AA 10 00 12 1 tmp\7802.tmp
if exist tmp\7803.tmp findver "     OROM AMD RAID MISC 7803    - " 55AA 10 00 12 1 tmp\7803.tmp
if exist tmp\raidx64.tmp drvver tmp\raidx64.tmp
if exist tmp\raidutil.tmp drvver tmp\raidutil.tmp
if exist tmp\RAIDxpt2f10o.tmp findver "     OROM AMD RAIDXpert2-F10    - " 5243424E42474E 8 00 12 1 tmp\RAIDxpt2f10o.tmp
if exist tmp\RAIDxpt2f10e.tmp findver "     EFI AMD RAIDXpert2-F10     - " 5243424E454E44 8 00 12 1 tmp\RAIDxpt2f10e.tmp
if exist tmp\RAIDxpt2f50o.tmp findver "     OROM AMD RAIDXpert2-F50    - " 5243424E42474E 8 00 12 1 tmp\RAIDxpt2f50o.tmp
if exist tmp\RAIDxpt2f50e.tmp findver "     EFI AMD RAIDXpert2-F50     - " 5243424E454E44 8 00 12 1 tmp\RAIDxpt2f50e.tmp

if exist tmp\RAIDxpt2fxxe.tmp findver "     EFI AMD RAIDXpert2-Fxx     - " 5243424E454E44 8 00 12 1 tmp\RAIDxpt2fxxe.tmp
exit /b

:mrvlver
findver "     OROM Marvell 88SE6121      - " 50434952AB112161 -22 00 10 1 csmcore
findver "     OROM Marvell 88SE9120      - " 504349524B1B2091 -21 00 10 1 csmcore
findver "     OROM Marvell 88SE91a0      - " 504349524B1Ba091 -21 00 10 1 csmcore
findver "     OROM Marvell 88SE9123      - " 504349524B1B2391 -21 00 10 1 csmcore
findver "     OROM Marvell 88SE91a3      - " 504349524B1Ba391 -21 00 10 1 csmcore
findver "     OROM Marvell 88SE9128      - " 504349524B1B2891 -21 00 10 1 csmcore
findver "     OROM Marvell 88SE9130      - " 504349524B1B3091 -21 00 10 1 csmcore
findver "     OROM Marvell 88SE9172      - " 504349524B1B7291 -21 00 10 1 csmcore
findver "     OROM Marvell 88SE917a      - " 504349524B1B7a91 -21 00 10 1 csmcore
findver "     OROM Marvell 88SE9182      - " 504349524B1B8291 -21 00 10 1 csmcore
findver "     OROM Marvell 88SE918a      - " 504349524B1B8a91 -21 00 10 1 csmcore
hexfind 004b1b309200 csmcore>nul && findver "     OROM Marvell 88SE9230      - " 504349524B1B3092 -21 00 10 1 csmcore
hexfind 004b1b9291 csmcore>nul && findver "     OROM Marvell 88SE9192      - " 004D565244004D56554900 -10 00 10 1 csmcore
rem hexfind 004b1ba291 csmcore>nul && %mmt% /e /l tmp\91a2.tmp 1b4b 91a2 && findver "     OROM Marvell 88SE91a2      - " 42494F532056657273696F6E20 14 00 10 1 tmp\91a2.tmp
if %me%==1 if exist tmp\mrv*.tmp for /f "tokens=*" %%b in ('dir tmp\mrv*.tmp /b') do drvver "tmp\%%b"
exit /b

:inlver
findver "     OROM Intel Boot Agent FE   - " 496E74656C28522920426F6F74204167656E74204645 24 00 7 2 csmcore && set lanir=0
findver "     OROM Intel Boot Agent GE   - " 496E74656C28522920426F6F74204167656E74204745 24 00 7 2 csmcore && set lanir=1
findver "     OROM Intel Boot Agent CL   - " 496E74656C28522920426F6F74204167656E7420434C 24 00 7 2 csmcore && set lanir=1
findver "     OROM Intel Boot Agent XE   - " 496E74656C28522920426F6F74204167656E74205845 24 00 7 2 csmcore && set lanir10=1
findver "     OROM Intel Boot Agent XG   - " 496E74656C28522920426F6F74204167656E74205847 24 00 7 2 csmcore
findver "     OROM Intel Boot Agent 40G  - " 496E74656C28522920426F6F74204167656E74203430 24 00 7 2 csmcore
rem findver "     OROM Intel iSCSI Boot      - " 496E74656C2852292069534353492052656D6F746520426F6F74 35 00 7 1 csmcore
if exist tmp\lani*.tmp for /f "tokens=*" %%b in ('dir tmp\lani*.tmp /b') do drvver "tmp\%%b"
exit /b

:rtkver
findver "     OROM Realtek Boot Agent FE - " 5265616C74656B20504349652046452046616D696C7920436F6E74726F6C6C657220536572696573 42 20 4 1 csmcore && set lanrr=0
findver "     OROM Realtek Boot Agent GE - " 5265616C74656B2050434965204742452046616D696C7920436F6E74726F6C6C657220536572696573 43 20 4 1 csmcore && set lanrr=1
if exist tmp\lanr*.tmp for /f "tokens=*" %%b in ('dir tmp\lanr*.tmp /b') do drvver "tmp\%%b"
exit /b

:qcaver
findver "     OROM QCM-Atheros PXE       - " 504349452045746865726E657420436F6E74726F6C6C6572 26 28 8 2 csmcore && set lanar=1
exit /b

:bcmver
findver "     OROM Broadcom Boot Agent   - " 4252434D204D424100536C6F742030303030 20 00 7 1 csmcore && set lanbr=1
if exist tmp\lanb*.tmp for /f "tokens=*" %%b in ('dir tmp\lanb*.tmp /b') do drvver "tmp\%%b"
exit /b

:oromguid
if exist _OROM_in_FFS.txt del /f /q _OROM_in_FFS.txt
for /f %%f in ('dir "tmp\orom_GUID_*" /b') do (
echo - %%f
echo - %%f>>_OROM_in_FFS.txt
for /f %%a in ('findver "" 002456425420 06 64 15 1 tmp\%%f') do (
	for /f %%b in ('findver "" 002456425420 80 FF 4 1 tmp\%%f') do (
	echo      VBIOS %%a Version %%b
	echo      VBIOS %%a Version %%b>>_OROM_in_FFS.txt
	)
)
for /f "tokens=*" %%a in ('findver "     " 496E74656C2852292052617069642053746F7261676520546563686E6F6C6F677920  00 0A 80 2 tmp\%%f') do (
	echo      %%a
	echo      %%a>>_OROM_in_FFS.txt
)
for /f "tokens=*" %%a in ('findver "     " 496E74656C28522920426F6F74204167656E7420 00 00 72 2 tmp\%%f') do (
	echo      %%a
	echo      %%a>>_OROM_in_FFS.txt
)
for /f "tokens=*" %%a in ('findver "     " 496E74656C2852292069534353492052656D6F746520426F6F742076657273696F6E 00 0D 45 2 tmp\%%f') do (
	echo      %%a
	echo      %%a>>_OROM_in_FFS.txt
)
for /f "tokens=*" %%a in ('findver "     " 5265616C74656B2050434965204742452046616D696C79 00 0D 60 2 tmp\%%f') do (
	echo      %%a
	echo      %%a>>_OROM_in_FFS.txt
)
for /f "tokens=*" %%a in ('findver "     " 504349452045746865726E657420436F6E74726F6C6C6572 -8 0D 60 2 tmp\%%f') do (
	echo      %%a
	echo      %%a>>_OROM_in_FFS.txt
)
for /f "tokens=*" %%a in ('findver "" 4252434D204D424100536C6F742030303030 20 00 7 2 tmp\%%f') do (
	echo      Broadcom Ethernet Boot Agent %%a
	echo      Broadcom Ethernet Boot Agent %%a>>_OROM_in_FFS.txt
)

for /f "tokens=*" %%a in ('findver "" 4D617276656C6C203838534539 00 00 39 1 tmp\%%f') do (
	for /f %%b in ('findver "" 4D617276656C6C203838534539 41 00 10 1 tmp\%%f') do (
	echo      %%a %%b
	echo      %%a %%b>>_OROM_in_FFS.txt
	)
)
)
exit /b

:cba
set finfo=InfoBootAgent.txt & if exist #%finfo% del /f /q #%finfo%
set fbacl=BootAgentCL & if exist _%fbacl%*.lom del /f /q _%fbacl%*.lom
set fbage=BootAgentGE & if exist _%fbage%*.lom del /f /q _%fbage%*.lom

echo;
for /f "tokens=1,2" %%a in ('uefifind body list 426F6F74204167656E7420434C bios.bin') do (
    if %%a==A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
	echo Found Boot Agent CL & echo Found Boot Agent CL>>#%finfo%
	echo GUID    %%a & echo GUID    %%a>>#%finfo%
	echo SubGUID %%b & echo SubGUID %%b>>#%finfo%
	%mmt% /e /l tmp\BACL.lom %%a %%b
	for /f "eol=; tokens=1,2" %%d in (%sdl%\DevID_List_iCL.txt) do (
		hexfind 504349528680%%d tmp\BACL.lom>nul && echo Device ID %%e && echo Device ID %%e>>#%finfo% && setdevid %%e %sdl%\IntlOromCL.LOM _BootAgentCL_%%e.lom>nul && echo Create _%fbacl%_%%e.lom && echo Create _%fbacl%_%%e.lom>>#%finfo% && del tmp\bacl.lom && echo;
		)
	)
)

for /f "tokens=1,2" %%a in ('uefifind body list 426F6F74204167656E74204745 bios.bin') do (
    if %%a==A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
	echo Found Boot Agent GE & echo Found Boot Agent GE>>#%finfo%
	echo GUID    %%a & echo GUID    %%a>>#%finfo%
	echo SubGUID %%b & echo SubGUID %%b>>#%finfo%
	%mmt% /e /l tmp\BAGE.lom %%a %%b
	for /f "eol=; tokens=1,2" %%d in (%sdl%\DevID_List_iGE.txt) do (
		hexfind 504349528680%%d tmp\BAGE.lom>nul && echo Device ID %%e && echo Device ID %%e>>#%finfo% && setdevid %%e %sdl%\IntlOromGE.LOM _BootAgentGE_%%e.lom>nul && echo Create _%fbage%_%%e.lom && echo Create _%fbage%_%%e.lom>>#%finfo% && del tmp\bage.lom  && echo;		
	    )
	for /f "eol=; tokens=1,2" %%d in (%sdl%\DevID_List_iCL.txt) do (
		hexfind 504349528680%%d tmp\BAGE.lom>nul && echo Device ID %%e && echo Device ID %%e>>#%finfo% && setdevid %%e %sdl%\E1562X3.LOM _BootAgentGE_%%e.lom>nul && echo Create _%fbage%_%%e.lom && echo Create _%fbage%_%%e.lom>>%finfo% && del tmp\bage.lom  && echo;		
	    )
    )
)
echo;
pause
goto mn1

:rtkdel
echo;
for /f "tokens=1,2" %%b in ('uefifind body list 00005200650061006C00740065006B0020005500450046004900200055004E004400490020004400720069007600650072000000 bios.bin') do (
 	if %%b==A0327FE0-1FDA-4E5B-905D-B510C45A61D0 (
		%mmt% /d /l %%b %%c
	) else (
		%mmt% /d %%b
	)
	echo * Remove EFI Realtek LAN Undi GUID %%b %%c
)
del /f /q tmp\lanr_*.*>nul & set lanro=0 & set lanre=0 & echo;
pause
goto mn1