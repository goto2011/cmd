
/*****************************************************************************
 �� �� ��  : AutoExpand
 ��������  : ��չ������ں���
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �޸�

*****************************************************************************/
macro AutoExpand()
{
    //������Ϣ
    // get window, sel, and buffer handles
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    if(sel.lnFirst != sel.lnLast)
    {
        /*�������*/
        BlockCommandProc()
    }
    if (sel.ichFirst == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    nVer = 0
    nVer = GetVersion()
    /*ȡ���û���*/
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    // get line the selection (insertion point) is on
    szLine = GetBufLine(hbuf, sel.lnFirst);
    // parse word just to the left of the insertion point
    wordinfo = GetWordLeftOfIch(sel.ichFirst, szLine)
    ln = sel.lnFirst;
    chTab = CharFromAscii(9)

    // prepare a new indented blank line to be inserted.
    // keep white space on left and add a tab to indent.
    // this preserves the indentation level.
    chSpace = CharFromAscii(32);
    ich = 0
    while (szLine[ich] == chSpace || szLine[ich] == chTab)
    {
        ich = ich + 1
    }
    szLine1 = strmid(szLine,0,ich)
    szLine = strmid(szLine, 0, ich) # "    "

    sel.lnFirst = sel.lnLast
    sel.ichFirst = wordinfo.ich
    sel.ichLim = wordinfo.ich

    /*�Զ���ɼ������ƥ����ʾ*/
    wordinfo.szWord = RestoreCommand(hbuf,wordinfo.szWord)
    /*
    */
    sel = GetWndSel(hwnd)
    if (wordinfo.szWord == "pn") /*���ⵥ�ŵĴ���*/
    {
        DelBufLine(hbuf, ln)
        AddPromblemNo()
        return
    }else if (wordinfo.szWord == "al")
    {
        DelBufLine(hbuf, ln)
    	addLoggerName();
        return
    }

    /*��������ִ��*/
    else if (wordinfo.szWord == "config" || wordinfo.szWord == "co")
    {
        DelBufLine(hbuf, ln)
        ConfigureSystem()
        return
    }
    /*�޸���ʷ��¼����*/
    else if (wordinfo.szWord == "hi")
    {
        DelBufLine(hbuf, ln)
        InsertHistory(hbuf,ln,language)
        return
    }

    else if (wordinfo.szWord == "abg")
    {
        sel.ichFirst = sel.ichFirst - 3
        SetWndSel(hwnd,sel)
        InsertReviseAdd()
        PutBufLine(hbuf, ln+1 ,szLine1)
        SetBufIns(hwnd,ln+1,sel.ichFirst)
        return
    }
    else if (wordinfo.szWord == "dbg")
    {
        sel.ichFirst = sel.ichFirst - 3
        SetWndSel(hwnd,sel)
        InsertReviseDel()
        PutBufLine(hbuf, ln+1 ,szLine1)
        SetBufIns(hwnd,ln+1,sel.ichFirst)
        return
    }
    else if (wordinfo.szWord == "mbg")
    {
        sel.ichFirst = sel.ichFirst - 3
        SetWndSel(hwnd,sel)
        InsertReviseMod()
        PutBufLine(hbuf, ln+1 ,szLine1)
        SetBufIns(hwnd,ln+1,sel.ichFirst)
        return
    }
    if(language == 1)
    {
        ExpandProcEN(szMyName,wordinfo,szLine,szLine1,nVer,ln,sel)
    }
    else
    {
        ExpandProcCN(szMyName,wordinfo,szLine,szLine1,nVer,ln,sel)
    }
}

/*****************************************************************************
 �� �� ��  : ExpandProcEN
 ��������  : Ӣ��˵������չ�����
 �������  : szMyName  �û���
             wordinfo
             szLine
             szLine1
             nVer
             ln
             sel
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ExpandProcEN(szMyName,wordinfo,szLine,szLine1,nVer,ln,sel)
{

    szCmd = wordinfo.szWord
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    /*Ӣ��ע��*/
    if (szCmd == "/*")
    {
        szCurLine = GetBufLine(hbuf, sel.lnFirst);
        szLeft = strmid(szCurLine,0,wordinfo.ichLim)
        lineLen = strlen(szCurLine)
        kk = 0
        while(wordinfo.ichLim + kk < lineLen)
        {
            if((szCurLine[wordinfo.ichLim + kk] != " ")||(szCurLine[wordinfo.ichLim + kk] != "\t")
            {
                msg("you must insert /* at the end of a line");
                return
            }
            kk = kk + 1
        }
        szContent = Ask("Please input comment")
        DelBufLine(hbuf, ln)
        CommentContent(hbuf,ln,szLeft,szContent,1)
        return
    }
    else if(szCmd == "{")
    {
        InsBufLine(hbuf, ln + 1, "@szLine@")
        InsBufLine(hbuf, ln + 2, "@szLine1@" # "}");
        SetBufIns (hbuf, ln + 1, strlen(szLine))
        return
    }
    else if (szCmd == "while" )
    {
        SetBufSelText(hbuf, " ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
    }
    else if( szCmd == "else" )
    {
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "#ifd" || szCmd == "#ifdef") //#ifdef
    {
          DelBufLine(hbuf, ln)
          InsIfdef()
          return
    }
    else if (szCmd == "#ifn" || szCmd == "#ifndef") //#ifndef
    {
          DelBufLine(hbuf, ln)
          InsIfndef()
          return
    }
    else if (szCmd == "#if")
    {
          DelBufLine(hbuf, ln)
          InsertPredefIf()
          return
    }
    else if (szCmd == "cpp")
    {
          DelBufLine(hbuf, ln)
          InsertCPP(hbuf,ln)
          return
    }
    else if (szCmd == "if")
    {
        SetBufSelText(hbuf, " ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
/*            InsBufLine(hbuf, ln + 4, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@" # ";");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");*/
    }
    else if (szCmd == "ef")
    {
        PutBufLine(hbuf, ln, szLine1 # "else if ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
    }
    else if (szCmd == "ife")
    {
        PutBufLine(hbuf, ln, szLine1 # "if ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 4, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@" # ";");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");
    }
    else if (szCmd == "ifs")
    {
        PutBufLine(hbuf, ln, szLine1 # "if ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 4, "@szLine1@" # "else if ( # )");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@" # ";");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 8, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 9, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 10, "@szLine@" # ";");
        InsBufLine(hbuf, ln + 11, "@szLine1@" # "}");
    }
    else if (szCmd == "for")
    {
        SetBufSelText(hbuf, " ( # ; # ; # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#")
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}")
        SetWndSel(hwnd, sel)
        SearchForward()
        szVar = ask("Please input loop variable")
        newsel = sel
        newsel.ichLim = GetBufLineLength (hbuf, ln)
        SetWndSel(hwnd, newsel)
        SetBufSelText(hbuf, " ( @szVar@ = # ; @szVar@ # ; @szVar@++ )")
    }
    else if (szCmd == "fo")
    {
        SetBufSelText(hbuf, "r ( ulI = 0; ulI < # ; ulI++ )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#")
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}")
        symname =GetCurSymbol ()
        symbol = GetSymbolLocation(symname)
        if(strlen(symbol) > 0)
        {
            nIdx = symbol.lnName + 1;
            while( 1 )
            {
                szCurLine = GetBufLine(hbuf, nIdx);
                nRet = strstr(szCurLine,"{")
                if( nRet != 0xffffffff )
                {
                    break;
                }
                nIdx = nIdx + 1
                if(nIdx > symbol.lnLim)
                {
                    break
                }
             }
             InsBufLine(hbuf, nIdx + 1, "    UINT32 ulI = 0;");
         }
    }
    else if (szCmd == "switch" )
    {
        nSwitch = ask("Please input the number of case")
        SetBufSelText(hbuf, " ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsertMultiCaseProc(hbuf,szLine1,nSwitch)
    }
    else if (szCmd == "do")
    {
         InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
         InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
         InsBufLine(hbuf, ln + 3, "@szLine1@" # "} while ( # );")
    }
    else if (szCmd == "case" )
    {
         SetBufSelText(hbuf, " # :")
         InsBufLine(hbuf, ln + 1, "@szLine@" # "#")
         InsBufLine(hbuf, ln + 2, "@szLine@" # "break;")
    }
    else if (szCmd == "struct" || szCmd == "st")
    {
        DelBufLine(hbuf, ln)
        szStructName = (Ask("Please input struct name"))
        InsBufLine(hbuf, ln, "@szLine1@typedef struct _@szStructName@");
        InsBufLine(hbuf, ln + 1, "@szLine1@{");
        InsBufLine(hbuf, ln + 2, "@szLine@             ");
        szStructName = cat(szStructName,"_S")
        InsBufLine(hbuf, ln + 3, "@szLine1@}@szStructName@;");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "enum" || szCmd == "en")
    {
        DelBufLine(hbuf, ln)
        szStructName = (Ask("Please input enum name"))
        InsBufLine(hbuf, ln, "@szLine1@typedef enum _@szStructName@");
        InsBufLine(hbuf, ln + 1, "@szLine1@{");
        InsBufLine(hbuf, ln + 2, "@szLine@             ");
        szStructName = cat(szStructName,"_E")
        InsBufLine(hbuf, ln + 3, "@szLine1@}@szStructName@;");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "file" || szCmd == "fi")
    {
         DelBufLine(hbuf, ln)
        InsertFileHeaderEN( hbuf,ln, szMyName,"" )
        return
    }
    else if (szCmd == "func" || szCmd == "fu")
    {
        DelBufLine(hbuf,ln)
           lnMax = GetBufLineCount(hbuf)
           if(ln != lnMax)
           {
            szNextLine = GetBufLine(hbuf,ln)
            if( (strstr(szNextLine,"(") != 0xffffffff) || (nVer != 2))
            {
                symbol = GetCurSymbol()
                if(strlen(symbol) != 0)
                {
                    FuncHeadCommentEN(hbuf, ln, symbol, szMyName,0)
                    return
                }
            }
        }
        szFuncName = Ask("Please input function name")
           FuncHeadCommentEN(hbuf, ln, szFuncName, szMyName, 1)
    }
    else if (szCmd == "tab")
    {
        DelBufLine(hbuf, ln)
        ReplaceBufTab()
        return
    }
    else if (szCmd == "ap")
    {
          SysTime = GetSysTime(1)
           sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = AddPromblemNo()
        InsBufLine(hbuf, ln, "@szLine1@/* Promblem Number: @szQuestion@     Author:@szMyName@,   Date:@sz@/@sz1@/@sz3@ ");
        szContent = Ask("Description")
        szLeft = cat(szLine1,"   Description    : ");
        ln = CommentContent(hbuf,ln + 1,szLeft,szContent,1)
        return
       }
    else if (szCmd == "hd")
    {
         DelBufLine(hbuf, ln)
         CreateFunctionDef(hbuf,szMyName,1)
         return
    }
    else if (szCmd == "hdn")
    {
         DelBufLine(hbuf, ln)
        /*���ɲ�Ҫ�ļ�������ͷ�ļ�*/
         CreateNewHeaderFile()
         return
    }
    else if (szCmd == "ab")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Added by @szMyName@, @sz@/@sz1@/@sz3@   PN:@szQuestion@*/");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Added by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        return
    }
    else if (szCmd == "ae")
    {
          SysTime = GetSysTime(1)
           sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln, "@szLine1@/* END:   Added by @szMyName@, @sz@/@sz1@/@sz3@ */");
        return
    }
    else if (szCmd == "db")
    {
          SysTime = GetSysTime(1)
           sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
            if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Deleted by @szMyName@, @sz@/@sz1@/@sz3@   PN:@szQuestion@*/");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Deleted by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }

        return
    }
    else if (szCmd == "de")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln + 0)
        InsBufLine(hbuf, ln, "@szLine1@/* END: Deleted by @szMyName@, @sz@/@sz1@/@sz3@ */");
        return
    }
    else if (szCmd == "mb")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        
        /* < mod by duangan, 2008-10-09,begin */
        if(strlen(szQuestion) > 0)
        {
            // InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Modified by @szMyName@, @sz@/@sz1@/@sz3@   PN:@szQuestion@*/");
            InsBufLine(hbuf, ln, "@szLine1@/* <@szQuestion@ @szMyName@ @sz@-@sz1@-@sz3@ begin */");
        }
        else
        {
            // InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Modified by @szMyName@, @sz@/@sz1@/@sz3@ */");
            InsBufLine(hbuf, ln, "@szLine1@/* <********* @szMyName@ @sz@-@sz1@-@sz3@ begin */");
        }
        /* mod by duangan, 2008-10-09,end > */
        return
    }
    else if (szCmd == "me")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        
        /* < mod by duangan, 2008-10-09,begin */
        szQuestion = GetReg ("PNO")
        
        // InsBufLine(hbuf, ln, "@szLine1@/* END:   Modified by @szMyName@, @sz@/@sz1@/@sz3@ */");
        if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* @szQuestion@ @szMyName@ @sz@-@sz1@-@sz3@ end> */");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* ********* @szMyName@ @sz@-@sz1@-@sz3@ end> */");
        }
        /* mod by duangan, 2008-10-09,end > */

        return
    }else if (szCmd == "removeTrace")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln, "@szLine1@/* END:   Modified by @szMyName@, @sz@/@sz1@/@sz3@ */");
        return
    }
    else
    {
        SearchForward()
//            ExpandBraceLarge()
        stop
    }
    SetWndSel(hwnd, sel)
    SearchForward()
}


/*****************************************************************************
 �� �� ��  : ExpandProcCN
 ��������  : ����˵������չ����
 �������  : szMyName
             wordinfo
             szLine
             szLine1
             nVer
             ln
             sel
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ExpandProcCN(szMyName,wordinfo,szLine,szLine1,nVer,ln,sel)
{
    szCmd = wordinfo.szWord
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)

    //����ע��
    if (szCmd == "/*")
    {
        szCurLine = GetBufLine(hbuf, sel.lnFirst);
        szLeft = strmid(szCurLine,0,wordinfo.ichLim)
        lineLen = strlen(szCurLine)
        kk = 0
        /*ע��ֻ������β������ע�͵����ô���*/
        while(wordinfo.ichLim + kk < lineLen)
        {
            if(szCurLine[wordinfo.ichLim + kk] != " ")
            {
                msg("ֻ������β����");
                return
            }
            kk = kk + 1
        }
        szContent = Ask("������ע�͵�����")
        DelBufLine(hbuf, ln)
        CommentContent(hbuf,ln,szLeft,szContent,1)
        return
    }
    else if(szCmd == "{")
    {
        InsBufLine(hbuf, ln + 1, "@szLine@")
        InsBufLine(hbuf, ln + 2, "@szLine1@" # "}");
        SetBufIns (hbuf, ln + 1, strlen(szLine))
        return
    }
    else if (szCmd == "while" || szCmd == "wh")
    {
        SetBufSelText(hbuf, " ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
    }
    else if( szCmd == "else" || szCmd == "el")
    {
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "#ifd" || szCmd == "#ifdef") //#ifdef
    {
          DelBufLine(hbuf, ln)
          InsIfdef()
          return
    }
    else if (szCmd == "#ifn" || szCmd == "#ifndef") //#ifdef
    {
          DelBufLine(hbuf, ln)
          InsIfndef()
          return
    }
    else if (szCmd == "#if")
    {
          DelBufLine(hbuf, ln)
          InsertPredefIf()
          return
    }
    else if (szCmd == "cpp")
    {
          DelBufLine(hbuf, ln)
          InsertCPP(hbuf,ln)
          return
    }
    else if (szCmd == "if")
    {
        SetBufSelText(hbuf, " ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
/*            InsBufLine(hbuf, ln + 4, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@" # ";");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");*/
    }
    else if (szCmd == "ef")
    {
        PutBufLine(hbuf, ln, szLine1 # "else if ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
    }
    else if (szCmd == "ife")
    {
        PutBufLine(hbuf, ln, szLine1 # "if ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 4, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@" # ";");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");
    }
    else if (szCmd == "ifs")
    {
        PutBufLine(hbuf, ln, szLine1 # "if ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
        InsBufLine(hbuf, ln + 3, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 4, "@szLine1@" # "else if ( # )");
        InsBufLine(hbuf, ln + 5, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 6, "@szLine@" # ";");
        InsBufLine(hbuf, ln + 7, "@szLine1@" # "}");
        InsBufLine(hbuf, ln + 8, "@szLine1@" # "else");
        InsBufLine(hbuf, ln + 9, "@szLine1@" # "{");
        InsBufLine(hbuf, ln + 10, "@szLine@" # ";");
        InsBufLine(hbuf, ln + 11, "@szLine1@" # "}");
    }
     else if (szCmd == "for")
    {
         SetBufSelText(hbuf, " ( # ; # ; # )")
         InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
         InsBufLine(hbuf, ln + 2, "@szLine@" # "#")
         InsBufLine(hbuf, ln + 3, "@szLine1@" # "}")
        SetWndSel(hwnd, sel)
        SearchForward()
         szVar = ask("������ѭ������")
         newsel = sel
         newsel.ichLim = GetBufLineLength (hbuf, ln)
        SetWndSel(hwnd, newsel)
        SetBufSelText(hbuf, " ( @szVar@ = # ; @szVar@ # ; @szVar@++ )")
    }
     else if (szCmd == "fo")
    {
         SetBufSelText(hbuf, "r ( ulI = 0; ulI < # ; ulI++ )")
         InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
         InsBufLine(hbuf, ln + 2, "@szLine@" # "#")
         InsBufLine(hbuf, ln + 3, "@szLine1@" # "}")
        symname =GetCurSymbol ()
        symbol = GetSymbolLocation(symname)
           if(strlen(symbol) > 0)
           {
            nIdx = symbol.lnName + 1;
            while( 1 )
            {
                szCurLine = GetBufLine(hbuf, nIdx);
                nRet = strstr(szCurLine,"{")
                if( nRet != 0xffffffff )
                {
                    break;
                }
                nIdx = nIdx + 1
                if(nIdx > symbol.lnLim)
                {
                    break
                }
            }
             InsBufLine(hbuf, nIdx + 1, "    UINT32 ulI = 0;");
         }
    }
     else if (szCmd == "switch" || szCmd == "sw")
    {
        nSwitch = ask("������case�ĸ���")
        SetBufSelText(hbuf, " ( # )")
        InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
        InsertMultiCaseProc(hbuf,szLine1,nSwitch)
    }
     else if (szCmd == "do")
    {
         InsBufLine(hbuf, ln + 1, "@szLine1@" # "{")
         InsBufLine(hbuf, ln + 2, "@szLine@" # "#");
         InsBufLine(hbuf, ln + 3, "@szLine1@" # "} while ( # );")
    }
     else if (szCmd == "case" || szCmd == "ca" )
    {
         SetBufSelText(hbuf, " # :")
         InsBufLine(hbuf, ln + 1, "@szLine@" # "#")
         InsBufLine(hbuf, ln + 2, "@szLine@" # "break;")
    }
     else if (szCmd == "struct" || szCmd == "st" )
    {
        DelBufLine(hbuf, ln)
        szStructName = toupper(Ask("������ṹ��:"))
        InsBufLine(hbuf, ln, "@szLine1@typedef struct @szStructName@");
        InsBufLine(hbuf, ln + 1, "@szLine1@{");
        InsBufLine(hbuf, ln + 2, "@szLine@      ");
        szStructName = cat(szStructName,"_STRU")
        InsBufLine(hbuf, ln + 3, "@szLine1@}@szStructName@;");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
     else if (szCmd == "enum" || szCmd == "en")
    {
        DelBufLine(hbuf, ln)
        szStructName = toupper(Ask("������ö����:"))
        InsBufLine(hbuf, ln, "@szLine1@typedef enum @szStructName@");
        InsBufLine(hbuf, ln + 1, "@szLine1@{");
        InsBufLine(hbuf, ln + 2, "@szLine@       ");
        szStructName = cat(szStructName,"_ENUM")
        InsBufLine(hbuf, ln + 3, "@szLine1@}@szStructName@;");
        SetBufIns (hbuf, ln + 2, strlen(szLine))
        return
    }
    else if (szCmd == "file" || szCmd == "fi" )
    {
        DelBufLine(hbuf, ln)
        /*�����ļ�ͷ˵��*/
        InsertFileHeaderCN( hbuf,ln, szMyName,"" )
        return
    }
    else if (szCmd == "hd")
    {
         DelBufLine(hbuf, ln)
        /*����C���Ե�ͷ�ļ�*/
         CreateFunctionDef(hbuf,szMyName,0)
         return
    }
    else if (szCmd == "hdn")
    {
         DelBufLine(hbuf, ln)
        /*���ɲ�Ҫ�ļ�������ͷ�ļ�*/
         CreateNewHeaderFile()
         return
    }
    else if (szCmd == "func" || szCmd == "fu")
    {
        DelBufLine(hbuf,ln)
        lnMax = GetBufLineCount(hbuf)
        if(ln != lnMax)
        {
            szNextLine = GetBufLine(hbuf,ln)
            /*����2.1���si����ǷǷ�symbol�ͻ��ж�ִ�У��ʸ�Ϊ�Ժ�һ��
              �Ƿ��С��������ж��Ƿ����º���*/
            if( (strstr(szNextLine,"(") != 0xffffffff) || (nVer != 2))
            {
                /*���Ѿ����ڵĺ���*/
                symbol = GetCurSymbol()
                if(strlen(symbol) != 0)
                {
                    FuncHeadCommentCN(hbuf, ln, symbol, szMyName,0)
                    return
                }
            }
        }
        szFuncName = Ask("�����뺯������:")
        /*���º���*/
        FuncHeadCommentCN(hbuf, ln, szFuncName, szMyName, 1)
    }
    else if (szCmd == "tab") /*��tab��չΪ�ո�*/
    {
        DelBufLine(hbuf, ln)
        ReplaceBufTab()
    }
    else if (szCmd == "ap")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = AddPromblemNo()
        InsBufLine(hbuf, ln, "@szLine1@/* �� �� ��: @szQuestion@     �޸���:@szMyName@,   ʱ��:@sz@/@sz1@/@sz3@ ");
        szContent = Ask("�޸�ԭ��")
        szLeft = cat(szLine1,"   �޸�ԭ��: ");
        ln = CommentContent(hbuf,ln + 1,szLeft,szContent,1)
        return
    }
    else if (szCmd == "ab")
    {
          SysTime = GetSysTime(1)
           sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Added by @szMyName@, @sz@/@sz1@/@sz3@   ���ⵥ��:@szQuestion@*/");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Added by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        return
    }
    else if (szCmd == "ae")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln, "@szLine1@/* END:   Added by @szMyName@, @sz@/@sz1@/@sz3@ */");
        return
    }
    else if (szCmd == "db")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Deleted by @szMyName@, @sz@/@sz1@/@sz3@   ���ⵥ��:@szQuestion@*/");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Deleted by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }

        return
    }
    else if (szCmd == "de")
    {
          SysTime = GetSysTime(1)
           sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln + 0)
        InsBufLine(hbuf, ln, "@szLine1@/* END: Deleted by @szMyName@, @sz@/@sz1@/@sz3@ */");
        return
    }
    else if (szCmd == "mb")
    {
          SysTime = GetSysTime(1)
           sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
            if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Modified by @szMyName@, @sz@/@sz1@/@sz3@   ���ⵥ��:@szQuestion@*/");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Modified by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        return
    }
    else if (szCmd == "me")
    {
          SysTime = GetSysTime(1)
           sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln, "@szLine1@/* END:   Modified by @szMyName@, @sz@/@sz1@/@sz3@ */");
        return
    }
    else
    {
        SearchForward()
        stop
    }
    SetWndSel(hwnd, sel)
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : BlockCommandProc
 ��������  : ���������
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro BlockCommandProc()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    if(sel.lnFirst > 0)
    {
        ln = sel.lnFirst - 1
    }
    else
    {
        stop
    }
    szLine = GetBufLine(hbuf,ln)
    szLine = TrimString(szLine)
    if(szLine == "while" || szLine == "wh")
    {
        InsertWhile()   /*����while*/
    }
    else if(szLine == "do")
    {
        InsertDo()   //����do while���
    }
    else if(szLine == "for")
    {
        InsertFor()  //����for���
    }
    else if(szLine == "if")
    {
        InsertIf()   //����if���
    }
    else if(szLine == "el" || szLine == "else")
    {
        InsertElse()  //����else���
        DelBufLine(hbuf,ln)
        stop
    }
    else if((szLine == "#ifd") || (szLine == "#ifdef"))
    {
        InsIfdef()        //����#ifdef
        DelBufLine(hbuf,ln)
        stop
    }
    else if((szLine == "#ifn") || (szLine == "#ifndef"))
    {
        InsIfndef()        //����#ifdef
        DelBufLine(hbuf,ln)
        stop
    }
    else if (szLine == "abg")
    {
        InsertReviseAdd()
        DelBufLine(hbuf, ln)
        stop
    }
    else if (szLine == "dbg")
    {
        InsertReviseDel()
        DelBufLine(hbuf, ln)
        stop
    }
    else if (szLine == "mbg")
    {
        InsertReviseMod()
        DelBufLine(hbuf, ln)
        stop
    }
    else if(szLine == "#if")
    {
        InsertPredefIf()
        DelBufLine(hbuf,ln)
        stop
    }
    DelBufLine(hbuf,ln)
    SearchForward()
    stop
}

/*****************************************************************************
 �� �� ��  : RestoreCommand
 ��������  : ��������ָ�����
 �������  : hbuf
             szCmd
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro RestoreCommand(hbuf,szCmd)
{
    if(szCmd == "ca")
    {
          SetBufSelText(hbuf, "se")
        szCmd = "case"
    }
    else if(szCmd == "sw")
    {
          SetBufSelText(hbuf, "itch")
        szCmd = "switch"
    }
    else if(szCmd == "el")
    {
          SetBufSelText(hbuf, "se")
        szCmd = "else"
    }
    else if(szCmd == "wh")
    {
          SetBufSelText(hbuf, "ile")
        szCmd = "while"
    }
    return szCmd
}

/*****************************************************************************
 �� �� ��  : SearchForward
 ��������  : ��ǰ����#
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro SearchForward()
{
    LoadSearchPattern("#", 1, 0, 1);
    Search_Forward
}

/*****************************************************************************
 �� �� ��  : SearchBackward
 ��������  : �������#
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro SearchBackward()
{
    LoadSearchPattern("#", 1, 0, 1);
    Search_Backward
}

/*****************************************************************************
 �� �� ��  : InsertFuncName
 ��������  : �ڵ�ǰλ�ò��뵫ǰ������
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertFuncName()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    symbolname = GetCurSymbol()
    SetBufSelText (hbuf, symbolname)
}

/*****************************************************************************
 �� �� ��  : strstr
 ��������  : �ַ���ƥ���ѯ����
 �������  : str1  Դ��
             str2  ��ƥ���Ӵ�
 �������  : ��
 �� �� ֵ  : 0xffffffffΪû���ҵ�ƥ���ַ���
             ����Ϊƥ���ַ�������ʼλ��
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro strstr(str1,str2)
{
    i = 0
    j = 0
    len1 = strlen(str1)
    len2 = strlen(str2)
    if((len1 == 0) || (len2 == 0))
    {
        return 0xffffffff
    }
    while( i < len1)
    {
        if(str1[i] == str2[j])
        {
            while(j < len2)
            {
                j = j + 1
                if(str1[i+j] != str2[j])
                {
                    break
                }
            }
            if(j == len2)
            {
                return i
            }
            j = 0
        }
        i = i + 1
    }
    return 0xffffffff
}

/*****************************************************************************
 �� �� ��  : InsertTraceInfo
 ��������  : �ں�������ںͳ��ڲ����ӡ
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertTraceInfo()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    symbolname = GetCurSymbol()
    symbol = GetSymbolLocation (symbolname)

    hsyml = SymbolChildren(symbol)
    cchild = SymListCount(hsyml)

    cchild=cchild
    ichild = 0

	nLineEnd = symbol.lnLim
    nExitCount = 1;
    loggerName = getLoggerName()
    traceMessage="    PLogSvc_Logger_trace(@loggerName@, \"\\r\\n @symbolname@() ";
    traceMessage=cat(traceMessage,"method entry with args ")
//    InsBufLine(hbuf, sel.lnFirst, "PLogSvc_Logger_trace(\"\\r\\n Entering the method |@symbolname@() with args ");
	ichild = 0
    while (ichild < cchild){
        childsym = SymListItem(hsyml, ichild)
        if(childsym.Type=="Parameter"){

	        childname=SymbolLeafName(childsym)
		    traceMessage=cat(traceMessage, "@childname@ = %d ")
		}else if(childsym.Type=="Type Reference"){
		    voidReturn= EndsWithString(childsym.symbol,"void",4);
		}
        ichild = ichild + 1
    }

    traceMessage=cat(traceMessage,   "\"");
    ichild = 0
    while (ichild < cchild){
        childsym = SymListItem(hsyml, ichild)
        if(childsym.Type=="Parameter"){
	        childname=SymbolLeafName(childsym)
	        traceMessage=cat(traceMessage,", @childname@")
	    }
        ichild = ichild + 1
    }
    traceMessage=cat(traceMessage,");")
    trimmedFirstLine=TrimString(GetBufLine(hbuf,sel.lnFirst));
    if(StartsWithString(trimmedFirstLine,"PLogSvc_Logger_trace(",21)==false){
		InsBufLine(hbuf, sel.lnFirst, traceMessage);
	}

    ln = sel.lnFirst + 1
    fIsEnd = 1
    returnFound=false

    while(ln < nLineEnd)
    {
	    traceMessage="    PLogSvc_Logger_trace(@loggerName@, \"\\r\\n @symbolname@() ";
    //    traceMessage="    PLogSvc_Logger_trace(@loggerName@, ";
        szLine = GetBufLine(hbuf, ln)
        /*�޳����е�ע�����*/
        RetVal = SkipCommentFromString(szLine,fIsEnd)
        szLine = RetVal.szContent
        fIsEnd = RetVal.fIsEnd
        //�����Ƿ���return���
        ret =strstr(szLine,"return")
        //�����߿հ״�С
        nLeft = GetLeftBlank(szLine)
        szLeft = strmid(szLine,0,nLeft)
        if( ret != 0xffffffff )
        {
//			returnFound=true
            traceMessage= cat(traceMessage,"exit ---: @nExitCount@ \");")
		    trimmedLine=TrimString(GetBufLine(hbuf,ln-1));
		    if(StartsWithString(trimmedLine,"PLogSvc_Logger_trace(",21)==false){
		        InsBufLine(hbuf, ln, traceMessage)
		        nLineEnd = nLineEnd + 1
          		ln = ln + 1
			}
            nExitCount = nExitCount + 1
            if(nLineEnd < ln + 2)
            {
                return
            }
          }
          ln = ln + 1
    }
    if(voidReturn==true){
	    traceMessage="    PLogSvc_Logger_trace(@loggerName@, \"\\r\\n @symbolname@() ";
	    traceMessage= cat(traceMessage,"exit ---: @nExitCount@ \");")
	    trimmedLine=TrimString(GetBufLine(hbuf,ln-2));
	    if(StartsWithString(trimmedLine,"PLogSvc_Logger_trace(",21)==false){
	        InsBufLine(hbuf, ln-1, traceMessage)
		}
    }
    /*
	*/

//    InsBufLine(hbuf, ln,  traceMessage)
//    InsBufLine(hbuf, ln,  "")
    SymListFree(hsyml)
}

macro RemoveCurBufTraceInfo()
{
    hbuf = GetCurrentBuf()
    isymMax = GetBufSymCount(hbuf)
    isym = 0
    while (isym < isymMax)
    {
        isLastLine = 0
        symbol = GetBufSymLocation(hbuf, isym)
        fIsEnd = 1
        if(strlen(symbol) > 0)
        {
            if(symbol.Type == "Function")
            {
                SetBufIns(hbuf,symbol.lnName,0)
                RemoveTraceInfo()
            }
        }
        isym = isym + 1
    }
}

macro RemoveTraceInfo()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    if(hbuf == hNil)
       stop
    symbolname = GetCurSymbol()
    symbol = GetSymbolLocationFromLn(hbuf, sel.lnFirst)
    loggerName = getLoggerName()
//    symbol = GetSymbolLocation (symbolname)
    nLineEnd = symbol.lnLim
    szEntry = "PLogSvc_Logger_trace(@loggerName@, \"\\r\\n @symbolname@() "
    szExit = "PLogSvc_Logger_trace(@loggerName@, \"\\r\\n @symbolname@() "
//    szExit = "VOS_Debug_Trace(\"\\r\\n |@symbolname@() exit---:"
    ln = symbol.lnName
    fIsEntry = 0
    while(ln < nLineEnd)
    {
        szLine = GetBufLine(hbuf, ln)
        /*�޳����е�ע�����*/
        RetVal = TrimString(szLine)
        if(fIsEntry == 0)
        {
            ret = strstr(szLine,szEntry)
            if(ret != 0xffffffff)
            {
                DelBufLine(hbuf,ln)
                nLineEnd = nLineEnd - 1
                fIsEntry = 1
                ln = ln + 1
                continue
            }
        }
        ret = strstr(szLine,szExit)
        if(ret != 0xffffffff)
        {
            DelBufLine(hbuf,ln)
            nLineEnd = nLineEnd - 1
        }
        ln = ln + 1
    }
}

/*****************************************************************************
 �� �� ��  : InsertFileHeaderEN
 ��������  : ����Ӣ���ļ�ͷ����
 �������  : hbuf
             ln         �к�
             szName     ������
             szContent  ������������
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertFileHeaderEN(hbuf, ln,szName,szContent)
{

    InsBufLine(hbuf, ln + 0,  "/******************************************************************************")
    InsBufLine(hbuf, ln + 1,  "")
    InsBufLine(hbuf, ln + 2,  "  Copyright (C), 2001-2011, Huawei Tech. Co., Ltd.")
    InsBufLine(hbuf, ln + 3,  "")
    InsBufLine(hbuf, ln + 4,  " ******************************************************************************")
    sz = GetFileName(GetBufName (hbuf))
    InsBufLine(hbuf, ln + 5,  "  File Name     : @sz@")
    InsBufLine(hbuf, ln + 6,  "  Version       : Initial Draft")
    InsBufLine(hbuf, ln + 7,  "  Author        : @szName@")
    SysTime = GetSysTime(1)
    sz=SysTime.Year
    sz1=SysTime.month
    sz3=SysTime.day
    InsBufLine(hbuf, ln + 8,  "  Created       : @sz@/@sz1@/@sz3@")
    InsBufLine(hbuf, ln + 9,  "  Last Modified :")
    szTmp = "  Description   : "
    nlnDesc = ln
    iLen = strlen (szContent)
    InsBufLine(hbuf, ln + 10, "  Description   : @szContent@")
    InsBufLine(hbuf, ln + 11, "  Function List :")
    //���뺯���б�
    ln = InsertFileList(hbuf,ln + 12) - 12
    InsBufLine(hbuf, ln + 12, "  History       :")
    InsBufLine(hbuf, ln + 13, "  1.Date        : @sz@/@sz1@/@sz3@")
    InsBufLine(hbuf, ln + 14, "    Author      : @szName@")
    InsBufLine(hbuf, ln + 15, "    Modification: Created file")
    InsBufLine(hbuf, ln + 16, "")
    InsBufLine(hbuf, ln + 17, "******************************************************************************/")
    InsBufLine(hbuf, ln + 18, "")
    InsBufLine(hbuf, ln + 19, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 20, " * external variables                           *")
    InsBufLine(hbuf, ln + 21, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 22, "")
    InsBufLine(hbuf, ln + 23, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 24, " * external routine prototypes                  *")
    InsBufLine(hbuf, ln + 25, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 26, "")
    InsBufLine(hbuf, ln + 27, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 28, " * internal routine prototypes                  *")
    InsBufLine(hbuf, ln + 29, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 30, "")
    InsBufLine(hbuf, ln + 31, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 32, " * project-wide global variables                *")
    InsBufLine(hbuf, ln + 33, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 34, "")
    InsBufLine(hbuf, ln + 35, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 36, " * module-wide global variables                 *")
    InsBufLine(hbuf, ln + 37, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 38, "")
    InsBufLine(hbuf, ln + 39, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 40, " * constants                                    *")
    InsBufLine(hbuf, ln + 41, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 42, "")
    InsBufLine(hbuf, ln + 43, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 44, " * macros                                       *")
    InsBufLine(hbuf, ln + 45, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 46, "")
    InsBufLine(hbuf, ln + 47, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 48, " * routines' implementations                    *")
    InsBufLine(hbuf, ln + 49, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 50, "")
    if(iLen != 0)
    {
        return
    }
    //���û�й���������������ʾ����
    szContent = Ask("Description")
    SetBufIns(hbuf,nlnDesc + 14,0)
    DelBufLine(hbuf,nlnDesc +10)
    //ע���������,�Զ�����
    CommentContent(hbuf,nlnDesc + 10,"  Description   : ",szContent,0)
}


/*****************************************************************************
 �� �� ��  : InsertFileHeaderCN
 ��������  : �������������ļ�ͷ˵��
 �������  : hbuf
             ln
             szName
             szContent
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertFileHeaderCN(hbuf, ln,szName,szContent)
{
    InsBufLine(hbuf, ln + 0,  "/******************************************************************************")
    InsBufLine(hbuf, ln + 1,  "")
    InsBufLine(hbuf, ln + 2,  "                  ��Ȩ���� (C), 2001-2011, ��Ϊ�������޹�˾")
    InsBufLine(hbuf, ln + 3,  "")
    InsBufLine(hbuf, ln + 4,  " ******************************************************************************")
    sz = GetFileName(GetBufName (hbuf))
    InsBufLine(hbuf, ln + 5,  "  �� �� ��   : @sz@")
    InsBufLine(hbuf, ln + 6,  "  �� �� ��   : ����")
    InsBufLine(hbuf, ln + 7,  "  ��    ��   : @szName@")
    SysTime = GetSysTime(1)
    szTime = SysTime.Date
    InsBufLine(hbuf, ln + 8,  "  ��������   : @szTime@")
    InsBufLine(hbuf, ln + 9,  "  ����޸�   :")
    iLen = strlen (szContent)
    nlnDesc = ln
    szTmp = "  ��������   : "
    InsBufLine(hbuf, ln + 10, "  ��������   : @szContent@")
    InsBufLine(hbuf, ln + 11, "  �����б�   :")
    //���뺯���б�
    ln = InsertFileList(hbuf,ln + 12) - 12
    InsBufLine(hbuf, ln + 12, "  �޸���ʷ   :")
    InsBufLine(hbuf, ln + 13, "  1.��    ��   : @szTime@")

    if( strlen(szMyName)>0 )
    {
       InsBufLine(hbuf, ln + 14, "    ��    ��   : @szName@")
    }
    else
    {
       InsBufLine(hbuf, ln + 14, "    ��    ��   : #")
    }
    InsBufLine(hbuf, ln + 15, "    �޸�����   : �����ļ�")
    InsBufLine(hbuf, ln + 16, "")
    InsBufLine(hbuf, ln + 17, "******************************************************************************/")
    InsBufLine(hbuf, ln + 18, "")
    InsBufLine(hbuf, ln + 19, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 20, " * �ⲿ����˵��                                 *")
    InsBufLine(hbuf, ln + 21, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 22, "")
    InsBufLine(hbuf, ln + 23, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 24, " * �ⲿ����ԭ��˵��                             *")
    InsBufLine(hbuf, ln + 25, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 26, "")
    InsBufLine(hbuf, ln + 27, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 28, " * �ڲ�����ԭ��˵��                             *")
    InsBufLine(hbuf, ln + 29, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 30, "")
    InsBufLine(hbuf, ln + 31, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 32, " * ȫ�ֱ���                                     *")
    InsBufLine(hbuf, ln + 33, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 34, "")
    InsBufLine(hbuf, ln + 35, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 36, " * ģ�鼶����                                   *")
    InsBufLine(hbuf, ln + 37, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 38, "")
    InsBufLine(hbuf, ln + 39, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 40, " * ��������                                     *")
    InsBufLine(hbuf, ln + 41, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 42, "")
    InsBufLine(hbuf, ln + 43, "/*----------------------------------------------*")
    InsBufLine(hbuf, ln + 44, " * �궨��                                       *")
    InsBufLine(hbuf, ln + 45, " *----------------------------------------------*/")
    InsBufLine(hbuf, ln + 46, "")
    if(strlen(szContent) != 0)
    {
        return
    }
    //���û�����빦�������Ļ���ʾ����
    szContent = Ask("�������ļ���������������")
    SetBufIns(hbuf,nlnDesc + 14,0)
    DelBufLine(hbuf,nlnDesc +10)
    //�Զ�������ʾ��������
    CommentContent(hbuf,nlnDesc+10,"  ��������   : ",szContent,0)
}

/*****************************************************************************
 �� �� ��  : InsertFileList
 ��������  : �����б����
 �������  : hbuf
             ln
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertFileList(hbuf,ln)
{
    hnewbuf = newbuf("")
    if(hnewbuf == hNil)
    {
        stop
    }
    isymMax = GetBufSymCount (hbuf)
    isym = 0
    //����ȡ��ȫ���ĵ�ǰbuf���ű��е�ȫ������
    while (isym < isymMax)
    {
        symbol = GetBufSymLocation(hbuf, isym)
        if(strlen(symbol) > 0)
        {
            if((symbol.Type == "Function") || ("Editor Macro" == symbol.Type))
            {
                //ȡ�������Ǻ����ͺ�ķ���
                symname = symbol.Symbol
                //�����Ų��뵽��buf����������Ϊ�˼���V2.1
                AppendBufLine(hnewbuf,symname)
               }
           }
        isym = isym + 1
    }
    isymMax = GetBufLineCount (hnewbuf)
    isym = 0
    while (isym < isymMax)
    {
        szLine = GetBufLine(hnewbuf, isym)
        InsBufLine(hbuf,ln,"              @szLine@")
        ln = ln + 1
        isym = isym + 1
    }
    closebuf(hnewbuf)
    return ln
}


/*****************************************************************************
 �� �� ��  : CommentContent1
 ��������  : �Զ�������ʾ�ı�,�Զ�����κ�Ϊһ��
 �������  : hbuf
             ln         �к�
             szPreStr   ������Ҫ������ַ���
             szContent  ��Ҫ������ַ�������
             isEnd      �Ƿ���Ҫ��ĩβ����'*'��'/'
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CommentContent1 (hbuf,ln,szPreStr,szContent,isEnd)
{
    //���������еĶ���ı��ϲ�
    szClip = MergeString()
    //ȥ������Ŀո�
    szTmp = TrimString(szContent)
    //������봰���е������Ǽ������е�����˵���Ǽ���������
    ret = strstr(szClip,szTmp)
    if(ret == 0)
    {
        szContent = szClip
    }
    szLeftBlank = szPreStr
    iLen = strlen(szPreStr)
    k = 0
    while(k < iLen)
    {
        szLeftBlank[k] = " ";
        k = k + 1;
    }
    iLen = strlen (szContent)
    szTmp = cat(szPreStr,"#");
    if( iLen == 0)
    {
        InsBufLine(hbuf, ln, "@szTmp@")
    }
    else
    {
        i = 0
        while  (iLen - i > 75 - k )
        {
            j = 0
            while(j < 75 - k)
            {
                iNum = szContent[i + j]
                //��������ı���ɶԴ���
                if( AsciiFromChar (iNum)  > 160 )
                {
                   j = j + 2
                }
                else
                {
                   j = j + 1
                }
                if( (j > 70 - k) && (szContent[i + j] == " ") )
                {
                    break
                }
            }
            if( (szContent[i + j] != " " ) )
            {
                n = 0;
                iNum = szContent[i + j + n]
                while( (iNum != " " ) && (AsciiFromChar (iNum)  < 160))
                {
                    n = n + 1
                    if((n >= 3) ||(i + j + n >= iLen))
                         break;
                    iNum = szContent[i + j + n]
                   }
                if(n < 3)
                {
                    j = j + n
                    sz1 = strmid(szContent,i,i+j)
                    sz1 = cat(szPreStr,sz1)
                }
                else
                {
                    sz1 = strmid(szContent,i,i+j)
                    sz1 = cat(szPreStr,sz1)
                    if(sz1[strlen(sz1)-1] != "-")
                    {
                        sz1 = cat(sz1,"-")
                    }
                }
            }
            else
            {
                sz1 = strmid(szContent,i,i+j)
                sz1 = cat(szPreStr,sz1)
            }
            InsBufLine(hbuf, ln, "@sz1@")
            ln = ln + 1
            szPreStr = szLeftBlank
            i = i + j
            while(szContent[i] == " ")
            {
                i = i + 1
            }
        }
        sz1 = strmid(szContent,i,iLen)
        sz1 = cat(szPreStr,sz1)
        if(isEnd)
        {
            sz1 = cat(sz1,"*/")
        }
        InsBufLine(hbuf, ln, "@sz1@")
    }
    return ln
}



/*****************************************************************************
 �� �� ��  : CommentContent
 ��������  : �Զ�������ʾ�ı�?

 �������  : hbuf
             ln         �к�
             szPreStr   ������Ҫ������ַ���
             szContent  ��Ҫ������ַ�������
             isEnd      �Ƿ���Ҫ��ĩβ����'*'��'/'
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CommentContent (hbuf,ln,szPreStr,szContent,isEnd)
{
    szLeftBlank = szPreStr
    iLen = strlen(szPreStr)
    k = 0
    while(k < iLen)
    {
        szLeftBlank[k] = " ";
        k = k + 1;
    }

    hNewBuf = newbuf("clip")
    if(hNewBuf == hNil)
        return
    SetCurrentBuf(hNewBuf)
    PasteBufLine (hNewBuf, 0)
    lnMax = GetBufLineCount( hNewBuf )
    szTmp = TrimString(szContent)
    szLine = GetBufLine(hNewBuf , 0)
    ret = strstr(szLine,szTmp)
    if(ret == 0)
    {
        /*������봰����������Ǽ������һ����˵���Ǽ���������ȡ�������е���
          ��*/
        szContent = TrimString(szLine)
    }
    else
    {
        lnMax = 1
    }
    szRet = ""
    nIdx = 0
    while ( nIdx < lnMax)
    {
        if(nIdx != 0)
        {
            szLine = GetBufLine(hNewBuf , nIdx)
            szContent = TrimLeft(szLine)
               szPreStr = szLeftBlank
        }
        iLen = strlen (szContent)
        szTmp = cat(szPreStr,"#");
        if( (iLen == 0) && (nIdx == (lnMax - 1))
        {
            InsBufLine(hbuf, ln, "@szTmp@")
        }
        else
        {
            i = 0
            //��ÿ��75���ַ�����
            while  (iLen - i > 75 - k )
            {
                j = 0
                while(j < 75 - k)
                {
                    iNum = szContent[i + j]
                    if( AsciiFromChar (iNum)  > 160 )
                    {
                       j = j + 2
                    }
                    else
                    {
                       j = j + 1
                    }
                    if( (j > 70 - k) && (szContent[i + j] == " ") )
                    {
                        break
                    }
                }
                if( (szContent[i + j] != " " ) )
                {
                    n = 0;
                    iNum = szContent[i + j + n]
                    //����������ַ�ֻ�ܳɶԴ���
                    while( (iNum != " " ) && (AsciiFromChar (iNum)  < 160))
                    {
                        n = n + 1
                        if((n >= 3) ||(i + j + n >= iLen))
                             break;
                        iNum = szContent[i + j + n]
                    }
                    if(n < 3)
                    {
                        //�ֶκ�ֻ��С��3�����ַ������¶���������ȥ
                        j = j + n
                        sz1 = strmid(szContent,i,i+j)
                        sz1 = cat(szPreStr,sz1)
                    }
                    else
                    {
                        //����3���ַ��ļ����ַ��ֶ�
                        sz1 = strmid(szContent,i,i+j)
                        sz1 = cat(szPreStr,sz1)
                        if(sz1[strlen(sz1)-1] != "-")
                        {
                            sz1 = cat(sz1,"-")
                        }
                    }
                }
                else
                {
                    sz1 = strmid(szContent,i,i+j)
                    sz1 = cat(szPreStr,sz1)
                }
                InsBufLine(hbuf, ln, "@sz1@")
                ln = ln + 1
                szPreStr = szLeftBlank
                i = i + j
                while(szContent[i] == " ")
                {
                    i = i + 1
                }
            }
            sz1 = strmid(szContent,i,iLen)
            sz1 = cat(szPreStr,sz1)
            if((isEnd == 1) && (nIdx == (lnMax - 1))
            {
                sz1 = cat(sz1,"*/")
            }
            InsBufLine(hbuf, ln, "@sz1@")
        }
        ln = ln + 1
        nIdx = nIdx + 1
    }
    closebuf(hNewBuf)
    return ln - 1
}

/*****************************************************************************
 �� �� ��  : FormatLine
 ��������  : ��һ�г��ı������Զ�����
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro FormatLine()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    // get line the selection (insertion point) is on
    szCurLine = GetBufLine(hbuf, sel.lnFirst);
    lineLen = strlen(szCurLine)
    szLeft = strmid(szCurLine,0,sel.ichFirst)
    szContent = strmid(szCurLine,sel.ichFirst,lineLen)
    DelBufLine(hbuf, sel.lnFirst)
    CommentContent(hbuf,sel.lnFirst,szLeft,szContent,0)

}

/*****************************************************************************
 �� �� ��  : CreateBlankString
 ��������  : ���������ո���ַ���
 �������  : nBlankCount
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreateBlankString(nBlankCount)
{
    szBlank=""
    nIdx = 0
    while(nIdx < nBlankCount)
    {
        szBlank = cat(szBlank," ")
        nIdx = nIdx + 1
    }
    return szBlank
}

/*****************************************************************************
 �� �� ��  : TrimLeft
 ��������  : ȥ���ַ�����ߵĿո�
 �������  : szLine
 �������  : ȥ����ո����ַ���
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro TrimLeft(szLine)
{
    nLen = strlen(szLine)
    if(nLen == 0)
    {
        return szLine
    }
    nIdx = 0
    while( nIdx < nLen )
    {
        if( ( szLine[nIdx] != " ") && (szLine[nIdx] != "\t") )
        {
            break
        }
        nIdx = nIdx + 1
    }
    return strmid(szLine,nIdx,nLen)
}

/*****************************************************************************
 �� �� ��  : TrimRight
 ��������  : ȥ���ַ����ұߵĿո�
 �������  : szLine
 �������  : ȥ���ҿո����ַ���
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro TrimRight(szLine)
{
    nLen = strlen(szLine)
    if(nLen == 0)
    {
        return szLine
    }
    nIdx = nLen
    while( nIdx > 0 )
    {
        nIdx = nIdx - 1
        if( ( szLine[nIdx] != " ") && (szLine[nIdx] != "\t") )
        {
            break
        }
    }
    return strmid(szLine,0,nIdx+1)
}

/*****************************************************************************
 �� �� ��  : TrimString
 ��������  : ȥ���ַ������ҿո�
 �������  : szLine
 �������  : ȥ�����ҿո����ַ���
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro TrimString(szLine)
{
    szLine = TrimLeft(szLine)
    szLIne = TrimRight(szLine)
    return szLine
}
macro StartsWithString(str1,str2,length)
{
	str1Length=strlen(str1)
	str2Length=strlen(str2)

	if(str1Length>=str2Length){
	    nIdx = str2Length
	    while( nIdx > 0 )
	    {
	        nIdx = nIdx - 1
	        if( str1[nIdx] !=str2[nIdx]){
	            return false
	        }
	    }
	    return true
	}
	return false
}
macro EndsWithString(str1,str2,length)
{
	str1Length=strlen(str1)
	str2Length=strlen(str2)
	if(str1Length>=str2Length){
	    nIdx = 0
	    while( nIdx > str2Length )
	    {
	        if( str1[str1Length-1-str2Length+nIdx] !=str2[nIdx]){
	            return false
	        }
	    }
	    return true
	}
	return false
}

/*****************************************************************************
 �� �� ��  : GetFunctionDef
 ��������  : ���ֳɶ��еĺ�������ͷ�ϲ���һ��
 �������  : hbuf
             symbol  ��������
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetFunctionDef(hbuf,symbol)
{
    ln = symbol.lnName
    szFunc = ""
       if(strlen(symbol) == 0)
       {
           return szFunc
    }
    fIsEnd = 1
    while(ln < symbol.lnLim)
    {
        szLine = GetBufLine (hbuf, ln)
        //ȥ����ע�͵�������
        RetVal = SkipCommentFromString(szLine,fIsEnd)
		szLine = RetVal.szContent
		szLine = TrimString(szLine)
		fIsEnd = RetVal.fIsEnd
        //�����{��ʾ��������ͷ������
        ret = strstr(szLine,"{")
        if(ret != 0xffffffff)
        {
            szLine = strmid(szLine,0,ret)
            szFunc = cat(szFunc,szLine)
            break
        }
        szFunc = cat(szFunc,szLine)
        ln = ln + 1
    }
    return szFunc
}

/*****************************************************************************
 �� �� ��  : GetWordFromString
 ��������  : ���ַ�����ȡ����ĳ�ַ�ʽ�ָ���ַ�����
 �������  : hbuf         ���ɷָ���ַ�����buf
             szLine       �ַ���
             nBeg         ��ʼ����λ��
             nEnd         ��������λ��
             chBeg        ��ʼ���ַ���־
             chSeparator  �ָ��ַ�
             chEnd        �����ַ���־
 �������  : ����ַ�����
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetWordFromString(hbuf,szLine,nBeg,nEnd,chBeg,chSeparator,chEnd)
{
    if((nEnd > strlen(szLine) || (nBeg > nEnd))
    {
        return 0
    }
    nMaxLen = 0
    nIdx = nBeg
    //�ȶ�λ����ʼ�ַ���Ǵ�
    while(nIdx < nEnd)
    {
        if(szLine[nIdx] == chBeg)
        {
            break
        }
        nIdx = nIdx + 1
    }
    nBegWord = nIdx + 1
    nEndWord = 0
    //�Էָ���Ϊ��ǽ�������
    while(nIdx < nEnd)
    {
        if(szLine[nIdx] == chSeparator)
        {
           szWord = strmid(szLine,nBegWord,nIdx)
           szWord = TrimString(szWord)
           nLen = strlen(szWord)
           if(nMaxLen < nLen)
           {
               nMaxLen = nLen
           }
           AppendBufLine(hbuf,szWord)
           nBegWord = nIdx + 1
        }
        if(szLine[nIdx] == chEnd)
        {
            nEndWord = nIdx
        }
        nIdx = nIdx + 1
    }
    if(nEndWord > nBegWord)
    {
        szWord = strmid(szLine,nBegWord,nEndWord)
        szWord = TrimString(szWord)
        nLen = strlen(szWord)
        if(nMaxLen < nLen)
        {
            nMaxLen = nLen
        }
        AppendBufLine(hbuf,szWord)
    }
    return nMaxLen
}


/*****************************************************************************
 �� �� ��  : FuncHeadCommentCN
 ��������  : �������ĵĺ���ͷע��
 �������  : hbuf
             ln        �к�
             szFunc    ������
             szMyName  ������
             newFunc   �Ƿ��º���
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro FuncHeadCommentCN(hbuf, ln, szFunc, szMyName,newFunc)
{
    if(newFunc != 1)
    {
        symbol = GetSymbolLocationFromLn(hbuf, ln)
        if(strlen(symbol) > 0)
        {
            hTmpBuf = NewBuf("Tempbuf")
            if(hTmpBuf == hNil)
            {
                stop
            }
            //���ļ�����ͷ�����һ�в�ȥ����ע��
            szLine = GetFunctionDef(hbuf,symbol)
            iBegin = symbol.ichName +strlen(szFunc)
            //ȡ������ֵ����
            szRet =  strmid(szLine,0,symbol.ichName)
            szRet = TrimString(szRet)
            if(toupper (szRet) == "MACRO")
            {
                //���ں귵��ֵ���⴦��
                szRet = ""
            }
            //�Ӻ���ͷ�������������
            nMaxParamSize = GetWordFromString(hTmpBuf,szLine,iBegin,strlen(szLine),"(",",",")")
            lnMax = GetBufLineCount(hTmpBuf)
            ln = symbol.lnFirst
            SetBufIns (hbuf, ln, 0)
        }
    }
    else
    {
        lnMax = 0
        iIns = 0
        szLine = ""
        szRet = ""
    }
    InsBufLine(hbuf, ln, "/*****************************************************************************")
    if( strlen(szFunc)>0 )
    {
        InsBufLine(hbuf, ln+1, " �� �� ��  : @szFunc@")
    }
    else
    {
        InsBufLine(hbuf, ln+1, " �� �� ��  : #")
    }
    oldln = ln
    InsBufLine(hbuf, ln+2, " ��������  : ")
    szIns = " �������  : "
    if(newFunc != 1)
    {
        //�����Ѿ����ڵĺ������뺯������
        i = 0
        while ( i < lnMax)
        {
            szTmp = GetBufLine(hTmpBuf, i)
            nLen = strlen(szTmp);
            szBlank = CreateBlankString(nMaxParamSize - nLen + 2)
            szTmp = cat(szTmp,szBlank)
            ln = ln + 1
            szTmp = cat(szIns,szTmp)
            InsBufLine(hbuf, ln+2, "@szTmp@")
            iIns = 1
            szIns = "             "
            i = i + 1
        }
        closebuf(hTmpBuf)
    }
    if(iIns == 0)
    {
            ln = ln + 1
            InsBufLine(hbuf, ln+2, " �������  : ��")
    }
    InsBufLine(hbuf, ln+3, " �������  : ��")
    InsBufLine(hbuf, ln+4, " �� �� ֵ  : @szRet@")
    InsBufLine(hbuf, ln+5, " ���ú���  : ")
    InsBufLine(hbuf, ln+6, " ��������  : ")
    InsbufLIne(hbuf, ln+7, " ");
    InsBufLine(hbuf, ln+8, " �޸���ʷ      :")

    SysTime = GetSysTime(1);
    szTime = SysTime.Date

    InsBufLine(hbuf, ln+9, "  1.��    ��   : @szTime@")

    if( strlen(szMyName)>0 )
    {
       InsBufLine(hbuf, ln+10, "    ��    ��   : @szMyName@")
    }
    else
    {
       InsBufLine(hbuf, ln+10, "    ��    ��   : #")
    }
    InsBufLine(hbuf, ln+11, "    �޸�����   : �����ɺ���")
    InsBufLine(hbuf, ln+12, "")
    InsBufLine(hbuf, ln+13, "*****************************************************************************/")
    if ((newFunc == 1) && (strlen(szFunc)>0))
    {
        InsBufLine(hbuf, ln+14, "UINT32  @szFunc@( # )")
        InsBufLine(hbuf, ln+15, "{");
        InsBufLine(hbuf, ln+16, "    #");
        InsBufLine(hbuf, ln+17, "}");
        SearchForward()
    }
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    sel.ichFirst = 0
    sel.ichLim = sel.ichFirst
    sel.lnFirst = ln + 14
    sel.lnLast = ln + 14
    szContent = Ask("�����뺯����������������")
    setWndSel(hwnd,sel)
    DelBufLine(hbuf,oldln + 2)
    newln = CommentContent(hbuf,oldln+2," ��������  : ",szContent,0) - 2
    ln = ln + newln - oldln
    if ((newFunc == 1) && (strlen(szFunc)>0))
    {
        isFirstParam = 1
        szRet = Ask("�����뷵��ֵ����")
        if(strlen(szRet) > 0)
        {
            PutBufLine(hbuf, ln+4, " �� �� ֵ  : @szRet@")
            PutBufLine(hbuf, ln+14, "@szRet@ @szFunc@(   )")
            SetbufIns(hbuf,ln+14,strlen(szRet)+strlen(szFunc) + 3
        }
        szFuncDef = ""
        sel.ichFirst = strlen(szFunc)+strlen(szRet) + 3
        sel.ichLim = sel.ichFirst + 1
        //ѭ���������
        while (1)
        {
            szParam = ask("�����뺯��������")
            szParam = TrimString(szParam)
            szTmp = cat(szIns,szParam)
            szParam = cat(szFuncDef,szParam)
            sel.lnFirst = ln + 14
            sel.lnLast = ln + 14
            setWndSel(hwnd,sel)
            sel.ichFirst = sel.ichFirst + strlen(szParam)
            sel.ichLim = sel.ichFirst
            oldsel = sel
            if(isFirstParam == 1)
            {
                PutBufLine(hbuf, ln+2, "@szTmp@")
                isFirstParam  = 0
            }
            else
            {
                ln = ln + 1
                InsBufLine(hbuf, ln+2, "@szTmp@")
                oldsel.lnFirst = ln + 14
                oldsel.lnLast = ln + 14
            }
            SetBufSelText(hbuf,szParam)
            szIns = "             "
            szFuncDef = ", "
            oldsel.lnFirst = ln + 16
            oldsel.lnLast = ln + 16
            oldsel.ichFirst = 4
            oldsel.ichLim = 5
            setWndSel(hwnd,oldsel)
        }
    }
    return ln + 17
}

/*****************************************************************************
 �� �� ��  : FuncHeadCommentEN
 ��������  : ����ͷӢ��˵��
 �������  : hbuf
             ln
             szFunc
             szMyName
             newFunc
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro FuncHeadCommentEN(hbuf, ln, szFunc, szMyName,newFunc)
{
    if(newFunc != 1)
    {
        symbol = GetSymbolLocationFromLn(hbuf, ln)
        if(strlen(symbol) > 0)
        {
            hTmpBuf = NewBuf("Tempbuf")

            //���ļ�����ͷ�����һ�в�ȥ����ע��
            szLine = GetFunctionDef(hbuf,symbol)
            iBegin = symbol.ichName +strlen(szFunc)

            //ȡ������ֵ����
            szRet =  strmid(szLine,0,symbol.ichName)
            szRet = TrimString(szRet)
            if(toupper (szRet) == "MACRO")
            {
                //���ں귵��ֵ���⴦��
                szRet = ""
            }

            //�Ӻ���ͷ�������������
            nMaxParamSize = GetWordFromString(hTmpBuf,szLine,iBegin,strlen(szLine),"(",",",")")
            lnMax = GetBufLineCount(hTmpBuf)
            ln = symbol.lnFirst
            SetBufIns (hbuf, ln, 0)
        }
    }
    else
    {
        lnMax = 0
        iIns = 0
        szRet = ""
        szLine = ""
    }
    InsBufLine(hbuf, ln, "/*****************************************************************************")
    InsBufLine(hbuf, ln+1, " Prototype    : @szFunc@")
    InsBufLine(hbuf, ln+2, " Description  : ")
    oldln  = ln
    szIns = " Input        : "
    if(newFunc != 1)
    {
        //�����Ѿ����ڵĺ���������������
        i = 0
        while ( i < lnMax)
        {
            szTmp = GetBufLine(hTmpBuf, i)
            nLen = strlen(szTmp);
            szBlank = CreateBlankString(nMaxParamSize - nLen + 2)
            szTmp = cat(szTmp,szBlank)
            ln = ln + 1
            szTmp = cat(szIns,szTmp)
            InsBufLine(hbuf, ln+2, "@szTmp@")
            iIns = 1
            szIns = "                "
            i = i + 1
        }
        closebuf(hTmpBuf)
    }
    if(iIns == 0)
    {
            ln = ln + 1
            InsBufLine(hbuf, ln+2, " Input        : None")
    }
    InsBufLine(hbuf, ln+3, " Output       : None")
    InsBufLine(hbuf, ln+4, " Return Value : ")
    InsBufLine(hbuf, ln+5, " Calls        : ")
    InsBufLine(hbuf, ln+6, " Called By    : ")
    InsbufLIne(hbuf, ln+7, " ");

    SysTime = GetSysTime(1);
    sz1=SysTime.Year
    sz2=SysTime.month
    sz3=SysTime.day

    InsBufLine(hbuf, ln + 8, "  History        :")
    InsBufLine(hbuf, ln + 9, "  1.Date         : @sz1@/@sz2@/@sz3@")
    InsBufLine(hbuf, ln + 10, "    Author       : @szMyName@")
    InsBufLine(hbuf, ln + 11, "    Modification : Created function")
    InsBufLine(hbuf, ln + 12, "")
    InsBufLine(hbuf, ln + 13, "*****************************************************************************/")
    if ((newFunc == 1) && (strlen(szFunc)>0))
    {
        InsBufLine(hbuf, ln+14, "UINT32  @szFunc@( # )")
        InsBufLine(hbuf, ln+15, "{");
        InsBufLine(hbuf, ln+16, "    #");
        InsBufLine(hbuf, ln+17, "}");
        SearchForward()
    }
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    sel.ichFirst = 0
    sel.ichLim = sel.ichFirst
    sel.lnFirst = ln + 14
    sel.lnLast = ln + 14
    szContent = Ask("Description")
    DelBufLine(hbuf,oldln + 2)
    setWndSel(hwnd,sel)
    newln = CommentContent(hbuf,oldln + 2," Description  : ",szContent,0) - 2
    ln = ln + newln - oldln
    if ((newFunc == 1) && (strlen(szFunc)>0))
    {
        szRet = Ask("Please input return value type")
        if(strlen(szRet) > 0)
        {
            PutBufLine(hbuf, ln+4, " Return Value : @szRet@")
            PutBufLine(hbuf, ln+14, "@szRet@ @szFunc@( # )")
            SetbufIns(hbuf,ln+14,strlen(szRet)+strlen(szFunc) + 3
        }
        szFuncDef = ""
        isFirstParam = 1
        sel.ichFirst = strlen(szFunc)+strlen(szRet) + 3
        sel.ichLim = sel.ichFirst + 1
        while (1)
        {
            szParam = ask("Please input parameter")
            szParam = TrimString(szParam)
            szTmp = cat(szIns,szParam)
            szParam = cat(szFuncDef,szParam)
            sel.lnFirst = ln + 14
            sel.lnLast = ln + 14
            setWndSel(hwnd,sel)
            sel.ichFirst = sel.ichFirst + strlen(szParam)
            sel.ichLim = sel.ichFirst
            oldsel = sel
            if(isFirstParam == 1)
            {
                PutBufLine(hbuf, ln+2, "@szTmp@")
                isFirstParam  = 0
            }
            else
            {
                ln = ln + 1
                InsBufLine(hbuf, ln+2, "@szTmp@")
                oldsel.lnFirst = ln + 14
                oldsel.lnLast = ln + 14
            }
            SetBufSelText(hbuf,szParam)
            szIns = "                "
            szFuncDef = ", "
            oldsel.lnFirst = ln + 16
            oldsel.lnLast = ln + 16
            oldsel.ichFirst = 4
            oldsel.ichLim = 5
            setWndSel(hwnd,oldsel)
        }
    }
    return ln + 17
}

/*****************************************************************************
 �� �� ��  : InsertHistory
 ��������  : �����޸���ʷ��¼
 �������  : hbuf
             ln        �к�
             language  ����
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertHistory(hbuf,ln,language)
{
    iHistoryCount = 1
    isLastLine = ln
    i = 0
    while(ln-i>0)
    {
        szCurLine = GetBufLine(hbuf, ln-i);
        iBeg1 = strstr(szCurLine,"��    ��  ")
        iBeg2 = strstr(szCurLine,"Date      ")
        if((iBeg1 != 0xffffffff) || (iBeg2 != 0xffffffff))
        {
            iHistoryCount = iHistoryCount + 1
            i = i + 1
            continue
        }
        iBeg1 = strstr(szCurLine,"�޸���ʷ")
        iBeg2 = strstr(szCurLine,"History      ")
        if((iBeg1 != 0xffffffff) || (iBeg2 != 0xffffffff))
        {
            break
        }
        iBeg = strstr(szCurLine,"/**********************")
        if( iBeg != 0xffffffff )
        {
            break
        }
        i = i + 1
    }
    if(language == 0)
    {
        InsertHistoryContentCN(hbuf,ln,iHistoryCount)
    }
    else
    {
        InsertHistoryContentEN(hbuf,ln,iHistoryCount)
    }
}

/*****************************************************************************
 �� �� ��  : UpdateFunctionList
 ��������  : ���º����б�
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro UpdateFunctionList()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    ln = sel.lnFirst
    iHistoryCount = 1
    isLastLine = ln
    iTotalLn = GetBufLineCount (hbuf)
    while(ln < iTotalLn)
    {
        szCurLine = GetBufLine(hbuf, ln);
        iLen = strlen(szCurLine)
        j = 0;
        while(j < iLen)
        {
            if(szCurLine[j] != " ")
                break
            j = j + 1
        }
        if(j > 10)
        {
            DelBufLine(hbuf, ln)
        }
        else
        {
            break
        }
        iTotalLn = GetBufLineCount (hbuf)
    }
    InsertFileList(hbuf,ln)
 }

/*****************************************************************************
 �� �� ��  : InsertHistoryContentCN
 ��������  : ������ʷ�޸ļ�¼����˵��
 �������  : hbuf
             ln
             iHostoryCount
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro  InsertHistoryContentCN(hbuf,ln,iHostoryCount)
{
    SysTime = GetSysTime(1);
    szTime = SysTime.Date
    szMyName = getreg(MYNAME)

    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln + 1, "  @iHostoryCount@.��    ��   : @szTime@")

    if( strlen(szMyName) > 0 )
    {
       InsBufLine(hbuf, ln + 2, "    ��    ��   : @szMyName@")
    }
    else
    {
       InsBufLine(hbuf, ln + 2, "    ��    ��   : #")
    }
       szContent = Ask("�������޸ĵ�����")
       CommentContent(hbuf,ln + 3,"    �޸�����   : ",szContent,0)
}


/*****************************************************************************
 �� �� ��  : InsertHistoryContentEN
 ��������  : ������ʷ�޸ļ�¼Ӣ��˵��
 �������  : hbuf
             ln
             iHostoryCount
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro  InsertHistoryContentEN(hbuf,ln,iHostoryCount)
{
    SysTime = GetSysTime(1);
    szTime = SysTime.Date
    sz1=SysTime.Year
    sz2=SysTime.month
    sz3=SysTime.day
    szMyName = getreg(MYNAME)
    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln + 1, "  @iHostoryCount@.Date         : @sz1@/@sz2@/@sz3@")

    InsBufLine(hbuf, ln + 2, "    Author       : @szMyName@")
       szContent = Ask("Please input modification")
       CommentContent(hbuf,ln + 3,"    Modification : ",szContent,0)
}

/*****************************************************************************
 �� �� ��  : CreateFunctionDef
 ��������  : ����C����ͷ�ļ�
 �������  : hbuf
             szName
             language
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CreateFunctionDef(hbuf, szName, language)
{
    ln = 0

    //��õ�ǰû�к�׺���ļ���
    szFileName = GetFileNameNoExt(GetBufName (hbuf))
    if(strlen(szFileName) == 0)
    {
        sz = ask("������ͷ�ļ���")
        szFileName = GetFileNameNoExt(sz)
        szExt = GetFileNameExt(szFileName)
        szPreH = toupper (szFileName)
        szPreH = cat("__",szPreH)
        szExt = toupper(szExt)
        szPreH = cat(szPreH,"_@szExt@__")
    }
    szPreH = toupper (szFileName)
    sz = cat(szFileName,".h")
    szPreH = cat("__",szPreH)
    szPreH = cat(szPreH,"_H__")
    hOutbuf = NewBuf(sz) // create output buffer
    if (hOutbuf == 0)
        stop
    //�������ű�ȡ�ú�����
    isymMax = GetBufSymCount(hbuf)
    isym = 0
    while (isym < isymMax)
    {
        isLastLine = 0
        symbol = GetBufSymLocation(hbuf, isym)
        fIsEnd = 1
        if(strlen(symbol) > 0)
        {
            if(symbol.Type == "Function")
            {
                szLine = GetBufLine (hbuf, symbol.lnName)
                //ȥ��ע�͵ĸ���
                RetVal = SkipCommentFromString(szLine,fIsEnd)
		        szNew = RetVal.szContent
		        fIsEnd = RetVal.fIsEnd
                szLine = cat("extern ",szLine)
                szNew = cat("extern ",szNew)
                sline = symbol.lnFirst
                while((isLastLine == 0) && (sline < symbol.lnLim))
                {
                    i = 0
                    j = 0
                    iLen = strlen(szNew)
                    while(i < iLen)
                    {
                        if(szNew[i]=="(")
                        {
                           j = j + 1;
                        }
                        else if(szNew[i]==")")
                        {
                            j = j - 1;
                            if(j <= 0)
                            {
                                //��������ͷ����
                                isLastLine = 1
                                //ȥ����������ַ�
                    	        szLine = strmid(szLine,0,i+1);
                                szLine = cat(szLine,";")
                                break
                            }
                        }
                        i = i + 1
                    }
                    InsBufLine(hOutbuf, ln, "@szLine@")
                    ln = ln + 1
                    sline = sline + 1
                    if(isLastLine != 1)
                    {
                        //��������ͷ��û�н�����ȡһ��
                        szLine = GetBufLine (hbuf, sline)
                        szLine = cat("       ",szLine)
                        //ȥ��ע�͵ĸ���
		                RetVal = SkipCommentFromString(szLine,fIsEnd)
				        szNew = RetVal.szContent
				        fIsEnd = RetVal.fIsEnd
                    }
                }
            }
        }
        isym = isym + 1
    }
    SetCurrentBuf(hOutbuf)
    InsertCPP(hOutbuf,0)
    HeadIfdefStr(szPreH)
    szContent = GetFileName(GetBufName (hbuf))
    if(language == 0)
    {
        szContent = cat(szContent," ��ͷ�ļ�")
        InsertFileHeaderCN(hOutbuf,0,szName,szContent)
    }
    else
    {
        szContent = cat(szContent," header file")
        InsertFileHeaderEN(hOutbuf,0,szName,szContent)
    }
}

macro CreateNewHeaderFile()
{
    hbuf = GetCurrentBuf()
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szName = getreg(MYNAME)
    if(strlen( szName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    isymMax = GetBufSymCount(hbuf)
    isym = 0
    ln = 0
    //��õ�ǰû�к�׺���ļ���
    sz = ask("Please input header file name")
    szFileName = GetFileNameNoExt(sz)
    szExt = GetFileNameExt(sz)
    szPreH = toupper (szFileName)
    szPreH = cat("__",szPreH)
    szExt = toupper(szExt)
    szPreH = cat(szPreH,"_@szExt@__")
    hOutbuf = NewBuf(sz) // create output buffer
    if (hOutbuf == 0)
        stop

    SetCurrentBuf(hOutbuf)
    InsertCPP(hOutbuf,0)
    HeadIfdefStr(szPreH)
    szContent = GetFileName(GetBufName (hbuf))
    if(language == 0)
    {
        szContent = cat(szContent," ��ͷ�ļ�")
        InsertFileHeaderCN(hOutbuf,0,szName,szContent)
    }
    else
    {
        szContent = cat(szContent," header file")
        InsertFileHeaderEN(hOutbuf,0,szName,szContent)
    }

    lnMax = GetBufLineCount(hOutbuf)
    if(lnMax > 9)
    {
        ln = lnMax - 9
    }
    else
    {
        return
    }
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    sel.lnFirst = ln
    sel.ichFirst = 0
    sel.ichLim = 0
    SetBufIns(hOutbuf,ln,0)
    szType = Ask ("Please prototype type : extern or static")
    //�������ű�ȡ�ú�����
    while (isym < isymMax)
    {
        isLastLine = 0
        symbol = GetBufSymLocation(hbuf, isym)
        fIsEnd = 1
        if(strlen(symbol) > 0)
        {
            if(symbol.Type == "Function")
            {
                szLine = GetBufLine (hbuf, symbol.lnName)
                //ȥ��ע�͵ĸ���
                RetVal = SkipCommentFromString(szLine,fIsEnd)
		        szNew = RetVal.szContent
		        fIsEnd = RetVal.fIsEnd
                szLine = cat("@szType@ ",szLine)
                szNew = cat("@szType@ ",szNew)
                sline = symbol.lnFirst
                while((isLastLine == 0) && (sline < symbol.lnLim))
                {
                    i = 0
                    j = 0
                    iLen = strlen(szNew)
                    while(i < iLen)
                    {
                        if(szNew[i]=="(")
                        {
                           j = j + 1;
                        }
                        else if(szNew[i]==")")
                        {
                            j = j - 1;
                            if(j <= 0)
                            {
                                //��������ͷ����
                                isLastLine = 1
                                //ȥ����������ַ�
                    	        szLine = strmid(szLine,0,i+1);
                                szLine = cat(szLine,";")
                                break
                            }
                        }
                        i = i + 1
                    }
                    InsBufLine(hOutbuf, ln, "@szLine@")
                    ln = ln + 1
                    sline = sline + 1
                    if(isLastLine != 1)
                    {
                        //��������ͷ��û�н�����ȡһ��
                        szLine = GetBufLine (hbuf, sline)
                        szLine = cat("       ",szLine)
                        //ȥ��ע�͵ĸ���
		                RetVal = SkipCommentFromString(szLine,fIsEnd)
				        szNew = RetVal.szContent
				        fIsEnd = RetVal.fIsEnd
                    }
                }
            }
        }
        isym = isym + 1
    }
    sel.lnLast = ln
    SetWndSel(hwnd,sel)
}


/*   G E T   W O R D   L E F T   O F   I C H   */
/*-------------------------------------------------------------------------
    Given an index to a character (ich) and a string (sz),
    return a "wordinfo" record variable that describes the
    text word just to the left of the ich.

    Output:
        wordinfo.szWord = the word string
        wordinfo.ich = the first ich of the word
        wordinfo.ichLim = the limit ich of the word
-------------------------------------------------------------------------*/
macro GetWordLeftOfIch(ich, sz)
{
    wordinfo = "" // create a "wordinfo" structure

    chTab = CharFromAscii(9)

    // scan backwords over white space, if any
    ich = ich - 1;
    if (ich >= 0)
        while (sz[ich] == " " || sz[ich] == chTab)
        {
            ich = ich - 1;
            if (ich < 0)
                break;
        }

    // scan backwords to start of word
    ichLim = ich + 1;
    asciiA = AsciiFromChar("A")
    asciiZ = AsciiFromChar("Z")
    while (ich >= 0)
    {
        ch = toupper(sz[ich])
        asciiCh = AsciiFromChar(ch)

/*        if ((asciiCh < asciiA || asciiCh > asciiZ)
             && !IsNumber(ch)
             &&  (ch != "#") )
            break // stop at first non-identifier character
*/
        if ((asciiCh < asciiA || asciiCh > asciiZ)
           && !IsNumber(ch)
           && ( ch != "#" && ch != "{" && ch != "/" && ch != "*"))
            break;

        ich = ich - 1;
    }

    ich = ich + 1
    wordinfo.szWord = strmid(sz, ich, ichLim)
    wordinfo.ich = ich
    wordinfo.ichLim = ichLim;

    return wordinfo
}


/*****************************************************************************
 �� �� ��  : ReplaceBufTab
 ��������  : �滻tabΪ�ո�
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ReplaceBufTab()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    iTotalLn = GetBufLineCount (hbuf)
    nBlank = Ask("Enter the number of blanks")
    if(nBlank == 0)
    {
        nBlank = 4
    }
    szBlank = CreateBlankString(nBlank)
    ReplaceInBuf(hbuf,"\t",szBlank,0, iTotalLn, 1, 0, 0, 1)
}

/*****************************************************************************
 �� �� ��  : ReplaceTabInProj
 ��������  : �������������滻tabΪ�ո�
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ReplaceTabInProj()
{
    hprj = GetCurrentProj()
    ifileMax = GetProjFileCount (hprj)
    nBlank = Ask("Enter the number of blanks")
    if(nBlank == 0)
    {
        nBlank = 4
    }
    szBlank = CreateBlankString(nBlank)

    ifile = 0
    while (ifile < ifileMax)
    {
        filename = GetProjFileName (hprj, ifile)
        hbuf = OpenBuf (filename)
        if(hbuf != 0)
        {
            iTotalLn = GetBufLineCount (hbuf)
            ReplaceInBuf(hbuf,"\t",szBlank,0, iTotalLn, 1, 0, 0, 1)
        }
        ifile = ifile + 1
    }
}

/*****************************************************************************
 �� �� ��  : ReplaceInBuf
 ��������  : �滻tabΪ�ո�,ֻ��2.1����Ч
 �������  : hbuf
             chOld
             chNew
             nBeg
             nEnd
             fMatchCase
             fRegExp
             fWholeWordsOnly
             fConfirm
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ReplaceInBuf(hbuf,chOld,chNew,nBeg,nEnd,fMatchCase, fRegExp, fWholeWordsOnly, fConfirm)
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    hbuf = GetWndBuf(hwnd)
    sel = GetWndSel(hwnd)
    sel.ichLim = 0
    sel.lnLast = 0
    sel.ichFirst = sel.ichLim
    sel.lnFirst = sel.lnLast
    SetWndSel(hwnd, sel)
    LoadSearchPattern(chOld, 0, 0, 0);
    while(1)
    {
        Search_Forward
        selNew = GetWndSel(hwnd)
        if(sel == selNew)
        {
            break
        }
        SetBufSelText(hbuf, chNew)
           selNew.ichLim = selNew.ichFirst
        SetWndSel(hwnd, selNew)
        sel = selNew
    }
}


/*****************************************************************************
 �� �� ��  : ConfigureSystem
 ��������  : ����ϵͳ
 �������  : ��
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ConfigureSystem()
{
    szLanguage = ASK("Please select language: 0 Chinese ,1 English");
    if(szLanguage == "#")
    {
       SetReg ("LANGUAGE", "0")
    }
    else
    {
       SetReg ("LANGUAGE", szLanguage)
    }

    szName = ASK("Please input your name");
    if(szName == "#")
    {
       SetReg ("MYNAME", "")
    }
    else
    {
       SetReg ("MYNAME", szName)
    }
    szLoggerName = ASK("Please input your logger name");
    if(szLoggerName == "#")
    {
       SetReg ("MY_LOGGER_NAME", "")
    }
    else
    {
       SetReg ("MY_LOGGER_NAME", szLoggerName)
    }
}
macro getUserName(){
   szName= GetReg("MYNAME")
   if(strlen(szName)<0){
	    szName = ASK("Please input your name");
    	if(szName == "#"){
	       SetReg ("MYNAME", "")
	    }else{
	       SetReg ("MYNAME", szName)
	    }
	}
	return szName;

}
macro getReviewType(){
   szName= GetReg("REVIEW_TYPE")
   if(strlen(szName)<=0){
	    szName = ASK("Please select review type: 0 Code ,1 LLD");
    	if(szName == "#"){
	       SetReg ("REVIEW_TYPE", "")
	    }else{
	       SetReg ("REVIEW_TYPE", szName)
	    }
	}
	return szName;

}

/*****************************************************************************
 �� �� ��  : GetLeftBlank
 ��������  : �õ��ַ�����ߵĿո��ַ���
 �������  : szLine
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetLeftBlank(szLine)
{
    nIdx = 0
    nEndIdx = strlen(szLine)
    while( nIdx < nEndIdx )
    {
        if( (szLine[nIdx] !=" ") && (szLine[nIdx] !="\t") )
        {
            break;
        }
        nIdx = nIdx + 1
    }
    return nIdx
}

/*****************************************************************************
 �� �� ��  : ExpandBraceLittle
 ��������  : С������չ
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ExpandBraceLittle()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    if( (sel.lnFirst == sel.lnLast)
        && (sel.ichFirst == sel.ichLim) )
    {
        SetBufSelText (hbuf, "(  )")
        SetBufIns (hbuf, sel.lnFirst, sel.ichFirst + 2)
    }
    else
    {
        SetBufIns (hbuf, sel.lnFirst, sel.ichFirst)
        SetBufSelText (hbuf, "( ")
        SetBufIns (hbuf, sel.lnLast, sel.ichLim + 2)
        SetBufSelText (hbuf, " )")
    }

}

/*****************************************************************************
 �� �� ��  : ExpandBraceMid
 ��������  : ��������չ
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ExpandBraceMid()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    if( (sel.lnFirst == sel.lnLast)
        && (sel.ichFirst == sel.ichLim) )
    {
        SetBufSelText (hbuf, "[]")
        SetBufIns (hbuf, sel.lnFirst, sel.ichFirst + 1)
    }
    else
    {
        SetBufIns (hbuf, sel.lnFirst, sel.ichFirst)
        SetBufSelText (hbuf, "[")
        SetBufIns (hbuf, sel.lnLast, sel.ichLim + 1)
        SetBufSelText (hbuf, "]")
    }

}

/*****************************************************************************
 �� �� ��  : ExpandBraceLarge
 ��������  : ��������չ
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��18��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ExpandBraceLarge()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    nlineCount = 0
    retVal = ""
    szLine = GetBufLine( hbuf, ln )
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
    szRight = ""
    szMid = ""
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        if( nLeft == strlen(szLine) )
        {
            SetBufSelText (hbuf, "{")
        }
        else
        {
            ln = ln + 1
            InsBufLine(hbuf, ln, "@szLeft@{")
            nlineCount = nlineCount + 1

        }
        InsBufLine(hbuf, ln + 1, "@szLeft@    ")
        InsBufLine(hbuf, ln + 2, "@szLeft@}")
        nlineCount = nlineCount + 2
        SetBufIns (hbuf, ln + 1, strlen(szLeft)+4)
    }
    else
    {
        //����Ƿ���������̫����ʱע�͵�
        RetVal= CheckBlockBrace(hbuf)
        if(RetVal.iCount != 0)
        {
            msg("Invalidated brace number")
            stop
        }
        szOld = strmid(szLine,0,sel.ichFirst)
        if(sel.lnFirst != sel.lnLast)
        {
            szMid = strmid(szLine,sel.ichFirst,strlen(szLine))
            szMid = TrimString(szMid)
            szLast = GetBufLine(hbuf,sel.lnLast)
            if( sel.ichLim > strlen(szLast) )
            {
                szLineselichLim = strlen(szLast)
            }
            else
            {
                szLineselichLim = sel.ichLim
            }
            szRight = strmid(szLast,szLineselichLim,strlen(szLast))
            szRight = TrimString(szRight)
        }
        else
        {
             if(sel.ichLim >= strlen(szLine))
             {
                 sel.ichLim = strlen(szLine)
             }
             szMid = strmid(szLine,sel.ichFirst,sel.ichLim)
             szMid = TrimString(szMid)
             if( sel.ichLim > strlen(szLine) )
             {
                 szLineselichLim = strlen(szLine)
             }
             else
             {
                 szLineselichLim = sel.ichLim
             }
             szRight = strmid(szLine,szLineselichLim,strlen(szLine))
             szRight = TrimString(szRight)
        }
        nIdx = sel.lnFirst
        while( nIdx < sel.lnLast)
        {
             szCurLine = GetBufLine(hbuf,nIdx+1)
             if( sel.ichLim > strlen(szCurLine) )
             {
                 szLineselichLim = strlen(szCurLine)
             }
             else
             {
                 szLineselichLim = sel.ichLim
             }
             szCurLine = cat("    ",szCurLine)
             if(nIdx == sel.lnLast - 1)
             {
                 szCurLine = strmid(szCurLine,0,szLineselichLim + 4)
                 PutBufLine(hbuf,nIdx+1,szCurLine)
             }
             else
             {
                 PutBufLine(hbuf,nIdx+1,szCurLine)
             }
             nIdx = nIdx + 1
        }
        if(strlen(szRight) != 0)
        {
            InsBufLine(hbuf, sel.lnLast + 1, "@szLeft@@szRight@")

        }
        InsBufLine(hbuf, sel.lnLast + 1, "@szLeft@}")
        nlineCount = nlineCount + 1
        if(nLeft < sel.ichFirst)
        {
            PutBufLine(hbuf,ln,szOld)
            InsBufLine(hbuf, ln+1, "@szLeft@{")
            nlineCount = nlineCount + 1
            ln = ln + 1
        }
        else
        {
            DelBufLine(hbuf,ln)
            InsBufLine(hbuf, ln, "@szLeft@{")
        }
        if(strlen(szMid) > 0)
        {
            InsBufLine(hbuf, ln+1, "@szLeft@    @szMid@")
            nlineCount = nlineCount + 1
            ln = ln + 1
        }
    }
    retVal.szLeft = szLeft
    retVal.nLineCount = nlineCount
    return retVal
}

/*
macro ScanStatement(szLine,iBeg)
{
    nIdx = 0
    iLen = strlen(szLine)
    while(nIdx < iLen -1)
    {
        if(szLine[nIdx] == "/" && szLine[nIdx + 1] == "/")
        {
            return 0xffffffff
        }
        if(szLine[nIdx] == "/" && szLine[nIdx + 1] == "*")
        {
           while(nIdx < iLen)
           {
               if(szLine[nIdx] == "*" && szLine[nIdx + 1] == "/")
               {
                   break
               }
               nIdx = nIdx + 1

           }
        }
        if( (szLine[nIdx] != " ") && (szLine[nIdx] != "\t" ))
        {
            return nIdx
        }
        nIdx = nIdx + 1
    }
    if( (szLine[iLen -1] == " ") || (szLine[iLen -1] == "\t" ))
    {
        return 0xffffffff
    }
    return nIdx
}
*/
/*
macro MoveCommentLeftBlank(szLine)
{
    nIdx  = 0
    iLen = strlen(szLine)
    while(nIdx < iLen - 1)
    {
        if(szLine[nIdx] == "/" && szLine[nIdx+1] == "*")
        {
            szLine[nIdx] = " "
            szLine[nIdx + 1] = " "
            nIdx = nIdx + 2
            while(nIdx < iLen - 1)
            {
                if(szLine[nIdx] != " " && szLine[nIdx] != "\t")
                {
                    szLine[nIdx - 2] = "/"
                    szLine[nIdx - 1] = "*"
                    return szLine
                }
                nIdx = nIdx + 1
            }

        }
        if(szLine[nIdx] == "/" && szLine[nIdx+1] == "/")
        {
            szLine[nIdx] = " "
            szLine[nIdx + 1] = " "
            nIdx = nIdx + 2
            while(nIdx < iLen - 1)
            {
                if(szLine[nIdx] != " " && szLine[nIdx] != "\t")
                {
                    szLine[nIdx - 2] = "/"
                    szLine[nIdx - 1] = "/"
                    return szLine
                }
                nIdx = nIdx + 1
            }

        }
        nIdx = nIdx + 1
    }
    return szLine
}*/

/*****************************************************************************
 �� �� ��  : DelCompoundStatement
 ��������  : ɾ��һ���������
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro DelCompoundStatement()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    szLine = GetBufLine(hbuf,ln )
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
    Msg("@szLine@  will be deleted !")
    fIsEnd = 1
    while(1)
    {
        RetVal = SkipCommentFromString(szLine,fIsEnd)
        szTmp = RetVal.szContent
        fIsEnd = RetVal.fIsEnd
        //���Ҹ������Ŀ�ʼ
        ret = strstr(szTmp,"{")
        if(ret != 0xffffffff)
        {
            szNewLine = strmid(szLine,ret+1,strlen(szLine))
            szNew = strmid(szTmp,ret+1,strlen(szTmp))
            szNew = TrimString(szNew)
            if(szNew != "")
            {
                InsBufLine(hbuf,ln + 1,"@szLeft@    @szNewLine@");
            }
            sel.lnFirst = ln
            sel.lnLast = ln
            sel.ichFirst = ret
            sel.ichLim = ret
            //���Ҷ�Ӧ�Ĵ�����

            //ʹ���Լ���д�Ĵ���̫��
            retTmp = SearchCompoundEnd(hbuf,ln,ret)
            if(retTmp.iCount == 0)
            {

                DelBufLine(hbuf,retTmp.ln)
                sel.ichFirst = 0
                sel.ichLim = 0
                DelBufLine(hbuf,ln)
                sel.lnLast = retTmp.ln - 1
                SetWndSel(hwnd,sel)
                Indent_Left
            }

            //ʹ��Si�Ĵ�������Է�����V2.1ʱ��ע��Ƕ��ʱ��������
/*            SetWndSel(hwnd,sel)
            Block_Down
            selNew = GetWndSel(hwnd)
            if(selNew != sel)
            {

                DelBufLine(hbuf,selNew.lnFirst)
                sel.ichFirst = 0
                sel.ichLim = 0
                DelBufLine(hbuf,ln)
                sel.lnLast = selNew.lnFirst - 1
                SetWndSel(hwnd,sel)
                Indent_Left
            }*/
            break
        }
        szTmp = TrimString(szTmp)
        iLen = strlen(szTmp)
        if(iLen != 0)
        {
            if(szTmp[iLen-1] == ";")
            {
                break
            }
        }
        DelBufLine(hbuf,ln)
        if( ln == GetBufLineCount(hbuf ))
        {
             break
        }
        szLine = GetBufLine(hbuf,ln)
    }
}

/*****************************************************************************
 �� �� ��  : CheckBlockBrace
 ��������  : ��ⶨ����еĴ�����������
 �������  : hbuf
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CheckBlockBrace(hbuf)
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    ln = sel.lnFirst
    nCount = 0
    RetVal = ""
    szLine = GetBufLine( hbuf, ln )
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        RetVal.iCount = 0
        RetVal.ich = sel.ichFirst
        return RetVal
    }
    if(sel.lnFirst == sel.lnLast && sel.ichFirst != sel.ichLim)
    {
        RetTmp = SkipCommentFromString(szLine,fIsEnd)
        szTmp = RetTmp.szContent
        RetVal = CheckBrace(szTmp,sel.ichFirst,sel.ichLim,"{","}",0,1)
        return RetVal
    }
    if(sel.lnFirst != sel.lnLast)
    {
	    fIsEnd = 1
	    while(ln <= sel.lnLast)
	    {
	        if(ln == sel.lnFirst)
	        {
	            RetVal = CheckBrace(szLine,sel.ichFirst,strlen(szLine)-1,"{","}",nCount,fIsEnd)
	        }
	        else if(ln == sel.lnLast)
	        {
	            RetVal = CheckBrace(szLine,0,sel.ichLim,"{","}",nCount,fIsEnd)
	        }
	        else
	        {
	            RetVal = CheckBrace(szLine,0,strlen(szLine)-1,"{","}",nCount,fIsEnd)
	        }
	        fIsEnd = RetVal.fIsEnd
	        ln = ln + 1
	        nCount = RetVal.iCount
	        szLine = GetBufLine( hbuf, ln )
	    }
    }
    return RetVal
}

/*****************************************************************************
 �� �� ��  : SearchCompoundEnd
 ��������  : ����һ���������Ľ�����
 �������  : hbuf
             ln      ��ѯ��ʼ��
             ichBeg  ��ѯ��ʼ��
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro SearchCompoundEnd(hbuf,ln,ichBeg)
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    ln = sel.lnFirst
    nCount = 0
    SearchVal = ""
    szLine = GetBufLine( hbuf, ln )
    lnMax = GetBufLineCount(hbuf)
    fIsEnd = 1
    while(ln < lnMax)
    {
        RetVal = CheckBrace(szLine,ichBeg,strlen(szLine)-1,"{","}",nCount,fIsEnd)
        fIsEnd = RetVal.fIsEnd
        ichBeg = 0
        nCount = RetVal.iCount
        if(nCount == 0)
        {
            break
        }
        ln = ln + 1
        szLine = GetBufLine( hbuf, ln )
    }
    SearchVal.iCount = RetVal.iCount
    SearchVal.ich = RetVal.ich
    SearchVal.ln = ln
    return SearchVal
}

/*****************************************************************************
 �� �� ��  : CheckBrace
 ��������  : ������ŵ�������
 �������  : szLine       �����ַ���
             ichBeg       �����ʼ
             ichEnd       ������
             chBeg        ��ʼ�ַ�(������)
             chEnd        �����ַ�(������)
             nCheckCount
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro CheckBrace(szLine,ichBeg,ichEnd,chBeg,chEnd,nCheckCount,isCommentEnd)
{
    retVal = ""
    nIdx = ichBeg
    nLen = strlen(szLine)
    if(ichEnd >= nLen)
    {
        ichEnd = nLen - 1
    }
    RetVal = ""
    fIsEnd = 1
    while(nIdx <= ichEnd)
    {
        if(szLine[nIdx] == "/" && szLine[nIdx+1] == "/")
        {
            break
        }
        if( (isCommentEnd == 0) || (szLine[nIdx] == "/" && szLine[nIdx+1] == "*"))
        {
            fIsEnd = 0
            while(nIdx < nLen - 1)
            {
                if(szLine[nIdx] == "*" && szLine[nIdx+1] == "/")
                {
                    nIdx = nIdx + 1
                    fIsEnd  = 1
                    isCommentEnd = 1
                    break
                }
                nIdx = nIdx + 1
            }
        }
        if(szLine[nIdx] == chBeg)
        {
            nCheckCount = nCheckCount + 1
        }
        if(szLine[nIdx] == chEnd)
        {
            nCheckCount = nCheckCount - 1
            if(nCheckCount == 0)
            {
                retVal.ich = nIdx
            }
        }
        nIdx = nIdx + 1
    }
    retVal.iCount = nCheckCount
    retVal.fIsEnd = fIsEnd
    return retVal
}

/*****************************************************************************
 �� �� ��  : InsertElse
 ��������  : ����else���
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertElse()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
        InsBufLine(hbuf, ln,szLeft)
        SetWndSel(hwnd,sel)
    }
    val = ExpandBraceLarge()
    szLeft = val.szLeft
    InsBufLine(hbuf, ln, "@szLeft@else")
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        PutBufLine(hbuf,ln+2, "@szLeft@    ")
         SetBufIns (hbuf, ln+2, strlen(szLeft)+4)
         return
    }
       SetBufIns (hbuf, ln, strlen(szLeft)+7)
}

/*****************************************************************************
 �� �� ��  : InsertCase
 ��������  : ����case���
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertCase()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    szLine = GetBufLine( hbuf, ln )
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
    InsBufLine(hbuf, ln, "@szLeft@" # "case # :")
    InsBufLine(hbuf, ln + 1, "@szLeft@" # "    " # "#")
    InsBufLine(hbuf, ln + 2, "@szLeft@" # "    " # "break;")
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : InsertSwitch
 ��������  : ����swich���
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertSwitch()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    szLine = GetBufLine( hbuf, ln )
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);
    InsBufLine(hbuf, ln, "@szLeft@switch ( # )")
    InsBufLine(hbuf, ln + 1, "@szLeft@" # "{")
    nSwitch = ask("������case�ĸ���")
    InsertMultiCaseProc(hbuf,szLeft,nSwitch)
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : InsertMultiCaseProc
 ��������  : ������case
 �������  : hbuf
             szLeft
             nSwitch
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertMultiCaseProc(hbuf,szLeft,nSwitch)
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    ln = sel.lnFirst

    nIdx = 0
    if(nSwitch == 0)
    {
        hNewBuf = newbuf("clip")
        if(hNewBuf == hNil)
            return
        SetCurrentBuf(hNewBuf)
        PasteBufLine (hNewBuf, 0)
        nLeftMax = 0
           lnMax = GetBufLineCount(hNewBuf )
         i = 0
        while ( i < lnMax)
        {
            szLine = GetBufLine(hNewBuf , i)
//            nLeft = GetLeftBlank(szLine)
            szLine = GetSwitchVar(szLine)
            if(strlen(szLine) != 0 )
            {
                ln = ln + 3
                InsBufLine(hbuf, ln - 1, "@szLeft@    " # "case @szLine@:")
                InsBufLine(hbuf, ln    , "@szLeft@    " # "    " # "#")
                InsBufLine(hbuf, ln + 1, "@szLeft@    " # "    " # "break;")
              }
              i = i + 1
        }
        closebuf(hNewBuf)
       }
       else
       {
        while(nIdx < nSwitch)
        {
            ln = ln + 3
            InsBufLine(hbuf, ln - 1, "@szLeft@    " # "case # :")
            InsBufLine(hbuf, ln    , "@szLeft@    " # "    " # "#")
            InsBufLine(hbuf, ln + 1, "@szLeft@    " # "    " # "break;")
            nIdx = nIdx + 1
        }
      }
    InsBufLine(hbuf, ln + 2, "@szLeft@    " # "default:")
    InsBufLine(hbuf, ln + 3, "@szLeft@    " # "    " # "#")
    InsBufLine(hbuf, ln + 4, "@szLeft@" # "}")
    SetWndSel(hwnd, sel)
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : GetSwitchVar
 ��������  : ��ö�١��궨��ȡ��caseֵ
 �������  : szLine
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetSwitchVar(szLine)
{
    RetVal = SkipCommentFromString(szLine,1)
    szLine = RetVal.szContent
    ret = strstr(szLine,"#define" )
    if(ret != 0xffffffff)
    {
        szLine = strmid(szLine,ret + 8,strlen(szLine))
    }
    szLine = TrimLeft(szLine)
    nIdx = 0
    nLen = strlen(szLine)
    while( nIdx < nLen)
    {
        if((szLine[nIdx] == " ") || (szLine[nIdx] == ",") || (szLine[nIdx] == "="))
        {
            szLine = strmid(szLine,0,nIdx)
            return szLine
        }
        nIdx = nIdx + 1
    }
    return szLine
}


macro SkipControlCharFromString(szLine)
{
   nLen = strlen(szLine)
   nIdx = 0
   newStr = ""
   while(nIdx < nLen - 1)
   {
       if(szLine[nIdx] == "\t")
       {
           newStr = cat(newStr,"    ")
       }
       else if(szLine[nIdx] < " ")
       {
           newStr = cat(newStr," ")
       }
       else
       {
           newStr = cat(newStr," ")
       }
   }
}

/*****************************************************************************
 �� �� ��  : SkipCommentFromString
 ��������  : ȥ��ע�͵����ݣ���ע��������Ϊ�ո�
 �������  : szLine
             isCommentEnd
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro SkipCommentFromString(szLine,isCommentEnd)
{
    RetVal = ""
    fIsEnd = 1
    nLen = strlen(szLine)
    nIdx = 0
    while(nIdx < nLen - 1)
    {
        if(szLine[nIdx] == "/" && szLine[nIdx+1] == "/")
        {
            szLine = strmid(szLine,0,nIdx)
            break
        }
        if( (isCommentEnd == 0) || (szLine[nIdx] == "/" && szLine[nIdx+1] == "*"))
        {
            fIsEnd = 0
            while(nIdx < nLen - 1)
            {
                if(szLine[nIdx] == "*" && szLine[nIdx+1] == "/")
                {
                    szLine[nIdx+1] = " "
                    szLine[nIdx] = " "
                    nIdx = nIdx + 1
                    fIsEnd  = 1
                    isCommentEnd = 1
                    break
                }
                szLine[nIdx] = " "
                nIdx = nIdx + 1
            }
        }
        nIdx = nIdx + 1
    }
    RetVal.szContent = szLine;
    RetVal.fIsEnd = fIsEnd
    return RetVal
}

/*****************************************************************************
 �� �� ��  : InsertDo
 ��������  : ����Do���
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertDo()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
        InsBufLine(hbuf, ln,szLeft)
        SetWndSel(hwnd,sel)
    }
    val = ExpandBraceLarge()
    szLeft = val.szLeft
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        PutBufLine(hbuf,ln+1, "@szLeft@    #")
    }
    PutBufLine(hbuf, sel.lnLast + val.nLineCount, "@szLeft@}while ( # );")
//       SetBufIns (hbuf, sel.lnLast + val.nLineCount, strlen(szLeft)+8)
    InsBufLine(hbuf, ln, "@szLeft@do")
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : InsertWhile
 ��������  : ����While���
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertWhile()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
        InsBufLine(hbuf, ln,szLeft)
        SetWndSel(hwnd,sel)
    }
    val = ExpandBraceLarge()
    szLeft = val.szLeft
    InsBufLine(hbuf, ln, "@szLeft@while ( # )")
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        PutBufLine(hbuf,ln+2, "@szLeft@    #")
    }
       SetBufIns (hbuf, ln, strlen(szLeft)+7)
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : InsertFor
 ��������  : ����for���
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertFor()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
        InsBufLine(hbuf, ln,szLeft)
        SetWndSel(hwnd,sel)
    }
    val = ExpandBraceLarge()
    szLeft = val.szLeft
    InsBufLine(hbuf, ln,"@szLeft@for ( # ; # ; # )")
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        PutBufLine(hbuf,ln+2, "@szLeft@    #")
    }
    sel.lnFirst = ln
    sel.lnLast = ln
    sel.ichFirst = 0
    sel.ichLim = 0
    SetWndSel(hwnd, sel)
    SearchForward()
    szVar = ask("������ѭ������")
    PutBufLine(hbuf,ln, "@szLeft@for ( @szVar@ = # ; @szVar@ # ; @szVar@++ )")
    SearchForward()
}

/*****************************************************************************
 �� �� ��  : InsertIf
 ��������  : ����If���
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertIf()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    ln = sel.lnFirst
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
        InsBufLine(hbuf, ln,szLeft)
        SetWndSel(hwnd,sel)
    }
    val = ExpandBraceLarge()
    szLeft = val.szLeft
    InsBufLine(hbuf, ln, "@szLeft@if ( # )")
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        PutBufLine(hbuf,ln+2, "@szLeft@    #")
    }
//       SetBufIns (hbuf, ln, strlen(szLeft)+4)
    SearchForward()
}


macro MergeString()
{
    hbuf = newbuf("clip")
    if(hbuf == hNil)
        return
    SetCurrentBuf(hbuf)
    PasteBufLine (hbuf, 0)
       lnMax = GetBufLineCount(hbuf )
    lnLast =  0
    if(lnMax > 1)
     {
        lnLast = lnMax - 1
         i = lnMax - 1
       }
    while ( i > 0)
    {
        szLine = GetBufLine(hbuf , i-1)
        szLine = TrimLeft(szLine)
        nLen = strlen(szLine)
        if(szLine[nLen - 1] == "-")
        {
              szLine = strmid(szLine,0,nLen - 1)
        }
        nLen = strlen(szLine)
        if( (szLine[nLen - 1] != " ") && (AsciiFromChar (szLine[nLen - 1])  <= 160))
        {
              szLine = cat(szLine," ")
        }
        SetBufIns (hbuf, lnLast, 0)
        SetBufSelText(hbuf,szLine)
        i = i - 1
    }
    szLine = GetBufLine(hbuf,lnLast)
    closebuf(hbuf)
    return szLine
}

/*****************************************************************************
 �� �� ��  : ClearPrombleNo
 ��������  : ������ⵥ��
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro ClearPrombleNo()
{
   SetReg ("PNO", "")
}

/*****************************************************************************
 �� �� ��  : AddPromblemNo
 ��������  : ������ⵥ��
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro AddPromblemNo()
{
    szQuestion = ASK("Please Input problem number ");
    if(szQuestion == "#")
    {
       szQuestion = ""
       SetReg ("PNO", "")
    }
    else
    {
       SetReg ("PNO", szQuestion)
    }
    return szQuestion
}
macro AddLoggerName()
{
    szQuestion = ASK("Please Input your logger variable");
    if(szQuestion == "#")
    {
       szQuestion = ""
       SetReg ("MY_LOGGER_NAME", "")
    }
    else
    {
       SetReg ("MY_LOGGER_NAME", szQuestion)
    }
    return szQuestion
}

/*
this macro convet selected  C++ coment block to C comment block
for example:
  line "  // aaaaa "
  convert to  /* aaaaa */
*/
macro ComentCPPtoC()
{
    hwnd = GetCurrentWnd()
    lnFirst = GetWndSelLnFirst(hwnd)
    lnLast = GetWndSelLnLast(hwnd)

    lnCurrent = lnFirst
    while (lnCurrent <= lnLast)
    {
        CmtCvtLine(lnCurrent)
        lnCurrent = lnCurrent + 1;
    }
}

//   aaaaaaa
macro CmtCvtLine(lnCurrent)
{
    hbuf = GetCurrentBuf()
    szLine = GetBufLine(hbuf,lnCurrent)
    ch_comment = CharFromAscii(47)
    ich = 0
    ilen = strlen(szLine)

    iIsComment = 0;

    while ( ich < ilen -1 )
    {
        if(( szLine[ich]==ch_comment ) && (szLine[ich+1]==ch_comment))
        {
            nIdx = ich
            while ( nIdx < ilen -1 )
            {
                if( (( szLine[nIdx] == "/" ) && (szLine[nIdx+1] == "*")||
                     ( szLine[nIdx] == "*" ) && (szLine[nIdx+1] == "/") )
                {
                    szLine[nIdx] = " "
                    szLine[nIdx+1] = " "
                }
                nIdx = nIdx + 1
            }
            szLine[ich+1] = "*"
            szLine = cat(szLine,"  */")
            DelBufLine(hbuf,lnCurrent)
            InsBufLine(hbuf,lnCurrent,szLine)
            return 1
        }
        ich = ich + 1
    }
    return 0
}

/*****************************************************************************
 �� �� ��  : GetFileNameExt
 ��������  : �õ��ļ���չ��
 �������  : sz
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetFileNameExt(sz)
{
    i = 1
    j = 0
    szName = sz
    iLen = strlen(sz)
    if(iLen == 0)
      return ""
    while( i <= iLen)
    {
      if(sz[iLen-i] == ".")
      {
         j = iLen-i
         szExt = strmid(sz,j + 1,iLen)
         return szExt
      }
      i = i + 1
    }
    return ""
}

/*****************************************************************************
 �� �� ��  : GetFileNameNoExt
 ��������  : �õ�������û����չ��
 �������  : sz
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetFileNameNoExt(sz)
{
    i = 1
    szName = sz
    iLen = strlen(sz)
    j = iLen
    if(iLen == 0)
      return ""
    while( i <= iLen)
    {
      if(sz[iLen-i] == ".")
      {
         j = iLen-i
      }
      if( sz[iLen-i] == "\\" )
      {
         szName = strmid(sz,iLen-i+1,j)
         return szName
      }
      i = i + 1
    }
    szName = strmid(sz,0,j)
    return szName
}

/*****************************************************************************
 �� �� ��  : GetFileName
 ��������  : �õ�����չ�����ļ���
 �������  : sz
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetFileName(sz)
{
    i = 1
    szName = sz
    iLen = strlen(sz)
    if(iLen == 0)
      return ""
    while( i <= iLen)
    {
      if(sz[iLen-i] == "\\")
      {
        szName = strmid(sz,iLen-i+1,iLen)
        break
      }
      i = i + 1
    }
    return szName
}

/*****************************************************************************
 �� �� ��  : InsIfdef
 ��������  : ����#ifdef���
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsIfdef()
{
    sz = Ask("Enter #ifdef condition:")
    if (sz != "")
        IfdefStr(sz);
}

macro InsIfndef()
{
    sz = Ask("Enter #ifndef condition:")
    if (sz != "")
        IfndefStr(sz);
}

macro InsertCPP(hbuf,ln)
{
    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln, "#endif /* __cplusplus */")
    InsBufLine(hbuf, ln, "#endif")
    InsBufLine(hbuf, ln, "extern \"C\"{")
    InsBufLine(hbuf, ln, "#if __cplusplus")
    InsBufLine(hbuf, ln, "#ifdef __cplusplus")
    InsBufLine(hbuf, ln, "")

    iTotalLn = GetBufLineCount (hbuf)
    InsBufLine(hbuf, iTotalLn, "")
    InsBufLine(hbuf, iTotalLn, "#endif /* __cplusplus */")
    InsBufLine(hbuf, iTotalLn, "#endif")
    InsBufLine(hbuf, iTotalLn, "}")
    InsBufLine(hbuf, iTotalLn, "#if __cplusplus")
    InsBufLine(hbuf, iTotalLn, "#ifdef __cplusplus")
    InsBufLine(hbuf, iTotalLn, "")
}

macro ReviseCommentProc(hbuf,ln,szCmd,szMyName,szLine1)
{
    if (szCmd == "ap")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = AddPromblemNo()
        InsBufLine(hbuf, ln, "@szLine1@/* �� �� ��: @szQuestion@     �޸���:@szMyName@,   ʱ��:@sz@/@sz1@/@sz3@ ");
        szContent = Ask("�޸�ԭ��")
        szLeft = cat(szLine1,"   �޸�ԭ��: ");
        ln = CommentContent(hbuf,ln + 1,szLeft,szContent,1)
        return
    }
    else if (szCmd == "ab")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion)>0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Added by @szMyName@, @sz@/@sz1@/@sz3@   ���ⵥ��:@szQuestion@*/");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Added by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        return
    }
    else if (szCmd == "ae")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln, "@szLine1@/* END:   Added by @szMyName@, @sz@/@sz1@/@sz3@ */");
        return
    }
    else if (szCmd == "db")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
        if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Deleted by @szMyName@, @sz@/@sz1@/@sz3@   ���ⵥ��:@szQuestion@*/");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Deleted by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }

        return
    }
    else if (szCmd == "de")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln + 0)
        InsBufLine(hbuf, ln, "@szLine1@/* END: Deleted by @szMyName@, @sz@/@sz1@/@sz3@ */");
        return
    }
    else if (szCmd == "mb")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        szQuestion = GetReg ("PNO")
            if(strlen(szQuestion) > 0)
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Modified by @szMyName@, @sz@/@sz1@/@sz3@   ���ⵥ��:@szQuestion@*/");
        }
        else
        {
            InsBufLine(hbuf, ln, "@szLine1@/* BEGIN: Modified by @szMyName@, @sz@/@sz1@/@sz3@ */");
        }
        return
    }
    else if (szCmd == "me")
    {
        SysTime = GetSysTime(1)
        sz=SysTime.Year
        sz1=SysTime.month
        sz3=SysTime.day

        DelBufLine(hbuf, ln)
        InsBufLine(hbuf, ln, "@szLine1@/* END:   Modified by @szMyName@, @sz@/@sz1@/@sz3@ */");
        return
    }
}

/*****************************************************************************
 �� �� ��  : InsertReviseAdd
 ��������  : ��������޸�ע�Ͷ�
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertReviseAdd()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    SysTime = GetSysTime(1)
    sz=SysTime.Year
    sz1=SysTime.month
    sz3=SysTime.day
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
    }
    else
    {
        szLine = GetBufLine( hbuf, sel.lnFirst )
        nLeft = GetLeftBlank(szLine)
        szLeft = strmid(szLine,0,nLeft);
    }
    szQuestion = GetReg ("PNO")
    if(strlen(szQuestion)>0)
    {
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* BEGIN: Added by @szMyName@, @sz@/@sz1@/@sz3@   PN:@szQuestion@*/");
    }
    else
    {
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* BEGIN: Added by @szMyName@, @sz@/@sz1@/@sz3@ */");
    }

    if(sel.lnLast < lnMax - 1)
    {
        InsBufLine(hbuf, sel.lnLast + 2, "@szLeft@/* END:   Added by @szMyName@, @sz@/@sz1@/@sz3@ */");
    }
    else
    {
        AppendBufLine(hbuf, "@szLeft@/* END:   Added by @szMyName@, @sz@/@sz1@/@sz3@ */");
    }
    SetBufIns(hbuf,sel.lnFirst + 1,strlen(szLeft))
}

/*****************************************************************************
 �� �� ��  : InsertReviseDel
 ��������  : ����ɾ���޸�ע�Ͷ�
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertReviseDel()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    SysTime = GetSysTime(1)
    sz=SysTime.Year
    sz1=SysTime.month
    sz3=SysTime.day
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
    }
    else
    {
        szLine = GetBufLine( hbuf, sel.lnFirst )
        nLeft = GetLeftBlank(szLine)
        szLeft = strmid(szLine,0,nLeft);
    }
    szQuestion = GetReg ("PNO")
    if(strlen(szQuestion)>0)
    {
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* BEGIN: Deleted by @szMyName@, @sz@/@sz1@/@sz3@   PN:@szQuestion@*/");
    }
    else
    {
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* BEGIN: Deleted by @szMyName@, @sz@/@sz1@/@sz3@ */");
    }

    if(sel.lnLast < lnMax - 1)
    {
        InsBufLine(hbuf, sel.lnLast + 2, "@szLeft@/* END:   Deleted by @szMyName@, @sz@/@sz1@/@sz3@ */");
    }
    else
    {
        AppendBufLine(hbuf, "@szLeft@/* END:   Deleted by @szMyName@, @sz@/@sz1@/@sz3@ */");
    }
    SetBufIns(hbuf,sel.lnFirst + 1,strlen(szLeft))
}

/*****************************************************************************
 �� �� ��  : InsertReviseMod
 ��������  : �����޸�ע�Ͷ�
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro InsertReviseMod()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    SysTime = GetSysTime(1)
    sz=SysTime.Year
    sz1=SysTime.month
    sz3=SysTime.day
    if(sel.lnFirst == sel.lnLast && sel.ichFirst == sel.ichLim)
    {
        szLeft = CreateBlankString(sel.ichFirst)
    }
    else
    {
        szLine = GetBufLine( hbuf, sel.lnFirst )
        nLeft = GetLeftBlank(szLine)
        szLeft = strmid(szLine,0,nLeft);
    }
    szQuestion = GetReg ("PNO")

    /* < mod by duangan, 2008-10-09,begin */
    if(strlen(szQuestion)>0)
    {
        //InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* BEGIN: Modified by @szMyName@, @sz@/@sz1@/@sz3@   PN:@szQuestion@*/");
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* <@szQuestion@ @szMyName@ @sz@-@sz1@-@sz3@ begin */");
    }
    else
    {
        //InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* BEGIN: Modified by @szMyName@, @sz@/@sz1@/@sz3@ */");
        InsBufLine(hbuf, sel.lnFirst, "@szLeft@/* <********* @szMyName@ @sz@-@sz1@-@sz3@ begin */");
    }

    if(sel.lnLast < lnMax - 1)
    {
        //InsBufLine(hbuf, sel.lnLast + 2, "@szLeft@/* END:   Modified by @szMyName@, @sz@/@sz1@/@sz3@ */");
        InsBufLine(hbuf, sel.lnLast + 2, "@szLeft@/* @szQuestion@ @szMyName@ @sz@-@sz1@-@sz3@ end> */");
    }
    else
    {
        //AppendBufLine(hbuf, "@szLeft@/* END:   Modified by @szMyName@, @sz@/@sz1@/@sz3@ */");
        AppendBufLine(hbuf, "@szLeft@/* @szQuestion@ @szMyName@ @sz@-@sz1@-@sz3@ end> */");
    }
    /* mod by duangan, 2008-10-09,end > */
    SetBufIns(hbuf,sel.lnFirst + 1,strlen(szLeft))
}

// Wrap ifdef <sz> .. endif around the current selection
macro IfdefStr(sz)
{
    hwnd = GetCurrentWnd()
    lnFirst = GetWndSelLnFirst(hwnd)
    lnLast = GetWndSelLnLast(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    if(lnMax != 0)
    {
        szLine = GetBufLine( hbuf, lnFirst )
    }
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);

    hbuf = GetCurrentBuf()
    if(lnLast + 1 < lnMax)
    {
        InsBufLine(hbuf, lnLast+1, "@szLeft@#endif /* @sz@ */")
    }
    else if(lnLast + 1 == lnMax)
    {
        AppendBufLine(hbuf, "@szLeft@#endif /* @sz@ */")
    }
    else
    {
        AppendBufLine(hbuf, "")
        AppendBufLine(hbuf, "@szLeft@#endif /* @sz@ */")
    }
    InsBufLine(hbuf, lnFirst, "@szLeft@#ifdef @sz@")
    SetBufIns(hbuf,lnFirst + 1,strlen(szLeft))
}

macro IfndefStr(sz)
{
    hwnd = GetCurrentWnd()
    lnFirst = GetWndSelLnFirst(hwnd)
    lnLast = GetWndSelLnLast(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    if(lnMax != 0)
    {
        szLine = GetBufLine( hbuf, lnFirst )
    }
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);

    hbuf = GetCurrentBuf()
    if(lnLast + 1 < lnMax)
    {
        InsBufLine(hbuf, lnLast+1, "@szLeft@#endif /* @sz@ */")
    }
    else if(lnLast + 1 == lnMax)
    {
        AppendBufLine(hbuf, "@szLeft@#endif /* @sz@ */")
    }
    else
    {
        AppendBufLine(hbuf, "")
        AppendBufLine(hbuf, "@szLeft@#endif /* @sz@ */")
    }
    InsBufLine(hbuf, lnFirst, "@szLeft@#ifndef @sz@")
    SetBufIns(hbuf,lnFirst + 1,strlen(szLeft))
}


macro InsertPredefIf()
{
    sz = Ask("Enter #if condition:")
    PredefIfStr(sz)
}
macro PredefIfStr(sz)
{
    hwnd = GetCurrentWnd()
    lnFirst = GetWndSelLnFirst(hwnd)
    lnLast = GetWndSelLnLast(hwnd)
    hbuf = GetCurrentBuf()
    lnMax = GetBufLineCount(hbuf)
    if(lnMax != 0)
    {
        szLine = GetBufLine( hbuf, lnFirst )
    }
    nLeft = GetLeftBlank(szLine)
    szLeft = strmid(szLine,0,nLeft);

    hbuf = GetCurrentBuf()
    if(lnLast + 1 < lnMax)
    {
        InsBufLine(hbuf, lnLast+1, "@szLeft@#endif /* #if @sz@ */")
    }
    else if(lnLast + 1 == lnMax)
    {
        AppendBufLine(hbuf, "@szLeft@#endif /* #if @sz@ */")
    }
    else
    {
        AppendBufLine(hbuf, "")
        AppendBufLine(hbuf, "@szLeft@#endif /* #if @sz@ */")
    }
    InsBufLine(hbuf, lnFirst, "@szLeft@#if  @sz@")
    SetBufIns(hbuf,lnFirst + 1,strlen(szLeft))
}


macro HeadIfdefStr(sz)
{
    hwnd = GetCurrentWnd()
    lnFirst = GetWndSelLnFirst(hwnd)
    hbuf = GetCurrentBuf()
    InsBufLine(hbuf, lnFirst, "")
    InsBufLine(hbuf, lnFirst, "#define @sz@")
    InsBufLine(hbuf, lnFirst, "#ifndef @sz@")
    iTotalLn = GetBufLineCount (hbuf)
    InsBufLine(hbuf, iTotalLn, "#endif /* @sz@ */")
    InsBufLine(hbuf, iTotalLn, "")
}

macro GetSysTime(a)
{
     RunCmd ("sidate")
     SysTime=""
     SysTime.Year=getreg(Year)
     if(strlen(SysTime.Year)==0)
     {
         setreg(Year,"2002")
         setreg(Month,"05")
         setreg(Day,"02")
         SysTime.Year="2002"
         SysTime.month="05"
         SysTime.day="20"
         SysTime.Date="2002��05��20��"
     }
     else
     {
         SysTime.Month=getreg(Month)
         SysTime.Day=getreg(Day)
         SysTime.Date=getreg(Date)
/*         SysTime.Date=cat(SysTime.Year,"��")
         SysTime.Date=cat(SysTime.Date,SysTime.Month)
         SysTime.Date=cat(SysTime.Date,"��")
         SysTime.Date=cat(SysTime.Date,SysTime.Day)
         SysTime.Date=cat(SysTime.Date,"��")*/
     }
     return SysTime
 }

/*****************************************************************************
 �� �� ��  : HeaderFileCreate
 ��������  : ����ͷ�ļ�
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro HeaderFileCreate()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    hbuf = GetWndBuf(hwnd)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }

   CreateFunctionDef(hbuf,szMyName,language)
}

/*****************************************************************************
 �� �� ��  : FunctionHeaderCreate
 ��������  : ���ɺ���ͷ
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro FunctionHeaderCreate()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    sel = GetWndSel(hwnd)
    ln = sel.lnFirst
    hbuf = GetWndBuf(hwnd)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
    nVer = GetVersion()
    lnMax = GetBufLineCount(hbuf)
    if(ln != lnMax)
    {
        szNextLine = GetBufLine(hbuf,ln)
        if( (strstr(szNextLine,"(") != 0xffffffff) || (nVer != 2 ))
        {
            symbol = GetCurSymbol()
            if(strlen(symbol) != 0)
            {
                if(language == 0)
                {
                    FuncHeadCommentCN(hbuf, ln, symbol, szMyName,0)
                }
                else
                {
                    FuncHeadCommentEN(hbuf, ln, symbol, szMyName,0)
                }
                return
            }
        }
    }
    if(language == 0 )
    {
        szFuncName = Ask("�����뺯������:")
            FuncHeadCommentCN(hbuf, ln, szFuncName, szMyName, 1)
    }
    else
    {
        szFuncName = Ask("Please input function name")
           FuncHeadCommentEN(hbuf, ln, szFuncName, szMyName, 1)

    }
}

/*****************************************************************************
 �� �� ��  : GetVersion
 ��������  : �õ�Si�İ汾��
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetVersion()
{
   Record = GetProgramInfo ()
   return Record.versionMajor
}

/*****************************************************************************
 �� �� ��  : GetProgramInfo
 ��������  : ��ó�����Ϣ��V2.1����
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro GetProgramInfo ()
{
    Record = ""
    Record.versionMajor     = 2
    Record.versionMinor    = 1
    return Record
}

/*****************************************************************************
 �� �� ��  : FileHeaderCreate
 ��������  : �����ļ�ͷ
 �������  : ��
 �� �� ֵ  :
 ���ú���  :
 ��������  :

 �޸���ʷ      :
  1.��    ��   : 2002��6��19��
    ��    ��   : ¬ʤ��
    �޸�����   : �����ɺ���

*****************************************************************************/
macro FileHeaderCreate()
{
    hwnd = GetCurrentWnd()
    if (hwnd == 0)
        stop
    ln = 0
    hbuf = GetWndBuf(hwnd)
    language = getreg(LANGUAGE)
    if(language != 1)
    {
        language = 0
    }
    szMyName = getreg(MYNAME)
    if(strlen( szMyName ) == 0)
    {
        szMyName = Ask("Enter your name:")
        setreg(MYNAME, szMyName)
    }
       SetBufIns (hbuf, 0, 0)
    if(language == 0)
    {
        InsertFileHeaderCN( hbuf,ln, szMyName,"" )
    }
    else
    {
        InsertFileHeaderEN( hbuf,ln, szMyName,"" )
    }
}
macro getLoggerName(){
	loggerName=getreg(MY_LOGGER_NAME)
    if(strlen( loggerName ) == 0)
    {
        loggerName  = Ask("Enter your loggername:")
        setreg(MY_LOGGER_NAME, loggerName )
    }
    return loggerName

}
//CodeReview Macros
/* version 1.1.1 */

macro Review_Restore_Link()
{
	hbuf = GetCurrentBuf()

	sProjRoot = GetProjDir(GetCurrentProj())
	sProjRoot = Cat(sProjRoot, "\\")

	line = 0
	while(True)
	{
		sel = SearchInBuf(hbuf, "FileName : ", line, 0, 1, 0, 0)
		if(sel == "") break

		line = sel.lnFirst
		col = sel.ichLim
		str = GetBufLine(hbuf, line)
		fileName = strmid(str, col, strlen(str))
		fileName = cat(sProjRoot, fileName)

		str = GetBufLine(hbuf, line+1)
		lnNumber = strmid(str, 11, strlen(str))
		SetSourceLink(hbuf, line + 2, fileName, lnNumber - 1)
		line = line+2
	}

	//updateSummary(hbuf)
}

macro Review_Add_Comment()
{
	hbuf = GetCurrentBuf()
	curFileName = GetBufName(hbuf)
	curFunc = GetCurSymbol()
	curLineNumber = GetBufLnCur(hbuf)

	sProjRoot = GetProjDir(GetCurrentProj())
	nPos = strlen(sProjRoot)
	sFileName = strmid(curFileName, nPos+1, strlen(curFileName))
	sLocation = cat("Location : ",sFileName);
	sFileName = cat( "FileName : ", sFileName )
	sLineNumber = cat( "Line     : ", curLineNumber + 1 )
	sLocation = cat(sLocation,"/L");
	sLocation = cat(sLocation,curLineNumber + 1);

	promote = "Defect : D,d(Defect); Q,q(Query)"
	sTemp = ask(promote);
	sTemp = toupper(sTemp[0]);
	while( sTemp != "D" && sTemp != "Q")
	{
		sTemp = ask(cat("Please input again! ", promote));
		sTemp = toupper(sTemp[0]);
	}

	if( sTemp == "D" ) sTemp = "Defect";
	else if ( sTemp == "Q" ) sTemp = "Query";
	sClass = cat("Class    : ",sTemp);

	/* get the severity of the current comment */
	if(sTemp == "Defect")
	{
		promote = "Severity : G,g(General); S,s(Suggest); M,m(Major)"
		sTemp = ask(promote);
		sTemp = toupper(sTemp[0]);
		while( sTemp != "G" && sTemp != "S" && sTemp != "M" )
		{
			sTemp = ask(cat("Please input again! ", promote));
			sTemp = toupper(sTemp[0]);
		}

		if( sTemp == "G" ) sTemp = "General";
		else if ( sTemp == "S" ) sTemp = "Suggest";
		else if ( sTemp == "M" ) sTemp = "Major";
		sSeverity = cat( "Severity : ", sTemp );
		// end of get the severity of the current comment

		/* get Categories */
		promote = "Categories : S,s(SRS); H,h(HLD); L,l(LLD); C,c(Code)"
		sTemp = ask(promote);
		sTemp = toupper(sTemp[0]);
		while( sTemp != "S" && sTemp != "H" && sTemp != "L"
			&& sTemp != "T" && sTemp != "C" && sTemp != "U")
		{
			sTemp = ask(cat("Please input again! ", promote));
			sTemp = toupper(sTemp[0]);
		}

		if( sTemp == "S" ) sTemp = "SRS";
		else if ( sTemp == "H" ) sTemp = "HLD";
		else if ( sTemp == "L" ) sTemp = "LLD";
		else if ( sTemp == "C" ) sTemp = "Code";
		sCategories = cat( "Categories : ", sTemp );
		//end of get categores

		/* get defect type */
		promote = "Categories : I,i(Interface); F,f(Function); B,b(Build/Package/Merge); A,a(Assignment); D,d(Documentation); C,c(Checking); L,l(Algorithm); T,t(Timing/Serialization); O,o(Others)"
		sTemp = ask(promote);
		sTemp = toupper(sTemp[0]);
		while( sTemp != "I" && sTemp != "F" && sTemp != "B"
			&& sTemp != "A" && sTemp != "D" && sTemp != "C"
			&& sTemp != "L" && sTemp != "T" && sTemp != "O")
		{
			sTemp = ask(cat("Please input again! ", promote));
			sTemp = toupper(sTemp[0]);
		}

		if( sTemp == "I" ) sTemp = "Interface";
		else if ( sTemp == "F" ) sTemp = "Function";
		else if ( sTemp == "B" ) sTemp = "Build/Package";
		else if ( sTemp == "A" ) sTemp = "Assignment";
		else if ( sTemp == "D" ) sTemp = "Documentation";
		else if ( sTemp == "C" ) sTemp = "Checking";
		else if ( sTemp == "L" ) sTemp = "aLgorithm";
		else if ( sTemp == "T" ) sTemp = "Timing/Serialization";
		else if ( sTemp == "O" ) sTemp = "Others";
		sDefectType = cat( "DefectType : ", sTemp );
		/* end of get defect type */
	}
	else
	{
		sTemp = " ";
		sSeverity = cat( "Severity : ", sTemp );
		sCategories = cat( "Categories : ", sTemp );
		sDefectType = cat( "DefectType : ", sTemp );
	}

	/* get the comment */
	promote = "Input your comment:"
	sTemp = ask(promote);
	sComments = cat( "Comments : ", sTemp );

	/* get the licence user name for the reviewer name */
	progRecord = GetProgramEnvironmentInfo()
	directory=progRecord.ProgramDir


	sMyName = progRecord.UserName

	/* get the ReviewComment buffer handle */
	bNewCreated = false; // used for the review comment is firstly created
//	hout = GetBufHandle("ReviewComment.txt")
    fileName=cat(getUserName(),"Comments");
    fileName=cat(fileName,"-");
    fileName=cat(fileName,getReviewType());
    fileName=cat(fileName,".txt");
    //	msg("the values are :@fileName@");
    project=GetCurrentProj ();
    newFileName=cat(progRecord.ConfigurationFile,"\\..\\..\\..\\..\\..\\data\\comments");
    value=Ask("Enter y to save in @newFileName@");
    if(value=="y")
      value=newFileName;
		hout =GetBufHandle(value);
     /*
	if(value=="n")

	else
	*/
//		hout=OpenBuf ("d:\\t.txt");
//		SaveBufAs(hout, "d:\\t.txt")
		/*
	if(value!="n")

		*/
	if (hout == hNil)
	{
		// No existing Review Comment buffer
		//hout= OpenBuf ("ReviewComment.txt")
		hout= OpenBuf (fileName)
		if( hout == hNil )
		{
			/* No existing ReviewComment.txt, then create a new review comment buffer */
			//hout = NewBuf("ReviewComment.txt")
			hout = NewBuf(fileName)
			NewWnd(hout)
			bNewCreated = true

			/*----------------------------------------------------------------*/
			/* Get the owner's name from the environment variable: MYNAME.    */
			/* If the variable doesn't exist, then the owner field is skipped.*/
			/*----------------------------------------------------------------*/
			AppendBufLine(hout, cat("Reviewer Name : ", getUserName()))

			AppendBufLine(hout, "-------------------------------------------------------------------------")
		}
	} // end of get ReviewComment buffer handle

	delConver123(hout)
	delSummary(hout)
	AppendBufLine(hout, "")
	sSystime = GetSysTime(0)
   AppendBufLine(hout, cat("Date: ",sSystime.date)

	AppendBufLine(hout, sFileName)
	AppendBufLine(hout, sLineNumber)
	AppendBufLine(hout, sLocation)
		AppendBufLine(hout, cat("Reviewer : ", sMyName))
	AppendBufLine(hout, cat("Symbol   : ", curFunc) )
	AppendBufLine(hout, sCategories)
	AppendBufLine(hout, sClass)
	AppendBufLine(hout, sSeverity)
	AppendBufLine(hout, sDefectType)
	AppendBufLine(hout, "Status   : Open")
	AppendBufLine(hout, sComments)
	AppendBufLine(hout, "Author : ")
	AppendBufLine(hout, "Author Rmks\t: ")
	AppendBufLine(hout, "Resolve : ")
	lnSource = GetBufLineCount(hout) - 13
	SetSourceLink(hout, lnSource, curFileName, curLineNumber)
	//updateSummary(hout)
	if( bNewCreated ) SetCurrentBuf(hbuf)
	jump_to_link;
}

macro Review_Summary()
{
	hbuf = GetCurrentBuf()
	updateSummary(hbuf)
}

macro Review_Output_Excel()
{
	sSign123 = "--------------------------Converted to Excel CSV format-----------------------------------"
	//rvTitle = "it1=\"FileName :\";it2=\"������Ա\t\";it3=\"����\t\";it4=\"λ��\t\";it5=\"��������\t\";it6=\"���ؼ���\t\";it7=\"ȱ����Դ\t\";it8=\"ȱ������\t\";it9=\"�����޸�˵��\t\";it10=\"״̬\t\""
	//rvObj = "it1=\"FileName :\";it2=\"Reviewer :\";it3=\"Comments :\";it4=\"Location :\";it5=\"Class    :\";it6=\"Severity :\";it7=\"Categories :\";it8=\"DefectType :\";it9=\"Resolve :\";it10=\"Status   :\""*/
	rvTitle = "it1=\"FileName ,\";it2=\"Reviewer ,\";it3=\"Comments,\";it4=\"Location ,\";it5=\"Class    ,\";it6=\"Severity ,\";it7=\"Categories ,\";it8=\"DefectType ,\";it9=\"Resolve ,\";it10=\"Status \""
	hbuf = GetCurrentBuf()

	delConver123(hbuf)

	AppendBufLine(hbuf, "")
	AppendBufLine(hbuf, "")

	AppendBufLine(hbuf, sSign123)
	AppendBufLine(hbuf, "-------------------------------------------------------------------------------------------------")
	sOutput = cat(rvTitle.it2,rvTitle.it3)
	sOutput = cat(sOutput,rvTitle.it4)
	sOutput = cat(sOutput,rvTitle.it5)
	sOutput = cat(sOutput,rvTitle.it6)
	sOutput = cat(sOutput,rvTitle.it7)
	sOutput = cat(sOutput,rvTitle.it8)
	sOutput = cat(sOutput,rvTitle.it9)
	sOutput = cat(sOutput,rvTitle.it10)
	AppendBufLine(hbuf, sOutput)
	//AppendBufLine(hbuf, "-------------------------------------------------------------------------------------------------")
	AppendBufLine(hbuf, "")
	ln = 0
	while (True)
	{
		sOutput = ""
		sel = SearchInBuf(hbuf, "^FileName\\s+:\\s+", ln, 0, 1, 1, 0)
		if (sel == null) break

		ln = sel.lnFirst
		col = sel.ichLim

		tpsel = SearchInBuf(hbuf, "^Reviewer\\s+:\\s+", ln, 0, 1, 1, 0)
		if(tpsel)
		{
			tpln = tpsel.lnFirst
			tpcol = tpsel.ichLim
			sContent = GetBufLine(hbuf, tpln)
			if(tpcol < strlen(tpsel))
				sOutput = cat(sOutput,strmid(sContent, tpcol, strlen(sContent)))
			sOutput = cat(sOutput,",")
		}

		tpsel = SearchInBuf(hbuf, "^Comments\\s+:\\s+", ln, 0, 1, 1, 0)
		if(tpsel)
		{
			tpln = tpsel.lnFirst
			tpcol = tpsel.ichLim
			sContent = GetBufLine(hbuf, tpln)
			if(tpcol < strlen(tpsel))
				sOutput = cat(sOutput,strmid(sContent, tpcol, strlen(sContent)))
			sOutput = cat(sOutput,",")
		}

		tpsel = SearchInBuf(hbuf, "^Location\\s+:\\s+", ln, 0, 1, 1, 0)
		if(tpsel)
		{
			tpln = tpsel.lnFirst
			tpcol = tpsel.ichLim
			sContent = GetBufLine(hbuf, tpln)
			if(tpcol < strlen(tpsel))
				sOutput = cat(sOutput,strmid(sContent, tpcol, strlen(sContent)))
			sOutput = cat(sOutput,",")
		}

		tpsel = SearchInBuf(hbuf, "^Class\\s+:\\s+", ln, 0, 1, 1, 0)
		if(tpsel)
		{
			tpln = tpsel.lnFirst
			tpcol = tpsel.ichLim
			sContent = GetBufLine(hbuf, tpln)
			if(tpcol < strlen(tpsel))
				sOutput = cat(sOutput,strmid(sContent, tpcol, strlen(sContent)))
			sOutput = cat(sOutput,",")
		}

		tpsel = SearchInBuf(hbuf, "^Severity\\s+:\\s+", ln, 0, 1, 1, 0)
		if(tpsel)
		{
			tpln = tpsel.lnFirst
			tpcol = tpsel.ichLim
			sContent = GetBufLine(hbuf, tpln)
			if(tpcol < strlen(tpsel))
				sOutput = cat(sOutput,strmid(sContent, tpcol, strlen(sContent)))
			sOutput = cat(sOutput,",")
		}

		tpsel = SearchInBuf(hbuf, "^Categories\\s+:\\s+", ln, 0, 1, 1, 0)
		if(tpsel)
		{
			tpln = tpsel.lnFirst
			tpcol = tpsel.ichLim
			sContent = GetBufLine(hbuf, tpln)
			if(tpcol < strlen(tpsel))
				sOutput = cat(sOutput,strmid(sContent, tpcol, strlen(sContent)))
			sOutput = cat(sOutput,",")
		}

		tpsel = SearchInBuf(hbuf, "^DefectType\\s+:\\s+", ln, 0, 1, 1, 0)
		if(tpsel)
		{
			tpln = tpsel.lnFirst
			tpcol = tpsel.ichLim
			sContent = GetBufLine(hbuf, tpln)
			if(tpcol < strlen(tpsel))
				sOutput = cat(sOutput,strmid(sContent, tpcol, strlen(sContent)))
			sOutput = cat(sOutput,",")
		}

		tpsel = SearchInBuf(hbuf, "^Resolve\\s+:\\s+", ln, 0, 1, 1, 0)
		if(tpsel)
		{
			tpln = tpsel.lnFirst
			tpcol = tpsel.ichLim
			sContent = GetBufLine(hbuf, tpln)
			if(tpcol < strlen(tpsel))
				sOutput = cat(sOutput,strmid(sContent, tpcol, strlen(sContent)))
			sOutput = cat(sOutput,",")
		}

		tpsel = SearchInBuf(hbuf, "^Status\\s+:\\s+", ln, 0, 1, 1, 0)
		if(tpsel)
		{
			tpln = tpsel.lnFirst
			tpcol = tpsel.ichLim
			sContent = GetBufLine(hbuf, tpln)
			if(tpcol < strlen(tpsel))
				sOutput = cat(sOutput,strmid(sContent, tpcol, strlen(sContent)))
			sOutput = cat(sOutput," ")
		}

		AppendBufLine(hbuf, sOutput)
		AppendBufLine(hbuf, "")
		tpsel = SearchInBuf(hbuf, "^Author\\s+:\\s+", ln, 0, 1, 1, 0)
		if(tpsel)
			tpln = tpsel.lnFirst
		else
			tpln = ln + 9

		ln = tpln + 1
	}
	AppendBufLine(hbuf, "-------------------------------------------------------------------------------------------------")
}

macro updateSummary(hbuf)
{
	rvSum0 = getReviewSummary(hbuf)
	rvSum = "general=\"0\";suggest=\"0\";major=\"0\";query=\"0\";open=\"0\";closed=\"0\";rejected=\"0\";SysReq=\"0\";SDes=\"0\";SRS=\"0\";HLD=\"0\";LLD=\"0\";Code=\"0\";Others=\"0\";In=\"0\";Fu=\"0\";Bu=\"0\";Ass=\"0\";Do=\"0\";Ch=\"0\";Al=\"0\";Ti=\"0\";Oth=\"0\""

    /* summary the severity */
	ln = 0
	while (True)
	{
		sel = SearchInBuf(hbuf, "^Severity\\s+:\\s+", ln, 0, 1, 1, 0)
		if (sel == null) break

		ln = sel.lnFirst
		col = sel.ichLim
		s = GetBufLine(hbuf, ln)
		if((col + 1) > strlen(s))
		{
			rvSum.query = rvSum.query + 1
			ln = ln + 1;
			continue;
		}
		sTemp = strmid(s, col, col+1)
		sTemp = toupper(sTEmp);

		if (sTemp == "G" && norejected(hbuf, ln))
			rvSum.general = rvSum.general + 1
		else if (sTemp == "S" && norejected(hbuf, ln))
			rvSum.suggest = rvSum.suggest + 1
		else if (sTemp == "M" && norejected(hbuf, ln))
			rvSum.major = rvSum.major + 1

		ln = ln + 1
	}

	/* summary the satus */
	ln = 0
	while (True)
	{
		sel = SearchInBuf(hbuf, "^Status\\s+:\\s+", ln, 0, 1, 1, 0)
		if (sel == null) break

		ln = sel.lnFirst
		col = sel.ichLim
		s = GetBufLine(hbuf, ln)
		sTemp = strmid(s, col, col+1)
		sTemp = toupper(sTEmp);

		if (sTemp == "O") rvSum.open = rvSum.open + 1
		else if (sTemp == "C")	rvSum.closed = rvSum.closed + 1
		else if (sTemp == "R")	rvSum.rejected = rvSum.rejected + 1

		ln = ln + 1
	}

	/* summary the categories */
	ln = 0
	while (True)
	{
		norej = norejected(hbuf, ln);
		sel = SearchInBuf(hbuf, "^Categories\\s+:\\s+", ln, 0, 1, 1, 0)
		if (sel == null) break

		ln = sel.lnFirst
		col = sel.ichLim
		s = GetBufLine(hbuf, ln)
		if ( (col+2 > strlen(s)) && IsDefect(hbuf, ln))
		{
			msg("Please write categories!")
			return
		}
		if((col + 2) > strlen(s))
			sTemp = "OT"
		else
			sTemp = strmid(s, col, col+2)
		sTemp = toupper(sTEmp);

		if (sTemp == "SY" && norej) rvSum.SysReq = rvSum.SysReq + 1
		else if (sTemp == "SD" && norej)	rvSum.SDes = rvSum.SDes + 1
		else if (sTemp == "SR" && norej)	rvSum.SRS = rvSum.SRS + 1
		else if (sTemp == "HL" && norej)	rvSum.HLD = rvSum.HLD + 1
		else if (sTemp == "LL" && norej)	rvSum.LLD = rvSum.LLD + 1
		else if (sTemp == "CO" && norej)	rvSum.Code = rvSum.Code + 1
		else if (sTemp == "OT" && norej)	rvSum.Others = rvSum.Others + 1

		ln = ln + 1
	}
/* summary the type */
	ln = 0
	while (True)
	{
		norej = norejected(hbuf, ln);
		sel = SearchInBuf(hbuf, "^DefectType\\s+:\\s+", ln, 0, 1, 1, 0)
		if (sel == null) break

		ln = sel.lnFirst
		col = sel.ichLim
		s = GetBufLine(hbuf, ln)
		temp = IsDefect(hbuf, ln);
		if ( (col+2 > strlen(s)) && temp != 1)
		{
			msg("Please write DefectType!")
			return
		}
		if((col + 2) > strlen(s))
			sTemp = "OT"
		else
			sTemp = strmid(s, col, col+2)
		sTemp = toupper(sTEmp);

		if (sTemp == "IN" && norej) rvSum.In = rvSum.In + 1
		else if (sTemp == "FU" && norej)	rvSum.Fu = rvSum.Fu + 1
		else if (sTemp == "BU" && norej)	rvSum.Bu = rvSum.Bu + 1
		else if (sTemp == "AS" && norej)	rvSum.Ass = rvSum.Ass + 1
		else if (sTemp == "DO" && norej)	rvSum.Do = rvSum.Do + 1
		else if (sTemp == "CH" && norej)	rvSum.Ch = rvSum.Ch + 1
		else if (sTemp == "AL" && norej)	rvSum.Al = rvSum.Al + 1
		else if (sTemp == "TI" && norej)	rvSum.Ti = rvSum.Ti + 1
		else if (sTemp == "OT" && norej)	rvSum.Oth= rvSum.Oth + 1

		ln = ln + 1
	}

	if ( rvSum.general == rvSum0.general && rvSum.suggest == rvSum0.suggest && rvSum.major == rvSum0.major &&
		  rvSum.query == rvSum0.query && rvSum.open == rvSum0.open &&
		  rvSum.closed == rvSum0.closed && rvSum.rejected == rvSum0.rejected  &&
		  rvSum.SysReq == rvSum0.SysReq && rvSum.SDes == rvSum0.SDes &&
		  rvSum.SRS == rvSum0.SRS && rvSum.HLD == rvSum0.HLD &&
		  rvSum.LLD == rvSum0.LLD &&
		  rvSum.Code == rvSum0.Code &&
		  rvSum.Others == rvSum0.Others )
		return
	else
	{
		delSummary(hbuf)
		setReviewSummary(hbuf, rvSum)
	}
}

macro getReviewSummary(hbuf)
{
	sel = SearchInBuf(hbuf, "^Summary$", 0, 0, 1, 1, 0)
	rvSum = "general=\"0\";suggest=\"0\";major=\"0\";query=\"0\";open=\"0\";closed=\"0\";rejected=\"0\";SysReq=\"0\";SDes=\"0\";SRS=\"0\";HLD=\"0\";LLD=\"0\";Code=\"0\";Others=\"0\";In=\"0\";Fu=\"0\";Bu=\"0\";Ass=\"0\";Do=\"0\";Ch=\"0\";Al=\"0\";Ti=\"0\";Oth=\"0\""

	if (sel == null)
		return rvSum

	/* get severity summary */
	ln = sel.lnFirst + 2
	sel = SearchInBuf(hbuf, "^General\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.general = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^Suggest\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.suggest = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^Major\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.major = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^Query\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.query = strmid(sLine, col, strlen(sLine))

	/* get status summary */
	sel = SearchInBuf(hbuf, "^Open\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.open = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^Closed\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.closed = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^Rejected\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.rejected = strmid(sLine, col, strlen(sLine))

	/* get categories summary */
	sel = SearchInBuf(hbuf, "^SysReq\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.SysReq = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^SDes\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.SDes = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^SRS\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.SRS = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^HLD\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.HLD = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^LLD\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.LLD = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^Code\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.Code = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^Others\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.Others = strmid(sLine, col, strlen(sLine))


    /* get type summary */
	ln = sel.lnFirst + 2
	sel = SearchInBuf(hbuf, "^Interface\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.In = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^Functions\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.Fu = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^Build\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.Bu = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^Assignment\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.Ass = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^Documentation\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.Do = strmid(sLine, col, strlen(sLine))

	sel = SearchInBuf(hbuf, "^Checking\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.Ch = strmid(sLine, col, strlen(sLine))

    sel = SearchInBuf(hbuf, "^Algorithm\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.Al = strmid(sLine, col, strlen(sLine))

    sel = SearchInBuf(hbuf, "^Timing/Serialization\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.Ti = strmid(sLine, col, strlen(sLine))

    sel = SearchInBuf(hbuf, "^Others\\s+=\\s+", ln, 0, 1, 1, 0)
	col = sel.ichLim
	sLine = GetBufLine(hbuf, sel.lnFirst)
	rvSum.Oth = strmid(sLine, col, strlen(sLine))

	return rvSum
}

macro setReviewSummary(hbuf, rvSum)
{
	AppendBufLine(hbuf, "")
	AppendBufLine(hbuf, "Summary")
	AppendBufLine(hbuf, "-------------------------------------------------------------------------")

	/* Defects sumary */
	AppendBufLine(hbuf, "[Defects sumary]:")
	s = Cat("Total defects = ", rvSum.general + rvSum.suggest + rvSum.major + rvSum.query)
	AppendBufLine(hbuf, s)
	s = Cat("General = ", rvSum.general)
	AppendBufLine(hbuf, s)
	s = Cat("Suggest = ", rvSum.suggest)
	AppendBufLine(hbuf, s)
	s = Cat("Major = ", rvSum.major)
	AppendBufLine(hbuf, s)
	s = Cat("Query = ", rvSum.query)
	AppendBufLine(hbuf, s)

	/* Status sumary */
	AppendBufLine(hbuf, "")
	AppendBufLine(hbuf, "[Status sumary]:")
	s = Cat("Open = ", rvSum.open)
	AppendBufLine(hbuf, s)
	s = Cat("Closed = ", rvSum.closed)
	AppendBufLine(hbuf, s)
	s = " ";
	AppendBufLine(hbuf, s)
	s = Cat("Rejected = ", rvSum.rejected)
	AppendBufLine(hbuf, s)

	/* Categories summary */
	AppendBufLine(hbuf, "")
	AppendBufLine(hbuf, "[Defects categories]:")
	s = Cat("Total defects = ", rvSum.SysReq + rvSum.SDes + rvSum.SRS + rvSum.HLD + rvSum.LLD + rvSum.Code + rvSum.Others)
	AppendBufLine(hbuf, s)
	s = Cat("SysReq = ", rvSum.SysReq)
	AppendBufLine(hbuf, s)
	s = Cat("SDes = ", rvSum.SDes)
	AppendBufLine(hbuf, s)
	s = Cat("SRS = ", rvSum.SRS)
	AppendBufLine(hbuf, s)
	s = Cat("HLD = ", rvSum.HLD)
	AppendBufLine(hbuf, s)
	s = Cat("LLD = ", rvSum.LLD)
	AppendBufLine(hbuf, s)
	s = Cat("Code = ", rvSum.Code)
	AppendBufLine(hbuf, s)
	s = Cat("Others = ", rvSum.Others)
	AppendBufLine(hbuf, s)
	/* Type summary */
	AppendBufLine(hbuf, "")
	AppendBufLine(hbuf, "[Defects Type]:")
	s = Cat("Total defects = ",   rvSum.In + rvSum.Fu + rvSum.Bu + rvSum.Ass + rvSum.Do  + rvSum.Ch + rvSum.Al + rvSum.Ti + rvSum.Oth  )
	AppendBufLine(hbuf, s)
	s = Cat("Interface = ", rvSum.In)
	AppendBufLine(hbuf, s)
	s = Cat("Functions = ", rvSum.Fu)
	AppendBufLine(hbuf, s)
	s = Cat("Build/Package/Merge = ", rvSum.Bu)
	AppendBufLine(hbuf, s)
	s = Cat("Assignment = ", rvSum.Ass)
	AppendBufLine(hbuf, s)
	s = Cat("Documentation = ", rvSum.Do)
	AppendBufLine(hbuf, s)
	s = Cat("Checking = ", rvSum.Ch)
	AppendBufLine(hbuf, s)
	s = Cat("Algorithm = ", rvSum.Al)
	AppendBufLine(hbuf, s)
	s = Cat("Timing/Serialization = ", rvSum.Ti)
	AppendBufLine(hbuf, s)
	s = Cat("Others = ", rvSum.Oth)
	AppendBufLine(hbuf, s)

}

macro delSummary(hbuf)
{
	sSign123 = "-----------------------Convert to lotus123 format-----------------------------------"

	sel = SearchInBuf(hbuf, "^Summary$", 0, 0, 1, 1, 0)
	tpsel = SearchInBuf(hbuf, sSign123, 0, 0, 1, 1, 0)
	if(tpsel == null)
		tpln = 0
	else
		tpln = tpsel.lnFirst

	if (sel == null)
		return
	else
	{
		ln = sel.lnFirst
		LineCount = GetBufLineCount(hbuf) - 1

		if(tpln > ln)
			LineCount = tpln - 1

		while(LineCount >= ln)
		{
            DelBufLine(hbuf, LineCount)
            LineCount = LineCount -1;
        }
    }
}

macro delConver123(hbuf)
{
	sSign123 = "-----------------------Convert to lotus123 format-----------------------------------"

	tpsel = SearchInBuf(hbuf, "^Summary$", 0, 0, 1, 1, 0)
	sel = SearchInBuf(hbuf, sSign123, 0, 0, 1, 1, 0)
	if(tpsel == null)
		tpln = 0
	else
		tpln = tpsel.lnFirst

	if (sel == null)
		return
	else
	{
		ln = sel.lnFirst
		LineCount = GetBufLineCount(hbuf) - 1

		if(tpln > ln)
			LineCount = tpln - 1

		while(LineCount >= (ln - 2))
		{
            DelBufLine(hbuf, LineCount)
            LineCount = LineCount -1;
        }
    }
}

macro norejected(hbuf, ln)
{
	sel = SearchInBuf(hbuf, "^Status\\s+:\\s+", ln, 0, 1, 1, 0)
	if (sel == null) return True;

	ln = sel.lnFirst
	col = sel.ichLim
	s = GetBufLine(hbuf, ln)
	sTemp = strmid(s, col, col+1)
	sTemp = toupper(sTEmp);

	if (sTemp == "R") return  False;

	return True;
}

macro IsDefect(hbuf, ln)
{
	sel = SearchInBuf(hbuf, "^Class\\s+:\\s+", ln, 0, 1, 1, 0)
	if (sel == null) return True;

	ln = sel.lnFirst
	col = sel.ichLim
	s = GetBufLine(hbuf, ln)
	sTemp = strmid(s, col, col+1)
	sTemp = toupper(sTEmp);
	ret = True;
/*	if (sTemp == "Q") return  False;

	return True;*/
	if (sTemp == "Q") ret = False;
	return ret;

}
macro RunPClintOnFile()
{
  programInfo=GetProgramEnvironmentInfo ();
  configurationFile=programInfo.ConfigurationFile


  msg("the project directy @insightDir@");

}


