/***************************************************************************
 * glut.h is part of Math Graphic Library
 * Copyright (C) 2007-2012 Alexey Balakin <mathgl.abalakin@gmail.ru>       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Library General Public License as       *
 *   published by the Free Software Foundation; either version 3 of the    *
 *   License, or (at your option) any later version.                       *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU Library General Public     *
 *   License along with this program; if not, write to the                 *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/
//-----------------------------------------------------------------------------
#ifndef _MGL_GLUT_H_
#define _MGL_GLUT_H_
#ifdef __cplusplus
#include <mgl2/wnd.h>
//-----------------------------------------------------------------------------
extern "C" {
#endif
void _mgl_key_up(unsigned char ch,int ,int );
HMGL MGL_EXPORT mgl_create_graph_glut(int (*draw)(HMGL gr, void *p), const char *title, void *par, void (*load)(void *p));
#ifdef __cplusplus
}
//-----------------------------------------------------------------------------
class MGL_EXPORT mglGLUT: public mglGraph
{
public:
	mglGLUT(int (*draw)(HMGL gr, void *p), const char *title="MathGL", void *par=0, void (*load)(void *p)=0) : mglGraph(-1)
	{	gr = mgl_create_graph_glut(draw,title,par,load);	}
	mglGLUT(int (*draw)(mglGraph *gr), const char *title="MathGL") : mglGraph(-1)
	{	gr = mgl_create_graph_glut(draw?mgl_draw_graph:0,title,(void*)draw,0);	}
	mglGLUT(mglDraw *draw=0, const char *title="MathGL") : mglGraph(-1)
	{	gr = mgl_create_graph_glut(draw?mgl_draw_class:0,title,draw,mgl_reload_class);	}
};
//-----------------------------------------------------------------------------
#endif
#endif
