# GenericDialog
A simple generic dialog for Matlab, to quickly prompt a set of parameters. 
The design is based on ImageJ's "GenericDialog" class, and mimics its functionalities.

## Example

    % create a new dialog, and populate it with some fields
    % each option is defined by a name, a default value, and optionnal settings
    gd = imagem.gui.GenericDialog('Create Image');
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
     
    % retrieve the user inputs
    name = gd.getNextString();
    width = getNextNumber(gd);
    height = getNextNumber(gd);
    type = getNextString(gd);
    display = getNextBoolean(gd);
     
    % Create a new image based on user inputs, and display if requested
    img = zeros([height width ], type);
    if display
        imshow(img);
        title(name);
    end
