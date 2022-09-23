#' ssuex: SSU Student Allocations at Exeter University (CMH)
#'
# '\strong{Description}
#' This function allocates SSUs to students based on their preferences.
#' It takes two tab-delimited headed files containing student preferences and
#' information about available SSUs and returns an output file containing the
#' the assigned SSU.
#'
#' @param sFile Tab delimited file with header containing information about students:
#' \code{student number, last name, first name, c1, ..., cN}
#' @param uFile Tab delimited file with header containing information about SSUs:
#' \code{unit code, spaces available, random allowcation allowed}
#' @param oFile Name of output file
#' @return NA
#' @export

ssuex <- function(sFile, uFile, oFile) {


  # STUDENT DATA SETUP #########################################################
  # Read student choices
  #students = read.table("test_files/exeter_students.txt", sep="\t", stringsAsFactors = F, header=T)
  students = read.table(sFile, sep="\t", stringsAsFactors = F, header=T)

  names(students)[1] = "student_number"
  names(students)[2] = "student_last_name"
  names(students)[3] = "student_first_name"

  # Ensure all choices upper-case
  for (i in 4:ncol(students)) {
    students[[i]] = toupper(students[[i]])
  }
  # Create SSU-choice score (based on popularity of ssu choices)
  students$choice_score = 0
  # Create column containing assigned ssu
  students$assignment = NA
  # Create column containing whether preference assigned
  students$chosen = NA
  ##############################################################################


  # SSU DATA SETUP  ############################################################
  # Read data on spaces available for each unit
  #ssus = read.table("test_files/exeter_ssus.txt", sep="\t", stringsAsFactors = F, header=T)
  ssus = read.table(uFile, sep="\t", stringsAsFactors = F, header=T)
  names(ssus)[1] = "unit_code"
  names(ssus)[2] = "spaces"
  names(ssus)[3] = "random_alloc"
  # Ensure upper case for SSU codes
  ssus$unit_code = toupper(ssus$unit_code)
  # Could remove SSUs at this point with spaces = 0 but will keep for purposes of
  # reporting how many assigned to ALL SSUs provided in input file

  # Initiate number of times the SSU has been selected
  ssus$requests = 0
  # initiate number of individuals assigned to unit
  ssus$count = 0
  # Add up the number of requests for each SSU from the students DF
  # cycle through columns 4 onward of student choices
  for (i in 1:nrow(students)) {
    for (j in 4:(ncol(students)-3)) {
      ssu_index = which(ssus$unit_code == students[i,j])
      if (length(ssu_index)==1) {
        ssus$requests[ssu_index] = ssus$requests[ssu_index]+1
      }
    }
  }
  # sort by requests descending
  ssus = ssus[order(-ssus$requests),]
  ##############################################################################


  # Update student choice score ################################################
  for (i in 1:nrow(students)) {
    for (j in 4:(ncol(students)-3)) {
      ssu_index = which(ssus$unit_code == students[i,j])
      if (length(ssu_index)==1) {
        students$choice_score[i]=students$choice_score[i]+ssus$requests[ssu_index]
      }
    }
  }
  # Sort students by their choice score descending.
  students = students[order(-students$choice_score),]
  ##############################################################################


  # Cycle through SSUs in descending order of popularity ########################
  # First iteration should not assign random allocations

  # cycle through SSUs
  for (i in 1:nrow(ssus)) {

    # check ssu capacity >0 and not at capacity
    if (ssus$spaces[i] > 0) {

      # Cycle through students ordered by the overall popularity of their ssu requests
      for (j in 1:nrow(students)) {

        # check student not already assigned
        if (is.na(students$assignment[j])) {

          # cycle through columns 4 onward to check SSU code present
          for (k in 4:(ncol(students)-3)) {

            # check if they have the current SSU code and assign
            if (students[j,k] == ssus$unit_code[i]) {
              students$assignment[j] = ssus$unit_code[i]
              students$chosen[j] = "YES"
              ssus$count[i] = ssus$count[i]+1
              # break out of loop as student assigned to a chosen SSU
              break
            }

          } # finished with student for this first round of SSU allocation

        } # end check student not already assigned. Else do nothing

        # check if we are now at SSU capacity, go to next SSU if so
        if (ssus$count[i] == ssus$spaces[i]) {
          break
        }

      } # end cycle through students

    } # end check spaces available from outset

  } # end SSU cycle
  ##############################################################################


  # At this point, some students may not have been assigned their choice or not
  # provides a choice at all. So we will go through students again and randomly
  # assign to fill up SSUs with capacity.

  # Sort SSU DF by spaces and number of requests (both descending)
  ssus = ssus[order(-ssus$spaces, -ssus$requests),]

  # Cycle through students DF again and fill remaining SSUs
  for (i in 1:nrow(ssus)) {

    # Don't randomly assign SSU to student if at capacity or should be chosen
    if (ssus$spaces[i] == ssus$count[i] | ssus$random_alloc[i]=="N") {
      next
    }

    # Cycle through students again
    for (j in 1:nrow(students)) {

      # check student not already assigned
      if (is.na(students$assignment[j])) {
        students$assignment[j] = ssus$unit_code[i]
        students$chosen[j] = "NO"
        ssus$count[i] = ssus$count[i]+1
      }
      # check if we are now at SSU capacity, go to next SSU if so
      if (ssus$count[i] == ssus$spaces[i]) {
        break
      }

    } # end cycle through students

  } # end SSU cycle
  ssus = ssus[order(-ssus$spaces, -ssus$requests ),]

  # Prepare student DF for output
  # a. sort student DF again by name
  students = students[order(students$student_last_name),]
  # b. remove choice_score
  students$choice_score = NULL


  # Output to files:
  write.table(students, paste(oFile,"_allocations.txt", sep=""), quote=F, row.names=F, sep = "\t")
  write.table(ssus, paste(oFile,"_ssus.txt", sep=""), quote=F, row.names=F, sep = "\t")

}
