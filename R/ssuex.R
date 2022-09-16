####### STUDENT DATA SETUP #######

# Read student choices
students = read.table("~/Desktop/ssuex_orig_input_files/choices.txt",
                      sep="\t", stringsAsFactors = F, header=T)

# Create column containing SSU-choice score (based on popularity of ssu choices)
students$choice_score = 0

# Create column containing assigned ssu
students$assignment = NA

###################################



######### SSU DATA SETUP #########

# Read data on spaces available for each unit
ssus = read.table("~/Desktop/ssuex_orig_input_files/spaces.txt",
                  sep="\t", stringsAsFactors = F, header=T)

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

###################################



# Update student choice score as the sum of the number of times their SSUs have been chosen
for (i in 1:nrow(students)) {
  for (j in 3:(ncol(students)-2)) {
    ssu_index = which(ssus$unit_code == students[i,j])
    if (length(ssu_index)==1) {
      students$choice_score[i] = students$choice_score[i]+ssus$requests[ssu_index]
    }
  }
}
# Sort students to process by their choice score descending.
# Students picking the most popular choices assigned first as those picking
# less popular can be assigned to those SSUs
students = students[order(-students$choice_score),]



# Cycle through SSUs in dscending order of popularitu
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
