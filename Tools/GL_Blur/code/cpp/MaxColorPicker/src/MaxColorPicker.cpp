//**************************************************************************/
// Copyright (c) 1998-2007 Autodesk, Inc.
// All rights reserved.
// 
// These coded instructions, statements, and computer programs contain
// unpublished proprietary information written by Autodesk, Inc., and are
// protected by Federal copyright law. They may not be disclosed to third
// parties or copied or duplicated in any form, in whole or in part, without
// the prior written consent of Autodesk, Inc.
#include <limits>
#include <sstream>

#include <max.h>

#include <maxscript/maxscript.h>
#include <maxscript/kernel/value.h>
#include <maxscript/foundation/arrays.h>
#include <maxscript/foundation/name.h>
#include <maxscript/foundation/numbers.h>
#include <maxscript/foundation/strings.h>
#include <maxscript/foundation/structs.h>
#include <maxscript/foundation/3dmath.h>
#include <maxscript/foundation/arrays.h>
#include <maxscript/foundation/collection.h>
#include <maxscript/maxwrapper/mxsobjects.h>
#include <maxscript/maxwrapper/maxclasses.h>

#include <maxscript/macros/define_instantiation_functions.h>

#include <maxscript/kernel/exceptions.h>

def_visible_primitive(spColorPick, "spColorPick");

///////////////////////////////////////////////////////////////////////////////
// color picker : needed by environment artists
///////////////////////////////////////////////////////////////////////////////
static Color	col(0.0f, 0.0f, 0.0f);
static bool		pressed	= false;
static bool		hooked	= false;

LRESULT CALLBACK
MouseHookProc(int nCode, WPARAM wParam, LPARAM lParam)
{
	if (nCode >= 0)
	{
		if( wParam == WM_RBUTTONDOWN )
			pressed	= true;

		if( wParam == WM_RBUTTONUP && pressed )
		{
			HDC	hdc	= GetDC(NULL);
			if( hdc )
			{
				POINT	cursor;
				GetCursorPos(&cursor);

				COLORREF	color	= GetPixel(hdc, cursor.x, cursor.y);
				int red		= GetRValue(color);
				int green	= GetGValue(color);
				int blue	= GetBValue(color);

				col.r	= red / 255.0f;
				col.g	= green / 255.0f;
				col.b	= blue / 255.0f;

				ReleaseDC(NULL, hdc);
			}
			pressed	= false;
			hooked	= false;
		}
	}
	return CallNextHookEx(0, nCode, wParam, lParam);
}

Point3Value _sp_p3value(0.0f, 0.0f, 0.0f);

Value*
spColorPick_cf(Value** arg_list, int count)
{
	// set output stream
	CharStream*	out = thread_local(current_stdout);
	hooked	= true;
	
	HHOOK mousehook = SetWindowsHookEx(WH_MOUSE_LL, MouseHookProc, GetModuleHandle(NULL), 0);
	
	out->printf("Enter color selection mode (Right Button click for selection)\n", col.r, col.g, col.b);
	
	MSG msg;	
	while( GetMessage(&msg,0,0,0) && hooked )
	{
		if( msg.message != WM_RBUTTONDOWN && 
			msg.message != WM_RBUTTONUP )
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}

	UnhookWindowsHookEx(mousehook);

	out->printf("Selected color (%f, %f, %f)\n", col.r, col.g, col.b);

	_sp_p3value	= Point3Value(col.r, col.g, col.b);
	return &_sp_p3value;
}

