The input files used to populate the datapack originate from two ICPI Fact View Datasets - (1) IM by PSNU and (2) NAT_SUBNAT. The two files can be found on PEPFAR.net (Home >HQ >Interagency Collaborative for Program Improvement (ICPI) >Shared Documents >ICPI Data Store >MER >ICPI Fact View) 

Due to file size, these files have been saved in a central location on my local machine rather than in the RawData folder in this directory. To run the `01_datapack_output.do`, you will need to adjust the `fvdata` global macro in  `00_datapack_initialize.do` to reflect the folder path on your machine. 
