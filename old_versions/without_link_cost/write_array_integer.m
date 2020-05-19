function write_array_integer(fileID,array_name,array)
    array_len = length(array);
    formatSpec = 'param\t%s :=';
    fprintf(fileID,formatSpec,array_name);
    formatSpec = '\n\t\t%d\t%d';
    for i=1:array_len
        fprintf(fileID,formatSpec,i,array(i));
    end
    fprintf(fileID,';');
end

