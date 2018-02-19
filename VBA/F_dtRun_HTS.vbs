Option Explicit

    Public compl_fldr As String
    Public colIND
    Dim colIND_start
    Dim colIND_end
    Public distroTable As ListObject
    Public distroWkbk As Workbook
    Public dtWkbk As Workbook
    Public FirstRow
    Public fname_dp As String
    Public IND
    Public INDnames
    Public LastColumn As Integer
    Public LastColumnMech As Integer
    Public LastRow
    Public LastRowMech
    Public mechlistWkbk As Workbook
    Public OpUnit As Object
    Public OpUnit_ns As String
    Public theme_fldr As String
    Public OUcompl_fldr As String
    Public OUpath As String
    Public path As String
    Public psnulistWkbk As Workbook
    Public pulls_fldr As String
    Public rng As Integer
    Public SelectedOpUnits
    Public sht As Variant
    Public shtCount As Integer
    Public shtNames As Variant
    Public tmplWkbk As Workbook
    Public tblName
    Public view As String




Sub loadform()
    'prompt for form to load to choose OUs to run
    frmRunSel.Show

End Sub


Sub PopulateSiteDisaggTool()
    'turn off screen updating
        Application.ScreenUpdating = False
        Debug.Print Application.ScreenUpdating
    'establish OUs on ref sheet
        Sheets("POPref").Activate
        rng = Sheets("POPref").Range("D5").Value + 1
        Set SelectedOpUnits = Sheets("POPref").Range(Cells(2, 6), Cells(rng, 6))
    'setup folders
        Call fldrSetup
    'define template workbook
        Set tmplWkbk = ActiveWorkbook
    ' whether to view or just store change forms
        view = Sheets("POPref").Range("D11")
    'open and name all data files
        Application.DisplayAlerts = False
        Workbooks.OpenText Filename:=pulls_fldr & "Global_DT_DisaggDistro_HTS.csv"
        Set distroWkbk = ActiveWorkbook
        Workbooks.OpenText Filename:=pulls_fldr & "Global_DT_MechList.csv"
        Set mechlistWkbk = ActiveWorkbook

        Application.DisplayAlerts = True
        tmplWkbk.Activate


    For Each OpUnit In SelectedOpUnits

        'remove space and comma for file saving (ns = no space)
        OpUnit_ns = Replace(Replace(OpUnit, " ", ""), "'", "")
        'create OU specific folder
        OUpath = compl_fldr & OpUnit_ns & VBA.Format(Now, "yyyy.mm.dd")
        If Len(Dir(OUpath, vbDirectory)) = 0 Then MkDir OUpath
        OUcompl_fldr = OUpath & "\"

        'run through all subs
        Call Initialize
        Call getData
        Call distroFormulas
        Call indDistro
        Call saveFile

        'Zip output folder
        If tmplWkbk.Sheets("POPref").Range("D14").Value = "Yes" Then
            Call Zip_All_Files_in_Folder
        End If

    Next

    'close data files
        distroWkbk.Close
        mechlistWkbk.Close


End Sub

Sub fldrSetup()
    'for saving/opening:
        'set path
            If Sheets("POPref").Range("D17").Value = 0 Then
                'browse to folder
                    MsgBox "Browse to the DataPack folder.", vbInformation, "Find DataPack"
                    With Application.FileDialog(msoFileDialogFolderPicker)
                        .AllowMultiSelect = False
                        .Show
                        On Error Resume Next
                        path = .SelectedItems(1) & "\"
                        Err.Clear
                        On Error GoTo 0
                    End With
                'if no folder select, end sub
                    If Len(path) = 0 Then End
                'ask user if file location is correct; end if not
                    If MsgBox(path & vbCr & "Is this the location?", vbYesNo) = vbNo Then End
                'add path
                    Sheets("POPref").Range("D17").Value = path
            Else
                path = Sheets("POPref").Range("D17").Value
            End If
        ' set folder directory
            pulls_fldr = path & "Output\"
            compl_fldr = path & "CompletedDataPacks\"
            theme_fldr = path & "Theme\"
        'set directory initially to the pulls folder
            ChDir (path)
End Sub

Sub Initialize()
    'snu & site level for OU
        tmplWkbk.Sheets("POPref").Activate
    'create datapack file for OU (copy sheets over to new book one at a time)
        tmplWkbk.Activate
        Sheets("Home").Copy
        Set dtWkbk = ActiveWorkbook
        shtNames = Array("Allocation by SNUxIM", "IndexMod", "MobileMod", _
                         "VCTMod", "OtherMod", "Index", "STI", _
                         "Inpat", "Emergency", "VCT", "VMMC", _
                         "TBClinic", "PMTCTANC", "PediatricServices", _
                         "Malnutrition", "OtherPITC", "KeyPop")
         shtCount = 1
         For Each sht In shtNames
            tmplWkbk.Activate
            Sheets(sht).Copy After:=dtWkbk.Sheets(shtCount)
            shtCount = shtCount + 1
         Next sht
    'add the data pack theme
        dtWkbk.Activate
        ActiveWorkbook.Theme.ThemeColorScheme.Load (theme_fldr & "Adjacency.xml")
    'hard code update date into home tab & insert OU name
        Sheets("Home").Activate
        Sheets("Home").Range("N1").Select
        Range("N1").Copy
        Selection.PasteSpecial Paste:=xlPasteValues
        Range("O1").Value = OpUnit
        Range("O4").Select
        Range("O4").Copy
        Selection.PasteSpecial Paste:=xlPasteValues
        Range("AA1").Select

End Sub

Sub getData()

    'make sure file with data is activate
        distroWkbk.Activate
    'find the last column & row
        LastColumn = Range("A1").CurrentRegion.Columns.count
    'find first and last row of OU
        FirstRow = Range("A:A").Find(what:=OpUnit, After:=Range("A1")).Row
        LastRow = Range("A:A").Find(what:=OpUnit, After:=Range("A1"), searchdirection:=xlPrevious).Row
    'copy over headers & paste in Data Pack
        Range(Cells(1, 2), Cells(1, LastColumn)).Select
        Selection.Copy
        dtWkbk.Activate
        Sheets.Add After:=Sheets(Sheets.count)
        ActiveSheet.Name = "HistoricDistro"
        Range("A1").Select
        Selection.PasteSpecial Paste:=xlPasteValues
        Application.CutCopyMode = False
    'select OU data from global file to copy to data pack
        distroWkbk.Activate
        Range(Cells(FirstRow, 2), Cells(LastRow, LastColumn)).Select
    'copy the data and paste in the data pack
        Selection.Copy
        dtWkbk.Activate
        Sheets("HistoricDistro").Activate
        Range("A2").Select
        Selection.PasteSpecial Paste:=xlPasteValues
        Application.CutCopyMode = False
    'convert into a table
        LastRow = Range("A1").CurrentRegion.Rows.count
        Range(Cells(1, 1), Cells(LastRow, LastColumn)).Select
        Set distroTable = ActiveSheet.ListObjects.Add(xlSrcRange, Selection, , xlYes)
        Range("A1").Select
    'rename table
        With ActiveSheet
            .ListObjects(1).Name = "distro"
        End With

End Sub



Sub distroFormulas()

    'add in allocation & target lookup formulas to the first line of every tab (allocation distro has to occur after distro table is created)
        shtNames = Array("IndexMod", "MobileMod", _
                         "VCTMod", "OtherMod", "Index", "STI", _
                         "Inpat", "Emergency", "VCT", "VMMC", _
                         "TBClinic", "PMTCTANC", "PediatricServices", _
                         "Malnutrition", "OtherPITC", "KeyPop")
        For Each sht In shtNames
            Sheets(sht).Activate
            'allocation formula
            If sht <> "Emergency" And sht <> "STI" And sht <> "PediatricServices" And sht <> "Malnutrition" Then
                colIND_start = WorksheetFunction.Match("ALLOCATION", ActiveWorkbook.Sheets(sht).Range("1:1"), 0)
                colIND_end = WorksheetFunction.Match("CHECK", ActiveWorkbook.Sheets(sht).Range("1:1"), 0) - 1
                Range(Cells(7, colIND_start), Cells(7, colIND_end)).Select
                Selection.FormulaR1C1 = "=IFERROR(INDEX(distro[#Data], MATCH([@[psnu_type]],distro[psnu_type],0),MATCH(R6C[0],distro[#Headers],0)),0)"
            End If
            'target formula
            colIND_start = WorksheetFunction.Match("DP TARGETS", ActiveWorkbook.Sheets(sht).Range("1:1"), 0)
            colIND_end = WorksheetFunction.Match("DISAGGREGATE TARGETS", ActiveWorkbook.Sheets(sht).Range("1:1"), 0) - 1
            Range(Cells(7, colIND_start), Cells(7, colIND_end)).Select
            Selection.FormulaR1C1 = "=IFERROR(INDEX(targets[#Data],MATCH([@[psnu_type]]&"" ""&[@mechid],targets[psnu_type_mechid],0),MATCH(R6C[0],targets[#Headers],0)),0)"
            'formulas for pseudo numerators (eg TX_RET 15+ = TX_RET - TX_RET <15)
            If sht <> "KeyPop" Then
                Sheets(sht).Activate
                colIND = WorksheetFunction.Match("DP TARGETS", ActiveWorkbook.Sheets(sht).Range("1:1"), 0)
                Cells(7, colIND + 2).FormulaR1C1 = "=IFERROR(RC[-2] - RC[-1],0)"
                If sht <> "VMMC" And sht <> "TBClinic" And sht <> "PMTCTANC" And sht <> "PediatricServices" And sht <> "Malnutrition" Then
                    Cells(7, colIND + 5).FormulaR1C1 = "=IFERROR(RC[-2] - RC[-1], 0)"
                End If
            End If
        Next sht

'        shtNames = Array("PediatricServices", "Malnutrition")
'        For Each sht In shtNames
'            colIND_start = WorksheetFunction.Match("DP TARGETS", ActiveWorkbook.Sheets(sht).Range("1:1"), 0)
'            Range(Cells(7, colIND_start), Cells(7, colIND_start + 1)).Select
'            Selection.FormulaR1C1 = "=IFERROR(INDEX(targets[#Data],MATCH([@[psnu_type]]&"" ""&[@mechid],targets[psnu_type_mechid],0),MATCH(R6C[0],targets[#Headers],0)),0)"
'            Cells(7, colIND + 3).FormulaR1C1 = "=RC[-2] - RC[-1]"
'        Next sht


End Sub



Sub indDistro()

    'activate mech list
        mechlistWkbk.Activate
    ' find the last column & row
        LastColumn = Range("A1").CurrentRegion.Columns.count
    'find first and last row of OU
        FirstRow = Range("A:A").Find(what:=OpUnit, After:=Range("A1")).Row
        LastRow = Range("A:A").Find(what:=OpUnit, After:=Range("A1"), searchdirection:=xlPrevious).Row
    'select OU data from global file to copy to data pack
        Range(Cells(FirstRow, 2), Cells(LastRow, LastColumn)).Select
    'copy the mech lists and paste in the disagg tool
        Selection.Copy
        dtWkbk.Activate
        Sheets.Add After:=Sheets(Sheets.count)
        ActiveSheet.Name = "MechList"
        Range("A1").Select
        Selection.PasteSpecial Paste:=xlPasteValues
        Application.CutCopyMode = False
    'define range
        Range("A1").Select
        LastColumnMech = Range("A1").CurrentRegion.Columns.count
        LastRowMech = Range("A1").CurrentRegion.Rows.count
        LastRow = LastRowMech + 6
    'copy mech lists into each tab
        shtNames = Array("IndexMod", "MobileMod", _
                         "VCTMod", "OtherMod", "Index", "STI", _
                         "Inpat", "Emergency", "VCT", "VMMC", _
                         "TBClinic", "PMTCTANC", "PediatricServices", _
                         "Malnutrition", "OtherPITC", "KeyPop")
        For Each sht In shtNames
            'copy mech list into each tab, formula will copy down in for whole table
            Sheets("MechList").Activate
            Range(Cells(1, 1), Cells(LastRowMech, LastColumnMech)).Select
            Selection.Copy
            Sheets(sht).Activate
            Range("C7").Select
            Selection.PasteSpecial Paste:=xlPasteValues
            Application.CutCopyMode = False
            'hard copy allocation lookups to cells (no need to have dynamic lookup at this point)
            If sht <> "PediatricServices" And sht <> "Malnutrition" Then
                colIND_start = WorksheetFunction.Match("ALLOCATION", ActiveWorkbook.Sheets(sht).Range("1:1"), 0)
                colIND_end = WorksheetFunction.Match("CHECK", ActiveWorkbook.Sheets(sht).Range("1:1"), 0) - 1
                Range(Cells(7, colIND_start), Cells(LastRow, colIND_end)).Select
                Selection.Copy
                Selection.PasteSpecial Paste:=xlPasteValues
                Application.CutCopyMode = False
            End If
            'add left colored border bar in column A
            Range(Cells(5, 1), Cells(LastRow, 1)).Select
            With Selection.Interior
                .Pattern = xlSolid
                .PatternColorIndex = xlAutomatic
                .ThemeColor = xlThemeColorAccent4
                .TintAndShade = 0.399975585192419
            End With

            Cells(1, 7).Select
        Next sht



End Sub

Sub saveFile()
    'reset each view to beginning of sheet
    Dim i
        shtCount = ActiveWorkbook.Worksheets.count
        For i = 2 To shtCount
            Worksheets(i).Activate
            Range("H2").Activate
            Range("A1").Select
        Next i

    'delete distribution tab
        Application.DisplayAlerts = False
        Sheets(Array("HistoricDistro", "MechList")).Delete
        Application.DisplayAlerts = True

    'save
        Sheets("Home").Activate
        Range("X1").Select
        fname_dp = OUcompl_fldr & OpUnit_ns & "COP18DisaggTool_HTS" & "v" & VBA.Format(Now, "yyyy.mm.dd") & ".xlsx"
        Application.DisplayAlerts = False
        ActiveWorkbook.SaveAs fname_dp

    'keep data pack open?
        If view = "No" Then
            dtWkbk.Close
        End If

        Application.DisplayAlerts = True
End Sub

''''''''''''''''''''
''   Zip Folder   ''
''''''''''''''''''''
'Source: http://www.rondebruin.nl/win/s7/win001.htm

Sub Zip_All_Files_in_Folder()
'ABOUT: This sub zips the OU folder that contains the _
data pack and its supplementary files"

    Dim FileNameZip, FolderName
    Dim strDate As String, DefPath As String
    Dim oApp As Object

        DefPath = compl_fldr
        If Right(DefPath, 1) <> "\" Then
            DefPath = DefPath & "\"
        End If

        FolderName = OUcompl_fldr

        strDate = VBA.Format(Now, "yyyy.mm.dd")
        FileNameZip = DefPath & OpUnit_ns & "DisaggTool" & strDate & ".zip"

    'Create empty Zip File
        NewZip (FileNameZip)

        Set oApp = CreateObject("Shell.Application")
    'Copy the files to the compressed folder
        oApp.Namespace(FileNameZip).CopyHere oApp.Namespace(FolderName).items

    'Keep script waiting until Compressing is done
        On Error Resume Next
        Do Until oApp.Namespace(FileNameZip).items.count = _
           oApp.Namespace(FolderName).items.count
            Application.Wait (Now + TimeValue("0:00:01"))
        Loop
        On Error GoTo 0


End Sub

Sub NewZip(sPath)
    'Create empty Zip File
    'Changed by keepITcool Dec-12-2005
    If Len(Dir(sPath)) > 0 Then Kill sPath
        Open sPath For Output As #1
    Print #1, Chr$(80) & Chr$(75) & Chr$(5) & Chr$(6) & String(18, 0)
    Close #1
End Sub


Function bIsBookOpen(ByRef szBookName As String) As Boolean
    ' Rob Bovey
    On Error Resume Next
    bIsBookOpen = Not (Application.Workbooks(szBookName) Is Nothing)
End Function


Function Split97(sStr As Variant, sdelim As String) As Variant
    'Tom Ogilvy
    Split97 = Evaluate("{""" & _
    Application.Substitute(sStr, sdelim, """,""") & """}")
End Function
