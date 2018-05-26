// gcc -g -o indicator-xkbmod indicator-xkbmod.c -lX11 && ./indicator-xkbmod
#include <stdio.h>
#include <string.h>
#include <X11/XKBlib.h>
#include <X11/Xutil.h>

Display *dpy;
Window win;
GC gc_bk, gc_ledon;

void led_mod(int flag, int x, char *s) {
  if (flag) {
    XFillRectangle(dpy,win,gc_ledon,11*x,0,10,16 );
    XDrawString(dpy,win,gc_bk,11*x+1,15, s, 1);
  }
}

int main (int argc, char **argv) {
  char* displayName = strdup("");
  int eventCode;
  int errorReturn;
  XEvent eve;
  int major = XkbMajorVersion;
  int minor = XkbMinorVersion;;
  int reasonReturn;
  XkbStateRec p;
   
  XkbIgnoreExtension(False);

  dpy = XkbOpenDisplay(displayName, &eventCode, &errorReturn,
                            &major, &minor, &reasonReturn);

  if (reasonReturn != XkbOD_Success) return 1;
  if (XkbSelectEvents(dpy, XkbUseCoreKbd, XkbStateNotifyMask, XkbAllStateComponentsMask)!=True)
    return 1;

  int scr_num = DefaultScreen(dpy);
  XSizeHints win_hint;
  win_hint.min_width =  94; win_hint.max_width  = 94;
  win_hint.min_height = 16; win_hint.max_height = 16;
  win_hint.x = DisplayWidth(dpy,scr_num)-94; win_hint.y = 0;
  win_hint.flags = PMinSize|PMaxSize|PPosition;

  win = XCreateSimpleWindow(dpy,
			    RootWindow(dpy, scr_num),
			    win_hint.x, 0, 94, 16, 0, 
			    WhitePixel(dpy, scr_num),
			    BlackPixel(dpy, scr_num)
			    );
  XTextProperty windowName;
  char *wname = "indicator-xkbmod";
  XStringListToTextProperty(&wname, 1, &windowName);
  XClassHint classhint;
  classhint.res_name = wname; classhint.res_class = wname;
  XSetWMProperties(dpy, win, &windowName, NULL, NULL, 0, &win_hint, NULL, &classhint);
  XMapWindow(dpy,win);

  XFontStruct* Font_info;
  char *font_name = "-*-gothic-medium-r-normal-*-16-*-*-*-*-*-*-*";
  XFontStruct *font_info;
  font_info = XLoadQueryFont(dpy, font_name);
  if (!font_info) return 1;

  XGCValues val_bk, val_ledon, val_altgr, val_switch;
  val_bk.foreground = BlackPixel(dpy,scr_num);
  val_bk.font = font_info->fid;
  gc_bk = XCreateGC(dpy, win, GCForeground|GCFont, &val_bk);

  XColor c_altgr, c_switch, c_bk, cexact; Colormap cmap;
  cmap = DefaultColormap(dpy, 0);
  XAllocNamedColor(dpy, cmap, "Gold", &c_bk, &cexact); val_ledon.foreground = c_bk.pixel;
  XAllocNamedColor(dpy, cmap, "rgb:00/C0/C0", &c_altgr, &cexact); val_altgr.foreground = c_altgr.pixel;
  XAllocNamedColor(dpy, cmap, "rgb:00/C0/00", &c_switch, &cexact); val_switch.foreground = c_switch.pixel;

  GC gc_altgr, gc_switch;
  gc_ledon = XCreateGC(dpy, win, GCForeground, &val_ledon);
  gc_altgr = XCreateGC(dpy, win, GCForeground, &val_altgr);
  gc_switch = XCreateGC(dpy, win, GCForeground, &val_switch);
  if ((gc_bk<0)||(gc_ledon<0)) return 1;

  while (True) {
    XNextEvent( dpy, &eve );
    if (eve.type==eventCode) {
      XkbEvent xkb_eve = (XkbEvent) eve;
      if (xkb_eve.any.xkb_type == XkbStateNotify){
	XkbStateNotifyEvent s= xkb_eve.state;
	if (  (s.mods!=p.mods)||(s.group!=p.group) ) {
	  XFillRectangle(dpy,win,gc_bk,0,0, 100,16 );
	  led_mod(s.mods&1, 0, "S"); led_mod(s.mods&4, 1, "C");
	  led_mod(s.mods&8, 2, "A"); led_mod(s.mods&0x40, 3, "W");
	  switch (s.group) {
	    case 1:
	      XFillRectangle(dpy,win,gc_switch,44,0,50,16 );
	      XDrawString(dpy,win,gc_bk,45,15, "Switch", 6);
	    break;
	    case 2:
	      XFillRectangle(dpy,win,gc_altgr,44,0,50,16 );
	      XDrawString(dpy,win,gc_bk,45,15, "AltGr ", 6);
	    break;
	  }
	  p.mods = s.mods; p.group = s.group;
	}
      }
    }
  }
  XCloseDisplay(dpy);
  return 0;
}
