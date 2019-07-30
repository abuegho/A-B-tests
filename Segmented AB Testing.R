library(readxl)
library(tidyverse)
library(infer)

## in case you suspect any of these pkgs aren't installed/updated run:
## install.packages(c('readxl', 'tidyverse', 'infer', 'xlsx'))



Test_Results = read_excel(file_loc)  ##sheet_name isn't necessary if data are in the first tab
Test_Results$`C/T` = factor(Test_Results$`C/T`, levels = c('Test', 'Control'))

testlist = list()
ratingslist = list()
for (i in unique(Test_Results$Segment)) {
  df = filter(Test_Results, Segment == i)
  pv_perc = df %>% 
    t_test(Played ~ `C/T`, order = c('Test', 'Control'))  ## performs t-test on Played %
  pv_days = df %>% 
    filter(Played > 0) %>% 
    t_test(`Days Played` ~ `C/T`, order = c('Test', 'Control')) ## performs t-test on Gaming Days/Month
  pv_nADT = df %>% 
    filter(Played > 0) %>% t_test(nADT ~ `C/T`, order = c('Test', 'Control'))   ## performs t-test on nADT
  
  Prop = df %>% 
    group_by(`C/T`) %>% 
    summarise(prop_play = mean(Played)) %>% 
    spread(`C/T`, prop_play, sep = ' Prop ')  ##Test vs Control averages of Played %
  days = df %>% 
    group_by(`C/T`) %>% 
    summarise(days = mean(ifelse(`Days Played` > 0, `Days Played`, NA), na.rm = T)) %>% 
    spread(`C/T`, days, sep = ' Days ')       ##Test vs Control averages of Gaming Days/Month
  nADT = df %>% 
    group_by(`C/T`) %>% 
    summarise(nADT = mean(ifelse(`Days Played` > 0, nADT, NA), na.rm = T)) %>% 
    spread(`C/T`, nADT, sep = ' nADT ')       ##Test vs Control averages of nADT
  
  vals = cbind(pv_perc = pv_perc$p_value, pv_days = pv_days$p_value, pv_nADT = pv_nADT$p_value,
               prop_cont = Prop$`C/T Prop Control`, prop_test = Prop$`C/T Prop Test`,
               prop_res = ifelse(Prop$`C/T Prop Test` > Prop$`C/T Prop Control`, 'Higher', 'Lower'),
               days_cont = days$`C/T Days Control`, days_test = days$`C/T Days Test`,
               days_res = ifelse(days$`C/T Days Test` > days$`C/T Days Control`, 'Higher', 'Lower'),
               nADT_cont = nADT$`C/T nADT Control`, nADT_test = nADT$`C/T nADT Test`,
               nADT_res = ifelse(nADT$`C/T nADT Test` > nADT$`C/T nADT Control`, 'Higher', 'Lower')) ##binds each seg's values into single row
  testlist[[i]] = data.frame(vals)
  output = do.call(rbind, testlist) %>% rownames_to_column(var = 'Segment') %>% 
    arrange(Segment)##combines all segments results into one table
  
  ratingslist[[i]] = Test_Results %>% filter(Segment == i) %>% 
    group_by(`C/T`) %>% summarise('Total Invited' = n(), 'Total Played' = sum(Played), 
                                  'Respone Rate' = percent(sum(Played)/n(), .1), 'Total Redeemed' = sum(Redeemed),
                                  'Offer Response' = percent(sum(Redeemed)/n(), .1), 'Gaming Days' = sum(`Days Played`),
                                  'Frequency' = sum(`Days Played`)/sum(Played), 'Actual' = sum(`Rated Actual`),
                                  'Total Theo' = sum(`Theo Amount`), 'Total Expense' = sum(`Total Expense`),
                                  'Net Actual' = sum(`Rated Actual`) - sum(`Total Expense`), 
                                  'Net Theo' = sum(`Theo Amount`) - sum(`Total Expense`))
  routput = do.call(rbind, ratingslist) %>% rownames_to_column(var = 'Segment') %>% arrange(Segment)
}

siglevs = output %>% 
  transmute(segment = Segment,
            perc_Result = ifelse(as.numeric(as.character(pv_perc)) <= .15 , 
                                 paste(nADT_res, ' @', percent(1 - as.numeric(as.character(pv_perc)), .1)), 'Not Significant'), 
            days_Result = ifelse(as.numeric(as.character(pv_days)) <= .15 , 
                                 paste(nADT_res, ' @', percent(1 - as.numeric(as.character(pv_days)), .1)), 'Not Significant'), 
            nADT_Result = ifelse(as.numeric(as.character(pv_nADT)) <= .15 , 
                                 paste(nADT_res, ' @', percent(1 - as.numeric(as.character(pv_nADT)), .1)), 'Not Significant')) %>% 
  arrange(segment)

xlsx::write.xlsx(siglevs, 'test output.xlsx', sheetName = 'Significance Levels', row.names = F)  
xlsx::write.xlsx(routput, 'test output.xlsx', sheetName = 'Ratings Details', append = T)
xlsx::write.xlsx(output, 'test output.xlsx', sheetName = 'P-Values', append = T, row.names = F)  ## exports output into default or designated directory
