function stefano_fieldnames(s, target, sString)
    % Created by BK, Jan. 12, 2015
    % Displays structure set of s denoting where target is
    % Only works with numerical target
    
    % THIS MODIFICATION MAKES IT WORK IF YOUR INPUT HAS 2 DIGITS AFTER THE
    % DECIMAL. FOR EXAMPLE, IF YOU INPUT 64.58 IT WILL GIVE YOU ALL PLACES WHERE
    % THE VALUE ROUNDS UP TO THAT, SUCH AS 64.580071664753500 (THESE ARE ACTUAL
    % VALUES FROM FILE 
    % C:\Documents and Settings\stefanopeca\MyDocuments\EPID_dosimetry_RESEARCH\R012987-3\RP.1.2.246.352.71.5.542985299129.1372903.20140725081558.dcm
    
    % Does not display the index within an array
    %
    % Inputs:
    %   s       : structure to be search
    %   target  : target (numerical) to be searched for
    %   sString : string of structure name

    fields = fieldnames(s);
    
    for i = 1 : length(fields)
        if isstruct(s.(fields{i}))
            newsString = [sString, '.', fields{i}];
            stefano_fieldnames(s.(fields{i}), target, newsString);
        elseif find(.01*round(100*(s.(fields{i}))) == target, 1, 'first')
            disp([sString, '.', fields{i}]);
        end    
    end
end