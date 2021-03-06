function [status, res] = svg2pdf(in, out, latex)

import mperl.file.spec.catfile;
import inkscape.inkscape_binary;
import mperl.cwd.abs_path;

in = abs_path(in);

if nargin < 3 || isempty(latex),
    latex = false;
end

if nargin < 2 || isempty(out),
    [path, name] = fileparts(in);
    out = catfile(path, [name '.pdf']);
end

if latex,
    latex = '--export-latex ';
else
    latex = '';
end

cmd = sprintf('"%s" -z %s--export-pdf="%s" "%s"', ...
    inkscape_binary, latex, out, in); 

[status, res] = system(cmd);

end