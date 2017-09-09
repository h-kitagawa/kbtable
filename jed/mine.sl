$1 = "white"; $2 = "black";
set_color("normal", $1, $2);	       % default fg/bg
set_color("status", "yellow", "blue"); % status or mode line
set_color("region", "yellow", "blue"); % for marking regions
set_color("operator", $1, $2);	       % +, -, etc..
set_color("number", "yellow", $2);     % 10, 2.71,... TeX formulas
set_color("comment", "color034", $2);    % /* comment */
set_color("string", "yellow", $2);    % "string" or 'char'
set_color("keyword", "color147", $2); % if, while, unsigned, ...
set_color("keyword1", "green", $2);    % malloc, exit, etc...
set_color("delimiter", "yellow", $2);	       % {}[](),.;...
set_color("preprocess", "cyan", $2);% #ifdef ....
set_color("message", "cyan", $2);% color for messages
set_color("error", "brightred", $2);   % color for errors
set_color("dollar", "magenta", $2);    % color dollar sign continuat$
set_color("...", "red", $2);	       % folding indicator

set_color ("menu_char", "green", "gray");
set_color ("menu", "white", "gray");
set_color ("menu_popup", "white", "gray");
set_color ("menu_shadow", "blue", "black");
set_color ("menu_selection", "black", "white");
set_color ("menu_selection_char", "brightred", "white");

set_color ("cursor", "black", "red");
set_color ("cursorovr", "black", "cyan");

%% The following have been automatically generated:
set_color("linenum", "yellow", "blue");
set_color("trailing_whitespace", "black", "magenta");
set_color("tab", "yellow", $2);
set_color("url", "magenta", $2);
set_color("italic", $1, $2);
set_color("underline", "green", $2);
set_color("bold", "brightred", $2);
set_color("html", "brightred", $2);
set_color("keyword2", "black", "red"); % 全角空白
set_color("keyword3", "color118", $2); % def, newcommand
set_color("keyword4", $1, $2);
set_color("keyword5", $1, $2);
set_color("keyword6", $1, $2);
set_color("keyword7", $1, $2);
set_color("keyword8", $1, $2);
set_color("keyword9", $1, $2);
