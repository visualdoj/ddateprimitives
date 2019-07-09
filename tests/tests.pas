uses
  ddateprimitives,
  ddateprimitives_iso8601,
  ddateprimitives_julian;

procedure TestCivilDays;
var
  Days, Res: ddateprimitives.TDateInteger;
  Civil: TYearMonthDay;
  Y, M, D: ddateprimitives.TDateInteger;
  YLow, YHigh: TDateInteger;
  T1, T2: TDateInteger;
begin
  civil_from_days(DATE_PRIMITIVES_DAYS_LOW,  YLow,  T1, T2);
  civil_from_days(DATE_PRIMITIVES_DAYS_HIGH, YHigh, T1, T2);
  if YLow + 1 >= DATE_PRIMITIVES_YEAR_LOW then begin
    Writeln('Error: DATE_PRIMITIVES_YEAR_LOW is lower than civil_from_days can return');
  end;
  if YHigh - 1 <= DATE_PRIMITIVES_YEAR_HIGH then begin
    Writeln('Error: DATE_PRIMITIVES_YEAR_HIGH is higher than civil_from_days can return');
  end;
  Writeln('Lowest supported serial day number: ', DATE_PRIMITIVES_DAYS_LOW);
  Writeln('Highest supported serial day number: ', DATE_PRIMITIVES_DAYS_HIGH);
  Writeln('Lowest supported year: ', YLow + 1);
  Writeln('Highest supported year: ', YHigh - 1);
  Y := -5877640;
  while Y <= 5879609 do begin
    M := 1;
    while M <= 12 do begin
      D := 1;
      while D <= last_day_of_month(Y, M) do begin
        Days := days_from_civil(Y, M, D);
        civil_from_days(Days, Civil);
        if (Y <> Civil.Year) or (M <> Civil.Month) or (D <> Civil.Day) then begin
          Writeln('Conversion FAILED for ', Y, ' ', M, ' ', D);
          Exit;
        end;
        Inc(D);
      end;
      Inc(M);
    end;
    Inc(Y);
  end;
  Days := -2147483648;
  while Days <= 2147483647 - 719468 do begin
    civil_from_days(Days, Civil);
    Res := days_from_civil(Civil.Year, Civil.Month, Civil.Day);
    if Days <> Res then begin
      Writeln('Conversion FAILED for ', Days);
      Exit;
    end;
    Inc(Days);
  end;
end;

procedure TestJulianDays;
var
  Days, Res: ddateprimitives.TDateInteger;
  Civil: TYearMonthDay;
  Y, M, D: ddateprimitives.TDateInteger;
  YLow, YHigh: TDateInteger;
  T1, T2: TDateInteger;
begin
  julian_from_days(JULIAN_DAYS_LOW,  YLow,  T1, T2);
  julian_from_days(JULIAN_DAYS_HIGH, YHigh, T1, T2);
  if YLow + 1 >= JULIAN_YEAR_LOW then begin
    Writeln('Error: DATE_PRIMITIVES_YEAR_LOW is lower than civil_from_days can return');
  end;
  if YHigh - 1 <= JULIAN_YEAR_HIGH then begin
    Writeln('Error: DATE_PRIMITIVES_YEAR_HIGH is higher than civil_from_days can return');
  end;
  Writeln('Lowest supported julian day number: ', JULIAN_DAYS_LOW);
  Writeln('Highest supported julian day number: ', JULIAN_DAYS_HIGH);
  Writeln('Lowest supported julian year: ', YLow + 1);
  Writeln('Highest supported julian year: ', YHigh - 1);
  Y := -5877519;
  while Y <= 5879488 do begin
    M := 1;
    while M <= 12 do begin
      D := 1;
      while D <= last_day_of_month(Y, M) do begin
        Days := days_from_julian(Y, M, D);
        julian_from_days(Days, Civil);
        if (Y <> Civil.Year) or (M <> Civil.Month) or (D <> Civil.Day) then begin
          Writeln('Conversion FAILED for ', Y, ' ', M, ' ', D);
          Exit;
        end;
        Inc(D);
      end;
      Inc(M);
    end;
    Inc(Y);
  end;
  Days := -2147483648;
  while Days <= 2147483647 - 719470 do begin
    julian_from_days(Days, Civil);
    Res := days_from_julian(Civil.Year, Civil.Month, Civil.Day);
    if Days <> Res then begin
      Writeln('Conversion FAILED for ', Days);
      Exit;
    end;
    Inc(Days);
  end;
end;

procedure TestWeekdayDifference;
const
  A: array[0 .. 7 - 1] of array[0 .. 7 - 1] of LongInt = (
    (0, 6, 5, 4, 3, 2, 1),
    (1, 0, 6, 5, 4, 3, 2),
    (2, 1, 0, 6, 5, 4, 3),
    (3, 2, 1, 0, 6, 5, 4),
    (4, 3, 2, 1, 0, 6, 5),
    (5, 4, 3, 2, 1, 0, 6),
    (6, 5, 4, 3, 2, 1, 0)
  );
var
  X, Y: PtrInt;
begin
  for X := 0 to 6 do begin
    for Y := 0 to 6 do begin
      if weekday_difference(X, Y) <> A[X][Y] then begin
        Writeln('TestWeekdayDifference FAILED at ', X, ' ', Y);
        Exit;
      end;
    end;
  end;
end;

procedure TestJulian;
begin
  if days_from_julian(1582, 10, 5) <> days_from_civil(1582, 10, 15) then
    Writeln('Rome does not switch from Julian to Gregorian');
end;

function NextTuesday(Today: TDateInteger): TDateInteger;
const
  TUESDAY = 2;
var
  Tomorrow: TDateInteger;
  Delta: TDateInteger;
begin
  // We want to start from tomorrow, because today may be a tuesday and
  // in this case we want a week from today, not today.
  Tomorrow := Today + 1;
  // Compute number of days from tomorrow to tuesday
  Delta := weekday_difference(TUESDAY, weekday_from_days(Tomorrow));
  // Return the result
  Result := Tomorrow + Delta;
end;

procedure WriteDate(Days: TDateInteger);
var
  Civil: TYearMonthDay;
begin
  civil_from_days(Days, Civil);
  Write(Civil.Year, '-', Civil.Month, '-', Civil.Day);
end;

var
  I: LongInt;
  Year, Week, Day: TDateInteger;
  Civil: TYearMonthDay;
begin
  Writeln('Weekday of 1970-01-01: ', weekday_from_days(days_from_civil(1970, 1, 1)));
  Writeln(days_from_civil(1970, 1, 1));
  Writeln(days_from_civil(1970, 1, 30));
  Writeln(days_from_civil(1971, 1, 1));
  Writeln(days_from_civil(1980, 1, 1));
  Writeln(days_from_civil(2019, 7, 8));
  Write('leap years: ... ');
  for I := 2000 to 2050 do begin
    if is_leap(I) then
      Write(I, ' ');
  end;
  Writeln('...');
  Writeln('Start of week-based 2019: ', iso_week_start_from_year(2019));
  for I := 1 to 10 do begin
    iso_week_from_civil(2019, 1, I, Year, Week, Day);
    Write('2019-01-', I, ' -> ', Year, '-', Week, '-', Day);
    civil_from_iso_week(Year, Week, Day, Civil);
    if not ((Civil.Year = 2019) and (Civil.Month = 1) and (Civil.Day = I)) then
      Write(' (reverse conversion FAILED)');
    Writeln;
  end;
  Write('Next tuesday of 1970-01-01 is: ');
  WriteDate(NextTuesday(days_from_civil(1970, 1, 1)));
  Writeln;
  TestCivilDays;
  TestJulianDays;
  TestWeekdayDifference;
  TestJulian;
end.
