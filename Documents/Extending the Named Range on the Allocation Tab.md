If you have added rows below the last row on the Allocation by SNUxIM tab in the Data Pack, your totals in row 5 and values the SNU targets tab will not be complete. To adjust this by extending your Named Ranges down, follow the steps below.

Navigate to the Allocation SNUxIM tab in the Data Pack

Open Name Manager (Formulas > Defined Names > Name Manager)

![image](https://user-images.githubusercontent.com/8933069/36595138-b5d2f6de-18a9-11e8-9f82-376a24349244.png)

In the Name Manager, click on the on "Refers To" label at the top to sort by the tabs. 

Select all 230 named ranges from the Allocation by SNUxIM tab in the list and delete them. Close out the window.

![image](https://user-images.githubusercontent.com/8933069/36595331-723088a0-18aa-11e8-9b39-7dea1863dd32.png)

Delete all rows that refer to Allocation by SNUxIM

In the Allocation by SNUxIM tab, select the range C4:HX4, which contains the names associated with each column range.  Next, expand the range down to the bottom of the table all the way down to the last observation. 

![image](https://user-images.githubusercontent.com/8933069/36595539-2f94e706-18ab-11e8-8549-0f6fe18f7005.png)

With the whole range selected, find the 'Create from Selection' in the ribbon (Formulas > Defined Names >Create from Selection) and click on it.

![image](https://user-images.githubusercontent.com/8933069/36595638-9e882664-18ab-11e8-9348-c051cee57092.png)

In the Defined Names option in the ribbon, click , un-select 'Left Column' so that only 'Top Row" is selected and click Okay.
![image](https://user-images.githubusercontent.com/8836685/36594942-4a30e8a4-186e-11e8-9166-c42c3d134279.png)

Fin.
