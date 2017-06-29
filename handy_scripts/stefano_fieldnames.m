function stefano_fieldnames(s, target, sString)
    % Created by BK, Jan. 12, 2015
    % Displays structure set of s denoting where target is
    % Only works with numerical target
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