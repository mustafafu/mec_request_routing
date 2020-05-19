function write_array_float(fileID,array_name,array)
    array_len = length(array);
    formatSpec = 'param\t%s :=';
    fprintf(fileID,formatSpec,array_name);
    formatSpec = '\n\t\t%d\t%.2f';
    for i=1:array_len
        fprintf(fileID,formatSpec,i,array(i));
    end
    fprintf(fileID,';');
end

