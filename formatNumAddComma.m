% function to add commas into a number without them. eg converts 10000 to
% 10,000
% Author: Angela Rose

function labelText = formatNumAddComma(num)

    str_label = string(num); 
    str_label_len = strlength(str_label);
    str_label_ed = insertBefore(str_label, str_label_len-2, ',');
    labelText = {str_label_ed}; 

end
