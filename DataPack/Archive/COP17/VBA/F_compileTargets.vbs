Option Explicit

'variables
    Public colIND As Integer
    Public compWkbk As Workbook
    Public dpPath As String
    Public dpWkbk As Workbook
    Public i As Integer
    Public IND As String
    Public LastColumn As Integer
    Public LastRow As Integer
    Public sitePath As String
    Public siteWkbk As Workbook


Sub compileTargets()

'name compiler tool workbook
    Set compWkbk = ActiveWorkbook

'folder location
    'data pack
        MsgBox "Locate the most recent Data Pack stored on this machine", vbInformation, "Data Pack Folder Path"
            With Application.FileDialog(msoFileDialogOpen)
                .AllowMultiSelect = False
                .Show
                On Error Resume Next
                dpPath = .SelectedItems(1)
                Err.Clear
                On Error GoTo 0
            End With
    'if no folder select, end sub
        If Len(dpPath) = 0 Then Exit Sub
    'site tool
        MsgBox "Locate the most recent Site & Disaggregate Tool stored on this machine", vbInformation, "Site Tool Folder Path"
            With Application.FileDialog(msoFileDialogOpen)
                .AllowMultiSelect = False
                .Show
                On Error Resume Next
                sitePath = .SelectedItems(1)
                Err.Clear
                On Error GoTo 0
            End With
    'if no folder select, end sub
        If Len(sitePath) = 0 Then Exit Sub


'turn off screen updating
    Application.ScreenUpdating = False

'open site tool
    Workbooks.OpenText Filename:=sitePath
    Sheets("Data Pack SNU Targets").Activate
    Set siteWkbk = ActiveWorkbook

'open data pack
    Workbooks.OpenText Filename:=dpPath
    Sheets("Target Calculation").Activate
    Set dpWkbk = ActiveWorkbook

'copy snu list to site tool
    LastRow = Range("C3").CurrentRegion.Rows.Count
    Range(Cells(7, 3), Cells(LastRow, 3)).Select
    Selection.Copy
    siteWkbk.Activate
    Cells(7, 3).Select
    Selection.PasteSpecial Paste:=xlPasteValues
    Application.CutCopyMode = False

'use error handler
    On Error GoTo ErrorHandler:

'pull all site targets from Data Pack
    siteWkbk.Activate
    LastColumn = Range("C2").CurrentRegion.Columns.Count
    For i = 4 To LastColumn
        Range(Cells(7, i), Cells(LastRow, i)).ClearContents
        IND = Cells(4, i).Value
        dpWkbk.Activate
        colIND = WorksheetFunction.Match(IND, ActiveWorkbook.Sheets("Target Calculation").Range("4:4"), 0)
        Range(Cells(7, colIND), Cells(LastRow, colIND)).Select
        Selection.Copy
        siteWkbk.Activate
        Cells(7, i).Select
        Selection.PasteSpecial Paste:=xlPasteValues
        Application.CutCopyMode = False
ContErr:
    Next i


'save & close
    Application.DisplayAlerts = False
    dpWkbk.Close
    ActiveWorkbook.SaveAs sitePath
    Application.DisplayAlerts = False


Exit Sub

ErrorHandler:
    If Err.Number = 1004 Then
        'issue = mislabeled target in the data pack
        siteWkbk.Activate
        Cells(7, i).Select
        With Selection
            .Value = "ERROR: no target column in Data Pack matches this column header. Rename header to match Data Pack and rerun compiler tool."
            .NumberFormat = "#,##0;-#,##0;;[Red]@"
        End With
        Resume ContErr
    Else
        Application.DisplayAlerts = False
        dpWkbk.Close
        Application.DisplayAlerts = True
        MsgBox "An unexpected error was encountered (" & Err.Number & ") and the script has stopped running."
        Exit Sub
    End If

End Sub
