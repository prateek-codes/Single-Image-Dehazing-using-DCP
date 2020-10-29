warning('off','all');
for i=1:1%suppose there are 10 image
    jpgFileName1 = strcat('hazz', num2str(i), '.jpg');
	if exist(jpgFileName1, 'file')
     
        
		image= double(imread(jpgFileName1))/255;
       
        
        end
 
tic;
image = imresize(image, 0.4);
%figure, imshow(image);
rC = image(:, :, 1);
gC = image(:, :, 2);
bC = image(:, :, 3);
R = adapthisteq(rC,'clipLimit',0.02,'Distribution','rayleigh');
G = adapthisteq(gC,'clipLimit',0.02,'Distribution','rayleigh');
B = adapthisteq(bC,'clipLimit',0.02,'Distribution','rayleigh');
rgbImage = cat(3,R,G,B);
result = dehaze_fast(rgbImage, 0.95, 15);%clahe+dcp
reslt = dehaze_fast(image, 0.95, 15);%DCP+clahe
rC = reslt(:, :, 1);
gC = reslt(:, :, 2);
bC = reslt(:, :, 3);
R = adapthisteq(rC,'clipLimit',0.02,'Distribution','rayleigh');
G = adapthisteq(gC,'clipLimit',0.02,'Distribution','rayleigh');
B = adapthisteq(bC,'clipLimit',0.02,'Distribution','rayleigh');
rgbImg = cat(3,R,G,B);
%}
toc;

figure
montage({image,reslt})
figure
montage({reslt,rgbImg})
figure
montage({image,rgbImage})
figure
montage({reslt,result})
%{
figure,imshow(image);%ori image
figure,imshow(rgbImage);%CLAHE
figure,imshow(reslt);%DCP of ori
figure,imshow(result);% CLAHE+DCP
figure,imshow(rgbImg);% DCP+CLAHE
%}



%{
-------------FADE---------------
disp("----------hazy"+i+"------------");
[D1,D_map1] = FADE(image);
%figure, imshow(image,[])
%title(["FADE of Original image:"+i,num2str(D1)])
disp(D1);
[D2,D_map2] = FADE(rgbImage);
%figure, imshow(rgbImage,[])
%title(["FADE of Original image after CLAHE:"+i,num2str(D3)])
disp(D2);
[D3,D_map3] = FADE(result);
%figure, imshow(result,[])
%title(["FADE of dehazed image after clahe of ori image"+i,num2str(D2)])
disp(D3);
[D4,D_map4] = FADE(reslt);
%figure, imshow(result,[])
%title(["FADE of dehazed image before clahe:"+i,num2str(D2)])
disp(D4);
[D5,D_map5] = FADE(rgbImg);
%figure, imshow(result,[])
%title(["FADE of dehazed image after clahe:"+i,num2str(D2)])
disp(D5);
%}

%{
-------------------SSIM-----------
I = rgb2gray(ori);
R = rgb2gray(image);
[mssim, ssim_map] = ssim(I,R);
disp("Hazy"+i);
disp(mssim);
%}

warning('on','all');
end;