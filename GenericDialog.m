classdef GenericDialog < handle
%GENERICDIALOG A generic dialog, similar to ImageJ's.
%
%   Class GenericDialog
%
%   Example
%     % creates a new dialog, and populates it with some fields
%     gd = GenericDialog('Create Image');
%     addTextField(gd, 'Name: ', 'New Image');
%     addNumericField(gd, 'Width: ', 320, 0);
%     addNumericField(gd, 'Height: ', 200, 0);
%     addChoice(gd, 'Type: ', {'uint8', 'uint16', 'double'}, 'uint8');
%     addCheckBox(gd, 'Display', true);
%
%     % displays the dialog, and waits for user
%     showDialog(gd);
%     % check if ok or cancel button was clicked
%     if wasCanceled(gd)
%         return;
%     end
%
%     % retrieve the user inputs
%     name     = getNextString(gd);
%     width    = getNextNumber(gd);
%     height   = getNextNumber(gd);
%     type     = getNextString(gd);
%     display = getNextBoolean(gd);
%
%     % create a new image based on user inputs
%     img = zeros([height width], type);
%     if display
%         imshow(img);
%         title(name);
%     end
%
%   See also
%     inputdlg, figure, uix.VBox

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2014-04-18,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2014 INRA - Cepia Software Platform.


%% Properties
properties
    handles;
    
    controlHandles = [];
    currentIndex = 1;
    
    boxSizes = [];
    
    % a list of answers (one cell for each item that was added).
    answers = {};
    
    % the string corresponding to the button used to close the dialog.
    % can be one of 'ok', 'cancel'.
    closingButton = '';
    
end % end properties


%% Constructor
methods
    function obj = GenericDialog(varargin)
        % Constructor for GenericDialog class.

        createLayout(obj, varargin{:});
    end

end % end constructors

methods (Access = private)
    function createLayout(obj, varargin)
        % Initialize the layout (figure and widgets).
        hf = createFigure(obj, varargin{:});
        obj.handles.figure = hf;
        
        % vertical layout for widgets and control panels
        vb  = uix.VBox('Parent', hf, 'Spacing', 5, 'Padding', 5);
        
        % create an empty panel that will contain widgets
        obj.handles.mainPanel = uix.VBox('Parent', vb);
        
        % button for control panel
        buttonsPanel = uix.HButtonBox('Parent', vb, 'Padding', 5);
        uicontrol( 'Parent', buttonsPanel, ...
            'String', 'OK', ...
            'Callback', @obj.onButtonOK);
        uicontrol( 'Parent', buttonsPanel, ...
            'String', 'Cancel', ...
            'Callback', @obj.onButtonCancel);
        
        set(vb, 'Heights', [-1 40] );

    end
    
     function hf = createFigure(obj, varargin)
        % Create new figure and return its handle.
        
        % parse dialog title
        if isempty(varargin)
            dlgName = 'Generic Dialog';
        else
            dlgName = varargin{1};
        end

        % computes a new handle index large enough not to collide with
        % common figure handles
        while true
            newFigHandle = 30000 + randi(10000);
            if ~ishandle(newFigHandle)
                break;
            end
        end
        
        % create the figure that will contains the display
        hf = figure(newFigHandle);
        
        set(hf, ...
            'Name', dlgName, ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'Toolbar', 'none', ...
            'NextPlot', 'new', ...
            'WindowStyle', 'modal', ...
            'Visible', 'off');
        
        set(hf, 'units', 'pixels');
        pos = get(hf, 'Position');
        pos(3:4) = [200 250];
        set(hf, 'Position', pos);
        
        obj.handles.figure = hf;
     end
end

%% Generic Methods
methods
    function showDialog(obj)
        % Make the dialog visible, and waits for user validation.
        setVisible(obj, true);
        waitForUser(obj);
    end
    
    function setSize(obj, newSize, unit)
        if ~isa('unit', 'var')
            unit = 'pixels';
        end
        set(obj.handles.figure, 'units', unit);
        pos = get(obj.handles.figure, 'Position');
        pos(3:4) = newSize;
        set(obj.handles.figure, 'Position', pos);
    end
    
    function setVisible(obj, value)
        if value
            set(obj.handles.figure, 'Visible', 'on');
            set(obj.handles.figure, 'WindowStyle', 'modal');
        else
            set(obj.handles.figure, 'Visible', 'off');
        end
    end
    
    function b = wasOked(obj)
        b = strcmp(obj.closingButton, 'ok');
    end
    
    function b = wasCanceled(obj)
        b = strcmp(obj.closingButton, 'cancel');
    end
    
    function closeFigure(obj)
        % close the current figure
        if ~isempty(obj.handles.figure)
            close(obj.handles.figure);
        end
    end
end

%% Management of choice items
methods
    function [h, ht] = addTextField(obj, label, text, cb)
        % Add a text field to this dialog.
        %
        % usage:
        %   addTextField(GD, LABEL, INPUTTEXT);
        
        
        hLine = uix.HBox('Parent', obj.handles.mainPanel, ...
            'Spacing', 5, 'Padding', 5);
        
        % Label of the widget
        ht = addLabel(hLine, label);
        
        % creates the new control
        %         bgColor = getWidgetBackgroundColor(this);
        bgColor = [1 1 1];
        h = uicontrol(...
            'Style', 'Edit', ...
            'Parent', hLine, ...
            'String', text, ...
            'BackgroundColor', bgColor);
        if exist('cb', 'var')
            set(h, 'Callback', cb);
        end
        
        % keep widget handle for future use
        obj.controlHandles = [obj.controlHandles h];
        
        % setup size in horizontal direction
        set(hLine, 'Widths', [-5 -5]);
        
        % update vertical size of widgets
        obj.boxSizes = [obj.boxSizes 35];
        set(obj.handles.mainPanel, 'Heights', obj.boxSizes);
    end
    
    function [h, ht] = addNumericField(obj, label, value, nDigits, cb)
        % Add a numeric text field to this dialog.
        %
        % usage:
        %   addNumericField(GD, LABEL, INPUTTEXT);
        
        % create horizontal box
        hLine = uix.HBox('Parent', obj.handles.mainPanel, ...
            'Spacing', 5, 'Padding', 5);
        
        % Label of the widget
        ht = addLabel(hLine, label);
        
        % create initial text from value
        pattern = ['%.' num2str(nDigits) 'f'];
        text = sprintf(pattern, value);
        
        % creates the new control
        %         bgColor = getWidgetBackgroundColor(this);
        bgColor = [1 1 1];
        h = uicontrol(...
            'Style', 'Edit', ...
            'Parent', hLine, ...
            'String', text, ...
            'BackgroundColor', bgColor);
        if exist('cb', 'var')
            set(h, 'Callback', cb);
            set(h, 'KeyPressFcn', cb);
        end
        
%         % try to add a key press listener
%         jtf = findjobj(h);
%         jtfh = handle(jtf, 'callbackproperties');
%         set(jtfh, 'KeyPressedCallback', 'disp(''text modified'')')
%         h2 = uicontrol('style', 'edit', 'string', 'Hello!');
        
        % keep widget handle for future use
        obj.controlHandles = [obj.controlHandles h];
        
        % setup size in horizontal direction
        set(hLine, 'Widths', [-5 -5]);
        
        % update vertical size of widgets
        obj.boxSizes = [obj.boxSizes 35];
        set(obj.handles.mainPanel, 'Heights', obj.boxSizes);
    end
    
    function h = addCheckBox(obj, label, checked, cb)
        % Add a check box for choosing a boolean to this dialog.
        %
        % usage:
        %   addCheckBox(GD, LABEL, STATE);
        
        % create horizontal box
        hLine = uix.HBox('Parent', obj.handles.mainPanel, ...
            'Spacing', 5, 'Padding', 5);

        % use default value if not specified
        if ~exist('checked', 'var')
            checked = false;
        end

        % creates the new control
        %         bgColor = getWidgetBackgroundColor(this);
%         bgColor = [1 1 1];
        h = uicontrol(...
            'Style', 'Checkbox ', ...
            'Parent', hLine, ...
            'String', label, ...
            'Value', checked);
        if exist('cb', 'var')
            set(h, 'Callback', cb);
        end
        
        % keep widget handle for future use
        obj.controlHandles = [obj.controlHandles h];
        
        % setup size in horizontal direction
        set(hLine, 'Widths', -5);
        
        % update vertical size of widgets
        obj.boxSizes = [obj.boxSizes 25];
        set(obj.handles.mainPanel, 'Heights', obj.boxSizes);
    end
    
    function [h, ht] = addChoice(obj, label, choiceLabels, initialValue, cb)
        % Add choice as a popupmenu.
        %
        % usage:
        %   addChoice(GD, LABEL, CHOICES, INITIALVALUE);
        
        % create horizontal box
        hLine = uix.HBox('Parent', obj.handles.mainPanel, ...
            'Spacing', 5, 'Padding', 5);
        
        % Label of the widget
        ht = addLabel(hLine, label);
        
        % set initial value as numeric if not the case
        if ~exist('initialValue', 'var')
            initialValue = 1;
            
        elseif ischar(initialValue)
            ind = find(strcmp(choiceLabels, initialValue), 1);
            if isempty(ind)
                error(['Could not find initial value [' initialValue ...
                    '] within the list of choices']);
            end
            initialValue = ind;
        end
        
        % creates the new control
        %         bgColor = getWidgetBackgroundColor(this);
        bgColor = [1 1 1];
        h = uicontrol(...
            'Style', 'PopupMenu', ...
            'Parent', hLine, ...
            'String', choiceLabels, ...
            'Value', initialValue, ...
            'BackgroundColor', bgColor);
        if isa('cb', 'var')
            set(h, 'Callback', cb);
        end
        
        % keep widget handle for future use
        obj.controlHandles = [obj.controlHandles h];
        
        % setup size in horizontal direction
        set(hLine, 'Widths', [-5 -5]);
        
        % update vertical size of widgets
        obj.boxSizes = [obj.boxSizes 35];
        set(obj.handles.mainPanel, 'Heights', obj.boxSizes);
    end
    
end % end methods


%% get widget results
methods
    function string = getNextString(obj)
        h = getNextControlHandle(obj);
        
        string = get(h, 'String');
        
        if strcmp(get(h, 'style'), 'popupmenu')
            index = get(h, 'value');
            string = string{index};
        end
    end
    
    function index = getNextChoiceIndex(obj)
        h = getNextControlHandle(obj);
        
        if ~strcmp(get(h, 'style'), 'popupmenu')
            error('Next control must be a popup menu');
        end
        index = get(h, 'value');
    end
    
    function value = getNextNumber(obj)
        h = getNextControlHandle(obj);
        
        string = get(h, 'String');
        value = str2double(string);
        if isnan(value)
            error(['Could not parse value in string: ' string]);
        end
    end
    
    function value = getNextBoolean(obj)
        h = getNextControlHandle(obj);
        
        type = get(h, 'style');
        if ~strcmp(type, 'checkbox')
            error(['Next item must be a checkbox, not a ' type]);
        end
        value = get(h, 'value');
    end
    
    function h = getNextControlHandle(obj)
        % Iterate along the widgets, and returns the next handle.
        % throw an error if no more 
        if obj.currentIndex > length(obj.controlHandles)
            error('No more widget to process');
        end
        
        h = obj.controlHandles(obj.currentIndex);
        obj.currentIndex = obj.currentIndex + 1;
    end
    
    function resetCounter(this)
        this.currentIndex = 1;
    end
end


%% Figure and control Callback
methods
    function onButtonOK(obj, varargin)
        obj.closingButton = 'ok';
        set(obj.handles.figure, 'Visible', 'off');
    end
    
    function onButtonCancel(obj, varargin)
        obj.closingButton = 'cancel';
        set(obj.handles.figure, 'Visible', 'off');
    end
    
    function button = waitForUser(obj)
        waitfor(obj.handles.figure, 'Visible', 'off');
        button = obj.closingButton;
    end
end

end % end classdef

%% Utility functions

function ht = addLabel(parent, label)
% Add a label to a widget, with predefined settings.
ht = uicontrol('Style', 'Text', ...
    'Parent', parent, ...
    'String', label, ...
    'FontWeight', 'Normal', ...
    'FontSize', 10, ...
    'FontWeight', 'Normal', ...
    'HorizontalAlignment', 'Right');
end