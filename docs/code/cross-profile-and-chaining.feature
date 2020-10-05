
// tag::single-source-multiple-profiles[]
Profile the "receiverAccount" partition of the "Account" identified by value of "toCustomerInstitutionID" in input record "eft"
With profile update time for the "receiverAccount" derived from value of "createdOn" formatted as "MM/dd/yyyy HH:mm:ss"
Profile the "receiverPerson" partition of the "Person" identified by value of "toPersonID" in input record "eft"
With retrospective variable requests for "receiverPerson" allowed up to 1 Month in the past
With profile update time for the "receiverPerson" derived from value of "createdOn" formatted as "MM/dd/yyyy HH:mm:ss"

// end::single-source-multiple-profiles[]


// tag::single-source-multiple-partions-same-profile[]
Profile the "receiverToken" partition of the "Token" identified by value of "toContactTokenID" in input record "eft"
With profile update time for the "receiverToken" derived from value of "createdOn" formatted as "MM/dd/yyyy HH:mm:ss"
Profile the "senderToken" partition of the "Token" identified by value of "contactTokenID" in input record "eft"
With profile update time for the "senderToken" derived from value of "createdOn" formatted as "MM/dd/yyyy HH:mm:ss"
// end::single-source-multiple-partions-same-profile[]

// tag::multiple-source-writing-to-same-profiles[]
Profile the "senderPerson" partition of the "Person" identified by value of "personID" in input record "eft"
With profile update time for the "senderPerson" derived from value of "createdOn" formatted as "MM/dd/yyyy HH:mm:ss"
Profile the "addressUser" partition of the "Person" identified by value of "personID" in input record "person_address"
With profile update time for the "addressUser" derived from value of "addressDate" formatted as "MM/dd/yyyy HH:mm:ss"
// end::multiple-source-writing-to-same-profiles[]

// tag::read-profile-cross-datasource[]
Profile the "geoData" partition of the "Person" identified by value of "geoUID" in input record "geo"
With profile update time for the "receiverPerson" derived from value of "geoDate" formatted as "MM/dd/yyyy HH:mm:ss"
Read the "geoData" partition of the "Person" profile identified by value of "personID" in input record "eft" and call it "senderGeoData"
With profile query time for the "senderGeoData" derived from value of "createdOn" formatted as "MM/dd/yyyy HH:mm:ss"
Read the "geoData" partition of the "Person" profile identified by value of "toPersonID" in input record "eft" and call it "receiverGeoData"
With profile query time for the "receiverGeoData" derived from value of "createdOn" formatted as "MM/dd/yyyy HH:mm:ss"
// end::read-profile-cross-datasource[]


// tag::cross-data-source-variable-access[]
# Cross data source variables that are chained using stateless transformations -
Variable Set:
Calculate variables when the input datasource is "eft"
Add "weirdCrossSourceRatioVar" as "senderGeoData::geoUser:country:uniq_count_4D_1L" / "sender_amount:all:min_5d"
Add "moreWeirdness" as "weirdCrossSourceRatioVar" + "amount"
Add "isFrequentTraveller" as "senderGeoData::geoUser:country:uniq_count_4D_1L" > 5
Add "isHighSpender" as "sender_amount:all:min_5d" > 1000
// end::cross-data-source-variable-access[]




// tag::cross-profile-variable-access[]
# Cross profile variables that are chained using stateless transformations.
Variable Set:
Calculate variables when the input datasource is "eft"
Add "isCrossBorder" as "receiverGeoData::lastCountry" != "senderGeoData::lastCountry"
Add "geoDistance" as the distance between "senderAddress::lastLat", "senderAddress::lastLong" and "receiverAddress:lastLat", "receiverAddress:lastLong"
// end::cross-profile-variable-access[]


// tag::variable-chaining[]
Variable Set:
Calculate profiled variables for the "sender" when the input record is "Eft"
Add "fromIPAddress" as the cross data source profile variable "senderLoc::lastIP"
Add "numDistinctSenderIPs" as the number of distinct occurrences of "fromIPAddress" category over 5 "days"
Add "isFavIPForSender" to indicate the presence of "fromIpAddress" in a blist of size 5
Add "isFavIPForSenderDouble" as "'1.00'" if "isFavIPForSender" otherwise use "'0.00'"
Add "senderIPBlistHitRate" as the overall time average of "isFavIPForSenderDouble" over 4 "days"
// end::variable-chaining[]
