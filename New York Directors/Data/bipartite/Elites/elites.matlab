% Create a list of nodes in the vector (N)
% Create a list of affiliations with a relevant dimension attached (M)
% Input matrix of links between nodes and affiliations (D)

n = size(N,1);
m = size(M,1);
k = max(M(:,2));
l = size(D,1);

for i = 1:l
	for j = 1:m
		if  D(i,1) == M(j,1)
			D(i,3) = M(j,2);
		end
	end
end

for i = 1:l
	A(D(i,3),D(i,2)) = D(i,3);
end

AA = sum(logical(A));

for i = 1:size(AA,2)
	if 	AA(i)==k
		E(i) = i;
	end
end

E(E==0)=[];

E = transpose(E)

% Need to use D's node projection... (PDN)
% So, first need to node project D to PDN

PDN = [0,0];

n = size(D,1);
for i = 1:n
    for j = i+1:n
        if D(i,1) == D(j,1)
            PDN(size(PDN,1)+1,1) = D(i,2);
        	PDN(size(PDN,1),2) = D(j,2);
        end
    end
end

% Create the elite network structure (B)

B = [0,0];

for i = 1:size(E,1)
	for j = 1:size(E,1)
		for k = 1:size(PDN,1)
			if PDN(k,1)==E(i) && PDN(k,2)==E(j)
				B(size(B,1)+1,1) = E(i);
				B(size(B,1),2) = E(j);
			end
		end
	end
end

B(1,:) = []