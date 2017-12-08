Option Explicit

    Public compl_fldr As String
    Public distroWkbk As Workbook
    Public dtWkbk As Workbook
    Public fname_dp As String
    Public LastColumn As Integer
    Public LastRow As Integer
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
        Workbooks.OpenText Filename:=pulls_fldr & "DisaggDistro.csv"
        Set distroWkbk = ActiveWorkbook
        Workbooks.OpenText Filename:=pulls_fldr & "Global_DT_MechList.csv"
        Set mechlistWkbk = ActiveWorkbook
        Workbooks.OpenText Filename:=pulls_fldr & "Global_DT_PSNUList.csv"
        Set psnulistWkbk = ActiveWorkbook
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
        Call psnuDistro
        Call indDistro
        Call saveFile

        'Zip output folder
        If tmplWkbk.Sheets("POPref").Range("D14").Value = "Yes" Then
            Call Zip_All_Files_in_Folder
        End If

    Next




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
            pulls_fldr = path & "DataPulls\"
            compl_fldr = path & "CompletedDataPacks\"
            theme_fldr = path & "Theme\"
        'set directory initially to the pulls folder
            ChDir (path)
End Sub

Sub Initialize()
    'snu & site level for OU
        tmplWkbk.Sheets("POPref").Activate
    'create datapack file for OU (copy sheets over to new book)
        tmplWkbk.Activate
        Sheets(Array("Home", "Allocation by SNUxIM", "GEND_GBV Alloc", "GEND_GBV Targets", _
        "HTS_SELF Alloc", "HTS_SELF Targets", "OVC_SERV Alloc", "OVC_SERV Targets", _
        "PMTCT Alloc", "PMTCT Targets", "PP_PREV Alloc", "PP_PREV Targets", "PrEP_NEW Alloc", _
        "PrEP_NEW Targets", "TB Alloc", "TB Targets", "TX_CURR Alloc", "TX_CURR Targets", _
        "TX_NEW Alloc", "TX_NEW Targets", "TX_PVLS Alloc", "TX_PVLS Targets", "TX_RET Alloc", _
        "TX_RET Targets", "TX_TB Alloc", "TX_TB Targets", "VMMC_CIRC Alloc", "VMMC_CIRC Targets", _
        "All Ready Alloc Targets", "Historic Distro", "Follow on Mech List")).Copy
        Set dtWkbk = ActiveWorkbook
        ActiveWorkbook.Theme.ThemeColorScheme.Load (theme_fldr & "Adjacency.xml")
    'hard code update date into home tab & insert OU name
        Sheets("Home").Range("N1").Select
        Range("N1").Copy
        Selection.PasteSpecial Paste:=xlPasteValues
        Range("O1").Value = OpUnit
        Range("AA1").Select

End Sub

Sub getData()

    'make sure file with data is activate
        distroWkbk.Activate
    ' find the last column & row
        LastColumn = Range("A1").CurrentRegion.Columns.Count
    'find first and last row of OU
        FirstRow = Range("A:A").Find(what:=OpUnit, After:=Range("A1")).Row
        LastRow = Range("A:A").Find(what:=OpUnit, After:=Range("A1"), searchdirection:=xlPrevious).Row
    'select OU data from global file to copy to data pack
        Range(Cells(FirstRow, 2), Cells(LastRow, LastColumn)).Select
    'copy the data and paste in the data pack
        Selection.Copy
        dtWkbk.Activate
        Sheets("Historic Distro").Activate
        Range("C3").Select
        Selection.PasteSpecial Paste:=xlPasteValues
        Application.CutCopyMode = False

End Sub

Sub psnuDistro()

    'activate PSNU list
        psnulistWkbk.Activate
    ' find the last column & row
        LastColumn = Range("A1").CurrentRegion.Columns.Count
    'find first and last row of OU
        FirstRow = Range("A:A").Find(what:=OpUnit, After:=Range("A1")).Row
        LastRow = Range("A:A").Find(what:=OpUnit, After:=Range("A1"), searchdirection:=xlPrevious).Row
    'select OU data from global file to copy to data pack
        Range(Cells(FirstRow, 2), Cells(LastRow, LastColumn)).Select
    'copy the PSNU lists and paste in the disagg tool's allocation tabs
        Selection.Copy
        dtWkbk.Activate
        shtNames = Array("GEND_GBV", "HTS_SELF", "OVC_SERV", _
                "PMTCT", "PP_PREV Alloc", "PrEP_NE", "TB", "TX_CURR", _
                "TX_NEW", "TX_PVLS", "TX_RET", "TX_TB", "VMMC_CIRC")
        For Each sht In shtNames
            Sheet(sht & " Alloc").Activate
            Range("C7").Select
            Selection.PasteSpecial Paste:=xlPasteValues
        Next sht
        Application.CutCopyMode = False
    'hard code site info & distro
        For Each sht In shtNames
            Sheet(sht & " Alloc").Activate
            LastRow = Range("C1").CurrentRegion.Rows.Count
            LastColumn = Range("C2").CurrentRegion.Columns.Count
            Range(Cells(7, 3), Cells(LastRow, LastColumn)).Select
            Selection.Copy
            Selection.PasteSpecial Paste:=xlPasteValues
            Application.CutCopyMode = False
            'add colored bar to right
            Range(Cells(5, 1), Cells(LastRow, 1)).Select
            With Selection.Interior
                .Pattern = xlSolid
                .PatternColorIndex = xlAutomatic
                .ThemeColor = xlThemeColorAccent4
                .TintAndShade = 0.399975585192419
            End With

            Cells(1, 7).Select

        Next sht


    'delete distribution tab
        Application.DisplayAlerts = False
        Sheets("Historic Distro").Delete
        Application.DisplayAlerts = True

End Sub

Sub indDistro()

    'activate mech list
        mechlistWkbk.Activate
    ' find the last column & row
        LastColumn = Range("A1").CurrentRegion.Columns.Count
    'find first and last row of OU
        FirstRow = Range("A:A").Find(what:=OpUnit, After:=Range("A1")).Row
        LastRow = Range("A:A").Find(what:=OpUnit, After:=Range("A1"), searchdirection:=xlPrevious).Row
    'select OU data from global file to copy to data pack
        Range(Cells(FirstRow, 2), Cells(LastRow, LastColumn)).Select
    'copy the mech lists and paste in the disagg tool's allocation tabs
        Selection.Copy
        dtWkbk.Activate
        shtNames = Array("GEND_GBV", "HTS_SELF", "OVC_SERV", _
                "PMTCT", "PP_PREV Alloc", "PrEP_NE", "TB", "TX_CURR", _
                "TX_NEW", "TX_PVLS", "TX_RET", "TX_TB", "VMMC_CIRC")
        For Each sht In shtNames
            Sheet(sht & " Targets").Activate
            Range("C7").Select
            Selection.PasteSpecial Paste:=xlPasteValues
        Next sht
        Application.CutCopyMode = False
    'hard code site info & distro
        For Each sht In shtNames
            Sheet(sht & " Targets").Activate
            LastRow = Range("C1").CurrentRegion.Rows.Count
            LastColumn = Range("C2").CurrentRegion.Columns.Count
            Range(Cells(7, 3), Cells(LastRow, LastColumn)).Select
            Selection.Copy
            Selection.PasteSpecial Paste:=xlPasteValues
            Application.CutCopyMode = False
            'add colored bar to right
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
        shtCount = ActiveWorkbook.Worksheets.Count
        For i = 2 To shtCount
            Worksheets(i).Activate
            Range("H2").Activate
            Range("A1").Select
        Next i
    'save
        Sheets("Home").Activate
        Range("X1").Select
        fname_dp = OUcompl_fldr & OpUnit_ns & "COP18DisaggTool" & "v" & VBA.Format(Now, "yyyy.mm.dd") & ".xlsx"
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
        FileNameZip = DefPath & OpUnit_ns & "SiteTool" & strDate & ".zip"

    'Create empty Zip File
        NewZip (FileNameZip)

        Set oApp = CreateObject("Shell.Application")
    'Copy the files to the compressed folder
        oApp.Namespace(FileNameZip).CopyHere oApp.Namespace(FolderName).items

    'Keep script waiting until Compressing is done
        On Error Resume Next
        Do Until oApp.Namespace(FileNameZip).items.Count = _
           oApp.Namespace(FolderName).items.Count
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
