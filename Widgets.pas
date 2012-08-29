PROGRAM Widgets;
CONST
	NULLP     = pointer(0);
	NULLC     = #0;
	LF        = #10;
	MAXLN     = 12;
	MAXSTATES = 50;

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

	state      = RECORD
		id        : integer; 
		count     : integer; 
		employees : array[1..MAXLN] of employee;
		plants : array [1..MAXLN] of plant;
	END;

	statep = ^state;
	employeep = ^employee;

VAR
	ch        : char;
	empl      : employee;
	stt       : ^state;
	employees : array [1..MAXLN] of employee;
	emplcount : integer;
	i         : integer;
	world     : packed array [1..MAXSTATES] of ^state;

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
		empl.name[i] := NULLC;
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
		WHILE empl.name[i] <> NULLC DO
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

PROCEDURE reademployees;
BEGIN
	emplcount := 1;

	REPEAT
		readempl;
		employees[emplcount] := empl;
		inc(emplcount);
		read(ch); (* Eat the line feed *)
	UNTIL eof;
END;

PROCEDURE writeemployees;
BEGIN
	FOR emplcount := 1 TO MAXLN DO
	BEGIN
		empl := employees[emplcount];
		writeempl;
	END;
END;

PROCEDURE writestate;
BEGIN
	IF stt^.count < 10 THEN
		write('                           ')
	ELSE
		IF stt^.count < 100 THEN
			write('                          ')
		ELSE
			write('                         ');
	writeln(stt^.count, ' ***  total for state ', stt^.id)
END;

PROCEDURE writestates;
BEGIN
	FOR i := 1 TO MAXSTATES DO
	BEGIN
		stt := world[i];
		IF NOT(stt = NULLP) THEN
			writestate;
	END;
END;

FUNCTION findstate(stateid : integer) : statep;
BEGIN
	IF world[stateid] = NULLP THEN
		world[stateid] := new(statep);
		world[stateid]^.count := 0;
		world[stateid]^.id := stateid;
		findstate := world[stateid];
END;

PROCEDURE initworld;
BEGIN
	FOR i := 1 TO MAXSTATES DO
		world[i] := NULLP;
END;

PROCEDURE appendtostate(stt : statep; empl : employeep);
BEGIN
END;

PROCEDURE sortworld;
BEGIN
	FOR i := 1 TO emplcount DO
	BEGIN
		empl := employees[i];
		stt := findstate(empl.state);
		stt^.count := stt^.count + empl.count;
		appendtostate(@stt, @empl)
	END;
END;

BEGIN
	initworld;
	reademployees;
	writeemployees;
	sortworld;
	writestates;
END.
