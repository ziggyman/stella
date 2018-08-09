/***************************************************************************
 * qt_example.cpp is part of Math Graphic Library
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
#include "mgl2/qt.h"
#if defined(WIN32) || defined(_MSC_VER) || defined(__BORLANDC__)
#include <windows.h>
#else
#include <unistd.h>
#endif
//-----------------------------------------------------------------------------
int test_wnd(mglGraph *gr);
int sample(mglGraph *gr);
int sample_1(mglGraph *gr);
int sample_2(mglGraph *gr);
int sample_3(mglGraph *gr);
int sample_d(mglGraph *gr);
//-----------------------------------------------------------------------------
//#define PTHREAD_SAMPLE
mglPoint pnt;  // some global variable for changeable data
void *mgl_qt_tmp(void *);
//-----------------------------------------------------------------------------
class Foo : public mglDraw
{
	mglPoint pnt;  // some result of calculation
public:
	mglWnd *Gr;  // graphics to be updated
	int Draw(mglGraph *gr);
	void Calc();
};
//-----------------------------------------------------
void Foo::Calc()
{
	for(int i=0;i<30;i++)   // do calculation
	{
#if defined(WIN32) || defined(_MSC_VER) || defined(__BORLANDC__)
		Sleep(1000);
#else
		sleep(1);           // which can be very long
#endif
		pnt = mglPoint(2*mgl_rnd()-1,2*mgl_rnd()-1);
		Gr->Update();        // update window
	}
}
//-----------------------------------------------------
int Foo::Draw(mglGraph *gr)
{
	gr->Line(mglPoint(),pnt,"Ar2");
	gr->Box();
	return 0;
}
//-----------------------------------------------------
int main(int argc,char **argv)
{
#ifdef PTHREAD_SAMPLE
	Foo *foo = new Foo;
	mglQT gr(foo,"MathGL examples");
	foo->Gr = &gr;   foo->Run();
	return gr.Run();
#else
	mglQT *gr;
	char key = 0;
	if(argc>1)	key = argv[1][0]!='-' ? argv[1][0]:argv[1][1];
	else	printf("You may specify argument '1', '2', '3' or 'd' for viewing examples of 1d, 2d, 3d or dual plotting\n");
	switch(key)
	{
	case '1':	gr = new mglQT(sample_1,"1D plots");	break;
	case '2':	gr = new mglQT(sample_2,"2D plots");	break;
	case '3':	gr = new mglQT(sample_3,"3D plots");	break;
	case 'd':	gr = new mglQT(sample_d,"Dual plots");	break;
	case 't':	gr = new mglQT(test_wnd,"Testing");	break;
	default: 	gr = new mglQT(sample,"Drop and waves");	break;
	}
	gr->Run();	return 0;
#endif
}
//-----------------------------------------------------------------------------
