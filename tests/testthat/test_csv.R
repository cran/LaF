
lines <- c(
  "1,M,1.45,Rotterdam",
  "2,F,12.00,Amsterdam",
  "3,,.22 ,Berlin",
  ",M,22,Paris",
  "4,F,12345,London",
  "5,M,,Copenhagen",
  "6,M,-12.1,",
  "7,F,-1,Oslo")
 
data <- data.frame(
  id=c(1,2,3,NA,4,5,6,7),
  gender=as.factor(c("M", "F", NA, "M", "F", "M", "M", "F")),
  x=c(1.45, 12, 0.22, 22, 12345, NA, -12.1, -1),
  city=c("Rotterdam", "Amsterdam", "Berlin", "Paris", 
      "London", "Copenhagen", "", "Oslo"),
  stringsAsFactors=FALSE
)

context("Reading of delimited files using blockwise operators")

test_that("reading all data works (\\n end-of-line)", {
  fn <- tempfile()
  writeLines(lines, con=fn, sep="\n")
  laf <- laf_open_csv(filename=fn, 
      column_types=c("integer", "categorical", "double", "string"))
  testdata <- laf[]
  expect_equal(testdata[,1], data[,1])
  expect_equal(sort(levels(testdata[[2]])), c("F", "M"))
  expect_equal(as.character(testdata[,2]), as.character(data[,2]))
  expect_equal(testdata[,3], data[,3])
  expect_equal(testdata[,4], data[,4])
  expect_true(is.na(testdata[4,1]))
  expect_true(is.na(testdata[3,2]))
  expect_true(is.na(testdata[6,3]))
  file.remove(fn)
})

test_that("reading all data works (\\r\\n end-of-line)", {
  fn <- tempfile()
  writeLines(lines, con=fn, sep="\r\n")
  laf <- laf_open_csv(filename=fn, 
      column_types=c("integer", "categorical", "double", "string"))
  testdata <- laf[]
  expect_equal(testdata[,1], data[,1])
  expect_equal(sort(levels(testdata[[2]])), c("F", "M"))
  expect_equal(as.character(testdata[,2]), as.character(data[,2]))
  expect_equal(testdata[,3], data[,3])
  expect_equal(testdata[,4], data[,4])
  expect_true(is.na(testdata[4,1]))
  expect_true(is.na(testdata[3,2]))
  expect_true(is.na(testdata[6,3]))
  file.remove(fn)
})

test_that("reading all data works (\\n end-of-line; extra newline)", {
  fn <- tempfile()
  writeLines(c(lines,""), con=fn, sep="\n")
  laf <- laf_open_csv(filename=fn, 
      column_types=c("integer", "categorical", "double", "string"))
  testdata <- laf[]
  expect_equal(testdata[,1], data[,1])
  expect_equal(sort(levels(testdata[[2]])), c("F", "M"))
  expect_equal(as.character(testdata[,2]), as.character(data[,2]))
  expect_equal(testdata[,3], data[,3])
  expect_equal(testdata[,4], data[,4])
  expect_true(is.na(testdata[4,1]))
  expect_true(is.na(testdata[3,2]))
  expect_true(is.na(testdata[6,3]))
  file.remove(fn)
})

test_that("reading all data works (\\n end-of-line; , decimal, ; seperator)", {
  fn <- tempfile()
  tmp <- gsub(",", ";", lines)
  writeLines(gsub("\\.", ",", tmp), con=fn, sep="\n")
  laf <- laf_open_csv(filename=fn, dec=",", sep=";",
      column_types=c("integer", "categorical", "double", "string"))
  testdata <- laf[]
  expect_equal(testdata[,1], data[,1])
  expect_equal(sort(levels(testdata[[2]])), c("F", "M"))
  expect_equal(as.character(testdata[,2]), as.character(data[,2]))
  expect_equal(testdata[,3], data[,3])
  expect_equal(testdata[,4], data[,4])
  expect_true(is.na(testdata[4,1]))
  expect_true(is.na(testdata[3,2]))
  expect_true(is.na(testdata[6,3]))
  file.remove(fn)
})

test_that("process_blocks works", {
  fn <- tempfile()
  writeLines(lines, con=fn, sep="\n")
  laf <- laf_open_csv(filename=fn, 
    column_types=c("integer", "categorical", "double", "string"))

  calc_sum <- function(d, r) {
      if (is.null(r)) r <- 0
      r <- r + sum(d[,1], na.rm=TRUE)
  }
  expect_equal(process_blocks(laf, calc_sum, columns=1), sum(data[,1], na.rm=TRUE))
  expect_equal(process_blocks(laf, calc_sum, columns=3), sum(data[,3], na.rm=TRUE))
  file.remove(fn)
})

