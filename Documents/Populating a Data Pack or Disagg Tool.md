## Instructions on How to Populate a Data Pack or Disaggregation Tools

### Initial setup
* Almost all the information you need to run the Data Pack or Disagg Tools are located on the [Data Pack repository](https://github.com/achafetz/DataPack) on GitHub. You'll need this repo on you local machine in order to populate the disagg tools
* Since the data pack/disagg tools (and R scripts) get updated frequently, it's best to check to see if you have the most recent files
* Option 1 (recommended): Git client
   * Download Github Desktop or other Git client to your computer (you'll need to have a Github account)
   * Clone the [Data Pack repository](https://github.com/achafetz/DataPack) from GitHub to your computer
   * Note: If you anticipate making any suggested change to the tools or scripts, fork the repo to your GitHub account before you clone it. It will then make it easier to submit pull requests.
* Option 2: Manual Download
   * Go to [Github](https://github.com/achafetz/DataPack)  
   * There is a green button to Clone or download to the right of the screen. Click this and download the repository, storing it in a logical location (eg "~/Documents")

### Generating/storing the underlying Data
* No data is stored on GitHub since it is a public repository.
* There are two options for getting the Data
* Option 1: R scripts
   * You you want to run everything end to end, you will need to have R installed on your machine to run the R Scipts that create Ouputs that feed into the Data Pack/Disagg Tool Templates.
   * Since the data is not stored on GitHub, you will need to download the most recent [Fact View Datasets from PEPFAR SharePoint](https://www.pepfar.net/OGAC-HQ/icpi/Shared%20Documents/Forms/AllItems.aspx?RootFolder=%2FOGAC-HQ%2Ficpi%2FShared%20Documents%2FICPI%20Data%20Store%2FMER&View=%7B94C838B2-E166-4122-B8B4-7BEB9E1BC12B%7D) and store them in a local folder. This can be the RawData folder so long as you do not push the data to Github. You will need all versions of the Fact View - PSNU, OUxIM, and PSNUxIM as well as NAT_SUBNAT
   * In the initialize script ([00_datapack_initialize.R](https://github.com/achafetz/DataPack/blob/master/Scripts/00_datapack_initialize.R)), change the `projectpath` (line 16) to whatever folder that holds the repository as well as `fvdata` to the folder where the Fact View datasets are stored. This initialization script needs to be run every time you start a new instance of R.
   * Running [scripts](https://github.com/achafetz/DataPack/tree/master/Scripts) 01-04 create the datasets that underlie the Data Pack and 11-12 for the Disagg Tools. All scripts can be found in the "~/DataPack/Scripts" folder
* Option 2: Download output files
   * If you are not able to/do not wish to run the R scripts, you can download the R scripts output from [PEPFAR SharePoint](https://www.pepfar.net/OGAC-HQ/icpi/Shared%20Documents/Forms/AllItems.aspx?RootFolder=%2FOGAC-HQ%2Ficpi%2FShared%20Documents%2FWORKSTREAMS%2FData%20Pack%2FDevelopment%2FOutput&FolderCTID=0x012000C815322C717A7E4B8164EA374FA254EC002682B939F9BED347BD49E43D77D3C691&View=%7B94C838B2-E166-4122-B8B4-7BEB9E1BC12B%7D) and store it in the "~/DataPack/Output" folder. Note that this may not always have the most recent output, so it's more reliable to go with Option 1.

### Populating the Data Pack/Disagg Tools
* Now that the folders structure is setup, data is in place, and the R script output has been generated and stored, it's now possible to populate the Data Pack and/or Disaggregation Tools.
* Prior to running any tools, you need to ensure you have the most recent template available on your local machine. If you use a Git client, conduct a pull request to ensure there are no file updates. If instead you downloaded the templates, make sure that the version (date) and time of the templates [stored on GitHub](https://github.com/achafetz/DataPack/tree/master/TemplateGeneration) are not more recent than the templates in your folder ("~/DataPack/TemplateGeneration"). If not, you will need to manually download and replace your local versions.
   * Note: You may need to delete tools prior to the pull request in order to avoid a Git commit issue
* Once you have confirmed or pulled the most up to date tool, you will need to update the file path is updated for your machine. Open the tool you wish to populate to the POPref tab and updated the file path (cell D17) to reflect where the DataPack folder is located. Save the Data Pack/Disaggregation Tool.
* To generate a tool, go to the POPrun tab and click the gold "Run" button.
* You will be promoted to select a few things:
   * OU selection - Select one or multiple (Click + Ctrl, or Click + Shift).
   * Options
      * No selection - Tool populates and is saved to the "~/DataPack/CompletedDataPacks" folder
      * View output - Keep the tool(s) open after it has been generated. It's recommend that you only select this option if you are populating just one tool.
      * Zip folder - Recommended choice. Creates a zipped folder (in addition to a regular folder). This is the file format & naming convention that should be used when uploading to PEPFAR SharePoint
   * Click the "Generate" button after making the selection in the pop up window around countries and viewing/storing.
      * It can take between 20 second to 20 minutes to run a tool depending on the tool type and which country or countries selected as well as the RAM on your local machine.
      * It is recommended that you close our of all other programs and increase your computer's processing to High performance (typically found under the Power Options in the Control Panel).
  * After generating to the tool, have a quick glance through the tabs to ensure there are no glaring errors (eg #NAs), missing data, and the window view is in the upper right hand corner of every tab.

## Final Steps
* After the tool is generated and reviewed, you should upload the file(s) to [PEPFAR SharePoint](https://www.pepfar.net/OGAC-HQ/icpi/Shared%20Documents/Forms/AllItems.aspx?RootFolder=%2FOGAC-HQ%2Ficpi%2FShared%20Documents%2FWORKSTREAMS%2FData%20Pack&View=%7B94C838B2-E166-4122-B8B4-7BEB9E1BC12B%7D) and alert SGAC_SI [at] state.gov that new files for the country or countries are available.
