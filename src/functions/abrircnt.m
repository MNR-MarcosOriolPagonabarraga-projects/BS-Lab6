function [CNT]=abrircnt(FILENAME)

% extrae la cabecera del fichero cnt

CNT.FILE.FID=fopen(FILENAME,'r+','ieee-le');   % Abrimos el fichero (lectura)
CNT.FileName = FILENAME;

PPos=min([max(find(FILENAME=='.')) length(FILENAME)+1]);
SPos=max([0 find(FILENAME==filesep)]);
CNT.FILE.Ext = FILENAME(PPos+1:length(FILENAME));  % extensión del fichero
CNT.FILE.Name = FILENAME(SPos+1:PPos-1); % nombre del fichero
if SPos==0,
   CNT.FILE.Path = pwd;  % path del fichero
else
	CNT.FILE.Path = FILENAME(1:SPos-1);  % path del fichero
end;

%CABECERA FIJA
[tmp,count]=fread(CNT.FILE.FID,141,'char');   % Lectura de los primeros 141 bytes
H1=setstr(tmp');
CNT.rev=H1(1:20);   % revision string
CNT.type=H1(21);    % file type AVG=1, EEG=0
CNT.id=H1(22:41);   % patient id
CNT.oper=H1(42:61); % operator id
CNT.doctor=H1(62:81);   % doctor id
CNT.referral=H1(82:101);    % referral id
CNT.hospital=H1(102:121);   % hospital id
CNT.patient=H1(122:141);    % subject name
CNT.age=fread(CNT.FILE.FID,1,'short');   % subject age
[tmp,count]=fread(CNT.FILE.FID,219,'char');   % Lectura de los primeros 219 bytes
H1=setstr(tmp');
CNT.sex=H1(1);    % subject sex Male=M, Female=F
CNT.hand=H1(2);   % handedness Mixed=M, Right=R, Left=L
CNT.med=H1(3:22);    % medications
CNT.class=H1(23:42);  % classification
CNT.state=H1(43:62);  % subject wakefulness
CNT.label=H1(63:82);  % session label
CNT.date=H1(83:92);   % session date string
CNT.time=H1(93:104);   % session time string
CNT.reserved4=H1(105:219);  % reserved space
CNT.compsweeps=fread(CNT.FILE.FID,1,'short');    % number of sweeps   
CNT.acceptcnt=fread(CNT.FILE.FID,1,'short');     % number of accepted sweeps
CNT.rejectcnt=fread(CNT.FILE.FID,1,'short');     % number of rejected sweeps
CNT.pnts=fread(CNT.FILE.FID,1,'short');      % number of points per waverform
CNT.nchannels=fread(CNT.FILE.FID,1,'short'); % number of active channels
[tmp,count]=fread(CNT.FILE.FID,4,'char');   % Lectura de los siguientes 4 bytes
H1=setstr(tmp');
CNT.reserved5=H1(1:3);  % reserved space
CNT.variance=H1(4);   % variance data included flag
CNT.rate=fread(CNT.FILE.FID,1,'ushort'); % D-to-A rate (Hz)
CNT.scale=fread(CNT.FILE.FID,1,'double');    % scale factor for calibration
[tmp,count]=fread(CNT.FILE.FID,111,'char');   % Lectura de los siguientes 111 bytes
H1=setstr(tmp');
CNT.reserved6=H1(1:111);  % reserved space
CNT.dispmin=fread(CNT.FILE.FID,1,'float');   % display minimum
CNT.dispmax=fread(CNT.FILE.FID,1,'float');   % display maximum 
CNT.xmin=fread(CNT.FILE.FID,1,'float');  % epoch start in seconds (neg)
CNT.xmax=fread(CNT.FILE.FID,1,'float');  % epoch stop in seconds
[tmp,count]=fread(CNT.FILE.FID,351,'char');   % Lectura de los siguientes 351 bytes
H1=setstr(tmp');
CNT.reserved7=H1(1:351); % reserved space
CNT.numsamples=fread(CNT.FILE.FID,1,'long');     % number of samples in continuous file
[tmp,count]=fread(CNT.FILE.FID,18,'char');   % Lectura de los siguientes 18 bytes
H1=setstr(tmp');
CNT.reserved8=H1(1:18);  % reserved space
CNT.eventtablepos=fread(CNT.FILE.FID,1,'long');  % offset to the event table
[tmp,count]=fread(CNT.FILE.FID,2,'char');   % Lectura de los siguientes 2 bytes
H1=setstr(tmp');
CNT.reserved9=H1(1:2);  % reserved space
CNT.channeloffset=fread(CNT.FILE.FID,1,'long');      % channel size for SYNAMPS file
[tmp,count]=fread(CNT.FILE.FID,4,'char');   % Lectura de los siguientes 4 bytes
H1=setstr(tmp');
CNT.reserved10=H1(1:4);  % reserved space


%CABECERA VARIABLE
fseek(CNT.FILE.FID,900,'bof');
for (i=1:CNT.nchannels),
    [tmp,count]=fread(CNT.FILE.FID,15,'char');   % Lectura de los siguientes 15 bytes
    H1=setstr(tmp');
    CNT.lab(i,:)=H1(1:10);    % electrode label (last byte NULL)
    CNT.reserved1(i,:)=H1(11:15);     % reserved space
    CNT.n(i,:)=fread(CNT.FILE.FID,1,'short');  % number of observations at each electrode
    [tmp,count]=fread(CNT.FILE.FID,30,'char');   % Lectura de los siguientes 30 bytes
    H1=setstr(tmp');
    CNT.reserved2(i,:)=H1(1:30);    % reserved space
    CNT.baseline(i,:)=fread(CNT.FILE.FID,1,'short');   % baseline offset in raw ad units
    [tmp,count]=fread(CNT.FILE.FID,10,'char');   % Lectura de los siguientes 10 bytes
    H1=setstr(tmp');
    CNT.reserved3(i,:)=H1(1:10);    % reserved space
    CNT.sensivity(i,:)=fread(CNT.FILE.FID,1,'float');  % channel sensivity
    [tmp,count]=fread(CNT.FILE.FID,8,'char');   % Lectura de los siguientes 8 bytes
    H1=setstr(tmp');
    CNT.reserved(i,:)=H1(1:8);    % reserved space
    CNT.calib(i,:)=fread(CNT.FILE.FID,1,'float');  % calibration coefficient
end
%LECTURA DE LA TABLA DE EVENTOS
fseek(CNT.FILE.FID,CNT.eventtablepos,-1);
CNT.tabletype=fread(CNT.FILE.FID,1,'uchar');    % tipo de la tabla de eventos
CNT.tablesize=fread(CNT.FILE.FID,1,'long');     % tamaño de la tabla de eventos en bytes
CNT.nevent=CNT.tablesize/8;     % numero de eventos
for (i=1:CNT.nevent),
    fseek(CNT.FILE.FID,CNT.eventtablepos+9+((i-1)*8),-1);
    CNT.event(i,1)=fread(CNT.FILE.FID,1,'ushort');  % primera columna el tipo de estimulo
    tmp=fread(CNT.FILE.FID,2,'uchar');
    CNT.event(i,2)=tmp(2);  % segunda columna el tipo de respuesta
    tmp=fread(CNT.FILE.FID,1,'long');
    CNT.event(i,3)=(tmp-900-(75*CNT.nchannels))/(2*CNT.nchannels);  % tercera columna el instante del evento en numero de muestras
end

