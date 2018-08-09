/***************************************************************************
 * glut_example.cpp is part of Math Graphic Library
 * Copyright (C) 2007-2012 Alexey Balakin <mathgl.abalakin@gmail.ru>       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/
#include "mgl2/glut.h"
//-----------------------------------------------------------------------------
int test_wnd(mglGraph *gr);
int sample(mglGraph *gr);
int sample_m(mglGraph *gr);
int sample_1(mglGraph *gr);
int sample_2(mglGraph *gr);
int sample_3(mglGraph *gr);
int sample_d(mglGraph *gr);
//-----------------------------------------------------------------------------
typedef int (*draw_func)(mglGraph *gr);
int main(int argc,char **argv)
{
	char key = 0;
	if(argc>1)	key = argv[1][0]!='-' ? argv[1][0] : argv[1][1];
	else	printf("You may specify argument '1', '2', '3' or 'd' for viewing examples of 1d, 2d, 3d or dual plotting\n");

	const char *desc;
	draw_func func;
	switch(key)
	{
	case '1':	func = sample_1;	desc = "1D plots";	break;
	case '2':	func = sample_2;	desc = "2D plots";	break;
	case '3':	func = sample_3;	desc = "3D plots";	break;
	case 'd':	func = sample_d;	desc = "Dual plots";	break;
	case 't':	func = test_wnd;	desc = "Testing";	break;
	default:	func = sample;	desc = "Example of molecules";	break;
	}
	mglGLUT gr(func,desc);
	return 0;
}
//-----------------------------------------------------------------------------
