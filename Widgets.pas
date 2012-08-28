PROGRAM Widgets;
CONST
	NULLB = #0;
	LF    = #10;
	MAXLN = 12;

TYPE
	textfield  = packed array [1..64] of char;

	employee = RECORD
		count       : integer;
		dept        : integer;
		id          : integer;
		name        : textfield;
		plant       : integer;
		state       : integer;
	END;

	department = array [1..MAXLN] of employee;
	plant      = array [1..MAXLN] of department;
	state      = array [1..MAXLN] of plant;

VAR
	ch        : char;
	empl      : employee;
	employees : array [1..MAXLN] of employee;
	world     : array [1..MAXLN] of state;
	emplcount : integer;

PROCEDURE readempl;
	PROCEDURE readname;
	VAR
		ch : char;
		i  : integer;
	BEGIN
		i := 1;
		read(ch);
		IF ch = ' ' THEN
			read(ch);
		WHILE ch <> ':' DO
		BEGIN
			empl.name[i] := ch;
			i := i + 1;
			read(ch);
		END;
		empl.name[i] := nullb;
		read(ch);
	END;

BEGIN
	read(empl.state);
	read(empl.plant);
	read(empl.dept);
	read(empl.id);
	readname;
	read(empl.count);
END;

PROCEDURE writeempl;
	PROCEDURE writename;
	VAR
		i : integer;
	BEGIN
		i := 1;
		WHILE empl.name[i] <> nullb DO
		BEGIN
		write(ErrOutput, empl.name[i]);
			i := i + 1;
		END;
	END;
BEGIN

	WITH empl DO
	BEGIN
		write(ErrOutput, 'State: ', state, ' Plant: ', plant, ' Dept: ', dept, ' ID: ', id, ' Name: ');
		writename;
		write(ErrOutput, ' Widgets: ', count);
		writeln(ErrOutput);
	END
END;

BEGIN
emplcount := 1;
	REPEAT
		readempl;
		writeempl;
		employees[emplcount] := empl;
		inc(emplcount);
		read(ch);
	UNTIL eof;
END.
