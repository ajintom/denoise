%FUNCTION my_omp solves y = Ax, takes the input parameters y, A, k where
%y is the output field, A is the dictionary and k is the sparsity. It
%returns the solution of x.

function  x = my_omp(k, A, y, truth)
    %initialising residue and atoms_array 
    atom_vector = zeros(size(A,2),1);
    ind_atom=[];
    res=y;
    
    thresh = 0;
    res_norm = [];
    sig_norm = [];
    
    count = 1;
    A_dup = A;
    
    % iterations begin
    while count < k+1
        % choosing best atom 
        inner_product = abs(A' * res);
        [atom, atom_index] = max(inner_product);
        
        % append to atom-indices array
        ind_atom = [ind_atom atom_index];
        
        % least-sq solution to y = A * x 
        xfinal = A_dup(:, ind_atom)\y;
        
        % compute residual
        res = y - A_dup(:,ind_atom) * xfinal;
        
        % orthogonlaise dictionary
        for i = 1 : size(A,2)
            A(:,i) = A(:,i) - A(:,i)'*A(:,atom_index) * A(:,atom_index);
        end   
        
        res_norm = [res_norm norm(res,1)];
        sig_norm = [sig_norm norm(y,1)];
        
        disp(norm(res,1)./norm(truth,1))
        
        
        % stopping criteria
        if (res_norm(count)) < thresh * sig_norm(count) 
            break; 
        end
        
        count = count + 1;
    end
    x = atom_vector;
    t = ind_atom';
    x(t) = xfinal;
    
    figure
    plot(res_norm./sig_norm);
    title('SRR')
    
end

