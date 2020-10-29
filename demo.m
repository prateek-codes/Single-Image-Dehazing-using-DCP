warning('off','all');


for i=1:1%suppose there are 10 image
    jpgFileName1 = strcat('hazz', num2str(i), '.jpg');
    jpgFileName2= strcat('ori', num2str(i), '.jpg');
	if exist(jpgFileName1, 'file')
        if exist(jpgFileName2, 'file')
        
		image= double(imread(jpgFileName1))/255;
        ori= double(imread(jpgFileName2))/255;
        
        end
    end
tic;

%image = double(imread('Hazy3.jpg'))/255;

image = imresize(image, 0.2);
ori=imresize(ori, 0.2);
%{
rgbmap= colormap(image);
hsv = rgb2hsv(image);
hsvmap= rgb2hsv(rgbmap);
h = hsv(:, :, 1);
s = hsv(:, :, 2);
v = hsv(:, :, 3);
h = adapthisteq(h,'clipLimit',0.02,'Distribution','rayleigh')
s = adapthisteq(s,'clipLimit',0.02,'Distribution','rayleigh');
v = adapthisteq(v,'clipLimit',0.02,'Distribution','rayleigh');
h = edge(h, 'canny');
s = edge(s, 'canny');
v = edge(v, 'canny');
t=cat(3, h,s,v);
t = hsv2rgb(t);

rC = image(:, :, 1);
gC = image(:, :, 2);
bC = image(:, :, 3);
R = adapthisteq(rC,'clipLimit',0.02,'Distribution','rayleigh');
G = adapthisteq(gC,'clipLimit',0.02,'Distribution','rayleigh');
B = adapthisteq(bC,'clipLimit',0.02,'Distribution','rayleigh');
rgbImage = cat(3,R,G,B);
%}
%x= histeq(image)
res = dehaze(image, 0.95, 15);
%result = dehaze(rgbImage, 0.95, 15);
%{
rC = res(:, :, 1);
gC = res(:, :, 2);
bC = res(:, :, 3);
R = adapthisteq(rC,'clipLimit',0.02,'Distribution','rayleigh');
G = adapthisteq(gC,'clipLimit',0.02,'Distribution','rayleigh');
B = adapthisteq(bC,'clipLimit',0.02,'Distribution','rayleigh');
rgbImg = cat(3,R,G,B);
%}
toc;

figure
montage({ori,res})
%figure,imshow(res);%DCP of ori
figure,imshow(result);% CLAHE+DCP
%figure,imshow(rgbImg);% DCP+CLAHE


%{
-------------FADE-----------


disp("----------hazy"+i+"------------");
[D1,D_map1] = FADE(image);
%figure, imshow(image,[])
%title(["FADE of Original image:"+i,num2str(D1)])
disp(D1);
[D3,D_map3] = FADE(x);
%figure, imshow(rgbImage,[])
%title(["FADE of Original image after CLAHE:"+i,num2str(D3)])
disp(D3);
[D2,D_map2] = FADE(result);
%figure, imshow(result,[])
%title(["FADE of dehazed image:"+i,num2str(D2)])
disp(D2);

%}



%{
 %----------------MSR------------
use the maximum chanel as an approximation of the image illumination 
L = max(result, [], 3); 
% compute reflectance using both methods 
ret = MSRetinex(mat2gray(L), 5, 3, 2, [5 5], 8); 
% use value of hsv domain to enhance the image 
Ihsv = rgb2hsv(result); 
Ihsv(:, :, 3) = mat2gray(ret); 
R1 = hsv2rgb(Ihsv);
figure, imshow(R1)
%}



%-------------------SSIM-----------
I = rgb2gray(ori);
R = rgb2gray(res);
[mssim, ssim_map] = ssim(I,R);
disp("Hazy"+i);
disp(mssim);
%}
%{
[D3,D_map3] = FADE(R1);
disp(D3);
%}
%------------------PSNR-------------
%{
peaksnr = psnr(result,image);
disp("Hazy"+i);
disp(peaksnr);

deltaE = deltaE2000(image,result);
disp("Hazy"+i);
disp(deltaE);
%}
warning('on','all');
end;