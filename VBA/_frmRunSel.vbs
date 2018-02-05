
Option Explicit

Dim i As Integer


Private Sub CheckBox2_Click()

End Sub

Private Sub UserForm_Initialize()
' initialize form

    With lbxOPUnits
        For i = 2 To 37
            .AddItem Worksheets("POPref").Range("B" & i).Value
        Next i
    End With

    lbxOPUnits.MultiSelect = 2

End Sub

Private Sub cmdRun_Click()
'run command --> generate forms

    Dim selOU 'selected operating units
    Dim rowNum
    Dim tmplWkbk1 As Workbook
    Dim chkView
    Dim chkZip

    Application.ScreenUpdating = False
    'record start time
        StartTime = Timer
    'clear Selected OUs in case of earlier error
        ActiveWorkbook.Sheets("POPref").Select
        Sheets("POPref").Range("F2:F37").ClearContents
    'set view
        Sheets("POPref").Range("D11").Select
        If Me.chkView.Value = True Then
            Selection.Value = "Yes"
        Else
            Selection.Value = "No"
        End If
    'zip folder?
        ActiveWorkbook.Sheets("POPref").Range("D14").Select
        If Me.chkZip.Value = True Then
            Selection.Value = "Yes"
        Else
            Selection.Value = "No"
        End If

    'name activeworkbook
        Set tmplWkbk1 = ActiveWorkbook

    'move OUs from list to POPref sheet to loop over
     For selOU = 0 To lbxOPUnits.ListCount - 1
         If lbxOPUnits.Selected(selOU) = True Then
             rowNum = Sheets("POPref").Range("D5").Value + 1
             Sheets("POPref").Cells(rowNum, 6).Offset(1, 0) = lbxOPUnits.list(selOU)
             lbxOPUnits.Selected(selOU) = False
         End If
     Next

   ' close form
        Unload Me

   ' run change form code
    'Call PopulateSiteDisaggTool

   'clear selected OUs and view
       tmplWkbk1.Sheets("POPref").Activate
        Range("F2:F37").ClearContents

   'end on toc
    Sheets("POPrun").Activate
    'time elaspsed
    SecondsElapsed = Round(Timer - StartTime, 2)
    Application.ScreenUpdating = True
    MsgBox "New Data Packs Created! Runtime: " & SecondsElapsed & " seconds", vbInformation

End Sub

Private Sub cmdClose_Click()
' close from and remove contents on close

    Unload Me

End Sub
