%FUNCTION my_omp solves y = Ax, takes the input parameters y, A, k where
%y is the output field, A is the dictionary and k is the sparsity. It
%returns the solution of x.

function  x = my_omp(k, A, y)

    atom_vector = zeros(size(A,2),1);
    ind_atom=[];
    res=y;
    count = 1;
    while count < k+1
        inner_product = abs(A' * res);
        [atom, atom_index] = max(inner_product);
        ind_atom = [ind_atom atom_index];
        xfinal = A(:, ind_atom)\y;
        res = y-A(:,ind_atom) * xfinal;
        count = count + 1;
    end
    x = atom_vector;
    t = ind_atom';
    x(t) = xfinal;
end

