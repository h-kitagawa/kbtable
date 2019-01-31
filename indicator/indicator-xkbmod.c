// gcc -g -o indicator-xkbmod indicator-xkbmod.c -lX11 && ./indicator-xkbmod
#include <stdio.h>
#include <string.h>
#include <X11/XKBlib.h>
#include <X11/Xutil.h>

Display *dpy;
Window win;
GC gc_bk, gc_ledon;
XSizeHints win_hint;

void led_mod(int flag, int x, char *s) {
  if (flag) {
    XFillRectangle(dpy,win,gc_ledon,9*x,0,8,win_hint.min_height );
    XDrawString(dpy,win,gc_bk,9*x+1,14, s, 1);
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
  win_hint.min_width =  97; win_hint.max_width  = 97;
  win_hint.min_height = 16; win_hint.max_height = win_hint.min_height;
  win_hint.x = DisplayWidth(dpy,scr_num)-97; win_hint.y = 0;
  win_hint.flags = PMinSize|PMaxSize|PPosition;

  win = XCreateSimpleWindow(dpy,
			    RootWindow(dpy, scr_num),
			    win_hint.x, 0, win_hint.min_width, win_hint.min_height, 0,  
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
  char *font_name = "-*-fixed-bold-r-normal-*-14-*-*-*-*-*-iso8859-1";
  char *font_name2 = "-*-gothic-bold-r-normal-*-14-*-*-*-*-*-iso8859-1";
  XFontStruct *font_info;
  font_info = XLoadQueryFont(dpy, font_name);
  if (!font_info) {
    font_info = XLoadQueryFont(dpy, font_name2);
    if (!font_info) return 1;
  }

  XGCValues val_bk, val_ledon, val_altgr, val_switch, val_num;
  val_bk.foreground = BlackPixel(dpy,scr_num);
  val_bk.font = font_info->fid;
  gc_bk = XCreateGC(dpy, win, GCForeground|GCFont, &val_bk);

  XColor c_altgr, c_switch, c_bk, c_num, cexact; Colormap cmap;
  cmap = DefaultColormap(dpy, 0);
  XAllocNamedColor(dpy, cmap, "rgb:FF/DF/08", &c_bk, &cexact); val_ledon.foreground = c_bk.pixel;
  XAllocNamedColor(dpy, cmap, "rgb:FF/5F/5F", &c_num, &cexact); val_num.foreground = c_num.pixel;
  XAllocNamedColor(dpy, cmap, "rgb:00/E0/E0", &c_altgr, &cexact); val_altgr.foreground = c_altgr.pixel;
  XAllocNamedColor(dpy, cmap, "rgb:00/E0/00", &c_switch, &cexact); val_switch.foreground = c_switch.pixel;

  GC gc_altgr, gc_switch, gc_num;
  gc_ledon = XCreateGC(dpy, win, GCForeground, &val_ledon);
  gc_num = XCreateGC(dpy, win, GCForeground, &val_num);
  gc_altgr = XCreateGC(dpy, win, GCForeground, &val_altgr);
  gc_switch = XCreateGC(dpy, win, GCForeground, &val_switch);
  if ((gc_bk<0)||(gc_ledon<0)) return 1;

#define BUF_SIZE 256
  unsigned char buf[BUF_SIZE];
  while (True) {
    XNextEvent( dpy, &eve );
    if (eve.type==eventCode) {
      XkbEvent xkb_eve = (XkbEvent) eve;
      if (xkb_eve.any.xkb_type == XkbStateNotify){
	XkbStateNotifyEvent s= xkb_eve.state;
	if (  (s.mods!=p.mods)||(s.group!=p.group) ) {
	  XFillRectangle(dpy,win,gc_bk,0,0, 100,win_hint.min_height );
	  led_mod(s.mods&1, 0, "s"); led_mod(s.mods&4, 1, "c");
	  led_mod(s.mods&0x40, 2, "w"); led_mod(s.mods&8, 3, "a"); 
      led_mod(s.mods&0x10, 4, "N"); led_mod(s.mods&0x80, 5, "S"); 
	  switch (s.group) {
	    case 1:
	      XFillRectangle(dpy,win,gc_switch,54,0,50,win_hint.min_height );
	      XDrawString(dpy,win,gc_bk,55,14, "Switch", 6);
	    break;
	    case 2:
	      XFillRectangle(dpy,win,gc_altgr,54,0,50,win_hint.min_height );
	      XDrawString(dpy,win,gc_bk,55,14, "AltGr ", 6);
	    break;
	    case 3:
	      XFillRectangle(dpy,win,gc_num,54,0,50,win_hint.min_height );
	      XDrawString(dpy,win,gc_bk,55,14, "Group3", 6);
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
