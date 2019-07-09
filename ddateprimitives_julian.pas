// http://howardhinnant.github.io/date_algorithms.html
{$MODE FPC}
{$MODESWITCH OUT}
{$MODESWITCH RESULT}
unit ddateprimitives_julian;

interface

uses
  ddateprimitives;

type
  TDateInteger = ddateprimitives.TDateInteger;

const
  // Supported years range for Julian is the same as for Gregorian
  JULIAN_YEAR_LOW       = DATE_PRIMITIVES_YEAR_LOW;
  JULIAN_YEAR_HIGH      = DATE_PRIMITIVES_YEAR_HIGH;

  // Supported serial day number for Julian is almost the same as for Gregorian
  JULIAN_DAYS_LOW       = DATE_PRIMITIVES_DAYS_LOW;
  JULIAN_DAYS_HIGH      = High(TDateInteger) - 719470;

//
//  days_from_julian
//
//      Converts Julian year,month,day triple to a serial day number. Note that
//      serial day number is still defined though Gregorian calendar.
//
//      Returns number of days since Gregorian 1970-01-01 to Julian Y-M-D.
//      Negative values indicate days prior to 1970-01-01.
//
//  Parameters:
//
//      Y-M-D represents a date in the Julian calendar
//
//      Y: year  is in range
//             JULIAN_YEAR_LOW .. JULIAN_YEAR_HIGH
//      M: month is in range 1..12
//      D: day   is in range 1..last_day_of_month_julian(Y, M)
//
//  Returns:
//
//      Result: number of days from Gregorian 1970-01-01 to Julian Y-M-D
//              if some of Y, M, D are out of range, result is undefined
//
function days_from_julian(Y, M, D: TDateInteger): TDateInteger;

//
//  julian_from_days
//
//      Returns Year/Month/Day triple for Julian calendar.
//
//      It is inverse function for the days_from_julian function.
//
//  Parameters:
//
//      Days: number of days since Gregorian 1970-01-01 in range
//              JULIAN_DAYS_LOW .. JULIAN_DAYS_HIGH
//
//  Returns:
//
//      Julian or Result: structure for the Year,Month,Day triple
//      Year, Month, Day: tiple as separated variables
//
procedure julian_from_days(Days: TDateInteger;
                           out Julian: TYearMonthDay); overload;
function  julian_from_days(Days: TDateInteger): TYearMonthDay; overload; inline;
procedure julian_from_days(Days: TDateInteger;
                           out Year, Month, Day: TDateInteger); overload; inline;

implementation

function days_from_julian(Y, M, D: TDateInteger): TDateInteger;
var
  Era: TDateInteger; // 400 years time period
                 // (the civil calendar exactly repeats itself every 400 years)
  Yoe: TDateInteger; // Year of the era
  Doy: TDateInteger;
  Doe: TDateInteger; // Day of the era
begin
  // Internally, we suppose that a year starts at 1 march
  if M <= 2 then
    Dec(Y);
  if Y >= 0 then begin
    Era := Y div 4;
  end else
    Era := (Y - 3) div 4;
  Yoe := Y - Era * 4; // [0, 3]
  if M > 2 then begin
    Doy := -3
  end else
    Doy := 9;
  Doy := (153 * (M + Doy) + 2) div 5 + D - 1;       // [0, 365]
  Doe := Yoe * 365 + Doy; // [0, 1460]
  Result := Era * 1461 + Doe - 719470;
end;

procedure julian_from_days(Days: TDateInteger;
                           out Julian: TYearMonthDay);
var
  Era: TDateInteger;
  Doe: TDateInteger; // Day of the era
  Yoe: TDateInteger; // Year of the era
  Doy: TDateInteger;
  Mp: TDateInteger;
begin
  Inc(Days, 719470);
  if Days >= 0 then begin
    Era := Days div 1461;
  end else
    Era := (Days - 1460) div 1461;
  Doe := (Days - Era * 1461);           // 0..1460
  Yoe := (Doe - Doe div 1460) div 365;  // 0..3
  Julian.Year := Yoe + Era * 4;
  Doy := Doe - 365 * Yoe;               // 0..365
  Mp := (5 * Doy + 2) div 153;          // 0..11
  Julian.Day := Doy - (153 * Mp + 2) div 5 + 1; // 1..31
  if Mp < 10 then begin
    Julian.Month := Mp + 3;
  end else
    Julian.Month := Mp - 9;             //  1..12
  if Julian.Month <= 2 then
    Inc(Julian.Year);
end;

function julian_from_days(Days: TDateInteger): TYearMonthDay;
begin
  julian_from_days(Days, Result);
end;

procedure julian_from_days(Days: TDateInteger;
                           out Year, Month, Day: TDateInteger);
var
  Julian: TYearMonthDay;
begin
  julian_from_days(Days, Julian);
  Year := Julian.Year;
  Month := Julian.Month;
  Day := Julian.Day;
end;

end.
