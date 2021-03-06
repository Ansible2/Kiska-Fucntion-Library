/* ----------------------------------------------------------------------------
Function: KISKA_fnc_pickUpCrate

Description:
	Executes pick up action

Parameters:

	0: _crate <OBJECT> - The crate being picked up
	1: _caller <OBJECT> - The person picking up the crate

Returns:
	BOOL

Examples:
    (begin example)

		[crate1,player] call KISKA_fnc_pickUpCrate;

    (end)

Author:
	Ansible2 // Cipher
---------------------------------------------------------------------------- */
params [
	["_crate",objNull,[objNull]],
	["_caller",player,[objNull]]
];

// make player lower weapon if not done already
if !(weaponLowered _caller) then {
	_caller action ["WeaponOnBack",_caller];
};

// make them only walk
_caller forceWalk true;

// attach box to player
private _fn_getCrateAttachpoint = {
	params ["_crateType"];

	if (_crateType isEqualTo "B_supplyCrate_F") exitWith {
		[0,2,1]
	};
	if (_crateType isEqualTo "B_CargoNet_01_ammo_F") exitWith {
		[0,2,0.90]
	};
	// default
	[0,2,0.80]
};
private _crateAttachPoint = [typeOf _crate] call _fn_getCrateAttachpoint;

_crate attachTo [_caller,_crateAttachPoint];

// publicly set the crate as picked up
_crate setVariable ["DSO_cratePickedUp",true,true];

// add a drop action to the player
private _dropCrate_actionID = _caller addAction [
	"--Drop Crate",
	{
		private _caller = param [0,player,[objNull]];
		private _dropCrate_actionID = param [2,0,[123]];
		private _crate = param [3];

		[_crate,_caller,_dropCrate_actionID] call KISKA_fnc_dropCrate;
	},
	_crate,
	15,
	true,
	true,
	"",
	"",
	2
];

// this is to remove the action from the crate if it is loaded while picked up
_caller setVariable ["DSO_dropCrateActionID",_dropCrate_actionID];

[_crate,_caller,_dropCrate_actionID] spawn {
	params ["_crate","_caller","_dropCrate_actionID"];

	waitUntil {
		if (!alive _caller OR {!(_crate getVariable ["DSO_cratePickedUp",true])} OR {!(incapacitatedState _caller isEqualTo "")} OR {_caller getVariable ["ace_isUnconscious",false]}) exitWith {
			
			// checking if the crate has already been dropped by the player
			if (!isNil {_caller getVariable "DSO_dropCrateActionID"}) then {
				[_crate,_caller,_dropCrate_actionID] call KISKA_fnc_dropCrate;
			};

			true
		};

		sleep 0.25;

		false
	};
};

true