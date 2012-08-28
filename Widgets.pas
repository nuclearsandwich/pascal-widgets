PROGRAM Widgets;
CONST
	nullb = #0;

TYPE
	textfield = packed array [1..64] of char;
	employee = RECORD
		dept        : integer;
		id          : integer;
		name        : textfield;
		plant       : integer;
		state       : integer;
		widgetcount : integer;
	END;

	department = array [1..12] of employee;
	plant      = array [1..12] of department;
	state      = array [1..12] of plant;

VAR
	world : array [1..12] of state;

PROCEDURE readempl;
VAR
	count : integer;
	dept  : integer;
	id    : integer;
	name  : textfield;
	plant : integer;
	state : integer;

	PROCEDURE readname(VAR name : textfield);
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
			name[i] := ch;
			i := i + 1;
			read(ch);
		END;
		name[i] := nullb;
		read(ch);
	END;

	PROCEDURE writename(name : textfield);
	VAR
		i : integer;
	BEGIN
		i := 1;
		WHILE name[i] <> nullb DO
		BEGIN
			write(name[i]);
			i := i + 1;
		END;
	END;

BEGIN
	read(state);
	read(plant);
	read(dept);
	read(id);
	readname(name);
	read(count);
	write('State: ', state, ' Plant: ', plant, ' Dept: ', dept, ' ID: ', id, ' Name: ');
	writename(name);
	write(' Widgets: ', count);
	writeln;
	employee();
END;


BEGIN
	readempl;
END.
