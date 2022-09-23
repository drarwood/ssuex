# ssuex
**Developer: Andrew R Wood (a.r.wood@exeter.ac.uk)**

An R package to allocate SSUs for the College of Medicine and Health at the University of Exeter

### A. Obtaining and loading ssuex
First, you must download the R package from this GitHub repos which can be done using the devtools library. If you do not already have devtools you can install it using:
```
    install.packages("devtools")
```
Once installed, you can use devtools to download and install the R package directly from GitHub
```
    library(devtools)
    install_github("drarwood/ssuex")
```
Now you are ready to load the library in R:
```
    library(ssuex)
```

## B. Inputs

### 1. Student preferences file
This file should be a headed tab delimited file where each line holds student number, last name, first name, and the choices provided by the student:
```
student_number  last_name  first_name  c1      c2      c3      c4
000000001       Adams      Samuel      E2/331  E2/377  E2/174  E2/416
000000002       Angelo     Michael     E2/174  E2/331  E2/416  E2/487
...
```
Note that the headings do not matter, but the ordering of the columns should be as outlined above. Also, any number of columns can be provided for student choices (not just 4). However, you should ensure that all rows contain the same number of columns (tab delimited), even if not filled in the populated in the text file. The code provided is capable of handling missing choices for students as long as the first 3 columns containing information about the student is populated as students that do not provide choices will be randomly allocated to SSUs that allow for random student allocations.


### 2. SSUs file
This file should be a headed tab delimited file where each line holds the unit id, maximum spaces available, and whether students can be randomly allocated to the SSU (Y/N).
```
unit_id  spaces random_allocation
E2/331   6      Y
E2/416   5      Y
...
```
As with the file containing student preferences, the headers of the tab delimited file do not matter but the ordering of the columns should be as outlined above.


### 3. Outfile prefix
This should simply be a string of the prefix of the files you want to generate. The process will generate two files, one defining the allocations while the other summarizes the allocations of the SSUs (see below).



## C. Running ssuex
After loading the ssux library (above), you can type the following:
```
ssuex(sFile = "/path/to/your/student_file.txt", uFile = "/path/to/your/ssu_file.txt", oFile="/path/and/file_prefix")
```
You do not need to specify file paths if you your input and desired output directory are your current working directory in R.


## D. Outputs
After executing the command above, two files will be generated:

#### 1. SSU Allocations File (file_prefix_allocations.txt)

The SSU allocations file will hold the original data in the file containing student SSU preferences plus 2 additional columns:
```
student_number  last_name  first_name  c1      c2      c3      c4      assignment  chosen
000000001       Adams      Samuel      E2/331  E2/377  E2/174  E2/416  E2/331      YES
000000002       Angelo     Michael     E2/174  E2/331  E2/416  E2/487  E2/416      YES
...
```

The `assignment` column contains the assigned SSU for the student. The `chosen` columns contains values "YES" / "NO" depending on whether the allocated SSU is in the list of preferences provided by the student (if at all). If not choices are provided, this is set to "NO".


#### 2. SSU Summary File (file_prefix_ssus.txt)

The SSU summary file contains a summary of the SSUs provided, their capacity, the total number of requests made by all students (`requests`), and the number of students assigned (`count`):
```
unit_code   spaces   random_alloc  requests   count
E2/377      6        Y             28         6
E2/416      6        Y             21         6
...
```
