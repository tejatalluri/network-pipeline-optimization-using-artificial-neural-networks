function [net,Y,E,Xf,Af,tr]=adapt(net,X,T,Xi,Ai)


if nargin < 1,error(message('nnet:Args:NotEnough')); end
if ~isa(net,'network'), error(message('nnet:adapt:NotANet')); end
if isempty(net.adaptFcn), error(message('nnet:adapt:Undef')); end

xMatrix = ~iscell(X);
if nargin < 3, T = {}; tMatrix = xMatrix; else tMatrix = ~iscell(T); end
if nargin < 4, Xi = {}; xiMatrix = xMatrix; else xiMatrix = ~iscell(Xi); end
if nargin < 5, Ai = {}; aiMatrix = xMatrix; else aiMatrix = ~iscell(Ai); end
[X,err] = nntype.data('format',X);
if ~isempty(err),nnerr.throw(nnerr.value(err,'Inputs'));end
if ~isempty(T), [T,err] = nntype.data('format',T); end
if ~isempty(err),nnerr.throw(nnerr.value(err,'Targets'));end
if ~isempty(Xi), [Xi,err] = nntype.data('format',Xi); end
if ~isempty(err),nnerr.throw(nnerr.value(err,'Input delay states'));end
if ~isempty(Ai), [Ai,err] = nntype.data('format',Ai); end
if ~isempty(err),nnerr.throw(nnerr.value(err,'Layer delay states'));end

% Network
net = struct(net);
[~,zeroDelayLoop] = nn.layer_order(net);
 if zeroDelayLoop, error(message('nnet:NNet:ZeroDelayLoop')); end
[net,X,Xi,Ai,T,~,Q,TS,err] = nntraining.config(net,X,Xi,Ai,T,{1});
if ~isempty(err), nnerr.throw(err), end

% ADAPT NETWORK
% -------------

tools = nn7;
hints = tools.netHints(net,tools.hints);
hints.outputInd = find(net.outputConnect);

% Processed inputs
Pc = tools.pc(net,X,Xi,Q,TS,hints);

% Delayed Inputs
Pd = tools.pd(net,Pc,Q,TS,hints);

% Adapt network
[net,Ac,tr] = feval(net.adaptFcn,net,Pd,T,Ai);
net = class(net,'network');

% Network outputs, errors, final inputs
Al = Ac(:,net.numLayerDelays+(1:TS));
Y = nnMATLAB.post_outputs(hints,Al(hints.outputInd,:));
E = gsubtract(T,Y);
Xf = Pc(:,TS+(1:net.numInputDelays));
Af = Ac(:,TS+(1:net.numLayerDelays));

% FORMAT OUTPUT ARGUMENTS
% -----------------------

if (xMatrix), Y = cell2mat(Y); end
if (tMatrix), E = cell2mat(E); end
if (xiMatrix), Xf = cell2mat(Xf); end
if (aiMatrix), Af = cell2mat(Af); end
  
