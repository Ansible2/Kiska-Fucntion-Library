/* ----------------------------------------------------------------------------
Function: KISKA_fnc_datalinkMsg

Description:
	Displays a message to the player and creates a diary entry of that message

Parameters:

	0: _message <STRING> - ...
	1: _waitTime <NUMBER> - How long to wait before playing message (0 is instantly)
	2: _playSound <BOOL> - Play PTT sound effect

Returns:
	NOTHING 

Examples:
    (begin example)

		["this is the message", 0, true] call KISKA_fnc_datalinkMsg;

    (end)

Author:
	Ansible2 // Cipher
---------------------------------------------------------------------------- */
#define KISKA_DIARY "KISKA Systems"
scriptName "KISKA_fnc_datalinkMsg";

if !(hasInterface) exitWith {};

params [ 
	["_message","Message",[]], 
	["_waitTime",0,[1]],
	["_playSound",true,[true]] 
];

[
	{
		private _message = param [0];
		if (_this select 1) then {
			playSound "KISKA_ptt";
		};

		[["DATALINK",1.1,[0.75,0,0,1]],_message,false] call CBA_fnc_notify;
		
		if !(player diarySubjectExists KISKA_DIARY) then {
			player createDiarySubject [KISKA_DIARY, KISKA_DIARY];
		};

		player createDiaryRecord [KISKA_DIARY,["Datalink Messages","-"+_message]];

	}, 
	[_message,_playSound], 
	_waitTime
] call CBA_fnc_waitAndExecute;