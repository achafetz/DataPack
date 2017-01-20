Option Explicit

    Public compl_fldr As String
    Public dataWkbk As Workbook
    Public dpWkbk As Workbook
    Public fname_dp As String
    Public LastColumn As Integer
    Public LastRow As Integer
    Public OpUnit As Object
    Public OpUnit_ns As String
    Public other_fldr As String
    Public OUcompl_fldr As String
    Public OUpath As String
    Public path As String
    Public pulls_fldr As String
    Public rng As Integer
    Public SelectedOpUnits
    Public sht As Variant
    Public shtNames As Variant
    Public tmplWkbk As Workbook
    Public view As String




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
        Call siteDistro
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
            other_fldr = path & "OtherInfo\"
        'set directory initially to the pulls folder
            ChDir (path)
End Sub

Sub Initialize()
    'snu & site level for OU
        tmplWkbk.Sheets("POPref").Activate
    'create datapack file for OU (copy sheets over to new book)
        tmplWkbk.Activate
        Sheets(Array("Home", "Data Pack SNU Targets", "Site IM Allocation", "TX_NEW", _
            "TX_CURR", "PMTCT_STAT", "PMTCT_ART", "PMTCT_EID", "TB_ART", "TB_STAT", "VMMC_CIRC", _
            "OVC_SERV", "KP_PREV", "KP_MAT", "PP_PREV", "Site Allocation", "Indicators")).Copy
        Set dpWkbk = ActiveWorkbook
        ActiveWorkbook.Theme.ThemeColorScheme.Load (other_fldr & "Adjacency.xml")
    'hard code update date into home tab & insert OU name
        Sheets("Home").Range("N1").Select
        Range("N1").Copy
        Selection.PasteSpecial Paste:=xlPasteValues
        Range("O1").Value = OpUnit
        Range("AA1").Select
    'Open data file file
        Workbooks.OpenText Filename:=pulls_fldr & OpUnit_ns & "_Site_*.xlsx"
        Set dataWkbk = ActiveWorkbook

End Sub

Sub getData()
    shtNames = Array("Site Allocation", "Indicators")
    For Each sht In shtNames
    'make sure file with data is activate
        dataWkbk.Activate
        Sheets(sht).Activate
    ' find the last column & row
        LastColumn = Range("A1").CurrentRegion.Columns.Count
        LastRow = Range("C1").CurrentRegion.Rows.Count
    'select OU data from global file to copy to data pack
        Range(Cells(2, 3), Cells(LastRow, LastColumn)).Select
    'copy the data and paste in the data pack
        Selection.Copy
        dpWkbk.Activate
        Sheets(sht).Activate
        Range("A7").Select
        Selection.PasteSpecial Paste:=xlPasteValues
        Application.CutCopyMode = False
    Next

    'close dataset
     dataWkbk.Close

End Sub

Sub siteDistro()
        Sheets("Site Allocation").Activate
    'find last row
        LastRow = Range("A1").CurrentRegion.Rows.Count
    'copy site info to Site IM Allocation tab
        Range(Cells(7, 1), Cells(LastRow, 5)).Select
        Sheets("Site IM Allocation").Activate
        Range("C8").Select
        ActiveSheet.Paste
        Application.CutCopyMode = False
    'copy forumla down to all cells
        LastColumn = Range("C2").CurrentRegion.Columns.Count
        Range(Cells(7, 3), Cells(7, LastColumn)).Select
        Selection.Copy
        Range(Cells(7, 3), Cells(LastRow, LastColumn)).Select
        ActiveSheet.Paste
        Application.CutCopyMode = False
    'hard code site info & distro
        LastColumn = WorksheetFunction.Match("FY18 Target Allocation", ActiveWorkbook.Range("1:1"), 0) - 1
        Range(Cells(7, 3), Cells(LastRow, LastColumn)).Select
        Selection.Copy
        Selection.PasteSpecial Paste:=xlPasteValues
        Application.CutCopyMode = False

    Cells(1, 7).Select

End Sub

Sub indDistro()

    'copy site info
        Sheets("Indicators").Activate
    'find last row
        LastRow = Range("C1").CurrentRegion.Rows.Count

    Sheets(Array("TX_NEW", "TX_CURR", "PMTCT_STAT", _
        "PMTCT_ART", "PMTCT_EID", "TB_ART", "TB_STAT", "VMMC_CIRC", _
        "OVC_SERV", "KP_PREV", "KP_MAT", "PP_PREV")).Copy
    For Each sht In shtNames
    'copy site info to Site IM Allocation tab
        Sheets("indicators").Activate
        Range(Cells(7, 1), Cells(LastRow, 5)).Select
        Sheets(sht).Activate
        Range("C7").Select
        Selection.PasteSpecial Paste:=xlPasteValues
        Application.CutCopyMode = False

    'copy forumla down to all cells
        LastColumn = Range("C2").CurrentRegion.Columns.Count
        Range(Cells(7, 3), Cells(7, LastColumn)).Select
        Selection.Copy
        Range(Cells(7, 3), Cells(LastRow, LastColumn)).Select
        ActiveSheet.Paste
        Application.CutCopyMode = False

    'hard code site info & distro
        LastColumn = WorksheetFunction.Match("DP", ActiveWorkbook.Sheets(sht).Range("1:1"), 0) - 1
        Range(Cells(7, 3), Cells(LastRow, LastColumn)).Select
        Selection.Copy
        Selection.PasteSpecial Paste:=xlPasteValues
        Application.CutCopyMode = False

        Cells(1, 7).Select

    Next sht


End Sub

Sub saveFile()
    'save
        Sheets("Home").Activate
        Range("X1").Select
        fname_dp = OUcompl_fldr & OpUnit_ns & "COP17Site&DisaggTool" & "v" & VBA.Format(Now, "yyyy.mm.dd") & ".xlsx"
        Application.DisplayAlerts = False
        ActiveWorkbook.SaveAs fname_dp

    'keep data pack open?
        If view = "No" Then
            dpWkbk.Close
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
        FileNameZip = DefPath & OpUnit_ns & strDate & ".zip"

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
