D  = [insert a tuple matrix];

n = size(D,1);
for i = 1:n
    for j = i+1:n
        if D(i,1)~=D(j,1) && D(i,2)==D(j,2)
            fprintf('%0.0f,%0.0f\n',D(i,1),D(j,1))
        end
    end
end