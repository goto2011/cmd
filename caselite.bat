:: ================ CaseLite.bat, V1:2008-09-19 =============================
:: ================ CaseLite.bat, V2:2010-07-07 =============================
:: ================ by��duangan, email: duan.gandhi@gmail.com ==============

@echo off&setlocal EnableDelayedexpansion
@cls
@set root_dir=%cd%
@set data=%date:~0,4%-%date:~5,2%-%date:~8,2%

::���������޸ģ�����
@set produce_type=7x30
@set case_id=DTS2010082100042
@set lint_root=C:\Lint
@set author_name=duangan

:: call :system_side_call ap
call :system_side_call modem

goto :end

:system_side_call
:: ap or modem
@set system_side=%~1
echo %system_side%

@if /i %system_side%==modem set work_project=\\10.111.93.22\g$\project_jiazhifeng\0815\update
@if /i %system_side%==ap set work_project=\\10.111.76.100\duangan\android_7x30_0821
:: 

:: \\h00105634\UIone_h00105634\uione_QSC_DRV\U9100\code
:: @if /i %produce_type%==UIOne set CC_root=\\w125598a\SVN\uione_QSC_DRV\U9100\code
:: @if /i %produce_type%==Q05A set CC_root=\\l45499d\QSC_CCVIEW\QSC_VIEW_main\WT_MOBILE_A03_CODE\HUAWEI-U1300_U3300\code\6240

@if /i %system_side%==modem set CC_root=E:\code\7x30_1280
@if /i %system_side%==modem set branch_id=br_modem_7x30_1280

@if /i %system_side%==ap set CC_root=\\10.111.76.100\duangan\svn_only\7x30_1280
@if /i %system_side%==ap set branch_id=br_Froyo_7x30_1280


::======================================================
::==================step1:create "_new" ================
::======================================================
:step1
set case_dir_name=

set case_dir_name=%root_dir%\%case_id%-%author_name%-%data%
@if /i %system_side%==modem set case_dir_name=%case_dir_name%_modem
@if /i %system_side%==ap set case_dir_name=%case_dir_name%_android

if exist %case_dir_name% rd %case_dir_name%/s/q
md %case_dir_name%

::======================================================
::==================step2:trim file list ===============
::======================================================
:step2
set file_list_ori=
set file_list_trim=
set file_name=
set dir_name=
set last_path=
set dir_head=
set file_name1=
set file_name2=

@if /i %system_side%==modem set file_list_ori=file_list_modem.txt
@if /i %system_side%==ap set file_list_ori=file_list_ap.txt
set file_list_trim=file_list_trim.txt
if exist %file_list_trim% (del %file_list_trim%)

for /f "tokens=1-2 delims=()" %%i in (%file_list_ori%) do (
	set file_name=%%i
	set dir_name=%%j
	
	if /i not !dir_name!\!file_name!==!last_path! (
  	::����д��ĸ���Сд��ĸ
  	rem for %%i in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do call set str=%%str:%%i=%%i%%
	  for %%i in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do call set file_name=%%file_name:%%i=%%i%%
	
    set last_path=!dir_name!\!file_name!
	set dir_head=!dir_name:~0,5!
	  
	  if /i !dir_head!==code\  (set dir_tail=!dir_name:~5!)else (set dir_tail=!dir_name!)
	  
		set file_name1=!work_project!\!dir_head!\!dir_tail!\!file_name!
		set file_name2=!work_project!\!dir_tail!\!file_name!
		echo !file_name1!
		
		if exist !file_name1!  echo !dir_head!\!dir_tail!\!file_name!>>!file_list_trim!
	    if exist !file_name2!  echo !dir_tail!\!file_name!>>!file_list_trim!
	)
)

rem move %file_list_trim& %file_list_ori%

::======================================================
::==================step3:cpy file to "_new" dir =======
::======================================================
:step3
set file_list_trim=
set case_dir_new=
set s3_file_route=
set s3_file_name=
set s3_curr_route=

cd %root_dir%
set file_list_trim=file_list_trim.txt
set case_dir_new=%case_dir_name%\_NEW
if exist %case_dir_new% rd %case_dir_new%/s/q
md %case_dir_new%

if /i %system_side%==ap (
  set case_dir_new=%case_dir_name%\_NEW\android
  md %case_dir_new%)
  
if /i %system_side%==modem (
  set case_dir_new=%case_dir_name%\_NEW\modem
  md %case_dir_new%)
  
if /i %produce_type%==Q05A (
  set case_dir_new=%case_dir_name%\_NEW\code\6240
  md %case_dir_new%)

for /f "tokens=1*" %%i in (%file_list_trim%) do (
	set s3_file_route=%%i
	set s3_file_name=%%~nxi
	echo -----------begin_new--------------
	echo !s3_file_route!
	echo !s3_file_name!
	
	cd %case_dir_new%
	set s3_curr_route=%case_dir_new%
	call :create_dir !s3_file_route!
	
	rem cpy file!
  copy %work_project%\!s3_file_route! %case_dir_new%\!s3_file_route!
)

goto :step4

:create_dir
  set s3_dir_name1=
  set s3_dir_name2=
  set s3_dir_name3=
  
  set s3_dir_name1=%~1

	for /f "tokens=1* delims=\" %%a in ("%s3_dir_name1%") do (
		set s3_dir_name2=%%a
		set s3_dir_name3=%%b
  )
  		
  if /i !s3_dir_name2!==!s3_file_name! goto :EOF
	
  set s3_curr_route=%s3_curr_route%\!s3_dir_name2!
  if not exist %s3_curr_route% md %s3_curr_route%
  cd %s3_curr_route%
  echo %s3_curr_route%
  call :create_dir !s3_dir_name3!

  goto :EOF


::======================================================
::==================step4:cpy file to "_old" dir =======
::======================================================
:step4
set file_list_trim=
set case_dir_old=
set s3_file_route=
set s3_file_name=
set s3_curr_route=

cd %root_dir%
set file_list_trim=file_list_trim.txt
set case_dir_old=%case_dir_name%\_OLD
if exist %case_dir_old% rd %case_dir_old%/s/q
md %case_dir_old%

if /i %system_side%==ap (
  set case_dir_old=%case_dir_name%\_OLD\android
  md %case_dir_new%)
  
if /i %system_side%==modem (
  set case_dir_old=%case_dir_name%\_OLD\modem
  md %case_dir_new%)
  
if /i %produce_type%==Q05A (
  set case_dir_old=%case_dir_name%\_OLD\code\6240
  md %case_dir_old%)

for /f "tokens=1*" %%i in (%file_list_trim%) do (
	set s3_file_route=%%i
	set s3_file_name=%%~nxi
	echo -----------begin_old--------------
	echo !s3_file_route!
	echo !s3_file_name!
	
	cd %case_dir_old%
	set s3_curr_route=%case_dir_old%
	call :create_dir !s3_file_route!
	
	rem cpy file!
  copy %CC_root%\!s3_file_route! %case_dir_old%\!s3_file_route!
)
goto :step5


:create_dir
  set s3_dir_name1=
  set s3_dir_name2=
  set s3_dir_name3=
  
  set s3_dir_name1=%~1

	for /f "tokens=1* delims=\" %%a in ("%s3_dir_name1%") do (
		set s3_dir_name2=%%a
		set s3_dir_name3=%%b
  )
  		
  if /i !s3_dir_name2!==!s3_file_name! (
  	goto :EOF
	)
	
  set s3_curr_route=%s3_curr_route%\!s3_dir_name2!
  if not exist %s3_curr_route% md %s3_curr_route%
  cd %s3_curr_route%
  echo %s3_curr_route%
  call :create_dir !s3_dir_name3!

  goto :EOF


::======================================================
::==================step5:create file =======
::======================================================
:step5
set case_file_name=

:::: Modify Comments.txt ::::
set case_file_name=%case_dir_name%\"Modify Comments.txt"
if exist %case_file_name% del %case_file_name%  /F/Q
echo �Ķ��ˣ�Author��    ��%author_name%>>%case_file_name%
echo ���ⵥ�ţ�Bug ID��  ��%case_id%>>%case_file_name%
echo ·���ļ���(Changed Files)��>>%case_file_name%
cd %root_dir%
@if /i %system_side%==modem echo modem side��>>%case_file_name%
@if /i %system_side%==ap echo android side��>>%case_file_name%
echo �޸ģ�>>%case_file_name%
for /f "tokens=1*" %%i in (%file_list_trim%) do (
	set s3_file_route=%%i
	echo            !s3_file_route!>>%case_file_name%
	)
echo �޸ķ�֧(Branch)  ��%branch_id%>>%case_file_name%
echo �Ķ�����(Description about the modification)��[%case_id%]>>%case_file_name%
echo ���ձ�ʶ(Risk level)��>>%case_file_name%
echo ����(Other comments)��None >>%case_file_name%


:::: Test Report.txt ::::
set case_file_name=%case_dir_name%\"Test Report.txt"
if exist %case_file_name% del %case_file_name% /F/Q
echo ���Ի���(Test environment)��U8800�ֻ�>>%case_file_name%
echo ��������(Test Case)��>>%case_file_name%
echo    1.>>%case_file_name%
echo      Ԥ��������>>%case_file_name%
echo      ���룺    >>%case_file_name%
echo      �������裺>>%case_file_name%
echo      Ԥ�ڽ����>>%case_file_name%
echo      ��ע��>>%case_file_name%
echo    2.>>%case_file_name%
echo      Ԥ��������>>%case_file_name%
echo      ���룺    >>%case_file_name%
echo      �������裺>>%case_file_name%
echo      Ԥ�ڽ����>>%case_file_name%
echo      ��ע��>>%case_file_name%
echo    3.>>%case_file_name%
echo      Ԥ��������>>%case_file_name%
echo      ���룺    >>%case_file_name%
echo      �������裺>>%case_file_name%
echo      Ԥ�ڽ����>>%case_file_name%
echo      ��ע��>>%case_file_name%
echo .>>%case_file_name%
echo ���Խ���(Test Result)��Pass>>%case_file_name%


:::: ���Ʒ����.txt :::: delete.
::: set case_file_name=%case_dir_name%\���Ʒ����.txt
::: if exist %case_file_name% del %case_file_name% /F/Q
::: echo /U1250/U3210/U6100/U7510/U9120/U1290>>%case_file_name%


:::: Basic Information.txt ::::
set case_file_name=%case_dir_name%\"Basic Information".txt
if exist %case_file_name% del %case_file_name% /F/Q
echo When CheckIn:%data%>>%case_file_name%
echo Affected Platform(Ӱ���ƽ̨): MSM7230>>%case_file_name%
echo .>>%case_file_name%
echo Affected Product(Ӱ��Ĳ�Ʒ): U8800>>%case_file_name%
echo .>>%case_file_name%
echo ע����Ҫ�г��޸�Ӱ���ƽ̨��>>%case_file_name%


:::: Self_check CheckList.xls ::::
set case_file_name=%case_dir_name%\"Self_check CheckList.xls"
if exist %case_file_name% del %case_file_name% /F/Q
copy %root_dir%\tools\"Self_check CheckList.xls"  %case_dir_name% 

:::: Findbugs Check Report.txt
set case_file_name=%case_dir_name%\"Findbugs Check Report.txt"
if exist %case_file_name% del %case_file_name% /F/Q
copy %root_dir%\tools\"Findbugs Check Report.txt"  %case_dir_name% 

:::: MSM7230ƽ̨_�ײ���_����������б�.xls
set case_file_name=%case_dir_name%\"MSM7230ƽ̨_�ײ���_����������б�.xls"
if exist %case_file_name% del %case_file_name% /F/Q
copy %root_dir%\tools\"MSM7230ƽ̨_�ײ���_����������б�.xls"  %case_dir_name% 

set case_file_name_old=tools\Self_check_CheckList.csv
for /f "delims=" %%i in (%case_file_name_old%) do (
  @echo %%i>>%case_file_name%
)
::	echo ���,�Լ�����,����,��ע,,>>%case_file_name%
::	echo 1,��Ʒ���ƺ��Ƿ���ȷ��ӣ��Ƿ���������Ʒ����Ӱ�졣>>%case_file_name%
::	echo Feature define is correct ?",���漰,,,>>%case_file_name%
::	echo 2,"ָ��ʹ��ǰ�Ƿ�����˷ǿ��жϣ�����ԭ�������г�ֵı�֤��>>%case_file_name%
::	echo Null check for pointer before used?",���漰,,,>>%case_file_name%
::	echo 3,"�����ڴ���Ƿ��ж�����ʧ�ܵĴ���>>%case_file_name%
::	echo Memory allocate failure check done?",���漰,,,>>%case_file_name%
::	echo 4,"�ڴ��ͷ��Ƿ���ȷ������©�����ر�����;�˳��ķ�֧��>>%case_file_name%
::	echo Memory release is proper?",���漰,,,>>%case_file_name%
::	echo 5,"�Ƿ�����ڴ�Խ�硣���ڴ����Խ�硢�����±�Խ�磩>>%case_file_name%
::	echo Any access of memory out of boundary?",����,,,>>%case_file_name%
::	echo 6,"�ڴ濽���Ƿ������ַ�����β��־��\0��>>%case_file_name%
::	echo Add '\0' at the end of string?",����,,,>>%case_file_name%
::	echo 7,"�����Ƿ���ȷ��ʼ����>>%case_file_name%
::	echo Variable initialized correctly?",����,,,>>%case_file_name%
::	echo 8,"�Ƿ����ħ�����֡� >>%case_file_name%
::	echo Any magic numbers used?",����,,,>>%case_file_name%
::	echo 9,"������ʽ��ʽ�ĺ꣬�Ƿ���ȷʹ�������š�>>%case_file_name%
::	echo Brackets used in macro definitions?",���漰,,,>>%case_file_name%
::	echo 10,"ע�����Ƿ����25%>>%case_file_name%
::	echo Comments  more than 25% percent?",����,,,>>%case_file_name%
::	echo 11,"��Ҫ��������쳣���Ƿ��д�ӡ��Ϣ��>>%case_file_name%
::	echo Enough message printed in main process and exceptionals?",���漰,,,>>%case_file_name%
::	echo 12,"���Ŀ¼�е������ļ��Ƿ񶼰�Ҫ���ṩ��>>%case_file_name%
::	echo Provide all files?",����,,,>>%case_file_name%
::	echo 13,"һ�����ⵥ�Ƿ�����˶�����⡣��������˷Ǳ����ⵥ���޸ģ� >>%case_file_name%
::	echo More than one issues merged in one defect?",����,,,>>%case_file_name%
::	echo 14,"�漰�ڴ���޸ģ��Ƿ����ڴ�й¶���߽����˼�顣 >>%case_file_name%
::	echo Check with memory leak tools when modify code related to memory?",���漰,,,>>%case_file_name%
::	echo 15,"�Ƿ������°汾�Ͻ�������֤�� >>%case_file_name%
::	echo Verified in the latest version?",����,,,>>%case_file_name%
::	echo 16,"�Ƿ��Ʒ�乫�����⡣������yes��˵�����ĸ�ƽ̨��Q05A/UIone��������������Ʒ������>>%case_file_name%
::	echo Happend in other products? write the products or build if any and give a report.",����,/U1250/U3210/U6100/U7510/U9120/U1290,,>>%case_file_name%
::	echo 17,"��������Simulator�Ƿ����ͨ��>>%case_file_name%
::	echo Defect verified on Simulator?",���漰,,,>>%case_file_name%


:::: Review Record.TXT ::::
set case_file_name=%case_dir_name%\"Review Record.TXT"
if exist %case_file_name% del %case_file_name% /F/Q
echo ������(Review Persons)   ��your name>>%case_file_name%
echo �����¼(Review Records) ��>>%case_file_name%
echo       No Issue >>%case_file_name%
echo .>>%case_file_name%
echo �޸ļ�¼(Modification Records) ��>>%case_file_name%
echo       None >>%case_file_name%
echo .>>%case_file_name%
echo ���ӽ��ۣ�Review Result����>>%case_file_name%
echo ע������м���ʱ�������⣬��¼���⣬����޸ģ�Ҫ���޸ļ�¼��>>%case_file_name%

copy %root_dir%\tools\�ײ�����ģ�����˵����(XXX).doc  %case_dir_name%

::======================================================
::==================step6:PC_lint =======
::======================================================
@if /i %system_side%==ap goto :EOF

:step6
set file_list_trim=
set s6_file_route=
set s6_file_name=
set s6_file_type=

cd %root_dir%
set file_list_trim=file_list_trim.txt
set s6_file_name=%case_dir_name%\"PC_Lint Check Report.TXT"

set SRCROOT=%work_project%\amss\products\7x30

if exist %s6_file_name% del %s6_file_name% /F/Q
echo ����ļ�(Files being checked)��>>%s6_file_name%
cd %root_dir%
for /f "tokens=1*" %%i in (%file_list_trim%) do (
	set s6_file_route=%%i
	echo            !s6_file_route!>>%s6_file_name%
	)
echo ����������˵��(Comments to the PC_Lint output)��û����������. >>%s6_file_name%
echo PC_Lint���������(PC_Lint output)��>>%s6_file_name%

for /f "tokens=1*" %%i in (%file_list_trim%) do (
	set s6_file_route=%%i
	set s6_file_name=%%~nxi
	set s6_file_type=%%~xi
	
	cd %case_dir_name%

	if /i !s6_file_type!==.c (
    rem %lint_root%\lint-nt -u -i%lint_root% std env-si %work_project%\!s6_file_route!
    %lint_root%\lint-nt -u -i%lint_root% std env-si %work_project%\!s6_file_route! >> %s6_file_name%
    
    %lint_root%\lint-nt -u -i%lint_root% std env-si %CC_root%\!s6_file_route! >> %s6_file_name%.old
	)
)

rename "PC_Lint Check Report.TXT" "PC_Lint Check Report_new.TXT"
rename "PC_Lint Check Report.TXT.old" "PC_Lint Check Report_old.TXT"

goto :EOF

:end
endlocal