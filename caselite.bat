:: ================ CaseLite.bat, V1:2008-09-19 =============================
:: ================ CaseLite.bat, V2:2010-07-07 =============================
:: ================ by：duangan, email: duan.gandhi@gmail.com ==============

@echo off&setlocal EnableDelayedexpansion
@cls
@set root_dir=%cd%
@set data=%date:~0,4%-%date:~5,2%-%date:~8,2%

::以下项请修改！！！
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
  	::将大写字母变成小写字母
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
echo 改动人（Author）    ：%author_name%>>%case_file_name%
echo 问题单号（Bug ID）  ：%case_id%>>%case_file_name%
echo 路径文件名(Changed Files)：>>%case_file_name%
cd %root_dir%
@if /i %system_side%==modem echo modem side：>>%case_file_name%
@if /i %system_side%==ap echo android side：>>%case_file_name%
echo 修改：>>%case_file_name%
for /f "tokens=1*" %%i in (%file_list_trim%) do (
	set s3_file_route=%%i
	echo            !s3_file_route!>>%case_file_name%
	)
echo 修改分支(Branch)  ：%branch_id%>>%case_file_name%
echo 改动简述(Description about the modification)：[%case_id%]>>%case_file_name%
echo 风险标识(Risk level)：>>%case_file_name%
echo 其他(Other comments)：None >>%case_file_name%


:::: Test Report.txt ::::
set case_file_name=%case_dir_name%\"Test Report.txt"
if exist %case_file_name% del %case_file_name% /F/Q
echo 测试环境(Test environment)：U8800手机>>%case_file_name%
echo 测试用例(Test Case)：>>%case_file_name%
echo    1.>>%case_file_name%
echo      预置条件：>>%case_file_name%
echo      输入：    >>%case_file_name%
echo      操作步骤：>>%case_file_name%
echo      预期结果：>>%case_file_name%
echo      备注：>>%case_file_name%
echo    2.>>%case_file_name%
echo      预置条件：>>%case_file_name%
echo      输入：    >>%case_file_name%
echo      操作步骤：>>%case_file_name%
echo      预期结果：>>%case_file_name%
echo      备注：>>%case_file_name%
echo    3.>>%case_file_name%
echo      预置条件：>>%case_file_name%
echo      输入：    >>%case_file_name%
echo      操作步骤：>>%case_file_name%
echo      预期结果：>>%case_file_name%
echo      备注：>>%case_file_name%
echo .>>%case_file_name%
echo 测试结论(Test Result)：Pass>>%case_file_name%


:::: 跨产品分析.txt :::: delete.
::: set case_file_name=%case_dir_name%\跨产品分析.txt
::: if exist %case_file_name% del %case_file_name% /F/Q
::: echo /U1250/U3210/U6100/U7510/U9120/U1290>>%case_file_name%


:::: Basic Information.txt ::::
set case_file_name=%case_dir_name%\"Basic Information".txt
if exist %case_file_name% del %case_file_name% /F/Q
echo When CheckIn:%data%>>%case_file_name%
echo Affected Platform(影响的平台): MSM7230>>%case_file_name%
echo .>>%case_file_name%
echo Affected Product(影响的产品): U8800>>%case_file_name%
echo .>>%case_file_name%
echo 注：需要列出修改影响的平台。>>%case_file_name%


:::: Self_check CheckList.xls ::::
set case_file_name=%case_dir_name%\"Self_check CheckList.xls"
if exist %case_file_name% del %case_file_name% /F/Q
copy %root_dir%\tools\"Self_check CheckList.xls"  %case_dir_name% 

:::: Findbugs Check Report.txt
set case_file_name=%case_dir_name%\"Findbugs Check Report.txt"
if exist %case_file_name% del %case_file_name% /F/Q
copy %root_dir%\tools\"Findbugs Check Report.txt"  %case_dir_name% 

:::: MSM7230平台_底层组_已入库问题列表.xls
set case_file_name=%case_dir_name%\"MSM7230平台_底层组_已入库问题列表.xls"
if exist %case_file_name% del %case_file_name% /F/Q
copy %root_dir%\tools\"MSM7230平台_底层组_已入库问题列表.xls"  %case_dir_name% 

set case_file_name_old=tools\Self_check_CheckList.csv
for /f "delims=" %%i in (%case_file_name_old%) do (
  @echo %%i>>%case_file_name%
)
::	echo 序号,自检内容,结论,备注,,>>%case_file_name%
::	echo 1,产品或定制宏是否正确添加，是否会对其他产品产生影响。>>%case_file_name%
::	echo Feature define is correct ?",不涉及,,,>>%case_file_name%
::	echo 2,"指针使用前是否进行了非空判断，除非原代码中有充分的保证。>>%case_file_name%
::	echo Null check for pointer before used?",不涉及,,,>>%case_file_name%
::	echo 3,"申请内存后是否有对申请失败的处理。>>%case_file_name%
::	echo Memory allocate failure check done?",不涉及,,,>>%case_file_name%
::	echo 4,"内存释放是否正确且无遗漏。（特别是中途退出的分支）>>%case_file_name%
::	echo Memory release is proper?",不涉及,,,>>%case_file_name%
::	echo 5,"是否存在内存越界。（内存访问越界、数组下标越界）>>%case_file_name%
::	echo Any access of memory out of boundary?",符合,,,>>%case_file_name%
::	echo 6,"内存拷贝是否考虑了字符串结尾标志’\0’>>%case_file_name%
::	echo Add '\0' at the end of string?",符合,,,>>%case_file_name%
::	echo 7,"变量是否正确初始化。>>%case_file_name%
::	echo Variable initialized correctly?",符合,,,>>%case_file_name%
::	echo 8,"是否存在魔鬼数字。 >>%case_file_name%
::	echo Any magic numbers used?",符合,,,>>%case_file_name%
::	echo 9,"定义表达式形式的宏，是否正确使用了括号。>>%case_file_name%
::	echo Brackets used in macro definitions?",不涉及,,,>>%case_file_name%
::	echo 10,"注释量是否大于25%>>%case_file_name%
::	echo Comments  more than 25% percent?",符合,,,>>%case_file_name%
::	echo 11,"主要处理步骤和异常处是否有打印消息。>>%case_file_name%
::	echo Enough message printed in main process and exceptionals?",不涉及,,,>>%case_file_name%
::	echo 12,"入库目录中的所有文件是否都按要求提供。>>%case_file_name%
::	echo Provide all files?",符合,,,>>%case_file_name%
::	echo 13,"一个问题单是否合入了多个问题。（或合入了非本问题单的修改） >>%case_file_name%
::	echo More than one issues merged in one defect?",符合,,,>>%case_file_name%
::	echo 14,"涉及内存的修改，是否用内存泄露工具进行了检查。 >>%case_file_name%
::	echo Check with memory leak tools when modify code related to memory?",不涉及,,,>>%case_file_name%
::	echo 15,"是否在最新版本上进行了验证。 >>%case_file_name%
::	echo Verified in the latest version?",符合,,,>>%case_file_name%
::	echo 16,"是否产品间公共问题。若答复是yes，说明是哪个平台（Q05A/UIone），并请给出跨产品分析。>>%case_file_name%
::	echo Happend in other products? write the products or build if any and give a report.",符合,/U1250/U3210/U6100/U7510/U9120/U1290,,>>%case_file_name%
::	echo 17,"问题解决后，Simulator是否编译通过>>%case_file_name%
::	echo Defect verified on Simulator?",不涉及,,,>>%case_file_name%


:::: Review Record.TXT ::::
set case_file_name=%case_dir_name%\"Review Record.TXT"
if exist %case_file_name% del %case_file_name% /F/Q
echo 检视人(Review Persons)   ：your name>>%case_file_name%
echo 问题记录(Review Records) ：>>%case_file_name%
echo       No Issue >>%case_file_name%
echo .>>%case_file_name%
echo 修改记录(Modification Records) ：>>%case_file_name%
echo       None >>%case_file_name%
echo .>>%case_file_name%
echo 检视结论（Review Result）：>>%case_file_name%
echo 注：如果有检视时发现问题，记录问题，如果修改，要做修改记录。>>%case_file_name%

copy %root_dir%\tools\底层驱动模块设计说明书(XXX).doc  %case_dir_name%

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
echo 检查文件(Files being checked)：>>%s6_file_name%
cd %root_dir%
for /f "tokens=1*" %%i in (%file_list_trim%) do (
	set s6_file_route=%%i
	echo            !s6_file_route!>>%s6_file_name%
	)
echo 对输出结果的说明(Comments to the PC_Lint output)：没有引入问题. >>%s6_file_name%
echo PC_Lint的输出如下(PC_Lint output)：>>%s6_file_name%

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