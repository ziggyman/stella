/***************************************************************************
 * export_2d.cpp is part of Math Graphic Library
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
#include "mgl2/canvas.h"
#include "mgl2/canvas_cf.h"
#include "mgl2/font.h"
#include <time.h>
#include <algorithm>
#include <vector>
#include <string>
#include <sys/stat.h>
#undef _GR_
#define _GR_	((mglCanvas *)(*gr))
#define _Gr_	((mglCanvas *)(gr))
void mgl_printf(void *fp, bool gz, const char *str, ...);
//-----------------------------------------------------------------------------
MGL_NO_EXPORT const char *mgl_get_dash(unsigned short d, mreal w)
{
	static char b[32];
	static std::string s;
	if(d==0xffff)	return "";
	int f=0, p=d&1, n=p?0:1, i, j;
	s = p ? "" : "0";
	for(i=0;i<16;i++)
	{
		j = i;//15-i;
		if(((d>>j)&1) == p)	f++;
		else
		{
			snprintf(b,32," %g",f*w);	s += b;
			p = (d>>j)&1;	f = 1;	n++;
		}
	}
	snprintf(b,32," %g",f*w);	s += b;
	s += n%2 ? "" : " 0";
	return s.c_str();
}
//-----------------------------------------------------------------------------
bool MGL_NO_EXPORT mgl_is_same(HMGL gr, long i, mreal wp,uint32_t cp, int st)
{
	const mglPrim &pr=_Gr_->GetPrm(i);
	if(abs(pr.type)!=1)	return false;
	if(pr.w>=1 && wp!=pr.w)	return false;
	if(pr.w<1 && wp!=1)	return false;
	if(st!=pr.n3)	return false;
	return (cp==_Gr_->GetPrmCol(i));
}
//-----------------------------------------------------------------------------
void MGL_NO_EXPORT put_line(HMGL gr, void *fp, bool gz, long i, mreal wp, uint32_t cp,int st, const char *ifmt, const char *nfmt, bool neg, mreal fc)
{
	long n1=gr->GetPrm(i).n1, n2=gr->GetPrm(i).n2;
	if(n1>n2)	{	n1=gr->GetPrm(i).n2;	n2=gr->GetPrm(i).n1;	}
	if(n1<0 || n2<0)	return;
	const mglPnt &pp1 = gr->GetPnt(n1), &pp2 = gr->GetPnt(n2);
	mreal x0=pp1.x, y0=pp1.y;
	bool ok=true;
	register long j;	// first point
	std::vector<long> ids;
	while(ok)	// try to find starting point
	{
		for(ok=false,j=i+1;j<gr->GetPrmNum();j++)
		{
			mglPrim &q = gr->GetPrm(j);
			if(q.type>1)	break;
			if(mgl_is_same(gr, j, wp,cp,st) && q.type==1 && q.n1>=0 && q.n2>=0)	// previous point
			{
				const mglPnt &p1 = gr->GetPnt(q.n1);
				const mglPnt &p2 = gr->GetPnt(q.n2);
				if(p2.x==x0 && p2.y==y0)
				{
					ok = true;	ids.push_back(q.n1);
					x0 = p1.x;	y0 = p1.y;	q.type = -1;
				}
				else if(p1.x==x0 && p1.y==y0)
				{
					ok = true;	ids.push_back(q.n2);
					x0 = p2.x;	y0 = p2.y;	q.type = -1;
				}
			}
		}
	}
	std::reverse(ids.begin(),ids.end());
	ids.push_back(n1);	ids.push_back(n2);
	x0 = pp2.x;	y0 = pp2.y;	ok = true;
	while(ok)	// try to find starting point
	{
		for(ok=false,j=i+1;j<gr->GetPrmNum();j++)
		{
			mglPrim &q = gr->GetPrm(j);
			if(q.type>1)	break;
			if(mgl_is_same(gr, j,wp,cp,st) && q.type==1 && q.n1>=0 && q.n2>=0)	// next point
			{
				const mglPnt &p1 = gr->GetPnt(q.n1);
				const mglPnt &p2 = gr->GetPnt(q.n2);
				if(p2.x==x0 && p2.y==y0)
				{
					ok = true;	ids.push_back(q.n1);
					x0 = p1.x;	y0 = p1.y;	q.type = -1;
				}
				else if(p1.x==x0 && p1.y==y0)
				{
					ok = true;	ids.push_back(q.n2);
					x0 = p2.x;	y0 = p2.y;	q.type = -1;
				}
			}
		}
	}
	for(size_t j=0;j<ids.size();j++)
	{
		const mglPnt &p = gr->GetPnt(ids[j]);
		x0 = p.x;	y0 = p.y;
		mgl_printf(fp, gz, j>0?nfmt:ifmt,fc*x0,(neg?_Gr_->GetHeight()-y0:y0)*fc);
	}
}
//-----------------------------------------------------------------------------
//put_desc(fp,"%c%c%c_%04x {", "np %d %d mt %d %d ll %d %d ll cp fill\n",
//"np %d %d mt ", "%d %d ll ", "cp dr\n", "} def")
void MGL_NO_EXPORT put_desc(HMGL gr, void *fp, bool gz, const char *pre, const char *ln1, const char *ln2, const char *ln3, const char *suf)
{
	register long i,j,n;
	wchar_t *g;
	int *s;
	for(n=i=0;i<gr->GetPrmNum();i++)	if(gr->GetPrm(i).type==4)	n++;
	if(n==0)	return;		// no glyphs
	g = new wchar_t[n];	s = new int[n];
	for(n=i=0;i<gr->GetPrmNum();i++)
	{
		const mglPrim q = gr->GetPrm(i);
		if(q.type!=4 || (q.n3&8))	continue;	// not a glyph
		bool is=false;
		for(j=0;j<n;j++)	if(g[j]==q.n4 && s[j]==(q.n3&7))	is = true;
		if(is)	continue;		// glyph is described
		// have to describe
		g[n]=q.n4;	s[n]=q.n3&7;	n++;	// add to list of described
		// "%c%c%c_%04x {"
		mgl_printf(fp, gz, pre, q.n3&1?'b':'n', q.n3&2?'i':'n', q.n4);
		const mglGlyph &g = gr->GetGlf(q.n4);
		int nl=g.nl;
		const short *ln=g.line;
		long ik,ii;
		bool np=true;
		if(ln && nl>0)	for(ik=0;ik<nl;ik++)
		{
			ii = 2*ik;
			if(ln[ii]==0x3fff && ln[ii+1]==0x3fff)	// line breakthrough
			{	mgl_printf(fp, gz, "%s",ln3);	np=true;	continue;	}
			else if(np)	mgl_printf(fp, gz, ln1,ln[ii],ln[ii+1]);
			else		mgl_printf(fp, gz, ln2,ln[ii],ln[ii+1]);
			np=false;
		}
		mgl_printf(fp, gz, "%s%s",ln3,suf);	// finish glyph description suf="} def"
	}
	delete []g;		delete []s;
}
//-----------------------------------------------------------------------------
void MGL_EXPORT mgl_write_eps(HMGL gr, const char *fname,const char *descr)
{
	if(!fname || *fname==0)	return;
	if(gr->GetPrmNum()<1)	return;
	_Gr_->clr(MGL_FINISHED);	_Gr_->PreparePrim(1);
	time_t now;	time(&now);

	bool gz = fname[strlen(fname)-1]=='z';
	void *fp;
	if(!strcmp(fname,"-"))	fp = stdout;		// allow to write in stdout
	else		fp = gz ? (void*)gzopen(fname,"wt") : (void*)fopen(fname,"wt");
	if(!fp)		{	gr->SetWarn(mglWarnOpen,fname);	return;	}
	mgl_printf(fp, gz, "%%!PS-Adobe-3.0 EPSF-3.0\n%%%%BoundingBox: 0 0 %d %d\n", _Gr_->GetWidth(), _Gr_->GetHeight());
	mgl_printf(fp, gz, "%%%%Created by MathGL library\n%%%%Title: %s\n",descr ? descr : fname);
	mgl_printf(fp, gz, "%%%%CreationDate: %s\n",ctime(&now));
	mgl_printf(fp, gz, "/lw {setlinewidth} def\n/rgb {setrgbcolor} def\n");
	mgl_printf(fp, gz, "/np {newpath} def\n/cp {closepath} def\n");
	mgl_printf(fp, gz, "/ll {lineto} def\n/mt {moveto} def\n");
	mgl_printf(fp, gz, "/rl {rlineto} def\n/rm {rmoveto} def\n/dr {stroke} def\n");
	mgl_printf(fp, gz, "/ss {%g} def\n",0.35*gr->mark_size());
	mgl_printf(fp, gz, "/s2 {%g} def\n",0.7*gr->mark_size());
	mgl_printf(fp, gz, "/sm {-%g} def\n",0.35*gr->mark_size());
	mgl_printf(fp, gz, "/m_c {ss 0.3 mul 0 360 arc} def\n");
	mgl_printf(fp, gz, "/d0 {[] 0 setdash} def\n/sd {setdash} def\n");

	bool m_p=false,m_x=false,m_d=false,m_v=false,m_t=false,
	m_s=false,m_a=false,m_o=false,m_T=false,
	m_V=false,m_S=false,m_D=false,m_Y=false,m_l=false,
	m_L=false,m_r=false,m_R=false,m_X=false,m_P=false;
	register long i;
	// add mark definition if present
	for(i=0;i<gr->GetPrmNum();i++)
	{
		const mglPrim q = gr->GetPrm(i);
		if(q.type>0)	continue;		if(q.n4=='+')	m_p = true;
		if(q.n4=='x')	m_x = true;		if(q.n4=='s')	m_s = true;
		if(q.n4=='d')	m_d = true;		if(q.n4=='v')	m_v = true;
		if(q.n4=='^')	m_t = true;		if(q.n4=='*')	m_a = true;
		if(q.n4=='o' || q.n4=='O' || q.n4=='C')	m_o = true;
		if(q.n4=='S')	m_S = true;		if(q.n4=='D')	m_D = true;
		if(q.n4=='V')	m_V = true;		if(q.n4=='T')	m_T = true;
		if(q.n4=='<')	m_l = true;		if(q.n4=='L')	m_L = true;
		if(q.n4=='>')	m_r = true;		if(q.n4=='R')	m_R = true;
		if(q.n4=='Y')	m_Y = true;
		if(q.n4=='P')	m_P = true;		if(q.n4=='X')	m_X = true;
	}
	if(m_P)	{	m_p=true;	m_s=true;	}
	if(m_X)	{	m_x=true;	m_s=true;	}
	if(m_p)	mgl_printf(fp, gz, "/m_p {sm 0 rm s2 0 rl sm sm rm 0 s2 rl d0} def\n");
	if(m_x)	mgl_printf(fp, gz, "/m_x {sm sm rm s2 s2 rl 0 sm 2 mul rm sm 2 mul s2 rl d0} def\n");
	if(m_s)	mgl_printf(fp, gz, "/m_s {sm sm rm 0 s2 rl s2 0 rl 0 sm 2 mul rl cp d0} def\n");
	if(m_d)	mgl_printf(fp, gz, "/m_d {sm 0 rm ss ss rl ss sm rl sm sm rl cp d0} def\n");
	if(m_v)	mgl_printf(fp, gz, "/m_v {sm ss 2 div rm s2 0 rl sm sm 1.5 mul rl d0 cp} def\n");
	if(m_t)	mgl_printf(fp, gz, "/m_t {sm sm 2 div rm s2 0 rl sm ss 1.5 mul rl d0 cp} def\n");
	if(m_a)	mgl_printf(fp, gz, "/m_a {sm 0 rm s2 0 rl sm 1.6 mul sm 0.8 mul rm ss 1.2 mul ss 1.6 mul rl 0 sm 1.6 mul rm sm 1.2 mul ss 1.6 mul rl d0} def\n");
	if(m_o)	mgl_printf(fp, gz, "/m_o {ss 0 360 d0 arc} def\n");
	if(m_S)	mgl_printf(fp, gz, "/m_S {sm sm rm 0 s2 rl s2 0 rl 0 sm 2 mul rl cp} def\n");
	if(m_D)	mgl_printf(fp, gz, "/m_D {sm 0 rm ss ss rl ss sm rl sm sm rl cp} def\n");
	if(m_V)	mgl_printf(fp, gz, "/m_V {sm ss 2 div rm s2 0 rl sm sm 1.5 mul rl cp} def\n");
	if(m_T)	mgl_printf(fp, gz, "/m_T {sm sm 2 div rm s2 0 rl sm ss 1.5 mul rl cp} def\n");
	if(m_Y)	mgl_printf(fp, gz, "/m_Y {0 sm rm 0 ss rl sm ss rl s2 0 rm sm sm rl d0} def\n");
	if(m_r)	mgl_printf(fp, gz, "/m_r {sm 2 div sm rm 0 s2 rl ss 1.5 mul sm rl d0 cp} def\n");
	if(m_l)	mgl_printf(fp, gz, "/m_l {ss 2 div sm rm 0 s2 rl sm 1.5 mul sm rl d0 cp} def\n");
	if(m_R)	mgl_printf(fp, gz, "/m_R {sm 2 div sm rm 0 s2 rl ss 1.5 mul sm rl cp} def\n");
	if(m_L)	mgl_printf(fp, gz, "/m_L {ss 2 div sm rm 0 s2 rl sm 1.5 mul sm rl cp} def\n");
	if(m_P)	mgl_printf(fp, gz, "/m_P {m_p 0 sm rm m_s} def\n");
	if(m_X)	mgl_printf(fp, gz, "/m_X {m_x ss sm rm m_s} def\n");
	//	if(m_C)	mgl_printf(fp, gz, "/m_C {m_c m_o} def\n");
	mgl_printf(fp, gz, "\n");

	// write definition for all glyphs
	put_desc(gr,fp,gz,"/%c%c_%04x { np\n", "\t%d %d mt ", "%d %d ll ", "cp\n", "} def\n");
	// write primitives
	mreal wp=-1;
	float qs_old=gr->mark_size()/gr->FontFactor();
	mglRGBA cp;
	int st=0;
	char str[256]="";
	for(i=0;i<gr->GetPrmNum();i++)
	{
		const mglPrim &q = gr->GetPrm(i);
		if(q.type<0)	continue;	// q.n1>=0 always
		cp.c = _Gr_->GetPrmCol(i);
		const mglPnt p1 = gr->GetPnt(q.n1);
		if(q.type>1)	snprintf(str,256,"%.2g %.2g %.2g rgb ", cp.r[0]/255.,cp.r[1]/255.,cp.r[2]/255.);

		if(q.type==0)	// mark
		{
			mreal x0 = p1.x,y0 = p1.y;
			snprintf(str,256,"%.2g lw %.2g %.2g %.2g rgb ", 50*q.s*q.w>1?50*q.s*q.w:1, cp.r[0]/255.,cp.r[1]/255.,cp.r[2]/255.);
			wp=1;	// NOTE: this may renew line style if a mark inside!
			if(q.s!=qs_old)
			{
				mgl_printf(fp, gz, "/ss {%g} def\n",q.s);
				mgl_printf(fp, gz, "/s2 {%g} def\n",q.s*2);
				mgl_printf(fp, gz, "/sm {-%g} def\n",q.s);
				qs_old = q.s;
			}
			switch(q.n4)
			{
				case '+':	mgl_printf(fp, gz, "np %g %g mt m_p %sdr\n",x0,y0,str);	break;
				case 'x':	mgl_printf(fp, gz, "np %g %g mt m_x %sdr\n",x0,y0,str);	break;
				case 's':	mgl_printf(fp, gz, "np %g %g mt m_s %sdr\n",x0,y0,str);	break;
				case 'd':	mgl_printf(fp, gz, "np %g %g mt m_d %sdr\n",x0,y0,str);	break;
				case '*':	mgl_printf(fp, gz, "np %g %g mt m_a %sdr\n",x0,y0,str);	break;
				case 'v':	mgl_printf(fp, gz, "np %g %g mt m_v %sdr\n",x0,y0,str);	break;
				case '^':	mgl_printf(fp, gz, "np %g %g mt m_t %sdr\n",x0,y0,str);	break;
				case 'S':	mgl_printf(fp, gz, "np %g %g mt m_S %sfill\n",x0,y0,str);	break;
				case 'D':	mgl_printf(fp, gz, "np %g %g mt m_D %sfill\n",x0,y0,str);	break;
				case 'V':	mgl_printf(fp, gz, "np %g %g mt m_V %sfill\n",x0,y0,str);	break;
				case 'T':	mgl_printf(fp, gz, "np %g %g mt m_T %sfill\n",x0,y0,str);	break;
				case 'o':	mgl_printf(fp, gz, "%g %g m_o %sdr\n",x0,y0,str);break;
				case 'O':	mgl_printf(fp, gz, "%g %g m_o %sfill\n",x0,y0,str);break;
				case 'Y':	mgl_printf(fp, gz, "np %g %g mt m_Y %sdr\n",x0,y0,str);	break;
				case '<':	mgl_printf(fp, gz, "np %g %g mt m_l %sdr\n",x0,y0,str);	break;
				case '>':	mgl_printf(fp, gz, "np %g %g mt m_r %sdr\n",x0,y0,str);	break;
				case 'L':	mgl_printf(fp, gz, "np %g %g mt m_L %sfill\n",x0,y0,str);	break;
				case 'R':	mgl_printf(fp, gz, "np %g %g mt m_R %sfill\n",x0,y0,str);	break;
				case 'P':	mgl_printf(fp, gz, "np %g %g mt m_P %sdr\n",x0,y0,str);	break;
				case 'X':	mgl_printf(fp, gz, "np %g %g mt m_X %sdr\n",x0,y0,str);	break;
				case 'C':	mgl_printf(fp, gz, "%g %g m_o %g %g m_c %sdr\n",x0,y0,x0,y0,str);	break;
				default:	mgl_printf(fp, gz, "%g %g m_c %sfill\n",x0,y0,str);
			}
		}
		else if(q.type==3)	// quad
		{
			const mglPnt &p2=gr->GetPnt(q.n2), &p3=gr->GetPnt(q.n3), &p4=gr->GetPnt(q.n4);
			if(cp.r[3])	mgl_printf(fp, gz, "np %g %g mt %g %g ll %g %g ll %g %g ll cp %sfill\n", p1.x, p1.y, p2.x, p2.y, p4.x, p4.y, p3.x, p3.y, str);
		}
		else if(q.type==2)	// trig
		{
			const mglPnt &p2=gr->GetPnt(q.n2), &p3=gr->GetPnt(q.n3);
			if(cp.r[3])	mgl_printf(fp, gz, "np %g %g mt %g %g ll %g %g ll cp %sfill\n", p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, str);
		}
		else if(q.type==1)	// line
		{
			snprintf(str,256,"%.2g lw %.2g %.2g %.2g rgb ", q.w>1 ? q.w:1., cp.r[0]/255.,cp.r[1]/255.,cp.r[2]/255.);
			wp = q.w>1  ? q.w:1;	st = q.n3;
			put_line(gr,fp,gz,i,wp,cp.c,st, "np %g %g mt ", "%g %g ll ", false, 1);
			const char *sd = mgl_get_dash(q.n3,q.w);
			if(sd && sd[0])	mgl_printf(fp, gz, "%s [%s] %g sd dr\n",str,sd,q.w*q.s);
			else			mgl_printf(fp, gz, "%s d0 dr\n",str);
		}
		else if(q.type==4)	// glyph
		{
			float phi = gr->GetGlyphPhi(gr->GetPnt(q.n2),q.w);
			if(mgl_isnan(phi))	continue;
			mreal 	ss = q.s/2, xx = p1.u, yy = p1.v, zz = q.p;
			mgl_printf(fp, gz, "gsave\t%g %g translate %g %g scale %g rotate %s\n",
					   p1.x, p1.y, ss, ss, -phi, str);
			if(q.n3&8)	// this is "line"
			{
				mreal dy = 0.004,f=fabs(zz);
				mgl_printf(fp, gz, "np %g %g mt %g %g ll %g %g ll %g %g ll cp ",
						   xx,yy+dy, xx+f,yy+dy, xx+f,yy-dy, xx,yy-dy);
			}
			else
				mgl_printf(fp, gz, "%.3g %.3g translate %g %g scale %c%c_%04x ",
						   xx, yy, zz, zz, q.n3&1?'b':'n', q.n3&2?'i':'n', q.n4);
			if(q.n3&4)	mgl_printf(fp, gz, "dr");
			else	mgl_printf(fp, gz, "eofill");
			mgl_printf(fp, gz, " grestore\n");
		}
	}
	for(i=0;i<gr->GetPrmNum();i++)
	{
		mglPrim &q = gr->GetPrm(i);
		if(q.type==-1)	q.type = 1;
	}
	mgl_printf(fp, gz, "\nshowpage\n%%%%EOF\n");
	if(strcmp(fname,"-"))	{	if(gz)	gzclose((gzFile)fp);	else	fclose((FILE *)fp);	}
}
void MGL_EXPORT mgl_write_eps_(uintptr_t *gr, const char *fname,const char *descr,int l,int n)
{	char *s=new char[l+1];	memcpy(s,fname,l);	s[l]=0;
	char *d=new char[n+1];	memcpy(d,descr,n);	d[n]=0;
	mgl_write_eps(_GR_,s,d);	delete []s;		delete []d;	}
//-----------------------------------------------------------------------------
void MGL_EXPORT mgl_write_svg(HMGL gr, const char *fname,const char *descr)
{
	if(!fname || *fname==0)	return;
	if(gr->GetPrmNum()<1)	return;
	_Gr_->clr(MGL_FINISHED);	_Gr_->PreparePrim(1);
	time_t now;	time(&now);

	bool gz = fname[strlen(fname)-1]=='z';
	long hh = _Gr_->GetHeight();
	void *fp;
	if(!strcmp(fname,"-"))	fp = stdout;		// allow to write in stdout
	else		fp = gz ? (void*)gzopen(fname,"wt") : (void*)fopen(fname,"wt");
	if(!fp)		{	gr->SetWarn(mglWarnOpen,fname);	return;	}
	mgl_printf(fp, gz, "<?xml version=\"1.0\" standalone=\"no\"?>\n");
	mgl_printf(fp, gz, "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 20000303 Stylable//EN\" \"http://www.w3.org/TR/2000/03/WD-SVG-20000303/DTD/svg-20000303-stylable.dtd\">\n");
	mgl_printf(fp, gz, "<svg width=\"%d\" height=\"%d\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">\n", _Gr_->GetWidth(), hh);

	mgl_printf(fp, gz, "<!--Created by MathGL library-->\n");
	mgl_printf(fp, gz, "<!--Title: %s-->\n<!--CreationDate: %s-->\n\n",descr?descr:fname,ctime(&now));

	// write definition for all glyphs
	put_desc(gr,fp,gz,"<symbol id=\"%c%c_%04x\"><path d=\"", "\tM %d %d ",
			 "L %d %d ", "Z\n", "\"/></symbol>\n");
	// currentColor -> inherit ???
	mgl_printf(fp, gz, "<g fill=\"none\" stroke=\"none\" stroke-width=\"0.5\">\n");
	// write primitives
	mreal wp=-1;
	register long i;
	int st=0;
	mglRGBA cp;

	for(i=0;i<gr->GetPrmNum();i++)
	{
		const mglPrim &q = gr->GetPrm(i);
		if(q.type<0)	continue;	// q.n1>=0 always
		cp.c = _Gr_->GetPrmCol(i);
		const mglPnt p1=gr->GetPnt(q.n1);
		if(q.type==0)
		{
			mreal x=p1.x,y=hh-p1.y,s=q.s;
			if(!strchr("xsSoO",q.n4))	s *= 1.1;
			wp = 1;
			if(strchr("SDVTLR",q.n4))
				mgl_printf(fp, gz, "<g fill=\"#%02x%02x%02x\">\n", int(cp.r[0]),int(cp.r[1]),int(cp.r[2]));
			else
				mgl_printf(fp, gz, "<g stroke=\"#%02x%02x%02x\"  stroke-width=\"%g\">\n", int(cp.r[0]),int(cp.r[1]),int(cp.r[2]), 50*q.s*q.w>1?50*q.s*q.w:1);
			switch(q.n4)
			{
			case 'P':
				mgl_printf(fp, gz, "<path d=\"M %g %g L %g %g M %g %g L %g %g M %g %g L %g %g L %g %g L %g %g L %g %g\"/>\n",
							x-s,y,x+s,y,x,y-s,x,y+s, x-s,y-s,x+s,y-s,x+s,y+s,x-s,y+s,x-s,y-s);	break;
			case '+':
				mgl_printf(fp, gz, "<path d=\"M %g %g L %g %g M %g %g L %g %g\"/>\n", x-s,y,x+s,y,x,y-s,x,y+s);	break;
			case 'X':
				mgl_printf(fp, gz, "<path d=\"M %g %g L %g %g M %g %g L %g %g M %g %g L %g %g L %g %g L %g %g L %g %g\"/>\n",
							x-s,y-s,x+s,y+s,x+s,y-s,x-s,y+s, x-s,y-s,x+s,y-s,x+s,y+s,x-s,y+s,x-s,y-s);	break;
			case 'x':
				mgl_printf(fp, gz, "<path d=\"M %g %g L %g %g M %g %g L %g %g\"/>\n", x-s,y-s,x+s,y+s,x+s,y-s,x-s,y+s);	break;
			case 's':
			case 'S':
				mgl_printf(fp, gz, "<path d=\"M %g %g L %g %g L %g %g L %g %gZ\"/>\n", x-s,y-s,x+s,y-s,x+s,y+s,x-s,y+s);	break;
			case 'd':
			case 'D':
				mgl_printf(fp, gz, "<path d=\"M %g %g L %g %g L %g %g L %g %gZ\"/>\n", x-s,y,x,y-s,x+s,y,x,y+s);	break;
			case 'v':
			case 'V':
				mgl_printf(fp, gz, "<path d=\"M %g %g L %g %g L %g %gZ\"/>\n", x-s,y-s/2,x+s,y-s/2,x,y+s);	break;
			case '^':
			case 'T':
				mgl_printf(fp, gz, "<path d=\"M %g %g L %g %g L %g %gZ\"/>\n", x-s,y+s/2,x+s,y+s/2,x,y-s);	break;
			case '<':
			case 'L':
				mgl_printf(fp, gz, "<path d=\"M %g %g L %g %g L %g %gZ\"/>\n", x+s/2,y+s,x+s/2,y-s,x-s,y);	break;
			case '>':
			case 'R':
				mgl_printf(fp, gz, "<path d=\"M %g %g L %g %g L %g %gZ\"/>\n", x-s/2,y+s,x-s/2,y-s,x+s,y);	break;
			case 'Y':
				mgl_printf(fp, gz, "<path d=\"M %g %g L %g %g L %g %g M %g %g L %g %g\"/>\n", x,y-s, x,y, x+s,y+s, x,y, x-s,y+s);	break;
			case 'C':
				mgl_printf(fp, gz, "<circle style=\"fill:#%02x%02x%02x\" cx=\"%g\" cy=\"%g\" r=\"0.15\"/>\n<circle cx=\"%g\" cy=\"%g\" r=\"%g\"/>\n",
							int(cp.r[0]),int(cp.r[1]),int(cp.r[2]),x,y,x,y,s);	break;
			case 'o':
				mgl_printf(fp, gz, "<circle cx=\"%g\" cy=\"%g\" r=\"%g\"/>\n", x,y,s);	break;
			case 'O':
				mgl_printf(fp, gz, "<circle style=\"fill:#%02x%02x%02x\" cx=\"%g\" cy=\"%g\" r=\"%g\"/>\n",
							int(cp.r[0]),int(cp.r[1]),int(cp.r[2]),x,y,s);	break;
			case '*':
				mgl_printf(fp, gz, "<path d=\"M %g %g L %g %g M %g %g L %g %g M %g %g L %g %g\"/>\n",
							x-s,y,x+s,y,x-0.6*s,y-0.8*s,x+0.6*s,y+0.8*s,x+0.6*s,y-0.8*s,x-0.6*s,y+0.8*s);	break;
			default:
				mgl_printf(fp, gz, "<circle style=\"fill:#%02x%02x%02x\" cx=\"%g\" cy=\"%g\" r=\"0.15\"/>\n",
							int(cp.r[0]),int(cp.r[1]),int(cp.r[2]),x,y);	break;
			}
			mgl_printf(fp, gz, "</g>\n");
		}
		else if(q.type==1)
		{
			mgl_printf(fp,gz,"<g stroke=\"#%02x%02x%02x\"",int(cp.r[0]),int(cp.r[1]),int(cp.r[2]));
			if(q.n3)
			{
				mgl_printf(fp, gz, " stroke-dasharray=\"%s\"", mgl_get_dash(q.n3,q.w));
				mgl_printf(fp, gz, " stroke-dashoffset=\"%g\"", q.s*q.w);
			}
			if(q.w>1)	mgl_printf(fp, gz, " stroke-width=\"%g\"", q.w);
			wp = q.w>1  ? q.w:1;	st = q.n3;
			put_line(gr,fp,gz,i,wp,cp.c,st, "><path d=\" M %g %g", " L %g %g", true, 1);
			mgl_printf(fp, gz, "\"/> </g>\n");
		}
		else if(q.type==2 && cp.r[3])
		{
			const mglPnt &p2=gr->GetPnt(q.n2), &p3=gr->GetPnt(q.n3);
			mgl_printf(fp, gz, "<g fill=\"#%02x%02x%02x\" opacity=\"%g\">\n", int(cp.r[0]),int(cp.r[1]),int(cp.r[2]),cp.r[3]/255.);
			mgl_printf(fp, gz, "<path d=\"M %g %g L %g %g L %g %g Z\"/> </g>\n", p1.x, hh-p1.y, p2.x, hh-p2.y, p3.x, hh-p3.y);
		}
		else if(q.type==3 && cp.r[3])
		{
			const mglPnt &p2=gr->GetPnt(q.n2), &p3=gr->GetPnt(q.n3), &p4=gr->GetPnt(q.n4);
			mgl_printf(fp, gz, "<g fill=\"#%02x%02x%02x\" opacity=\"%g\">\n", int(cp.r[0]),int(cp.r[1]),int(cp.r[2]),cp.r[3]/255.);
			mgl_printf(fp, gz, "<path d=\"M %g %g L %g %g L %g %g L %g %g Z\"/> </g>\n", p1.x, hh-p1.y, p2.x, hh-p2.y, p4.x, hh-p4.y, p3.x, hh-p3.y);
		}
		else if(q.type==4)
		{
			float phi = gr->GetGlyphPhi(gr->GetPnt(q.n2),q.w);
			if(mgl_isnan(phi))	continue;
			mreal ss = q.s/2, xx = p1.u, yy = p1.v, zz = q.p;
			if(q.n3&8)	// this is "line"
			{
				mgl_printf(fp, gz, "<g transform=\"translate(%g,%g) scale(%.3g,%.3g) rotate(%g)\"", p1.x, hh-p1.y, ss, -ss, -phi);
				if(q.n3&4)
					mgl_printf(fp, gz, " stroke=\"#%02x%02x%02x\">", int(cp.r[0]),int(cp.r[1]),int(cp.r[2]));
				else
					mgl_printf(fp, gz, " fill=\"#%02x%02x%02x\">", int(cp.r[0]),int(cp.r[1]),int(cp.r[2]));
				mreal dy = 0.004,f=fabs(zz);
				mgl_printf(fp, gz, "<path d=\"M %g %g L %g %g L %g %g L %g %g\"/></g>\n", xx,yy+dy, xx+f,yy+dy, xx+f,yy-dy, xx,yy-dy);
			}
			else
			{
				ss *= zz;
				mgl_printf(fp, gz, "<g transform=\"translate(%g,%g) scale(%.3g,%.3g) rotate(%g)\"", p1.x, hh-p1.y, ss, -ss, -q.w);
				if(q.n3&4)
					mgl_printf(fp, gz, " stroke=\"#%02x%02x%02x\">", int(cp.r[0]),int(cp.r[1]),int(cp.r[2]));
				else
					mgl_printf(fp, gz, " fill=\"#%02x%02x%02x\">", int(cp.r[0]),int(cp.r[1]),int(cp.r[2]));
				mgl_printf(fp, gz, "<use x=\"%g\" y=\"%g\" xlink:href=\"#%c%c_%04x\"/></g>\n", xx/zz, yy/zz, q.n3&1?'b':'n', q.n3&2?'i':'n', q.n4);
			}
		}
	}

	for(i=0;i<gr->GetPrmNum();i++)
	{	mglPrim &q=gr->GetPrm(i);	if(q.type==-1)	q.type = 1;	}
	mgl_printf(fp, gz, "</g></svg>");
	if(strcmp(fname,"-"))	{	if(gz)	gzclose((gzFile)fp);	else	fclose((FILE *)fp);	}
}
void MGL_EXPORT mgl_write_svg_(uintptr_t *gr, const char *fname,const char *descr,int l,int n)
{	char *s=new char[l+1];	memcpy(s,fname,l);	s[l]=0;
	char *d=new char[n+1];	memcpy(d,descr,n);	d[n]=0;
	mgl_write_svg(_GR_,s,d);	delete []s;		delete []d;	}
//-----------------------------------------------------------------------------
/// Color names easely parsed by LaTeX
struct mglSVGName	{	const char *name;	mreal r,g,b;	};
MGL_NO_EXPORT mglSVGName mgl_names[]={{"AliceBlue",.94,.972,1},
{"Apricot", 0.984, 0.725, 0.51},
{"Aquamarine", 0, 0.71, 0.745},
{"Bittersweet", 0.753, 0.31, 0.0902},
{"Black", 0.133, 0.118, 0.122},
{"Blue", 0.176, 0.184, 0.573},
{"BlueGreen", 0, 0.702, 0.722},
{"BlueViolet", 0.278, 0.224, 0.573},
{"BrickRed", 0.714, 0.196, 0.11},
{"Brown", 0.475, 0.145, 0},
{"BurntOrange", 0.969, 0.573, 0.114},
{"CadetBlue", 0.455, 0.447, 0.604},
{"CarnationPink", 0.949, 0.51, 0.706},
{"Cerulean", 0, 0.635, 0.89},
{"CornflowerBlue", 0.255, 0.69, 0.894},
{"Cyan", 0, 0.682, 0.937},
{"Dandelion", 0.992, 0.737, 0.259},
{"DarkOrchid", 0.643, 0.325, 0.541},
{"Emerald", 0, 0.663, 0.616},
{"ForestGreen", 0, 0.608, 0.333},
{"Fuchsia", 0.549, 0.212, 0.549},
{"Goldenrod", 1, 0.875, 0.259},
{"Gray", 0.58, 0.588, 0.596},
{"Green", 0, 0.651, 0.31},
{"GreenYellow", 0.875, 0.902, 0.455},
{"JungleGreen", 0, 0.663, 0.604},
{"Lavender", 0.957, 0.62, 0.769},
{"LimeGreen", 0.553, 0.78, 0.243},
{"Magenta", 0.925, 0, 0.549},
{"Mahogany", 0.663, 0.204, 0.122},
{"Maroon", 0.686, 0.196, 0.208},
{"Melon", 0.973, 0.62, 0.482},
{"MidnightBlue", 0, 0.404, 0.584},
{"Mulberry", 0.663, 0.235, 0.576},
{"NavyBlue", 0, 0.431, 0.722},
{"OliveGreen", 0.235, 0.502, 0.192},
{"Orange", 0.961, 0.506, 0.216},
{"OrangeRed", 0.929, 0.0745, 0.353},
{"Orchid", 0.686, 0.447, 0.69},
{"Peach", 0.969, 0.588, 0.353},
{"Periwinkle", 0.475, 0.467, 0.722},
{"PineGreen", 0, 0.545, 0.447},
{"Plum", 0.573, 0.149, 0.561},
{"ProcessBlue", 0, 0.69, 0.941},
{"Purple", 0.6, 0.278, 0.608},
{"RawSienna", 0.592, 0.251, 0.0235},
{"Red", 0.929, 0.106, 0.137},
{"RedOrange", 0.949, 0.376, 0.208},
{"RedViolet", 0.631, 0.141, 0.42},
{"Rhodamine", 0.937, 0.333, 0.624},
{"RoyalBlue", 0, 0.443, 0.737},
{"RoyalPurple", 0.38, 0.247, 0.6},
{"RubineRed", 0.929, 0.00392, 0.49},
{"Salmon", 0.965, 0.573, 0.537},
{"SeaGreen", 0.247, 0.737, 0.616},
{"Sepia", 0.404, 0.0941, 0},
{"SkyBlue", 0.275, 0.773, 0.867},
{"SpringGreen", 0.776, 0.863, 0.404},
{"Tan", 0.855, 0.616, 0.463},
{"TealBlue", 0, 0.682, 0.702},
{"Thistle", 0.847, 0.514, 0.718},
{"Turquoise", 0, 0.706, 0.808},
{"Violet", 0.345, 0.259, 0.608},
{"VioletRed", 0.937, 0.345, 0.627},
{"White", 0.6, 0.6, 0.6},
{"WildStrawberry", 0.933, 0.161, 0.404},
{"Yellow", 1, 0.949, 0},
{"YellowGreen", 0.596, 0.8, 0.439},
{"YellowOrange", 0.98, 0.635, 0.102},
{"white", 1,1,1},
{"black", 0,0,0},
{"red", 1,0,0},
{"green", 0,1,0},
{"blue", 0,0,1},
{"cyan", 0,1,1},
{"magenta", 1,0,1},
{"yellow", 1,1,0},
{"",-1,-1,-1}};
//-----------------------------------------------------------------------------
MGL_NO_EXPORT const char *mglColorName(mglColor c)	// return closest SVG color
{
	register long i;
	register mreal d, dm=10;
	const char *name="";
	for(i=0;mgl_names[i].name[0];i++)
	{
		d = fabs(c.r-mgl_names[i].r)+fabs(c.g-mgl_names[i].g)+fabs(c.b-mgl_names[i].b);
		if(d<dm)	{	dm=d;	name=mgl_names[i].name;	}
	}
	return name;
}
//-----------------------------------------------------------------------------
void MGL_EXPORT mgl_write_tex(HMGL gr, const char *fname,const char *descr)
{
	if(gr->GetPrmNum()<1)	return;
	_Gr_->clr(MGL_FINISHED);	_Gr_->PreparePrim(1);

	FILE *fp = fopen(fname,"wt");
	if(!fp)		{	gr->SetWarn(mglWarnOpen,fname);	return;	}
	fprintf(fp, "%% Created by MathGL library\n%% Title: %s\n\n",descr?descr:fname);
	fprintf(fp, "\\begin{tikzpicture}\n");

	// write primitives first
	mreal wp=-1;
	register long i;
	register int ii,jj,kk;
	int st=0;
	mglRGBA cp;
	char cname[16];

	for(i=0;i<gr->GetPrmNum();i++)
	{
		const mglPrim &q = gr->GetPrm(i);
		if(q.type<0)	continue;	// q.n1>=0 always
		cp.c = _Gr_->GetPrmCol(i);

		ii = (cp.r[0]+25L)/51;
		jj = (cp.r[1]+25L)/51;
		kk = (cp.r[2]+25L)/51;
		snprintf(cname,16,"mgl_%d",ii+6*(jj+6*kk));
//		cname = mglColorName(cp);
		const mglPnt p1=gr->GetPnt(q.n1);
		mreal x=p1.x/100,y=p1.y/100,s=q.s/100;
		if(q.type==0)
		{
			if(!strchr("xsSoO",q.n4))	s *= 1.1;
			wp = 1;
			switch(q.n4)	// NOTE: no thickness for marks in TeX
			{
				case 'P':
					fprintf(fp, "\\mglp{%g}{%g}{%s}{%g} \\mgls{%g}{%g}{%s}{%g}\n", x,y,cname,s,x,y,cname,s);	break;
				case 'X':
					fprintf(fp, "\\mglx{%g}{%g}{%s}{%g} \\mgls{%g}{%g}{%s}{%g}\n", x,y,cname,s,x,y,cname,s);	break;
				case 'C':
					fprintf(fp, "\\mglc{%g}{%g}{%s}{%g} \\mglo{%g}{%g}{%s}{%g}\n", x,y,cname,s,x,y,cname,s);	break;
				case '+':	fprintf(fp, "\\mglp{%g}{%g}{%s}{%g}\n", x,y,cname,s);	break;
				case 'x':	fprintf(fp, "\\mglx{%g}{%g}{%s}{%g}\n", x,y,cname,s);	break;
				case 's':	fprintf(fp, "\\mgls{%g}{%g}{%s}{%g}\n", x,y,cname,s);	break;
				case 'S':	fprintf(fp, "\\mglS{%g}{%g}{%s}{%g}\n", x,y,cname,s);	break;
				case 'd':	fprintf(fp, "\\mgld{%g}{%g}{%s}{%g}\n", x,y,cname,s);	break;
				case 'D':	fprintf(fp, "\\mglD{%g}{%g}{%s}{%g}\n", x,y,cname,s);	break;
				case '^':	fprintf(fp, "\\mglt{%g}{%g}{%s}{%g}\n", x,y,cname,s);	break;
				case 'T':	fprintf(fp, "\\mglT{%g}{%g}{%s}{%g}\n", x,y,cname,s);	break;
				case 'v':	fprintf(fp, "\\mglv{%g}{%g}{%s}{%g}\n", x,y,cname,s);	break;
				case 'V':	fprintf(fp, "\\mglV{%g}{%g}{%s}{%g}\n", x,y,cname,s);	break;
				case '<':	fprintf(fp, "\\mgll{%g}{%g}{%s}{%g}\n", x,y,cname,s);	break;
				case 'L':	fprintf(fp, "\\mglL{%g}{%g}{%s}{%g}\n", x,y,cname,s);	break;
				case '>':	fprintf(fp, "\\mglr{%g}{%g}{%s}{%g}\n", x,y,cname,s);	break;
				case 'R':	fprintf(fp, "\\mglR{%g}{%g}{%s}{%g}\n", x,y,cname,s);	break;
				case 'Y':	fprintf(fp, "\\mglY{%g}{%g}{%s}{%g}\n", x,y,cname,s);	break;
				case 'o':	fprintf(fp, "\\mglo{%g}{%g}{%s}{%g}\n", x,y,cname,s);	break;
				case 'O':	fprintf(fp, "\\mglO{%g}{%g}{%s}{%g}\n", x,y,cname,s);	break;
				case '*':	fprintf(fp, "\\mgla{%g}{%g}{%s}{%g}\n", x,y,cname,s);	break;
				default:	fprintf(fp, "\\mglc{%g}{%g}{%s}\n", x,y,cname);	break;
			}
		}
		else if(q.type==2 && cp.r[3])
		{
			const mglPnt p2=gr->GetPnt(q.n2), p3=gr->GetPnt(q.n3);
			fprintf(fp, "\\fill[%s, fill opacity=%g] (%g,%g) -- (%g,%g) -- (%g,%g) -- cycle;\n", cname,cp.r[3]/255., x,y, p2.x/100,p2.y/100, p3.x/100,p3.y/100);
		}
		else if(q.type==3 && cp.r[3])
		{
			const mglPnt p2=gr->GetPnt(q.n2), p3=gr->GetPnt(q.n3), p4=gr->GetPnt(q.n4);
			fprintf(fp, "\\fill[%s, fill opacity=%g] (%g,%g) -- (%g,%g) -- (%g,%g) -- (%g,%g) -- cycle;\n", cname,cp.r[3]/255., x,y, p2.x/100,p2.y/100, p4.x/100,p4.y/100, p3.x/100,p3.y/100);
		}
		else if(q.type==1)	// lines
		{
			//const char *dash[]={"", "8 8","4 4","1 3","7 4 1 4","3 2 1 2"};
			const char *w[]={"semithick","thick","very thick","ultra thick"};
			register int iw=int(q.w-0.5);	if(iw>3)	iw=3;
			if(iw<0)	fprintf(fp,"\\draw[%s] ",cname);
			else		fprintf(fp,"\\draw[%s,%s] ",cname,w[iw]);
			// TODO: add line dashing
			wp = q.w>1  ? q.w:1;	st = q.n3;
			put_line(gr,fp,false,i,wp,cp.c,st, "(%g,%g)", " -- (%g,%g)", false, 0.01);
			fprintf(fp, ";\n");
		}
		else if(q.type==6 && mgl_isnum(q.p))	// text
		{
			const mglText &t = gr->GetPtx(q.n3);
			mreal dy = q.w*cos(q.p*M_PI/180)/100, dx = q.w*sin(q.p*M_PI/180)/100;
			int f,a;	mglGetStyle(t.stl.c_str(), &f, &a);
			std::string ss=cname;
			if((a&3)==0)	ss.append(",anchor=base west");
			if((a&3)==1)	ss.append(",anchor=base");
			if((a&3)==2)	ss.append(",anchor=base east");
			if(f&MGL_FONT_ITAL)	ss.append(",font=\\itshape");
			if(f&MGL_FONT_BOLD)	ss.append(",font=\\bfshape");
			if(t.text.find('\\')!=std::string::npos || t.text.find('{')!=std::string::npos || t.text.find('_')!=std::string::npos || t.text.find('^')!=std::string::npos)
				fprintf(fp,"\\draw[%s] (%g,%g) node[rotate=%.2g]{$%ls$};\n", ss.c_str(),x-dx,y-dy, -q.p, t.text.c_str());
			else
				fprintf(fp,"\\draw[%s] (%g,%g) node[rotate=%.2g]{%ls};\n", ss.c_str(),x-dx,y-dy, -q.p, t.text.c_str());
		}
	}
	fprintf(fp, "\\end{tikzpicture}\n");
	for(i=0;i<gr->GetPrmNum();i++)
	{	mglPrim &q=gr->GetPrm(i);	if(q.type==-1)	q.type = 1;	}
	fclose(fp);

	// provide colors used by figure
	fp=fopen("mglcolors.tex","wt");
	for(ii=0;ii<6;ii++)	for(jj=0;jj<6;jj++)	for(kk=0;kk<6;kk++)
		fprintf(fp,"\\definecolor{mgl_%d}{RGB}{%d,%d,%d}\n",ii+6*(jj+6*kk),51*ii,51*jj,51*kk);
	mreal ms=0.4*gr->mark_size()/100;	// also provide marks
	fprintf(fp, "\\providecommand{\\mglp}[4]{\\draw[#3] (#1-#4, #2) -- (#1+#4,#2) (#1,#2-#4) -- (#1,#2+#4);}\n");
	fprintf(fp, "\\providecommand{\\mglx}[4]{\\draw[#3] (#1-#4, #2-#4) -- (#1+#4,#2+#4) (#1+#4,#2-#4) -- (#1-#4,#2+#4);}\n");
	fprintf(fp, "\\providecommand{\\mgls}[4]{\\draw[#3] (#1-#4, #2-#4) -- (#1+#4,#2-#4) -- (#1+#4,#2+#4) -- (#1-#4,#2+#4) -- cycle;}\n");
	fprintf(fp, "\\providecommand{\\mglS}[4]{\\fill[#3] (#1-#4, #2-#4) -- (#1+#4,#2-#4) -- (#1+#4,#2+#4) -- (#1-#4,#2+#4) -- cycle;}\n");
	fprintf(fp, "\\providecommand{\\mgld}[4]{\\draw[#3] (#1, #2-#4) -- (#1+#4,#2) -- (#1,#2+#4) -- (#1-#4,#2) -- cycle;}\n");
	fprintf(fp, "\\providecommand{\\mglD}[4]{\\fill[#3] (#1, #2-#4) -- (#1+#4,#2) -- (#1,#2+#4) -- (#1-#4,#2) -- cycle;}\n");
	fprintf(fp, "\\providecommand{\\mglv}[4]{\\draw[#3] (#1-#4, #2+#4/2) -- (#1+#4,#2+#4/2) -- (#1,#2-#4) -- cycle;}\n");
	fprintf(fp, "\\providecommand{\\mglV}[4]{\\fill[#3] (#1-#4, #2+#4/2) -- (#1+#4,#2+#4/2) -- (#1,#2-#4) -- cycle;}\n");
	fprintf(fp, "\\providecommand{\\mglt}[4]{\\draw[#3] (#1-#4, #2-#4/2) -- (#1+#4,#2-#4/2) -- (#1,#2+#4) -- cycle;}\n");
	fprintf(fp, "\\providecommand{\\mglT}[4]{\\fill[#3] (#1-#4, #2-#4/2) -- (#1+#4,#2-#4/2) -- (#1,#2+#4) -- cycle;}\n");
	fprintf(fp, "\\providecommand{\\mgll}[4]{\\draw[#3] (#1+#4/2, #2-#4) -- (#1+#4/2,#2+#4) -- (#1-#4,#2) -- cycle;}\n");
	fprintf(fp, "\\providecommand{\\mglL}[4]{\\fill[#3] (#1+#4/2, #2-#4) -- (#1+#4/2,#2+#4) -- (#1-#4,#2) -- cycle;}\n");
	fprintf(fp, "\\providecommand{\\mglr}[4]{\\draw[#3] (#1-#4/2, #2-#4) -- (#1-#4/2,#2+#4) -- (#1+#4,#2) -- cycle;}\n");
	fprintf(fp, "\\providecommand{\\mglR}[4]{\\fill[#3] (#1-#4/2, #2-#4) -- (#1-#4/2,#2+#4) -- (#1+#4,#2) -- cycle;}\n");
	fprintf(fp, "\\providecommand{\\mglR}[4]{\\draw[#3] (#1, #2-#4) -- (#1,#2) -- (#1-#4,#2+#4) (#1,#2) -- (#1+#4,#2+#4);}\n");
	fprintf(fp, "\\providecommand{\\mgla}[4]{\\draw[#3] (#1-#4, #2) -- (#1+#4,#2) (#1-0.6*#4,#2-0.8*#4) -- (#1+0.6*#4,#2+0.8*#4) (#1-0.6*#4,#2+0.8*#4) -- (#1+0.6*#4,#2-0.8*#4);}\n");
	fprintf(fp, "\\providecommand{\\mglY}[4]{\\draw[#3] (#1, #2-#4) -- (#1,#2) (#1-#4,#2+#4) -- (#1,#2) (#1+#4,#2+#4) -- (#1,#2);}\n");
	fprintf(fp, "\\providecommand{\\mglo}[4]{\\draw[#3] (#1, #2) circle (#4);}\n");
	fprintf(fp, "\\providecommand{\\mglO}[4]{\\fill[#3] (#1, #2) circle (#4);}\n");
	fprintf(fp, "\\providecommand{\\mglc}[3]{\\draw[#3] (#1, #2) circle (%g);}\n\n", 0.1*ms);
	fclose(fp);

	// provide main file for viewing figure
	fp=fopen("mglmain.tex","wt");
	fprintf(fp, "\\documentclass{article}\n\n");
	fprintf(fp, "%% following lines should be placed before \\begin{document}\n");
	fprintf(fp,"\\usepackage{tikz}\n\\input{mglcolors.tex}\n");
	fprintf(fp, "\\begin{document}\n%% start figure itself\n\\input{%s}\\end{document}\n",fname);
	fclose(fp);
}
//-----------------------------------------------------------------------------