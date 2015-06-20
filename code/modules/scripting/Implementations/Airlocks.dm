/*
 *	FUNCTIONS TO ADD:
 *
 *	Open/Close
 *	Shock
 *	Safety
 *	Access
 *	Bolts
 *	VOICE CONTROL!!!1!!!!2@!!!!!
 *	Speed
 *	AI Control
 *
 */

/n_Interpreter/TCS_Interpreter
	var/datum/TCS_Compiler/Compiler

	HandleError(runtimeError/e)
		Compiler.Holder.add_entry(e.ToString(), "Execution Error")

/datum/TCS_Compiler
	var/n_Interpreter/TCS_Interpreter/interpreter
	var/obj/machinery/door/airlock/Holder	// the server that is running the code
	var/ready = 1 // 1 if ready to run code

	/* -- Compile a raw block of text -- */

	proc/Compile(code as message)
		var/n_scriptOptions/nS_Options/options = new()
		var/n_Scanner/nS_Scanner/scanner       = new(code, options)
		var/list/tokens                        = scanner.Scan()
		var/n_Parser/nS_Parser/parser          = new(tokens, options)
		var/node/BlockDefinition/GlobalBlock/program   	 = parser.Parse()

		var/list/returnerrors = list()

		returnerrors += scanner.errors
		returnerrors += parser.errors

		if(returnerrors.len)
			return returnerrors

		interpreter 		= new(program)
		interpreter.persist	= 1
		interpreter.Compiler= src

		return returnerrors

	/* -- Execute the compiled code -- */

	proc/Run(var/datum/signal/signal)

		if(!ready)
			return

		if(!interpreter)
			return

		interpreter.container = src

		// Constants

		interpreter.SetVar("PI"		, 	3.141592653)	// value of pi
		interpreter.SetVar("E" 		, 	2.718281828)	// value of e
		interpreter.SetVar("SQURT2" , 	1.414213562)	// value of the square root of 2
		interpreter.SetVar("FALSE"  , 	0)				// boolean shortcut to 0
		interpreter.SetVar("TRUE"	,	1)				// boolean shortcut to 1

		interpreter.SetVar("NORTH" 	, 	NORTH)			// NORTH (1)
		interpreter.SetVar("SOUTH" 	, 	SOUTH)			// SOUTH (2)
		interpreter.SetVar("EAST" 	, 	EAST)			// EAST  (4)
		interpreter.SetVar("WEST" 	, 	WEST)			// WEST  (8)

		// Channel macros

		interpreter.SetVar("$common",	1459)
		interpreter.SetVar("$science",	1351)
		interpreter.SetVar("$command",	1353)
		interpreter.SetVar("$medical",	1355)
		interpreter.SetVar("$engineering",1357)
		interpreter.SetVar("$security",	1359)
		interpreter.SetVar("$supply",	1347)
		interpreter.SetVar("$service",	1349)

		// Signal data

		interpreter.SetVar("$content", 	signal.data["message"])
		interpreter.SetVar("$freq"   , 	signal.frequency)
		interpreter.SetVar("$source" , 	signal.data["name"])
		interpreter.SetVar("$job"    , 	signal.data["job"])
		interpreter.SetVar("$sign"   ,	signal)
		interpreter.SetVar("$pass"	 ,  !(signal.data["reject"])) // if the signal isn't rejected, pass = 1; if the signal IS rejected, pass = 0

		// Set up the script procs

		/*
			-> Opens or closes the door. Wow.
					@format: open(open, autoclose)

					@param open:		BOOLEAN IS DOOR OPEN OR CLOSE? WHAT
					@param autoclose:	BOOLEAN DOES DOOR AUTOMATICALLY CLOSE? WHAAAAAT
		*/
		interpreter.SetProc("open", "dooropen", signal, list("open", "autoclose"))

		/*
			-> Store a value permanently to the airlock
					@format: mem(address, value)

					@param address:		The memory address (string index) to store a value to
					@param value:		The value to store to the memory address
		*/
		interpreter.SetProc("mem", "mem", signal, list("address", "value"))

		/*
			-> Delay code for a given amount of deciseconds
					@format: sleep(time)

					@param time: 		time to sleep in deciseconds (1/10th second)
		*/
		interpreter.SetProc("sleep", /proc/delay)

		/*
			-> Replaces a string with another string
					@format: replace(string, substring, replacestring)

					@param string: 			the string to search for substrings (best used with $content$ constant)
					@param substring: 		the substring to search for
					@param replacestring: 	the string to replace the substring with

		*/
		interpreter.SetProc("replace", /proc/string_replacetext)

		/*
			-> Locates an element/substring inside of a list or string
					@format: find(haystack, needle, start = 1, end = 0)

					@param haystack:	the container to search
					@param needle:		the element to search for
					@param start:		the position to start in
					@param end:			the position to end in

		*/
		interpreter.SetProc("find", /proc/smartfind)

		/*
			-> Finds the length of a string or list
					@format: length(container)

					@param container: the list or container to measure

		*/
		interpreter.SetProc("length", /proc/smartlength)

		/* -- Clone functions, carried from default BYOND procs --- */

		// vector namespace
		interpreter.SetProc("vector", /proc/n_list)
		interpreter.SetProc("at", /proc/n_listpos)
		interpreter.SetProc("copy", /proc/n_listcopy)
		interpreter.SetProc("push_back", /proc/n_listadd)
		interpreter.SetProc("remove", /proc/n_listremove)
		interpreter.SetProc("cut", /proc/n_listcut)
		interpreter.SetProc("swap", /proc/n_listswap)
		interpreter.SetProc("insert", /proc/n_listinsert)

		interpreter.SetProc("pick", /proc/n_pick)
		interpreter.SetProc("prob", /proc/prob_chance)
		interpreter.SetProc("substr", /proc/docopytext)

		// Donkie~
		// Strings
		interpreter.SetProc("lower", /proc/n_lower)
		interpreter.SetProc("upper", /proc/n_upper)
		interpreter.SetProc("explode", /proc/string_explode)
		interpreter.SetProc("repeat", /proc/n_repeat)
		interpreter.SetProc("reverse", /proc/n_reverse)
		interpreter.SetProc("tonum", /proc/n_str2num)

		// Numbers
		interpreter.SetProc("tostring", /proc/n_num2str)
		interpreter.SetProc("sqrt", /proc/n_sqrt)
		interpreter.SetProc("abs", /proc/n_abs)
		interpreter.SetProc("floor", /proc/n_floor)
		interpreter.SetProc("ceil", /proc/n_ceil)
		interpreter.SetProc("round", /proc/n_round)
		interpreter.SetProc("clamp", /proc/n_clamp)
		interpreter.SetProc("inrange", /proc/n_inrange)
		// End of Donkie~


		// Run the compiled code
		interpreter.Run()

		// Backwards-apply variables onto signal data
		/* sanitize EVERYTHING. fucking players can't be trusted with SHIT */ // <-- Lol true

		signal.data["message"] 	= interpreter.GetVar("$content")
		signal.frequency 		= interpreter.GetVar("$freq")

		var/setname = ""
		var/obj/machinery/door/airlock/S = signal.data["server"]
		if(interpreter.GetVar("$source") in S.stored_names)
			setname = interpreter.GetVar("$source")
		else
			setname = "<i>[interpreter.GetVar("$source")]</i>"

		if(signal.data["name"] != setname)
			signal.data["realname"] = setname
		signal.data["name"]		= setname
		signal.data["job"]		= interpreter.GetVar("$job")
		signal.data["reject"]	= !(interpreter.GetVar("$pass")) // set reject to the opposite of $pass

		// If the message is invalid, just don't broadcast it!
		if(signal.data["message"] == "" || !signal.data["message"])
			signal.data["reject"] = 1

/*  -- Actual language proc code --  */

datum/signal

	proc/mem(var/address, var/value)

		if(istext(address))
			var/obj/machinery/door/airlock/A = data["server"]

			if(!value && value != 0)
				return A.memory[address]

			else
				A.memory[address] = value


	proc/dooropen(var/open, var/autoclose)

		if(open || !open)
			var/obj/machinery/door/airlock/A = data["server"]

			if(autoclose || !autoclose)
				A.autoclose = autoclose

			if(open)
				A.open()
			else
				A.close()