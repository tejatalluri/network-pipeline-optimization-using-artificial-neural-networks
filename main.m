close all;
clear all;
clc;


%% load data

[num]=xlsread('Book1.xlsx');
[num1]=xlsread('Book2.xlsx');
num2=num(1:2000,1:1);


%% radial bias

a=radbas(num2);

a2 = radbas(num2-10);
a3 = radbas(num2+20);
a4 = a + a2*1 + a3*0.5;

figure(1);
plot(num2,a,'b-',num2,a2,'b--',num2,a3,'b--',num2,a4,'m-')
title('Weighted Sum of Radial Basis Transfer Functions');
xlabel('Input p');
ylabel('Output a');


%% sum-squared error goal

eg = 0.01; 

%% spread constant

sc = 1;    

num2=mapstd(num2);
num1=mapstd(num1);

net = radialbias(num2,num1);


%% Adaptive Neural Network

rng;
num3=num(1:2000,1:1);
X = num3';
T = num1';

size(X);
size(T);

hiddenLayerSize = 20;
net = patternnet(hiddenLayerSize);

%% Set up Division of Data for Training, Validation, Testing

net.trainParam.epochs = 300;
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;


%% Train the Network

[net,tr] = train(net,X,T);

%% Test the Network

outputs = net(X);
errors = gsubtract(T,outputs);
performance = perform(net,T,outputs)

%%

tInd = tr.testInd;
tstOutputs = net(X(:,tInd));
tstPerform = perform(net,T(:,tInd),tstOutputs)


%% View the Network

view(net)
figure(2), plotperform(tr)

%% Adaptive

[net,Y,E,Pf]=adapt(net,X,T);
perf=mse(E)

