// https://tools.ietf.org/html/rfc3339
{$MODE FPC}
{$MODESWITCH OUT}
{$MODESWITCH RESULT}
unit ddateprimitives_iso8601;

interface

uses
  ddateprimitives;

type
  TDateInteger = ddateprimitives.TDateInteger;

  TYearWeekDay = record
    Year: TDateInteger;
    Week: TDateInteger; // 1-53
    Day: TDateInteger;  // 0-6 (Sun,Mon,Tue,Wed,Thu,Fri,Sat)
  end;

//
//  iso_week_start_from_year
//
//      Returns the first day of the week-based year.
//
//  Returns:
//
//      Result: serial day number of first day of Y
//
function iso_week_start_from_year(Y: TDateInteger): TDateInteger;

//
//  iso_week_from_civil
//
//      Converts civil date to week calendar date.
//
//  Parameters:
//
//      Y-M-D represents civil date.
//
//      Y: year  is in range
//             DATE_PRIMITIVES_YEAR_LOW .. DATE_PRIMITIVES_YEAR_HIGH
//      M: month is in range 1..12
//      D: day   is in range 1..last_day_of_month(Y, M)
//
//      The function does not check ranges of input arguments.
//      Caller should check it by himself.
//
//  Returns:
//
//      Iso or Result: the week-based date structure
//      Year, Week, Day: the week-based date as separated variables
//
procedure iso_week_from_civil(Y, M, D: TDateInteger;
                              out Iso: TYearWeekDay); overload;
function  iso_week_from_civil(Y, M, D: TDateInteger): TYearWeekDay; overload; inline;
procedure iso_week_from_civil(Y, M, D: TDateInteger;
                              out Year, Week, Day: TDateInteger); overload; inline;

//
//  civil_from_iso_week
//
//      Converts week-based date to civil date.
//
//  Parameters:
//
//      Y,W,D represents week-based date.
//
//      Y: year number in range
//             DATE_PRIMITIVES_YEAR_LOW .. DATE_PRIMITIVES_YEAR_HIGH
//      W: the week number in range 1..53
//      D: the week day number in range 0..6
//
//      The function does not check ranges of input arguments.
//      Caller should check it by himself.
//
//  Returns:
//
//      Civil: structure for the resulting date
//      Year,Month,Day: the triple as separated variables
//
procedure civil_from_iso_week(Y, W, D: TDateInteger;
                              out Civil: TYearMonthDay); overload;
function civil_from_iso_week(Y, W, D: TDateInteger): TYearMonthDay; overload; inline;
procedure civil_from_iso_week(Y, W, D: TDateInteger;
                              out Year, Month, Day: TDateInteger); overload; inline;

implementation

function iso_week_start_from_year(Y: TDateInteger): TDateInteger;
var
  Tp: TDateInteger;
  Wd: TDateInteger;
begin
  Tp := days_from_civil(Y, 1, 4); // 4 january Y
  Wd := weekday_from_days(Tp);
  Exit(Tp - weekday_difference(Wd, 1)); // 1 = Monday
end;

procedure iso_week_from_civil(Y, M, D: TDateInteger;
                              out Iso: TYearWeekDay);
const
  MONDAY = 1;
  THURSDAY = 4;
var
  Tp: TDateInteger;
  IsoWeekStart: TDateInteger;
  IsoWeekNextYearStart: TDateInteger;
  Civil: TYearMonthDay;
begin
  Tp := days_from_civil(Y, M, D);
  IsoWeekStart := iso_week_start_from_year(Y);
  if Tp < IsoWeekStart then begin
    IsoWeekStart := iso_week_start_from_year(Y - 1);
  end else begin
    IsoWeekNextYearStart := iso_week_start_from_year(Y + 1);
  end;
  civil_from_days(IsoWeekStart + TDateInteger(THURSDAY - MONDAY), Civil);
  Iso.Day := weekday_from_days(Tp);
  Iso.Week := (Tp - IsoWeekStart) div 7 + 1;
  Iso.Year := Civil.Year;
end;

function iso_week_from_civil(Y, M, D: TDateInteger): TYearWeekDay;
begin
  iso_week_from_civil(Y, M, D, Result);
end;

procedure iso_week_from_civil(Y, M, D: TDateInteger;
                              out Year, Week, Day: TDateInteger);
var
  Iso: TYearWeekDay;
begin
  iso_week_from_civil(Y, M, D, Iso);
  Year := Iso.Year;
  Week := Iso.Week;
  Day := Iso.Day;
end;

procedure civil_from_iso_week(Y, W, D: TDateInteger;
                              out Civil: TYearMonthDay);
var
  Tp: TDateInteger;
begin
  Tp := iso_week_start_from_year(Y) + (W - 1) * 7;
  if D = 0 then begin
    Inc(Tp, 6);
  end else
    Inc(Tp, D - 1);
  civil_from_days(Tp, Civil);
end;

function civil_from_iso_week(Y, W, D: TDateInteger): TYearMonthDay;
begin
  civil_from_iso_week(Y, W, D, Result);
end;

procedure civil_from_iso_week(Y, W, D: TDateInteger;
                              out Year, Month, Day: TDateInteger);
var
  Civil: TYearMonthDay;
begin
  civil_from_iso_week(Y, W, D, Civil);
  Year := Civil.Year;
  Month := Civil.Month;
  Day := Civil.Day;
end;

end.
