# ddateprimitives

The library contains very useful algorithm primitives for building your own date library. It is lightweight, cross platform and does not depend on any other units and libraris.

This is pascal port of [Compatible Low-Level Date Algorithms](http://howardhinnant.github.io/date_algorithms.html). As the original code this library is dedicated to the public domain too.

For detailed documentation for the library see [ddateprimitives](ddateprimitives.pas) comments in the interface section. For algorithm details read original paper [Compatible Low-Level Date Algorithms](http://howardhinnant.github.io/date_algorithms.html) with great and detailed explanations.

Here is brief description.

## TDateInteger

The library declares `TDateInteger` as alias to one of integer type and uses the type for all integer computations. You can change it to whatever signed and at least 32-bit integer type you want.

## Serial day number

**Serial day number** of a specified date is number of days since 1970-01-01 to the date.

You can get serial day number of specified Year-Month-Day triple with `days_from_civil` function:

```pascal
  NumberOfDays := days_from_civil(Year, Month, Day);
```

You can get year, month and day triple of specified serial day number with `civil_from_days` function:

```pascal
  // result will be written to the variables Year, Month and Day
  civil_from_days(SerialDay, Year, Month, Day);

  // alternatively you can get result to a TYearMonthDay structure
  var Civil: TYearMonthDay;
  civil_from_days(SerialDay, Civil);

  // or even:
  Civil := civil_from_days(SerialDay);
```

## Unix Timestamp

**Unix Timestamp** or **Unix Time** or **UNIX Epoch Time** is the number of seconds since 1970-01-01 00:00:00.

Using functions from the previous section you can also convert date to or from Unix Timestamp:

```pascal
const
  SECONDS_PER_DAY = 24 * 60 * 60;

// ...

  UnixTimestamp := days_from_civil(Year, Month, Day) * SECONDS_PER_DAY;

// ...

  civil_from_days(UnixTimestamp div SECONDS_PER_DAY, Year, Month, Day);
```

## Leap years

You can check whenever specified year is leap or not:

```pascal
if is_leap(Year) then begin
  // ...
end else begin
  // ...
end;
```

## Days in the specified month

You can get number of days of specified month in civil calendar with `last_day_of_month` function:

```pascal
  DaysInMonth := last_day_of_month(Year, Month);
```

It takes into account leap years.

## Weekday

**Weekday** is a number in range 0..6 representing week day number starting with sunday (that is, 0 is for Sunday, 1 is for Monday, 2 is for Tuesday, 3 is for Wednesday, 4 is for Thursday, 5 is for Friday and 6 is for Saturday).

You can determine weekday of serial day number with `weekday_from_days` function:

```pascal
  Weekday := weekday_from_days(Days);
  
  // You can also combine it with days_from_civil:
  Weekday := weekday_from_days(days_from_civil(Year, Month, Day));
```

You can get next or previous weekday with `next_weekday` and `prev_weekday` respectively:

```pascal
  NextWeekday := next_weekday(Weekday);

  PrevWeekday := prev_weekday(Weekday);
```

You can subtract one weekday from another (e.g. Sun - Sat is 1, and Sat - Sun is 6), result is always a number in range 0..6:

```pascal
  WeekdayDiff = weekday_difference(FirstWeekday, SecondWeekday);
```

Here is an example function that returns next Tuesday for a given date. It can get you an idea of how to use `weekday_difference`:

```pascal
function NextTuesday(Today: TDateInteger): TDateInteger;
const
  TUESDAY = 2;
var
  Tomorrow: TDateInteger;
  Delta: TDateInteger;
begin
  // We want to start from tomorrow, because today may be a tuesday and
  // in this case we want a week from today, not today
  Tomorrow := Today + 1;
  // Compute number of days from tomorrow to tuesday
  Delta := weekday_difference(TUESDAY, weekday_from_days(Tomorrow));
  // Return the result
  Result := Tomorrow + Delta;
end;
```

## Week Calendar (ISO 8601)

**Week Calendar date** as it specified in ISO 8601 is a date in form Year, Week, WeekDay, where Week is week number in range 1..53, WeekDay is day of week. The first day of the year is the Monday that occurs on or before Jan 4, so a year number in week and civil calendar representations differs for some dates.

Unit [ddateprimitives_iso8601](ddateprimitives_iso8601.pas) provides primitives for working with ISO 8601 week-based dates.

Note that in the unit week day is still considered as a number 0..6 representing Sun..Sat, although in the ISO 8601 a week starts with Monday.

You can convert civil date to week calendar date with `iso_week_from_civil`:

```pascal
uses
  ddateprimitives,
  ddateprimitives_iso8601;

// ...

  // Result will be written to variables IsoYear, IsoWeek, IsoWeekDay
  iso_week_from_civil(Y, M, D,
                      IsoYear, IsoWeek, IsoWeekDay);
```

You can convert week calendar date to civil date with `civil_from_iso_week`:

```pascal
  // Result will be written to variables CivilYear, CivilWeek, CivilWeekDay
  civil_from_iso_week(Y, W, D,
                      CivilYear, CivilWeek, CivilWeekDay);
```

You can get serial day number of the first day of the week calendar year Year:

```pascal
  FirstDay := iso_week_start_from_year(Year);
```

## Julian Calendar

Unit [ddateprimitives_julian](ddateprimitives_julian.pas) provides primitives for work with julian calendar dates. Function `days_from_julian` returns serial day number (in civil calendar meaning, not julian):

```pascal
uses
  ddateprimitives,
  ddateprimitives_julian;

// ...

  Days := days_from_julian(Year, Month, Day);

  // You can also combine it with civil_from_days to get civil calendar date
  civil_from_days(days_from_julian(Year, Month, Day),
                  CivilYear, CivilMonth, CivilDay);
```

Function `julian_from_days` returns julian calendar date for the specifie serial day number:

```pascal
  // result will be written to the variables Year, Month, Day
  julian_from_days(SerialDay,
                   Year, Month, Day)

  // You can combine it with days_from_civil to convert civil date to julian
  julian_from_days(days_from_civil(CivilYear, CivilMonth, CivilDay),
                   Year, Month, Day);
```

Function `weekday_from_days` returns correct week day even for julian calendar. `is_leap` and `last_day_of_month` do not work for julian calendar.
