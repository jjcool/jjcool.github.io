package com.fico.analytics.aarf.udfs

fun sum(a: Number, b: Number): Double {
    return a.toDouble() + b.toDouble();
}

// tag::warn[]
fun warnFunction(avgValue: Double, minValue: Double): List<Warning> {
    val list: MutableList<Warning> = mutableListOf()
    if (avgValue > 100.0 && minValue < 50)
        list.add(Warning("500", "min balance is low and average is high"))
    return list
}
// end::warn[]

// tag::error[]
fun errorFunction(avgValue: Double, maxValue: Double): List<Error> {
    val list: MutableList<Error> = mutableListOf()
    if (avgValue < 100.0 && maxValue > 500)
        list.add(Error("501", "suspicious transaction"))
    return list
}
// end::error[]

private val dateFormatter: DateTimeFormatter = DateTimeFormat.forPattern("MM/dd/yyyy HH:mm:ss");
fun dateDifferenceGt5Minutes(date1: String, date2: String, minDiffForNonDuplicateTxn :Int) : List<Warning> {
    val list: MutableList<Warning> = mutableListOf()
    if(date1.isNotEmpty() && date2.isNotEmpty()) {
        val dateTime1 = dateFormatter.parseDateTime(date1.trim({ it <= ' ' }))
        val dateTime2 = dateFormatter.parseDateTime(date2.trim({ it <= ' ' }))
        val diffMin = Minutes.minutesBetween(dateTime1, dateTime2).minutes
        if (diffMin < minDiffForNonDuplicateTxn) {
            list.add(Warning("200", "probably a duplicate transaction"))
        }
    }

    return list
}

fun duplicateTxnCheck(date1: String, date2: String, minDiffForNonDuplicateTxn :Int, amount1:Double, amount2: Double, mcc:Int):List<Error> {
    val list: MutableList<Error> = mutableListOf()
    if(dateDifferenceGt5Minutes(date1,date2, minDiffForNonDuplicateTxn).isNotEmpty()){
        if(amount1 == amount2)
            list.add(Error("200", "duplicate transaction for $mcc"))
    }
    return list

}

// tag::errorandwarn[]
fun validateForErrorsAndWarnings(date1: String, date2: String, minDiffForNonDuplicateTxn :Int, amount1:Double, amount2: Double, mcc:Int):Pair<List<Error>,List<Warning>> {
    val warnList = dateDifferenceGt5Minutes(date1,date2, minDiffForNonDuplicateTxn)
    val errorList = duplicateTxnCheck(date1, date2,minDiffForNonDuplicateTxn,amount1, amount2, mcc)
    return Pair(errorList, warnList)
}
// end::errorandwarn[]