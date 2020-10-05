# language : fcs
Variable Library: StreamVar Variable Generation Configuration
// tag::inputset[]
Input Set:
// tag::datasource[]
Given input record "Accounts" for online profile record updates, feature generation and scoring
// end::datasource[]
// tag::input[]
And input formatted as "json"
// end::input[]
// tag::inputfields[]
With fields
| field_name                           | data_type |
| accountid                            | String    |
| merchantcode                         | Int       |
| amount                               | Double    |
| date                                 | String    |
| merchantType                         | String    |
| nonWorkingHoursSpendingOnMerchandise | String    |
// end::inputfields[]
// end::inputset[]

// tag::inputsetnonmutating[]
Input Set:
Given input record "Accounts:VariableRequest" for on-demand information requests without profile record updates
With fields
| field_name                             | data_type |
| queryDate                              | String    |
| profileIdFieldValue                    | String    |
// end::inputsetnonmutating[]

// tag::outputset[]
Output Set:
// tag::outputds[]
Generate output record "Accounts:VariableResponse" for input record "Accounts"
// end::outputds[]
// tag::outputformat[]
And output formatted as "csv"
// end::outputformat[]
// tag::outputvars[]
Then output select values
| value_name                                                     |
| account_amount:merchantIsCash_Yes:event_avg_1D                 |
| account_amount:all:min_1D                                      |
| account:luxuryOrAirlineGt500_No:freq_2D                        |
| account:nonWorkingHoursSpendingOnMerchandise:min_delta_time_1D |
| account:merchantIsCash_Yes:recency_1D                          |
// end::outputvars[]
//tag::scoring[]
Add "__score__" as the score calculated with configuration from "examples/scoring.conf" and scoring model input values
| value_name                                                     |
| account_amount:merchantIsCash_Yes:event_avg_4D                 |
| account_amount:nonWorkingHoursSpendingOnMerchandise_Y:min_4D   |
| account:luxuryOrAirlineGt500_No:freq_4D                        |
| account:nonWorkingHoursSpendingOnMerchandise:min_delta_time_4D |
| account:merchantIsCash_Yes:recency_4D                          |
| amount                                                         |
| account_merchantcode:all:blist_is_miss_5L                      |
| account:nonWorkingHoursSpendingOnMerchandise:min_delta_time_1D |
// end::scoring[]
//tag::reasons[]
Add "__reasons__" as the Falcon Reason Reporter reason codes associated with "__score__" and configuration from "examples/reasons.conf"
// end::reasons[]


//tag::limited_reasons[]
Add "__reasons__" as the top 3 Falcon Reason Reporter reason codes associated with "__score__" and configuration from "examples/reasons.conf"
// end::limited_reasons[]


//tag::conditional_scoring[]
Add "__conditional_score__" as the score calculated when "profileAge" is "young" with configuration from "examples/scoring.conf" and scoring model input values
| value_name                                                     |
| account_amount:merchantIsCash_Yes:event_avg_4D                 |
| account_amount:nonWorkingHoursSpendingOnMerchandise_Y:min_4D   |
| account:luxuryOrAirlineGt500_No:freq_4D                        |
| account:nonWorkingHoursSpendingOnMerchandise:min_delta_time_4D |
| account:merchantIsCash_Yes:recency_4D                          |
| amount                                                         |
| account_merchantcode:all:blist_is_miss_5L                      |
| account:nonWorkingHoursSpendingOnMerchandise:min_delta_time_1D |
// end::conditional_scoring[]

//tag::segmented_scoring[]
Variable Set:
  Calculate variables when the input record is "Accounts"
  Add "feature3_conditioned" as "feature3" * 1.0
  Add "feature4_conditioned" as "feature4" * 1.0
  Add "feature5_conditioned" as "feature5" * 1.0
  Add "feature6_conditioned" as 1.0 if "feature6" otherwise use 0.0
  Add "ratio" as the ratio of "numerator" over "denominator"
  With "feature7" as "ratio" if it is finite otherwise use "0.0"
  Add "profile_Age_is_mature" as "profile_Age" > 30.0
  Add "accountAge" as "'mature'" if "profile_Age_is_mature" otherwise use "'young'"
  Add "youngScore" as the score calculated when "accountAge" is "young" with configuration from "src/integration-test/resources/configs/scoring/segment_young/scoringModel.conf" and scoring model input values
    | value_name             |
    |  feature1              |
    |  feature2              |
    |  feature3_conditioned  |
    |  feature4_conditioned  |
    |  feature5_conditioned  |
    |   amount               |
    |  feature6_conditioned  |
    |  feature7              |

  Add "matureScore" as the score calculated when "accountAge" is "mature" with configuration from "src/integration-test/resources/configs/scoring/segment_mature/scoringModel.conf" and scoring model input values
    | value_name            |
    | feature1              |
    | feature2              |
    | feature3_conditioned  |

  Add "__segmented_score__" as the score from one of "youngScore, matureScore" calculated based on "accountAge" segmentation
  // end::segmented_scoring[]

  //tag::segmented_reasons[]
  Add "reasonForYoungScore" as the top 3 Falcon Reason Reporter reason codes associated with segment score "youngScore" and configuration from "src/integration-test/resources/configs/scoring/segment_young/reasonModel.conf"
  Add "reasonForMatureScore" as the Falcon Reason Reporter reason codes associated with segment score "matureScore" and configuration from "src/integration-test/resources/configs/scoring/segment_mature/reasonModel.conf"
  Add "__segmented_reasons__" as one of the Falcon Reason Reporter reason codes "reasonForMatureScore,reasonForYoungScore" associated with segmented score "__segmented_score__"
 //end::segmented_reasons[]



// end::outputset[]

// tag::profileset[]
Profiling Set:
// tag::profile[]
Profile the "account" partition of the "Account" identified by value of "accountid" in input record "Accounts"
// end::profile[]
// tag::history[]
With retrospective variable requests for "account" allowed up to 1 Month in the past
// end::history[]
// tag::date[]
With profile update time for the "account" derived from value of "date" formatted as "MM/dd/yyyy HH:mm:ss"
// end::date[]
// tag::timeZone[]
With profile update time stamp for the "account" using time zone "EST"
// end::timeZone[]
// end::profileset[]

// tag::parameterset[]
Parameter Set:
Given parameter set "mySetA" for the "account" when the input data source is "Accounts"
With numeric fields
| numeric_field |
| amount        |

With time intervals and lag
| time_intervals | lag | time_unit |
| 1, 10, 30      | 0   | Days      |
| 1, 10,  30     | 7   | Days      |

With categorical filters
| categorical_field                    | values_of_interest |
| merchantIsCash                       | Yes                |
| luxuryOrAirlineGt500                 | Yes", "No          |
| nonWorkingHoursSpendingOnMerchandise | Y                  |
// end::parameterset[]

// tag::variablesetsource[]
Calculate variables when the input data source is "Accounts"
// end::variablesetsource[]
// tag::preparedstmt[]
With "amountGt500" as "amount" > 500
With "binnedAmount" as 100 if "amountGt500" otherwise use 0
With "amountEqualTo10" as "amount" = 10.0
With "amountGreaterThan12" as "amount" > 12.0
With "amountPlus10" as "amount" + 10
With "amount1PlusAmount2" as the sum of "500,20,1000"
// end::preparedstmt[]
// tag::genericlookup[]
With "<varName1>" of type int from lookup table "<lookup file>" using lookup key "<lookupKey1>"
With "<varName2>" of type double from lookup table "<lookup file>" using lookup key "<lookupKey2>"
With "<varName3>" of type string from lookup table "<lookup file>" using lookup key "<lookupKey3>"
// end::genericlookup[]

// tag::falconlookup[]
Get lookup table value <lookup_value> for <lookup_key> in "Accounts" using lookup table "examples/risk1d.txt" of type <lookup_table_type>
| lookup_value  | lookup_key                        | lookup_table_type        |
| mcc_riskcalib | prefix_DCP_merchantcode_suffix_00 | falcon_risk_1d:riskcalib |
| country_woe   | merchantType                      | falcon_risk_1d:woe       |
// end::falconlookup[]

Variable Set: Ratio Variables for the general use case. This handles cross-datasource ratio
// tag::ratio[]
Generate ratio variables from table using a "diagonal" grid filter strategy when the input datasource is "Accounts"
| numerator           | param_set_num | denominator         | param_set_den |
| minimum_by_category | mySetA        | maximum_by_category | mySetA        |
// end::ratio[]

// tag::variableoutline[]
Variable Outline: StreamVar Variable Explosion. Note that time increments can be a list but lags are a single value
Generate profiled variables using the "<function>" function for the "account" when the input datasource is "Accounts"
With numeric fields
| numeric_field |
| amount        |
// tag::time_unit_lag[]
With time increments and lag
| time_increments | lag | time_unit |
| 1, 2            | 0   | Days      |
| 3               | 0   | Months    |
// end::time_unit_lag[]
With categorical filters
| categorical_field | values_of_interest |
| merchantIsCash    | Yes", "No          |
Variables:
| function            |
| minimum_by_category |
| maximum_by_category |
// end::variableoutline[]

// tag::variableexplosion_a[]
Variable Outline: StreamVar Variable Explosion. Note that time increments can be a list but lags are a single value
Generate profiled variables using the "<function>" function for the "account" when the input datasource is "Accounts"
With numeric fields
| numeric_field |
| amount        |
With time intervals and lag
| time_intervals | lag | time_unit |
| 1, 2           | 0   | Days      |
With categorical filters
| categorical_field | values_of_interest |
| merchantIsCash    | Yes", "No          |
Variables:
| function            |
| minimum_by_category |
// end::variableexplosion_a[]
// tag::variableexplosion_b[]
Variable Outline: StreamVar Variable Explosion. Not that time increments can be a list but lags are a single value
Generate profiled variables using the "<function>" function for the "account" when the input datasource is "Accounts"
With numeric fields
| numeric_field |
| amount        |
With time intervals and lag
| time_intervals | lag | time_unit |
| 1, 2           | 0   | Days      |
Variables:
| function        |
| overall_minimum |
// end::variableexplosion_b[]
// tag::variableexplosion_c[]
Variable Outline: StreamVar Variable Explosion. Not that time increments can be a list but lags are a single value
Generate profiled variables using the "<function>" function for the "account" when the input datasource is "Accounts"
With time intervals and lag
| time_intervals | lag | time_unit |
| 1, 2           | 0   | Days      |
With categorical filters
| categorical_field | values_of_interest |
| merchantIsCash    | Yes", "No          |
Variables:
| function            |
| recency_by_category |
// end::variableexplosion_c[]
// tag::variableexplosion_d[]
Variable Outline: StreamVar Variable Explosion. Not that time increments can be a list but lags are a single value
Generate profiled variables using the "<function>" function for the "account" when the input datasource is "Accounts"
With time intervals and lag
| time_intervals | lag | time_unit |
| 1, 2           | 0   | Days      |
With categorical filters
| categorical_field | values_of_interest |
| merchantIsCash    |                    |
Variables:
| function        |
| overall_recency |
// end::variableexplosion_d[]

// tag::fullform[]
Variable Set:
Calculate profiled variables for the "account" when the input datasource is "Accounts"
// tag::fullformstmt[]
Add "rv3001" as the event average of "amount" where "merchantType" is "  'FastFood'" over 4 "days"
// end::fullformstmt[]
Add "rv3002" as the minimum of "amount" where "merchantType" is "  'FastFood'" over 4 "days"
Add "rv3003" as the maximum of "amount" where "merchantType" is "  'FastFood'" over 4 "days"
Add "rv3004" as the rank of "merchantcode" where "merchantType" is "Grocery" in a blist of size 5
// end::fullform[]

// tag::blist[]
Variable Set: Blist Variable Explosion.
Generate profiled variables using the "<function>" function for the "account" when the input datasource is "Accounts"
With Blist properties
| blist_key    | size | update_field   | update_field_value |
| merchantcode | 4    | merchantIsCash | Yes                |
| merchantcode | 5    | groceryOrGas   | “No”               |
| posEntryMode | 10   |                |                    |
And Blist functions
| function      |
| blist_rank    |
| blist_weight  |
| blist_is_hit  |
| blist_is_miss |
// end::blist[]