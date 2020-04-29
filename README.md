# Streamlining Segmented A/B testing

The .R file provides a script to automate t-testing of campaign results in a multi-segmented market.

## Motivation:
* Your company decides to run a campaign and examine preliminarily its effects using a basic t-test, before delving into more complex exploratory methods
* Constraints are two-fold:
  - Data of results contain all segments, and you'd want each segment considered seperately
  - You're not just testing effect of a single metric; multiple metrics are in question, which can add up linear time to set-up
 * What's more, these tests are conducted routinely
 * This was the case during my previous employment, and a typical approach was a macro-riddled excel file, and/or an obnoxious amount of copy-pasting and tweaking (AKA, wasted man-hours and opaque, error-prone operations)
 
 ## Data
| C/T      |      Redemption (Yes/No)      |  . |  . |  Visits |  Net worth |    Segment |
|----------|:-------------:|------:|------:|------:|------:|------:|
| Test |  1 |    . |    . | 12 | $1600 | West |
| Control |    0   |    . |    . |   7 |   $1200 | North|
| . | . |    . |    . |    . |    . | . |
| . | . |    . |    . |    . |    . | . |
| Test | 0 |    . |    . |    9 |   $100 | East |

## Solution
Script automates entire operation, so long as the data is structered as above. Plug and chug, minding the variable names in lines 11, 18, 21, 23, and so on.
The output of the programme is a three-tabbed excel sheet:
**1**. A table reporting significance levels (or lack thereof) of the test on each metric within each segment
**2**. A table summarising the results of each segment based on Control/Test groups
**3**. A table of p-values for audience demanding more details

Please let me know of any questions or suggestions about the code. I'm hopeful this would help some frustrated analyst just gnashing his teeth while peering at some undocumented/unguided worksheet left in his hands by an employee who abandoned the company millennia ago (yes, it happens)
