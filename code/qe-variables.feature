# language : fcs
Variable Library: StreamVar Variable Generation Configuration

#1. QEs are calculated after the StreamVar Profiled variables
#2. Each QE profile(grouped by peer Group) will have its own separate model steps
#3. Post Processing of the QE variables happens in the separate model Step
#4. QEs are supported for multiple data source
#5. QE model step bypasses all other data sources record as it is.

## Supported QE types :
# legacyFalcon
# adaptiveGridEventDecay
# adaptiveTierney

## Supported shuffler functions
# hash
# roundrobin
# randompermuation

# default values for
# peer group = empty string (equivalent to "''")
# shuffler : randompermuation
# merge period = 0
# transactions partitioned  = 1
Input Set:
Given input data source "Accounts"
And input formatted as "json"

Profile the "Account" identified by field "accountid" and call it "account"


//tag::qe-profile-declaration[]
//Profile the QE "<profile name>" in input record "<data source name>" and call it "<profile alias>"
Profile the QE "Profile1" in input record "Accounts" and call it "profile1"
//end::qe-profile-declaration[]

//tag::peer-group-property[]
//With peer groups identified by value of "<peer group property field or string>"
With peer groups identified by value of "merchantCode"
//end::peer-group-property[]

//tag::partitions-property[]
//With transactions partitioned across <number of partitions> mergeable profiles
With transactions partitioned across 1 mergeable profiles
//end::partitions-property[]

Profile the QE "Profile2" in input record "Accounts" and call it "profile2"
With peer groups identified by value of "emptyPeerGroup"

//tag::merge-period-property[]
//With merge period of <merge period> transactions
With merge period of 1250 transactions
//end::merge-period-property[]

Profile the QE "Profile3" in input record "Accounts" and call it "profile3"

//tag::shuffler-property[]
//With shuffling of transactions by "<shuffler name>"
With shuffling of transactions by "roundrobin"
//end::shuffler-property[]


//tag::complete-qe-profile[]
Profile the QE "Profile4" in input record "Accounts" and call it "profile4"
With peer groups identified by value of "merchantCode"
With merge period of 1250 transactions
With shuffling of transactions by "hash"
With transactions partitioned across 1 mergeable profiles

//end::complete-qe-profile[]

With date field "date" formatted as "MM/dd/yyyy HH:mm:ss"
With fields
| field_name                             | data_type |
| accountid                              | String    |
| merchantcode                           | Int       |
| amount                                 | Double    |
| date                                   | String    |
| merchantType                           | String    |
| nonWorkingHoursSpendingOnMerchandise   | String    |

Output Set:
Generate output record "Accounts:ScoreResponse" for input record "Accounts"
With output formatted as "json"
Then output "select" variables "every input record"
And output select values
| value_name                                     |
| account_amount:merchantIsCash_Yes:event_avg_4D |
| qeGrid                                         |
| qeAmount                                       |
| qeAmountTierney                                |
| qeEventAvgTierney                              |
| qeAmountWithMerging                            |

And calculate score with configuration from "examples/scoring.conf" and scoring model input values
| value_name                                                     |
| account_amount:merchantIsCash_Yes:event_avg_4D                 |
| account_amount:nonWorkingHoursSpendingOnMerchandise_Y:min_4D   |
| account:luxuryOrAirlineGt500_No:freq_4D                        |
| account:nonWorkingHoursSpendingOnMerchandise:min_delta_time_4D |
| account:merchantIsCash_Yes:recency_4D                          |
| amount                                                         |
| account_merchantcode:all:blist_is_miss_5L                      |
| ratioOverMinAndMax                                             |

And calculate reason codes using Falcon Reason Reporter and scoring model input values and configuration from "examples/reasons.conf"

Variable Set:
Calculate variables when the input data source is "Accounts"
Add "merchantIsCash" as "'Cash'" = "merchantType"
Add "emptyPeerGroup" as the constant "''"
Add "luxuryOrAirlineGt500" as "luxuryOrAirline" and "amountGt500"
With "luxuryOrAirline" as "merchantTypeLuxury" or "merchantTypeAirline"
With "merchantTypeLuxury" as "merchantType" = "'  'Luxury''"
With "merchantTypeAirline" as "merchantType" = "'  'Airline''"
With "amountGt500" as "amount" > 500
Add "ratioOverMinAndMax" as the ratio of "minimumAmountIn30Days" over "maximumAmountIn30Days"


Variable Set:
Calculate profiled variables for the "account" when the input datasource is "Accounts"
Add "account_amount:merchantIsCash_Yes:event_avg_4D" as the event average of "amount" where "merchantIsCash" is "true" over 4 "days"
Add "account_amount:nonWorkingHoursSpendingOnMerchandise_Y:min_4D" as the minimum of "amount" where "nonWorkingHoursSpendingOnMerchandise" is "Y" over 4 "days"
Add "account:luxuryOrAirlineGt500_No:freq_4D" as the number of occurrences of "false" in "luxuryOrAirlineGt500" category over 4 "days"
Add "account:nonWorkingHoursSpendingOnMerchandise:min_delta_time_4D" as the minimum number of periods between two non-missing occurrences of "nonWorkingHoursSpendingOnMerchandise" category over 4 "days"
Add "account:merchantIsCash_Yes:recency_4D" as the periods since occurrence of non-missing values in "merchantIsCash" category over 5 "days"
Add "minimumAmountIn30Days" as the minimum of "amount" where "luxuryOrAirlineGt500" is "true" over 30 "days" lagged by 7 "days"
Add "maximumAmountIn30Days" as the maximum of "amount" where "luxuryOrAirlineGt500" is "true" over 30 "days" lagged by 7 "days"


Variable Outline: Blist Variable Explosion. Note that time intervals can be a list but lags are a single value
Generate profiled variables using the "<function>" function for the "account" when the input datasource is "Accounts"
With Blist properties
| blist_key      |   size  | update_field  | update_field_value  |
| merchantcode   |   5    |                |                     |

Variables:
| function          |
| blist_is_miss     |

  //tag::qe-variable-generation[]
//tag::qe-param-declaration[]
Variable Set:
Calculate global profiled variables for the "profile1" when the input datasource is "Accounts"
With parameters for "adaptiveTierney" QE algorithm as below
| param_name        | param_value    |
| qLow              | 0.95           |
| qHigh             | 0.99           |
| eventScale        | 500.0          |
//end::qe-param-declaration[]


And "qeAmountTierney" as the QE-scaled value of "amount"
//And "qeCreditAmount" as the scaled value of "creditAmount"

#override the qe properties at variable level
And "qeEventAvgTierney" as the QE-scaled value of "account_amount:merchantIsCash_Yes:event_avg_4D" with parameters
| param_name        | param_value    |
| updateWhen        | merchantIsCash |
| eventScale        | 1000.0          |
//end::qe-variable-generation[]

Variable Set:
Calculate global profiled variables for the "profile2" when the input datasource is "Accounts"
With parameters for "adaptiveGridEventDecay" QE algorithm as below
| param_name | param_value |
| qLow       | 0.95        |
| qHigh      | 0.99        |
| eventScale | 100.0       |
And "qeGrid" as the QE-scaled value of "amount"

Variable Set:
Calculate global profiled variables for the "profile3" when the input datasource is "Accounts"
With parameters for "legacyFalcon" QE algorithm as below
| param_name | param_value |
| qLow       | 0.95        |
| qHigh      | 0.99        |
| epochSize  | 500         |
And "qeAmount" as the QE-scaled value of "amount"

Variable Set:
Calculate global profiled variables for the "profile4" when the input datasource is "Accounts"
With parameters for "legacyFalcon" QE algorithm as below
| param_name | param_value |
| qLow       | 0.98        |
| qHigh      | 0.99        |
| epochSize  | 500         |
And "qeAmountWithMerging" as the QE-scaled value of "amount"

Input Set:
Given input data source "Merchants"
And input formatted as "json"
Profile the "Merchants" identified by field "mid" and call it "merchant"

Profile the QE "QEMerchantProfile" in input record "Merchants" and call it "qeMerchantProfile"
With peer groups identified by value of "transactionType"


And retrospective variable requests allowed up to 1 Month in the past
With date field "date" formatted as "M/d/yyyy"
With fields
| field_name                       | data_type |
| seq                              | Int       |
| mid                              | String    |
| date                             | String    |
| value                            | Double    |
| transactionType                  | String    |
| description                      | String    |
| product                          | String    |

Output Set:
Generate output record "Merchants:VariableResponse" for input record "Merchants"
With output formatted as "json"
Then output "select" variables "every input record"
Then output select values
| value_name                                             |
| product                                                |
| merchant_value:product_VISA:min_1D                     |
| merchant_value:transactionType_Credit:std_dev_15D      |
| merchant:product_VISA:pen_recency_5D                   |
| merchant:description_Refund:recent_consec_streak_1D_7L |
| qeGrid                                                 |
| logOddsCDFOfValue                                      |
| quantileEstimateAt0.98                                 |


Variable Set:
Calculate profiled variables for the "merchant" when the input datasource is "Merchants"
Add "merchant_value:product_VISA:min_1D" as the minimum of "value" where "product" is "VISA" over 1 "days"
Add "merchant_value:transactionType_Credit:std_dev_15D" as the standard deviation of "value" where "transactionType" is "Credit" over 15 "days"
Add "merchant:product_VISA:pen_recency_5D" as the periods since the penultimate occurrence of "VISA" in "product" category over 5 "days"
Add "merchant:description_Refund:recent_consec_streak_1D_7L" as the number of consecutive periods including recent of observing "Refund" in "description" category over 1 "days" lagged by 7 "days"

Variable Set:
Calculate global profiled variables for the "qeMerchantProfile" when the input datasource is "Merchants"
With parameters for "adaptiveGridEventDecay" QE algorithm as below
| param_name | param_value |
| qLow       | 0.95        |
| qHigh      | 0.99        |
| eventScale | 100.0       |

//tag::scaled_qe[]
//And "<scaled variable name>" as the QE-scaled value of "<observation field>"
And "qeGrid" as the QE-scaled value of "value"
//end::scaled_qe[]


//tag::log-odds[]
//And "<logOddsCDF vaiable name>" as the log-odds of estimated cumulative probability of "<observation field>"
And "logOddsCDFOfValue" as the log-odds of estimated cumulative probability of "value"
//end::log-odds[]

//tag::quantileEstimate[]
//And "<quantile Estimate var name>" as the quantile estimate of "<observation>" at <quantile between 0 and 1> quantile
And "quantileEstimateAt0.98" as the quantile estimate of "value" at 0.98 quantile
//end::quantileEstimate[]