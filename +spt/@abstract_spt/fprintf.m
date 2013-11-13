function count = fprintf(fid, obj, varargin)
% FPRINTF - Print spatial transformation object in Remark text format
%
% ## Usage synopsis
%
% count = fprintf(fid, obj)
% count = fprintf(fid, obj, 'key', value, ...)
%
% Where
%
% FID is a valid file handle.
%
% OBJ is a spt.abstract_spt object.
%
% COUNT is the number of characters printed.
%
%
% ## Accepted key/value pairs
%
% ParseDisp     - Class:    logical scalar
%                 Def:      true
%                 If set to true a summary of the object properties will be
%                 printed by parsing the output produced by method disp()
%
% SaveBinary    - Class:    logical scalar
%                 Def:      false
%                 If set to true, a binary copy of the object will be saved
%                 to disk and a link to to it will be provided in the
%                 generated Remark output.
%
%
% See also: spt

import misc.process_arguments;
import report.disp2table;
import misc.fid2fname;
import mperl.file.spec.rel2abs;
import mperl.file.spec.catfile;
import misc.code2multiline;
import misc.unique_filename;

opt.ParseDisp  = true;
opt.SaveBinary = false;

defCfg = get_method_config(obj, 'fprintf');
[~, opt] = process_arguments(opt, [defCfg(:);varargin(:)]);

count = 0;
if opt.ParseDisp
    myTable = disp2table(obj);
    count = count + fprintf(fid, myTable);
end

if opt.SaveBinary
    fName = rel2abs(fid2fname(fid));
    rPath = fileparts(fName);
    
    % Save binary data
    dataName    = get_name(obj);
    
    newDataFile = unique_filename(catfile(rPath, [dataName '.mat']));
    sptObj = obj; %#ok<NASGU>
    save(newDataFile, 'sptObj');    
   
    count = count + fprintf(fid, '\n%-20s: [%s][%s]\n\n', ...
        'Binary BSS object', [dataName '.mat'], [dataName '-data']);
    
    count = count + fprintf(fid, '[%s]: %s\n', [dataName '-data'], ...
        [dataName '.mat']);
    
    count = count + fprintf(fid, '\n\nTo load to MATLAB''s workspace:\n\n');
    
    count = count + fprintf(fid, '[[Code]]:\n');
    
    code  = sprintf('bss = load(''%s'', ''sptObj'')', newDataFile);
    code  = code2multiline(code, [], char(9));
    count = count + fprintf(fid, '%s\n\n', code);
    
    count = count + fprintf(fid, ...
        '\n\nThen, to get the estimated mixing and separating matrices:\n\n');
    
    count = count + fprintf(fid, '\t%% The mixing (backprojection) matrix:\n');
    count = count + fprintf(fid, '\tA = bprojmat(bss.sptObj);\n\t\n');
    count = count + fprintf(fid, '\t%% The separating (projection) matrix:\n');
    count = count + fprintf(fid, '\tW = projmat(bss.sptObj);\n\n');
end


end