(*
	Copyright 2012 Steven! Ragnarök. All Rights Reserved.
	Solves Widgets Assignment by Professor Ron Mak as given in ASSIGNMENT.
*)
PROGRAM Widgets;
CONST
	NULLP         = pointer(0); (* NULL Pointer *)
	NULLC         = #0; (* NULL character *)
	MAXSTATES     = 50; (* Max number of possible states *)
	MAXPLANTS     = 50; (* Max number of possible plants *)
	MAXDEPTS      = 100; (* Max number of possible departments *)
	MAXEMPLOYEES  = 1000; (* Max number of possible employees *)
	HEADER1       = 'STATE PLANT DEPT EMPID COUNT NAME'; (* Table header line 1 *)
	HEADER2       = '----- ----- ---- ----- ----- ----'; (* Table header line 2 *)
  U10COUNT      = '                            '; (* spacing constant *)
	U100COUNT     = '                          '; (* Smaller spacing constant *)

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
		employees : array [1..MAXEMPLOYEES] of ^employee;
		id        : integer;
	END;
	plant = RECORD
		count       : integer;
		departments : array [1..MAXDEPTS] of ^department;
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
	ch        : char; (* For reading input by character *)
	empl      : employee; (* The current employee *)
	i         : integer; (* a generic counting index *)
	world     : array [1..MAXSTATES] of ^state; (* All states in the world *)
	total     : integer; (* Total number of widgets produced *)

(* Read a single employee from stdin *)
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
			inc(i);
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

(* Write an employee to stdout *)
PROCEDURE writeempl(e : employeep);
	PROCEDURE writename;
	VAR
		i : integer;
	BEGIN
		i := 1;
		WHILE e^.name[i] <> NULLC DO
		BEGIN
			write(e^.name[i]);
			inc(i);
		END;
	END;
BEGIN
	WITH e^ DO
	BEGIN
		write('   ', state, '    ', plant, '   ', dept, '   ', id);
		IF count < 10 tHEN
			write('     ')
		ELSE
			write('    ');
		write(count, ' ');
		writename;
		writeln;
	END
END;

(* Write a department to stdout *)
PROCEDURE writedept(d : deptp);
VAR
	i : integer;
BEGIN
	writeln;
	FOR i := 1 TO MAXEMPLOYEES DO
		IF not(d^.employees[i] = NULLP) THEN
			writeempl(d^.employees[i]);
	writeln;
	IF d^.count < 10 THEN
		write(U10COUNT)
	ELSE
		write(U100COUNT);
	writeln(d^.count, ' *    total for department ', d^.id);
END;

(* Write a plant to stdout *)
PROCEDURE writeplant(p : plantp);
VAR
	i : integer;
BEGIN
	FOR i := 1 TO MAXDEPTS DO
	BEGIN
		IF not(p^.departments[i] = NULLP) THEN
			writedept(p^.departments[i]);
	END;
	IF p^.count < 10 THEN
		write(U10COUNT)
	ELSE
		write(U100COUNT);
	writeln(p^.count, ' **   total for plant ', p^.id);
END;

(* Write a state to stdout *)
PROCEDURE writestate(s : statep);
VAR
	i : integer;
BEGIN
	FOR i := 1 TO MAXPLANTS DO
	BEGIN
		IF not(s^.plants[i] = NULLP) THEN
			writeplant(s^.plants[i]);
	END;
	IF s^.count < 10 THEN
		write(U10COUNT)
	ELSE
		write(U100COUNT);
	writeln(s^.count, ' ***  total for state ', s^.id)
END;

(* Write headers, states, and total to stdout *)
PROCEDURE writeworld;
BEGIN
	writeln(HEADER1);
	writeln(HEADER2);
	FOR i := 1 TO MAXSTATES DO
	BEGIN
		IF not(world[i] = NULLP) THEN
			writestate(world[i]);
	END;
	IF total < 10 THEN
		write(U10COUNT)
	ELSE
		write(U100COUNT);
	writeln(total, ' **** grand total');
END;

(* Find or initialize the desired state *)
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

(* Initialize the world *)
PROCEDURE initworld;
BEGIN
	total := 0;
	FOR i := 1 TO MAXSTATES DO
		world[i] := NULLP;
END;

(* Add an employee to a department *)
PROCEDURE appendtodept(d : deptp; e : employeep);
	FUNCTION copyemployee : employeep;
		FUNCTION copyname : textfield;
		VAR
			i : integer;
		BEGIN
			i := 1;
			WHILE e^.name[i] <> NULLC DO
			BEGIN
				copyname[i] := e^.name[i];
				inc(i);
			END;
			copyname[i] := NULLC;
		END;
	BEGIN
		copyemployee := new(employeep);
		copyemployee^.id := e^.id;
		copyemployee^.state := e^.state;
		copyemployee^.plant := e^.plant;
		copyemployee^.dept := e^.dept;
		copyemployee^.count := e^.count;
		copyemployee^.name := copyname;
	END;
BEGIN
	d^.count := d^.count + e^.count;
	d^.employees[e^.id] := copyemployee;
END;

(* Add an employee to a plant *)
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

(* Add an employee to a state *)
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

(* Read employees and fill the world with them *)
PROCEDURE fillworld;
BEGIN
	WHILE not(EOF) DO
	BEGIN
		readempl;
		total := total + empl.count;
		appendtostate(findstate(empl.state), @empl);
		read(ch); (* Eat the line feed *)
	END;
END;

(* Main program *)
BEGIN
	initworld;
	fillworld;
	writeworld;
END.
