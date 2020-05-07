function write_matrix_integer(fileID,matrix_name,matrix)
    matrix_size = size(matrix);
    formatSpec = 'param\t%s:';
    fprintf(fileID,formatSpec,matrix_name);
    formatSpec = ' %d';
    for jj=1:matrix_size(2)
        fprintf(fileID,formatSpec,jj);
    end
    fprintf(fileID,':=');
%     formatSpec = '\n\t\t%d\t%d';
    for ii=1:matrix_size(1)
        fprintf(fileID,'\n\t\t%d\t',ii);
        for jj = 1:matrix_size(2)
            fprintf(fileID,' %d',matrix(ii,jj));
        end
    end
    fprintf(fileID,';');
end

