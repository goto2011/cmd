:: ================ CmdLite.bat, V1:2008-07-28 =============================
:: ================ by��duangan, email: duan.gandhi@gmail.com ==============

::Ϊ�淶������Ų�д����ָ�����¹淶��2008-11-04,V1����
::��1�������ļ�·�����������������ܴ�"\"��
::��2������if == �Ƚ���䣬��ʹ��/i���أ������Դ�Сд��
::��3��ע��ʹ��::��ʽ��ע�ʹ���ʹ�� rem ��ʽ��
::��4����ת������ʹ�� call ��ʽ���������� goto��ʽ��ԭ�п��ô��벻Ҫ���޸ġ�
::��5��ʹ�ñ���ʹ�ñ�׼��ʽ�������������ں���ͷ����set dst_dir=��������ʹ�á�ԭ�п��ô��벻Ҫ���޸ġ�

@echo off&setlocal EnableDelayedexpansion
@cls

set p1=%~1
if not defined p1 (goto cmd_begin)

for %%a in ("%cd%") do (set root_disk=%%~da)
rem for %%b in (%a%) do (set root_dir=%%~npb)
set root_dir=%cd%
@set cmd_file=%~0

:: ������Ҫ�ֹ��༭.
:: ����Զ�̼��������
@set remote_computer=\\d69678
@set remote_dir=\\d69678\V2�ű�
@set add_cmd=make_qsc_dbl_fsbl_osbl_sec_new.cmd

:: ���屾��Ĭ�Ϲ���·��
@set default_project=V735_B705_Debug_NoLog\code
@set back_root=f:\backup
@set ue32_exe=c:\"Program Files"\UltraEdit
@set bc_exe=d:\tools\"==Good=="\BeyondCompare3\BCompare.exe

:: ���̿���ʱʹ��
set src_priject_dir=\\c69681b\01_U1250V100R001\2008-12-06_V735V100R001C02B704SP02
set dst_priject_dir=z:\V735_B704_SP02
set dst_backup_dir=F:\code\QSC
:: Ĭ�Ϲ�������Ϊ 1250.
set product_id=u1250

@%root_disk%
@cd\
@cd %root_dir%

@if /i %p1%==?         goto help_print
@if /i %p1%==/?        goto help_print
@if /i %p1%==help      goto help_print
@if /i %p1%==cp        goto compile_begin
@if /i %p1%==o_list    goto show_o_list
@if /i %p1%==kill_scan goto kill_virus_scan
@if /i %p1%==ue        goto compile_begin
@if /i %p1%==xcopy     goto compile_begin
@if /i %p1%==sync      goto sync_cmd
@if /i %p1%==copy_prj  goto copy_prj_cmd
@if /i %p1%==sys_clear goto sys_clear_cmd
@if /i %p1%==send_email goto send_email_cmd
@if /i %p1%==del_usb_driver goto del_usb_cmd
@if /i %p1%==ppt2doc        goto ppt2doc_cmd
@if /i %p1%==ftp_ex         goto ftp_ex_cmd
@if /i %p1%==lib_list       goto show_lib_list else goto err


:help_print
@echo   === Help: welcome to cmd root.===
@echo   cmd list:
@echo   0.?:          Get help.
@echo   1.cp:         Compile project(add ' ?' for project list.)
@echo   2.o_list:     List verify .o file's func.(support * and ? to muilt files.)
@echo   3.lib_list:   List verify .lib file's func.(for one file.)
@echo   4.get_c:      Get pre_compile file from a .c file.(not support)
@echo   5.kill_scan:  Kill virus scan program.
@echo   6.ue:         Open UltraEdit-32.
@echo   7.xcopy:      Copy quicker.em/screendriver.mod/camsensordriver.mod to curretn project.(2008-10-09)
@echo   8.sync:       Sync files.(2008-10-11)
@echo   9.copy_prj:   Copy a project and build a SI project.(2008-10-18)
@echo   10.sys_clear:   Clear system temp files and trash.(2008-11-11)
@echo   11.send_email:  Send_email.(2008-11-11)
@echo   12.del_usb_driver:  Delete huawei USB driver.(2008-11-25)
@echo   13.ppt2doc:  Transfer ppt file to doc file(only text)(2008-11-27)
@echo   14.ftp_ex:   ftp client cmd(2008-12-12)


@echo   === create by duangan 2008-08-28. Finished at 2008-11-11.===
@goto END


:show_o_list
@if not exist tools (md tools)
@cd %default_project%\build\ms\%product_id%
@call ads12
@if exist a.lib del a.lib
@armar -r a.lib %~2 %~3 %~4 %~5 %~6 %~7 %~8 %~9
@armar -zs a.lib > %root_dir%\tools\o_list.txt
@if exist a.lib del a.lib
@echo ��鿴�ļ�: tools\o_list.txt
@goto END


:show_lib_list
@if not exist tools (md tools)
@cd %default_project%\build\ms\%product_id%
@call ads12
@armar -zs %~2 > %root_dir%\tools\lib_list.txt
@@echo ��鿴�ļ�: tools\lib_list.txt
@goto END


:kill_virus_scan
@net stop "Symantec AntiVirus"
@taskkill /IM defwatch
@taskkill /IM rtvscan
@goto END


:: ======================================================
:: ==================compile begin!!!====================
:: ======================================================

:compile_begin
set p2=%~2
if not defined p2 (goto compile_help)

@if /i %p2%==716  (
		set project_dir=U1250_C23_B716\code
		set product_id=u1250_SWE_Telia
		set product_dir=u1250)
		
@if /i %p2%==33 (
		set project_dir=U1250_C23_B716\code
		set product_id=u1250_SWE_Telia
		set product_dir=u1250)


@if /i %p2%==B715SP01  (
		set project_dir=V735_B715SP01\code
		set product_id=u1250
		set product_dir=u1250)
		
@if /i %p2%==34 (
		set project_dir=V735_B715SP01\code
		set product_id=u1250
		set product_dir=u1250)


@if /i %p2%==1290_B020SP03  (
		set project_dir=U1290_B020SP03\code
		set product_id=u1290
		set product_dir=u1290)
		
@if /i %p2%==35 (
		set project_dir=U1290_B020SP03\code
		set product_id=u1290
		set product_dir=u1290)


@if /i %p2%==1290_B021_SBA  (
		set project_dir=U1290_B021_1382010A\code
		set product_id=u1290
		set product_dir=u1290)
		
@if /i %p2%==36 (
		set project_dir=U1290_B021_1382010A\code
		set product_id=u1290
		set product_dir=u1290)

@if /i %p2%==U1250_B717SP02  (
		set project_dir=U1250_B717SP02\code
		set product_id=u1250-VIRGIN
		set product_dir=u1250)
		
@if /i %p2%==37 (
		set project_dir=U1250_B717SP02\code
		set product_id=u1250-VIRGIN
		set product_dir=u1250)


@if /i %p2%==U1290_B027sp02  (
		set project_dir=U1290_B027sp02\code
		set product_id=U1290
		set product_dir=u1290)
		
@if /i %p2%==38 (
		set project_dir=U1290_B027sp02\code
		set product_id=U1290
		set product_dir=u1290)


@if /i %p2%==U1280h_B717SP01  (
		set project_dir=U1280h_B717SP01\code
		set product_id=U1280h
		set product_dir=u1280h)

@if /i %p2%==39 (
		set project_dir=U1280h_B717SP01\code
		set product_id=U1280h
		set product_dir=u1280h)
		
		
@if /i %p2%==U1250_B718SP01  (
		set project_dir=U1250V100R001PRTC75B718SP01_Debug_Log_Factory\code
		set product_id=u1250_factory_image
		set product_dir=u1250)

@if /i %p2%==40 (
		set project_dir=U1250V100R001PRTC75B718SP01_Debug_Log_Factory\code
		set product_id=u1250_factory_image
		set product_dir=u1250)
			
set compile_cmd=%product_id%.cmd

@if /i %p2%==?  	  goto compile_help
@if /i %~1==cp 			goto compile
@if /i %~1==ue 			goto open_ue32
@if /i %~1==xcopy 	goto my_xcopy


:compile_help
@echo   === Help: welcome to cmd root.===
@echo   Project list:
@echo   1.sd:     SD_update project(�Ѿ�copy������Ŀ¼)  *unuse*
@echo   2.usb:    USB_update project(���.o���ļ�)       *unuse*
@echo   3.41b:    SD+41B project(���.o���ļ�)           *unuse*
@echo   4.test:   test project for USB update performance. *unuse*
@echo   5.b02:    B002(��ʽ�汾,2008-08-11) project *unuse*
@echo   6.1210:   1210(on 1210,2008-09-10;for case) project *unuse*
@echo   7.009 :   009(on 1210,2008-09-18;for USB debug) project *unuse*
@echo   8.010 :   010(��ΪB10����,2008-09-28) for sd update(AR1D00413\AR1D00414). *unuse*
@echo   9.q_1210 :Q_1210(��ͨ1210����,2008-10-10) for sd update(AR1D00413\AR1D00414). *unuse*
@echo   9.010_u : 010(��ΪB10����,2008-10-15) for sd update(��8�Ļ����ϻ���sd����������). *unuse*
@echo   10.012 :  012(��ΪB12����,2008-10-18) for sd update(AR1D00413\AR1D00414).
@echo   11.013 :  013(��ΪB13����,2008-10-27) for usb update(AR1D00501). *unuse*
@echo   12.015 :  015(��ΪB15����,2008-11-07) for File update(AR1D00531). *unuse*
@echo   13.017 :  017(��ΪB17����,2008-11-14) for FSBL security solution(AR1D00569). *unuse*
@echo   14.703 :  703(��Ϊ703����,2008-11-22) for FSBL security solution(AR1D00569/AR1D00678). *unuse*
@echo   15.704 :  704SP02(��Ϊ704SP02����,2008-12-08) for AR1D00957. *unuse*
@echo   16.705 :  705(��Ϊ1260 705����,2008-12-19). *unuse*
@echo   17.V736_705 :       3210_705(��Ϊ V736 705����,2008-12-25) for SD update fail. *unuse*
@echo   18.V835_705SP02 :   6100_705SP02(��Ϊ V835_705SP02����,2008-12-29)for root crack. *unuse*
@echo   19.V835_706 :       V835_706(��Ϊ V835_706 ����,2009-01-12)for un-display during update. *unuse*
@echo   20.706 :            V735_706(��Ϊ V735_706 ����,2009-01-14)for sd card error during MMI test. *unuse*
@echo   21.707sp01 :        V735_707sp01(��Ϊ V735_707sp01 ����,2009-01-22)for partiton update.
@echo   22.708 :            V735_708(2009-02-07)for SD card icon.
@echo   23.708sp01 :        V735_708sp01(2009-02-17)for SD card.
@echo   24.709 :            V735_709(2009-02-28)for SD card and vvs resume.
@echo   25.710 :            V735_710(2009-03-03)for SD card.
@echo   26.710SP01 :        V735_710SP01(2009-03-10)for AR1D02630(oeminfo dload_id).
@echo   27.710SP02 :        V735_710SP02(2009-03-20)for SD card problem.
@echo   28.711 :            V735_711(2009-03-20)for SD card problem.
@echo   29.711SP01 :        V735_B711SP01(2009-03-26)for update customEFS by trace.
@echo   30.711SP03 :        V735_B711SP03(2009-03-30)for SD card problem.
@echo   31.711SP03_2 :      V735_B711SP03(2009-04-07)for erase file version[AR1D03456].
@echo   32.712 :            V735_B712(2009-04-08)for SD card DMA fail.
@echo   33.716 :            U1250_C23_B716(2009-05-22)for auto switch operator fail.
@echo   34.V735_B715SP01 :  V735_B715SP01(2009-05-23)for sd case.
@echo   35.1290_B020SP03 :  U1290_B020SP03(2009-05-28)for fast dump.
@echo   36.1290_B021_SBA :  1290_B021_SBA(2009-06-04)for sd card compatibility from QC SBA.
@echo   37.U1250_B717SP02 : U1250_B717SP02(2009-07-16)for �Ĵ����ǰ汾�ָ�������������(base 1360).
@echo   38.U1290_B027sp02 : U1290_B027sp02(2009-07-18)1290 ���°汾��������֤����(base 1382+030A SBA).
@echo   39.U1280h_B717SP01: U1280h_B717SP01(2009-07-13)Q05A base 1382 version.
@echo   40.U1250_B718SP01:  U1250_B718SP01(2009-07-28)Q05A base 1360 version for dload error with no lcd.

@echo   === create by duangan 2009-05-22.===
@goto END



:compile
cd %project_dir%\build\ms
call ads12
rem copy %root_dir%\%cmd_file%  %cmd_file% /y

set p3=%~3
set p4=%~4
if not defined p3 (goto compile_all)
if /i %p3%==boot goto compile_boot
if /i %p3%==ue   goto open_ue32
if /i %p3%==map  call :open_map_file %p4%
goto compile_all
@goto END

:compile_all
@echo cp_all
call %compile_cmd% %~3 %~5 %~6 %~7 %~8 %~9
@goto compile_end


:compile_boot
@echo cp_boot
call %compile_cmd% doosbl dofsbl dodbl %~4 %~5 %~6 %~7 %~8 %~9
@goto compile_end


:compile_end
set copy_objects=

set copy_objects=amss.mbn\dbl.mbn\fsbl.mbn\osbl.mbn\oemlogo.mbn\camsensordriver.mod\screendriver.mod\partition.mbn
call :copy_mbn %copy_objects%
call :my_xcopy setl4path
call :my_xcopy quicker
call :my_xcopy screendriver
call :my_xcopy camsensordriver

net time %remote_computer%

:: create a task to call cmd
:: schtasks /create /tn %add_cmd% /tr %remote_dir% /sc ONCE /s %remote_computer% /st (time /t)
@goto END

:: copy mbn file from project to pack dir.
:copy_mbn
  set my_copy_objects=%~1
  set copy_object1=
  set copy_object2=
  
	for /f "tokens=1* delims=\" %%a in ("%my_copy_objects%") do (
		set copy_object1=%%a
		set copy_object2=%%b
		
    copy bin\%product_dir%\!copy_object1! %remote_dir% /y
    
 		if /i !copy_object1!==camsensordriver.mod (
 			 copy ..\..\dll_mod\dll_camera\mod\ADS12_ARM7\!copy_object1! %remote_dir% /y
 		)
		 
		if /i !copy_object1!==screendriver.mod (
		   copy ..\..\dll_mod\dll_lcd\mod\ADS12_ARM7\!copy_object1! %remote_dir% /y
		)
	   
	  call :copy_mbn !copy_object2!
  )
  goto :EOF


:: ����Ϊ������ amss/dbl/fsbl/osbl
:open_map_file
  set my_open_object=%~1
  set my_map_file=
  
  if /i %my_open_object%==amss set my_map_file=build\ms\%product_dir%.map
  if /i %my_open_object%==dbl set my_map_file=romboot\sbl\dbl\dbl_%product_dir%.map
  if /i %my_open_object%==fsbl set my_map_file=romboot\sbl\fsbl\fsbl_%product_dir%.map
  if /i %my_open_object%==osbl set my_map_file=romboot\osbl\osbl_%product_dir%.map
  
  cd\
  cd %root_dir%\%project_dir%
  @%ue32_exe%\uedit32 %my_map_file%
  @goto END


:open_ue32
  set log_file_name=build\ms\build%product_dir%.log
  
  cd\
  cd %root_dir%\%project_dir%
  @%ue32_exe%\uedit32 %log_file_name%
  @goto END


:: ��һ������Ϊcopy�ļ��������У��ڶ����͵�������ѡ��
:my_xcopy
set dst_dir=
set res_dir=
set res_file=

set dst_dir=%~2
set res_dir=%~3
set res_file=%~1

if /i %res_file%==setl4path (
	if not defined res_dir (set res_dir=%root_dir%\tools)
	if not defined dst_dir (set dst_dir=%root_dir%\%project_dir%)
	set dst_dir=!dst_dir!\build\ms\cmm
	set res_file=setl4path.cmm
	)
	

if /i %res_file%==quicker (
	if not defined res_dir (set res_dir=%root_dir%\tools)
	if not defined dst_dir (set dst_dir=%root_dir%\%project_dir%)
	set dst_dir=!dst_dir!\apps\mha\tools\insightmacros
	set res_file=quicker.em
	)
	
if /i %res_file%==screendriver (
	if not defined res_dir (set res_dir=%root_dir%\%project_dir%)
	if not defined dst_dir (set dst_dir=%root_dir%\%project_dir%)
	set res_dir=!res_dir!\dll_mod\dll_lcd\mod\ADS12_ARM7
	set dst_dir=!dst_dir!\build\ms\bin\%product_dir%
	set res_file=screendriver.mod
	)
	
if /i %res_file%==camsensordriver (
	if not defined res_dir (set res_dir=%root_dir%\%project_dir%)
	if not defined dst_dir (set dst_dir=%root_dir%\%project_dir%)
	set res_dir=!res_dir!\dll_mod\dll_camera\mod\ADS12_ARM7
	set dst_dir=!dst_dir!\build\ms\bin\%product_dir%
	set res_file=camsensordriver.mod
	)
	
copy %res_dir%\%res_file% %dst_dir% /y
@goto :EOF


:: ======================================================
:: ==================compile end==!!!====================
:: ======================================================

:cmd_begin
@cmd.exe /k cd.
goto :EOF


:: ���ִ��������з�֧�š�
:sys_clear_cmd
echo �������ϵͳ�����ļ������Ե�......
del /f /s /q %systemdrive%\*.tmp
del /f /s /q %systemdrive%\*._mp
del /f /s /q %systemdrive%\*.log
del /f /s /q %systemdrive%\*.gid
del /f /s /q %systemdrive%\*.chk
del /f /s /q %systemdrive%\*.old
del /f /s /q %systemdrive%\recycled\*.*
del /f /s /q %windir%\*.bak
del /f /s /q %windir%\prefetch\*.*
rd /s /q %windir%\temp & md %windir%\temp
rem del /f /q %userprofile%\cookies\*.*
del /f /q %userprofile%\recent\*.*
del /f /s /q "%userprofile%\Local Settings\Temporary Internet Files\*.*"
del /f /s /q "%userprofile%\Local Settings\Temp\*.*"
del /f /s /q "%userprofile%\recent\*.*"
del /f /s /q %temp%\*.*
del /f /s /q %tmp%\*.*

echo ���ϵͳLJ��ɣ�
echo. & pause

goto END 


:: ���������з�֧��
::sendEmail.exe-1.52 by Brandon Zehm <caspian@dotconf.net>
::Synopsis:  sendEmail.exe -f ADDRESS [options]
::  Required:
::    -f ADDRESS                from (sender) email address
::    * At least one recipient required via -t, -cc, or -bcc
::    * Message body required via -m, STDIN, or -o message-file=FILE
::  Common:
::    -t ADDRESS [ADDR ...]     to email address(es)
::    -u SUBJECT                message subject
::    -m MESSAGE                message body
::    -s SERVER[:PORT]          smtp mail relay, default is localhost:25
::  Optional:
::    -a   FILE [FILE ...]      file attachment(s)
::    -cc  ADDRESS [ADDR ...]   cc  email address(es)
::    -bcc ADDRESS [ADDR ...]   bcc email address(es)
::  Paranormal:
::    -xu USERNAME              authentication user (for SMTP authentication)
::    -xp PASSWORD              authentication password (for SMTP authentication)
::    -l  LOGFILE               log to the specified file
::    -v                        verbosity, use multiple times for greater effect
::    -q                        be quiet (no stdout output)
::    -o NAME=VALUE             see extended help topic "misc" for details
::  Help:
::    --help TOPIC              The following extended help topics are available:
::        addressing            explain addressing and related options
::        message               explain message body input and related options
::        misc                  explain -xu, -xp, and others
::        networking            explain -s, etc
::        output                explain logging and other output options
:send_email_cmd
echo ���ڷ���email�����Ե�......
@set SEND_EMAIL_CMD=%root_dir%\tools\sendEmail.exe
@set SMTP_SERVER=smtp.huawei.com
@set ID=d69678
@set send_id=69678@notesmail.huawei.com
@set receive_id=69678@notesmail.huawei.com
@set cc_id=69678@notesmail.huawei.com

%SEND_EMAIL_CMD% -f "%send_id%" -t "%receive_id%" -u "3GLT V200R006C02 ( UCC SourceMonitor Results of Today ) %DATE%" -s "%SMTP_SERVER%" -m " You have received this email because you asked to be notified. Please open the following files to see the details . Thank you ! " -a ".\file_list.txt" -a ".\file_list_trim.txt" -cc "%cc_id%"
goto END


:: �����Ϊusb����.
:del_usb_cmd
del c:\windows\inf\hwmdm.inf
del c:\windows\inf\hwmdm.PNF
del c:\windows\inf\hwser.inf
del c:\windows\inf\hwser.PNF
del c:\windows\inf\hwusb.inf
del c:\windows\inf\hwusb.PNF
del c:\windows\system32\drivers\hwusbser.sys
del c:\windows\system32\drivers\hwusbapp.sys
del c:\windows\system32\drivers\hwusbmdm.sys

del C:\WINDOWS\LastGood\system32\DRIVERS\hwusbser.sys
del C:\WINDOWS\LastGood\system32\DRIVERS\hwusbapp.sys
del C:\WINDOWS\LastGood\system32\DRIVERS\hwusbmdm.sys

del c:\winnt\inf\hwmdm.inf
del c:\winnt\inf\hwmdm.PNF
del c:\winnt\inf\hwser.inf
del c:\winnt\inf\hwser.PNF
del c:\winnt\inf\hwusb.inf
del c:\winnt\inf\hwusb.PNF
del c:\winnt\system32\drivers\hwusbser.sys
del c:\winnt\system32\drivers\hwusbapp.sys
del c:\winnt\system32\drivers\hwusbmdm.sys

del d:\winnt\inf\hwmdm.inf
del d:\winnt\inf\hwmdm.PNF
del d:\winnt\inf\hwser.inf
del d:\winnt\inf\hwser.PNF
del d:\winnt\inf\hwusb.inf
del d:\winnt\inf\hwusb.PNF
del d:\winnt\system32\drivers\hwusbser.sys
del d:\winnt\system32\drivers\hwusbapp.sys
del d:\winnt\system32\drivers\hwusbmdm.sys
goto END



::�˽ű�����������ppt�ļ��е��ı�ת��Ϊword�ļ���ͼƬ�������������Զ�����
:ppt2doc_cmd
'�˽ű�����������ppt�ļ��е��ı�ת��Ϊword�ļ���ͼƬ�������������Զ�����
'�ű���ÿһ�ж�������ϸ��ע�⣬�ɸ����Լ�����Ҫ��è������
'ʹ���������⻶ӭ������ϵ����������p_168@163.com
'��ӭ�����ҵļ�������:http://diylab.cnblogs.com
'�󶨵����ؼ����
strComputer = "."
'����������󣬼���ִ��
on error resume next
Set objWMIService = GetObject("winmgmts:" _
 & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
msgbox "�˽ű�����������ppt�ļ��е��ı�ת��Ϊword�ļ���ͼƬ�������������Զ�����" & vbcrlf & "ʹ��ʱ�������Ҫת����ppt�ļ����Ƶ�Ŀ¼d:\1\�¡�˫�����д��ļ����ɡ�" & vbcrlf & "���д˽ű���Ҫ�����ϰ�װ��office"
'����һ��word����
Set objWord = CreateObject("Word.Application")
'����һ��ppt����
Set pptApp = CreateObject("PowerPoint.application")
'���c:\Ŀ¼�µ��ļ�����
Set FileList = objWMIService.ExecQuery _
 ("ASSOCIATORS OF {Win32_Directory.Name='d:\1'} Where " _
     & "ResultClass = CIM_DataFile")
For Each objFile In FileList
'����ļ�����չ����ppt
If objFile.Extension = "ppt" Or objFile.Extension = "pps" Then
pptApp.visible = true
'�����ppt�ļ�
Set pptSelection = pptApp.Presentations.Open("d:\1\" & objFile.FileName & "." & objFile.Extension)

'������ýű�����ÿ�Щ��������һ�и�Ϊ"objWord.Visible = false",���Ƽ���
objWord.Visible = true
'�½�һ��word���Ա���ppt�е��ı�
Set objDoc = objWord.Documents.Add()
Set objSelection = objWord.Selection
  '��ppt�ĵ�һҳ��ʼѭ����Slides.Count���õ�Ƭ������
  For i = 1 To pptSelection.Slides.Count
    '��ÿһ��ppt�ĵ�һ���ı���ʼѭ����Shapes.Count����ÿ�Żõ�Ƭ���ı��������
    For j = 1 To pptSelection.Slides(i).Shapes.Count
      If pptSelection.Slides(i).Shapes(j).TextFrame.TextRange.text <> vbcrlf Then
        '�����ÿҳ�ĵ�һ�У��Ͱ����⴦����ɺ�����     
        if i =1 then
          objSelection.Font.Name = "����"
          '���ı����е�������ӵ�word��
          objSelection.TypeText  pptSelection.Slides(i).Shapes(j).TextFrame.TextRange.text
          'objSelection.TypeParagraph()
        Else
          objSelection.Font.Name = "����"
          objSelection.TypeText  pptSelection.Slides(i).Shapes(j).TextFrame.TextRange.text
        End If
      End If
      
      '��һ���س�
      objSelection.TypeText  vbcrlf
    Next
      
    '��һ���س�
    objSelection.TypeText  vbcrlf
  Next
'�ر����ppt�ļ�
pptSelection.close
'����word�ļ���
objDoc.SaveAs("d:\1\" & objFile.FileName & ".doc")
'�������Ҫ�ر�word����������һ��ɾ��
objDoc.close
'������뵯����Ϣ�򣬰�������һ��ɾ��
'msgbox "ת�����word�ѱ�����d:\1\" & objFile.FileName & ".doc"
else  'û��ppt�ļ�
'msgbox "����d:\��û�з���ppt�ļ���"
 End If
Next
pptApp.quit
goto END


:: ��ν��ǿ��Ҳֻ��ʵ��������/����Ŀ¼���Ĺ��ܣ��������ű��ṩ��һ���ܺõ�˼·����˵�Ǽܹ���
:: ����ѭ��ͬ��Ʒ�ʽ����չʵ���������ܡ�
:: ע�⣺
:: 1���ýű�ǿ�����ǿ��ٷ��㣬�����쳣����δ�Ӵ�������FTP�û��������������ʱFTPĿ¼�����ɶ�������ʱ��FTPĿ¼����д��δ���ж���
:: 2��Ϊ���̶ȵļ���FTP�Ự���̣�����ʱ�����ر���Ŀ¼�������ļ��ͷ�������Ŀ¼�ṹ��ϵ���һ�����Ա��뱣֤�м䲻���ж�Ȩ�����⣨��������cd������Ŀ¼�����������ֻ��ҵĽ����ʼ��cd����Ŀ��·����һֱͣ�ڵ�ǰ·������
:: 3������һЩFTP����������mget/mput *�����̶Ȳ���һ�£���ǰ��ʹ��mget/mput *.*���ϴ�������Ŀ¼�������ļ���Ҳ���ǲ�֧�ֲ�����չ�����ļ���
:: 4��֧�ֺ��ո�ı���Ŀ¼��Զ��Ŀ¼��
:: 5������WinXP + Solaris��Pureftpd��������ͨ����
:: from �з�֧��  zhuliangsheng 00107233 ���� 2008-12-12 13:53:41
:ftp_ex_cmd
:: configuration section
set "FTP_SERVER=10.10.10.10"
set "FTP_PORT=21"
set "FTP_USERNAME=ftpuser"
set "FTP_PASSWORD=ftpuser"
set "REMOTE_DIR=/remote/test"
set "LOCAL_DIR=D:\local\test"

call :uploaddir "%LOCAL_DIR%" "%REMOTE_DIR%"
call :downloaddir "%REMOTE_DIR%" "%LOCAL_DIR%.cicle"
goto :eof

:uploaddir - upload directory tree
::           - %~1 local directory
::           - %~2 remote directory
setlocal

set "localdir=%~1"
set "remotedir=%~2"

echo "%localdir%" ----^> "%remotedir%"

call :autoftp cmdftp_uploaddir "%localdir%" "%remotedir%">nul

for /D %%I in ("%localdir%\*") do (
    call :uploaddir "%localdir%\%%~nxI" "%remotedir%/%%~nxI"
)

endlocal
goto :eof


:cmdftp_uploaddir - ftp commands for upload directory tree
::                  - %~1 local directory
::                  - %~2 remote directory
echo lcd "%~1"
echo mkdir "%~2"
echo cd "%~2"
echo binary
echo prompt
echo mput *.*
goto :eof


:downloaddir - download directory tree
::           - %~1 remote directory
::           - %~2 local directory
setlocal

set "remotedir=%~1"
set "localdir=%~2"

echo "%remotedir%" ----^> "%localdir%"
if not exist "%localdir%\" mkdir "%localdir%"

set "cmdout=_cmdout_"
call :autoftp cmdftp_downloaddir "%remotedir%" "%localdir%">"%cmdout%"

for /F "tokens=1 delims=:" %%I in ('findstr /N /X "{{{" "%cmdout%"') do set "begin=%%I"
for /F "tokens=1 delims=:" %%I in ('findstr /N /X "}}}" "%cmdout%"') do set "end=%%I"

set "dirout=_dirout_"
call :echolines "%cmdout%" %begin% %end% >"%dirout%"
del /Q "%cmdout%"

for /F "tokens=8*" %%I in ('findstr /R "^d" "%dirout%"') do (
    call :downloaddir "%remotedir%/%%~J" "%localdir%\%%~J"
)
if exist "%dirout%" del /Q "%dirout%"

endlocal
goto :eof


:cmdftp_downloaddir - ftp commands for download directory tree
::                  - %~1 remote directory
::                  - %~2 local directory
echo cd "%~1"
echo lcd "%~2"
echo binary
echo prompt
echo mget *.*
echo !echo {{{
echo dir
echo !echo }}}
goto :eof


:autoftp - a complete ftp interaction
::       - %* ftp command label and arguments
setlocal

set "ftpin=_ftpin_"
(call :preftp & call :%* & call :postftp)>>"%ftpin%"
ftp -n <"%ftpin%"
del /Q "%ftpin%"
endlocal

goto :eof


:preftp - setup the ftp session
echo open %FTP_SERVER% %FTP_PORT%
echo user %FTP_USERNAME% %FTP_PASSWORD%
goto :eof


:postftp - teardown the ftp session
echo quit
goto :eof


:echolines - echo special lines
::         - %~1 file name
::         - %~2 begin line number
::         - %~3 end line number
setlocal

set "file=%~1"
set /A begin=%~2
set /A end=%~3
set "options=tokens=1* delims=:"
set /A skips=%begin%-1
if %skips% GTR 0 set "options=skip=%skips% %options%"
for /F "%options%" %%I in ('findstr /N .* "%file%"') do (
    echo %%J
    if %%I GEQ %end% goto :endfor
)
:endfor

endlocal
goto :eof



:: ���ݽű��ļ�
:sync_cmd
set back_dir=

%bc_exe% %root_dir%\   \\d69678b\d$\duangan
%bc_exe% %root_dir%\   \\j45962h\d$\duangan

@set data=%date:~0,4%-%date:~5,2%-%date:~8,2%_%time:~0,2%_%time:~3,2%_%time:~6,2%
set back_dir=%back_root%\%data%

if not exist %back_root%\nul (md %back_root%)
if not exist %back_dir%\nul (md %back_dir%)
copy %root_dir%\%cmd_file%  %back_dir%\
copy %root_dir%\caselite.bat  %back_dir%\
copy %root_dir%\file_list.txt  %back_dir%\
copy %root_dir%\file_list_trim.txt  %back_dir%\

goto :END


::�޸ĸ���Ŀ��·����Դ·��.
:copy_prj_cmd
xcopy %src_priject_dir% %dst_priject_dir%\ /c /v /s /e /y /z /i
call :my_xcopy quicker %dst_priject_dir%\code
call :my_xcopy screendriver %dst_priject_dir%\code %src_priject_dir%\code
call :my_xcopy camsensordriver %dst_priject_dir%\code %src_priject_dir%\code

rem xcopy %src_priject_dir% %dst_backup_dir%\ /c /v /s /e /y /z /i

if errorlevel 4 goto lowmemory
if errorlevel 0 goto END
goto END

:lowmemory
echo �ռ䲻�㡣
goto END 







:err
echo command error
goto help_print



:END
@cd\
@%root_disk%
@cd %root_dir%
endlocal
