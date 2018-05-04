p = .3
for i=1:200
for j=1:200
dist(i,j) = (abs((i-100))^p+abs((j-100))^p)^(1/p);
end
end
figure; 
imagesc(dist)