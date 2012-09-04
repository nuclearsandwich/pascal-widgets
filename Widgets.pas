PROGRAM Widgets;
CONST
	NULLP         = pointer(0);
	NULLC         = #0;
	LF            = #10;
	MAXLN         = 12;
	MAXSTATES     = 50;
	MAXPLANTS     = 50;
	MAXDEPTS      = 100;
	MAXEMPLOYEES  = 100;

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

	department = RECORD
		count     : integer;
		employees : packed array [1..MAXEMPLOYEES] of ^employee;
		id        : integer;
	END;

	plant = RECORD
		count       : integer;
		departments : packed array [1..MAXDEPTS] of ^department;
		id          : integer;
	END;

	state = RECORD
		count  : integer; 
		id     : integer; 
		plants : array [1..MAXPLANTS] of ^plant;
	END;

	deptp     = ^department;
	employeep = ^employee;
	plantp    = ^plant;
	statep    = ^state;

VAR
	ch        : char;
	empl      : employee;
	employees : array [1..MAXLN] of employee;
	emplcount : integer;
	i         : integer;
	world     : packed array [1..MAXSTATES] of ^state;

PROCEDURE readempl;
	PROCEDURE readname;
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

PROCEDURE writeempl(e : employeep);
	PROCEDURE writename;
	VAR
		i : integer;
	BEGIN
		i := 1;
		WHILE e^.name[i] <> NULLC DO
		BEGIN
			write(ErrOutput, empl.name[i]);
			i := i + 1;
		END;
	END;
BEGIN
	WITH e^ DO
	BEGIN
		write('   ', state, '   ', plant, '   ', dept, '   ', id);
		IF count > 10 tHEN
			write('     ')
		ELSE
			write('    ');
		write(count);
		write(' ');
		writename;
		writeln;
	END
END;

PROCEDURE reademployees;
BEGIN
	emplcount := 0;
	WHILE Not(EOF) DO
	BEGIN
		inc(emplcount);
		readempl;
		employees[emplcount] := empl;
		read(ch); (* Eat the line feed *)
	END;
END;

PROCEDURE writedept(d : deptp);
VAR
	i : integer;
BEGIN
	FOR i := 1 TO MAXEMPLOYEES DO
	BEGIN
		IF Not(d^.employees[i] = NULLP) THEN
			writeempl(d^.employees[i]);
	END;
END;

PROCEDURE writeplant(p : plantp);
VAR
	i : integer;
BEGIN
	FOR i := 1 TO MAXDEPTS DO
	BEGIN
		IF Not(p^.departments[i] = NULLP) THEN
			writedept(p^.departments[i]);
	END;
	writeln('              ** total for plant ', p^.id);
END;

PROCEDURE writestate(s : statep);
VAR
	i : integer;
BEGIN
	FOR i := 1 TO MAXPLANTS DO
	BEGIN
		IF Not(s^.plants[i] = NULLP) THEN
			writeplant(s^.plants[i]);
	END;

	IF s^.count < 10 THEN
		write('                           ')
	ELSE
		IF s^.count < 100 THEN
			write('                          ')
		ELSE
			write('                         ');
	writeln(s^.count, ' ***  total for state ', s^.id)
END;

PROCEDURE writeworld;
BEGIN
	FOR i := 1 TO MAXSTATES DO
	BEGIN
		IF Not(world[i] = NULLP) THEN
			writestate(world[i]);
	END;
END;


FUNCTION findstate(stateid : integer) : statep;
	FUNCTION initstate : statep;
	VAR
		index : integer;
	BEGIN
		initstate := new(statep);
		initstate^.count := 0;
		initstate^.id := stateid;
		FOR index := 1 TO MAXPLANTS DO
			initstate^.plants[index] := NULLP;
	END;
BEGIN
	IF world[stateid] = NULLP THEN
		world[stateid] := initstate;
	findstate := world[stateid];
END;

PROCEDURE initworld;
BEGIN
	FOR i := 1 TO MAXSTATES DO
		world[i] := NULLP;
END;

PROCEDURE appendtodept(d : deptp; e : employeep);
BEGIN
	d^.count := d^.count + e^.count;
	d^.employees[e^.id] := e;
END;

PROCEDURE appendtoplant(p : plantp; e : employeep);
	FUNCTION finddept(deptid : integer) : deptp;
		FUNCTION initdept : deptp;
		BEGIN
			initdept := new(deptp);
			initdept^.count := 0;
			initdept^.id := deptid;
		END;
	BEGIN
		IF p^.departments[deptid] = NULLP THEN
			p^.departments[deptid] := initdept;
		finddept := p^.departments[deptid];
	END;
BEGIN
	p^.count := p^.count + e^.count;
	appendtodept(finddept(e^.dept), e);
END;

PROCEDURE appendtostate(s : statep; e : employeep);
	FUNCTION findplant(plantid : integer) : plantp;
		FUNCTION initplant : plantp;
		VAR
			i : integer;
		BEGIN
			initplant := new(plantp);
			initplant^.count := 0;
			initplant^.id := plantid;
			FOR i := 1 TO MAXDEPTS DO
				initplant^.departments[i] := NULLP;
		END;
	BEGIN
		IF s^.plants[plantid] = NULLP THEN
			s^.plants[plantid] := initplant;
		findplant := s^.plants[plantid];
	END;
BEGIN
	s^.count := s^.count + e^.count;
	appendtoplant(findplant(e^.plant), e);
END;

PROCEDURE fillworld;
VAR
	i : integer;
BEGIN
	FOR i := 1 TO emplcount DO
	BEGIN
		empl := employees[i];
		appendtostate(findstate(empl.state), @empl)
	END;
END;

BEGIN
	initworld;
	reademployees;
	fillworld;
	writeworld;
END.
