with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;

procedure cal is
    LYear : Integer;
    First_Day : Integer;
    Language : String(1..7);
    Weeks_Per_Month : constant := 6;
    Days_Per_Week : constant := 7;

    -- Type to represent a week
    type Week is array (1 .. Days_Per_Week) of Integer;

    -- Type to represent a month as several weeks
    type Month is array (1 .. Weeks_Per_Month) of Week;

    -- Type to represent the entire year as a 4x3 structure
    type Year_Calendar is array (1 .. 4, 1 .. 3) of Month;

    -- The calendar for the year
    Calendar : Year_Calendar;

    -- Subprogram to check if the year is valid
    function isvalid(Year : in Integer) return Boolean is
    begin
        return Year >= 1582; -- The Gregorian calendar started in 1582
    end isvalid;

    -- Subprogram to read the calendar information
    procedure readcalinfo(Year : out Integer; FirstDay : out Integer; Lang : out String) is
        Valid : Boolean := False;
        Y : Integer;
        Temp_Lang : String(1..7);
    begin
        loop
            Ada.Text_IO.Put("Enter year (>=1582): ");
            Ada.Integer_Text_IO.Get(Year);
            Ada.Text_IO.Skip_Line;  -- Skip the remaining line after the input

            Valid := isvalid(Year);  -- Check if the entered year is valid

            exit when Valid;  -- Exit the loop if the year is valid

            Ada.Text_IO.Put_Line("Invalid year. Please try again.");  -- Prompt to re-enter if the year is invalid
        end loop;

        -- Calculate the day on which January 1st falls using the given formula
        Y := Year - 1;
        FirstDay := (36 + Y + (Y / 4) - (Y / 100) + (Y / 400) + 1) mod 7;

        loop
            Ada.Text_IO.Put("Enter language (English/French )'type 'French ' for french to match spacing': ");
            Ada.Text_IO.Get(Temp_Lang);

            if Temp_Lang = "English" then 
                Lang := "English";
                exit;  -- Exit the loop if a valid language is entered
            elsif Temp_Lang = "French " then
                Lang := "French ";
                exit;
            else
                Ada.Text_IO.Put_Line("Invalid language. Please enter 'English' or 'French '.");
            end if;
        end loop;
    end readcalinfo;


    -- Subprogram to check if a year is a leap year
    function leapyear(year : Integer) return Boolean is
    begin
        return (year mod 4 = 0) and then ((year mod 100 /= 0) or else (year mod 400 = 0));
    end leapyear;

    -- Subprogram to return the number of days in a given month and year
    function numdaysinmonth(month : Integer; year : Integer) return Integer is
        days : Integer;
    begin
        case month is
            when 1 | 3 | 5 | 7 | 8 | 10 | 12 => days := 31;
            when 4 | 6 | 9 | 11 => days := 30;
            when 2 =>
                if leapyear(year) then
                    days := 29;
                else
                    days := 28;
                end if;
            when others => 
                days := 0; -- Invalid month
        end case;
        return days;
    end numdaysinmonth;

    -- Subprogram to build the calendar
    procedure buildcalendar is
        -- Procedure to fill in the month data
        procedure FillMonth(Month_Index : Integer; Year : Integer; First_Day : in out Integer) is
            Month_Days : constant Integer := numdaysinmonth(Month_Index, Year);
            Day : Integer := 1;
            Week_Index : Integer := 1;
            Day_Of_Week : Integer := First_Day;
            Row : constant Integer := (Month_Index - 1) / 3 + 1;
            Col : constant Integer := (Month_Index - 1) mod 3 + 1;
            Current_Month : Month := (others => (others => 0)); -- Initialize all days to zero
        begin
            -- Fill the days for the current month
            while Day <= Month_Days loop
                Current_Month(Week_Index)(Day_Of_Week) := Day;
                Day := Day + 1;
                Day_Of_Week := Day_Of_Week mod Days_Per_Week + 1;
                if Day_Of_Week = 1 then
                    Week_Index := Week_Index + 1;
                end if;
            end loop;

            -- Set the first day for the next month
            First_Day := Day_Of_Week;
            Calendar(Row, Col) := Current_Month; -- Save the updated month back to the Calendar
        end FillMonth;

        begin
            -- Read the year info and first day
            readcalinfo(LYear, First_Day, Language);
            -- Fill in the calendar for each month
            for Month_Index in 1 .. 12 loop
                FillMonth(Month_Index, LYear, First_Day);
            end loop;
        end buildcalendar;
        
    -- Procedure to print the month name
    procedure printmonthname(month : Integer) is
        month_names_english : constant array(1..12) of String(1..9) := 
            ("January  ", "feburary ", "march    ", "april    ",
             "may      ", "june     ", "july     ", "august   ",
             "september", "october  ", "november ", "december ");
        month_names_french  : constant array(1..12) of String(1..9) := 
            ("janvier  ", "fevrier  ", "mars     ", "avril    ",
             "mai      ", "juin     ", "juillet  ", "aout     ",
             "septembre", "octobre  ", "novembre ", "decembre ");
    begin
        if Language = "English" then
            Put(month_names_english(month));
        elsif Language = "French " then
            Put(month_names_french (month));
        end if;
    end printmonthname;

    
    procedure printrowheading(month1, month2, month3 : Integer) is
        days_english : constant String := " Su Mo Tu We Th Fr Sa";
        days_french  : constant String := " Di Lu Ma Me Je Ve Sa";
    begin
        -- Print the heading for a row of three months
        Ada.Text_IO.Put("          ");
        printmonthname(month1);
        Ada.Text_IO.Put("         ");
        printmonthname(month2);
        Ada.Text_IO.Put("             "); 
        printmonthname(month3);
        Ada.Text_IO.New_Line;

        -- Print the days of the week headers based on the selected language
        if Language = "English" then
            Ada.Text_IO.Put_Line(days_english & "  " & days_english & "  " & days_english);
        elsif Language = "French " then
            Ada.Text_IO.Put_Line(days_french  & "  " & days_french  & "  " & days_french );
        end if;
    end printrowheading;

    procedure printday(day : Integer) is
    begin
        if day = 0 then
            Ada.Text_IO.Put("   ");
        else
            if day < 10 then
                Ada.Text_IO.Put(" ");
            end if;
            Ada.Integer_Text_IO.Put(day, 0);
            Ada.Text_IO.Put(" ");
        end if;
    end printday;

    procedure printrowmonth(Row : Integer) is
    begin
        -- Iterate through each week (maximum of 6) of the months
        for Week_Index in 1 .. Weeks_Per_Month loop
            -- Print the weeks for each of the three months in the row
            for Col in 1 .. 3 loop
                for Day_Of_Week in 1 .. Days_Per_Week loop
                    printday(Calendar(Row, Col)(Week_Index)(Day_Of_Week));
                end loop;

                -- Add spacing between months unless it's the last month in the row
                if Col < 3 then
                    Ada.Text_IO.Put("  ");
                end if;
            end loop;

            -- New line after printing a week for each of the three months
            Ada.Text_IO.New_Line;
            -- Check if we have reached the end of the month to exit the loop
            if Week_Index = Weeks_Per_Month or else
            (Calendar(Row, 1)(Week_Index + 1)(1) = 0 and
                Calendar(Row, 2)(Week_Index + 1)(1) = 0 and
                Calendar(Row, 3)(Week_Index + 1)(1) = 0) then
                exit; -- If the next week's first day slot of all three months is 0, printed all weeks
            end if;
        end loop;
    end printrowmonth;



procedure banner(Year : in Integer; Indent : in Integer) is
    type Font_Line is array(1 .. 7) of Character;
    type Font_Array is array(1 .. 10) of Font_Line;
    type Font_Data is array(0 .. 9) of Font_Array;

    -- font for banner did a list implementation rather than data file 
    Font : constant Font_Data := (
        ( -- 0
            "  0 0  ", " 0   0 ", "0     0", "0     0", "0     0", 
            "0     0", "0     0", "0     0", "  0 0  ",(others => ' ')
        ),
        ( -- 1
            "   1   ", "  11   ", " 1 1   ", "   1   ", "   1   ", 
            "   1   ", "   1   ", "   1   ", " 11111 ", (others => ' ')
        ),
        ( -- 2
            "  222  ", " 2   2 ", "     2 ", "    2  ", "   2   ", 
            "  2    ", " 2     ", "2      ", "222222 ", (others => ' ')
        ),
        ( -- 3
            " 333   ", "3   3  ", "    3  ", "  333  ", "  333  ", 
            "    3  ", "    3  ", "3   3  ", " 333   ", (others => ' ')
        ),
        ( -- 4
            "    4  ", "   44  ", "  4 4  ", " 4  4  ", "4   4  ", 
            "444444 ", "    4  ", "    4  ", "    4  ", (others => ' ')
        ),
        ( -- 5
            "555555 ", "5      ", "5      ", "55555  ", "    5  ", 
            "    5  ", "    5  ", "5   5  ", " 555   ", (others => ' ')
        ),
        ( -- 6
            " 6666  ", "6      ", "6      ", "66666  ", "6   6  ", 
            "6   6  ", "6   6  ", "6   6  ", " 666   ", (others => ' ')
        ),
        ( -- 7
            "777777 ", "    7  ", "   7   ", "  7    ", " 7     ", 
            "7      ", "7      ", "7      ", "7      ", (others => ' ')
        ),
        ( -- 8
            " 8888  ", "8    8 ", "8    8 ", " 8888  ", "8    8 ", 
            "8    8 ", "8    8 ", "8    8 ", " 8888  ", (others => ' ')
        ),
        ( -- 9
            " 9999  ", "9   9  ", "9   9  ", "9   9  ", " 99999 ", 
            "    9  ", "    9  ", "   9   ", " 9     ", (others => ' ')
        )
    );


    -- Convert year to string and calculate its length
    Year_Str : constant String := Integer'Image(Year);

begin
    -- Print the banner line by line
    for Line in 1 .. 10 loop
        -- Indent at the beginning of each line
        for I in 1 .. Indent loop
            Ada.Text_IO.Put(" ");
        end loop;
        
        -- Print each digit of the year in large font
        for Index in Year_Str'Range loop
            if Year_Str(Index) in '0' .. '9' then
                declare
                    Digit_Index : constant Natural := Character'Pos(Year_Str(Index)) - Character'Pos('0');
                begin
                    -- Print the corresponding line of the banner for the digit
                    for Char_Pos in Font_Line'Range loop
                        Ada.Text_IO.Put(Font(Digit_Index)(Line)(Char_Pos));
                    end loop;
                end;
            end if;
        end loop;
        
        -- New line after each line of the banner
        Ada.Text_IO.New_Line;
    end loop;
end banner;


begin
    -- Read the calendar information from the user
    buildcalendar;

    -- Check if the year is a leap year and print the result
    if leapyear(LYear) then
        if Language = "English" then
            Put_Line("It's a leap year.");
        elsif Language = "French " then
            Put_Line("C'est une année bissextile.");
        end if;
    else
        if Language = "English" then
            Put_Line("It's not a leap year.");
        elsif Language = "French " then
            Put_Line("Ce n'est pas une année bissextile.");
        end if;
    end if;

    banner(LYear, 10);

    -- Build the calendar for the year
    Ada.Text_IO.New_Line; -- Additional line for spacing before printing the months

    -- Print the months of the year, organized in 4 rows of 3 months each
    for Row in 1 .. 4 loop
        -- Print the row heading with month names and days of the week
        printrowheading((Row - 1) * 3 + 1, (Row - 1) * 3 + 2, (Row - 1) * 3 + 3);
        -- Print the months in the row
        printrowmonth(Row);
        Ada.Text_IO.New_Line; -- Add a new line after each row of months
    end loop;
end  cal;