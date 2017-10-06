Sub SaveNewVersion()

'ABOUT: This sub is used for saving a new version of the template. It will _
change the date in (a) file name (eg ...v2016.12.22.xlsm) and (b) "POPrun" _
tab (eg Updated: December 22, 2016). Run this sub via the "SAVE" button _
on the POPref tab in the template.

    Dim templ_fldr As String

    Application.ScreenUpdating = False

    'folder path for saving
        templ_fldr = "C:\Users\achafetz\Documents\DataPack\TemplateGeneration\"
    'update date in POPref
        Sheets("POPref").Range("D8").Value = VBA.Format(Now(), "mmmm d")
    'save file
        Application.DisplayAlerts = False
        ActiveWorkbook.SaveAs Filename:= _
            templ_fldr & "COP17Site&DisaggToolTemplate v" & VBA.Format(Now(), "yyyy.mm.dd") & ".xlsm" _
            , FileFormat:=xlOpenXMLWorkbookMacroEnabled, CreateBackup:=False
        Application.DisplayAlerts = True

    Application.ScreenUpdating = True

End Sub
