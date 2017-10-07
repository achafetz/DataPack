Option Explicit
'ABOUT: This series of subs creates the Data Pack and its supplemental _
files for use in the FY 2016 COP. This sub is run via the RUN button on _
the POPrun tab of the template. The RUN button initiates the generation _
form for choosing the OUs and Data Pack products

'variables
        Public rng As Integer
        Public SelectedOpUnits
        Public OpUnit As Object
        Public OpUnit_ns As String
        Public version As String
        Public view As String
        Public tmplWkbk As Workbook
        Public DataWkbk As Workbook
        Public dpWkbk As Workbook
        Public yldWkbk As Workbook
        Public ou_i As Integer
        Public path As String
        Public file As String
        Public pulls_fldr As String
        Public intr_fldr As String
        Public templ_fldr As String
        Public compl_fldr As String
        Public OUpath As String
        Public OUcompl_fldr As String
        Public fname_int As String
        Public fname_dp As String
        Public tbl As ListObject
        Public pvtField As String
        Public pvtField_uid As String
        Public pvtField_ou
        Public LastColumn As Integer
        Public snuLevel As Integer
        Public siteLevel As Integer
        Public snu_unique As Integer
        Public uniqueRng
        Public uniqueTot As Integer
        Public IndicatorCount
        Public celltxt As String
        Public ctgry As String
        Public LastRow As Integer
        Public EntryIndicatorCount As Integer
        Public i As Integer
        Public sFound As String
        Public sht As Variant
        Public shtNames As Variant
        Public LastSumColumn As Integer
        Public LastRowRC As Integer
        Public indColNum As Integer
        Public indRng As Range
        Public NUM As String
        Public DEN As String
        Public rcNUM As Integer
        Public rcDEN As Integer
        Public colIND As Integer
        Public IND
        Public INDnames
        Public priority
        Public prtype As String
        Public prtycolNum As Integer
        Public tb_val
        Public fname_csd As String
        Public outputFile As String
        Public selectedSNUs
        Public LastColumnDREAMS As Integer
        Public snu
        Public totSNUs
        Public startTIME
        Public fsize_txt
        Public fsize_dp
        Public reg As Integer
        Public military As String
        
        

Sub loadform()
    'prompt for form to load to choose OUs to run
    frmRunSel.Show
    
End Sub


Sub PopulateDataPack()
    'turn off screen updating
        Application.ScreenUpdating = False
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
    'run for just military
        military = Sheets("POPref").Range("D29")
        
    'loop over opunit
    ou_i = 2 ' count used to lookup SNU level for each OU (row #)
    
    For Each OpUnit In SelectedOpUnits
        'record start time
            startTIME = VBA.format(Now, "hh:nn:ss AM/PM")
        'regional program?
            reg = 0
            If InStr(1, OpUnit, "Region") > 0 Then reg = 1
        'remove space and comma for file saving (ns = no space)
        OpUnit_ns = Replace(Replace(OpUnit, " ", ""), "'", "")
        If tmplWkbk.Sheets("POPref").Range("D14").Value = "Yes" Then
            outputFile = "DataPack"
            Call Initialize
            Call GetData
            Call pvtSNUs
            Call dataFormulas
            Call yieldFormulas
            Call setupSNUs
            Call setupHTCDistro
            Call lookupsumFormulas
            Call format
            Call showChanges
            Call extlData
            Call filters
            Call dimDefault
            Call updatePBAC
            Call seperateCascades
            Call saveFile
          End If
        'Yields
        If tmplWkbk.Sheets("POPref").Range("D17").Value = "Yes" Then
            outputFile = "Yields"
            If OpUnit = "Caribbean Region" Then reg = 1 'adjustment to include OU name w/ sites
            Call Initialize
            If military <> "Yes" Then
            Call GetData
            Call pvtSNUs 'actually sites
            Call dataFormulasYields
            Call setupYieldsTables
            Call cleanYields
            End If
            Call saveFileYields
        End If
        'Zip output folder
        If tmplWkbk.Sheets("POPref").Range("D26").Value = "Yes" Then
            Call Zip_All_Files_in_Folder
        End If
            
        ou_i = ou_i + 1 'row for OU in POPref
    'record OU, run time, file size
        tmplWkbk.Activate
        Sheets("POPreport").Select
        LastRow = Range("A1").CurrentRegion.Rows.Count + 1 'find new row
        Cells(LastRow, 1).Select
        With Selection
            .Value = OpUnit
            .Offset(0, 1).Value = uniqueTot
            .Offset(0, 2).Value = VBA.format(Now, "m/d")
            .Offset(0, 3).Value = startTIME
            .Offset(0, 4).Value = VBA.format(Now, "hh:nn AM/PM")
            .Offset(0, 5).Value = VBA.format(Cells(LastRow, 5).Value - Cells(LastRow, 4).Value, "nn:ss")
            .Offset(0, 6).Value = fsize_txt & " KB"
            .Offset(0, 7).Value = fsize_dp & " KB"
        End With
    Next
    
    'turn on screen updating
        'Application.ScreenUpdating = True
End Sub


Sub fldrSetup()
    'for saving/opening:
        'set path
            If Sheets("POPref").Range("D23").Value = 0 Then
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
                    Sheets("POPref").Range("D23").Value = path
            Else
                path = Sheets("POPref").Range("D23").Value
            End If
        ' set folder directory
            pulls_fldr = path & "DataPulls\"
            intr_fldr = path & "Intermediate\"
            templ_fldr = path & "TemplateGeneration\"
            compl_fldr = path & "CompletedDataPacks\"
        'set directory initially to the pulls folder
            ChDir (pulls_fldr)
End Sub

Sub Initialize()
    'create OU specific folder
        OUpath = compl_fldr & OpUnit_ns & VBA.format(Now, "yyyy.mm.dd")
        If military = "Yes" Then OUpath = compl_fldr & OpUnit_ns & "Mil" & VBA.format(Now, "yyyy.mm.dd")
        If Len(Dir(OUpath, vbDirectory)) = 0 Then MkDir OUpath
        OUcompl_fldr = OUpath & "\"
    'snu & site level for OU
        tmplWkbk.Sheets("POPref").Activate
        snuLevel = Sheets("POPref").Cells(ou_i, 7).Value
        siteLevel = Sheets("POPref").Cells(ou_i, 8).Value
    'create datapack file for OU (copy sheets over to new book)
        tmplWkbk.Activate
        If outputFile = "DataPack" Then
            Sheets(Array("Home", "Entry Table", "Summary & Targets", "Indicator Table", "HTC Indicator Table", "HTC Data Entry", "PEPFAR Cascades", "Cascade Table", "PEPFAR Supplemental Cascades", "PBAC Output", "Change Form")).Copy
            Set dpWkbk = ActiveWorkbook
        ElseIf outputFile = "Yields" Then
            Sheets(Array("Home", "Yield Figures", "Indicator Table")).Copy
            Set yldWkbk = ActiveWorkbook
        End If
        On Error Resume Next
        ActiveWorkbook.Theme.ThemeColorScheme.Load ("C:\Program Files (x86)\Microsoft Office\Document Themes 14\Theme Colors\Adjacency.xml")
    'hard code update date into home tab & insert OU name
       Sheets("Home").Range("N1").Select
       Range("N1").Copy
       Selection.PasteSpecial Paste:=xlPasteValues
       Range("O1").Value = OpUnit
       If outputFile = "Yields" Then Range("P1").Value = "COP 17 YIELD FIGURES"
       Range("AA1").Select
End Sub

Sub GetData()
     'Open DATIM txt file
        If outputFile = "Yields" Then
            Workbooks.OpenText Filename:=OpUnit_ns & " Fac_*.txt", _
            Origin:=437, StartRow:=1, DataType:=xlDelimited, TextQualifier:= _
            xlDoubleQuote, Tab:=True, TrailingMinusNumbers:=True
        Else
            Workbooks.OpenText Filename:=OpUnit_ns & " _PSNU_*.txt", _
            Origin:=437, StartRow:=1, DataType:=xlDelimited, TextQualifier:= _
            xlDoubleQuote, ConsecutiveDelimiter:=False, Tab:=True, Semicolon:=False, _
            Comma:=False, Space:=False, Other:=False, FieldInfo:=Array(Array(1, 1), _
            Array(2, 1), Array(3, 1), Array(4, 1), Array(5, 1), Array(6, 1), Array(7, 1), Array(8, 1), _
            Array(9, 1), Array(10, 1), Array(11, 1), Array(12, 1), Array(13, 1), Array(14, 1), Array(15 _
            , 1), Array(16, 1), Array(17, 1), Array(18, 1), Array(19, 1), Array(20, 1), Array(21, 1), _
            Array(22, 1), Array(23, 1)), TrailingMinusNumbers:=True
            ' record file size
            fsize_txt = VBA.format(FileLen(ActiveWorkbook.FullName) / 1000, "#,##0")
        End If
       Set DataWkbk = ActiveWorkbook
     'save as xlsx (to allow for tab copy)
        Application.DisplayAlerts = False
        If outputFile = "DataPack" Then
            fname_int = intr_fldr & OpUnit_ns & outputFile & "datav" & VBA.format(Now, "yyyy.mm.dd") & ".xlsx"
            ActiveWorkbook.SaveAs fname_int, FileFormat:=51
        ElseIf outputFile = "DREAMS" Then
           fname_dp = OUcompl_fldr & OpUnit_ns & "COP16" & outputFile & "v" & VBA.format(Now, "yyyy.mm.dd") & ".xlsx"
            ActiveWorkbook.SaveAs fname_dp, FileFormat:=51
        End If
        Application.DisplayAlerts = True
    'change worksheet name
        ActiveSheet.Name = "rawdata"
     'setup range as datatable
        Range("A1").Select
        Selection.CurrentRegion.Select
        Set tbl = ActiveSheet.ListObjects.Add(xlSrcRange, Selection, , xlYes)
            tbl.TableStyle = ""
            tbl.Name = "data"
    'SNU identification
        If outputFile <> "DREAMS" Then
            tmplWkbk.Activate
            Sheets("POPtable").Select
            If outputFile = "DataPack" Then Sheets(Array("POPtable", "POPhtctable")).Copy After:=DataWkbk.Sheets(1)
            If outputFile = "Yields" Then Sheets("POPyieldtable").Copy After:=DataWkbk.Sheets(1)
            ActiveWorkbook.Names.Add Name:="site_lvl", RefersToR1C1:=siteLevel
            ActiveWorkbook.Names.Add Name:="snu_lvl", RefersToR1C1:=snuLevel
            Sheets("rawdata").Select
        End If

End Sub

Sub pvtSNUs()
Dim pf As PivotField
    'identify SNU Level Name and UID
       If outputFile = "DataPack" Then
            pvtField = "orgLevel" & snuLevel & "Name"
            pvtField_uid = "uidlevel" & snuLevel
            pvtField_ou = "orgLevel4Name" 'used for regional programs
        ElseIf outputFile = "Yields" Then
            pvtField = "orgLevel" & siteLevel & "Name"
            pvtField_uid = "uidlevel" & siteLevel
            pvtField_ou = "orgLevel4Name" 'used for regional programs
       End If
       If military = "Yes" Then
            pvtField = "orgLevel4Name"
            pvtField_uid = "uidlevel4"
            pvtField_ou = "orgLevel3Name" 'used for regional programs
        End If
    'pull SNU list via pivot table
       Sheets("rawdata").Activate
       Range("A2").Select
       Sheets.Add.Name = "pt"
    'pivot data
       ActiveWorkbook.PivotCaches.Create(SourceType:=xlDatabase, SourceData:= _
           "data", version:=xlPivotTableVersion14).CreatePivotTable TableDestination _
           :="pt!R3C1", TableName:="SNUList", DefaultVersion:= _
           xlPivotTableVersion14 'insert pivot table
       Sheets("pt").Cells(3, 1).Select
       On Error Resume Next
       With ActiveSheet.PivotTables("SNUList")
           .RowAxisLayout xlTabularRow 'setup pivot table as tabular
           .PivotFields(pvtField_uid).Orientation = xlRowField
           .PivotFields(pvtField_uid).Position = 1 'add list of UIDs for SNUs
           .PivotFields(pvtField_ou).Orientation = xlRowField
           .PivotFields(pvtField_ou).RepeatLabels = True
           .PivotFields(pvtField_ou).Position = 2 'add OU name for SNUs
           .PivotFields(pvtField).Orientation = xlRowField
           .PivotFields(pvtField).Position = 3 'add list of SNUs
           .PivotFields(pvtField).PivotItems("NULL").Visible = False 'remove NULL
           .PivotFields(pvtField).PivotItems("(blank)").Visible = False 'remove blanks
           .ColumnGrand = False
           .RowGrand = False
       End With
       If military = "Yes" Then
            ActiveSheet.PivotTables("SNUList").PivotFields(pvtField). _
                PivotFilters.Add Type:=xlCaptionContains, Value1:="Military"
       End If
       ActiveSheet.PivotTables("SNUList").DisplayFieldCaptions = False
       'Remove subtotals (by contextures.com)
        On Error Resume Next
        For Each pf In ActiveSheet.PivotTables("SNUList").PivotFields
        'First, set index 1 (Automatic) to True,
        'so all other values are set to False
            pf.Subtotals(1) = True
            pf.Subtotals(1) = False
        Next pf
       'add formula for capturing OU and SNU
        LastRow = Range("A3").CurrentRegion.Rows.Count + 2
        Range("D3").FormulaR1C1 = "=RC[-3]"
        Range("D3").Select
        Selection.AutoFill Destination:=Range(Cells(3, 4), Cells(LastRow, 4))
        Range("E3").Select
        If reg = 1 Then
            ActiveCell.FormulaR1C1 = "=RC[-3]&""/""&RC[-2]"
        ElseIf Range("C3").Value = "" Then
            ActiveCell.FormulaR1C1 = "=RC[-3]"
        Else
            ActiveCell.FormulaR1C1 = "=RC[-2]"
        End If
        Range("E3").Select
        Selection.AutoFill Destination:=Range(Cells(3, 5), Cells(LastRow, 5))
       'highlight UID and names to copy over
       Range(Cells(3, 4), Cells(LastRow, 5)).Select
       uniqueTot = Sheets("pt").Cells(4, 1).CurrentRegion.Rows.Count - 1 'account for text in A1
       If outputFile = "DataPack" Then
            ActiveWorkbook.Names.Add Name:="snu_unique", RefersToR1C1:=uniqueTot
            Selection.Copy
            Sheets(Array("POPtable", "POPhtctable")).Select
        ElseIf outputFile = "Yields" Then
            ActiveWorkbook.Names.Add Name:="site_unique", RefersToR1C1:=uniqueTot
            Selection.Copy
            Sheets("POPyieldtable").Select
        End If
        Range("A11").Select
        Selection.PasteSpecial Paste:=xlPasteValues
End Sub

Sub dataFormulas()
    Dim colPREV As Integer
    Dim colSNU As Integer
    
    'insert formulas (regular and array)
        shtNames = Array("POPtable", "POPhtctable")
        For Each sht In shtNames
            DataWkbk.Activate
            Sheets(sht).Select
            IndicatorCount = Range("A1").CurrentRegion.Columns.Count 'find last column
            LastRow = Range("A1").CurrentRegion.Rows.Count 'find last row
            'add basic formula
                Range(Cells(11, 3), Cells(11, IndicatorCount)).FormulaR1C1 = "=SUMIFS(data[Value],data[" & pvtField_uid & "],R[0]C1,data[indicator],R1C,data[disaggregate],R2C,data[categoryOptionComboName],R3C,data[categoryOptionComboName],R4C,data[numeratorDenom],R5C,data[resultTarget],R6C,data[period],R7C)"
            'add array formula for indicators that need it
                If sht = "POPtable" Then
                    For i = 2 To IndicatorCount
                        celltxt = ActiveSheet.Cells(3, i).Text
                        'array formulas
                        If InStr(1, celltxt, "{") Then
                            ctgry = Cells(3, i).Value
                            Cells(11, i).FormulaR1C1 = "=SUM(SUMIFS(data[Value],data[" & pvtField_uid & "],R[0]C1,data[indicator],R1C,data[disaggregate],R2C,data[categoryOptionComboName]," & ctgry & ",data[categoryOptionComboName],R4C,data[numeratorDenom],R5C,data[resultTarget],R6C,data[period],R7C))"
                        End If
                        'formulas with no disaggreate
                        If InStr(1, celltxt, "(default)") Then
                            Cells(11, i).FormulaR1C1 = "=SUMIFS(data[Value],data[" & pvtField_uid & "],R[0]C1,data[indicator],R1C,data[disaggregate],"""",data[categoryOptionComboName],R3C,data[categoryOptionComboName],R4C,data[numeratorDenom],R5C,data[resultTarget],R6C,data[period],R7C)"
                        End If
                        'FY15 Target formulas
                        celltxt = ActiveSheet.Cells(9, i).Text
                        If InStr(1, celltxt, "FY15 Target") Then
                            Cells(11, i).FormulaR1C1 = "=SUMIFS(data[Value],data[indicator],R1C,data[disaggregate],"""",data[categoryOptionComboName],R3C,data[categoryOptionComboName],R4C,data[numeratorDenom],R5C,data[resultTarget],R6C,data[period],R7C)"
                        End If
                    Next i
                End If
            'add formula to sum positives
                If sht = "POPhtctable" Then Cells(11, IndicatorCount).Formula = "=SUM(N11:X11)"
            'format cells & hard code them
                Range(Cells(11, 3), Cells(11, IndicatorCount)).Select
                Selection.NumberFormat = "#,##0"
                Selection.Copy
                Range(Cells(12, 3), Cells(LastRow, IndicatorCount)).Select
                ActiveSheet.Paste
            'sort by PLHIV then SNU name
                If sht = "POPtable" Then
                    'LastRow = Range("A1").CurrentRegion.Rows.Count
                    'IndicatorCount = Range("A1").CurrentRegion.Columns.Count 'find last column
                    colPREV = WorksheetFunction.Match("plhiv_num", DataWkbk.Sheets("POPtable").Range("10:10"), 0)
                    colSNU = WorksheetFunction.Match("snulist", DataWkbk.Sheets("POPtable").Range("10:10"), 0)
                    Range(Cells(10, 1), Cells(LastRow, IndicatorCount)).Select
                    ActiveWorkbook.Worksheets("POPtable").Sort.SortFields.Add Key:=Range( _
                        Cells(11, colPREV), Cells(LastRow, colPREV)), SortOn:=xlSortOnValues, Order:=xlDescending, DataOption:= _
                        xlSortNormal
                    ActiveWorkbook.Worksheets("POPtable").Sort.SortFields.Add Key:=Range( _
                        Cells(11, colSNU), Cells(LastRow, colSNU)), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:= _
                        xlSortNormal
                    With ActiveWorkbook.Worksheets("POPtable").Sort
                        .SetRange Range(Cells(10, 1), Cells(LastRow, IndicatorCount))
                        .Header = xlYes
                        .MatchCase = False
                        .Orientation = xlTopToBottom
                        .SortMethod = xlPinYin
                        .Apply
                    End With
                    'copy snu name over to POPhtctable
                    Range(Cells(11, 1), Cells(LastRow, 2)).Copy
                    Sheets("POPhtctable").Activate
                    Cells(11, 1).Select
                    ActiveSheet.Paste
                    Sheets("POPtable").Activate
                End If
            'select data & copy to data pack
                Range(Cells(9, 1), Cells(LastRow, IndicatorCount)).Select
                Selection.Copy
            'switch to template
                dpWkbk.Activate
            'copy data from pull file to data pack template
                If sht = "POPhtctable" Then Sheets("HTC Indicator Table").Activate
                If sht = "POPtable" Then Sheets("Indicator Table").Activate
                Range("B3").Select
                Selection.PasteSpecial Paste:=xlPasteValues
            'add total to table
                IndicatorCount = IndicatorCount + 2
                Range(Cells(5, 2), Cells(5, IndicatorCount)).Select
                Selection.Insert Shift:=xlDown, CopyOrigin:=xlFormatFromLeftOrAbove
                Range("C5").Select
                ActiveCell.Value = "Total"
                LastRow = Range("A4").CurrentRegion.Rows.Count + 2
                IndicatorCount = Range("D4").CurrentRegion.Columns.Count
                Range(Cells(5, 4), Cells(5, IndicatorCount)).Formula = "=SUBTOTAL(109, D6:D" & LastRow & ")"
                Range(Cells(5, 4), Cells(5, IndicatorCount)).NumberFormat = "#,##0"
            'adjust SUBTOTAL for FY15 Targets (not at SNU Level)
                If sht = "POPtable" Then
                    For i = 2 To IndicatorCount
                        celltxt = ActiveSheet.Cells(3, i).Text
                        If InStr(1, celltxt, "FY15 Target") Then
                        'copy value from first row (not really snu)
                            Cells(5, i).Value = Cells(6, i).Value
                        'set snu rows to 0 since FY15 targets set at national level
                            Range(Cells(6, i), Cells(LastRow, i)).Value = 0
                            'need code
                        End If
                    Next i
                    'remove total from prev and priority SNU
                    Sheets("Indicator Table").Activate
                    INDnames = Array("prevalence_num", "priority_snu")
                    For Each IND In INDnames
                        colIND = WorksheetFunction.Match(IND, dpWkbk.Sheets("Indicator Table").Range("4:4"), 0)
                        Cells(5, colIND).Value = ""
                    Next IND
                End If
            'add filter row
                Range(Cells(6, 2), Cells(6, IndicatorCount)).Select
                Selection.Insert Shift:=xlDown, CopyOrigin:=xlFormatFromLeftOrAbove
                LastRow = LastRow + 1
                Range(Cells(6, 3), Cells(6, IndicatorCount)).Select
                With Selection.Interior
                    .Pattern = xlSolid
                    .PatternColorIndex = xlAutomatic
                    .ThemeColor = xlThemeColorAccent4
                    .TintAndShade = 0.399975585192419
                    .PatternTintAndShade = 0
                End With
                Range(Cells(6, 3), Cells(LastRow, IndicatorCount)).Select
                Selection.AutoFilter
                Range("C6").Select
                With Selection
                    .FormulaR1C1 = "Filter Row"
                    .NumberFormat = ";;;"
                End With
            'wrap headers in table
                Range(Cells(3, 4), Cells(3, IndicatorCount)).WrapText = True
            'add named ranges
                Range(Cells(4, 3), Cells(LastRow, IndicatorCount)).Select
                Application.DisplayAlerts = False
                Selection.CreateNames Top:=True, Left:=False, Bottom:=False, Right:=False
                Application.DisplayAlerts = True
                
            Next sht
            
    'close pull file and delete it
        Application.DisplayAlerts = False
        DataWkbk.Close False
        Application.DisplayAlerts = True
        Kill fname_int
End Sub

Sub yieldFormulas()
    'add in formulas for yields
        Sheets("Indicator Table").Activate
        INDnames = Array("pmtct_eid_yield", "pmtct_stat_yield", "tb_stat_yield", "tx_ret_yield", "tx_ret_u15_yield", "htc_tst_u15_yield", "pre_art_yield", "pre_art_u15_yield")
        For Each IND In INDnames
            If IND = "pmtct_eid_yield" Then
                NUM = "pmtct_eid_pos_12mo"
                DEN = "pmtct_eid_12mo"
            ElseIf IND = "pmtct_stat_yield" Then
                NUM = "pmtct_stat_pos"
                DEN = "pmtct_stat_D"
            ElseIf IND = "tb_stat_yield" Then
                NUM = "tb_stat_pos"
                DEN = "tb_stat"
            ElseIf IND = "tx_ret_yield" Then
                NUM = "tx_ret"
                DEN = "tx_ret_D"
            ElseIf IND = "tx_ret_u15_yield" Then
                NUM = "tx_ret_u15"
                DEN = "tx_ret_u15_D"
            ElseIf IND = "htc_tst_u15_yield" Then
                NUM = "htc_tst_u15_pos"
                DEN = "htc_tst_u15"
            ElseIf IND = "pre_art_yield" Then
                NUM = "tx_curr"
                DEN = "care_curr"
            ElseIf IND = "pre_art_u15_yield" Then
                NUM = "tx_curr_u15"
                DEN = "care_curr_u15"
            Else
            End If
            colIND = WorksheetFunction.Match(IND, ActiveWorkbook.Sheets("Indicator Table").Range("4:4"), 0)
            rcNUM = WorksheetFunction.Match(NUM, ActiveWorkbook.Sheets("Indicator Table").Range("4:4"), 0) - colIND
            rcDEN = WorksheetFunction.Match(DEN, ActiveWorkbook.Sheets("Indicator Table").Range("4:4"), 0) - colIND
            If IND = "pmtct_eid_yield" Then
                Cells(5, colIND).FormulaR1C1 = "=IFERROR((RC[" & rcNUM & "]+RC[" & rcNUM - 1 & "])/ (RC[" & rcDEN & "]+RC[" & rcDEN + 2 & "]),"""")"
            ElseIf IND = "pre_art_yield" Or IND = "pre_art_u15_yield" Then
                Cells(5, colIND).FormulaR1C1 = "=IFERROR(IF(RC[" & rcDEN & "] - RC[" & rcNUM & "]<0,0,(RC[" & rcDEN & "] - RC[" & rcNUM & "])/ RC[" & rcDEN & "]),0)"
            Else
                Cells(5, colIND).FormulaR1C1 = "=IFERROR(RC[" & rcNUM & "]/ RC[" & rcDEN & "],"""")"
            End If
            Cells(5, colIND).Style = "Percent"
            Cells(5, colIND).Copy
            Range(Cells(7, colIND), Cells(LastRow, colIND)).Select
            ActiveSheet.Paste
        Next IND
        
End Sub

Sub setupSNUs()
    'convert SNU priority number to text
        Sheets("Indicator Table").Activate
        prtycolNum = WorksheetFunction.Match("priority_snu", ActiveWorkbook.Sheets("Indicator Table").Range("4:4"), 0)
        For i = 7 To LastRow
            priority = Cells(i, prtycolNum)
            Select Case priority
                Case Is = 0
                    prtype = "NOT DEFINED"
                Case Is = 1
                    prtype = "ScaleUp Sat"
                Case Is = 2
                    prtype = "ScaleUp Agg"
                Case Is = 4
                    prtype = "Sustained"
                Case Is = 5
                    prtype = "Ctrl Supported"
                Case Is = 6
                    prtype = "Sustained Com"
                Case Else
                    prtype = "NOT DEFINED"
            End Select
            Cells(i, prtycolNum).Value = prtype
        Next i
    'add SNU list to summary and targets tab
        Sheets("Summary & Targets").Activate
        Range(Cells(5, 3), Cells(LastRow, 3)).FormulaR1C1 = "='Indicator Table'!RC"
        Range(Cells(4, 3), Cells(LastRow, 3)).Select
        Application.DisplayAlerts = False
        Selection.CreateNames Top:=True, Left:=False, Bottom:=False, Right:=False
        Application.DisplayAlerts = False
        Columns("C:C").ColumnWidth = 20.75
    'add SNU list to cascades tab
        Sheets("Cascade Table").Activate
        Range(Cells(5, 3), Cells(LastRow, 3)).FormulaR1C1 = "='Indicator Table'!RC"
        Columns("C:C").ColumnWidth = 20.75
    'add SNU list, copy default values, and add named range to Entry Table tab
        Sheets("Entry Table").Activate
        EntryIndicatorCount = Range("A4").CurrentRegion.Columns.Count
        Range(Cells(6, 3), Cells(LastRow, 3)).FormulaR1C1 = "='Indicator Table'!RC"
        Range(Cells(7, 4), Cells(7, EntryIndicatorCount)).Select
        Selection.Copy
        Range(Cells(7, 4), Cells(LastRow, EntryIndicatorCount)).Select
        ActiveSheet.Paste
        Range(Cells(4, 3), Cells(LastRow, EntryIndicatorCount)).Select
        Application.DisplayAlerts = False
        Range(Cells(4, 3), Cells(LastRow, EntryIndicatorCount)).Select
        Selection.CreateNames Top:=True, Left:=False, Bottom:=False, Right:=False
        Application.DisplayAlerts = True
        Columns("C:C").ColumnWidth = 20.75
        Range("A1").Select
    'hard code priority levels and add drop down
        Range(Cells(7, 4), Cells(LastRow, 4)).Select
        With Selection
            .Copy
            .PasteSpecial Paste:=xlPasteValues
            .Validation.Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, Operator:= _
            xlBetween, Formula1:="ScaleUp Sat, ScaleUp Agg, Sustained, Ctrl Supported, Sustained Com, Other, NOT DEFINED"
        End With
        
End Sub

Sub setupHTCDistro()
    'add SNU list to HTC distro tab
        Sheets("HTC Data Entry").Activate
        Range(Cells(5, 3), Cells(LastRow, 3)).FormulaR1C1 = "='Indicator Table'!RC"
        Range(Cells(4, 3), Cells(LastRow, 3)).Select
        Application.DisplayAlerts = False
        Selection.CreateNames Top:=True, Left:=False, Bottom:=False, Right:=False
        Application.DisplayAlerts = False
        Columns("C:C").ColumnWidth = 20.75
    'add total for ART to HTC distro tab
        Sheets("HTC Data Entry").Activate
        For i = 5 To 11
            If i = 7 Then i = i + 1
            Cells(5, i).FormulaR1C1 = "=SUBTOTAL(109, R[2]C:R[" & LastRow - 5 & "]C)"
        Next i
        
    'add in extra named ranges
        Sheets("HTC Data Entry").Activate
        Set indRng = Sheets("HTC Data Entry").Range(Cells(5, 5), Cells(LastRow, 5))
        ActiveWorkbook.Names.Add Name:="T_htc_need", RefersTo:=indRng
        Sheets("Summary & Targets").Activate
        indColNum = WorksheetFunction.Match("New on Treatment (other sources: VMMC, TB/HIV, KP, Gen Pop, etc.)", ActiveWorkbook.Sheets("Summary & Targets").Range("4:4"), 0)
        Set indRng = Sheets("Summary & Targets").Range(Cells(5, indColNum), Cells(LastRow, indColNum))
        ActiveWorkbook.Names.Add Name:="T_oth_treat", RefersTo:=indRng
End Sub

Sub lookupsumFormulas()
    Dim colStart As Integer
    'add formulas for cascades
        Sheets("Cascade Table").Activate
        INDnames = Array("Estimated Number of PLHIV, end of FY16", "Estimated Number of PLHIV, end of FY17", "Estimated Number of PLHIV (<15), end of FY16", "Estimated Number of PLHIV (<15), end of FY17", "FY17 Target CARE_CURR", "FY17 Target TX_CURR", "FY17 Target CARE_CURR <15", "FY17 Target TX_CURR <15")
        For Each IND In INDnames
            i = WorksheetFunction.Match(IND, dpWkbk.Sheets("Cascade Table").Range("3:3"), 0) ' find first column where formula is needed
            colIND = WorksheetFunction.Match(IND, dpWkbk.Sheets("Summary & Targets").Range("4:4"), 0)
            Cells(7, i).FormulaR1C1 = "='Summary & Targets'!RC[" & colIND - i & "]"
        Next IND
    'copy lookup formulas to all SNUs
        shtNames = Array("HTC Data Entry", "Cascade Table", "Summary & Targets")
        For Each sht In shtNames
            Sheets(sht).Select
            LastSumColumn = Sheets(sht).Range("A2").CurrentRegion.Columns.Count
            Range(Cells(7, 4), Cells(7, LastSumColumn)).Select
            Selection.Copy
            For i = 8 To LastRow
                Range(Cells(i, 4), Cells(i, LastSumColumn)).Select
                ActiveSheet.Paste
            Next i
        Next sht
    'add formula to totals
        shtNames = Array("Cascade Table", "Summary & Targets")
        LastRowRC = LastRow - 5
        For Each sht In shtNames
            Sheets(sht).Select
            If sht = "Summary & Targets" Then
                colStart = 6
            Else
                colStart = 4
            End If
            For i = colStart To LastSumColumn
                If ActiveSheet.Cells(4, i).Value <> "" Then
                    Cells(5, i).Select
                    Selection.FormulaR1C1 = "=SUBTOTAL(109, R[1]C:R[" & LastRowRC & "]C)"
                    Selection.NumberFormat = "#,##0"
                End If
                If ActiveSheet.Cells(7, i).Style = "Percent" Then Cells(5, i).Value = ""
                If ActiveSheet.Cells(4, i).Value = "ART Coverage" Or ActiveSheet.Cells(4, i).Value = "ART Coverage (<15)" Then
                   Cells(7, i).Copy
                   Cells(5, i).Select
                   ActiveSheet.Paste
                End If
                   
            Next i
        Next sht
End Sub
    
    
Sub format()
    'format
      shtNames = Array("Indicator Table", "Entry Table", "HTC Data Entry", "HTC Indicator Table", "Cascade Table", "Summary & Targets")
        For Each sht In shtNames
        Sheets(sht).Select
        LastSumColumn = Sheets(sht).Range("A2").CurrentRegion.Columns.Count
        'format - color Navigation pane (column A)
            Range(Cells(5, 1), Cells(LastRow, 1)).Select
            With Selection.Interior
                .Pattern = xlSolid
                .PatternColorIndex = xlAutomatic
                .ThemeColor = xlThemeColorAccent4
                .TintAndShade = 0.399975585192419
                .PatternTintAndShade = 0
            End With
        'format - indented SNUs
            Range(Cells(6, 3), Cells(LastRow, 3)).Select
            Selection.IndentLevel = 1
        'format - banded rows
            With Range(Cells(7, 3), Cells(LastRow, LastSumColumn))
                .Activate
                .FormatConditions.Add xlExpression, Formula1:="=AND($C5<>"""",C$4<>"""",MOD(ROW(),2)=0)"
                With .FormatConditions(1).Interior
                    .Pattern = xlSolid
                    .PatternColorIndex = xlAutomatic
                    .ThemeColor = xlThemeColorAccent4
                    .TintAndShade = 0.799981688894314
                    .PatternTintAndShade = 0
                End With
            End With
            Range("A1").Select
        Next sht
    'format - color headers
        shtNames = Array("HTC Indicator Table", "Indicator Table")
        For Each sht In shtNames
            Sheets(sht).Select
            IndicatorCount = Range("A4").CurrentRegion.Columns.Count 'find last column
            Range(Cells(3, 4), Cells(3, IndicatorCount)).Select
            With Selection.Interior
                .Pattern = xlSolid
                .PatternColorIndex = xlAutomatic
                .ThemeColor = xlThemeColorAccent2
                .TintAndShade = 0
                .PatternTintAndShade = 0
            End With
            Range(Cells(4, 4), Cells(4, IndicatorCount)).Select
            With Selection.Interior
                .Pattern = xlSolid
                .PatternColorIndex = xlAutomatic
                .ThemeColor = xlThemeColorAccent2
                .TintAndShade = 0.399975585192419
                .PatternTintAndShade = 0
            End With
        Next sht

End Sub

Sub showChanges()
    'add conditional formatting to identify changes in table
        shtNames = Array("HTC Indicator Table", "HTC Data Entry", "Entry Table", "Indicator Table")
        For Each sht In shtNames
            Sheets(sht).Select
            Sheets(sht).Copy After:=Sheets(sht)
            If sht = "HTC Indicator Table" Then Sheets(sht & " (2)").Name = "dupHTCTable"
            If sht = "HTC Data Entry" Then Sheets(sht & " (2)").Name = "dupHTCdistTable"
            If sht = "Entry Table" Then Sheets(sht & " (2)").Name = "dupEntryTable"
            If sht = "Indicator Table" Then Sheets(sht & " (2)").Name = "dupTable"
            Range(Cells(3, 4), Cells(LastRow, IndicatorCount)).Select
            If sht <> "HTC Data Entry" Then
                Selection.Copy
                Selection.PasteSpecial Paste:=xlPasteValues
            End If
            Range("A1").Select
            Sheets(sht).Select
            Range("C5").Select
            If sht = "HTC Data Entry" Then
                Range(Cells(5, 13), Cells(LastRow, IndicatorCount)).Select
            Else
                Range(Cells(5, 4), Cells(LastRow, IndicatorCount)).Select
            End If
            If sht <> "Entry Table" Then
                With Selection
                    .Activate
                    If sht = "HTC Indicator Table" Then .FormatConditions.Add xlExpression, Formula1:="=D5<>dupHTCTable!D5"
                    If sht = "HTC Data Entry" Then .FormatConditions.Add xlExpression, Formula1:="=M5<>dupHTCdistTable!M5"
                    If sht = "Indicator Table" Then .FormatConditions.Add xlExpression, Formula1:="=D5<>dupTable!D5"
                    .FormatConditions(2).Interior.ThemeColor = xlThemeColorAccent3
                    .FormatConditions(2).priority = 1
                End With
            End If
            Range("C3").Select
            If sht = "HTC Data Entry" Then
                'highlight where distribution <>100%
                Range(Cells(5, 12), Cells(LastRow, 12)).Select
                With Selection
                    .Activate
                    .FormatConditions.Add xlExpression, Formula1:="=L5<>1"
                    .FormatConditions(2).Font.Color = -16777024
                    .FormatConditions(2).Font.TintAndShade = 0
                    .FormatConditions(2).priority = 1
                End With
                'hide zero values
                Range(Cells(7, 12), Cells(LastRow, IndicatorCount)).Select
                With Selection
                    .Activate
                    .FormatConditions.Add xlExpression, Formula1:="=AND(L7=0,MOD(ROW(),2)=1)"
                    .FormatConditions(4).NumberFormat = ";;;"
                    .FormatConditions(4).priority = 1
                    .FormatConditions.Add xlExpression, Formula1:="=AND(L7=0,MOD(ROW(),2)=0)"
                    With .FormatConditions(5).Interior
                        .Pattern = xlSolid
                        .PatternColorIndex = xlAutomatic
                        .ThemeColor = xlThemeColorAccent4
                        .TintAndShade = 0.799981688894314
                        .PatternTintAndShade = 0
                    End With
                    .FormatConditions(5).NumberFormat = ";;;"
                    .FormatConditions(5).priority = 1
                    'add blank line between sections for HTC Data Entry
                    .FormatConditions.Add xlExpression, Formula1:="=L$4=0"
                    With .FormatConditions(6).Interior
                        .Pattern = xlNone
                        .TintAndShade = 0
                        .PatternTintAndShade = 0
                    End With
                    .FormatConditions(6).priority = 1
                End With
            End If
            Range("C3").Select
        Next sht
    'hide duplicates
        Sheets(Array("dupTable", "dupHTCTable", "dupEntryTable", "dupHTCdistTable")).Visible = False
End Sub

Sub extlData()
    'add WHO TB numbers into cascade
        tmplWkbk.Activate
        Sheets("POPref").Select
        Range(Cells(ou_i, 9), Cells(ou_i, 12)).Copy
        dpWkbk.Activate
        Sheets("PEPFAR Cascades").Select
        Range("AR24").Select
        Selection.PasteSpecial Paste:=xlPasteValues
        For i = 0 To 3
            Range("AR24").Offset(0, i).Select
            tb_val = Selection.Value
            Selection.Formula = "=IF($A$3<>""Total"","""",IF($A$5<>""FY15 Results"",""""," & tb_val & "))"
        Next i
End Sub

Sub filters()
    'add filter rows
        shtNames = Array("Entry Table", "Summary & Targets", "Cascade Table", "HTC Data Entry")
        For Each sht In shtNames
            Sheets(sht).Select
            IndicatorCount = Range("A2").CurrentRegion.Columns.Count
            Range(Cells(6, 3), Cells(6, IndicatorCount)).Select
                With Selection.Interior
                    .Pattern = xlSolid
                    .PatternColorIndex = xlAutomatic
                    .ThemeColor = xlThemeColorAccent4
                    .TintAndShade = 0.399975585192419
                    .PatternTintAndShade = 0
                End With
                Range(Cells(6, 3), Cells(LastRow, IndicatorCount)).Select
                Selection.AutoFilter
                Range("C6").NumberFormat = ";;;"
                Range("B1").Select
        Next sht
End Sub

Sub dimDefault()

    'conditional formatting - hide if manual entry values equal default
        Sheets("Entry Table").Select
        IndicatorCount = Range("A2").CurrentRegion.Columns.Count
        Range(Cells(7, 6), Cells(LastRow, IndicatorCount)).Select
        With Selection
            .Activate
            .FormatConditions.Add xlExpression, Formula1:="=OR(F7=F$5,AND(F$5="""",F7=dupEntryTable!F7))"
            .FormatConditions(2).Font.ThemeColor = xlThemeColorDark1
            .FormatConditions(2).Font.TintAndShade = -0.499984740745262
            .FormatConditions(2).Interior.Pattern = xlNone
            .FormatConditions(2).Interior.TintAndShade = 0
            .FormatConditions(2).Interior.PatternTintAndShade = 0
            .FormatConditions(2).priority = 1
        End With
        With Range(Cells(7, 6), Cells(LastRow, IndicatorCount))
            .Activate
            .FormatConditions.Add xlExpression, Formula1:="=OR(AND(F7=F$5,MOD(ROW(),2)=0),AND(F$5="""",F7=dupEntryTable!F7,MOD(ROW(),2)=0))"
            With .FormatConditions(3).Font
                .ThemeColor = xlThemeColorDark1
                .TintAndShade = -0.499984740745262
            End With
            With .FormatConditions(3).Interior
                .Pattern = xlSolid
                .PatternColorIndex = xlAutomatic
                .ThemeColor = xlThemeColorAccent4
                .TintAndShade = 0.799981688894314
                .PatternTintAndShade = 0
            End With
            .FormatConditions(3).priority = 1
        End With
        Range("B1").Select
End Sub

Sub updatePBAC()
'update formula with last row in PBAC output (formulas with cell references
    Dim r As Integer
    'loop over columns, check for formula, then loop over rows
        Sheets("PBAC Output").Activate
        For i = 11 To 26
        If Len(Trim(Cells(5, i).Value)) > 0 Then
            For r = 5 To 9
                celltxt = ActiveSheet.Cells(r, i).Formula
                celltxt = Replace(celltxt, "20", LastRow)
                Cells(r, i).Formula = celltxt
            Next r
        End If
        Next i

End Sub

Sub seperateCascades()
    Dim csdWkbk As Workbook
    Dim nmdrng As Name
    Dim dpbook
    'get workbook name for dp for referencing in formula
        dpbook = ActiveWorkbook.FullName
    'keep a cascade table output to update de-linked Cascades later on
        Sheets("Cascade Table").Select
        Sheets("Cascade Table").Copy After:=Sheets("Cascade Table")
        Sheets("Cascade Table (2)").Name = "Cascade Output"
    'Move cascades
        Sheets(Array("Home", "PEPFAR Cascades", "PEPFAR Supplemental Cascades", "Cascade Table", "Indicator Table")).Copy
        Sheets("Home").Select
        Range("P1").Value = "COP 16 Cascades"
        On Error Resume Next
        ActiveWorkbook.Theme.ThemeColorScheme.Load ("C:\Program Files (x86)\Microsoft Office\Document Themes 14\Theme Colors\Adjacency.xml")
        Set csdWkbk = ActiveWorkbook
    'hard copy values into tables
        Sheets("Cascade Table").Activate
        IndicatorCount = Range("A2").CurrentRegion.Columns.Count
        Range(Cells(7, 3), Cells(LastRow, IndicatorCount)).Select
        Selection.Copy
        Selection.PasteSpecial Paste:=xlPasteValues
        Range("C5").Value = "Total"
        Range("C6").Value = "" 'remove text ("Filter Row" for dropdown)
        Range("B2").Select
        Sheets("PEPFAR Supplemental Cascades").Activate
        Range("H23:S26").Select
        Selection.Copy
        Selection.PasteSpecial Paste:=xlPasteValues
        Range("B2").Select
    'remove indicator tab and named ranges that link to DP
        Application.DisplayAlerts = False
        Sheets("Indicator Table").Delete
        Application.DisplayAlerts = True
        On Error Resume Next
        For Each nmdrng In csdWkbk.Names
            nmdrng.Delete
        Next
        On Error GoTo 0
    'add named ranges
        Sheets("Cascade Table").Activate
        Range(Cells(4, 3), Cells(LastRow, IndicatorCount)).Select
        Application.DisplayAlerts = False
        Selection.CreateNames Top:=True, Left:=False, Bottom:=False, Right:=False
        Application.DisplayAlerts = True
        Range("B1").Select
    'add data validation drop down to cascade tab
        Sheets("PEPFAR Cascades").Activate
        Range("A3").Select
        With Selection.Validation
            .Delete
            .Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, Operator:= _
            xlBetween, Formula1:="=Csnulist"
        End With
    'save Cascades
        Sheets("Home").Activate
        fname_csd = OUcompl_fldr & OpUnit_ns & "COP16Cascadesv" & VBA.format(Now, "yyyy.mm.dd") & ".xlsx"
        Application.DisplayAlerts = False
        ActiveWorkbook.SaveAs fname_csd
        ActiveWorkbook.Close
        Application.DisplayAlerts = False
    'remove tabs from Data Pack
        Application.DisplayAlerts = False
        dpWkbk.Activate
        Sheets(Array("PEPFAR Cascades", "PEPFAR Supplemental Cascades", "Cascade Table")).Delete
        Application.DisplayAlerts = True
End Sub

Sub seperateSDS()
    Dim sdsWkbk As Workbook
    Dim fname_sds As String
    'Move cascades
        Sheets(Array("Home", "SDS")).Copy
        Sheets("Home").Select
        Range("P1").Value = "COP 16 SDS Tables"
        On Error Resume Next
        ActiveWorkbook.Theme.ThemeColorScheme.Load ("C:\Program Files (x86)\Microsoft Office\Document Themes 14\Theme Colors\Adjacency.xml")
        Set sdsWkbk = ActiveWorkbook
    'save SDS workbook
        Sheets("Home").Activate
        fname_sds = OUcompl_fldr & OpUnit_ns & "COP16SDSTablesv" & VBA.format(Now, "yyyy.mm.dd") & ".xlsx"
        Application.DisplayAlerts = False
        ActiveWorkbook.SaveAs fname_sds
        ActiveWorkbook.Close
        Application.DisplayAlerts = False
    'remove tab from Data Pack
        Application.DisplayAlerts = False
        dpWkbk.Activate
        Sheets("SDS").Delete
        Application.DisplayAlerts = True
End Sub


Sub saveFile()
    'save
        Sheets("Home").Activate
        Range("X1").Select
        'record run time
        With Selection
            .Value = "Start"
            .Offset(0, 1).Value = startTIME
            .Offset(1, 0).Value = "End"
            .Offset(1, 1).Value = VBA.format(Now, "hh:nn AM/PM")
            .Offset(2, 0).Value = "Run time"
            .Offset(2, 1).FormulaR1C1 = "=R[-1]C - R[-2]C"
        End With
        Range("Z1").Select
        fname_dp = OUcompl_fldr & OpUnit_ns & "COP16" & outputFile & "v" & VBA.format(Now, "yyyy.mm.dd") & ".xlsx"
        If military = "Yes" Then fname_dp = OUcompl_fldr & OpUnit_ns & "MilCOP16" & outputFile & "v" & VBA.format(Now, "yyyy.mm.dd") & ".xlsx"
        Application.DisplayAlerts = False
        ActiveWorkbook.SaveAs fname_dp
    ' record file size
        fsize_dp = VBA.format(FileLen(ActiveWorkbook.FullName) / 1000, "#,##0")
    'keep data pack open?
        If view = "Yes" Then
            dpWkbk.Activate
        Else
            ActiveWorkbook.Close
        End If
        Application.DisplayAlerts = True
End Sub

''''''''''''''''''''
''     DREAMS     ''
''''''''''''''''''''

Sub setupDREAMS()
    'Define SNUs
        tmplWkbk.Activate
        Sheets("POPref").Select
        totSNUs = Cells(ou_i, 14).Value
        Sheets("POPdreamsSNUs").Select
        IndicatorCount = WorksheetFunction.Match(OpUnit, ActiveWorkbook.Sheets("POPdreamsSNUs").Range("1:1"), 0)
        Set selectedSNUs = Sheets("POPdreamsSNUs").Range(Cells(4, IndicatorCount), Cells(totSNUs + 3, IndicatorCount))
    'Copy sheets over to data file
        tmplWkbk.Activate
        Sheets(Array("Home", "DREAMS Table")).Select
        Sheets(Array("Home", "DREAMS Table")).Copy Before:=DataWkbk.Sheets(1)
        'On Error Resume Next
        ActiveWorkbook.Theme.ThemeColorScheme.Load ("C:\Program Files (x86)\Microsoft Office\Document Themes 14\Theme Colors\Adjacency.xml") 'setup home page
       Sheets("Home").Range("N1").Select
       Range("N1").Copy
       Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks _
        :=False, Transpose:=False
       Range("O1").Value = OpUnit
       Range("P1").Value = "COP 16 DREAMS TARGETING"
       Range("AA1").Select
    'add SNUs
        Sheets("DREAMS Table").Select
    'find last column used
        LastColumnDREAMS = totSNUs * 8 + 11
End Sub

Sub loadDREAMS()
    Dim snu
    'insert formulas
        For i = 5 To 81
            Range("P" & i).Select
            If Range("G" & i).Value = "M" Then
                Range(Cells(i, 8), Cells(i, 11)).FormulaR1C1 = "=SUMIF(R4C[8]:R4C" & LastColumnDREAMS & ",R4C,RC16:RC" & LastColumnDREAMS & ")"
                Selection.FormulaR1C1 = "=SUM(SUMIFS(data[Value],data[" & pvtField & "],R2C,data[indicator],RC3,data[categoryOptionComboName],RC4,data[categoryOptionComboName],{""* Male*"",""*(Male*""},data[resultTarget],""RESULT"",data[numeratorDenom],""N""))"
                Selection.Offset(0, 1).FormulaR1C1 = "=SUM(SUMIFS(data[Value],data[" & pvtField & "],R2C,data[indicator],RC3,data[categoryOptionComboName],RC4,data[categoryOptionComboName],{""* Male*"",""*(Male*""},data[resultTarget],""TARGET"",data[numeratorDenom],""N""))"
                Selection.Offset(0, 2).Value = 0
                Selection.Offset(0, 3).Value = 0
            ElseIf Range("G" & i).Value = "F" Then
                Range(Cells(i, 8), Cells(i, 11)).FormulaR1C1 = "=SUMIF(R4C[8]:R4C" & LastColumnDREAMS & ",R4C,RC16:RC" & LastColumnDREAMS & ")"
                Selection.FormulaR1C1 = "=SUM(SUMIFS(data[Value],data[" & pvtField & "],R2C,data[indicator],RC3,data[categoryOptionComboName],RC4,data[categoryOptionComboName],RC5,data[resultTarget],""RESULT"",data[numeratorDenom],""N""))"
                Selection.Offset(0, 1).FormulaR1C1 = "=SUM(SUMIFS(data[Value],data[" & pvtField & "],R2C,data[indicator],RC3,data[categoryOptionComboName],RC4,data[categoryOptionComboName],RC5,data[resultTarget],""TARGET"",data[numeratorDenom],""N""))"
                Selection.Offset(0, 2).Value = 0
                Selection.Offset(0, 3).Value = 0
            ElseIf Range("G" & i).Value = "T" Then
                Range(Cells(i, 8), Cells(i, 11)).FormulaR1C1 = "=SUM(R[1]C:R[6]C)"
                Range(Cells(i, 16), Cells(i, 19)).FormulaR1C1 = "=SUM(R[1]C:R[6]C)"
            ElseIf Range("G" & i).Value = "T2" Then
                Range(Cells(i, 8), Cells(i, 11)).FormulaR1C1 = "=SUM(R[1]C:R[4]C)"
                Range(Cells(i, 16), Cells(i, 19)).FormulaR1C1 = "=SUM(R[1]C:R[4]C)"
            Else
            End If
        Next i
    'copy table for each SNU
        totSNUs = totSNUs - 1
        Range(Cells(1, 12), Cells(81, 19)).Copy
        Cells(1, 12).Select
        For i = 1 To totSNUs
            Selection.Offset(0, 8).Select
            ActiveSheet.Paste
        Next i
    'add SNU name
        Range("F1").Select
        For Each snu In selectedSNUs
            Selection.Offset(0, 3).Select
            Selection.Value = snu
        Next snu
End Sub

Sub cleanupDREAMS()
    Dim col
    'hard copy data in
        For col = 16 To LastColumnDREAMS
            If Cells(2, col).Value <> "" Then
                For i = 5 To 81
                    If Range("O" & i).Value = "M" Or Range("O" & i).Value = "F" Then
                        Cells(i, col).Select
                        Selection.Copy
                        Selection.PasteSpecial Paste:=xlPasteValues
                    End If
                Next i
            End If
        Next col
                        
    'remove extra tabs
        Application.DisplayAlerts = False
        Sheets("rawdata").Delete
        Application.DisplayAlerts = True
    'delete 3 hidden columns
        Columns(3).Delete
        Columns(3).Delete
        Columns(3).Delete
    'insert new column
        Columns(1).Insert
        With Range(Cells(1, 1), Cells(81, 1)).Interior
            .Pattern = xlSolid
            .PatternColorIndex = xlAutomatic
            .ThemeColor = xlThemeColorAccent4
            .TintAndShade = 0.399975585192419
            .PatternTintAndShade = 0
        End With
        Columns("A:A").ColumnWidth = 12.86
        Range("B1").Select
End Sub


''''''''''''''''''''
''     Yields     ''
''''''''''''''''''''

Sub pvtSites()
    Dim pf As PivotField
    Dim pvtField_ou
            
    'pull SNU list via pivot table
       pvtField = "orgLevel" & siteLevel & "Name"
       pvtField_uid = "uidlevel" & siteLevel
       pvtField_ou = "orgLevel4Name" 'used for regional programs
    'pull SNU list via pivot table
       Sheets("rawdata").Activate
       Range("A2").Select
       Sheets.Add.Name = "pt"
       ActiveWorkbook.PivotCaches.Create(SourceType:=xlDatabase, SourceData:= _
           "data", version:=xlPivotTableVersion14).CreatePivotTable TableDestination _
           :="pt!R3C1", TableName:="SITEList", DefaultVersion:= _
           xlPivotTableVersion14 'insert pivot table
       Sheets("pt").Cells(3, 1).Select
       On Error Resume Next
       With ActiveSheet.PivotTables("SITEList")
           .RowAxisLayout xlTabularRow 'setup pivot table as tabular
           .PivotFields(pvtField_uid).Orientation = xlRowField
           .PivotFields(pvtField_uid).Position = 1 'add list of UIDs for SNUs
           .PivotFields(pvtField).Orientation = xlRowField
           .PivotFields(pvtField).Position = 2 'add list of SNUs
           .PivotFields(pvtField).PivotItems("NULL").Visible = False 'remove NULL
           .PivotFields(pvtField).PivotItems("(blank)").Visible = False 'remove blanks
           .ColumnGrand = False
           .RowGrand = False
       End With
       'Remove subtotals (by contextures.com)
        On Error Resume Next
        For Each pf In ActiveSheet.PivotTables("SITEList").PivotFields
        'First, set index 1 (Automatic) to True,
        'so all other values are set to False
            pf.Subtotals(1) = True
            pf.Subtotals(1) = False
        Next pf
       ActiveSheet.PivotTables("SITEList").DisplayFieldCaptions = False
       Range("A3:B3").Select
       Range(Selection, Selection.End(xlDown)).Select
       uniqueTot = Sheets("pt").Cells(4, 1).CurrentRegion.Rows.Count - 1 'account for text in A1
       ActiveWorkbook.Names.Add Name:="site_unique", RefersToR1C1:=uniqueTot
       Selection.Copy
       Sheets("POPyieldtable").Select
       Range("A11").Select
       Selection.PasteSpecial Paste:=xlPasteValues
End Sub

Sub dataFormulasYields()
    'insert formulas
        DataWkbk.Activate
    'Sheets(sht).Select
        IndicatorCount = Range("A1").CurrentRegion.Columns.Count 'find last column
        LastRow = Range("A1").CurrentRegion.Rows.Count 'find last row
    'add basic formula
        Range(Cells(11, 3), Cells(11, IndicatorCount)).FormulaR1C1 = "=SUMIFS(data[Value],data[" & pvtField_uid & "],R[0]C1,data[indicator],R1C,data[disaggregate],R2C,data[categoryOptionComboName],R3C,data[categoryOptionComboName],R4C,data[numeratorDenom],R5C,data[resultTarget],R6C)"
    'add array formula for indicators that need it
        For i = 2 To IndicatorCount
            celltxt = ActiveSheet.Cells(3, i).Text
            If InStr(1, celltxt, "(default)") Then
                Cells(11, i).FormulaR1C1 = "=SUMIFS(data[Value],data[" & pvtField_uid & "],R[0]C1,data[indicator],R1C,data[disaggregate],"""",data[categoryOptionComboName],R3C,data[categoryOptionComboName],R4C,data[numeratorDenom],R5C,data[resultTarget],R6C,data[period],R7C)"
            End If
        Next i
    'format cells & hard code tbhem
       Range(Cells(11, 3), Cells(11, IndicatorCount)).Select
        Selection.NumberFormat = "#,##0"
        Selection.Copy
        Range(Cells(12, 3), Cells(LastRow, IndicatorCount)).Select
        ActiveSheet.Paste
    'select data & copy to data pack
        Range(Cells(9, 1), Cells(LastRow, IndicatorCount)).Select
        Selection.Copy
    'switch to template
        yldWkbk.Activate
    'copy data from pull file to data pack template
        Sheets("Indicator Table").Activate
        Range("B3").Select
        Selection.PasteSpecial Paste:=xlPasteValues
End Sub

Sub setupYieldsTables()
    'copy uid for maping
        LastRow = Range("C4").CurrentRegion.Rows.Count + 2 'find last row
        Range(Cells(4, 2), Cells(LastRow, 3)).Copy
        Sheets.Add.Name = "SiteUID"
        Range("B2").Select
        Selection.PasteSpecial Paste:=xlPasteValues
        ActiveWindow.DisplayGridlines = False
    'format
        Columns("B:B").EntireColumn.AutoFit
        Columns("C:C").EntireColumn.AutoFit
        Range("B2").FormulaR1C1 = "UID"
        Range("C2").FormulaR1C1 = "SITE"
        Range("B2:C2").Select
        Selection.Font.Bold = True
        With Selection.Interior
            .Pattern = xlSolid
            .PatternColorIndex = xlAutomatic
            .ThemeColor = xlThemeColorAccent2
            .TintAndShade = 0
            .PatternTintAndShade = 0
        End With
    'hide sheet
        Range("A1").Select
        Sheets("SiteUID").Visible = False
        Sheets("Indicator Table").Activate
    'copy data to yields tables
        For i = 1 To 3
             IndicatorCount = Range("C4").CurrentRegion.Columns.Count 'find last column
             Range(Cells(4, 4), Cells(LastRow, IndicatorCount)).NumberFormat = "#,##0"
             Range(Cells(4, 2), Cells(LastRow, IndicatorCount)).Select
             Sheets("Indicator Table").Sort.SortFields.Clear
             Sheets("Indicator Table").Sort.SortFields.Add Key:=Range( _
                 "D5:D" & LastRow), SortOn:=xlSortOnValues, Order:=xlDescending, DataOption:= _
                 xlSortNormal
             With ActiveWorkbook.Worksheets("Indicator Table").Sort
                 .SetRange Range(Cells(4, 2), Cells(LastRow, IndicatorCount))
                 .Header = xlYes
                 .MatchCase = False
                 .Orientation = xlTopToBottom
                 .SortMethod = xlPinYin
                 .Apply
             End With
             If i <> 3 Then
                  Range(Cells(5, 3), Cells(LastRow, 5)).Select
             Else
                  Range(Cells(5, 3), Cells(LastRow, 4)).Select
             End If
             Selection.Copy
             Sheets("Yield Figures").Select
             If i = 1 Then Range("C24").Select
             If i = 2 Then Range("L24").Select
             If i = 3 Then Range("U24").Select
             ActiveSheet.Paste
             If i <> 3 Then
                  Sheets("Indicator Table").Select
                  Columns(4).EntireColumn.Delete
                  Columns(4).EntireColumn.Delete
             Else
                  Application.DisplayAlerts = False
                  Sheets("Indicator Table").Delete
                  Application.DisplayAlerts = True
             End If
        Next i
        
        Range("B1").Select
        Sheets("Home").Select
End Sub

Sub cleanYields()
    Dim tblrows As String
    Dim tbl As ListObject
    Dim tblnames
    Dim tn
    Dim j As Integer
    
    Sheets("Yield Figures").Select
    LastRow = Range("B1").CurrentRegion.Rows.Count
    tblnames = Array("htcTable", "pmtctTable", "artTable")
        j = 5 'column
    For Each tn In tblnames
        If tn = "htcTable" Then j = 5 'column
        If tn = "pmtctTable" Then j = 13
        If tn = "artTable" Then j = 22
        Set tbl = ActiveSheet.ListObjects(tn)
        tblrows = tbl.Range.Rows.Count - 1
        tbl.Sort.SortFields.Clear
        If tn = "htcTable" Then
            tbl.Sort. _
            SortFields.Add Key:=Range(tbl & "['# Tested]"), SortOn:=xlSortOnValues, _
            Order:=xlDescending, DataOption:=xlSortNormal
            With tbl.Sort
                .Header = xlYes
                .MatchCase = False
                .Orientation = xlTopToBottom
                .SortMethod = xlPinYin
                .Apply
            End With
        End If
        If tn = "htcTable" Then
             For i = 25 To LastRow
                If Cells(i, j) = 0 Then
                    tblrows = i - 23 & ":" & tblrows
                    [htcTable].Rows(tblrows).Delete
                    tbl.Sort.SortFields.Clear
                    tbl.Sort. _
                        SortFields.Add Key:=Range(tbl & "['# Positive]"), SortOn:=xlSortOnValues _
                        , Order:=xlDescending, DataOption:=xlSortNormal
                        With ActiveWorkbook.Worksheets("Yield Figures").ListObjects("htcTable").Sort
                            .Header = xlYes
                            '.MatchCase = False
                            .Orientation = xlTopToBottom
                            .SortMethod = xlPinYin
                            .Apply
                        End With
                    Exit For
                End If
            Next i
        ElseIf tn = "pmtctTable" Then
            For i = 25 To LastRow
                If Cells(i, j) = 0 And Cells(i, j + 1) = 0 Then
                    tblrows = i - 23 & ":" & tblrows
                    [pmtctTable].Rows(tblrows).Delete
                    Exit For
                End If
            Next i
        ElseIf tn = "artTable" Then
            For i = 25 To LastRow
                If Cells(i, j) = 0 Then
                    tblrows = i - 23 & ":" & tblrows
                    [artTable].Rows(tblrows).Delete
                    Exit For
                End If
            Next i
        End If
    Next tn
   
    Range("B1").Select
    Sheets("Home").Select
    
End Sub

Sub saveFileYields()
    'close pull file and delete it
        If military <> "Yes" Then
            Application.DisplayAlerts = False
            DataWkbk.Close False
            Application.DisplayAlerts = True
        End If
    'save
        Sheets("Home").Activate
        Application.DisplayAlerts = False
        fname_dp = OUcompl_fldr & OpUnit_ns & "COP16" & outputFile & "v" & VBA.format(Now, "yyyy.mm.dd") & ".xlsx"
        If military = "Yes" Then
            Sheets("Indicator Table").Delete
            fname_dp = OUcompl_fldr & OpUnit_ns & "MilCOP16" & outputFile & "v" & VBA.format(Now, "yyyy.mm.dd") & ".xlsx"
        End If
        ActiveWorkbook.SaveAs fname_dp
        If view = "Yes" Then
            yldWkbk.Activate
        Else
            ActiveWorkbook.Close
        End If
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
    
        strDate = VBA.format(Now, "yyyy.mm.dd")
        FileNameZip = DefPath & OpUnit_ns & strDate & ".zip"
        If military = "Yes" Then FileNameZip = DefPath & OpUnit_ns & "Mil" & strDate & ".zip"
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

    'delete unzipped folder
        If Right(OUcompl_fldr, 1) <> "\" Then OUcompl_fldr = OUcompl_fldr & "\"
        Kill OUcompl_fldr & "*.*"
        RmDir OUcompl_fldr
        
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


