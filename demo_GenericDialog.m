%GO  run script for GenericDialog class
%
%   output = go(input)
%
%   Example
%   go
%
%   See also
%
%
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2011-10-18,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% clean up
close all
clear classes %#ok<CLCLS>

% creates a new dialog, and populate it with some fields
gd = GenericDialog('Create Image');
addTextField(gd, 'Name: ', 'New Image');
addNumericField(gd, 'Width: ', 320, 0);
addNumericField(gd, 'Height: ', 200, 0);
addChoice(gd, 'Type: ', {'uint8', 'uint16', 'double'}, 'uint8');
addCheckBox(gd, 'Display', true);
% pack(gd);

% display the dialog, and wait for user
showDialog(gd);

% check if ok or cancel was clicked
if wasCanceled(gd)
    return;
end


name = gd.getNextString();
disp(name);

width = getNextNumber(gd);
height = getNextNumber(gd);
disp([width height]);
type = getNextString(gd);
display = getNextBoolean(gd);

% Create new image, and display if requested
img = zeros([height width ], type);
if display
    imshow(img);
    title(name);
end

