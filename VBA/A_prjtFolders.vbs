Sub genFolderStructure()

'ABOUT: This sub creates a folder structure for saving all files associated _
with this project. Pick a folder to add the overall project folder to. _
This sub will add then add the following folder in its sub directory _
including: _
    - DataPulls (.txt files for all DATIM data; two files for each OU, _
        one for the priority level and one for the facility level _
        for the yield figures), _
    - Intermediate (this is an intermediate folder used for saving files _
        in the middle of template generation; files will be erased from _
        folder prior to the completion of the final Data Pack, _
    - TemplateGeneration (folder contains the template .xlsm file), _
    - CompletedDataPacks (contains the final data pack files for each OU _
        after created from the template) and _
    - OtherInfo (contains all other documents and files). _
After the folders are created, the APR data from DATIM should be _
added to the DataPulls folder and the template file should be added to the _
TemplateGeneration folder.

    'variables
        Dim FolderName As String
        Dim newFolder
        Dim path As String
        Dim subpath As String

    'browse to folder
        MsgBox "Select the file path where you want the Data Pack folder to be located.", vbInformation, "Folder Path"
        With Application.FileDialog(msoFileDialogFolderPicker)
            .AllowMultiSelect = False
            .Show
            On Error Resume Next
            FolderName = .SelectedItems(1)
            Err.Clear
            On Error GoTo 0
        End With
    'if no folder select, end sub
        If Len(FolderName) = 0 Then Exit Sub
    'ask user if file location is correct; end if not
        If MsgBox(FolderName & "\DataPack" & vbCr & "Is this location okay?", vbYesNo) = vbNo Then Exit Sub
    'if the location is correct, add Data Pack folder and other subfolders
        For Each newFolder In Array("DataPack", "Output", "TempOutput", "TemplateGeneration", "CompletedDataPacks", "OtherInfo")
            If newFolder = "DataPack" Then
                path = FolderName & "\" & newFolder
                If Len(Dir(path, vbDirectory)) = 0 Then MkDir path
            Else
                subpath = path & "\" & newFolder
            End If
            If Len(Dir(subpath, vbDirectory)) = 0 Then MkDir subpath
        Next newFolder
    'end msgbox
        MsgBox "The folder was successfully created. You should now load" & vbCr & "" & _
            " the template and data into their respective folders."
End Sub
