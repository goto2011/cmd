:: ================ Get_Dir_Tree.cmd, V2:2010-08-21 =============================
:: ================ by��duangan, email: duan.gandhi@gmail.com ==============
@echo off

:: type1
:: @set dir_object="\\peknas05-rd\TC_UMTS_Mobile_Phone_F\���Ŀ¼"
:: @set dir_save_file=���ⵥ

:: type2
::@set dir_object="d:\Books"
::@set dir_save_file=Books

:: type3
::@set dir_object="\\lg-fs\Rnd"
::@set dir_save_file=lg-fs

:: type4, �����ֻ����ⵥ
::@set dir_object="\\peknas04-rd\TC_SMARTPHONE_F\DefectFolder"
::@set dir_save_file=���ⵥ

:: type5, FP���ⵥ
:: @set dir_object="\\peknas05-rd\TC_UMTS_Mobile_Phone_F\���Ŀ¼"
:: @set dir_save_file=FP���ⵥ

:: type6, IT֧����ϵ�����б�-szxnas49-rd
@set dir_object="\\szxnas49-rd\IT_Support_F"
@set dir_save_file=IT֧����ϵ�����б�-szxnas49-rd

echo -------------------------------------------------------------
echo ���ڻ�ȡ %dir_object% �ļ��б���Ϣ,���Ժ�...
echo -------------------------------------------------------------
echo Ŀ���ļ�Ϊ %dir_save_file%.txt
echo -------------------------------------------------------------

@del /f /a %dir_save_file%.txt.old
@if exist %dir_save_file%.txt move %dir_save_file%.txt %dir_save_file%.txt.old > nul

@dir %dir_object% /s /b /a-d > %dir_save_file%.txt
@tree %dir_object% /F > %dir_save_file%_2.txt