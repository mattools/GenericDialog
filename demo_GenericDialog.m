%DEMO_GENERICDIALOG Demo script for the GenericDialog class.
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
% e-mail: david.legland@inrae.fr
% Created: 2011-10-18,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2011 INRA - Cepia Software Platform.

% clean up
close all
clear classes %#ok<CLCLS>

% Creates a new dialog, and populate it with some fields.
% Each option is defined by a name, a default value, and optionnally some
% settings.
gd = GenericDialog('Create Image');
addTextField(gd, 'Name: ', 'New Image');
addNumericField(gd, 'Width: ', 320, 0);
addNumericField(gd, 'Height: ', 200, 0);
addChoice(gd, 'Type: ', {'uint8', 'uint16', 'double'}, 'uint8');
addCheckBox(gd, 'Display', true);

% display the dialog, and wait for user input
showDialog(gd);

% check if ok or canceled was clicked
if wasCanceled(gd)
    return;
end

% retrieve options given by user
name = gd.getNextString();
disp(name);
width = getNextNumber(gd);
height = getNextNumber(gd);
disp([width height]);
type = getNextString(gd);
displayFlag = getNextBoolean(gd);

% Create a new image, and display if requested
img = zeros([height width], type);
if displayFlag
    imshow(img);
    title(name);
end

