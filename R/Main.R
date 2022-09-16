#' ssuex: SSUs in Exeter
#'
# '\strong{Description}
#' This function allocates SSUs to students based on their preferences.
#' It takes two tab-delimited headed files containing student preferences and
#' information about available SSUs and returns an output file containing the
#' the assigned SSU.
#'
#' @param sFile Tab delimited file with header containing information about students:
#' \code{student name, number, c1, ..., cN}
#' @param uFile Tab delimited file with header containing information about SSUs:
#' \code{unit code, spaces available}
#' @param oFile Name of output file
#' @return NA
#' @export

allocate <- function(sFile, uFile, oFile) {


  # STUDENT DATA SETUP #########################################################
  # Read student choices
  students = read.table(sFile, sep="\t", stringsAsFactors = F, header=T)
  # Create SSU-choice score (based on popularity of ssu choices)
  students$choice_score = 0
  # Create column containing assigned ssu
  students$assignment = NA
  ##############################################################################


  # SSU DATA SETUP  ############################################################
  # Read data on spaces available for each unit
  ssus = read.table(uFile, sep="\t", stringsAsFactors = F, header=T)
  # Initiate number of times the SSU has been selected
  ssus$requests = 0
  # initiate number of individuals assigned to unit
  ssus$count = 0
  # Add up the number of requests for each SSU from the students DF
  # cycle through columns 3 onward of student choices
  for (i in 1:nrow(students)) {
    for (j in 3:(ncol(students)-2)) {
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
    for (j in 3:(ncol(students)-2)) {
      ssu_index = which(ssus$unit_code == students[i,j])
      if (length(ssu_index)==1) {
        students$choice_score[i]=students$choice_score[i]+ssus$requests[ssu_index]
      }
    }
  }
  # Sort students by their choice score descending.
  students = students[order(-students$choice_score),]
  ##############################################################################


  # Cycle through SSUs in dscending order of popularity ########################
  # First iteration should not assign random allocations
  for (i in 1:nrow(ssus)) {
    # Cycle through students ordered by the overall popularity of their ssu requests
    for (j in 1:nrow(students)) {
      # check student not already assigned
      if (is.na(students$assignment[j])) {
        # cycle through columns 3 onward to check SSU code present
        for (k in 3:(ncol(students)-2)) {
          # check if they have the current SSU code
          if (students[j,k] == ssus$unit_code[i]) {
            students$assignment[j] = ssus$unit_code[i]
            ssus$count[i] = ssus$count[i]+1
          }
        }
      }
      # skip remaining students for this SSU if count=capacity
      if (ssus$count[i] == ssus$spaces[i]) {
        break
      }
    }
  }
  ##############################################################################

  # Output to files:
  write.table(students, paste(oFile,".allocations", sep=""), quote=F, row.names=F, sep = "\t")
  write.table(ssus, paste(oFile,".ssus", sep=""), quote=F, row.names=F, sep = "\t")

}
