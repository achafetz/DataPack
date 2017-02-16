### Target Compiler Tool


The Site and Disaggregate Tool, new this COP cycle, allows teams to take the district targets and allocate them down to the site level. To do so, the site tool needs to draw on the targets created in the Data Pack. Since there site tool was created after the distribution of the data pack, there is no output tab as there is for the PBAC that puts all the targets in one place and updates automatically as inputs are adjusted in the Data Pack.

Rather than having to manually search for the 23 columns needed for the site and disaggregate tool and copy them one by one from one spreadsheet to the other, we have created a macro in Excel that automatically does all this for you in one fell swoop in an Excel file called the target Compiler Tool.

In order to move the targets, you’ll need three things:
- the final Data Pack for your OU
- the Site and Disagg Tool (found on your country's PEPFAR.net page)
- [the Target Compiler Tool](https://www.pepfarii.net/OGAC-HQ/icpi/Shared%20Documents/Forms/AllItems.aspx?RootFolder=%2FOGAC%2DHQ%2Ficpi%2FShared%20Documents%2FWORKSTREAMS%2FData%20Pack%2FCOP17%20DP%20Target%20Compiler&InitialTabId=Ribbon%2EDocument&VisibilityContext=WSSTabPersistence)

It’s not necessary, but probably best practice to start by closing out all our Excel files.

Next open the Target Compiler Tool and hit the run button (you may be given some prompts when you start up this file warning you that the file contains a macro and to activate the file).

After hitting the run button, you will be promoted to do two things – tell the tool where the Data Pack file is located and then to do the same for the Site and Disaggregate Tool. And that’s it! The macro will then run, moving your targets from the Data Pack’s Target Calculation tab over to the Site and Disagg Tool’s Data Pack SNU Targets tab.

The tool will hard code the targets in to your Site and Disaggregate tool. This fact is important to recognize since any time you make changes in the Data Pack, you should rerun the Target Compiler Tool. For this reason, it's best to wait until your Data Pack targets are finalized, or nearly finalized, to work with the site allocations in the Site and Disaggregates Tool.

The Target Compiler works by searching the Target Calculation tab in the Data Pack for the same column header in the table in the Data Pack SNU Targets tab of the Site and Disaggregate Tool. So, if you have changed the names of any of these, you’ll get red text in row 7 of that column explaining you should adjust your column header to match what is in the Data Pack.
