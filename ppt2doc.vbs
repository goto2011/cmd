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
msgbox "�˽ű�����������ppt�ļ��е��ı�ת��Ϊword�ļ���ͼƬ�������������Զ�����" & vbcrlf & "ʹ��ʱ�������Ҫת����ppt�ļ����Ƶ�Ŀ¼D:\Good\cmd\�¡�˫�����д��ļ����ɡ�" & vbcrlf & "���д˽ű���Ҫ�����ϰ�װ��office"
'����һ��word����
Set objWord = CreateObject("Word.Application")
'����һ��ppt����
Set pptApp = CreateObject("PowerPoint.application")
'���c:\Ŀ¼�µ��ļ�����
Set FileList = objWMIService.ExecQuery _
 ("ASSOCIATORS OF {Win32_Directory.Name='D:\Good\cmd'} Where " _
     & "ResultClass = CIM_DataFile")
For Each objFile In FileList
'����ļ�����չ����ppt
If objFile.Extension = "ppt" Or objFile.Extension = "pps" Then
pptApp.visible = true
'�����ppt�ļ�
Set pptSelection = pptApp.Presentations.Open("D:\Good\cmd\" & objFile.FileName & "." & objFile.Extension)

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
objDoc.SaveAs("D:\Good\cmd\" & objFile.FileName & ".doc")
'�������Ҫ�ر�word����������һ��ɾ��
'objDoc.close
'������뵯����Ϣ�򣬰�������һ��ɾ��
'msgbox "ת�����word�ѱ�����D:\Good\cmd\" & objFile.FileName & ".doc"
else  'û��ppt�ļ�
'msgbox "����d:\��û�з���ppt�ļ���"
 End If
Next
pptApp.quit